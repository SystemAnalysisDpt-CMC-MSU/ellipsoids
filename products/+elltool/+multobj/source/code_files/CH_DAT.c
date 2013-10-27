#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "ch_main.h"
#include "ch_var.def"

static char *msg [2][8] = {
 {"�� ���� ������ 䠩�",
  "������ �����",
  "��� �࠭�",
  "���� ���� �� ��᪥",
  "������ �ଠ� 䠩��",
  "���� ���ਥ�",
  "���������",
  "������ ⨯ ������"
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
  /* ��ॢ��� 楯� ���設 */
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
  /* ᮮ�饭�� � ������⨨ 䠩�� */
 {printf("%s %s",msg [ch_LNG] [0], name);
 }    /* ch_no_file */

int ch_read_dat (in_name, model_type, model_name, objnums)
  /* �⥭�� 䠩�� ���ᠭ�� ������⢠ */
char *in_name, *model_type, *model_name;
int **objnums;
 {int i, k, nvar, IOstatus;
  char *obj_names, buf [10], name [10], str [82], c;
  FILE *instream, *mcd;

  ch_free_mem ();
  if (NULL == (instream = fopen (in_name,"rb")))
   {ch_no_file (in_name);
return (-8);
   }
  fscanf (instream, "%s", str);
  if (strcmp (str, "*POTENTIAL#CHS-file#3.1*"))
   {fclose (instream);
    printf (msg [ch_LNG] [4]);
return (-8);
   }
  fgets (str, 82, instream);
  fscanf (instream, "%s", str); /* ��� mcd */
  if (NULL == (mcd = fopen (str, "r")))
   {ch_no_file (str);
    fclose (instream);
return (-8);
   }
  fscanf (instream, "%d", &ch_N);
  fgets (str, 82, instream);
  if (ch_N < 1)
   {printf (msg [ch_LNG] [5]);
    fclose (instream);
return (-8);
   }
  ch_N1 = ch_N + 1;

  ch_topCOUNT = 0;
  ch_estCOUNT = 0;
  IOstatus = 1;
/* ���뢠��� ���� � �ਧ����� ���� */
  ch_state = (int*) realloc (ch_state, ch_N * sizeof (int));
  obj_names = (char*) malloc (ch_N * 10);
  if (obj_names == NULL)
return (-5);
  for (i = 0; i < ch_N; i++) ch_state[i] = 0;
  for (i = 0; i < ch_N; i++)
   {fgets (str, 82, instream);
    *buf = ' ';
    sscanf (str, "%s%s", obj_names + i * 10, buf);
    if (*buf == '+' || *buf == '-')
     {IOstatus = 4;
      if (*buf == '+') k = 1;
      else k = -1;
      ch_state [i] = k;
     }
   }
  if (IOstatus == 1)
   {free (ch_state);
    ch_state = NULL;
   }
/* ����� ���ਠ���� ��६����� �� mcd */
  *objnums = (int*) realloc (*objnums, ch_N * sizeof (int));
  if (*objnums == NULL)
return (-5);
  for (i = 0; i < ch_N; i++) (*objnums) [i] = 0;
  for (i = 0; i < 3; i++)
    fgets (str, 82, mcd);
  while (1)
   {fgets (str, 82, mcd);
    if (str [0] == '-')
  break;
    sscanf (str, "%s%d%s", buf, &nvar, name);
    for (i = 0; i < ch_N; i++)
     {if ( ! strcmp (name, obj_names + i * 10))
       {(*objnums) [i] = nvar;
    break;
       }
     }
    fgets (str, 82, mcd);
   }
  for (i = 0; i < ch_N; i++)
    if ( ! (*objnums) [i])
     {printf ("%s %s", obj_names + i * 10, msg [ch_LNG] [6]);
      free (obj_names);
      fclose (mcd);
      fclose (instream);
return (-8);
     }
  free (obj_names);
  fgets (str, 82, mcd);
  fclose (mcd);
  if (!strcmp (model_type, "nul"))
    sscanf (str, "%s%s", model_type, model_name);
  else
   {sscanf (str, "%s%s", buf, model_name);
    if (strcmp (model_type, buf))
     {printf (msg [ch_LNG] [7]);
      fclose (instream);
return (-8);
     }
   }
  ch_EPS = ch_EPSdif;
  ch_width = ch_INF;
  fread ((char*)&c, 1, 1, instream);
/* ���樠����樨, ������騥 �� ������ */
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
  fread ((char*)&c, 1, 1, instream);
  if (!feof (instream))
   {fseek (instream, -1, SEEK_CUR);
    IOstatus = ch_read_chs (instream);
   }
  fclose (instream);
  if (IOstatus > 0) strcpy (read_name, in_name);
return (IOstatus);
 }  /* ch_read_dat */

int ch_read_chs (instream)
  /* �⥭�� ���பᨬ�樨 � ����୮� ���� */
FILE *instream;
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

/* ��⠭���� index_position */
  for (i = 0; i < ch_topCOUNT; i++) ch_next_position();
/* ���樠������ 楯� �࠭�� */
  for (i = 0; i <= ch_facetCOUNT; i++)
ERR_RET (ch_add_facet (&ch_first_facet));
  ch_emp_facet       = ch_first_facet;
  ch_first_facet     = ch_first_facet->next;
  ch_emp_facet->next = NULL;
/* ���뢠��� �࠭�� */
  sum = 0;
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
/* ����஫� �㬬� */
  if (sum != csum)
   {fclose (instream);
    printf (msg [ch_LNG] [4]);
return (-8);
   }
/* ���樠������ 楯� ���設 */
  for (i = 0; i < ch_estCOUNT; i++)
   {ptop = (ch_top*) malloc (sizeof (ch_top));
    if (ptop == NULL)
return (-5);
    ptop->next = ch_first_top;
    if (NULL == (ptop->c = (float*) malloc (ch_SIZEctop)))
return (-5);
    ch_first_top = ptop;
   }
/* ���뢠��� ���設 */
  for (i = 0; i < ch_N; i++)
    VIEW (ptop, ch_first_top)
      fread ((char*)(ptop->c + i), sizeof (float), 1, instream);
/* ���஢�� ���設 */
  current = 1;
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
/* ���뢠��� �����ᮢ */
#ifdef CH_SIMPLEX
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
/* ��।������ Ncomb */
  ch_Ncomb = 0;
  for (i = 1; i <= ch_index_position.number; i++)
   {a = ch_first_facet->simp [i].ind;
    while (a) {a &= (a - 1); ch_Ncomb++;}
   }
#else
  for (i = 0; i <= ch_index_position.number; i++)
    VIEW (pfacet, ch_first_facet)
      fread ((char*)(pfacet->ind + i), sizeof (long), 1, instream);
/* ��।������ Ncomb */
  ch_Ncomb = ch_N;
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
