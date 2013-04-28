module m_linalg_tests

use fruit
use m_random
use m_linalg

implicit none

private

abstract interface
    subroutine i_align(n, v1, v2, T)
        integer, intent(in), value :: n !< dimension
        double precision, intent(in) :: v1(n) !< first vector
        double precision, intent(in) :: v2(n) !< second vector
        double precision, intent(out) :: T(n, n) !< orthogonal matrix
    end subroutine
end interface

public :: test_linalg_all

contains

subroutine test_linalg_align(palign)
    procedure(i_align) palign
    double precision, parameter :: range = 10
    integer, parameter :: n = 10
    double precision v1(n), v2(n), T(n, n), Tv2(n)

    call random_number(v1, -range, range)
    call random_number(v2, -range, range)

    call palign(n, v1, v2, T)

    Tv2 = matmul(T, v2)
    call assert_true(v1(1)*Tv2(1) > 0, 'alpha > 0')

    Tv2 = Tv2*v1(1)/Tv2(1)
    call assert_equals(0D0, maxval(abs(v1 - Tv2)), 1D-8, 'v1 || v2')
end subroutine

subroutine test_linalg_align1
    call test_linalg_align(align)
end subroutine

subroutine test_linalg_align2
    call test_linalg_align(align2)
end subroutine

subroutine test_linalg_align3
    call test_linalg_align(align3)
end subroutine

subroutine test_linalg_align4
    call test_linalg_align(align4)
end subroutine

subroutine test_linalg_sqrtm
    double precision, parameter :: range = 1
    integer, parameter :: n = 10
    double precision Q(n, n), R(n, n)

    call random_number(Q, -range, range)
    Q = matmul(Q, transpose(Q))

    call sqrtm(n, Q, R)

    call assert_equals(0D0, maxval(abs(R - transpose(R))), 1D-12, 'R = R^T')
    call assert_equals(0D0, maxval(abs(Q - matmul(R, R))), 1D-8, 'R^2 = Q')
end subroutine

subroutine test_linalg_qr
    double precision, parameter :: range = 1
    integer, parameter :: m = 10, n = 5
    double precision A(m, n), Q(m, m), R(m, n), E(m, m)
    integer j

    call random_number(A, -range, range)

    R = 0
    call qr(m, n, A, Q, R)

    call assert_equals(0D0, maxval(abs(A - matmul(Q, R))), 1D-8, 'A = QR')

    E = 0
    do j = 1,m
        E(j, j) = 1
    end do
    call assert_equals(0D0, maxval(abs(E - matmul(Q, transpose(Q)))), 1D-8, 'Q is orthogonal')

    do j = 1,n
        R(1:j, j) = 0
    end do
    call assert_equals(0D0, maxval(abs(R)), 1D-16, 'R is upper triangular')
end subroutine

subroutine test_linalg_qr0
    double precision, parameter :: range = 1
    integer, parameter :: m = 10, n = 5
    double precision A(m, n), Q(m, n), R(m, n), E(n, n)
    integer j

    call random_number(A, -range, range)

    R = 0
    call qr0(m, n, A, Q, R)

    call assert_equals(0D0, maxval(abs(A - matmul(Q, R(1:n, 1:n)))), 1D-8, 'A = QR')

    E = 0
    do j = 1,n
        E(j, j) = 1
    end do
    call assert_equals(0D0, maxval(abs(E - matmul(transpose(Q), Q))), 1D-8, 'Q is orthogonal')

    do j = 1,n
        R(1:j, j) = 0
    end do
    call assert_equals(0D0, maxval(abs(R)), 1D-16, 'R is upper triangular')
end subroutine

subroutine test_linalg_all
    call run_test_case(test_linalg_align1, 'linalg_align')
    call run_test_case(test_linalg_align2, 'linalg_align2')
    call run_test_case(test_linalg_align3, 'linalg_align3')
    call run_test_case(test_linalg_align4, 'linalg_align4')
    call run_test_case(test_linalg_sqrtm, 'linalg_sqrtm')
    call run_test_case(test_linalg_qr, 'linalg_qr')
    call run_test_case(test_linalg_qr0, 'linalg_qr0')
end subroutine

end module
