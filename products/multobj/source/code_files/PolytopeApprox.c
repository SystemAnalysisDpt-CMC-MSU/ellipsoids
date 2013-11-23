
#include <mex.h>
#include <string.h>
#include <stdio.h>
void PolytopeApprox(int size,double* indProjVec,double* improveDirectVec,double ** inEqPolyMat, double ** eqPolyMat,double * inEqPolyVec,double * eqPolyVec, double* Amat,double* bVec,double* discrVec,double* vertMat, double* controlParams){
 //main function for which mex-file will be written

    read_par (controlParams);
    in_read (size,indProjVec, improveDirectVec);
    conv_go(NULL,0,NULL);
    out_write(Amat,bVec,discrVec,vertMat);
   }
