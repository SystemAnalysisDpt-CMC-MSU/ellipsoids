module m_closed_loop

use m_synthesis
use m_linear_ode
use m_ea
use m_ea_ode
use m_profile
use m_util
use m_mpi
use m_mat_save

implicit none

!> Closed-loop simulator
type t_closed_loop
    class(t_ea), pointer :: ea
    double precision, allocatable :: x0(:) !< initial state

    character :: vmode = 'Z' !< disturbance mode: [Z]ero, [U]ser defined, [W]orst, User Defined [L]

    ! parameters of ODE solver
    integer :: method = 2 !< method for solving the ODEs (1 = rk23, 2 = rk45, 3 = rk67)
    double precision :: tolerance = 1D-6 !< ODE solver tolerance
    double precision :: threshold = 1D-8 !< ODE solver threshold 
    double precision :: hstart = 0D0 !< ODE solver initial step guess

    procedure(i_disturbance), pointer :: disturbance => null()

    contains
    procedure initialize => closed_loop_initialize
    procedure simulate => closed_loop_simulate
end type

abstract interface
    subroutine i_disturbance(cl, nx, nu, nv, t, x, u, v)
        import :: t_closed_loop
        class(t_closed_loop) cl
        integer, intent(in) :: nx, nu, nv
        double precision, intent(in) :: t
        double precision, intent(in) :: x(nx), u(nu)
        double precision, intent(out) :: v(nv)
    end subroutine
end interface

interface
    subroutine setup_closed_loop(cl)
        import t_closed_loop
        class(t_closed_loop), pointer :: cl
    end subroutine
end interface

contains

subroutine closed_loop_initialize(this)
    class(t_closed_loop) this
    allocate( this%x0(this%ea%nx) )
end subroutine

subroutine closed_loop_simulate(this)
    class(t_closed_loop) this

    double precision, allocatable :: work(:), thres(:), ygot(:), ymax(:), dygot(:), work_sysv(:)
    double precision twant, tgot, dmin
    double precision u(this%ea%nu), ell(this%ea%nx), v(this%ea%nv), dv(this%ea%nv), Qidv(this%ea%nv)
    double precision xc(this%ea%nx), E(this%ea%nx, this%ea%nx), dx(this%ea%nx)
    double precision S(this%ea%nx, this%ea%nl), X(this%ea%nx, this%ea%nx, this%ea%nl)
    integer lenwrk, ifail, j, kmin, jl
    integer ut, ux, uu, uv, ud, uemin, uemax, uemean
    integer, allocatable :: ipiv(:)
    double precision R, ework(this%ea%nx*2+1), Ethis(this%ea%nx), Emax(this%ea%nx), Emean(this%ea%nx), Emin(this%ea%nx)
    logical write_eigs
    integer iwork(1), info

    character(256) prefix, fmtt, fmtx, fmtu, fmtv, fmtd

#ifdef MPI
    integer(MPI_ACCI) rank
#endif

#ifdef MPI
    call MPI_comm_rank(MPI_COMM_WORLD, rank, ierr)
#endif

#ifdef MPI
    if( rank == 0 ) then
