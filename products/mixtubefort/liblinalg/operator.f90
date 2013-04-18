module m_operator

implicit none

!> Abstract linear operator
type, abstract :: t_operator
    integer m !< dimension of values
    integer n !< dimension of arguments
    contains
    procedure :: apply_vector => operator_apply_vector
    procedure(i_apply), deferred :: apply
end type

abstract interface
    subroutine i_apply(this, mode, k, B, C)
        import t_operator
        class(t_operator) this
        character(*), intent(in) :: mode !< [N]ormal or [T]ransposed
        integer, intent(in) :: k !< number of vectors
        double precision, intent(in) :: B(:, :) !< input vectors
        double precision, intent(out) :: C(:, :) !< image vectors
    end subroutine
end interface

contains

subroutine operator_apply_vector(this, mode, B, C)
    class(t_operator) this
    character(*), intent(in) :: mode !< [N]ormal or [T]ransposed
    double precision, intent(in) :: B(:) !< input vector
    double precision, intent(out) :: C(:) !< image vector

    double precision :: mB(lbound(B, 1):ubound(B, 1), 1)
    double precision :: mC(lbound(C, 1):ubound(C, 1), 1)

    mB(:, 1) = B
    call this%apply(mode, 1, mB, mC)
    C = mC(:, 1)
end subroutine

end module
