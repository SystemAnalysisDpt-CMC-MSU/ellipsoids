#include <math.h>
#include "ch_main.h"

extern int ch_N;
extern float ch_EPSrel;

#ifdef ROUGH
static float unit = 1.0;
#endif

double ch_calc_dif (pcfacet, pctop)
  /*вычисление невязки грани (pcfacet-ссылка на поле "c") */
  /*       в вершине(pсtop-ссылка на поле "c") */
float *pcfacet, *pctop;
 {register int i;
  register double s, u;
  float max, sa;

  s = *++pcfacet;
  max = fabs(s);
  ++pcfacet;
  for (i = 0; i < ch_N; i++)
   {s += u = pcfacet [i] * (double)pctop [i];
    sa = fabs (u);
    if (rough(sa) > rough(max)) max = sa;
   }
  sa = fabs (s);
  if (rough(max) != 0)
    rough(max) = rough(max) rough_mult rough(ch_EPSrel);
  if (rough(sa) <= rough(max))
    s = 0.;
return (s);      /* невязка */
 }    /* ch_calc_dif */

#include <stdio.h>

extern int ch_N1;
extern ch_position ch_index_position;

void ch_prn_facet (pfacet)
  /* печать грани *pfacet */
ch_facet *pfacet;
 {register int  i;
#ifdef CH_SIMPLEX
  ch_simplex *psimp;
#endif

  printf ("\n");
#ifdef CH_SIMPLEX
  VIEW_INDEX (psimp, pfacet)
   {for (i = 1; i <= ch_index_position.number; i++)
      printf ("%9lX", psimp [i].ind);
    printf ("\n");
   }
#else
  for (i = 0; i <= ch_index_position.number; i++)
    printf ("%9lX", pfacet->ind [i]);
#endif
  for (i = 0; i <= ch_N1; i++)
    printf ("%12.4G", pfacet->c [i]);
  printf ("\n");
 }    /* ch_prn_facet */

extern int ch_Ncomb;
extern double *ch_coef;

void ch_combination (pplus, pminus, pnew)
  /* комбинирование граней *pplus и *pminus  */
  /* и запись результата в     *pnew         */
ch_facet *pplus, *pminus, *pnew;
 {register int  i;
  register double norm, w, s;
  float *pc1, *pc2, *pcnew, wa, pa;

  pa = s = pplus->dif;
  pcnew = pnew->c;
  if ((*pminus->c) == -1.)
   {pc1 = pplus->c;
    for (i=0; i <= ch_N1; i++) pcnew [i] = pc1 [i];
    pcnew [0] -= s;
    pcnew [1] -= s;
    ch_move_top (pnew, pplus);
   }
  else
   {wa = w = pminus->dif;
    if (rough(pa) < rough(wa))
     {s = s / w;
      pc1 = pminus->c;
      pc2 = pplus->c;
     }
    else
     {s = w / s;
      pc1 = pplus->c;
      pc2 = pminus->c;
     }
    norm = 0.;
    for (i = 0; i <= ch_N1; i++)
     {w = s * pc1 [i] + pc2 [i];
      wa = fabs (w);
      if (i == 0 || i == 1)
       {pa = fabs (pc2 [i]);
	if (rough(pa) != 0)
	  rough(pa) = rough(pa) rough_mult rough(ch_EPSrel);
	if (rough(wa) <= rough(pa)) w = 0.;
       }
      else
       {if (rough(wa) <= rough(ch_EPSrel)) w = 0.;
	else norm += w * w;
       }
      ch_coef [i] = w;
     }
    if ((ch_Ncomb == ch_N1) && (norm < 0.5))
      norm = 0.;
    else
     {norm = 1. / sqrt (norm);
     }
    for (i = 0; i <= ch_N1; i++) pcnew [i] = ch_coef [i] * norm;
   }
 }    /* ch_combination */
 