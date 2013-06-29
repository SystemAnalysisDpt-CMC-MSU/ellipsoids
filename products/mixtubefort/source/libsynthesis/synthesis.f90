module m_synthesis

use m_mpi
use m_profile

implicit none

!private

! parameters for f
integer p_nx
double precision, pointer :: p_X(:, :)
double precision, pointer :: p_F(:, :)
double precision, pointer :: p_dx(:)

public :: synthesis

contains

subroutine synthesis_all(nx, nu, nl, E, dx, B, pc, P, X, u, ell, dmin, kmin)
    integer, intent(in), value :: nx !< state dimension
    integer, intent(in), value :: nu !< control dimension
    integer, intent(in), value :: nl !< number of directions
    double precision, intent(in) :: E(nx, nx) !< fundamental matrix X(t_1, t)
    double precision, intent(in), target :: dx(nx) !< displacement of current state from the center of the reach set
    double precision, intent(in) :: B(nx, nu) !< control matrix
    double precision, intent(in) :: pc(nu) !< center of control ellipsoid
    double precision, intent(in) :: P(nu, nu) !< matrix of control ellipsoid
    double precision, intent(in), target :: X(nx, nx, nl) !< matrix of EA of the reach set

    double precision, intent(out) :: u(nu) !< control value
    double precision, intent(out) :: ell(nx) !< aiming direction
    double precision, intent(out) :: dmin !< distance to the reach set
    integer, intent(out) :: kmin !< number of the closest ellipsoid

    double precision uk(nu), dk
    integer k
#ifdef MPI
    integer(MPI_ACCI) rank, src, n4, k4
    double precision xchg_in(2), xchg_out(2)
#endif

    u = pc
    dmin = huge(dmin)
    do k = 1,nl
        call synthesis(nx, nu, E, dx, B, pc, P, X(:, :, k), uk, ell, dk)
        if( dk < dmin ) then
            dmin = dk
            u = uk
            kmin = k
        end if
    end do

#ifdef MPI
    call profiler%toc(tag = "SYNTHESIS")
    call MPI_comm_rank(MPI_COMM_WORLD, rank, ierr)

    xchg_in(1) = dmin
    xchg_in(2) = rank

    call MPI_allreduce(xchg_in, xchg_out, 1_MPI_ACCI, MPI_2DOUBLE_PRECISION, MPI_MINLOC, MPI_COMM_WORLD, ierr)

    dmin = xchg_out(1)
    src = idnint(xchg_out(2))

    n4 = nu
    call MPI_bcast(u, n4, MPI_DOUBLE_PRECISION, src, MPI_COMM_WORLD, ierr)
    n4 = nl
    call MPI_bcast(ell, n4, MPI_DOUBLE_PRECISION, src, MPI_COMM_WORLD, ierr)
    k4 = kmin
    call MPI_bcast(k4, 1_MPI_ACCI, MPI_INTEGER, src, MPI_COMM_WORLD, ierr)
    kmin = kmin + (src+1)*1000
    call profiler%toc(tag = "SYNTHESIS/NET")
#endif
end subroutine

