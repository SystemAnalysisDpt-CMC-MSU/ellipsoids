#include "mex.h"
#include <math.h>
#include <memory.h>
bool FindExtremPoints(double *,double *,double *,int);
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
		if(FindExtremPoints(pI1,pI2,pO,n0))
		{
			mxDestroyArray(pOut[0]);
			pOut[0] = NULL;
            mxDestroyArray(pOut[0]);
            pOut[0]=mxCreateDoubleMatrix(1,1,mxREAL);
            pO=mxGetPr(pOut[0]);
            *pO=mxGetNaN();
			//mlfAssign(&pOut[0], mlfNan());
		}
	}
}
double SProduct(double *src1,double *src2)
{
	return src1[0]*src2[0]+src1[1]*src2[1];
}
void SolveL(double* p,double *pA0,double *pA1,double *pb0,double *pb1)
{
	double detA=pA0[0]*pA1[1]-pA0[1]*pA1[0];
	double detx=pb0[0]*pA1[1]-pb1[0]*pA0[1];
	double dety=pA0[0]*pb1[0]-pA1[0]*pb0[0];
	p[0]=detx/detA;p[1]=dety/detA;
}
bool FindExtremPoints(double * data_dir,double* data_sup,double* data_res,int n)
{
	//double *data_X=new double[n+n];
	//int *data_I= new int[n];
	double * data_X=(double *)mxCalloc(n+n,sizeof(double));
	int *data_I=(int *)mxCalloc(n,sizeof(int));
	int ipp(0),ip(1),ipn,ippn,tmp,tmp1,tmp2,tmp0;
	double cur_nscal(1);
	data_I[0]=0;data_I[1]=1;
	int d(4),s(2),rs,rd,k;
	SolveL(data_X,data_dir,data_dir+2,data_sup,data_sup+1);
	for (;s<n;s++,d+=2)
	{
		rs=ip-1;
		rd=rs+rs;
		while (SProduct(data_X+rd,data_dir+d)>data_sup[s])
		{
			rd-=2;rs--;
			if (rs<ipp)
			{
				break;
			}
		}
		ipn=rs+1;
		if	(cur_nscal<0)
		{	
			tmp=ip+ip;
			if (SProduct(data_X+tmp,data_dir+d)>data_sup[s])
			{
				rs=ipp;
				rd=rs+rs;
				tmp=ip-1;
				while (SProduct(data_X+rd,data_dir+d)>data_sup[s])
				{
					rd+=2;rs++;
					if (rs>=tmp)
					{
						break;
					}
				}
				ippn=rs;
			}
			else
			{
				ippn=ip;
			}
		}
		else
		{
			ippn=ipp;
		}
		if ((ipn<ip)||(ippn<ip)||(cur_nscal>=0))
		{
			ip=ipn+1;
			ipp=ippn;
			if (ipp>=ip)
			{
				/////////////////
		//		res=nan;ћножество €вл€етс€ пустым
				//необходимо посмотреть, как реализуетс€ 
			//	присвоение свойсво Ёнеопределено инициалзированной переменной
			//		пэтому мы должны находитс€ в том само метсе в котром рождаютс€ 
			//		мечты и мы должны действовать достаточно быстро.
				//delete [] data_X;
				mxFree(data_X);
				mxFree(data_I);
				return true;
			}
			data_I[ip]=s;
			tmp=ipn+ipn;
			tmp1=data_I[ipn]+data_I[ipn];
			SolveL(data_X+tmp,data_dir+tmp1,data_dir+d,data_sup+data_I[ipn],data_sup+s);
			tmp1=data_I[ipp]+data_I[ipp];
			cur_nscal=data_dir[d+1]*data_dir[tmp1]-data_dir[d]*data_dir[tmp1+1];
			if (cur_nscal<0)
			{	
				tmp=ip+ip;
				SolveL(data_X+tmp,data_dir+tmp1,data_dir+d,data_sup+data_I[ipp],data_sup+s);
			}
		}
	}
	for (k=ipp;k<=ip;k++)
	{
		tmp=k+k;
		tmp1=data_I[k]+data_I[k];
		memcpy(data_res+tmp1,data_X+tmp,2*sizeof(double));
	}
	tmp=ip-1;
	for (k=0;k<=tmp;k++)
	{
		tmp0=data_I[k]+1;
		tmp1=data_I[k+1]-1;
		tmp2=data_I[k]+data_I[k];
		for (s=tmp0;s<=tmp1;s++)
		{
			memcpy(data_res+s+s,data_res+tmp2,2*sizeof(double));
		}
	}
	tmp0=data_I[ipp]-1;
	tmp1=data_I[ip]+data_I[ip];
	for (s=0;s<=tmp0;s++)
	{
		memcpy(data_res+s+s,data_res+tmp1,2*sizeof(double));
	}
	tmp0=data_I[ip]+1;
	for (s=tmp0;s<n;s++)
	{
		memcpy(data_res+s+s,data_res+tmp1,2*sizeof(double));
	}
	mxFree(data_X);
	mxFree(data_I);
	return false;
}
	
	
	
