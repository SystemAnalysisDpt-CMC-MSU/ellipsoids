module m_util

implicit none

private

interface get_program_parameter
    module procedure get_program_parameter_character
    module procedure get_program_parameter_logical
    module procedure get_program_parameter_double
    module procedure get_program_parameter_integer
end interface

public :: get_program_parameter

contains

pure function minus_to_underscore(c) result(d)
    character(*), intent(in) :: c
    character(len(c)) d
    integer j

    d = c
    do j = 1,len(c)
        if( c(j:j) == '-' ) then
            d(j:j) = '='
        end if
    end do
end function

pure function underscore_to_minus(c) result(d)
    character(*), intent(in) :: c
    character(len(c)) d
    integer j

    d = c
    do j = 1,len(c)
        if( c(j:j) == '_' ) then
            d(j:j) = '-'
        end if
    end do
end function

pure function upper(c) result(d)
    character(*), intent(in) :: c
    character(len(c)) d
    integer j, z

    d = c
    do j = 1,len(c)
        z = ichar(c(j:j))
        if( z >= ichar('a') .and. z <= ichar('z') ) then
            d(j:j) = char(z - ichar('a') + ichar('A'))
        end if
    end do
end function

pure function lower(c) result(d)
    character(*), intent(in) :: c
    character(len(c)) d
    integer j, z

    d = c
    do j = 1,len(c)
        z = ichar(c(j:j))
        if( z >= ichar('A') .and. z <= ichar('Z') ) then
            d(j:j) = char(z - ichar('A') + ichar('a'))
        end if
    end do
end function

! получение параметров из переменных окружения или аргументов командной строки
! параметр с именем label ищется
! * сначала в окружении (переменная "LABEL")
! * потом в командной строке (следующий аргумент после --label)
! * иначе берётся значение по умолчанию, если оно указано
! * совсем иначе возвращается пустая строка
subroutine get_program_parameter_character(p_name, p_value, p_default)
    character(*), intent(in) :: p_name ! имя параметра
    character(*), intent(out) :: p_value ! значение параметра
    character(*), intent(in), optional :: p_default ! значение по умолчанию
    character(255) arg, val
    integer j

    ! ищем в окружении
    call get_environment_variable(upper(minus_to_underscore(p_name)), val)
    if( len_trim(val) > 0 ) then
        p_value = trim(val)
        return
    end if

    ! ищем в командной строке
    do j = 1,iargc()-1
        call get_command_argument(j, arg)
        if( trim(arg) == '--'//trim(lower(underscore_to_minus(p_name))) ) then
            call get_command_argument(j+1, p_value)
            return
        end if
    end do

    ! значение по умолчанию
    if( present(p_default) ) p_value = p_default
end subroutine

! получение логического параметра
! * из переменной среды: LABEL=y/n
! * из аргументов командной строки: --label, --no-label
! * из значения по умолчанию (если указано)
subroutine get_program_parameter_logical(p_name, p_value, p_default)
    character(*), intent(in) :: p_name ! имя параметра
    logical, intent(out) :: p_value ! значение параметра
    logical, intent(in), optional :: p_default ! значение по умолчанию
    character(255) arg, val
    integer j

    ! ищем в окружении
    call get_environment_variable(upper(minus_to_underscore(p_name)), val)
    if( len_trim(val) > 0 ) then
        val = lower(val)
        if( val(1:1) == "y" ) then
            p_value = .true.
        else if( val(1:1) == "n" ) then
            p_value = .false.
        else 
            write(*, '(5A)') "WARNING: unrecognized value for parameter ", &
                trim(p_name), " (", trim(val), "), assuming 'n' (false)"
            p_value = .false.
        end if
        return
    end if

    ! ищем в командной строке
    do j = 1,iargc()
        call get_command_argument(j, arg)
        if( trim(arg) == '--'//trim(lower(underscore_to_minus(p_name))) ) then
            p_value = .true.
            return
        end if
        if( trim(arg) == '--no-'//trim(lower(underscore_to_minus(p_name))) ) then
            p_value = .false.
            return
        end if
    end do

    ! значение по умолчанию
    if( present(p_default) ) then
        p_value = p_default
    end if
end subroutine

! получение целочисленного параметра
! сначала получается в строковом виде, потом преобразуется в целочисленный
subroutine get_program_parameter_integer(p_name, p_value, p_default)
    character(*), intent(in) :: p_name ! имя параметра
    integer, intent(out) :: p_value ! значение параметра
    integer, intent(in), optional :: p_default ! значение по умолчанию
    character(256) val

    call get_program_parameter(p_name, val, "")
    if( len_trim(val) > 0 ) then
        read(val, *) p_value
    else if( present(p_default) ) then
        p_value = p_default
    end if
end subroutine

! получение вещественного параметра
! сначала получается в строковом виде, потом преобразуется в вещественный
subroutine get_program_parameter_double(p_name, p_value, p_default)
    character(*), intent(in) :: p_name ! имя параметра
    double precision, intent(out) :: p_value ! значение параметра
    double precision, intent(in), optional :: p_default ! значение по умолчанию
    character(256) val

    call get_program_parameter(p_name, val, "")
    if( len_trim(val) > 0 ) then
        read(val, *) p_value
    else if( present(p_default) ) then
        p_value = p_default
    end if
end subroutine

end module
