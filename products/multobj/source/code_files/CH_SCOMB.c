#include <malloc.h>
#include "ch_main.h"

extern ch_facet *ch_first_facet, *ch_emp_facet;
extern ch_position ch_index_position;
extern unsigned ch_SIZEind;
static unsigned long *bound;
static char copyright [] =
"(c) Chernykh O.L. Computing Center of Russian \
Academy of Sciences, 1994";

int ch_next_position (void)
/* следующая позиция индекса */
 {int IOstatus;
  ch_facet *pfacet;
  ch_simplex **psimp;
  ch_simplex *new_ind;

  if ( ! (ch_index_position.bit >>= 1))
   {ch_index_position.bit = ~((~((unsigned long)0L)) >> 1);
    ++ch_index_position.number;
    ch_SIZEind += sizeof (ch_simplex);
    ch_free_facet (& ch_emp_facet);
    bound = (unsigned long*) realloc (bound, ch_SIZEind);
    if (bound == NULL)
return (-5);
    VIEW (pfacet, ch_first_facet)
      for (psimp = &pfacet->simp; *psimp != NULL;
				  psimp = &((*psimp)->next))
       {new_ind = (ch_simplex*) realloc (*psimp, ch_SIZEind);
	if (new_ind == NULL)
return (-5);
	*psimp = new_ind;
	(*psimp) [ ch_index_position.number].ind = 0L;
       }
ERR_RET (ch_add_facet (&ch_emp_facet));
   }
return (0);
 }    /* ch_next_position */

#include <math.h>

extern int ch_PRNT;
extern ch_top *ch_conn_top;
extern float ch_EPS, ch_EPScheck, ch_INF;

int ch_check (ch_facet *pfacet)
/* проверка грани pfacet на прохождение через вершины */
 {int num;
  unsigned long pos, sumind;
  ch_simplex *psimp;
  ch_top *ptop;
  float s, smin, smax;
  float half = 0.5;
#ifdef ROUGH
  float unit = 1.0;
#endif

  if (ch_PRNT > 2) ch_prn_facet (pfacet);
  smin =  ch_INF;
  smax = -ch_INF;
  num = ch_index_position.number;
  pos = ch_index_position.bit;
  sumind = 0L;
  VIEW_INDEX (psimp, pfacet)
    sumind |= psimp [num].ind;

  VIEW (ptop, ch_conn_top)
   {if ( ! pos)     /* смена ячейки индекса */
     {pos = (unsigned long) 01L;
      num--;
      sumind = 0L;
      VIEW_INDEX (psimp, pfacet)
	sumind |= psimp [num].ind;
     }
    s = ch_calc_dif (pfacet->c, ptop->c);
    if (s > smax) smax = s;
    if ((sumind & pos) && s < smin) smin = s;
    pos<<=1;
   }
  s = smax - smin;    /* ширина коридора */
  if (rough(s) != 0)
   {rough(s) = rough(s) rough_mult rough(half);
    smin += s;
    if (rough(s) > rough(ch_EPS))
     {ch_EPS = s;
      if (rough(s) > rough(ch_EPScheck))
return (-3);
     }
   }
  pfacet->c [1] -= smin;   /* поправка правой части */
return (0);  /* код ошибки */
 }    /* ch_check */

extern float ch_EPSdif;

static ch_list pf[3];
#define VIEW_LIST(p,n) \
 for (p = pf [n].begin; p != *pf [n].end; p = p->next)

#ifdef CH_VOLUMES
#include <conio.h>
#include "ch\ch_volum.c"

extern ch_top *ch_first_top;
extern int ch_N1, ch_topCOUNT, ch_RHYPER;
static double sumvol;
#endif

#ifdef CH_VOLFILE
#include <stdio.h>
extern float ch_max_all_est;
static FILE *vol_stream;
#endif

