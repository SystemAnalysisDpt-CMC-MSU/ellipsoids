module m_profile

! Профайлер (отслеживание затраченного времени на различные куски программы).
! В начале вызвать profile_init, после каждого интересующего нас куска
! вызывать profile_toc с номером ячейки, куда следует записать затраченное
! время.

#ifdef MPI
use m_mpi
#endif

implicit none

private

! Таймер
! ------
!
! Таймер предназначен для определения текущего смещения по времени. Имеет смысл
! только разность значений, возвращаемых в соседних вызовах, но не абсолютное
! значение.
type, abstract, public :: t_profile_timer
    private
    contains
    procedure(i_time), deferred, nopass :: time
end type

abstract interface
    function i_time result(t)
        real(8) t
    end function
end interface

! Реализации таймеров

#ifdef MPI
type, public, extends(t_profile_timer) :: t_profile_timer_mpi
    contains
    procedure, nopass :: time => mpi_timer_time
end type
#endif

type, public, extends(t_profile_timer) :: t_profile_timer_cpu
    contains
    procedure, nopass :: time => cpu_timer_time
end type

! Данные по одной категории профайлера
type t_profile_category
    private
    logical :: used = .false.    ! использована ли данная ячейка
    character(256) :: tag = ''   ! метка (используется как в toc, так и в выводе результатов)
    real(8) :: time = 0          ! общее затраченное время на эту категорию
    integer(8) :: flop_count = 0 ! общее затраченное число операций с плавающей точкой на эту категорию
end type

! Профайлер
! ---------
!
! Порядок работы:
! 1. Предварительная настройка. Можно поменять количество категорий (N) или
! явно указать, какой таймер надо использовать.
!
! 2. Вызвать initialize. Будет автоматически определено наличие и статус MPI, и
! соответственно будет использоваться либо таймер MPI, либо стандартный таймер.
!
! 3. Можно придать метки отдельным категориям с помощью tag.
!
! 4. В ходе вычислений вызывать flop с указанием количества потраченных
! операций.
!
! 5. Вызывать toc(...) после каждой секции кода, указывая необходимую категорию.
! Можно указывать:
! - только номер
! - номер и метку, тогда метка будет переопределена
! - метку, тогда будет найдена категория по метке (или создана новая)
!
! 6. Вызвать report для печати отчёта (отдельного или по всем нодам).
!
type, public :: t_profiler
    private
    class(t_profile_timer), pointer, public :: timer => null() ! используемый таймер
#ifdef MPI
    integer(MPI_ACCI) :: rank = 0
    logical, public :: mpi = .false. ! флаг использования MPI
#endif
    integer, public :: N = 100 ! количество категорий
    type(t_profile_category), pointer :: categories(:) => null() ! данные по категориям
    real(8) :: start_time = 0 ! время начала работы
    real(8) :: last_time = 0 ! время на момент вызова последнего toc
    real(8) :: eta_time ! время начала определения ETA
    integer(8) :: last_flop_count = 0 ! количество операций на момент вызова последнего toc
    integer(8) :: flop_count = 0 ! общее количество операций
    contains
    procedure :: initialize => profiler_initialize
    procedure :: tag => profiler_tag
    procedure :: toc => profiler_toc
    procedure :: flop => profiler_flop
    procedure :: flopi => profiler_flopi
    procedure :: report => profiler_report
    procedure :: start_eta => profiler_start_eta
    procedure :: eta => profiler_eta
    procedure :: total => profiler_total
    procedure :: avg => profiler_avg
    procedure, private :: reduce => profiler_reduce
end type

! глобальная переменная с профайлером
type(t_profiler), public :: profiler

contains

#ifdef MPI
function mpi_timer_time result(t)
    real(8) t
    t = MPI_Wtime()
end function
#endif

function cpu_timer_time result(t)
    real(8) t
    call cpu_time(t)
end function

! инициализация
subroutine profiler_initialize(this)
    class(t_profiler) this
    
    ! выделяем память под категории
    allocate( this%categories(this%N) )

    ! определяем, какой таймер необходимо использовать
#ifdef MPI
    ! инициализировано ли MPI?
    if( this%mpi ) then
        allocate( t_profile_timer_mpi :: this%timer )

        ! определяем ранг
        call MPI_comm_rank(MPI_COMM_WORLD, this%rank, ierr)
    else
        allocate( t_profile_timer_cpu :: this%timer )
    end if
