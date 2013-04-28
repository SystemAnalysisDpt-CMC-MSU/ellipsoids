!> Сетап с помехой (выполнено условие подобия).
subroutine setup_approximation(ea)
    use m_ea
    use m_springs
    use m_util
    use m_matrix

    implicit none

    integer j
    double precision rM, rP, rQ, heterogeneity

    class(t_ea), pointer :: ea
    class(t_springs), pointer :: springs
    character(256) op

    allocate( springs )
    call get_program_parameter("n", springs%n, 1)
    call get_program_parameter("nu", springs%nu, 1)
    springs%nv = springs%nu
    call springs%initialize

    springs%m = 1D0/springs%n
    springs%k = 1D0*springs%n
    call get_program_parameter("heterogeneity", heterogeneity, 1D0)
    springs%m(springs%n/2+1:springs%n) = heterogeneity/springs%n

    ea%nx = springs%nx
    ea%nu = springs%nu
    ea%nv = springs%nv
    call get_program_parameter("nl", ea%nl, springs%nx)
    call get_program_parameter("alpha", ea%alpha, 9D-1)
    call get_program_parameter("beta", ea%beta, 9D-1)
    call get_program_parameter("Ntx", ea%Ntx, 20)

    call get_program_parameter("operator", op, "springs")

    select case ( op )
    case( "springs" )
        allocate( t_springs_operator :: ea%operator_A )
    case( "matrix" )
        allocate( t_matrix :: ea%operator_A )
    end select

    call ea%initialize
    select type ( A => ea%operator_A )
    type is ( t_springs_operator )
        A%springs => springs
    type is ( t_matrix )
        call A%initialize
        call springs%matrices( A%A )
    end select
    call springs%matrices(B = ea%B, C = ea%C)

    call get_program_parameter("rP", rP, 1D0)
    call get_program_parameter("rQ", rQ, 5D-1)
    do j = 1,ea%nu
        ea%P(j, j) = (sqrt(rP) - sqrt(rQ))**2
    end do

    call get_program_parameter("t", ea%t1, 12D0)

    ! initial data
    call g05fdf(0D0, 1D0, ea%nx * ea%nl, ea%L)

    call get_program_parameter("rM", rM, 1D-3)
    ea%M = 0D0
    do j = 1,ea%nx
        ea%M(j, j) = rM
    end do

    call get_program_parameter("Nt", ea%Nt, 200*springs%n + 1)
    call get_program_parameter("tolerance", ea%tolerance, 1D-4)
end subroutine

subroutine disturbance(cl, nx, nu, nv, t, x, u, v)

    use m_closed_loop
    use m_util

    IMPLICIT NONE

    class(t_closed_loop) cl
    integer, intent(in) :: nx, nu, nv
    double precision, intent(in) :: t
    double precision, intent(in) :: x(nx), u(nu)
    double precision, intent(out) :: v(nv)

    double precision, parameter :: pi = 3.1415926535897932384626433832795028841971D0
    integer j
    double precision rQ

    call get_program_parameter("rQ", rQ, 5D-1)

    do j = 1,nv
        v(j) = sin(j*pi*t/2 + 1D0)*sqrt(rQ)
    end do
end subroutine

subroutine setup_closed_loop(cl)
    use m_closed_loop
    use m_util
    
    class(t_closed_loop), pointer :: cl
    double precision, parameter :: pi = 3.1415926535897932384626433832795028841971D0
    double precision f, kw, kdw, rP, rQ
    integer j, n
    character(256) vmode
    external disturbance

    call get_program_parameter("n", n, 1)
    call get_program_parameter("kw", kw, 2D0)
    call get_program_parameter("kdw", kdw, -2D0)
    call get_program_parameter("rP", rP, 1D0)
    call get_program_parameter("rQ", rQ, 5D-1)
    call get_program_parameter("vmode", vmode, 'U')

    cl%vmode = vmode
    cl%disturbance => disturbance

    do j = 1,cl%ea%nu
        cl%ea%P(j, j) = rP
        cl%ea%Q(j, j) = rQ
    end do

    ! initial position
    do j = 1,n
        f = sin(2*pi*((1D0*j)/n)**2)
        cl%x0(j) = f*kw
        cl%x0(n+j) = f*kdw
    end do
end subroutine
