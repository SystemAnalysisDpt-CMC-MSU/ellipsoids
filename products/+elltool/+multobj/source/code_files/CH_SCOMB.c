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
/* ᫥����� ������ ������ */
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
/* �஢�ઠ �࠭� pfacet �� ��宦����� �१ ���設� */
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
   {if ( ! pos)     /* ᬥ�� �祩�� ������ */
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
  s = smax - smin;    /* �ਭ� ��ਤ�� */
  if (rough(s) != 0)
   {rough(s) = rough(s) rough_mult rough(half);
    smin += s;
    if (rough(s) > rough(ch_EPS))
     {ch_EPS = s;
      if (rough(s) > rough(ch_EPScheck))
return (-3);
     }
   }
  pfacet->c [1] -= smin;   /* ���ࠢ�� �ࠢ�� ��� */
return (0);  /* ��� �訡�� */
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
/* ���஢�� �࠭�� �� �� ᯨ᪠ �� ����� ���離� */
 {int i;
  float *pctop; /* �����樥��� ��ᮥ���塞�� ���設� */
  double dif;     /* ���離� �� ��ᮥ���塞�� ���設� */
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
  for (i = 0; i < 3; i++)	   /* ���樠������ ��� */
    pf [i].end = &(pf [i].begin);  /*   ������ ᯨ᪮�   */
  VIEW (pfacet, ch_first_facet)
   {b3 = dif = ch_calc_dif (pfacet->c, pctop);
    i = (rough(b3) < 0);
    b3 = pfacet->dif = fabs(dif);
    i += (i == (rough(b3) > rough(ch_EPSdif)));
      /*  i = 0  ��     dif  >  EPSdif   */
      /*  i = 1  �� abs(dif) <= EPSdif   */
      /*  i = 2  ��     dif  < -EPSdif   */
    *(pf [i].end) = pfacet;       /*  ����祭�� �࠭� �   */
    pf [i].end = &(pfacet->next); /* ����� �㦭��� ᯨ᪠ */
   }
  *(pf [2].end) = NULL;		/* �ନ஢���� */
  *(pf [1].end) = pf [2].begin;	/*   ��饣�     */
  *(pf [0].end) = pf [1].begin;	/*   ᯨ᪠     */
  ch_first_facet = pf [0].begin;
 }    /* ch_sort */

extern int ch_RCHECK, ch_RFREE;
extern int ch_facetTOTAL, ch_facetCOUNT;

int ch_cycle_comb (void)
/* �᭮���� 横� ��ᮥ������� ���設� */
 {ch_facet *pfacet, *pplus, *pminus, *pnew;
  ch_list new_facet;  /*ᯨ᮪ ����� �࠭��*/
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
  new_facet.end = &(new_facet.begin);	/* ���⮩ */
  new_facet.begin = pnew;		/* ᯨ᮪ */
  for (i = 0; i <= ch_index_position.number; i++)
    bound [i] = ~0L; 
  VIEW_LIST (pplus, 0)
    VIEW_INDEX (psimpplus, pplus)
      for (i = 1; i <= ch_index_position.number; i++)
	bound [i] &= ~psimpplus [i].ind;
/* �������஢���� */
  for (numlist = 2; numlist > 0; numlist--)
    VIEW_LIST (pminus, numlist)
     {if (numlist == 1)
       {
ERR_RET (ch_copy_facet (pnew, pminus));
       }
/* �஢�ઠ �� �ᥤ�⢮ � �࠭�楩 */
      VIEW_INDEX (psimpminus, pminus)
       {k = 2;
	for (i = 1; i <= ch_index_position.number; i++)
	 {a = psimpminus [i].ind & bound [i];
	  while (a)
	   {if (! --k)
	  break; /* ��� ᨬ����� ���ᥤ��� � �࠭�楩 */
	    a &= (a - 1);
	   }
	  if ( ! k)
	break;
	 }
	if (k)
      break;
       }
      if ( ! k)  /* ��� �ᥤ�⢠ � �࠭�楩 */
       {if (numlist == 1)
	 {ch_facetCOUNT++;
	  if (ch_PRNT > 1) ch_inf_print (021);
/* ����ன�� �� ᫥������ ������ �࠭� */
	  new_facet.end = &(pnew->next);
	  if (NULL == (pnew = pnew->next))
	   {  /* ��� ���⮩ �࠭� */
ERR_RET (ch_add_facet (&pnew));
	    *new_facet.end = pnew;
	   }
	 }
    continue;
       }
/* �c�� �ᥤ�⢮ � �࠭�楩 */
      if (numlist == 1)
/* ���������� ���⮣� ᨬ����� */
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
/* �஢�ઠ �� �㫥��� �࠭�  */
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
	  continue;   /* ᨬ����� �� �ᥤ��� */
	    psimpnew [ch_index_position.number].ind |=
			ch_index_position.bit;
#ifdef CH_VOLUMES
#ifdef CH_SURFACE
/* ��ᮥ���塞�� ���頤� */
	    if ( ! ch_RHYPER)
#else
/* ��ᮥ���塞� ��ꥬ �� RHYPER */
	    if (ch_RHYPER && iszero && numlist == 1)
#endif
	     {i = wherey ();
	      gotoxy (60, i);
	      sumvol += volume (NULL,
	      		(unsigned long*) psimpnew);
	      cprintf ("%f", sumvol);
	     }
#endif
/* ����ன�� �� ᫥���騩 ���⮩ ᨬ����� */
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

/* �᢮�������� ᨬ����ᮢ */
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
/* ��砫�� ��ꥬ �� RHYPER */
	  if (ch_RHYPER)
/* �஢�ઠ �� �㫥��� �࠭�  */
	   {sum = 0.;
	    for (i = 0; i <= ch_N1; i++)
	      sum += fabs ((double) pnew->c [i]);
	      iszero = (rough(sum) < rough(minsum));
/* ���樠������ ��ꥬ�	*/
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
/* ����ன�� �� ᫥������ ������ �࠭� */
	new_facet.end = &(pnew->next);
	if (NULL == (pnew = pnew->next))
	 {  /* ��� ���⮩ �࠭� */
ERR_RET (ch_add_facet (&pnew));
	  *new_facet.end = pnew;
	 }
       }
     }
  *(new_facet.end) = pf [2].begin;   /*  �ନ஢���� */
  ch_first_facet = new_facet.begin;  /* ������ ᯨ᪠ */
/*!!!��⨢�� ᫥����� �����!!!*/
  *(pf [1].end) = pnew;		/* �ନ஢����  */
  *(pf [0].end) = pf[1].begin;	/*    ᯨ᪠     */
  ch_emp_facet  = pf[0].begin;	/* ������ �࠭�� */
/* �᢮�������� �業���� ���設 � 㤠�塞�� �࠭�� */
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
#ifdef CH_SURFACE		/* 㤠�塞�� ���頤� */
	sumvol -= volume (NULL, (unsigned long*) psimpplus);
#else				/* ��ᮥ���塞� ��ꥬ */
	sumvol += volume (ch_conn_top,
		(unsigned long*) psimpplus);
#endif
	cprintf ("%f", sumvol);
       }
#endif
     }
  if (ch_RFREE) ch_free_facet (&ch_emp_facet->next);
return (0);  /* ��� �訡�� */
 }    /* ch_cycle_comb */