#else
    allocate( t_profile_timer_cpu :: this%timer )
#endif

    ! записываем начальное время
    this%start_time = this%timer%time()
    this%last_time = this%start_time
end subroutine

! работа с метками
subroutine profiler_tag(this, tag, n_in, n_out)
    class(t_profiler) this
    character(*), intent(in), optional :: tag ! метка
    ! если указано n_in, то категории с этим номером присваивается данная метка
    integer, intent(in), optional :: n_in 
    ! если указано n_out и не указано n_in, то в n_out возвращается либо
    ! номер существующей категории с данной меткой, либо номер новой категории.
    integer, intent(out), optional :: n_out

    integer n

    if( present(n_in) ) then
        ! в случае если указан n_in
        if( n_in < 1 .or. n_in > this%N ) stop "Profiler: invalid category number"
        associate( c => this%categories(n_in) )
            c%used = .true.
            if( present(tag) ) then
                if( len_trim(c%tag) > 0 .and. trim(c%tag) /= trim(tag) ) then
                    write(*, '(A, I0, A)') 'WARNING: profiler category ', n_in, ' is already assigned a different tag'
                else
                    c%tag = trim(tag)
                end if
            end if
            if( present(n_out) ) n_out = n_in
        end associate
    else
        if( .not. present(tag) ) stop "Profiler: both n_in and tag are absent in 'tag'"

        ! если не указан - ищем
        do n = 1,this%N
            associate( c => this%categories(n) )
                if( c%used .and. trim(c%tag) == trim(tag) ) then
                    ! нашли
                    if( present(n_out) ) n_out = n
                    return
                end if
            end associate
        end do

        ! не нашли
        ! ищем незанятую категорию
        do n = 1,this%N
            associate( c => this%categories(n) )
                if( .not. c%used ) then
                    c%tag = trim(tag)
                    c%used = .true.
                    if( present(n_out) ) n_out = n
                    return
                end if
            end associate
        end do

        ! вообще не нашли
        stop "Profiler: all categories are used, increase N"
    end if
end subroutine

! запись затраченного времени и операций
subroutine profiler_toc(this, n, tag)
    class(t_profiler) this
    integer, intent(in), optional :: n ! номер ячейки
    character(*), intent(in), optional :: tag ! метка

    integer n0
    real(8) time

    ! текущее время
    time = this%timer%time()
    ! определяем номер ячейки
    call this%tag(tag, n, n0)

    associate( c => this%categories(n0) )
        c%used = .true.
        c%time = c%time + (time - this%last_time)
        c%flop_count = c%flop_count + (this%flop_count - this%last_flop_count)
    end associate

    this%last_time = time
    this%last_flop_count = this%flop_count
end subroutine

! прибавление количества операций
subroutine profiler_flop(this, k)
    class(t_profiler) this
    integer(8), intent(in), value :: k
    this%flop_count = this%flop_count + k
end subroutine

! прибавление количества операций
subroutine profiler_flopi(this, k)
    class(t_profiler) this
    integer, intent(in), value :: k
    this%flop_count = this%flop_count + k
end subroutine

subroutine profiler_reduce(this, v, v_sum, v_min, v_max)
    class(t_profiler) this
    real(8), intent(in), value :: v ! агрегируемое значение
    real(8), intent(out), optional :: v_max ! максимальное значение
    real(8), intent(out), optional :: v_min ! минимальное значение
    real(8), intent(out), optional :: v_sum ! суммарное значение

    if( present(v_sum) ) then
#ifdef MPI
        if( this%mpi ) then
            call MPI_allreduce(v, v_sum, 1, MPI_REAL8, MPI_SUM, MPI_COMM_WORLD, ierr)
        else
            v_sum = v
        end if
#else
        v_sum = v
#endif
    endif
    if( present(v_max) ) then
#ifdef MPI
        if( this%mpi ) then
            call MPI_allreduce(v, v_max, 1, MPI_REAL8, MPI_MAX, MPI_COMM_WORLD, ierr)
        else
            v_max = v
        end if
#else
        v_max = v
#endif
    endif
    if( present(v_min) ) then
#ifdef MPI
        if( this%mpi ) then
            call MPI_allreduce(v, v_min, 1, MPI_REAL8, MPI_MIN, MPI_COMM_WORLD, ierr)
        else
            v_min = v
        end if
#else
        v_min = v
#endif
    endif
end subroutine

