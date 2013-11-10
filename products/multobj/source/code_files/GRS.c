/*#define CH_LP_PC   approksimaciya po MPS-fajlu */
/*#define CH_LPM     simpleks Malkova */
/*#define CH_POINTS*/  
#define CH_ELIPSE /*approksimaciya e'lipsoidov*/ 

#include "StdAfx.h"


#ifdef CH_ELIPSE
#include <math.h>
#endif

#include <string.h>
#include <stdio.h>
#include <conio.h>
#include <malloc.h>
#include "ch_main.h"
//#include "menu_s.h"

#ifdef CH_LP_PC
#include "\lp_pc\lp_pc.h"

#define  LP_PC
#include "\lp_pc\lp_pc.def"
#define INITIAL
#include "\lp_pc\initdat.def"
#endif

#ifdef CH_LPM
#define  LPM
#include "lpm\lpm_var.def"
#endif

#define CONVEX
#include "ch_var.def"



int add_top;
void read_par (void);
char *par_name = "set.par";
//char *par_name = NULL;


#ifdef CH_LPM
static int IOlpm;
#endif
static int IOstatus;
static float *c, *x;
static int *objnums;
static int stage = 0; /* stadiya processa : 0 - nachalo, */
		/* 1 - proshlo schityvanie, 2 - est' reshenie */

void wait (void)
 {////clreol ();
  //gotoxy (10, 15);
  //textcolor (12);
  printf ("Nazhmite lyubuyu klavishu . . .\n");
  //getch ();
 }    /* wait */

#ifdef CH_LP_PC
int objfun (c, objnums, Nfunc)
  /* zapis' celevoj funkcii v matricu */
float *c;     /* koe'fficienty celevoj funkcii */
int *objnums; /* nomera kriterial'nyx peremennyx v modeli */
int Nfunc;    /* nomer stroki celevoj funkcii */
 {int i, im, Ncol, done, Nc;

  i = im = Ncol = done = 0;
  Nc = ch_N;
  while (i < imatr [0])
   {if ( ! im)
     {if (Nc != ch_N)
       {printf ("Ne nashli stroku %8d v stolbce %8d",
		Nfunc, Ncol);
return (-7);
       }
      else
       {Ncol++;
	i++;
	for (Nc = 0; Nc < ch_N; Nc++)
	  if (objnums [Nc] == Ncol)
  break;
       }
     }
    else
      if (Nc != ch_N && im == Nfunc)
       {matr [i] = c [Nc];
	Nc = ch_N;
	if (++done == ch_N)
  break;
       }
    im = imatr [++i];
   }
  if (done != ch_N)
   {printf ("Ne vse stolbcy najdeny");
return (-7);
   }
return (0);
 }    /* objfun */

int objfun (float*, int*, int);
#endif

void in_read (int size,int* indProjVec,int* improveDirectVec) //read not from file now
 {int i;

  //clrscr ();
  printf ("Podozhdite, idet schityvanie\n");
  //gotoxy (1, 1);
  IOstatus = ch_read_dat(size, indProjVec, improveDirectVec,&objnums);
  if (IOstatus > 0)
   {

    c = (float*) realloc (c, ch_SIZEctop);
    x = (float*) realloc (x, ch_SIZEctop);
    if (x == NULL) IOstatus = -5;
   }
  if (IOstatus <= 0)
   {////clreol ();
    printf ("\n%s\n", ch_inform (IOstatus));
    stage = 0;
    ch_free_mem ();
    //wait ();
   }
  else
   {for (i = 0; i < ch_N; i++)
     {c [i] = 0.;
#ifdef CH_TXT
      objnums [i] = i + 1;
#endif
     }
//    add_top = 32 - ch_topCOUNT % 32;
    stage = 1;
  }
 }    /* in_read */

void out_write (float*** Amat,float** bVec,float*** vertMat,float** discrVec)
 {//clrscr ();
	 
	 printf("%d", stage);
  if (stage == 2)
   {printf ("Podozhdite, idet zapis'\n");
    //gotoxy (1, 1);
    if (ch_write_dat (Amat,bVec,vertMat,discrVec) < 0) wait();
   
  }
  else
   {printf ("Nechego zapisyvat' !\n");
    wait ();
   }
 }    /* out_write */


