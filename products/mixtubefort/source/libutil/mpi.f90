module m_mpi

implicit none

#ifdef MPI
include 'mpif.h'

integer, parameter :: MPI_ACCI=4
integer(MPI_ACCI) ierr
integer(MPI_ACCI) stat(MPI_STATUS_SIZE)
#endif

end module
