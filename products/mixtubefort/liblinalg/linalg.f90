module m_linalg

use m_profile

implicit none

contains

!> QR factorization
subroutine qr(m, n, A, Q, R)
    integer, intent(in), value :: m !< number of rows
    integer, intent(in), value :: n !< number of columns
    double precision, intent(in) :: A(m, n) !< matrix to be factorized as A=QR
    double precision, intent(out) :: Q(m, m) !< orthogonal matrix
    double precision, intent(out) :: R(m, n) !< upper triangular matrix

    double precision tau(m) !< множители при матрицах отражений
    double precision work(m) !< рабочая область
    integer info !< код возврата
    integer j

    ! compute the QR factorization
    ! (in terms of elementary reflections)
    Q(:, 1:n) = A
    Q(:, n+1:m) = 0
    call dgeqrf(m, m, Q, m, tau, work, m, info)

    ! extract matrix R
    R = 0
    do j = 1,n
        R(1:j, j) = Q(1:j, j)
    end do

    ! compute matrix Q
    call dorgqr(m, m, m, Q, m, tau, work, m, info)
end subroutine

!> QR factorization (economy size)
subroutine qr0(m, n, A, Q, R)
    integer, intent(in), value :: m !< number of rows
    integer, intent(in), value :: n !< number of columns
    double precision, intent(in) :: A(m, n) !< matrix to be factorized as A=QR
    double precision, intent(out) :: Q(m, n) !< orthogonal matrix
    double precision, intent(out) :: R(m, n) !< upper triangular matrix

    double precision tau(m) !< множители при матрицах отражений
    double precision work(m) !< рабочая область
    integer info !< код возврата
    integer j

    ! compute the QR factorization
    ! (in terms of elementary reflections)
    Q = A
    call dgeqrf(m, n, Q, m, tau, work, m, info)

    ! extract matrix R
    R = 0
    do j = 1,n
        R(1:j, j) = Q(1:j, j)
    end do

    ! compute matrix Q
    call dorgqr(m, n, n, Q, m, tau, work, m, info)
end subroutine

!> Compute an orthogonal matrix such that T*v2 = alpha*v1, alpha > 0
subroutine align(n, v1, v2, T)
    integer, intent(in), value :: n !< dimension
    double precision, intent(in) :: v1(n) !< first vector
    double precision, intent(in) :: v2(n) !< second vector
    double precision, intent(out) :: T(n, n) !< orthogonal matrix

    double precision Q1(n, n), R1(n)
    double precision Q2(n, n), R2(n)

    ! compute QR factorizations
    call qr(n, 1, v1, Q1, R1)
    call qr(n, 1, v2, Q2, R2)

    ! T = matmul(Q1, transpose(Q2))
    call dgemm('N', 'T', n, n, n, 1D0, Q1, n, Q2, n, 0D0, T, n)

    ! correct direction if necessary
    if( R1(1) * R2(1) < 0 ) T = -T
end subroutine

!> Compute an orthogonal matrix such that T*v2 = alpha*v1, alpha > 0
subroutine align2(n, v1, v2, T)
    integer, intent(in), value :: n !< dimension
    double precision, intent(in) :: v1(n) !< first vector
    double precision, intent(in) :: v2(n) !< second vector
    double precision, intent(out) :: T(n, n) !< orthogonal matrix

    double precision V(n, 2), Q(n, n), R(n, 2), c, s, QS(n, n)

    ! compute QR factorization
    V(:, 1) = v1
    V(:, 2) = v2
    call qr(n, 2, V, Q, R)

    ! compute sine and cosine
    c = dot_product(v1, v2)/sqrt(dot_product(v1, v1)*dot_product(v2, v2))
    s = -sqrt(1 - c**2)
    if( R(1, 1)*R(2, 2) < 0 ) s = -s

    ! QS = matmul(Q, rotation matrix)
    QS(:, 1) = Q(:, 1)*c + Q(:, 2)*s
    QS(:, 2) = -Q(:, 1)*s + Q(:, 2)*c
    QS(:, 3:n) = Q(:, 3:n)

    ! T = matmul(QS, transpose(Q))
    call dgemm('N', 'T', n, n, n, 1D0, QS, n, Q, n, 0D0, T, n)
end subroutine