void conv_go (double* semiaxes,int num /* for convex hull*/)
 {int i, new_dat;
  static int dat_is_read;
#ifdef CH_LP_PC
  static int Ncon, Nvar, Nfunc, y;
#endif

#ifdef CH_LPM
  static int Ncon, Nvar, Nmatr, Nvar0;
#ifndef CH_TXT
  static int j,k;
#endif
#endif

#ifdef CH_POINTS
  int j, jmax;
  double sum;
  float max;
  static float *coef;
  static int numnum;
#endif

#ifdef CH_ELIPSE
#ifdef CH_VOLUMES
#ifndef CH_SURFACE
  int j, y;
  static double pi = 3.1415926536;
#endif
#endif
  double d;
  static float *axes;
#endif

#ifdef CH_TIME
  int y1, h, m;
  double s;
  time_t t0, t;
#endif

  //clrscr ();
//  new_dat = strcmp (model_name, old_name);
  if(stage == 0 || stage == 2 )
   {printf ("Net dannyx. Osuwestvite chtenie.");
    wait ();
return;
   }

  //ch_max_topCOUNT = ch_topCOUNT + add_top;
  if (stage == 1)
   {
#ifndef CH_ELIPSE
    if (dat_is_read)
     {dat_is_read = 0;
#ifdef CH_LP_PC
      lp_initfree ();
      inibas = 1;
#endif
#ifdef CH_LPM
      lpm_free ();
#endif
     }
    if( ! dat_is_read)
#endif
     {printf ("Podozhdite, idet schityvanie\n");
      //gotoxy (1, 1);

#endif
	wait ();
//return;
       }
#ifdef CH_LP_PC
      if ( ! lp_fromps (model_name, "rhs", "ran", "boun", "obj",
		64, &Ncon, &Nvar, &Nfunc))
       {//clreol ();
	printf ("\nOshibka pri vvode MPS");
	wait ();
return;
       }
#endif

#ifdef CH_LPM
      IOlpm = lpm_read (model_name, &Ncon, &Nvar, &Nmatr,
		&Nvar0, 0, 0, 0);
      if (IOlpm < 0)
       {//clreol ();
	printf ("\n%s\n", lpm_inform (IOlpm));
	printf ("Oshibka pri vvode dannyx");
	wait ();
return;
       }
#endif
#ifdef CH_POINTS
      //fscanf (datstream, "%d", &numnum);
	  numnum=num;//count of points
      coef = (float*) realloc (coef, numnum * sizeof (float));
      if (coef == NULL)
       {printf ("Malo pamyati");
	wait ();
return;
       }
     coef=NULL;//what is it
#endif
#ifdef CH_ELIPSE
      axes = (float*) realloc (axes, ch_N * sizeof (float));
      if (axes == NULL)
       {printf ("Malo pamyati\n");
	wait ();
return;
       }
      for (i = 0; i < ch_N; i++)
       {
	axes [i] = semiaxes [i]*semiaxes[i];/* Kvadraty poluosej */
       }
#endif
      dat_is_read = 1;
     // clrscr ();
     }
   }
#ifdef CH_TIME
  time (&t0);
#endif
  if(IOstatus > 0) IOstatus = ch_primal (c, x, IOstatus);
  
  else if (IOstatus == 0)
	{if (ch_PRNT > 0) ch_inf_print (0);
	}
       else printf ("Prodolzhenie scheta nevozmozhno :\n");
	   
#ifdef CH_ELIPSE
#ifdef CH_VOLUMES
#ifndef CH_SURFACE
  //y = wherey ();
  //gotoxy (60, 1);
  d = 1;
  j = 1;
  for (i = ch_N; i > 0; i--)
   {d *= sqrt (axes [i-1]);
    j = ! j;
    d *= (j) ? pi : 2. / i;
   }
  printf ("%f", d);
 // gotoxy (31, y);
