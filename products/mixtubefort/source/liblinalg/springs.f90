module m_springs

use m_operator

implicit none

type t_springs
    integer :: n !< number of springs
    integer :: nu !< control dimension
    integer :: nv !< disturbance dimension

    integer :: nx !< state dimension
    double precision, allocatable :: m(:) !< load masses
    double precision, allocatable :: k(:) !< spring stiffnesses
    integer, allocatable :: iu(:) !< indices of springs with control
    integer, allocatable :: iv(:) !< indices of springs with disturbances
    contains
    procedure initialize => springs_initialize
    procedure matrices => springs_matrices
end type

type, extends(t_operator) :: t_springs_operator
    class(t_springs), pointer :: springs => null()
    contains
    procedure apply => springs_operator_apply
end type

contains

subroutine springs_initialize(this)
    class(t_springs) this
    integer j

    associate( n => this%n, nu => this%nu, nv => this%nv )
        this%nx = 2*n
        allocate( this%m(n), this%k(n) )
        this%m = 1D0
        this%k = 1D0
        allocate( this%iu(nu), this%iv(nv) )
        do j = 1,nu
            this%iu(j) = n + 1 - j
        end do
        do j = 1,nv
            this%iv(j) = n + 1 - j
        end do
    end associate
end subroutine

subroutine springs_matrices(this, A, B, C)
    class(t_springs) this
    double precision, intent(out), optional :: A(this%nx, this%nx), B(this%nx, this%nu), C(this%nx, this%nv)

    integer j

    associate( n => this%n, m => this%m, k => this%k, nu => this%nu, iu => this%iu, nv => this%nv, iv => this%iv )
        ! dynamics matrix
        if( present(A) ) then
            A = 0
            do j = 1,n
                if( j < n ) then
                    A(n+j, j) = -(k(j) + k(j+1))/m(j)
                    A(n+j, j+1) = k(j+1)/m(j)
                    A(n+j+1, j) = k(j+1)/m(j+1)
                else
                    A(n+j, j) = -k(j)/m(j)
                end if
                A(j, n+j) = 1D0
            end do
        end if

        ! control matrix
        if( present(B) ) then
            B = 0
            do j = 1,nu
                B(n + iu(j), j) = 1/m(iu(j))
            end do
        end if

        ! disturbance matrix
        if( present(C) ) then
            C = 0
            do j = 1,nv
                C(n + iv(j), j) = 1/m(iv(j))
            end do
        end if
    end associate
end subroutine

subroutine springs_operator_apply(this, mode, k, B, C)
    class(t_springs_operator) this
    character(*), intent(in) :: mode !< [N]ormal or [T]ransposed
    integer, intent(in) :: k !< number of vectors
    double precision, intent(in) :: B(:, :) !< input vectors
    double precision, intent(out) :: C(:, :) !< image vectors

    integer j, n

    C = 0
    n = this%springs%n

    associate( y => this%springs%k, m => this%springs%m )
        select case ( mode )
        case( 'N' )
            do j = 1,n
                if( j == 1 ) then
                    C(n+j, 1:k) = C(n+j, 1:k) - ((y(j) + y(j+1))/m(j)) * B(j, 1:k) + (y(j+1)/m(j)) * B(j+1, 1:k)
                else if( j < n ) then
                    C(n+j, 1:k) = C(n+j, 1:k) - ((y(j) + y(j+1))/m(j)) * B(j, 1:k) + (y(j+1)/m(j)) * B(j+1, 1:k) + (y(j)/m(j)) * B(j-1, 1:k)
                else
                    C(n+j, 1:k) = C(n+j, 1:k) - (y(j)/m(j)) * B(j, 1:k) + (y(j)/m(j)) * B(j-1, 1:k)
                end if
                C(j, 1:k) = B(n+j, 1:k)
            end do
        case( 'T' )
            do j = 1,n
                if( j == 1 ) then
                    C(j, 1:k) = C(j, 1:k) - ((y(j) + y(j+1))/m(j)) * B(n+j, 1:k) + (y(j+1)/m(j+1)) * B(n+j+1, 1:k)
                else if( j < n ) then
                    C(j, 1:k) = C(j, 1:k) - ((y(j) + y(j+1))/m(j)) * B(n+j, 1:k) + (y(j+1)/m(j+1)) * B(n+j+1, 1:k) + (y(j)/m(j-1)) * B(n+j-1, 1:k)
                else
                    C(j, 1:k) = C(j, 1:k) - (y(j)/m(j)) * B(n+j, 1:k) + (y(j)/m(j-1)) * B(n+j-1, 1:k)
                end if
                C(n+j, 1:k) = B(j, 1:k)
            end do
        end select
    end associate
end subroutine

end module
