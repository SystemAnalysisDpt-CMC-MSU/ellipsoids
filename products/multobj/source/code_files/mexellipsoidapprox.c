
#include <mex.h>
#include <string.h>
#include <stdio.h>
void EllipsoidApprox(int size,double* indProjVec,double* improveDirectVec,double* centervec, double* semiaxes,double* Amat,double* bVec,double* discrVec,double* vertMat, double* controlParams,double* sizeMat){
 //main function for which mex-file will be written
    read_par (controlParams);
    in_read (size,indProjVec, improveDirectVec);
    conv_go(semiaxes,0,NULL);
    out_write(Amat,bVec,discrVec,vertMat,sizeMat);
   }

void mexFunction(int nlhs,mxArray *plhs[],

int nrhs,const mxArray *prhs[])

{ //mex-function for ellipsoid's approx
	int size,i ;
	double* sizeMat;
	int *indProjVec,*improveDirectVec;
	double *centervec,*semiaxes,*controlParams,*bVec,*discrVec;
	double *Amat,*vertMat;


	if (nrhs !=6) {
		mexErrMsgTxt("Six input arguments are nedeed.");
	}

	else if (nlhs !=5) {
		mexErrMsgTxt("Five output arguments are nedeed.");
		}
	    size = mxGetScalar(prhs[0]);
		indProjVec=(int*)mxGetPr(prhs[1]);
		improveDirectVec=(int*) mxGetPr(prhs[2]);
		centervec= mxGetPr(prhs[3]);
		semiaxes= mxGetPr(prhs[4]);
		controlParams= mxGetPr(prhs[5]);
		plhs[1] = mxCreateDoubleMatrix(1, 30000, mxREAL);
		plhs[3] = mxCreateDoubleMatrix(1, size*30000, mxREAL);
		plhs[0] = mxCreateDoubleMatrix(1, size*30000, mxREAL);
		plhs[2] = mxCreateDoubleMatrix(1, 30000, mxREAL);
		Amat=mxGetPr(plhs[0]);
		bVec=mxGetPr(plhs[1]);
		vertMat=mxGetPr(plhs[3]);
		discrVec=mxGetPr(plhs[2]);
		plhs[4]=mxCreateDoubleMatrix(1, 4, mxREAL);
		sizeMat=mxGetPr(plhs[4]);
		EllipsoidApprox(size,indProjVec, improveDirectVec, centervec, semiaxes, Amat, bVec,discrVec, vertMat,  controlParams,sizeMat);

 }
