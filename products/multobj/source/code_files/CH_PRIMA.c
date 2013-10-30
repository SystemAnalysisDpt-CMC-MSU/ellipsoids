#include <malloc.h>
#include "ch_main.h"
#include "ch_var.def"

int ch_primal (c, x, IOstatus)
  /* процедура построения выпуклой оболoчки */
  /* для аппроксимации выпуклого множества  */
float *c, *x;
int IOstatus;
 {ch_facet *pfacet;
  int i;
  float s;

  switch (IOstatus)
   {default:
return (IOstatus);
    case 1:
    case 4:
     {
ERR_RET (ch_init_facet (IOstatus));
ERR_RET (ch_inf_comb ());
      ch_equ_search();
      if (ch_equ_facet != NULL) ch_equ_double();
     }
    case 2:
     {if (ch_PRNT > 0) ch_inf_print (0);
      ch_est_max ();
  break;
     }
    case 0:
     {if (ch_first_top == NULL)
       {ch_estTOTAL++;
	if (ch_PRNT > 1) ch_inf_print (02);
	ch_first_top = (ch_top*) malloc (sizeof (ch_top));
	if (ch_first_top == NULL)
return (-5);
	ch_first_top->next = NULL;
	if (NULL == (ch_first_top->c = (float*) malloc (ch_SIZEctop)))
return (-5);
	for (i = 0; i < ch_N; i++) ch_first_top->c [i] = x [i];
	if (ch_equ_facet != NULL)
	  ch_emp_facet->next = ch_second_facet;
	VIEW (pfacet, ch_first_facet)
	  if (*(pfacet->c) != -1.)
	    pfacet->c [1] -= ch_calc_dif (pfacet->c, ch_first_top->c);
	ch_emp_facet->next = NULL;
	if (ch_PRNT > 1) ch_inf_print (021);
	*(ch_next_est_facet->c) = 0.;
	ch_max_est_facet = NULL;
       }
      else
ERR_RET (ch_est_write (x));
     }
   }
  /* основной цикл присоединения вершины */
  while (1)
   {ch_est_next(c);
    if (ch_next_est_facet != NULL)
     {ch_dir_write (c);
return (0);
     }
    if (ch_PRNT > 0) ch_inf_print (077);
    if (ch_max_est_facet != NULL)
      s = *(ch_max_est_facet->c);
    if (ch_max_est_facet == NULL ||
		rough(s) <= rough(ch_EPSset))
return ((ch_equ_facet!=NULL) ? -6 : -1);
    if (ch_max_topCOUNT && 
    		ch_topCOUNT >= ch_max_topCOUNT
	|| ch_max_facetCOUNT && 
			ch_facetCOUNT >= ch_max_facetCOUNT)
return (-2);
    ch_conn_top = (ch_top*) malloc (sizeof (ch_top));
    if (ch_conn_top == NULL)
return (-5);
    ch_conn_top->c    = ch_max_est_facet->top;
    ch_conn_top->next = ch_first_top;
    if ( ! ch_ex_next)
     {
ERR_RET (ch_next_position ());
      ch_ex_next = 1;
     }
    if (ch_equ_facet != NULL)
     {if (ch_max_est_facet == ch_equ_facet)
       {ch_equ_facet->next = NULL;
	ch_equ_facet   = ch_emp_facet;
	ch_emp_facet   = ch_max_est_facet;
	ch_first_facet = ch_equ_facet;
       }
      s = *(ch_emp_facet->c) + *(ch_equ_facet->c);
      if (rough(s) < rough(ch_width)) ch_width = s;
ERR_RET (ch_equ_comb ());
      ch_equ_search();
      if (ch_equ_facet != NULL) ch_equ_double ();
     }
    else
     {ch_sort ();
ERR_RET (ch_cycle_comb ());
     }
    ch_first_top = ch_conn_top;
    ch_topCOUNT++;
    if (ch_PRNT > 1) ch_inf_print (010);
    ch_ex_next = 0;
    ch_est_max();
   }
 }    /* ch_primal */