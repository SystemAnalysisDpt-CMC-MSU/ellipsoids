#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "ch_main.h"
#include "ch_var.def"

//static char in_name [43] ="input.chs";
//static char out_name [40] ="output.set";
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


int ch_write_dat (float*** Amat,float** bVec,float*** vertMat,float** discrVec)
  /* recording output dataа */
 {int i, j, k, current, num, topTOTAL, row, idx;
  int ok;
  
  char str [82];
  char *l;
  float * bbVec;
  ch_facet *pfacet;
  ch_top *ptop;
  FILE *instream, *outstream;
#ifdef CH_SIMPLEX
  int numsimp;
  ch_simplex *psimp;
#endif
  if (ch_emp_facet != NULL) ch_free_facet (&ch_emp_facet->next);
  ch_estCOUNT = 0;
  ch_facetCOUNT = 0;
  VIEW (pfacet, ch_first_facet)
   {ch_facetCOUNT++;
    if (pfacet->top != NULL) ch_estCOUNT++;
   }
  topTOTAL = ch_estCOUNT;
  VIEW (ptop, ch_first_top) topTOTAL++;
 (*Amat)=(float**)realloc(*Amat,ch_N*sizeof(float*));
       for (j=0;j<ch_N;j++)
	        (*Amat)[j]=(float*)malloc(ch_facetCOUNT*sizeof(float));
   (*vertMat)=(float**)realloc((*vertMat),ch_N*sizeof(float*));
      for (j=0;j<ch_N;j++)
	          (*vertMat)[j]=(float*)malloc(topTOTAL*sizeof(float));
     (*bVec)=(float*)realloc((*bVec),ch_facetCOUNT*sizeof(float));
    (*discrVec)=(float*)realloc((*discrVec),ch_topCOUNT*sizeof(float));
/* recording faces */

  
  row = 0;
  idx = 0;
  i=2;
  do
   {num = 0;
    VIEW (pfacet, ch_first_facet)
    { 
		
	if (row<ch_N){
		(*Amat)[row][idx]=pfacet->c [i];
		
	}
	else if (row==ch_N)
	{
		
		(*bVec)[idx]=pfacet->c [i];
	}
	else 
	{
		(*discrVec)[idx]=pfacet->c [i];
	}
	idx++;
      if ((num++) == 4)
      {
	    num = 0;
      }
	 
	}
    if (num) 
	{
         row++;
		 idx=0;
	}
	
    if (i == ch_N1) i = 1;
    else if (i > 1) i++;
	 else i--;
   } while (i != -1);
/* recording tops */
  ch_reverse ();
  row = 0;  
  idx = 0;
  for (i = 0; i < ch_N; i++)
   {num = 0;
    VIEW (ptop, ch_first_top)
     {
	 (*vertMat)[row][idx]=ptop->c [i];
	 idx++;
      if ((num++) == 4)
      {
	    num = 0;
      }
     }
    VIEW (pfacet, ch_first_facet)
      if (pfacet->top)
	  {
		  (*vertMat)[row][idx]=pfacet->top [i];
		   idx++;
	if ((num++) == 4)
	 {
	  num = 0;
	 }
       }
    if (num) 
	{
		row++;
	    idx=0;
	}
	
   };
 
///* recording top's features */
//  num = 0;
//  VIEW (ptop, ch_first_top)
//   {fprintf (outstream, "  -1");
//    if ((num++) == 19)
//     {fprintf (outstream, "\n");
//      num = 0;
//     }
//   }
//  current = 0;
//  VIEW (pfacet, ch_first_facet)
//   {current++;
//    if (pfacet->top != NULL)
//     {fprintf (outstream, "%4d", current);
//      if ((num++) == 19)
//       {fprintf (outstream, "\n");
//	num = 0;
//       }
//     } 
//  }
//   
//  if (num) fprintf (outstream, "\n");
//  ch_reverse ();
///* recording indices */
//  k = ch_index_position.number;
//  if (ch_ex_next && ! (ch_index_position.bit << 1)) k--;
//  
//#ifdef CH_SIMPLEX
//  for (i = 1; i <= k; i++)
//   {num = 0;
//    pfacet = ch_first_facet;
//    numsimp = 0;
//
//    while (pfacet != NULL)
//     {if (numsimp)
//       {fprintf (outstream, "%8lX", psimp [i].ind);
//	numsimp--;
//	if (numsimp)
//	  psimp = psimp->next;
//	else
//	  pfacet = pfacet->next;
//       }
//      else
//       {VIEW_INDEX (psimp, pfacet) numsimp++;
//	psimp = pfacet->simp;
//	if (numsimp == 1)
//	  continue;
//	else
//	  fprintf (outstream, " +%5d ", numsimp-1);
//       }
//#else
//  for (i = 0; i <= k; i++)
//   {num = 0;
//    VIEW (pfacet, ch_first_facet)
//     {fprintf (outstream, "%8lX", pfacet->ind [i]);
//#endif
//      if ((num++) == 9)
//       {ok = fprintf (outstream, "\n");
//	num = 0;
//       }
//     }
//    if (num) ok = fprintf (outstream, "\n");
//   }
//  printf("123456789\n");
// // fclose (outstream);
// /* if (ok == EOF)
//   {printf (msg [ch_LNG] [3]);
//return (-8);
//   }*/
return (0);
 }    /* ch_write_dat */
