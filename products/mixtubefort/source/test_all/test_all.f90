program test_all

use fruit
use m_random
use m_linalg_tests
use m_ea_ode_tests
use m_springs_tests
use m_profile

implicit none

call profiler%initialize
call init_fruit
call init_random_seed
call test_linalg_all
call test_ea_ode_all
call test_springs_all
call fruit_summary

end program
