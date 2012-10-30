#include "triangle.h"
Vertex  get_mid(Vertex &v1,Vertex & v2)
{
	double x12=0.5*(v1.x+v2.x);
	double y12=0.5*(v1.y+v2.y);
	double z12=0.5*(v1.y+v2.y);
    Vertex res(x12,y12,z12);
	return res;
}
Vertex::Vertex(Vertex & v)
{
	x=v.x;
	y=v.y;
	z=v.z;
}
Vertex::Vertex(double &xx,double&yy,double &zz)
{
	x=xx;
	y=yy;
	z=zz;
}
Vertex & Vertex::operator = (const Vertex & v)
{
	x=v.x;
	y=v.y;
	z=v.z;
	return *this;
}

Face::Face(){};
Face::Face(int ii,int jj,int kk)
{
	i=ii;j=jj;k=kk;
}
Face::Face(Face &s)
{
	i=s.i;j=s.j;k=s.k;
}