! распечатка результатов
subroutine profiler_report(this, u)
    class(t_profiler) this
    integer, intent(in), value :: u ! на который юнит распечатывать
    real(8) tmax, tmin, tsum, smin, smax, fsum, ttotal, ttotalsum, ttotalmax, ttotalmin, ftotalsum, stotalmin, stotalmax
    integer j

#ifdef MPI
    if( this%mpi ) call MPI_barrier(MPI_COMM_WORLD, ierr)
#endif
    ttotal = this%timer%time() - this%start_time
#ifdef MPI
    if( this%rank == 0 ) then
#endif
        write(u, '(A, F0.1, A)') 'Time elapsed: ', ttotal, ' s' 
        write(u, '(A)') "Profile results:"
#ifdef MPI
        if( this%mpi ) then
            write(u, '(A4, 7(A9), "  ", A)') "ITEM", "MIN", "MAX", "SUM", "SUM", "MIN", "MAX", "TOTAL", "TAG"
            write(u, '(A4, 7(A9))') "#", "sec", "sec", "sec", "flop", "flop/s", "flop/s", "flop/s"
        else
#endif
            write(u, '(A4, 3(A9), "  ", A)') "#", "TIME", "FLOP", "FLOP/s", "TAG"
#ifdef MPI
        end if
    end if
#endif

    ! вычисляем суммарные затраты времени
    call this%reduce(ttotal, v_sum = ttotalsum, v_max = ttotalmax, v_min = ttotalmin)

    ! отчёт по отдельным категориям
    do j = 1,this%N
        associate( c => this%categories(j) )
            if( c%used ) then
                call this%reduce(c%time, v_sum = tsum)
                ! распечатываем только категории с суммарными затратами времени
                ! не менее 1%
                if( tsum < ttotalsum * .01 ) cycle
                call this%reduce(c%time, v_min = tmin, v_max = tmax)
                call this%reduce(real(c%flop_count, 8), v_sum = fsum)
                call this%reduce(c%flop_count/c%time, v_min = smin, v_max = smax)

#ifdef MPI
                if( this%rank == 0 ) then
                    if( this%mpi ) then
                        write(u, '(I4, 7(ES9.1), "  ", A)') j, tmin, tmax, tsum, fsum, smin, smax, fsum/tmax, trim(c%tag)
                    else
#endif
                        write(u, '(I4, 3(ES9.1), "  ", A)') j, tsum, fsum, smax, trim(c%tag)
#ifdef MPI
                    end if
                end if
#endif
            end if
        end associate
    end do    

    ! общий отчёт
    call this%reduce(real(this%flop_count, 8), v_sum = ftotalsum)
    call this%reduce(this%flop_count/ttotalmax, v_min = stotalmin, v_max = stotalmax)
#ifdef MPI
    if( this%rank == 0 ) then
        if( this%mpi ) then
            write(u, '(A4, 7(ES9.1), "  ", A)') "*", ttotalmin, ttotalmax, ttotalsum, ftotalsum, stotalmin, stotalmax, ftotalsum/ttotalmax, "TOTAL"
        else
#endif
            write(u, '(A4, 3(ES9.1), "  ", A)') "*", ttotalsum, ftotalsum, stotalmax, "TOTAL"
#ifdef MPI
        end if
    end if
#endif
end subroutine

! оценка оставшегося времени
! оценивается, сколько ещё будет происходить равномерный процесс на интервале
! [t_0, t_1], если в текущий момент мы находимся в t.
function profiler_eta(this, t, t0, t1) result(eta)
    class(t_profiler) this
    double precision, intent(in), value :: t0, t1, t
    double precision eta
    eta = max(0D0, (this%timer%time() - this%eta_time)/(t - t0) * (t1 - t))
end function

! оценка суммарного времени
function profiler_total(this, t, t0, t1) result(total)
    class(t_profiler) this
    double precision, intent(in), value :: t0, t1, t
    double precision total
    total = max(0D0, (this%timer%time() - this%eta_time)/(t - t0) * (t1 - t0))
end function

! среднее время на итерацию
function profiler_avg(this, k, k0) result(avg)
    class(t_profiler) this
    integer, intent(in), value :: k, k0
    double precision avg
    avg = (this%timer%time() - this%eta_time)/(k - k0)
end function

! начало отсчёта ETA
subroutine profiler_start_eta(this)
    class(t_profiler) this
    this%eta_time = this%timer%time()
end subroutine

end module
