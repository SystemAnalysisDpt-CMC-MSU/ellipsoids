module m_springs_tests

use fruit
use m_random
use m_springs

implicit none

contains

subroutine test_springs_operator
    integer, parameter :: nz = 5
    double precision :: d;
    type(t_springs), target :: springs
    type(t_springs_operator) springs_operator
    double precision, allocatable :: A(:, :), M(:, :), AM(:, :), OM(:, :)

    springs%n = 5
    springs%nu = 4
    springs%nv = 4

    call springs%initialize

    call random_number(springs%m)
    call random_number(springs%k)

    allocate( A(springs%nx, springs%nx) )

    call springs%matrices(A)
    springs_operator%springs => springs

    allocate( M(springs%nx, nz) )

    call random_number(M)

    allocate( AM(springs%nx, nz) )
    allocate( OM(springs%nx, nz) )

    AM = matmul(A, M)
    call springs_operator%apply('N', nz, M, OM)

    d = maxval(abs(AM - OM));

    call assert_equals(0D0, maxval(abs(AM - OM)), 1D-8, 'N')

    AM = matmul(transpose(A), M)
    call springs_operator%apply('T', nz, M, OM)

    d = maxval(abs(AM - OM));

    call assert_equals(0D0, maxval(abs(AM - OM)), 1D-8, 'T')
end subroutine

subroutine test_springs_all
    call run_test_case(test_springs_operator, 'springs_operator')
end subroutine

end module
