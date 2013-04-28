!------------------------
! FORTRAN unit test utility
!
! Author: Andrew H. Chen meihome @at@ gmail.com
!------------------------
!
! Unit test framework for FORTRAN.  (FoRtran UnIT)
!
! This package is to perform unit test for FORTRAN subroutines
!
! The method used most are: assert_true, assert_equals
! 
! Coding convention:  
!   1) All methods must be exposed by interface.  i.e. interface init_fruit
!   2) Variable and methods are lower case connected with underscores.  i.e. init_fruit, and
!      failed_assert_count
!
module fruit
  use fruit_util
  implicit none
  private

  integer, parameter :: MSG_LENGTH = 256
  integer, parameter :: MAX_MSG_STACK_SIZE = 2000
  integer, parameter :: MSG_ARRAY_INCREMENT = 50
  
  character(*), parameter :: DEFAULT_UNIT_NAME = '_not_set_'

  integer, private, save :: current_max = 50
  integer, private, save :: successful_assert_count = 0
  integer, private, save :: failed_assert_count = 0
  character (len = MSG_LENGTH), private, allocatable :: message_array(:)
  character (len = MSG_LENGTH), private, save :: msg = '[unit name not set from set_name]: '
  character (len = MSG_LENGTH), private, save :: unit_name  = DEFAULT_UNIT_NAME
  integer, private, save :: messageIndex = 1

  integer, private, save :: successful_case_count = 0
  integer, private, save :: failed_case_count = 0
  integer, private, save :: testCaseIndex = 1
  logical, private, save :: last_passed = .false.

  public :: &
    init_fruit, initializeFruit, fruit_summary, getTestSummary, get_last_message, &
    is_last_passed, assert_true, assertTrue, assert_equals, assertEquals, &
    assert_not_equals, assertNotEquals, add_success, addSuccess, &
    addFail, add_fail, set_unit_name, get_unit_name, &
    failed_assert_action, get_total_count, getTotalCount, &
    get_failed_count, getFailedCount, is_all_successful, isAllSuccessful, &
    run_test_case, runTestCase

  interface initializeFruit
     module procedure obsolete_initializeFruit_
  end interface

  interface getTestSummary
     module procedure obsolete_getTestSummary_  
  end interface

  interface assertTrue
     module procedure obsolete_assert_true_logical_
  end interface

  interface assert_equals
     module procedure assert_eq_int_
     module procedure assert_eq_double_
     module procedure assert_eq_real_
     module procedure assert_eq_logical_
     module procedure assert_eq_string_
     module procedure assert_eq_complex_
     module procedure assert_eq_real_in_range_
     module procedure assert_eq_double_in_range_

     module procedure assert_eq_1d_int_
     module procedure assert_eq_1d_double_
     module procedure assert_eq_1d_real_
     module procedure assert_eq_1d_string_
     module procedure assert_eq_1d_complex_
     module procedure assert_eq_1d_real_in_range_
     module procedure assert_eq_1d_double_in_range_

     module procedure assert_eq_2d_int_
     module procedure assert_eq_2d_double_
     module procedure assert_eq_2d_real_
     module procedure assert_eq_2d_complex_
  end interface

  interface assertEquals
     module procedure assert_eq_int_
     module procedure assert_eq_double_
     module procedure assert_eq_real_
     module procedure assert_eq_logical_
     module procedure assert_eq_string_
     module procedure assert_eq_complex_
     module procedure assert_eq_real_in_range_
     module procedure assert_eq_double_in_range_

     module procedure assert_eq_1d_int_
     module procedure assert_eq_1d_double_
     module procedure assert_eq_1d_real_
     module procedure assert_eq_1d_string_
     module procedure assert_eq_1d_complex_
     module procedure assert_eq_1d_real_in_range_
     module procedure assert_eq_1d_double_in_range_

     module procedure assert_eq_2d_int_
     module procedure assert_eq_2d_double_
     module procedure assert_eq_2d_real_
     module procedure assert_eq_2d_complex_
  end interface

  interface assert_not_equals
     module procedure assert_not_equals_real_
     module procedure assert_not_equals_1d_real_
     module procedure assert_not_equals_double_
  end interface

  interface assertNotEquals
     module procedure assert_not_equals_real_
     module procedure assert_not_equals_1d_real_
     module procedure assert_not_equals_double_
  end interface

  interface addSuccess
     module procedure obsolete_addSuccess_
  end interface

  interface add_fail
     module procedure add_fail_
     module procedure add_fail_unit_
  end interface

  interface addFail
     module procedure add_fail_
     module procedure add_fail_unit_
  end interface

  interface getTotalCount
     module procedure obsolete_getTotalCount_
  end interface

  interface getFailedCount
     module procedure obsolete_getFailedCount_
  end interface

  interface isAllSuccessful
     module procedure obsolete_isAllSuccessful_
  end interface

  interface run_test_case
     module procedure run_test_case_
     module procedure run_test_case_named_
  end interface

  interface runTestCase
     module procedure run_test_case_
     module procedure run_test_case_named_
  end interface

