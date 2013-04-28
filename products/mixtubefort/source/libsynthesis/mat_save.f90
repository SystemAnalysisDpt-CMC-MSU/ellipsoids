#include "fintrf.h"

module m_mat_save

use m_ea
use m_ea_ode
use m_springs
use m_matrix

implicit none

contains

subroutine mat_save_ea(filename, ea)

    implicit none

    class(t_ea), intent(in) :: ea
    character(*), intent(in) :: filename

    mwPointer matOpen, mxCreateDoubleMatrix, mxGetPr
    integer matPutVariable, matClose, mxIsFromGlobalWS

    mwPointer mp
    integer status, t

    mp = matOpen(filename, "w")

    associate( nx => ea%nx, nu => ea%nu, nv => ea%nv, nl => ea%nl, ny => ea_ode%ny, nt => ea%Nt, ntx => ea%Ntx )

        call mat_save_1d_integer(mp, "nx",  nx );
        call mat_save_1d_integer(mp, "nu",  nu );
        call mat_save_1d_integer(mp, "nv",  nv );
        call mat_save_1d_integer(mp, "nl",  nl );
        call mat_save_1d_integer(mp, "ntx", ntx);
        call mat_save_1d_integer(mp, "nt",  nt);
        call mat_save_1d_integer(mp, "ny",  ny);
        call mat_save_1d_integer(mp, "method", ea%method);

        call mat_save_1d_double (mp, "alpha", ea%alpha);
        call mat_save_1d_double (mp, "beta",  ea%beta );
        call mat_save_1d_double (mp, "t0",    ea%t0   );
        call mat_save_1d_double (mp, "t1",    ea%t1   );
        call mat_save_1d_double (mp, "tolerance", ea%tolerance);
        call mat_save_1d_double (mp, "threshold", ea%threshold);

        call mat_save_2d_double(mp,  "bMat", nx, nu,  ea%B );
        call mat_save_2d_double(mp,  "cMat", nx, nv,  ea%C );
        call mat_save_2d_double(mp,  "lMat", nx, nl,  ea%L );
        call mat_save_2d_double(mp,  "pVec", nu,  1,  ea%pc);
        call mat_save_2d_double(mp,  "pMat", nu, nu,  ea%P );
        call mat_save_2d_double(mp,  "qVec", nv,  1,  ea%qc);
        call mat_save_2d_double(mp,  "qMat", nv, nv,  ea%Q );
        call mat_save_2d_double(mp,  "mVec", nx,  1,  ea%mc);
        call mat_save_2d_double(mp,  "mMat", nx, nx,  ea%M );

        select type ( A => ea%operator_A )
        type is ( t_springs_operator )
            call mat_save_1d_integer(mp,  "springs_n",  A%springs%n);
            call mat_save_2d_double (mp,  "springs_m",  A%springs%n,  1,  A%springs%m );
            call mat_save_2d_double (mp,  "springs_k",  A%springs%n,  1,  A%springs%k );
            call mat_save_2d_integer(mp,  "springs_iu", A%springs%nu, 1,  A%springs%iu );
            call mat_save_2d_integer(mp,  "springs_iv", A%springs%nv, 1,  A%springs%iv );
        type is ( t_matrix )
            call mat_save_2d_double(mp,  "aMat", nx, nx,  A%A );
        end select
        
        call mat_save_2d_double (mp, "tVec", nt, 1,  ea%t );
        call mat_save_2d_double (mp, "yMat", ny, nt,  ea%y );

    end associate

    status = matClose(mp)
   
end subroutine

subroutine mat_save_1d_double(matfile,varname,d)
    mwPointer, intent(in) :: matfile
    character(*), intent(in) :: varname
    double precision, intent(in), value :: d
    double precision dd(1); dd(1) = d
    call mat_save_2d_double(matfile,varname,1,1,dd)
end subroutine

subroutine mat_save_2d_double(matfile,varname,m,n,d)
    mwPointer, intent(in) :: matfile
    character(*), intent(in) :: varname
    integer, intent(in), value :: m, n
    double precision, intent(in) :: d(m, n)
    mwPointer mxCreateNumericMatrix, mxClassIDFromClassName, mxGetPr, pa
    integer matPutVariable, status

    pa = mxCreateNumericMatrix(m,n,mxClassIDFromClassName('double'),0)
    call mxCopyReal8ToPtr(d, mxGetPr(pa), m*n)
    status = matPutVariable(matfile, varname, pa)
    call mxDestroyArray(pa)
end subroutine


subroutine mat_save_3d_double(matfile,varname,m,n,p,d)
    mwPointer, intent(in) :: matfile
    character(*), intent(in) :: varname
    integer, intent(in), value :: m, n, p
    double precision, intent(in) :: d(m,n,p)
    mwPointer mxCreateNumericArray, mxClassIDFromClassName, mxGetPr, pa
    integer matPutVariable, status

    mwSize dims(3);
    dims(1) = m; dims(2) = n; dims(3) = p; 

    pa = mxCreateNumericArray(3,dims,mxClassIDFromClassName('double'),0)
    call mxCopyReal8ToPtr(d, mxGetPr(pa), m*n*p)
    status = matPutVariable(matfile, varname, pa)
    call mxDestroyArray(pa)
end subroutine

subroutine mat_save_4d_double(matfile,varname,m,n,p,q,d)
    mwPointer, intent(in) :: matfile
    character(*), intent(in) :: varname
    integer, intent(in), value :: m, n, p, q
    double precision, intent(in) :: d(m,n,p,q)
    mwPointer mxCreateNumericArray, mxClassIDFromClassName, mxGetPr, pa
    integer matPutVariable, status

    mwSize dims(4);
    dims(1) = m; dims(2) = n; dims(3) = p; dims(4) = q; 

    pa = mxCreateNumericArray(4,dims,mxClassIDFromClassName('double'),0)
    call mxCopyReal8ToPtr(d, mxGetPr(pa), m*n*p*q)
    status = matPutVariable(matfile, varname, pa)
    call mxDestroyArray(pa)
end subroutine

subroutine mat_save_1d_integer(matfile,varname,d)
    mwPointer, intent(in) :: matfile
    character(*), intent(in) :: varname
    integer, intent(in), value :: d
    integer dd(1); dd(1) = d
    call mat_save_2d_integer(matfile,varname,1,1,dd)
end subroutine

subroutine mat_save_2d_integer(matfile,varname,m,n,d)
    mwPointer, intent(in) :: matfile
    character(*), intent(in) :: varname
    integer, intent(in), value :: m, n
    integer, intent(in) :: d(m, n)
    mwPointer mxCreateNumericMatrix, mxClassIDFromClassName, mxGetPr, pa
    integer matPutVariable, status

    pa = mxCreateNumericMatrix(m,n,mxClassIDFromClassName('int32'),0)
    call mxCopyInteger4ToPtr(d, mxGetPr(pa), m*n)
    status = matPutVariable(matfile, varname, pa)
    call mxDestroyArray(pa)
end subroutine

end module
