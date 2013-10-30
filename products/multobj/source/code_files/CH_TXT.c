#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "ch_main.h"
#include "ch_var.def"

static char *msg [2][4] = {
 {"Не могу открыть файл",
  "Неверные данные в строке 2",
  "Нет грани",
  "Мало места на диске"
 },
 {"Could not open file",
  "Line 2 is incorrect",
  "No facet number",
  "Disk full"
 }};


static int end;

/* unsigned SIZEind,SIZEctop,SIZEcfacet; */
/* int estTOTAL,facetTOTAL;              */
/* float max_all_est,EPSdif,INF;         */


int ch_write_dat (in_name, out_name)
  /* запись файла описаниЯ множества */
char *in_name, *out_name;
 {int i, k, current, num, topTOTAL;
  int ok;
  char str [82];
  char *l;
  ch_facet *pfacet;
  ch_top *ptop;
  FILE *instream, *outstream;
#ifdef CH_SIMPLEX
  int numsimp;
  ch_simplex *psimp;
#endif

  if (ch_emp_facet != NULL) ch_free_facet (&ch_emp_facet->next);
  if ( ! strcmp (in_name, out_name))
   {if (NULL == (l = strchr (in_name, '.')))
      l = strchr (in_name, '\0');
    strcpy (l, ".bak");
    unlink (in_name);
    rename (out_name, in_name);
   }
  if (NULL == (instream = fopen(in_name,"r")))
   {ch_no_file (in_name);
return (-8);
   }
  if(NULL == (outstream = fopen (out_name, "w")))
   {ch_no_file (out_name);
return(-8);
   }
  fgets (str, 82, instream);
  fputs (str, outstream);
  ch_estCOUNT = 0;
  ch_facetCOUNT = 0;
  VIEW (pfacet, ch_first_facet)
   {ch_facetCOUNT++;
    if (pfacet->top != NULL) ch_estCOUNT++;
   }
  topTOTAL = ch_estCOUNT;
  VIEW (ptop, ch_first_top) topTOTAL++;

  fgets (str, 82, instream);
  sprintf (str, "%5d%5d%5d%5d%5d%5d%5d", ch_N, ch_facetCOUNT,
       1, topTOTAL, 1, ch_topCOUNT, 0);
  sprintf (str + 35, "%10.3E%10.3E\n", ch_EPS, ch_width);
  if (end > 60) {str [55] = ' ';  str [56] = ' ';}
  fputs (str, outstream);
/* запись имен критериев */
  fgets (str, 82, instream);
  for (i = 0; i < ch_N; i++)
   {fgets (str, 82, instream);
    fputs (str, outstream);
   }
  fprintf (outstream, "\n");
  fclose (instream);

/* запись граней */
  i = 2;
  do
   {num = 0;
    VIEW (pfacet, ch_first_facet)
     {fprintf (outstream, "%16.8E", pfacet->c [i]);
      if ((num++) == 4)
       {fprintf (outstream, "\n");
	num = 0;
       }
     }
    if (num) fprintf (outstream, "\n");
    if (i == ch_N1) i = 1;
    else if (i > 1) i++;
	 else i--;
   } while (i != -1);
/* запись вершин */
  ch_reverse ();
  for (i = 0; i < ch_N; i++)
   {num = 0;
    VIEW (ptop, ch_first_top)
     {fprintf (outstream, "%16.8E", ptop->c [i]);
      if ((num++) == 4)
       {fprintf (outstream, "\n");
	num = 0;
       }
     }
    VIEW (pfacet, ch_first_facet)
      if (pfacet->top)
       {fprintf (outstream, "%16.8E", pfacet->top [i]);
	if ((num++) == 4)
	 {fprintf (outstream, "\n");
	  num = 0;
	 }
       }
    if (num) fprintf (outstream, "\n");
   }
/* запись признаков вершин */
  num = 0;
  VIEW (ptop, ch_first_top)
   {fprintf (outstream, "  -1");
    if ((num++) == 19)
     {fprintf (outstream, "\n");
      num = 0;
     }
   }
  current = 0;
  VIEW (pfacet, ch_first_facet)
   {current++;
    if (pfacet->top != NULL)
     {fprintf (outstream, "%4d", current);
      if ((num++) == 19)
       {fprintf (outstream, "\n");
	num = 0;
       }
     }
   }
  if (num) fprintf (outstream, "\n");
  ch_reverse ();
/* запись индексов */
  k = ch_index_position.number;
  if (ch_ex_next && ! (ch_index_position.bit << 1)) k--;

#ifdef CH_SIMPLEX
  for (i = 1; i <= k; i++)
   {num = 0;
    pfacet = ch_first_facet;
    numsimp = 0;

    while (pfacet != NULL)
     {if (numsimp)
       {fprintf (outstream, "%8lX", psimp [i].ind);
	numsimp--;
	if (numsimp)
	  psimp = psimp->next;
	else
	  pfacet = pfacet->next;
       }
      else
       {VIEW_INDEX (psimp, pfacet) numsimp++;
	psimp = pfacet->simp;
	if (numsimp == 1)
	  continue;
	else
	  fprintf (outstream, " +%5d ", numsimp-1);
       }
#else
  for (i = 0; i <= k; i++)
   {num = 0;
    VIEW (pfacet, ch_first_facet)
     {fprintf (outstream, "%8lX", pfacet->ind [i]);
#endif
      if ((num++) == 9)
       {ok = fprintf (outstream, "\n");
	num = 0;
       }
     }
    if (num) ok = fprintf (outstream, "\n");
   }
  fclose (outstream);
  if (ok == EOF)
   {printf (msg [ch_LNG] [3]);
return (-8);
   }
return (0);
 }    /* ch_write_dat */