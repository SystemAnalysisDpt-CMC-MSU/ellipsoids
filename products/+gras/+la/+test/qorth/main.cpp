#include "mex.h"
#include <math.h>
#include <memory.h>
void Orth(int ,double *,double *);
void mexFunction(int nOut,mxArray *pOut[],int nIn,mxArray *pIn[])
{
	int n,m;
	double *pI,*pO;
	if (nIn!=1) 
		mexErrMsgTxt("One argument required");
	if (!mxIsDouble(pIn[0]))
		mexErrMsgTxt("Input have to be double");
	m=mxGetM(pIn[0]);n=mxGetN(pIn[0]);
	if (n!=1) mexErrMsgTxt("Input must be a vector-column");
	if (nOut>0) 
	{
		
		pOut[0]=mxCreateDoubleMatrix(m,m,mxREAL);
		pI=mxGetPr(pIn[0]);
		pO=mxGetPr(pOut[0]);
		Orth(m,pI,pO);
	}
}
double getNorm(int n,double *ptr)
{
	double sum=0;
	for (int i=0;i<n;i++)
		sum+=ptr[i]*ptr[i];
	return sqrt(sum);
}
void normalize(int n,double *ptr)
{
	double norm=getNorm(n,ptr);
	for (int i=0;i<n;i++)
		ptr[i]/=norm;
}
void absolute(int n,double *ptr)
{
	for (int i=0;i<n;i++) if (ptr[i]<0) ptr[i]=-ptr[i];
}

void Orth(int m,double *pI,double *pO)
{
	int imax=0,i,j,l;
	double *ptr;
	double *ptr1;
	double *ptr2;
	double sum,mm=m-1;
	memcpy(pO,pI,m*sizeof(double));
    normalize(m,pO);
	ptr=pO+m;
    memcpy(ptr,pO,m*sizeof(double));
	absolute(m,ptr);
	for (i=1;i<m;i++)
	{
		if (ptr[i]>ptr[imax]) imax=i;
	}
    ptr1=ptr;
	for (j=0;j<mm;j++)
	{
		if (j<imax)
			l=j;
		else 
     		l=j+1;
		for(i=0;i<m;i++)
		{   for(sum=0,ptr2=pO;ptr2<ptr1;ptr2+=m)
			{
			sum=sum-(ptr2[i])*(ptr2[l]);
 			}
			ptr1[i]=sum;
		}
	    ptr1[l]++;
		normalize(m,ptr1);
		ptr1+=m;
	}
}