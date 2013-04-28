module m_ea_ode_tests

use fruit
use m_random
use m_ea_ode
use m_operator
use m_matrix

implicit none

private

public :: test_ea_ode_all

contains

subroutine test_pack_unpack
    double precision, parameter :: range = 1
    integer, parameter :: nx = 10, nl = 20, nu = 2, nv = 3
    double precision xc(nx), S(nx, nl), E(nx, nx), X(nx, nx, nl)
    double precision xcu(nx), Su(nx, nl), Eu(nx, nx), Xu(nx, nx, nl)
    double precision B(nx, nu), pc(nu), P(nu, nu), C(nx, nv), qc(nv), Q(nv, nv), alpha
    double precision, allocatable :: y(:)
    class(t_operator), pointer :: operator_A
    integer j

    allocate( t_matrix :: operator_A )
    select type( operator_A )
    type is ( t_matrix )
        operator_A%m = nx
        operator_A%n = nx
        call operator_A%initialize
        call random_number(operator_A%A, -range, range)
    end select

    call random_number(B, -range, range)
    call random_number(pc, -range, range)
    call random_number(P, -range, range); P = matmul(P, transpose(P))
    call random_number(C, -range, range)
    call random_number(qc, -range, range)
    call random_number(Q, -range, range); Q = matmul(Q, transpose(Q))
    call random_number(alpha)

    call ea_ode%initialize(nx, nu, nv, nl, operator_A, B, pc, P, C, qc, Q, alpha)

    call random_number(c, -range, range)
    call random_number(S, -range, range)
    call random_number(E, -range, range)
    call random_number(X, -range, range)

    do j = 1,nl
        X(:, :, j) = matmul(X(:, :, j), transpose(X(:, :, j)))
        X(:, :, j) = (X(:, :, j) + transpose(X(:, :, j)))/2
    end do

    allocate( y(ea_ode%ny) )

    call ea_ode%packvars(xc, E, S, X, y)
    call ea_ode%unpackvars(y, xcu, Eu, Su, Xu)

    call assert_equals(0D0, maxval(abs(xc - xcu)), 1D-16, 'xc')
    call assert_equals(0D0, maxval(abs(E - Eu)), 1D-16, 'E')
    call assert_equals(0D0, maxval(abs(S - Su)), 1D-16, 'S')
    call assert_equals(0D0, maxval(abs(X - Xu)), 1D-16, 'X')
end subroutine


subroutine test_ea_ode_all
    call run_test_case(test_pack_unpack, 'ea_ode_pack_unpack')
end subroutine

end module