void ch_sort (void)
/* сортировка граней на три списка по знаку невязки */
 {int i;
  float *pctop; /* коэффициенты присоединяемой вершины */
  double dif;     /* невязка на присоединяемой вершине */
  ch_facet *pfacet;
  float b3;

#ifdef CH_VOLUMES
  if (ch_topCOUNT == ch_N1 && ! ch_RHYPER)
   {i = wherey ();
#ifdef CH_SURFACE
    sumvol = 0.;
    VIEW (pfacet, ch_first_facet)
     {gotoxy (60, i - 1);
      sumvol += volume (NULL, (unsigned long*) pfacet->simp);
      cprintf ("%f", sumvol);
     }
#else
    gotoxy (60, i - 1);
    sumvol = volume (ch_first_top,
		     (unsigned long*) ch_first_facet->simp);
    cprintf ("%f", sumvol);
#endif
    gotoxy (60, i);
#ifdef CH_VOLFILE
    vol_stream = fopen ("outvol.prn", "w");
#endif
   }
#ifdef CH_VOLFILE
    if (vol_stream != NULL)
      fprintf (vol_stream, "%f %d %f\n",
	       ch_max_all_est, ch_topCOUNT, sumvol);
#endif
#endif

  pctop = ch_conn_top->c;
  for (i = 0; i < 3; i++)	   /* инициализация трех */
    pf [i].end = &(pf [i].begin);  /*   пустых списков   */
  VIEW (pfacet, ch_first_facet)
   {b3 = dif = ch_calc_dif (pfacet->c, pctop);
    i = (rough(b3) < 0);
    b3 = pfacet->dif = fabs(dif);
    i += (i == (rough(b3) > rough(ch_EPSdif)));
      /*  i = 0  при     dif  >  EPSdif   */
      /*  i = 1  при abs(dif) <= EPSdif   */
      /*  i = 2  при     dif  < -EPSdif   */
    *(pf [i].end) = pfacet;       /*  включение грани в   */
    pf [i].end = &(pfacet->next); /* конец нужного списка */
   }
  *(pf [2].end) = NULL;		/* формирование */
  *(pf [1].end) = pf [2].begin;	/*   общего     */
  *(pf [0].end) = pf [1].begin;	/*   списка     */
  ch_first_facet = pf [0].begin;
 }    /* ch_sort */

extern int ch_RCHECK, ch_RFREE;
extern int ch_facetTOTAL, ch_facetCOUNT;