#endif
        call get_program_parameter("prefix", prefix, "default")
        call get_program_parameter("write-eigs", write_eigs, .false.)

        ! open output files
        open(newunit=ut, file=trim(prefix)//"_t", buffered="yes")
        open(newunit=ux, file=trim(prefix)//"_x", buffered="yes")
        open(newunit=uu, file=trim(prefix)//"_u", buffered="yes")
        open(newunit=uv, file=trim(prefix)//"_v", buffered="yes")
        open(newunit=ud, file=trim(prefix)//"_d", buffered="yes")
        if( write_eigs ) then
            open(newunit=uemin, file=trim(prefix)//"_eigs_min", buffered="yes")
            open(newunit=uemax, file=trim(prefix)//"_eigs_max", buffered="yes")
            open(newunit=uemean, file=trim(prefix)//"_eigs_mean", buffered="yes")
        end if

        ! prepare output formats
        write(fmtt, '(A, I, A)') "(", 1, "ES12.4)"
        write(fmtx, '(A, I, A)') "(", this%ea%nx, "ES12.4)"
        write(fmtu, '(A, I, A)') "(", this%ea%nu, "ES12.4)"
        write(fmtv, '(A, I, A)') "(", this%ea%nv, "ES12.4)"
        write(fmtd, '(A, I, A)') "(", 1, "ES12.4)"
#ifdef MPI
    end if
#endif

    ! initialize ODE
    call linear_ode%initialize(this%ea%nx)
    linear_ode%operator_A => this%ea%operator_A

    ! initialize ODE solver
    lenwrk = this%ea%nx*20
    allocate( work(lenwrk), thres(this%ea%nx) )
    thres = this%threshold
    call d02pvf(this%ea%nx, this%ea%t0, this%x0, this%ea%t1+1D0, this%tolerance, thres, this%method, 'U', .false., this%hstart, work, lenwrk, ifail)
    call profiler%toc(tag = "CL/ODE")

    ! initialize linear solver
    if( this%ea%nv > 0 .and. this%vmode == 'U' ) then
        allocate( work_sysv(64*this%ea%nv) )
        allocate( ipiv(this%ea%nv) )
    end if

    ! time stepping
    allocate( ygot(this%ea%nx), dygot(this%ea%nx), ymax(this%ea%nx) )
    call profiler%start_eta
    ygot = this%x0
    tgot = this%ea%t(1)

    do j = 1,this%ea%Nt-1

        call profiler%toc(tag = "MISC")

        ! choose control
        call ea_ode%unpackvars(this%ea%y(:, j), xc, E, S, X)
        call profiler%toc(tag = "PACK/UNPACK")
        dx = ygot - xc

        call synthesis_all(this%ea%nx, this%ea%nu, this%ea%nl, E, dx, this%ea%B, this%ea%pc, this%ea%P, X, u, ell, dmin, kmin)
        call profiler%toc(tag = "SYNTHESIS")

        ! choose disturbance
        select case( this%vmode )
        case( 'Z' )
            v = this%ea%qc
        case( 'W' )
            call synthesis_all(this%ea%nx, this%ea%nv, this%ea%nl, E, dx, this%ea%C, this%ea%qc, this%ea%Q, X, v, ell, dmin, kmin)
            v = this%ea%qc - (v - this%ea%qc)
        case( 'U' )
            if( this%ea%nv > 0 ) then
                call this%disturbance(this%ea%nx, this%ea%nu, this%ea%nv, tgot, ygot, u, v)
                dv = v - this%ea%qc
                Qidv = dv
                call dsysv('U', this%ea%nv, 1, this%ea%Q, this%ea%nv, ipiv, Qidv, this%ea%nv, work_sysv, 64*this%ea%nv, ifail)
                R = dot_product(dv, Qidv)
                if( R > 1 ) then
                    v = this%ea%qc + dv/sqrt(R)
                end if
            end if
        case( 'L' )
            call this%disturbance(this%ea%nx, this%ea%nu, this%ea%nv, tgot, ygot, u, v)
            v = this%ea%qc + matmul(this%ea%Q, v)/dot_product(v, matmul(this%ea%Q, v))
        case default
            stop "Invalid disturbance mode"
        end select
        call profiler%toc(tag = "DISTURBANCE")

        ! write to output files
#ifdef MPI
        if( rank == 0 ) then
#endif
            write(ut, fmtt) tgot
            write(ux, fmtx) ygot
            if( this%ea%nu > 0 ) write(uu, fmtu) u
            if( this%ea%nv > 0 ) write(uv, fmtv) v
            write(ud, fmtd) dmin

            if( write_eigs ) then
                Emin = huge(Emin)
                Emax = 0
                Emean = 0
                do jl = 1,this%ea%nl
                    call dsyevd('N', 'U', this%ea%nx, X(:, :, jl), this%ea%nx, Ethis, ework, 2*this%ea%nx+1, iwork, 1, info)
                    Ethis = sqrt(max(0D0, Ethis))
                    Emin = min(Emin, Ethis)
                    Emax = max(Emax, Ethis)
                    Emean = Emean + Ethis/this%ea%nl
                end do

                write(uemin, fmtx) Emin
                write(uemax, fmtx) Emax
                write(uemean, fmtx) Emean
            end if
#ifdef MPI
        end if
#endif

        call profiler%toc(tag = "OUTPUT")

        ! do one step in ODE
        linear_ode%f = matmul(this%ea%B, u)
        if( this%ea%nv > 0 ) then
            linear_ode%f = linear_ode%f + matmul(this%ea%C, v)
        end if
        twant = this%ea%t(j+1)
        call d02pcf(the_linear_ode, twant, tgot, ygot, dygot, ymax, work, ifail)

        ! reset ODE solver
        call d02pvf(this%ea%nx, tgot, ygot, this%ea%t1+1D0, this%tolerance, thres, this%method, 'U', .false., this%hstart, work, lenwrk, ifail)
        call profiler%toc(tag = "CL/ODE")
        call profiler%toc(tag = "CL/ODE")

        ! terminal output
#ifdef MPI
        if( rank == 0 ) then
#endif
            if( modulo(j, 20) == 1 ) then
                write(*, '(A6, 2A10, A8, 4(A10))') 'k', 't', 'dmin', 'kmin', 'Tick Avg', 'ETA', 'Total'
            end if
            write(*, '(I6, 2ES10.2, I8, 3ES10.2)') j, tgot, dmin, kmin, profiler%avg(j, 0), &
                profiler%eta(tgot, this%ea%t0, this%ea%t1), &
                profiler%total(tgot, this%ea%t0, this%ea%t1)
#ifdef MPI            
        end if
#endif        

        call profiler%toc(tag = "CONSOLE")
    end do

#ifdef MPI
    if( rank == 0 ) then
#endif
        ! write data on final step
        write(ut, fmtt) tgot
        write(ux, fmtx) ygot
        if( this%ea%nu > 0 ) write(uu, fmtu) u
        if( this%ea%nv > 0 ) write(uv, fmtv) v
        write(ud, fmtd) dmin

        ! close files
        close(ut)
        close(ux)
        close(uu)
        close(uv)
        close(ud)
        if( write_eigs ) then
            close(uemin)
            close(uemax)
            close(uemean)
        end if
#ifdef MPI
    end if
#endif
end subroutine

end module
