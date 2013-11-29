
#include <mex.h>
#include <string.h>
#include <stdio.h>

void ConvexHull(int size,double* indProjVec,double* improveDirectVec,int num_points,double* points,double* Amat,double* bVec,double* discrVec,double* vertMat, double* controlParams,double* sizeMat){
 //main function for which mex-file will be written

    read_par (controlParams);

    in_read (size,indProjVec, improveDirectVec);
    conv_go(NULL,num_points,points);
    out_write(Amat,bVec,discrVec,vertMat,sizeMat);
   }
void mexFunction(int nlhs,mxArray *plhs[],

int nrhs,const mxArray *prhs[])

{ //mex-function for ellipsoid's approx
	int size,num_points, i;
	int *indProjVec,*improveDirectVec;
	double *points,*controlParams,*bVec,*discrVec,*sizeMat;
	double *Amat,*vertMat;


	if (nrhs !=6) {
		mexErrMsgTxt("Six input arguments are nedeed.");
	}

	else if (nlhs !=5) {
		mexErrMsgTxt("Five input arguments are nedeed.");
		}
	    size = mxGetScalar(prhs[0]);
		indProjVec=(int*)mxGetPr(prhs[1]);
		improveDirectVec=(int *) mxGetPr(prhs[2]);
		num_points= mxGetScalar(prhs[3]);
		points= mxGetPr(prhs[4]);
		controlParams= mxGetPr(prhs[5]);
		plhs[1] = mxCreateDoubleMatrix(1, num_points*100, mxREAL);
		plhs[3] = mxCreateDoubleMatrix(1, size*num_points*100, mxREAL);
		plhs[0] = mxCreateDoubleMatrix(1, size*num_points*100, mxREAL);
		plhs[2] = mxCreateDoubleMatrix(1, num_points*100, mxREAL);
        Amat=mxGetPr(plhs[0]);
		bVec=mxGetPr(plhs[1]);
        vertMat=mxGetPr(plhs[3]);
		discrVec=mxGetPr(plhs[2]);
		plhs[4]=mxCreateDoubleMatrix(1, 4, mxREAL);
		sizeMat=mxGetPr(plhs[4]);
		ConvexHull(size,indProjVec, improveDirectVec, num_points, points, Amat, bVec, discrVec,vertMat,  controlParams,sizeMat);
 }