!> Compute an orthogonal matrix such that T*v2 = alpha*v1, alpha > 0
subroutine align3(n, v1, v2, T)
    integer, intent(in), value :: n !< dimension
    double precision, intent(in) :: v1(n) !< first vector
    double precision, intent(in) :: v2(n) !< second vector
    double precision, intent(out) :: T(n, n) !< orthogonal matrix

    double precision V(n, 2), Q(n, 2), R(n, 2), c, s, QS(n, 2)
    integer j

    ! compute QR factorization
    V(:, 1) = v1
    V(:, 2) = v2
    call qr0(n, 2, V, Q, R)

    ! compute sine and cosine
    c = dot_product(v1, v2)/sqrt(dot_product(v1, v1)*dot_product(v2, v2))
    s = -sqrt(1 - c**2)
    if( R(1, 1)*R(2, 2) < 0 ) s = -s

    ! QS = matmul(Q, rotation matrix)
    QS(:, 1) = Q(:, 1)*(c-1) + Q(:, 2)*s
    QS(:, 2) = -Q(:, 1)*s + Q(:, 2)*(c-1)

    ! T = matmul(QS, transpose(Q))
    call dgemm('N', 'T', n, n, 2, 1D0, QS, n, Q, n, 0D0, T, n)
    do j = 1,n
        T(j, j) = T(j, j) + 1D0
    end do
end subroutine

!> Compute an orthogonal matrix such that T*v2 = alpha*v1, alpha > 0
subroutine align4(n, v1, v2, T)
    integer, intent(in), value :: n !< dimension
    double precision, intent(in) :: v1(n) !< first vector
    double precision, intent(in) :: v2(n) !< second vector
    double precision, intent(out) :: T(n, n) !< orthogonal matrix

    double precision V(n, 2), G(2, 2), Q(n, 2), c, s, QS(n, 2)
    integer j

    ! compute Gram matrix
    V(:, 1) = v1
    V(:, 2) = v2
    ! G = V'*V
    call dgemm('T', 'N', 2, 2, n, 1D0, V, n, V, n, 0D0, G, 2)

    ! compute QR factorization
    Q(:, 1) = v1/sqrt(G(1, 1))
    Q(:, 2) = (v2 - (G(1, 2)/G(1,1))*v1)/sqrt(G(2,2) - G(1,2)**2/G(1,1))

    ! compute sine and cosine
    c = G(1,2)/sqrt(G(1,1)*G(2, 2))
    s = -sqrt(1 - c**2)

    ! QS = matmul(Q, rotation matrix)
    QS(:, 1) = Q(:, 1)*(c-1) + Q(:, 2)*s
    QS(:, 2) = -Q(:, 1)*s + Q(:, 2)*(c-1)

    ! T = matmul(QS, transpose(Q))
    call dgemm('N', 'T', n, n, 2, 1D0, QS, n, Q, n, 0D0, T, n)
    do j = 1,n
        T(j, j) = T(j, j) + 1D0
    end do
end subroutine

!> Compute square root of a real symmetric matrix
subroutine sqrtm(n, A, R)
    integer, intent(in), value :: n !< dimension
    double precision, intent(in) :: A(n, n) !< input matrix
    double precision, intent(out) :: R(n, n) !< square root of A

    integer j
    double precision T(n, n), U(n, n), D(n)

    integer info
    integer iwork(5*n+3)
    double precision work(2*n**2 + 6*n + 1)

    ! compute eigenvalues (R) and eigenvectors(T)
    call profiler%toc(tag = "MISC")
    T = A
    call profiler%toc(tag = "SQRTM/T=A")
    call dsyevd('V', 'U', n, T, n, D, work, 2*n**2+6*n+1, iwork, 5*n+3, info)
    call profiler%toc(tag = "SQRTM/SYEVD")
    if( minval(D) < -1D-2 ) then
        write(*, '(A, ES10.2)') 'Negative eigenvalues: ', minval(D)
    end if
    D = max(D, 0D0)
    ! U = T*diag(sqrt(D))
    forall(j = 1:N) U(:, j) = T(:, j) * sqrt(D(j))
    call profiler%toc(tag = "SQRTM/DMUL")
    ! R = U*T' 
    call dgemm('N', 'T', n, n, n, 1D0, U, n, T, n, 0D0, R, n)
    call profiler%toc(tag = "SQRTM/MMUL")
end subroutine

end module