#endif
#endif
#endif
  while (!IOstatus)
   {
#ifdef CH_LP_PC
    if (IOstatus = objfun (c, objnums, Nfunc))
  break;
    y = wherey();
    //gotoxy (60,1);
    if (lp_primal (Ncon, Nvar, Nfunc) != 1)
     {IOstatus = -7;
     // gotoxy (1, y);
  break;
     }
    //gotoxy (31, y);
    inibas = 0;
    for (i = 0; i < ch_N; i++) x [i] = pvar [objnums [i]];
#endif
#ifdef CH_LPM
    lpm_objfun (c, objnums, ch_N);
    if (lpm_PRNT > 1) printf ("\n");
    IOlpm = lpm_primal (Ncon, Nvar, Nmatr);
    if (IOlpm >= 0)
#ifdef CH_TXT
      IOlpm = lpm_getsol (x, ch_N, Ncon);
#else
/* poluchenie resheniya */
     {for (i = 0; i < ch_N; i++) x [i] = 0.;
      for (i = 0; i < Ncon; i++)
       {j = lpm_ibase [i];
	if (j <= 0)
	 {IOlpm = -1;
      break;
	 }
	for (k = 0; k < ch_N; k++)
	  if (j == objnums [k])
	   {x [k] = lpm_x [i];
	break;
	   }
       }
     }
#endif
    if (IOlpm < 0)
     {printf ("%s\n", lpm_inform (IOlpm));
      IOstatus = -7;
  break;
     }
#endif
#ifdef CH_POINTS
    max = -ch_INF;
    for (j = 0; j < numnum;)
     {sum = 0;
      for (i = 0; i < ch_N; i++) sum += c [i] * coef [j++];
      if (sum > max) {max = sum; jmax = j - ch_N;}
     }
    for (i = 0; i < ch_N; i++) x [i] = coef [jmax++];
#endif
#ifdef CH_ELIPSE
    d = 0;
    for (i = 0; i < ch_N; i++) d += axes [i] * c [i] * c [i];
    d = 1. / sqrt (d);
    for (i = 0; i < ch_N; i++) x [i] = d * axes [i] * c [i];
#endif
#ifdef CH_TIME
    time (&t);
    s = difftime (t, t0);
    m = s / 60;
    h = m / 60;
    s = s - m * 60;
    m = m - h * 60;
    y1 = wherey ();
   // gotoxy (60, y1);
    printf ("%2d h %2d m %2.0f s", h, m, s);
#endif
    IOstatus = ch_primal (c, x, IOstatus);
#ifdef CH_SOUND
    if (ch_max_all_est < 0.0001) sound (10000);
    else sound ((int) 100 / sqrt ((double)ch_max_all_est));
    delay (100);
    nosound ();
#endif
    if (kbhit () && getch () == 27)
  break;
   }
#ifdef CH_SOUND
  sound (800);
  nosound ();
#endif
  //textcolor (2);
  printf ("\n\r");
  //clreol ();
  printf ("%s\n\r", ch_inform (IOstatus ? IOstatus : -7));
  //clreol ();
  if (IOstatus < 0 && IOstatus >= -4 ||
      IOstatus == -7 ) IOstatus=2;
  if (ch_equ_facet == NULL) stage = 2;
  // add_top = 32 - ch_topCOUNT % 32;
 // textcolor (12);
  while (kbhit ()) getch ();
  printf ("Nazhmite lyubuyu klavishu . . .\n");
  getch ();
 }    /* conv_go */

void calcEllipsoidApprox(int size,int* indProjVec,int* improveDirectVec,double* centervec, double* semiaxes,float*** Amat,float** bVec,float*** vertMat,float** discrVec){ 
 //main function for which mex-file will be written 
    
    read_par ();
    in_read (size,indProjVec, improveDirectVec);
    conv_go(semiaxes);
    out_write(Amat,bVec,vertMat,discrVec);
   }



int main(void){
	//for compilation while there is no mex-files
	
	int i;
    double* centervec;
	double* semiaxes;
	int size = 2;
	//output params
	int j;
	int*p=NULL;
	int*q=NULL;
    float** Amat=(float**)malloc(size*sizeof(float*));
    float ** vertMat=(float**)malloc(size*sizeof(float*));
	float* bVec=(float*)malloc(256*sizeof(float));
	float* discrVec=(float*)malloc(256*sizeof(float));
    

	//here input data will be defined
	centervec=(double*) malloc(2*sizeof(double));
	semiaxes=(double*) malloc(2*sizeof(double));
	
	centervec[0] = 0;
	centervec[1] = 0;
	semiaxes[0] = 1;
	semiaxes[1] = 1;
	
    calcEllipsoidApprox(size,p,q,centervec,semiaxes, &Amat, &bVec,&vertMat, &discrVec);
  return 0;
}