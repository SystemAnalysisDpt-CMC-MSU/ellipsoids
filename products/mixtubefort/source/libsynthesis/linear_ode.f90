module m_linear_ode

use m_profile
use m_operator

implicit none

!> System of linear ODEs
type t_linear_ode
    integer :: nx !< state dimension
    class(t_operator), pointer :: operator_A => null() !< linear dynamics
    double precision, allocatable :: f(:) !< vector from the right-hand side
contains
    procedure initialize => linear_ode_initialize
    procedure rhs => linear_ode_rhs
end type

type(t_linear_ode) linear_ode

contains

subroutine the_linear_ode(t, x, dx)
    double precision, intent(in) :: t !< current time
    double precision, intent(in) :: x(linear_ode%nx) !< current state
    double precision, intent(out) :: dx(linear_ode%nx) !< derivatives
    call linear_ode%rhs(t, x, dx)
end subroutine

subroutine linear_ode_initialize(this, nx)
    class(t_linear_ode) this
    integer, intent(in), value :: nx !< state dimension

    this%nx = nx
    allocate( this%f(nx) )
end subroutine

subroutine linear_ode_rhs(this, t, x, dx)
    class(t_linear_ode), intent(in) :: this
    double precision, intent(in) :: t !< current time
    double precision, intent(in) :: x(this%nx) !< current state
    double precision, intent(out) :: dx(this%nx) !< derivatives

    call profiler%toc(tag = "CL/ODE")

    associate( nx => this%nx )
        !dx = matmul(this%A, x)
        call this%operator_A%apply_vector('N', x, dx)
        dx = dx + this%f
        call profiler%toc(tag = "DYNAMICS")
    end associate
end subroutine

end module
