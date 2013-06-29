module m_random

implicit none

private

interface random_number
    module procedure random_number_m3r
    module procedure random_number_mr
    module procedure random_number_vr
    module procedure random_number_sr
    module procedure random_number_isr
end interface

public :: random_number, init_random_seed

contains

subroutine init_random_seed
    integer :: i, n, clock
    integer, dimension(:), allocatable :: seed

    call random_seed(size = n)
    allocate(seed(n))

    call system_clock(count=clock)

    seed = clock + 37 * [ (i - 1, i = 1, n) ]
    call random_seed(put = seed)

    deallocate(seed)
end subroutine

subroutine random_number_m3r(A, t1, t2)
    double precision, intent(out) :: A(:, :, :)
    double precision, intent(in), value :: t1, t2
    call random_number(A)
    A = (t2 - t1) * A + t1
end subroutine

subroutine random_number_mr(A, t1, t2)
    double precision, intent(out) :: A(:, :)
    double precision, intent(in), value :: t1, t2
    call random_number(A)
    A = (t2 - t1) * A + t1
end subroutine

subroutine random_number_vr(v, t1, t2)
    double precision, intent(out) :: v(:)
    double precision, intent(in), value :: t1, t2
    call random_number(v)
    v = (t2 - t1) * v + t1
end subroutine

subroutine random_number_sr(s, t1, t2)
    double precision, intent(out) :: s
    double precision, intent(in), value :: t1, t2
    call random_number(s)
    s = (t2 - t1) * s + t1
end subroutine

subroutine random_number_isr(s, t1, t2)
    integer, intent(out) :: s
    integer, intent(in), value :: t1, t2
    double precision t
    call random_number(t, real(t1-1, 8), real(t2, 8))
    s = ceiling(t)
end subroutine

end module
