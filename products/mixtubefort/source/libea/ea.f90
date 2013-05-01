module m_ea

use m_ea_ode
use m_profile
use m_mpi
use m_operator

implicit none

type t_ea
    integer :: nx !< state dimension
    integer :: nu = 0 !< control dimension
    integer :: nv = 0 !< disturbance dimension
    integer :: nl !< number of directions

    class(t_operator), pointer :: operator_A => null() !< linear dynamics
    double precision, allocatable :: B(:, :) !< control matrix
    double precision, allocatable :: C(:, :) !< disturbance matrix
    double precision, allocatable :: L(:, :) !< tight directions
    double precision, allocatable :: pc(:) !< center of control ellipsoid
    double precision, allocatable :: P(:, :) !< matrix of control ellipsoid
    double precision, allocatable :: qc(:) !< center of disturbance ellipsoid
    double precision, allocatable :: Q(:, :) !< matrix of disturbance ellipsoid
    double precision, allocatable :: mc(:) !< center of target set ellipsoid
    double precision, allocatable :: M(:, :) !< matrix of target set ellipsoid

    double precision :: alpha = 0D0 !< parameter alpha (continuous interchange)
    double precision :: beta = 0D0 !< parameter beta (discrete interchange)
    integer :: Ntx = 1 !< interchange every ... time steps
    double precision :: t0 = 0D0 !< start time
    double precision t1 !< finish time

    ! parameters of ODE solver
    integer :: Nt = 101 !< number of steps
    integer :: method = 2 !< method for solving the ODEs (1 = rk23, 2 = rk45, 3 = rk67)
    double precision :: tolerance = 1D-6 !< ODE solver tolerance
    double precision :: threshold = 1D-8 !< ODE solver threshold 

    ! computed ellipsoids
    !integer :: ny = 0
    double precision, allocatable :: t(:) !< time values (from t0 to t1)
    double precision, allocatable :: y(:, :) !< packed variables corresponding to time values
contains
    procedure initialize => ea_initialize
    procedure compute => ea_compute
end type

interface
    subroutine setup_approximation(ea)
        import t_ea
        class(t_ea), pointer :: ea
    end subroutine
end interface

contains

subroutine ea_initialize(this)
    class(t_ea) this

    associate( nx => this%nx, nu => this%nu, nv => this%nv, nl => this%nl )
        this%operator_A%m = nx
        this%operator_A%n = nx
        allocate( this%B(nx, nu) ); this%B = 0
        allocate( this%C(nx, nv) ); this%C = 0
        allocate( this%L(nx, nl) ); this%L = 0
        allocate( this%pc(nu) );    this%pc = 0
        allocate( this%P(nu, nu) ); this%P = 0
        allocate( this%qc(nv) );    this%qc = 0
        allocate( this%Q(nv, nv) ); this%Q = 0
        allocate( this%mc(nx) );    this%mc = 0
        allocate( this%M(nx, nx) ); this%M = 0
    end associate
end subroutine

subroutine ea_compute(this)
    class(t_ea) this
    
    double precision X0(this%nx, this%nx, this%nl), E0(this%nx, this%nx)
    double precision, allocatable :: y0(:), thres(:), ygot(:), dygot(:), ymax(:), work(:)
    integer j, lenwrk, ifail
    double precision tgot, h, twant, hstart
#ifdef MPI
    integer(MPI_ACCI) rank, nl_in, nl_out, k, n4, c_in, c_out
    double precision xc(this%nx), E(this%nx, this%nx), S(this%nx, this%nl), X(this%nx, this%nx, this%nl)
    double precision X_in(this%nx, this%nx), X_out(this%nx, this%nx), delta
