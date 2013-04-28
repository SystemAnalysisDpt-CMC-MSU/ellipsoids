module m_matrix

use m_operator

type, extends(t_operator) :: t_matrix
    double precision, allocatable :: A(:, :)
    contains 
    procedure initialize => matrix_initialize
    procedure apply => matrix_apply
end type

contains

subroutine matrix_initialize(this)
    class(t_matrix) this
    allocate( this%A(this%m, this%n) )
end subroutine

subroutine matrix_apply(this, mode, k, B, C)
    class(t_matrix) this
    character(*), intent(in) :: mode !< [N]ormal or [T]ransposed
    integer, intent(in) :: k !< number of vectors
    double precision, intent(in) :: B(:, :) !< input vectors
    double precision, intent(out) :: C(:, :) !< image vectors

    call dgemm(mode, 'N', this%m, k, this%n, 1D0, this%A, this%m, B, this%n, 0D0, C, this%m)
end subroutine

end module
