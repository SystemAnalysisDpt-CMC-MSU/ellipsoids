#include "mex.h"
#include <math.h>
#include <memory.h>
void Intersect(double *,double *,double *,int);
void SolveL(double* p,double *pA0,double *pA1,double *pb1,double *pb2);
void mexFunction(int nOut,mxArray *pOut[],int nIn,mxArray *pIn[])
{
	int n0,m0,n1,m1;
	double *pI1,*pI2,*pO;
	if (nIn!=2) 
		mexErrMsgTxt("Two arguments required");
	if (!mxIsDouble(pIn[0]))
		mexErrMsgTxt("Input have to be double");
    if (!mxIsDouble(pIn[1]))
		mexErrMsgTxt("Input have to be double");

	m0=mxGetM(pIn[0]);n0=mxGetN(pIn[0]);
	m1=mxGetM(pIn[1]);n1=mxGetN(pIn[1]);
	if ((m1!=1)||(m0!=2)||(n0!=n1)) mexErrMsgTxt("error in input");
	if (nOut==1) 
	{
		
		pOut[0]=mxCreateDoubleMatrix(2,n0,mxREAL);
		pI1=mxGetPr(pIn[0]);
		pI2=mxGetPr(pIn[1]);
		pO=mxGetPr(pOut[0]);
		Intersect(pI1,pI2,pO,n0);
	}
}
void SolveL(double* p,double *pA0,double *pA1,double *pb0,double *pb1)
{
	double detA=pA0[0]*pA1[1]-pA0[1]*pA1[0];
	double detx=pb0[0]*pA1[1]-pb1[0]*pA0[1];
	double dety=pA0[0]*pb1[0]-pA1[0]*pb0[0];
	p[0]=detx/detA;p[1]=dety/detA;
}
void Intersect(double * pI1,double* pI2,double* pO,int n)
{   int nn=n-1;
	int max=2*(n-1);
	int j=0;
	for(int i=0;j<nn;i+=2,j++)
	{
     SolveL(pO+i,pI1+i,pI1+i+2,pI2+j,pI2+j+1);
	}
	SolveL(pO+max,pI1+max,pI1,pI2+nn,pI2);
}