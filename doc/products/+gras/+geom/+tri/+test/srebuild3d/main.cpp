#include "mex.h"
#include <math.h>
#include <memory.h>
#include "ammeral.h"
#define MAX_DEPTH 4
void mexFunction(int nOut,mxArray *pOut[],int nIn,mxArray *pIn[])
{
	int m,n;
	double *pI;
	if (nIn!=1) 
	{
		mexErrMsgTxt("One arguments required");
    }
	if (!mxIsDouble(pIn[0]))
	{
		mexErrMsgTxt("Input have to be double");
	}
	m=mxGetM(pIn[0]);n=mxGetN(pIn[0]);
	if ((m!=1)||(n!=1)) mexErrMsgTxt("error in input");
	if (nOut==2) 
	{
		pI=mxGetPr(pIn[0]);
		Preparation();
		int depth=pI[0];
		if (depth>MAX_DEPTH) depth=3;
		if (depth>0)
		{
			BuildGranulation(depth);
		}
		Transformation(pOut);
	}
	else 
	{
		mexErrMsgTxt("Incorrect output");

	}
}




