#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "ch_main.h"
#include "ch_var.def"
#define CH_ELIPSE

static char *msg [2][8] = {
 {"Не могу открыть файл",
  "Неверные данные",
  "Нет грани",
  "Мало места на диске",
  "Неверный формат файла",
  "Мало критериев",
  "отсутствует",
  "Неверный тип модели"
 },
 {"Could not open file",
  "Data are incorrect",
  "No facet number",
  "Disk full",
  "File format is not correct",
  "Too few criteria",
  "is absent",
  "Incorrect model type"
 }};
static char read_name [40] = "$$$";

void ch_reverse (void)
  /* reverse of top sequence */
 {ch_top *ptop,*pred_top;
  ptop = ch_first_top;
  ch_first_top = NULL;
  while (ptop != NULL)
   {pred_top = ptop;
    ptop = ptop->next;
    pred_top->next = ch_first_top;
    ch_first_top = pred_top;
   }
 }    /* ch_reverse */

void ch_no_file (char *name)
  /* not nedeed any moreа */
 {printf("%s %s",msg [ch_LNG] [0], name);
 }    /* ch_no_file */
#ifndef CH_LP_PC

int ch_read_dat (int size,int **objnums)
  /* reading the data describing the set */
 {int i, k, nvar, IOstatus;
  char *obj_names, c;

  ch_free_mem ();
  ch_N = size; 
  ch_N1=ch_N+1;
  ch_topCOUNT = 0;
  ch_estCOUNT = 0;
  IOstatus = 1;
  ch_state = (int*) realloc (ch_state, ch_N * sizeof (int));
  obj_names = (char*) malloc (ch_N * 10);
  if (obj_names == NULL)
return (-5);
  // direction of improving 
  for (i = 0; i < ch_N; i++) ch_state[i] = 0;
  *objnums = (int*) realloc (*objnums, ch_N * sizeof (int));//indicies of project variables
  for (i = 1; i<=ch_N;i++)
	  (*objnums)[i-1]=i;
  ch_EPS = ch_EPSdif;
  ch_width = ch_INF;

/* initializations depending on models */
  ch_estTOTAL   = 0;
  ch_facetTOTAL = 0;
  ch_ex_next    = 0;
  ch_index_position.bit = (unsigned long) 0L;
#ifdef CH_SIMPLEX
  ch_index_position.number =  0;
  ch_SIZEind = sizeof (ch_simplex);
#else
  ch_index_position.number = -1;
  ch_SIZEind = 0;
#endif
  ch_SIZEctop = ch_N * sizeof (float);
  ch_SIZEcfacet= (ch_N + 2) * sizeof (float);
  ch_coef = (double*) realloc (ch_coef,
		(ch_N + 2) * sizeof (double));
  if(ch_coef == NULL)
return(-5);

return (IOstatus);
 }  /* ch_read_dat */

#endif
#ifdef CH_LP_PC
int ch_read_dat (int size, int* indProjVec,int* improveDirectVec ,int **objnums)
  /* reading dataа */
 {int i, k, nvar, IOstatus;
  char *obj_names, c;

  ch_free_mem ();
  if((indProjVec == NULL)||(improveDirectVec == NULL))
  {   
	  printf("incorrect input data");
      return (-8);
  }
  ch_N = size; 
  ch_N1=ch_N+1;
  ch_topCOUNT = 0;
  ch_estCOUNT = 0;
  IOstatus = 1;
  ch_state = (int*) realloc (ch_state, ch_N * sizeof (int));
  obj_names = (char*) malloc (ch_N * 10);
  if (obj_names == NULL)
return (-5);
  // direction of improving 
  ch_state = improveDirectVec;
  *objnums= indProjVec;

  //if (*objnums == NULL)
//return (-5);


  ch_EPS = ch_EPSdif;
  ch_width = ch_INF;

  ch_estTOTAL   = 0;
  ch_facetTOTAL = 0;
  ch_ex_next    = 0;
  ch_index_position.bit = (unsigned long) 0L;
#ifdef CH_SIMPLEX
  ch_index_position.number =  0;
  ch_SIZEind = sizeof (ch_simplex);
#else
  ch_index_position.number = -1;
  ch_SIZEind = 0;
#endif
  ch_SIZEctop = ch_N * sizeof (float);
  ch_SIZEcfacet= (ch_N + 2) * sizeof (float);
  ch_coef = (double*) realloc (ch_coef,
		(ch_N + 2) * sizeof (double));
  if(ch_coef == NULL)
return(-5);

return (IOstatus);
 }  /* ch_read_dat */
#endif 











/*int ch_read_chs (instream)// need to know what this function does
  /*reading approximation  */
