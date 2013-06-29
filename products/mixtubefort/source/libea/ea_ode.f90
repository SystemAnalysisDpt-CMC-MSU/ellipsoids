module m_ea_ode

use m_linalg
use m_profile
use m_operator

implicit none

!> input data for ellipsoidal approximation
type t_ea_ode
    integer nx !< state dimension
    integer nl !< number of directions
    integer ny !< total dimension

    logical f_dynamics !< dynamics flag
    logical f_control !< control flag
    logical f_disturbance !< disturbance flag
    logical f_interchange !< interchange (take convex combinations) of approximations

    double precision alpha !< parameter alpha

    class(t_operator), pointer :: operator_A => null() !< linear dynamics
    double precision, allocatable :: sBPB(:, :) !< sqrtm(B*P*B')
    double precision, allocatable :: CQC(:, :) !< sqrtm(C*Q*C')
    double precision, allocatable :: Bp(:) !< B*p
    double precision, allocatable :: Cq(:) !< C*q

    integer :: call_count !< function call counter
contains
    procedure initialize => ea_ode_initialize
    procedure packvars => ea_ode_packvars
    procedure unpackvars => ea_ode_unpackvars
    procedure rhs => ea_ode_rhs
end type

type(t_ea_ode) ea_ode

contains

subroutine the_ea_ode(t, y, dy)
    double precision, intent(in) :: t !< current time
    double precision, intent(in) :: y(ea_ode%ny) !< packed vector - current state
    double precision, intent(out) :: dy(ea_ode%ny) !< packed vector - derivatives
    call ea_ode%rhs(t, y, dy)
end subroutine

subroutine ea_ode_initialize(this, nx, nu, nv, nl, operator_A, B, pc, P, C, qc, Q, alpha)
    class(t_ea_ode) this

    integer, intent(in), value :: nx !< state dimension
    integer, intent(in), value :: nu !< control dimension
    integer, intent(in), value :: nv !< distrubance dimension
    integer, intent(in), value :: nl !< number of directions

    class(t_operator), intent(in), pointer :: operator_A !< linear dynamics 
    double precision, intent(in) :: B(nx, nu) !< control input matrix
    double precision, intent(in) :: pc(nu) !< center of control ellipsoid
    double precision, intent(in) :: P(nu, nu) !< control ellipsoid matrix
    double precision, intent(in) :: C(nx, nv) !< disturbance input matrix
    double precision, intent(in) :: qc(nv) !< center of disturbance ellipsoid
    double precision, intent(in) :: Q(nv, nv) !< disturbance ellipsoid matrix

    double precision, intent(in), value :: alpha !< parameter alpha

    double precision T(nx, nx) !< temporary matrix

    this%call_count = 0
    this%nx = nx
    this%nl = nl
    this%ny = nx + nx*nx + nx*nl + nx*(nx+1)*nl/2
    
    this%alpha = alpha
    this%f_interchange = (alpha /= 0)

    ! copy A
    this%f_dynamics = associated(operator_A)
    this%operator_A => operator_A

    ! compute sqrtm(B*P*B') and B*p
    this%f_control = nu > 0 .and. any(P /= 0)
    if( this%f_control ) then
        allocate( this%sBPB(nx, nx) )
        T = matmul(B, matmul(P, transpose(B)))
        call sqrtm(nx, T, this%sBPB)

        allocate( this%Bp(nx) )
        this%Bp = matmul(B, pc)
    end if

    ! compute C*Q*C' and Q*c
    this%f_disturbance = nv > 0 .and. any(Q /= 0)
    if( this%f_disturbance ) then
        allocate( this%CQC(nx, nx) )
        this%CQC = matmul(C, matmul(Q, transpose(C)))

        allocate( this%Cq(nx) )
        this%Cq = matmul(C, qc)
    end if
end subroutine

!> Packs all variables into a single vector
subroutine ea_ode_packvars(this, xc, E, S, X, y)
    class(t_ea_ode), intent(in) :: this
    double precision, intent(in) :: xc(this%nx) !< center of approximation
    double precision, intent(in) :: E(this%nx, this%nx) !< fundamental matrix
    double precision, intent(in) :: S(this%nx, this%nl) !< adjoint variables
    double precision, intent(in) :: X(this%nx, this%nx, this%nl) !< matrices of ellipsoidal approximations
    double precision, intent(out) :: y(this%ny) !< packed vector

    integer k, j, i

    associate( nx => this%nx, nl => this%nl )
        k = 0
        y(k+1:k+nx) = xc; k = k + nx
        y(k+1:k+nx*nx) = reshape(E, [nx*nx]); k = k + nx*nx
        y(k+1:k+nx*nl) = reshape(S, [nx*nl]); k = k + nx*nl

        do j = 1,nl
            do i = 1,nx
                y(k+1:k+i) = X(1:i, i, j); k = k + i
            end do
        end do
    end associate
end subroutine

!> Unpacks a vector packed by packvars
subroutine ea_ode_unpackvars(this, y, xc, E, S, X)
    class(t_ea_ode), intent(in) :: this
    double precision, intent(in) :: y(this%ny) !< packed vector
    double precision, intent(out) :: xc(this%nx) !< center of approximation
    double precision, intent(out) :: E(this%nx, this%nx) !< fundamental matrix
    double precision, intent(out) :: S(this%nx, this%nl) !< adjoint variables
    double precision, intent(out) :: X(this%nx, this%nx, this%nl) !< matrices of ellipsoidal approximations

    integer k, j, i

    associate( nx => this%nx, nl => this%nl )
        k = 0
        xc = y(k+1:k+nx); k = k + nx
        E = reshape(y(k+1:k+nx*nx), [nx, nx]); k = k + nx*nx
        S = reshape(y(k+1:k+nx*nl), [nx, nl]); k = k + nx*nl

        do j = 1,nl
            do i = 1,nx
                X(1:i, i, j) = y(k+1:k+i)
                X(i, 1:i, j) = y(k+1:k+i)
                k = k + i
            end do
        end do
    end associate
end subroutine

subroutine ea_ode_rhs(this, t, y, dy)
    class(t_ea_ode) this
    double precision, intent(in) :: t !< current time
    double precision, intent(in) :: y(this%ny) !< packed vector - current state
    double precision, intent(out) :: dy(this%ny) !< packed vector - derivatives

    double precision, dimension(this%nx) :: xc, dxc !< center of approximation
    double precision, dimension(this%nx, this%nx) :: E, dE !< fundamental matrix
    double precision, dimension(this%nx, this%nl) :: S, dS !< adjoint variables
    double precision, dimension(this%nx, this%nx, this%nl) :: X, dX !< matrices of ellipsoidal approximations

    double precision pi
    double precision, dimension(this%nx) :: CQCsj, Xjsj, v1, v2
    double precision, dimension(this%nx, this%nx) :: sXj, R, Z, xX, maxMat
    integer j

    associate( nx => this%nx, nl => this%nl, alpha => this%alpha )

        call profiler%toc(tag = "EA/ODE")

        call this%unpackvars(y, xc, E, S, X)
        call profiler%toc(tag = "PACK/UNPACK")

        if( this%f_dynamics ) then
            !dxc = matmul(this%A, xc)
            call this%operator_A%apply_vector('N', xc, dxc)
            !dE = matmul(this%A, E)
            call this%operator_A%apply('N', nx, E, dE)
            !dS = -matmul(transpose(this%A), S)
            call this%operator_A%apply('T', nl, S, dS)
            dS = -dS
        else
            dxc = 0
            dE = 0
            dS = 0
        end if
        call profiler%toc(tag = "DYNAMICS")

        if( this%f_control ) dxc = dxc + this%Bp
        if( this%f_disturbance ) dxc = dxc + this%Cq
        dxc = 0

        call profiler%toc(tag = "EA/PQ")

        do j = 1,nl
            associate( Xj => X(:, :, j), sj => S(:, j), dXj => dX(:, :, j) )
                if( this%f_dynamics ) then
                    !dXj = matmul(this%A, Xj)
                    call this%operator_A%apply('N', nx, Xj, dXj)
                    dXj = dXj + transpose(dXj)
                end if
                call profiler%toc(tag = "DYNAMICS")

                if( this%f_control ) then
                    call sqrtm(nx, Xj, sXj)
                    call profiler%toc(tag = "EA/CONTROL/SQRTM")
                    ! v1 = matmul(sXj, sj)
                    call dsymv('U', nx, 1D0, sXj, nx, sj, 1, 0D0, v1, 1)
                    ! v2 = matmul(sBPB, sj)
                    call dsymv('U', nx, 1D0, this%sBPB, nx, sj, 1, 0D0, v2, 1)
                    call profiler%toc(tag = "EA/CONTROL/V1V2")

                    call mrdivide(nx, nx, this%sBPB, sXj, maxMat)
                    call orthtranslmaxtr(nx, v2, v1, maxMat, R)

                    call profiler%toc(tag = "EA/CONTROL/ALIGN")
                    ! Z = matmul(sXj, R)
                    call dsymm('L', 'U', nx, nx, 1D0, sXj, nx, R, nx, 0D0, Z, nx)
                    call profiler%toc(tag = "EA/CONTROL/M1")
                    ! R = matmul(Z, sBPB)
                    call dsymm('R', 'U', nx, nx, 1D0, this%sBPB, nx, Z, nx, 0D0, R, nx)
                    call profiler%toc(tag = "EA/CONTROL/M2")
                    dXj = dXj - (R + transpose(R))
                    call profiler%toc(tag = "EA/CONTROL/ADD")
                end if
                call profiler%toc(tag = "EA/CONTROL")

                if( this%f_disturbance ) then
                    !pi = sqrt( dot_product(sj, matmul(this%CQC, sj)) / dot_product(sj, matmul(Xj, sj)) )
                    call dsymv('U', nx, 1D0, this%CQC, nx, sj, 1, 0D0, CQCsj, 1)
                    call dsymv('U', nx, 1D0, Xj, nx, sj, 1, 0D0, Xjsj, 1)
                    pi = sqrt( dot_product(sj, CQCsj) / dot_product(sj, Xjsj) )

                    dXj = dXj + pi*Xj + this%CQC/pi
                end if
                call profiler%toc(tag = "EA/DISTURBANCE")
            end associate
        end do

        ! interchange
        if( this%f_interchange ) then
            xX = sum(X, 3) * (alpha/nl)
            do j = 1,nl
                dX(:, :, j) = dX(:, :, j) - xX + alpha*X(:, :, j);
            end do
        end if
        call profiler%toc(tag = "EA/INTERCHANGE")

        call this%packvars(dxc, dE, dS, dX, dy)
        call profiler%toc(tag = "PACK/UNPACK")
    end associate

    this%call_count = this%call_count + 1
end subroutine

end module
