#include <malloc.h>
#include "ch_main.h"

extern unsigned ch_SIZEcfacet, ch_SIZEind;

int ch_add_facet (head)
  /* добавление новой грани в начало списка */
ch_facet **head;
 {ch_facet *pfacet;

  pfacet = (ch_facet*) malloc (sizeof (ch_facet));
  if (pfacet == NULL)
return (-5);
#ifdef CH_SIMPLEX
  pfacet->simp = (ch_simplex*) malloc(ch_SIZEind);
  if (pfacet->simp == NULL)
return (-5);
  pfacet->simp->next = NULL;
#else
   pfacet->ind = (unsigned long*) malloc (ch_SIZEind);
   if (pfacet->ind == NULL && ch_SIZEind)
return (-5);
#endif
  if (NULL == (pfacet->c = (float*) malloc (ch_SIZEcfacet)))
return (-5);
  pfacet->top  = NULL;
  pfacet->next = *head;
  *head = pfacet;
return (0);
 }    /* ch_add_facet */

extern float *ch_equ;

void ch_free_facet (head)
  /*  освобождение цепи граней  */
ch_facet **head;
 {ch_facet *pfacet, *first_facet;
#ifdef CH_SIMPLEX
  ch_simplex *first_simp, *psimp;
#endif

  pfacet = *head;
  while (pfacet != NULL)
   {first_facet = pfacet->next;
    free (pfacet->c);
#ifdef CH_SIMPLEX
    psimp = pfacet->simp;
    while (psimp != NULL)
     {first_simp = psimp->next;
      free (psimp);
      psimp = first_simp;
     }
#else
    free (pfacet->ind);
#endif
    if ((pfacet->top != NULL) && (pfacet->top != ch_equ))
      free (pfacet->top);
    free (pfacet);
    pfacet = first_facet;
   }
   *head = NULL;
 }    /* ch_free_facet */

#ifdef CH_SIMPLEX

extern unsigned ch_SIZEctop;
extern int ch_N,ch_N1;
extern ch_position ch_index_position;

int ch_copy_facet (pdest, psource)
  /* копирование грани */
ch_facet *pdest, *psource;
 {int i;
  ch_simplex *psimpdest, *psimpsource, *first_simp, *psimp;

/* копирование индексов */
  psimpdest = pdest->simp;
  VIEW_INDEX (psimpsource, psource)
   {for (i = 1; i <= ch_index_position.number; i++)
      psimpdest [i].ind = psimpsource [i].ind;
    if (psimpdest->next != NULL && psimpsource->next == NULL)
     {psimp = psimpdest->next;
      psimpdest->next = NULL;
      while (psimp != NULL)
       {first_simp = psimp->next;
	free (psimp);
	psimp = first_simp;
       }
  break;
     }
    else
      if(psimpdest->next == NULL && psimpsource->next != NULL)
       {psimpdest->next = (ch_simplex*) malloc (ch_SIZEind);
	psimpdest = psimpdest->next;
	if (psimpdest == NULL)
return (-5);
	psimpdest->next = NULL;
  continue;
       }
    psimpdest = psimpdest->next;
   }
/* копирование коэффициентов */
  for (i = 0; i <= ch_N1; i++)
    pdest->c [i] = psource->c [i];

/* перенос оценочной вершины (при прерывании - пропадет) */
  pdest->top = psource->top;
  if (psource->top != ch_equ) psource->top = NULL;

return(0);
 }  /* ch_copy_facet */
#endif

void ch_free_top (head)
  /*  освобождение цепи вершин  */
ch_top **head;
 {ch_top *ptop, *first_top;

  ptop = *head;
  while (ptop != NULL)
   {first_top = ptop->next;
    free (ptop->c);
    free (ptop);
    ptop = first_top;
   }
   *head = NULL;
 }    /* ch_free_top */

extern int ch_estCOUNT;
extern ch_top *ch_conn_top;

void ch_del_top (pfacet)
  /* освобождение оценочной вершины */
ch_facet *pfacet;

 {if ((pfacet->top != NULL) && (pfacet->top != ch_equ))
   {if (pfacet->top != ch_conn_top->c) free (pfacet->top);
    pfacet->top = NULL;
    ch_estCOUNT--;
   }
 }    /* ch_del_top */

extern float ch_EPSest;

void ch_move_top (pdest, psrc)
  /* перенос оценочной вершины */
ch_facet *pdest, *psrc;
 {if(pdest != psrc && *pdest->c >= ch_EPSest)
   {pdest->top = psrc->top;  /* при прерывании оценочная */
    psrc->top = NULL;         /*     вершина пропадет     */
   }
 }    /* ch_move_top */

extern ch_facet *ch_first_facet, *ch_emp_facet;
extern ch_facet *ch_second_facet, *ch_equ_facet;
extern ch_top *ch_first_top;

void ch_free_mem (void)
  /* освобождение памяти, выделенной под множество */
 {if (ch_first_facet != NULL && ch_first_facet->next == ch_emp_facet)
   {ch_first_facet->next = ch_second_facet;
    ch_equ_facet = NULL;
    ch_second_facet = NULL;
   }
  ch_free_facet (&ch_first_facet);
  ch_free_facet (&ch_emp_facet);
  ch_free_top (&ch_first_top);
 }