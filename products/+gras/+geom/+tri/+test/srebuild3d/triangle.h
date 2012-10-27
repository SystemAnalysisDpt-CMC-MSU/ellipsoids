class Face
{
public:
	Face();
	Face(int ii,int jj, int kk);
	Face(Face &);
	int i;
	int j;
	int k;
};
class Vertex
{

public:
	int number;
	Vertex(){};
	Vertex(Vertex &);
	Vertex(double &,double &,double &);
	Vertex & operator = (const Vertex &);
	double x,y,z;
};
Vertex  get_mid(Vertex &v1,Vertex & v2);
