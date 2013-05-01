program elle

use m_ea
use m_closed_loop
use m_profile
use m_mpi
use m_linear_ode
use m_random
use m_util
use m_mat_save

implicit none

class(t_ea), pointer :: ea => null()
class(t_closed_loop), pointer :: cl => null()
double precision seed
integer iseed
character(256) prefix

#ifdef MPI
integer(MPI_ACCI) rank, proc
#endif

#ifdef MPI
call MPI_init(ierr)
profiler%mpi = .true.
#endif
call profiler%initialize

! randomize
call init_random_seed
call random_number(seed)
#ifdef MPI
call MPI_comm_rank(MPI_COMM_WORLD, rank, ierr)
call MPI_comm_size(MPI_COMM_WORLD, proc, ierr)
seed = (seed + rank)/proc
#endif
iseed = seed*huge(iseed)
call g05cbf(iseed)

allocate( ea )
call setup_approximation(ea)
call ea%compute

call get_program_parameter("prefix", prefix, "default")
call mat_save_ea(trim(prefix)//"data.mat", ea);

!allocate( cl )
!cl%ea => ea
!call cl%initialize
!call setup_closed_loop(cl)
!call cl%simulate
call profiler%report(6)

#ifdef MPI
call MPI_finalize(ierr)
#endif

end program