/*FILE *instream;
 {int IOstatus, i, k, current, topSIGN, estSIGN;
  float p;
  unsigned long sum, csum, p1;
  ch_facet *pfacet;
  ch_top *ptop, *pred_top;
  unsigned long a;
#ifdef CH_SIMPLEX
  int numsimp;
  ch_simplex *psimp;
  long l;
#endif

  fread ((char*)&ch_facetCOUNT,sizeof (int), 1, instream);
  fread ((char*)&estSIGN,      sizeof (int), 1, instream);
  fread ((char*)&ch_estCOUNT,  sizeof (int), 1, instream);
  fread ((char*)&topSIGN,      sizeof (int), 1, instream);
  fread ((char*)&ch_topCOUNT,  sizeof (int), 1, instream);
  if (ch_facetCOUNT)
   {if (ch_facetCOUNT <= 0 ||estSIGN != 1 || ch_estCOUNT < 1
	   || topSIGN != 1 || ch_topCOUNT < 1)
     {printf (msg [ch_LNG] [1]);
return (-8);
     }
   }
  fread ((char*)&i,       sizeof (int), 1, instream);
  fread ((char*)&ch_EPS,  sizeof (float), 1, instream);
  fread ((char*)&ch_width,sizeof (float), 1, instream);
  fread ((char*)&csum,    sizeof (long), 1, instream);
  fread ((char*)&sum,     sizeof (long), 1, instream);

/* аsetting index_position */
 /* for (i = 0; i < ch_topCOUNT; i++) ch_next_position();
/* initialization of faces chain */
 /* for (i = 0; i <= ch_facetCOUNT; i++)
ERR_RET (ch_add_facet (&ch_first_facet));
  ch_emp_facet       = ch_first_facet;
  ch_first_facet     = ch_first_facet->next;
  ch_emp_facet->next = NULL;
/* считывание граней */
 /* sum = 0;
  k = 0;
  i = 2;
  do
   {VIEW (pfacet, ch_first_facet)
     {fread ((char*)&p, sizeof (float), 1, instream);
      pfacet->c [i] = p;
      p1 = *(unsigned long*)&p;
      if (k) p1 >>= 1;
      sum += p1;
      k = !k;
     }
    if (i == ch_N1) i = 1;
    else if (i > 1) i++;
	 else i--;
   } while (i != -1);
/* sum control */
 /* if (sum != csum)
   {fclose (instream);
    printf (msg [ch_LNG] [4]);
return (-8);
   }
/*initialization of tops chain  */
 /* for (i = 0; i < ch_estCOUNT; i++)
   {ptop = (ch_top*) malloc (sizeof (ch_top));
    if (ptop == NULL)
return (-5);
    ptop->next = ch_first_top;
    if (NULL == (ptop->c = (float*) malloc (ch_SIZEctop)))
return (-5);
    ch_first_top = ptop;
   }
/* reading the tops */
 /* for (i = 0; i < ch_N; i++)
    VIEW (ptop, ch_first_top)
      fread ((char*)(ptop->c + i), sizeof (float), 1, instream);
/* sorting the tops */
 /* current = 1;
  pfacet = ch_first_facet;
  ptop = ch_first_top;
  ch_first_top=NULL;
  ch_estCOUNT = 0;
  while (ptop != NULL)
   {fread ((char*)&k, sizeof (int), 1, instream);
    pred_top = ptop;
    ptop = ptop->next;
    if (k == -1)
     {pred_top->next = ch_first_top;
      ch_first_top = pred_top;
     }
    else
     {if (k < current)
       {current = 1;
	pfacet = ch_first_facet;
       }
      while (k != current)
       {current++;
	if(NULL == (pfacet = pfacet->next))
	 {printf ("%s %d", msg [ch_LNG] [2], k);
return (-8);
	 }
       }
      pfacet->top = pred_top->c;
      ch_estCOUNT++;
      free (pred_top);
     }
   }
/* reading indicies */
/*#ifdef CH_SIMPLEX
  for (i = 1; i <= ch_index_position.number; i++)
   {pfacet = ch_first_facet;
    psimp = pfacet->simp;
    numsimp = 0;
    while (pfacet != NULL)
     {fread ((char*)&l, sizeof (long), 1, instream);
      if (l < 0 && l > -32000)
	numsimp = l;
      else
       {psimp [i].ind = l;
	if (numsimp)
	 {if (i == 1)
	   {psimp->next = (ch_simplex*) malloc (ch_SIZEind);
	    if (psimp->next == NULL)
return(-5);
	    psimp->next->next = NULL;
	   }
	  psimp = psimp->next;
	  numsimp++;
	 }
	else
	 {pfacet = pfacet->next;
	  psimp = pfacet->simp;
	 }
       }
     }
   }
/* defining Ncomb */
 /* ch_Ncomb = 0;
  for (i = 1; i <= ch_index_position.number; i++)
   {a = ch_first_facet->simp [i].ind;
    while (a) {a &= (a - 1); ch_Ncomb++;}
   }
#else
  for (i = 0; i <= ch_index_position.number; i++)
    VIEW (pfacet, ch_first_facet)
      fread ((char*)(pfacet->ind + i), sizeof (long), 1, instream);
/* defining Ncomb */
/*  ch_Ncomb = ch_N;
  VIEW (pfacet, ch_first_facet)
   {if (*pfacet->c != -1.)
  continue;
    k = 0;
    ONES (pfacet);
    ch_Ncomb = k;
  break;
   }
#endif
  ch_RHYPER = (ch_Ncomb == ch_N1);
  IOstatus = 2;
  fclose (instream);
return (IOstatus);
 }    /* ch_read_chs */
