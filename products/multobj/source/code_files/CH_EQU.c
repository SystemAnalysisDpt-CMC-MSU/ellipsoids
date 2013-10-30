#include <malloc.h>
#include "ch_main.h"

extern ch_facet *ch_equ_facet, *ch_emp_facet;
extern ch_facet *ch_first_facet, *ch_second_facet;
extern float *ch_equ;

void ch_equ_search (void)
  /* поиск равенства и удаление его из цепи */
 {ch_facet *pfacet, **pp;

  pp = &ch_first_facet;
  VIEW (pfacet, ch_first_facet)
   {if (pfacet->top == ch_equ)
  break;
    pp = &(pfacet->next);
   }
  ch_equ_facet = pfacet;
  if (ch_equ_facet != NULL)
   {*pp = ch_equ_facet->next;
    ch_equ_facet->next = ch_first_facet;
    ch_first_facet = ch_equ_facet;
    ch_second_facet = ch_first_facet->next;
   }
  else ch_second_facet = NULL;
 }    /* ch_equ_search */

extern float ch_INF;
extern int ch_N1;
extern ch_position ch_index_position;

void ch_equ_double (void)
  /* дублирование равенства с обратным знаком */
 {int i;
  float p;

  /* копирование индексов */
#ifdef CH_SIMPLEX
  for (i = 1; i <= ch_index_position.number; i++)
    ch_emp_facet->simp [i].ind = ch_equ_facet->simp [i].ind;
#else
  for (i = 0; i <= ch_index_position.number; i++)
    ch_emp_facet->ind  [i]     = ch_equ_facet->ind [i];
#endif
  for (i = 1; i <= ch_N1; i++)
   {p = ch_equ_facet->c [i];
    if (p != 0.) p = -p;
    ch_emp_facet->c [i] = p;
   }
  *(ch_emp_facet->c) = ch_INF;
  /* с этого момента непоср.прерывание делать осторожно */
  ch_equ_facet->next = ch_emp_facet;
  ch_emp_facet->top = NULL;
  ch_equ_facet->top = NULL;
 }    /* ch_equ_double */

extern int ch_PRNT, ch_RCHECK, ch_estCOUNT, ch_facetTOTAL;
extern float ch_EPSdif;
extern ch_top *ch_conn_top;

#include <math.h>

int ch_equ_comb (void)
  /* цикл присоединения вершины в начальном приближении */
 {ch_facet *pfacet;
  int IOstatus;
  double dif;
  float b2, b3;

  ch_equ_facet->next = ch_second_facet;
  ch_equ_facet->dif = ch_emp_facet->dif = *(ch_emp_facet->c);
  VIEW (pfacet, ch_second_facet)
   {
#ifdef CH_SIMPLEX
    pfacet->simp [ch_index_position.number].ind |=
#else
    pfacet->ind  [ch_index_position.number]     |=
#endif
	       	  ch_index_position.bit;
    b2 = dif = ch_calc_dif (pfacet->c, ch_conn_top->c);
    b3 = pfacet->dif = fabs (dif);
    if (rough(b3) > rough(ch_EPSdif))
     {ch_combination ((rough(b2) > 0) ?
		ch_equ_facet : ch_emp_facet, pfacet, pfacet);
      if (ch_RCHECK)
ERR_RET (ch_check (pfacet));
      ch_facetTOTAL++;
     }
    ch_del_top (pfacet);
   }
  ch_second_facet = NULL;
  ch_emp_facet->top = NULL;
  ch_estCOUNT--;
  if (ch_PRNT > 1) ch_inf_print (025);
return (0); /* код ошибки */
 }    /* ch_equ_comb */