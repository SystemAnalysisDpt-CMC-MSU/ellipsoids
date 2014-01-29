#include <stdio.h>
#include <math.h>
#include <process.h>
#include "triangle.h"
#include "mex.h"
#define MAX_VERTICES 10242
#define MAX_FACES 20480
#define MAX_EDGES_MID_PREV 7680
void point(int i, double x, double y, double z);
void subdivide(int A, int B, int C);
void storeface(int i, int j, int k);
void midpnt(int B, int C, int *pP, double x, double y, double z);
int npoints;
Vertex *pnt[MAX_VERTICES];
int nface;
Face *fc[MAX_FACES];
Face *fc1[MAX_FACES];

int nedge;
struct {int i, j, P;} edges[MAX_EDGES_MID_PREV];
void Preparation()
{
    int i, l;
    double pi, r, alpha, tau;
    pi = 4 * atan(1.0);
    tau = (sqrt(5.0) + 1)/2;  /* tau = 2 * cos(pi/5)  */
    r = tau - 0.5;
    point(1, 0.0, 0.0, 1.0); /* North pole */   /* Северный полюс */
    for (i=0; i<5; i++)
    { alpha = -pi/5 + i * pi/2.5;
      point(2+i, cos(alpha)/r, sin(alpha)/r, 0.5/r);
    }
    for (i=0; i<5; i++)
    { alpha = i * pi/2.5;
      point(7+i, cos(alpha)/r, sin(alpha)/r, -0.5/r);
    }
    point(12, 0.0, 0.0, -1.0); /* South pole */   /* Южный полюс */
    npoints = 12;nface=0;nedge=0;
    for (i=0; i<5; i++) subdivide(1, 2+i, i<4 ? 3+i : 2);
    for (i=0; i<5; i++) subdivide(2+i, 7+i, i<4 ? 3+i : 2);
    for (i=0; i<5; i++) subdivide(7+i, i<4 ? 8+i : 7, i<4 ? i+3 : 2);
    for (i=0; i<5; i++) subdivide(i+7, 12, i<4 ? i+8 : 7);
}
void midpnt(int B, int C, int *pP, double x, double y, double z)
/*    Точка (x, y, z) является средней точкой отрезка BC.
 * Если это новая вершина, то она запоминается и записывается в
 * объектный файл данных с использованием нового номера вершины.
 * Если нет, то находится ее номер вершины. Номер вершины должен
 * быть приписан *pP в любом случае.
 *
 * Point (x, y, z) is midpoint of BC.
 * If it is a new vertex, store it and write it to the object file,
 * using a new vertex number. If not, find its vertex number.
 * The vertex number is to be assigned to *pP anyway.
 */
{ int tmp, e;
  if (C < B) {tmp = B; B = C; C = tmp;}
  /* B, C in increasing order, for the sake of uniqueness */
  /* B и C в порядке возрастания ради унификации	  */
  for (e=0; e<nedge; e++)
      if (edges[e].i == B && edges[e].j == C) break;
  if (e == nedge)   /* Not found, so we have a new vertex */
      /* Не обнаружено, значит имеем новую вершину */
  { edges[e].i = B; edges[e].j = C;
    edges[e].P = *pP = ++npoints;
    nedge++;
    point(*pP, x, y, z);
  } else *pP = edges[e].P;
  /* Edge BC has been dealt with before, so the vertex is not new
   * Ребро BC уже рассматривалось ранее, следовательно вершина не новая
   */
}
void point(int i, double x, double y, double z)
{
    pnt[i]=new Vertex(x,y,z);
    
}
void subdivide(int A, int B, int C)

/*  Деление треугольника ABC на четыре малых треугольника  */
/*  Divide triangle ABC into four smaller triangles        */

{
    double xP, yP, zP, xQ, yQ, zQ, xR, yR, zR,dP,dQ,dR;
    int P, Q, R;
    /* Значение переменной d равно -1 только до первого обращения к этой
     * функции; после первого вызова переменной d будет присвоено точное
     * значение  (между 0 и 1),  равное  расстоянию  между любой средней
     * точкой и центром сферы. Все средние точки  проецируются  на сферу
     * (с радиусом 1) путем деления на d значений их координат.
     *
     * d is equal to -1 only before the first  call  of this  function;
     * after this,  d will have  its correct  value  (between 0 and 1),
     * namely  the distance between any midpoint and the center of the
     * sphere. We project all midpoints onto the sphere (with radius 1)
     * by dividing their coordinates by d.
     */
    xP = (pnt[B]->x + pnt[C]->x)/2;
    yP = (pnt[B]->y + pnt[C]->y)/2;
    zP = (pnt[B]->z + pnt[C]->z)/2;
    
    xQ = (pnt[C]->x + pnt[A]->x)/2;
    yQ = (pnt[C]->y + pnt[A]->y)/2;
    zQ = (pnt[C]->z + pnt[A]->z)/2;
    
    xR = (pnt[A]->x + pnt[B]->x)/2;
    yR = (pnt[A]->y + pnt[B]->y)/2;
    zR = (pnt[A]->z + pnt[B]->z)/2;
    dP = sqrt(xP*xP + yP*yP + zP*zP);
    dR = sqrt(xR*xR + yR*yR + zR*zR);
    dQ = sqrt(xQ*xQ + yQ*yQ + zQ*zQ);
    /* 0 < d < 1 */
    xP /= dP; yP /= dP; zP /= dP;
    xQ /= dQ; yQ /= dQ; zQ /= dQ;
    xR /= dR; yR /= dR; zR /= dR;
    midpnt(B, C, &P, xP, yP, zP);
    midpnt(C, A, &Q, xQ, yQ, zQ);
    midpnt(A, B, &R, xR, yR, zR);
    storeface(A, R, Q);
    storeface(R, B, P);
    storeface(Q, P, C);
    storeface(Q, R, P);
}
void storeface(int i, int j, int k)
{
    fc[nface]=new Face(i,j,k);
    nface++;
}
void BuildGranulation(int depth)
{
    int tmp;
    for (int i=0;i<depth;i++)
    {
        tmp=nface;
        nface=0;
        nedge=0;
        for (int s=0;s<tmp;s++)
        {
            fc1[s]=fc[s];
        }
        for (int s=0;s<tmp;s++)
        {
            subdivide(fc1[s]->i,fc1[s]->j ,fc1[s]->k );
            delete fc1[s];
        }
    }
}
void Transformation(mxArray **pOut)
{
    double *pO1,*pO2;
    pOut[0]=mxCreateDoubleMatrix(npoints,3,mxREAL);
    pOut[1]=mxCreateDoubleMatrix(nface,3,mxREAL);
    pO1=mxGetPr(pOut[0]);
    pO2=mxGetPr(pOut[1]);
    int dnpoints=npoints+npoints;
    for (int i=1,i1=npoints,i2=dnpoints;i<=npoints;i++,i1++,i2++)
    {
        pO1[i-1]=pnt[i]->x;
        pO1[i1]=pnt[i]->y;
        pO1[i2]=pnt[i]->z;
        delete pnt[i];
    }
    int dnface=nface+nface;
    for (int i=0,i1=nface,i2=dnface;i<nface;i++,i1++,i2++)
    {
        pO2[i]=fc[i]->i;
        pO2[i1]=fc[i]->j;
        pO2[i2]=fc[i]->k;
        delete  fc[i];
    }
    
}