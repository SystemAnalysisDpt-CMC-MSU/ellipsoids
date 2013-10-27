#include <malloc.h>
#include "ch_main.h"
#include "ch_var.def"

int ch_init_dat(void)
/* инициализация переменных для CH */
/* вместо ch_read_dat для начала процесса */
 {ch_facetCOUNT = 0;
  ch_topCOUNT = 0;
  ch_estCOUNT = 0;
  ch_estTOTAL   = 0;
  ch_facetTOTAL = 0;
  ch_N1 = ch_N+1;
  ch_ex_next    = 0;
  ch_index_position.bit = (unsigned long) 0L;
  ch_index_position.number = -1;
  ch_SIZEind = 0;
  ch_SIZEctop = ch_N * sizeof (float);
  ch_SIZEcfacet= (ch_N + 2) * sizeof (float);
  ch_coef = (double*) realloc (ch_coef, (ch_N + 2) * sizeof (double));
  if(ch_coef==NULL) return(-5);
  ch_EPS = ch_EPSdif;
  ch_width = ch_INF;
return (1);
 }
