#include <malloc.h>
#include "ch_main.h"

extern ch_facet *ch_first_facet;
extern ch_facet *ch_next_est_facet, *ch_max_est_facet;
extern float ch_EPSest;
extern int ch_N;

void ch_est_next (last_dir)
  /* calculating of the point to next adding top*/
float *last_dir;
 {float max_top_est, s;
  ch_facet *pfacet;
#ifndef CH_FREEEST
  int i;
  float maxs, *pdir;

  maxs = 0.0;
#endif
  ch_next_est_facet = NULL;
  max_top_est = (ch_max_est_facet != NULL) ?
	       *(ch_max_est_facet->c) : ch_EPSest;
  VIEW (pfacet, ch_first_facet)
    if(pfacet->top == NULL)
     {s = *pfacet->c;
      if (rough(s) > rough(max_top_est))
       {
#ifndef CH_FREEEST
	pdir = pfacet->c + 2;
	s = 2.0;
	for (i = 0; i < ch_N; i++)
	  s += pdir [i] * last_dir [i];
	if (rough(s) > rough(maxs))
	 {maxs = s;
	  ch_next_est_facet = pfacet;
	 }
#else
	ch_next_est_facet = pfacet;
  break;
#endif
       }
     }
 }    /* ch_est_next */

extern float ch_max_all_est;
extern int ch_PRNT;

void ch_est_max (void)
  /* calculating the face with the best precision */
 {ch_facet *pfacet;
  float max_top_est, est;

  max_top_est = 0.;
  ch_max_all_est = 0.;
  ch_max_est_facet = NULL;
  VIEW (pfacet, ch_first_facet)
   {est = *(pfacet->c);
    if (rough(est) > rough(ch_max_all_est))
      ch_max_all_est = est;
    if (pfacet->top != NULL)
      if (rough(est) > rough(max_top_est))
       {max_top_est = est;
	ch_max_est_facet = pfacet;
       }
   }
  if (ch_PRNT > 1) ch_inf_print(040);
 }    /* ch_est_max */

extern float ch_EPSin;
extern ch_facet *ch_emp_facet;
extern unsigned ch_SIZEctop;
extern int ch_estCOUNT, ch_estTOTAL;

int ch_est_write (pctop)
  /* ‡€ˆ‘œ Ž–…Šˆ ˆ ‚…˜ˆ›. í… „‹Ÿ …‚Ž‰ ‚…˜ˆ›! */
float *pctop;
 {int i;
  float *new_top, old_max;
  float b2, b3;
  ch_facet *pfacet;

  ch_estTOTAL++;
  b3 = *(ch_next_est_facet->c) =
	 ch_calc_dif (ch_next_est_facet->c, pctop);
  b2 = -b3;
  if (rough(b2) > rough(ch_EPSin))
return (-4);
  if (rough(b3) > rough(ch_EPSest))
   {while (NULL == (new_top = (float*) malloc (ch_SIZEctop)))
     {if (ch_emp_facet->next == NULL)
return (-5);
      else ch_free_facet (&ch_emp_facet->next);
     }
    for (i = 0; i < ch_N; i++) new_top [i] = pctop [i];
    ch_next_est_facet->top = new_top;
    ch_estCOUNT++;
    if (ch_max_est_facet != NULL) b2 = *(ch_max_est_facet->c);
    if ((ch_max_est_facet == NULL) || rough(b3) > rough(b2))
      ch_max_est_facet = ch_next_est_facet;
   }
  if (ch_PRNT > 0)
   {old_max = ch_max_all_est;
    ch_max_all_est=0.;
    VIEW (pfacet, ch_first_facet)
     {b3 = *(pfacet->c);
      if (rough(b3) > rough(ch_max_all_est))
	ch_max_all_est = *(pfacet->c);
     }
   }
  if (ch_PRNT > 1)
    ch_inf_print (06 | ((rough(ch_max_all_est) <
			 rough(old_max)) ? 040 : 0));
return (0);    /* error code */
 }    /* ch_est_write */

void ch_dir_write (c)
 /* recording of the objective function*/
float *c;
 {float *pcfacet;
  int i;

  pcfacet = (ch_next_est_facet->c) + 2;
  for (i = 0; i < ch_N; i++) c [i] = pcfacet [i];
 }    /* ch_dir_write */