#endif

    ! initialize ODE
    call ea_ode%initialize(this%nx, this%nu, this%nv, this%nl, this%operator_A, this%B, this%pc, this%P, this%C, this%qc, this%Q, this%alpha)

    ! initial values
    do j = 1,this%nl
        X0(:, :, j) = this%M
    end do
    E0 = 0D0
    do j = 1,this%nx
        E0(j, j) = 1D0
    end do

    !this%ny = ea_ode%ny;

    allocate( y0(ea_ode%ny) )
    call ea_ode%packvars(this%mc, E0, this%L, X0, y0)
    call profiler%toc(tag = "PACK/UNPACK")

    ! initialize ODE solver
    h = (this%t1 - this%t0)/(this%Nt - 1)

    lenwrk = ea_ode%ny*20
    allocate( work(lenwrk), thres(ea_ode%ny) )
    thres = this%threshold
    hstart = h
    call d02pvf(ea_ode%ny, this%t1, y0, this%t0 - this%tolerance, this%tolerance, thres, this%method, 'U', .false., hstart, work, lenwrk, ifail)
    call profiler%toc(tag = "EA/ODE")

#ifdef MPI
    call MPI_comm_rank(MPI_COMM_WORLD, rank, ierr)
    nl_in = this%nl
    call MPI_allreduce(nl_in, nl_out, 1_MPI_ACCI, MPI_INTEGER4, MPI_SUM, MPI_COMM_WORLD, ierr)
#endif

    ! time stepping
    allocate( ygot(ea_ode%ny), dygot(ea_ode%ny), ymax(ea_ode%ny) )
    allocate( this%t(this%Nt), this%y(ea_ode%ny, this%Nt) )

    call profiler%start_eta

    j = this%Nt
    twant = this%t1
    tgot = twant
    ygot = y0

    this%t(j) = tgot
    this%y(:, j) = ygot

    do while ( tgot > this%t0 + h/2 )
        ! do one step
        twant = twant - h
        j = j - 1
        ea_ode%call_count = 0
        call d02pcf(the_ea_ode, twant, tgot, ygot, dygot, ymax, work, ifail)
        this%t(j) = tgot
        this%y(:, j) = ygot
        call profiler%toc(tag = "EA/ODE")

#ifdef MPI
        ! discrete interchange
        if( modulo(this%Nt - j, this%Ntx) == 0 ) then
            if( rank == 0 ) write(*, '(A)') 'Network Interchange'
            call ea_ode%unpackvars(ygot, xc, E, S, X)
            call profiler%toc(tag = "PACK/UNPACK")
            X_in = sum(X, 3)/nl_out
            n4 = this%nx**2
            call MPI_allreduce(X_in, X_out, n4, MPI_DOUBLE_PRECISION, MPI_SUM, MPI_COMM_WORLD, ierr)
            delta = 1 - exp(-this%beta*h*this%Ntx)
            do k = 1,this%nl
                X(:, :, k) = (1 - delta)*X(:, :, k) + delta*X_out
            end do
            call profiler%toc(tag = "INTERCHANGE/NET")
            call ea_ode%packvars(xc, E, S, X, ygot)
            call profiler%toc(tag = "PACK/UNPACK")
            call d02pvf(ea_ode%ny, tgot, ygot, this%t0-1D0, this%tolerance, thres, this%method, 'U', .false., hstart, work, lenwrk, ifail)
            call profiler%toc(tag = "EA/ODE")
        end if
#endif

        ! terminal output
#ifdef MPI        
        c_in = ea_ode%call_count
        call MPI_reduce(c_in, c_out, 1_MPI_ACCI, MPI_INTEGER4, MPI_SUM, 0_MPI_ACCI, MPI_COMM_WORLD, ierr)
        if( rank == 0 ) then
            ea_ode%call_count = c_out
#endif
            ! header (every 20 steps)
            if( modulo(this%Nt - j, 20) == 1 ) then
                write(*, '(A6, 5A10)') 'k', 't', 'Calls', 'Tick Avg', 'ETA', 'Total'
            end if
            ! values 
            write(*, '(I6, ES10.2, I10, 3ES10.2)') j, tgot, ea_ode%call_count, &
                profiler%avg(this%Nt, j), &
                profiler%eta(tgot, this%t1, this%t0), &
                profiler%total(tgot, this%t1, this%t0)
            call profiler%toc(tag = "CONSOLE")
#ifdef MPI            
        end if
#endif
    end do
end subroutine

end module