!> Control synthesis (for single ellipsoid)
subroutine synthesis(nx, nu, E, dx, B, pc, P, X, u, ell, d)
    integer, intent(in), value :: nx !< state dimension
    integer, intent(in), value :: nu !< control dimension
    double precision, intent(in) :: E(nx, nx) !< fundamental matrix X(t_1, t)
    double precision, intent(in), target :: dx(nx) !< displacement of current state from the center of the reach set
    double precision, intent(in) :: B(nx, nu) !< control matrix
    double precision, intent(in) :: pc(nu) !< center of control ellipsoid
    double precision, intent(in) :: P(nu, nu) !< matrix of control ellipsoid
    double precision, intent(in), target :: X(nx, nx) !< matrix of EA of the reach set

    double precision, intent(out) :: u(nu) !< control value
    double precision, intent(out) :: ell(nx) !< aiming direction
    double precision, intent(out) :: d !< distance to the reach set

    double precision, target :: F(nx, nx)
    double precision lambda0, lambda1, lambda, eps, Xell(nx), Fell(nx), Bell(nu), PBell(nu)
    integer info

    u = pc
    ell = 0
    d = 0
    
    ! F = matmul(E, transpose(E))
    call dgemm('N', 'T', nx, nx, nx, 1D0, E, nx, E, nx, 0D0, F, nx)

    ! assign global variables
    p_nx = nx
    p_X => X
    p_dx => dx
    p_F => F

    ! take small lambda0 and check the value of f
    lambda0 = 1D-16
    if( synthesis_f_p(lambda0) <= 0 ) then
        ! we are inside the reach set
        d = 0
        ell = 0
        u = pc
    else
        ! outside the reach set
        ! search for lambda1
        lambda1 = 1D-2
        do while( synthesis_f_p(lambda1) > 0 )
            lambda0 = lambda1
            lambda1 = lambda1 * 2
        end do

        ! find the root of f
        eps = (lambda1 - lambda0) * 1D-10
        call c05adf(lambda0, lambda1, eps, 0D0, synthesis_f_p, lambda, info)

        ! find the rest
        call synthesis_ell(nx, lambda, dx, X, F, ell)
        ell = 2 * lambda * ell
        ! Xell = matmul(X, ell)
        call dsymv('U', nx, 1D0, X, nx, ell, 1, 0D0, Xell, 1)
        ! Fell = matmul(F, ell)
        call dsymv('U', nx, 1D0, F, nx, ell, 1, 0D0, Fell, 1)

        !d = sqrt(dot_product(ell, dx - Fell/4) - sqrt(dot_product(ell, Xell)))
        d = sqrt(dot_product(ell, dx - Fell/4) - sqrt(dot_product(ell, Xell)))
        ! Bell = matmul(transpose(B)
        call dgemv('T', nx, nu, 1D0, B, nx, ell, 1, 0D0, Bell, 1)
        PBell = matmul(P, Bell)
        u = pc - PBell / sqrt(dot_product(Bell, PBell))
    end if
end subroutine

subroutine synthesis_ell(nx, lambda, dx, X, F, ell)
    integer, intent(in), value :: nx !< state dimension
    double precision, intent(in), value :: lambda !< value of lambda
    double precision, intent(in) :: dx(nx) !< displacement of current state from the center of the reach set
    double precision, intent(in) :: X(nx, nx) !< matrix of EA of the reach set
    double precision, intent(in) :: F(nx, nx) !< F matrix
    double precision, intent(out) :: ell(nx) !< computed direction

    double precision M(nx, nx), work(64*nx) 
    integer ipiv(nx), info

    M = X + lambda * F
    ! ell = M^{-1} dx 
    ell = dx
    call dsysv('U', nx, 1, M, nx, ipiv, ell, nx, work, 64*nx, info)
end subroutine

function synthesis_f(nx, lambda, dx, X, F) result(v)
    integer, intent(in), value :: nx !< state dimension
    double precision, intent(in), value :: lambda !< value of lambda
    double precision, intent(in) :: dx(nx) !< displacement of current state from the center of the reach set
    double precision, intent(in) :: X(nx, nx) !< matrix of EA of the reach set
    double precision, intent(in) :: F(nx, nx) !< F matrix
    double precision v !< function value

    double precision ell(nx), Xell(nx)

    call synthesis_ell(nx, lambda, dx, X, F, ell)
    call dsymv('U', nx, 1D0, X, nx, ell, 1, 0D0, Xell, 1)
    v = sqrt(max(0D0, dot_product(ell, Xell))) - 1
end function

function synthesis_f_p(lambda) result(v)
    double precision, intent(in) :: lambda !< value of lambda
    double precision v !< function value

    v = synthesis_f(p_nx, lambda, p_dx, p_X, p_F)
end function

end module
