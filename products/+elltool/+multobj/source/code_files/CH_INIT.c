#include <malloc.h>
#include <math.h>
#include "ch_main.h"

extern ch_facet *ch_first_facet, *ch_emp_facet;
extern float *ch_equ, ch_INF;
extern int ch_N, ch_N1, ch_Ncomb, *ch_state;
extern int ch_facetCOUNT, ch_facetTOTAL;
extern int ch_RHYPER;

int ch_init_facet (IOst)
  /* построение исходных граней */
int IOst;
 {ch_facet *pfacet;
  int i, j, k, IOstatus;
  double a, b, nonpar, norm;

  ch_Ncomb = ch_N + ch_RHYPER;
  for (i = 0; i <= ch_Ncomb; i++)
   {
ERR_RET (ch_add_facet (&ch_first_facet));
    for (j = 0; j <= ch_N1; j++) ch_first_facet->c [j] = 0.;
   }
ERR_RET (ch_add_facet (&ch_emp_facet));
  ch_facetCOUNT = ch_Ncomb + 1;
  ch_facetTOTAL = ch_facetCOUNT;
  pfacet = ch_first_facet;

  if (ch_RHYPER)
   {if (IOst != 4) nonpar = ch_N;
    else
     {nonpar = 0.;
      for (i = 0; i < ch_N; i++)
	if( ! ch_state [i]) nonpar++;
     }
    if(nonpar != 0.)
     {norm = -1. / sqrt (nonpar);
      ch_first_facet->c [0]= ch_INF;

      a = sqrt (nonpar+1.);
      b = norm / (a + 1.);    /* коэффициенты вершин правильного */
      a = - (a + nonpar) * b; /*    nonpar-мерного симплекса     */
     }
    pfacet = ch_first_facet->next;
   }

  for (i = 0; i < ch_N; i++)
   {pfacet->c [0] = ch_INF;
    if ((IOst == 4) && (k = ch_state [i]))
      pfacet->c [i + 2] = k;
    else
      if(ch_RHYPER)
       {ch_first_facet->c [i + 2] = norm;
	for (j = 0; j < ch_N; j++)
	  if ( ! ((IOst == 4) && ch_state [j]))
	    pfacet->c [j + 2] = (i == j) ? a : b;
       }
      else
       {pfacet->top = ch_equ;
	pfacet->c [i + 2] = 1.;
       }
    pfacet = pfacet->next;
   }
  pfacet->c [0] = -1.;
  pfacet->c [1] = -1.;
return (0);  /* код ошибки */
 }    /* ch_init_facet */

extern int ch_topCOUNT;
extern ch_position ch_index_position;

int ch_inf_comb (void)
  /* присоединение всех фиктивных вершин */
 {ch_facet *pfacet, *pf;
  int IOstatus;
  VIEW (pfacet, ch_first_facet)
    if(pfacet->top == NULL)
     {
ERR_RET (ch_next_position ());
      VIEW (pf, ch_first_facet)
	if (pf != pfacet)
#ifdef CH_SIMPLEX
	  pf->simp [ch_index_position.number].ind |=
#else
	  pf->ind  [ch_index_position.number] |=
#endif
		   ch_index_position.bit;
      ch_topCOUNT++;
     }
return (0);
 }    /* ch_inf_comb */