int ch_cycle_comb (void)
/* основной цикл присоединения вершины */
 {ch_facet *pfacet, *pplus, *pminus, *pnew;
  ch_list new_facet;  /*список новых граней*/
  ch_simplex *psimpplus, *psimpminus, *psimpnew, *first_simp;
  ch_simplex **ppsimp;
  int IOstatus, numlist;
#ifdef CH_VOLUMES
#ifndef CH_SURFACE
  int iszero;
  float sum, minsum = 0.1;
#endif
#endif
  register int i, k;
  register unsigned long a;

  pnew = ch_emp_facet;
  new_facet.end = &(new_facet.begin);	/* пустой */
  new_facet.begin = pnew;		/* список */
  for (i = 0; i <= ch_index_position.number; i++)
    bound [i] = ~0L; 
  VIEW_LIST (pplus, 0)
    VIEW_INDEX (psimpplus, pplus)
      for (i = 1; i <= ch_index_position.number; i++)
	bound [i] &= ~psimpplus [i].ind;
/* комбинирование */
  for (numlist = 2; numlist > 0; numlist--)
    VIEW_LIST (pminus, numlist)
     {if (numlist == 1)
       {
ERR_RET (ch_copy_facet (pnew, pminus));
       }
/* проверка на соседство с границей */
      VIEW_INDEX (psimpminus, pminus)
       {k = 2;
	for (i = 1; i <= ch_index_position.number; i++)
	 {a = psimpminus [i].ind & bound [i];
	  while (a)
	   {if (! --k)
	  break; /* этот симплекс несоседний с границей */
	    a &= (a - 1);
	   }
	  if ( ! k)
	break;
	 }
	if (k)
      break;
       }
      if ( ! k)  /* нет соседства с границей */
       {if (numlist == 1)
	 {ch_facetCOUNT++;
	  if (ch_PRNT > 1) ch_inf_print (021);
/* настройка на следующую пустую грань */
	  new_facet.end = &(pnew->next);
	  if (NULL == (pnew = pnew->next))
	   {  /* нет пустой грани */
ERR_RET (ch_add_facet (&pnew));
	    *new_facet.end = pnew;
	   }
	 }
    continue;
       }
/* еcть соседство с границей */
      if (numlist == 1)
/* добавление пустого симплекса */
       {psimpnew = pnew->simp;
	while (psimpnew->next != NULL)
	  psimpnew = psimpnew->next;
	if (NULL == (psimpnew->next =
		    (ch_simplex*) malloc (ch_SIZEind)))
return(-5);
	ppsimp = &psimpnew->next;
	psimpnew = *ppsimp;
	psimpnew->next = NULL;
#ifdef CH_VOLUMES
#ifndef CH_SURFACE
/* проверка на нулевую грань  */
	if (ch_RHYPER)
	 {sum = 0.;
	  for (i = 0; i <= ch_N1; i++)
	    sum += fabs ((double) pnew->c [i]);
	  iszero = (rough(sum) < rough(minsum));
	 }
#endif
#endif
       }
      VIEW_LIST (pplus, 0)
       {if (numlist == 2)
	  psimpnew = pnew->simp;
	VIEW_INDEX (psimpplus, pplus)
	  VIEW_INDEX (psimpminus, pminus)
	   {k = 2;
	    for (i = 1; i <= ch_index_position.number; i++)
	     {a = psimpminus [i].ind & ~psimpplus [i].ind;
	      while (a)
	       {if (! --k)
	      break;
		a &= (a - 1);
	       }
	      if (! k)
	    break;
	      psimpnew [i].ind = psimpplus [i].ind
			       & psimpminus [i].ind;
	     }
	    if ( ! k)
	  continue;   /* симлексы не соседние */
	    psimpnew [ch_index_position.number].ind |=
			ch_index_position.bit;
#ifdef CH_VOLUMES
#ifdef CH_SURFACE
/* присоединяемая площадь */
	    if ( ! ch_RHYPER)
#else
/* присоединяемый объем при RHYPER */
	    if (ch_RHYPER && iszero && numlist == 1)
#endif
	     {i = wherey ();
	      gotoxy (60, i);
	      sumvol += volume (NULL,
	      		(unsigned long*) psimpnew);
	      cprintf ("%f", sumvol);
	     }
#endif
/* настройка на следующий пустой симплекс */
	    ppsimp = &psimpnew->next;
	    psimpnew = *ppsimp;
	    if (psimpnew == NULL)
	     {psimpnew = (ch_simplex*) malloc (ch_SIZEind);
	      if (psimpnew == NULL)
return(-5);
	      *ppsimp = psimpnew;
	      psimpnew->next = NULL;
	     }
	   }
	if ((numlist == 1 && pplus->next != *pf [0].end)
		|| (numlist == 2 && psimpnew == pnew->simp))
      continue;

/* освобождение симплексов */
	while (psimpnew != NULL)
	 {first_simp = psimpnew->next;
	  free (psimpnew);
	  psimpnew = first_simp;
	 }
	*ppsimp = NULL;
	if (numlist == 2)
	 {ch_combination (pplus, pminus, pnew);
	  if (ch_RCHECK)
ERR_RET (ch_check (pnew));
#ifdef CH_VOLUMES
#ifndef CH_SURFACE
/* начальный объем при RHYPER */
	  if (ch_RHYPER)
/* проверка на нулевую грань  */
	   {sum = 0.;
	    for (i = 0; i <= ch_N1; i++)
	      sum += fabs ((double) pnew->c [i]);
	      iszero = (rough(sum) < rough(minsum));
/* инициализация объема	*/
	      if (iszero)
	       {i = wherey ();
		sumvol = 0.;
		VIEW_INDEX (psimpplus, pnew)
		 {gotoxy (60, i);
		  sumvol += volume (NULL,
		  		(unsigned long*) psimpplus);
		  cprintf ("%f", sumvol);
		 }
#ifdef CH_VOLFILE
		vol_stream = fopen ("outvol.prn", "w");
#endif
	       }
	   }
#endif
#endif
	  ch_facetTOTAL++;
	 }
	ch_facetCOUNT++;
	if (ch_PRNT > 1) ch_inf_print (021);
/* настройка на следующую пустую грань */
	new_facet.end = &(pnew->next);
	if (NULL == (pnew = pnew->next))
	 {  /* нет пустой грани */
ERR_RET (ch_add_facet (&pnew));
	  *new_facet.end = pnew;
	 }
       }
     }
  *(new_facet.end) = pf [2].begin;   /*  формирование */
  ch_first_facet = new_facet.begin;  /* нового списка */
/*!!!активна следующая итерация!!!*/
  *(pf [1].end) = pnew;		/* формирование  */
  *(pf [0].end) = pf[1].begin;	/*    списка     */
  ch_emp_facet  = pf[0].begin;	/* пустых граней */
/* освобождение оценочных вершин в удаляемых гранях */
#ifdef CH_VOLUMES
  i=wherey();
#endif
  for (numlist = 0; numlist <= 1; numlist++)
    VIEW_LIST (pfacet, numlist)
     {ch_facetCOUNT--;
      ch_del_top (pfacet);
      if (ch_PRNT > 1) ch_inf_print (024);
#ifdef CH_VOLUMES
      if (numlist ==1 || ch_RHYPER) continue;
      VIEW_INDEX (psimpplus, pfacet)
       {gotoxy (60, i);
#ifdef CH_SURFACE		/* удаляемая площадь */
	sumvol -= volume (NULL, (unsigned long*) psimpplus);
#else				/* присоединяемый объем */
	sumvol += volume (ch_conn_top,
		(unsigned long*) psimpplus);
#endif
	cprintf ("%f", sumvol);
       }
#endif
     }
  if (ch_RFREE) ch_free_facet (&ch_emp_facet->next);
return (0);  /* код ошибки */
 }    /* ch_cycle_comb */