contains

  subroutine init_fruit
    successful_assert_count = 0
    failed_assert_count = 0
    messageIndex = 1
    write (*,*)
    write (*,*) "Test module initialized"
    write (*,*)
    write (*,*) "   . : successful assert,   F : failed assert "
    write (*,*)
    if ( .not. allocated(message_array) ) then
      allocate(message_array(MSG_ARRAY_INCREMENT)) 
    end if
  end subroutine init_fruit

  subroutine obsolete_initializeFruit_
    call obsolete_ ("initializeFruit is OBSOLETE.  replaced by init_fruit")
    call init_fruit
  end subroutine obsolete_initializeFruit_

  subroutine obsolete_getTestSummary_
    call obsolete_ ( "getTestSummary is OBSOLETE.  replaced by fruit_summary")
    call fruit_summary
  end subroutine obsolete_getTestSummary_

  ! Run a named test case
  subroutine run_test_case_named_( tc, tc_name )
    interface
       subroutine tc()
       end subroutine
    end interface
    character(*), intent(in) :: tc_name

    integer :: initial_failed_assert_count

    initial_failed_assert_count = failed_assert_count

    ! Set the name of the unit test
    call set_unit_name( tc_name )

    last_passed = .true.

    call tc()

    if ( initial_failed_assert_count .eq. failed_assert_count ) then
       ! If no additional assertions failed during the run of this test case
       ! then the test case was successful
       successful_case_count = successful_case_count+1
    else
       failed_case_count = failed_case_count+1
    end if

    testCaseIndex = testCaseIndex+1
    
    ! Reset the name of the unit test back to the default
    call set_unit_name( DEFAULT_UNIT_NAME )

  end subroutine run_test_case_named_

  ! Run an 'unnamed' test case
  subroutine run_test_case_( tc )
    interface
       subroutine tc()
       end subroutine
    end interface

    call run_test_case_named_( tc, '_unnamed_' )

  end subroutine run_test_case_

  subroutine fruit_summary
    integer :: i

    write (*,*)
    write (*,*)
    write (*,*) '    Start of FRUIT summary: '
    write (*,*)

    if (failed_assert_count > 0) then
       write (*,*) 'Some tests failed!'
    else
       write (*,*) 'SUCCESSFUL!'
    end if

    write (*,*)
    if ( messageIndex > 1) then
       write (*,*) '  -- Failed assertion messages:'

       do i = 1, messageIndex - 1
          write (*,"(A)") '   '//trim(strip(message_array(i)))
       end do

       write (*,*) '  -- end of failed assertion messages.'
       write (*,*)
    else
       write (*,*) '  No messages '
    end if

    if (successful_assert_count + failed_assert_count /= 0) then

       write (*,*) 'Total asserts :   ', successful_assert_count + failed_assert_count
       write (*,*) 'Successful    :   ', successful_assert_count
       write (*,*) 'Failed        :   ', failed_assert_count
       write (*,'("Successful rate:   ",f6.2,"%")')  real(successful_assert_count) * 100.0 / &
            real (successful_assert_count + failed_assert_count)
       write (*, *)
       write (*,*) 'Successful asserts / total asserts : [ ',&
            successful_assert_count, '/', successful_assert_count + failed_assert_count, ' ]'
       write (*,*) 'Successful cases   / total cases   : [ ', successful_case_count, '/', &
            successful_case_count + failed_case_count, ' ]'
       write (*, *) '  -- end of FRUIT summary'

    end if
  end subroutine fruit_summary

  subroutine obsolete_addSuccess_
    call obsolete_ ("addSuccess is OBSOLETE.  replaced by add_success")
    call add_success
  end subroutine obsolete_addSuccess_

  subroutine add_fail_ (message)
    character (*), intent (in), optional :: message
    call failed_assert_action('none', 'none', message)
  end subroutine add_fail_

  subroutine add_fail_unit_ (unitName, message)
    character (*), intent (in) :: unitName
    character (*), intent (in) :: message

    call add_fail_ ("[in " //  unitName // "(fail)]: " //  message)
  end subroutine add_fail_unit_

  subroutine obsolete_isAllSuccessful_(result)
    logical, intent(out) :: result
    call obsolete_ ('subroutine isAllSuccessful is changed to function is_all_successful.')
    result = (failed_assert_count .eq. 0 )
  end subroutine obsolete_isAllSuccessful_

  subroutine is_all_successful(result)
    logical, intent(out) :: result
    result= (failed_assert_count .eq. 0 )
  end subroutine is_all_successful

  subroutine success_mark_
    write(*,"(A1)",ADVANCE='NO') '.'
  end subroutine success_mark_

  subroutine failed_mark_
    write(*,"(A1)",ADVANCE='NO') 'F'
  end subroutine failed_mark_

  subroutine increase_message_stack_
    character(len=MSG_LENGTH) :: msg_swap_holder(current_max)

    if (messageIndex > MAX_MSG_STACK_SIZE) then
       write(*,*) "Stop because there are too many error messages to put into stack."
       write (*,*) "Try to increase MAX_MSG_STACK_SIZE if you really need so."
       call getTestSummary ()
       stop 1
    end if

    if (messageIndex > current_max) then
      msg_swap_holder(1:current_max) = message_array(1:current_max)
      deallocate(message_array)
      current_max = current_max + MSG_ARRAY_INCREMENT
      allocate(message_array(current_max))
      message_array(1:current_max - MSG_ARRAY_INCREMENT) &
                   = msg_swap_holder(1: current_max - MSG_ARRAY_INCREMENT)
    end if
    
    message_array (messageIndex) = msg
    messageIndex = messageIndex + 1
  end subroutine increase_message_stack_

  function get_last_message()
    character(len=MSG_LENGTH) :: get_last_message
    if (messageIndex > 1) then
       get_last_message = strip(message_array(messageIndex-1))
    else
       get_last_message = ''
    end if
  end function get_last_message

  subroutine obsolete_getTotalCount_ (count)
    integer, intent (out) :: count
    call obsolete_ (' getTotalCount subroutine is replaced by function get_total_count')
    call get_total_count(count)
  end subroutine obsolete_getTotalCount_

  subroutine get_total_count(count) 
    integer, intent(out) :: count

    count = successful_assert_count + failed_assert_count
  end subroutine get_total_count

  subroutine obsolete_getFailedCount_ (count)
    integer, intent (out) :: count

    call obsolete_ (' getFailedCount subroutine is replaced by function get_failed_count')
    call get_failed_count (count)

  end subroutine obsolete_getFailedCount_

  subroutine get_failed_count (count)
    integer, intent(out) :: count
    count = failed_assert_count
  end subroutine get_failed_count

  subroutine obsolete_ (message)
    character (*), intent (in), optional :: message
    write (*,*) 
    write (*,*) "<<<<<<<<<<<<<<<<<<<<<<<<<< WARNING from FRUIT >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    write (*,*) message
    write (*,*) 
    write (*,*) " old calls will be replaced in the next release in Jan 2009"
    write (*,*) " Naming convention for all the method calls are changed to: first_name from"
    write (*,*) " firstName.  Subroutines that will be deleted: assertEquals, assertNotEquals,"
    write (*,*) " assertTrue, addSuccessful, addFail, etc."
    write (*,*) "<<<<<<<<<<<<<<<<<<<<<<<<<< WARNING from FRUIT >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    write (*,*) 
  end subroutine obsolete_

  subroutine add_success
    successful_assert_count = successful_assert_count + 1
    last_passed = .true.
    call success_mark_  
  end subroutine add_success

  subroutine failed_assert_action (expected, got, message)
    character(*), intent(in) :: expected, got
    character(*), intent(in), optional :: message

    call make_error_msg_ (expected, got, message)
    call increase_message_stack_
    failed_assert_count = failed_assert_count + 1
    last_passed = .false.
    call failed_mark_
  end subroutine failed_assert_action

  subroutine set_unit_name(value)
    character(*), intent(in) :: value
    unit_name = strip(value)
  end subroutine set_unit_name

  subroutine get_unit_name(value)
    character(*), intent(out) :: value
    value = strip(unit_name)
  end subroutine get_unit_name

  subroutine make_error_msg_ (var1, var2, message)
    character(*), intent(in) :: var1, var2
    character(*), intent(in), optional :: message
    msg = '[' // trim(strip(unit_name)) // ']: Expected [' // trim(strip(var1)) &
          // '], Got [' // trim(strip(var2)) // ']'
    if (present(message)) then
       msg = trim(msg) // '; User message: [' // message // ']'
    endif
  end subroutine make_error_msg_

  function is_last_passed()
    logical:: is_last_passed
    is_last_passed = last_passed 
  end function is_last_passed

  !--------------------------------------------------------------------------------
  ! all assertions
  !--------------------------------------------------------------------------------
  subroutine obsolete_assert_true_logical_(var1, message)
    logical, intent (in) :: var1
    character (*), intent (in), optional :: message

    call obsolete_ ('assertTrue subroutine is replaced by function assert_true')
    call assert_true(var1, message)
  end subroutine obsolete_assert_true_logical_

  subroutine assert_true (var1, message)
    logical, intent (in) :: var1
    character (*), intent (in), optional :: message

    if ( var1 .eqv. .true.) then
       call add_success
    else
       call failed_assert_action(to_s(.true.), to_s(var1), message)
    end if
  end subroutine assert_true

  subroutine assert_eq_int_ (var1, var2, message)
    integer, intent(in) :: var1, var2
    character (*), intent(in), optional :: message

    if ( var1 .eq. var2) then
       call add_success
    else
       call failed_assert_action (to_s(var1), to_s(var2), message)
    end if
  end subroutine assert_eq_int_

  subroutine assert_eq_logical_ (var1, var2, message)
    logical, intent (in)  :: var1, var2
    character (*), intent (in), optional :: message

    if ( var1 .eqv. var2 ) then
       call add_success
    else
       call failed_assert_action(to_s(var1), to_s(var2), message)
    end if
  end subroutine assert_eq_logical_

  subroutine assert_eq_string_ (var1, var2, message)
    character(*), intent (in)  :: var1, var2
    character (*), intent (in), optional :: message

    if ( trim(strip(var1)) == trim(strip(var2))) then
       call add_success
    else
       call failed_assert_action(var1, var2, message)
    end if
  end subroutine assert_eq_string_

  subroutine assert_eq_real_ (var1, var2, message)
    real, intent (in) :: var1, var2
    character (*), intent (in), optional :: message

    if ( var1 .eq. var2) then
       call add_success
    else
7      call failed_assert_action(to_s(var1), to_s(var2), message)
    end if
  end subroutine assert_eq_real_

  subroutine assert_eq_double_ (var1, var2, message)
    double precision, intent (in) :: var1, var2
    character(*), intent(in), optional :: message

    if ( var1 .eq. var2) then
       call add_success
    else
       call failed_assert_action(to_s(var1), to_s(var2), message)
    end if
  end subroutine assert_eq_double_

  subroutine assert_eq_complex_ (var1, var2, message)
    complex(kind=kind(1.0D0)), intent(IN) :: var1, var2
    character (*),             intent(IN), optional :: message

    if ( var1 .ne. var2) then
       call failed_assert_action(to_s(var1), to_s(var2), message)
    else
       call add_success
    end if

  end subroutine assert_eq_complex_

  subroutine assert_eq_real_in_range_(var1, var2, var3, message)
    real, intent (in) :: var1, var2, var3
    character(*), intent(in), optional :: message

    if ( abs( var1 - var2) .le. var3) then
       call add_success
    else
       call failed_assert_action(to_s(var1), to_s(var2), message)
    end if

  end subroutine assert_eq_real_in_range_

  subroutine assert_eq_double_in_range_(var1, var2, var3, message)
    double precision, intent (in) :: var1, var2, var3
    character(*), intent(in), optional :: message

    if ( abs( var1 - var2) .le. var3) then
       call add_success
    else
       call failed_assert_action(to_s(var1), to_s(var2), message)
    end if
  end subroutine assert_eq_double_in_range_

  subroutine assert_eq_1d_int_ (var1, var2, n, message)
    integer, intent (in) :: n
    integer, intent (in) :: var1(n), var2(n)
    character (*), intent (in), optional :: message

    integer count

    loop_dim1: do count = 1, n
       if ( var1(count) .ne. var2(count)) then
          call failed_assert_action(to_s(var1(count)), to_s(var2(count)), message)
          return
       end if
    end do loop_dim1

    call add_success
  end subroutine assert_eq_1d_int_

  subroutine assert_eq_1d_string_ (var1, var2, n, message)
    integer, intent (in) :: n
    character(*), intent (in) :: var1(n), var2(n)
    character (*), intent (in), optional :: message
    integer count

    loop_dim1: do count = 1, n
       if ( strip(var1(count)) .ne. strip(var2(count))) then
          call failed_assert_action(var1(count), var2(count), message)
          return
       end if
    end do loop_dim1

    call add_success
  end subroutine assert_eq_1d_string_

  subroutine assert_eq_1d_real_in_range_(var1, var2, n, var3, message)
    integer, intent(in) :: n
    real, intent (in) :: var1(n), var2(n), var3
    character(*), intent(in), optional :: message

    if ( maxval( abs( var1 - var2)) .le. var3) then
       call add_success
    else
       call failed_assert_action(to_s(var1(1)), to_s(var2(1)), &
                                 '1D array real has difference' // ' ' // message)
    end if
  end subroutine assert_eq_1d_real_in_range_

  subroutine assert_eq_1d_double_in_range_(var1, var2, n, var3, message)
    integer, intent(in) :: n
    double precision, intent (in) :: var1(n), var2(n), var3
    character(*), intent(in), optional :: message

    if ( maxval( abs( var1 - var2)) .le. var3) then
       call add_success
    else
       call failed_assert_action(to_s(var1(1)), to_s(var2(1)), message)
    end if
  end subroutine assert_eq_1d_double_in_range_

  subroutine assert_eq_1d_double (var1, var2, n, message)
    integer, intent (in) :: n
    double precision, intent (in) :: var1(n), var2(n)
    character(*), intent(in), optional :: message

    integer count

    loop_dim1: do count = 1, n
       if ( var1(count) .ne. var2(count)) then
          call failed_assert_action(to_s(var1(count)), to_s(var2(count)), &
               'Array different at count: ' // to_s(count) // ' ' // message)
          return
       end if
    end do loop_dim1

    call add_success
  end subroutine assert_eq_1d_double

  subroutine assert_eq_2d_real (var1, var2, n, m)
    integer, intent (in) :: n, m
    real, intent (in) :: var1(n,m), var2(n,m)

    integer count1, count2

    loop_dim2: do count2 = 1, m
       loop_dim1: do count1 = 1, n
          if ( var1(count1,count2) .ne. var2(count1,count2)) then
             call failed_assert_action(to_s(var1(count1, count2)), to_s(var2(count1, count2)),&
                  'Array (' // to_s(count1) // ',' // to_s( count2) //')')
             return
          end if
       end do loop_dim1
    end do loop_dim2

    call add_success
  end subroutine assert_eq_2d_real

  subroutine assert_eq_2d_double (var1, var2, n, m)
    integer, intent (in) :: n, m
    double precision, intent (in) :: var1(n,m), var2(n,m)

    integer count1, count2

    loop_dim2: do count2 = 1, m
       loop_dim1: do count1 = 1, n
          if ( var1(count1,count2) .ne. var2(count1,count2)) then
             call failed_assert_action(to_s(var1(count1, count2)), to_s(var2(count1, count2)), &
                  'Array difference at (' // to_s(count1) // ',' // to_s(count2) // ')')
             return
          end if
       end do loop_dim1
    end do loop_dim2

    call add_success
  end subroutine assert_eq_2d_double

  subroutine assert_eq_2d_int_ (var1, var2, n, m, message)
    integer, intent (in) :: n, m
    integer, intent (in) :: var1(n,m), var2(n,m)
    character (*), intent (in), optional :: message

    integer count1, count2

    loop_dim2: do count2 = 1, m
       loop_dim1: do count1 = 1, n
          if ( var1(count1,count2) .ne. var2(count1,count2)) then
             call failed_assert_action(to_s(var1(count1, count2)), &
                                       to_s(var2(count1, count2)), message)
             return
          end if
       end do loop_dim1
    end do loop_dim2

    call add_success
  end subroutine assert_eq_2d_int_

  subroutine assert_eq_1d_real_ (var1, var2, n, message)
    integer, intent (in) :: n
    real, intent (in) :: var1(n), var2(n)
    character (*), intent (in), optional :: message

    integer count

    loop_dim1: do count = 1, n
       if ( var1(count) .ne. var2(count)) then
          call failed_assert_action(to_s(var1(count)), to_s(var2(count)), message)
          return
       end if
    end do loop_dim1
    call add_success
  end subroutine assert_eq_1d_real_

  subroutine assert_eq_2d_real_ (var1, var2, n, m, message)
    integer, intent (in) :: n, m
    real, intent (in) :: var1(n,m), var2(n,m)
    character (*), intent(in), optional :: message

    integer count1, count2

    loop_dim2: do count2 = 1, m
       loop_dim1: do count1 = 1, n
          if ( var1(count1,count2) .ne. var2(count1,count2)) then
             call failed_assert_action(to_s(var1(count1, count2)), &
                                       to_s(var2(count1, count2)), message)
             return
          end if
       end do loop_dim1
    end do loop_dim2

    call add_success
  end subroutine assert_eq_2d_real_

  subroutine assert_eq_1d_double_ (var1, var2, n, message)
    integer, intent (in) :: n
    double precision, intent (in) :: var1(n), var2(n)
    character (*), intent (in), optional :: message
    integer count

    loop_dim1: do count = 1, n
       if ( var1(count) .ne. var2(count)) then
          call failed_assert_action(to_s(var1(count)), to_s(var2(count)), message)
          return
       end if
    end do loop_dim1

    call add_success
  end subroutine assert_eq_1d_double_

  subroutine assert_eq_2d_double_ (var1, var2, n, m, message)
    integer, intent (in) :: n, m
    double precision, intent (in) :: var1(n,m), var2(n,m)
    character (*), intent (in), optional :: message
    integer count1, count2

    loop_dim2: do count2 = 1, m
       loop_dim1: do count1 = 1, n
          if ( var1(count1,count2) .ne. var2(count1,count2)) then
             call failed_assert_action(to_s(var1(count1, count2)), &
                                       to_s(var2(count1, count2)), message)
             return
          end if
       end do loop_dim1
    end do loop_dim2

    call add_success
  end subroutine assert_eq_2d_double_

  subroutine assert_eq_1d_complex_ (var1, var2, n, message)
    integer,                   intent(IN) :: n
    complex(kind=kind(1.0D0)), intent(IN) :: var1(n), var2(n)
    character (*),             intent(IN), optional :: message
    integer count

    loop_dim1: do count = 1, n
       if ( var1(count) .ne. var2(count)) then
          call failed_assert_action(to_s(var1(count)), to_s(var2(count)), message)
          return
       end if
    enddo loop_dim1

    call add_success
  end subroutine assert_eq_1d_complex_

  subroutine assert_eq_2d_complex_ (var1, var2, n, m, message)
    integer,                   intent(IN) :: n, m
    complex(kind=kind(1.0D0)), intent(IN) :: var1(n,m), var2(n,m)
    character (*),             intent(IN), optional :: message
    integer count1, count2

    loop_dim2: do count2 = 1, m
       loop_dim1: do count1 = 1, n
          if ( var1(count1,count2) .ne. var2(count1,count2)) then
             call failed_assert_action(to_s(var1(count1, count2)), &
                                       to_s(var2(count1, count2)), message)
             return
          endif
       enddo loop_dim1
    enddo loop_dim2

    call add_success
  end subroutine assert_eq_2d_complex_

  subroutine assert_not_equals_real_ (var1, var2, message)
    real, intent (in) :: var1, var2
    character (*), intent (in), optional :: message

    if ( var1 .ne. var2) then
       call add_success
    else
       call failed_assert_action(to_s(var1), to_s(var2), message)
    end if
  end subroutine assert_not_equals_real_

  subroutine assert_not_equals_double_ (var1, var2, message)
    double precision, intent (in) :: var1, var2
    character(*), intent(in), optional :: message

    if ( var1 .ne. var2) then
       call add_success
    else
       call failed_assert_action(to_s(var1), to_s(var2), message)
    end if
  end subroutine assert_not_equals_double_

  subroutine assert_not_equals_1d_real_ (var1, var2, n)
    integer, intent (in) :: n
    real, intent (in) :: var1(n), var2(n)

    integer count

    loop_dim1: do count = 1, n
       if ( var1(count) .ne. var2(count)) then
          call failed_assert_action(to_s(var1(count)), to_s(var2(count)),&
               'Array (' // to_s(count)//')')
          return
       end if
    end do loop_dim1

    call add_success

  end subroutine assert_not_equals_1d_real_

end module fruit
