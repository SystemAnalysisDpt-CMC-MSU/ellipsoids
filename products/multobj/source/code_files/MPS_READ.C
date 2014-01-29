#include <math.h>
#include <string.h>
#include <alloc.h>
#include "lpm_var.def"

#ifdef WINDOWS
static GLOBALHANDLE hTable;
#else
#define _fmemcpy memcpy
#define _fmemcmp memcmp
#endif

static char *mess [2][12] = {
 {"Строки с одинаковым именем",
  "Нет строки",
  "Не могу открыть",
  "Первой строкой должно быть  NAME",
  "Второй строкой должно быть  ROWS",
  "Нет секции  COLUMNS",
  "Недопустимый тип",
  "Отсутствует  ENDATA",
  "Нет секции  RHS",
  "Неверные границы у переменной",
  "Нет элементов в строке",
  "Суммарная длина hash-цепочек"
 },
 {"Two rows with identical name",
  "Row not found:",
  "Cannot open",
  "First must be NAME\n",
  "Second must be ROWS\n",
  "Cannot find COLUMNS\n",
  "Unknown type",
  "No ENDATA\n",
  "Cannot find RHS\n",
  "Wrong bounds for column",
  "No elements in row",
  "Total hash-chain length"
 }};
static int sumlen;
static int len;
static unsigned int  *table;
char rhs_name [9] = "";
char ranges_name [9] = "";
char bounds_name [9] = "";
/*-----------------------------------------*/
typedef char (*type_table) [4];
type_table row_type = " l    l  e    e  g    g  n    n ";
type_table bou_type = " lo  up  fx  fr  mi  pl ";
int get_type (char *str, type_table tab, int n)
 {int i;
  for (i = 0; i < n; i++)
    if (!memicmp (str, tab [i], 4))
  break;
return (i);
 }  /* get_type */
/*-----------------------------------------*/
int fgetmps (char *str, int max, FILE *fp)
 {int i = 0, n = 0, c = 0;

  while (1)
   {c = fgetc (fp);
    if (c == '\n' || c == EOF)
  break;
    if (i == max)
  continue;
    str [i++] = c;
    if (c != ' ') n = i;
   }
  str [n] = str [36] = 0;
return (n - 10);
 }  /* fgetmps */
/*-----------------------------------------*/
void strcpy8 (char *dest, char *src)
 {int i, j;
  for (j = 0; j < 8; j++)
    if (src [j] != ' ')
  break;
  i = 0;
  for (; j < 8; j++)
   {if (src [j] == '\0')
  break;
    dest [i++] = src [j];
   }
  for (; i < 8; i++)
    dest [i] = ' ';
 }   /* strcpy8 */
/*-----------------------------------------*/
int init_hash (int m)
/* иницилизация hash-таблицы */
 {int maxdiv, simple, i;

  len = m << 1;
  if (len < 10) len = 10;
  len = (len & ~1) - 1;
  maxdiv = sqrt (len);
  do
   {len += 2;
    maxdiv++;
    simple = 1;
    for (i = 3; i <= maxdiv; i += 2)
     {if (len % i == 0)
       {simple = 0;
    break;
     } }
   } while (! simple);
#ifdef WINDOWS
  hTable = GlobalAlloc (GMEM_MOVEABLE | GMEM_ZEROINIT,
		len * sizeof (int));
  table = hTable ? GlobalLock (hTable) : NULL;
#else
  table = calloc (len, sizeof (int));
#endif
return (table ? 0 : -5);
 }   /* init_hash */
/*-----------------------------------------*/
int hash (char name [8], int mode)
/* mode = 0 поиск с выдачей номера */
/* mode = 1 запись в таблицу */
 {unsigned long n;
  int len2, num, init;
  int step, i, cr, lstep, li, lcr, maxi, maxli, maxcr;

  len2 = len - 2;	/* mod для определения шага */
  n = *(long*) name + *(long*) (name + 4);
  init = n % len;	/* первая проба */
  step = n % len2 + 1;	/* шаг для следующих проб */

  cr = 0;		/* счетчик проб (длина цепочки) */
/* цикл по пробам */
  for (i = init; (num = table [i]) != 0;
	i = (i + step) % len)
   {if (! _fmemcmp (lpm_row_name [num - 1], name, 8))
/* нашли имя :	mode = 0 - получили ответ */
/*		mode = 1 - имя уже есть - ошибка */
     {if (mode)
	fprintf (prn_file, "%s %.8s\n",
		mess [lpm_LNG][0], name);
return (mode ? -1 : i);
     }
    sumlen++;
    cr++;
   }
  if (!mode)
   {fprintf (prn_file, "%s %.8s \n",
		mess [lpm_LNG][1], name);
/* нет такого имени - ошибка */
return (-1);
   }
/* попытка уменьшить суммарную длину цепочек */
  maxcr = 0;	/* суммарная длина двух цепочек */
  maxi = i;	/* место, куда будем ставить это имя */
  maxli = i;	/* место, куда будем переносить старое имя */
  i = init;
  for (; cr > 1; cr--)
   {num = table [i];
    n = *(long *) (lpm_row_name [num - 1] + 4)
	+ *(long *) lpm_row_name [num - 1];
    lstep = n % len2 + 1;	/* шаг для старого имени */
    li = i;
    for (lcr = cr - 1; lcr > 0;lcr--)
     {li = (li + lstep) % len;
      if (!table [li])
    break;
     }
    if (lcr > maxcr)
/* нашли более хороший вариант */
     {maxcr = lcr;
      maxi = i;
      maxli = li;
      if (lcr == cr)
/* цепочка для нового имени длиной 1 - лучше уже не будет */
  break;
     }
    i = (i + step) % len;
   }
  sumlen -= maxcr;
/* перенос старого имени  на новое место */
/* если лучшего не нашли - тождественно */
  table [maxli] = table [maxi];
return (maxi);
 }   /* hash */
/*-----------------------------------------*/
int lpm_read
 (char *mps_name,/* имя MPS-файла */
  int *pm,	/* ограничений */
  int *pn,	/* переменных преобразованной задачи */
  lpm_num *pl,	/* элементов преобразованной задачи */
  int *pn0,	/* переменных исходной задачи */
/* добавка при отведении памяти */
  int dm,	/* ограничений */
  int dn,	/* переменных */
  lpm_num dl	/* элементов */
 )
 {int mn, lcount, ncount;
  int i, col, code, len, pos, fixed, check, IOstatus;
  char *end_rhs, *end_ranges, str [63], str1 [63];
  char col_old [9] = "";
  char col_name [9], row_name [9], cmp_name [9];
  double val, fixed_val;
  FILE *mps1, *mps2;
  long fp_rows = 0,
	fp_columns= 0,
	fp_ranges = 0,
	fp_bounds = 0;

  strcpy8 (rhs_name, rhs_name);
  strcpy8 (ranges_name, ranges_name);
  strcpy8 (bounds_name, bounds_name);
  end_ranges = end_rhs = "endata";
  mps1 = fopen (mps_name, "r");
  if (mps1 == NULL)
   {fprintf (prn_file, "%s  %s\n",
		mess [lpm_LNG][2], mps_name);
return (-1);
   }
  IOstatus = 0;
  fgetmps (str, 4, mps1);
  if (memicmp (str, "name", 4))
   {fputs (mess [lpm_LNG][3], prn_file);
    IOstatus = -1;
   }
  if (!IOstatus)
   {fgetmps (str, 4, mps1);
    if (memicmp (str, "rows", 4))
     {fputs (mess [lpm_LNG][4], prn_file);
      IOstatus = -1;
   } }
/* определение числа строк */
  if (!IOstatus)
   {fp_rows = ftell (mps1);
    *pm = 0;
    mn = 0;
    while (1)
     {fgetmps (str, 12, mps1);
      if (feof (mps1))
       {fputs (mess [lpm_LNG][5], prn_file);
	IOstatus = -1;
    break;
       }
      if (!memicmp (str, "columns", 7))
    break;
      code = get_type (str, row_type, 8) >> 1;
      if (code > 3)
       {fprintf (prn_file, "%s %.4s\n",
		mess [lpm_LNG][6], str);
	IOstatus = -1;
    break;
       }
      if (code > 2)
    continue;
      (*pm)++;
      if (code != 1) mn++;
   } }
  if (!IOstatus)
    IOstatus = lpm_row_mem (*pm + dm);
  if (!IOstatus)
   {mps2 = fopen (mps_name, "r");
    IOstatus = mps2 ? 0 : -5;
   }
  if (!IOstatus)
    IOstatus = init_hash (*pm);
  else
    fclose (mps2);
  if (IOstatus)
   {fclose (mps1);
return (IOstatus);
   }
  fp_columns = ftell (mps1);
  fseek (mps2, fp_rows, SEEK_SET);
/* составление hash-таблицы, запись имен и типов строк */
  sumlen = 0;
  i = 0;
#ifdef WINDOWS
  lpm_nrow = (int *) GlobalLock (hLpm_nrow);
  lpm_row_name = (name_table) GlobalLock (hLpm_row_name);
#endif
  for (i = 0; i < *pm;)
   {fgetmps (str, 12, mps2);
    code = get_type (str, row_type, 8) >> 1;
    if (code > 2)
  continue;
    lpm_nrow [i] = code;
    strcpy8 (row_name, str + 4);
    _fmemcpy (lpm_row_name [i], row_name, 8);
    code = hash (row_name, 1);
    if (code == -1)
     {IOstatus = -1;
  break;
     }
    table [code] = ++i;
   }
  if (lpm_PRNT > 1)
    fprintf (prn_file, "%s %d\n",
		mess [lpm_LNG][11], sumlen);
/* поиск остальных секций */
  if (!IOstatus)
   {check = 0;
    while (1)
     {fgetmps (str, 6, mps1);
      if (!memicmp (str, "rhs", 3))
       {check = 1;
    continue;
       }
      if (!memicmp (str, "ranges", 6))
       {end_rhs = "ranges";
	fp_ranges = ftell (mps1);
    continue;
       }
      if (!memicmp (str, "bounds", 6))
       {*(fp_ranges ? &end_ranges : &end_rhs) = "bounds";
	fp_bounds = ftell (mps1);
    continue;
       }
      if (!memicmp (str, "endata", 6))
    break;
      if (feof (mps1))
       {fputs (mess [lpm_LNG][7], prn_file);
	IOstatus = -1;
    break;
     } }
    if (!check)
     {fputs (mess [lpm_LNG][8], prn_file);
      IOstatus = -1;
   } }
  if (fp_ranges && !IOstatus)
/* коррекция типов строк по RANGES */
   {fseek (mps1, fp_ranges, SEEK_SET);
    check = 1;
    while (1)
     {len = fgetmps (str, 61, mps1);
      if (!memicmp (str, end_ranges, 6))
       {if (check) fp_ranges = 0;
    break;
       }
      strcpy8 (col_name, str + 4);
/* если ranges не задано, то берется первое встречное */
      if (ranges_name [0] == ' ')
	strcpy8 (ranges_name, col_name);
      if (memcmp (col_name, ranges_name, 8))
/* имя RANGES не наше */
       {if (check)
	 {fp_ranges = ftell (mps1);
    continue;
	 }
	else
    break;
       }
      check = 0;
      for (pos = 14; pos < len; pos += 15)
       {strcpy8 (row_name, str + pos);
	pos += 10;
	code = hash (row_name, 0);
	if (code == -1)
      continue;
	i = table [code] - 1;
	val = atof (str + pos);
	if (val == 0.)
	 {if (lpm_nrow [i] != 1)
	   {lpm_nrow [i] = 1;
	    mn--;
	 } }
	else
	 {if (lpm_nrow [i] == 1)
	   {lpm_nrow [i] = (val > 0.) ? 2 : 0;
	    mn++;
	 } }
       }	/* цикл по двум значениям */
     }	/* цикл по строкам файла */
   }	/* if есть секция RANGES */
/* поиск нашего имени в секции BOUNDS */
  if (fp_bounds && !IOstatus)
   {fseek (mps1, fp_bounds, SEEK_SET);
    check = 0;  /* пока не нашли нашего имени */
    while (1)
     {fgetmps (str1, 36, mps1);
      if (!memicmp (str1, "endata", 6))
    break;
      strcpy8 (col_name, str1 + 4);
/* если bounds не задано, то берется первое встречное */
      if (bounds_name [0] == ' ')
	strcpy8 (bounds_name, col_name);
      if (!memcmp (col_name, bounds_name, 8))
       {check = 1;
    break;
       }
      fp_bounds = ftell (mps1);
   } }
/* подсчет числа элементов основной матрицы */
  if (!IOstatus)
   {if (!check) fp_bounds = 0;
    lcount = ncount = 0;
    fseek (mps2, fp_columns, SEEK_SET);
    while (1)
     {len = fgetmps (str, 61, mps2);
      if (!memicmp (str, "rhs", 3))
    break;
      strcpy8 (col_name, str + 4);
      if (memcmp (col_name, col_old, 8))
/* новый столбец */
       {strcpy8 (col_old, col_name);
	fixed = 0;
	if (check)
/* не фиксирована ли переменная в BOUNDS */
	 {while (1)
	   {if (!memicmp (str1, "endata", 6))
	  break;
	    strcpy8 (cmp_name, str1 + 4);
	    if (memcmp (bounds_name, cmp_name, 8))
	     {check = 0;
	  break;
	     }
	    strcpy8 (cmp_name, str1 + 14);
	    if (memcmp (col_name, cmp_name, 8))
	  break;
	    if (!memicmp (str1, " fx ", 4))
	      fixed = 1;
	    fgetmps (str1, 36, mps1);
	 } }
	if (!fixed)
	 {ncount++;
	  lcount++;
       } }
/* конец обработки нового столбца */
      if (fixed)	/* эта переменная типа FX */
    continue;
      for (pos = 14; pos < len;	pos += 15)
       {strcpy8 (row_name, str + pos);
	pos += 10;
	code = hash (row_name, 0);
	if (code != -1)
	 {val = atof (str + pos);
	  if (val != 0.)
	    lcount++;
   } } } }
  if (!IOstatus)
   {*pn0 = ncount;
    *pn = ncount + mn;
    *pl = lcount + 2 * mn;
/* полное выделение памяти */
    IOstatus = lpm_col_mem (*pm + dm, *pn + dn, *pl + dl);
   }
  if (IOstatus)
   {fclose (mps1);
    fclose (mps2);
#ifdef WINDOWS
    GlobalUnlock (hLpm_row_name);
    GlobalUnlock (hLpm_nrow);
    GlobalUnlock (hTable);
    GlobalFree (hTable);
#else
    free (table);
#endif
return (IOstatus);
   }
#ifdef WINDOWS
  lpm_lock ();
  lpm_rhs = (lpm_pfloat) GlobalLock (hLpm_rhs);
#endif
/* считывание правых частей */
  for (i = 0; i < *pm; i++) lpm_rhs [i] = 0.;
  while (1)
   {len = fgetmps (str, 61, mps2);
    if (!memicmp (str, end_rhs, 6))
  break;
    strcpy8 (cmp_name, str + 4);
/* если rhs не задано, то берется первое встречное */
    if (rhs_name [0] == ' ')
      strcpy8 (rhs_name, cmp_name);
    if (memcmp (rhs_name, cmp_name, 8))
  continue;
    for (pos = 14; pos < len; pos += 15)
     {strcpy8 (row_name, str + pos);
      pos += 10;
      code = hash (row_name, 0);
      if (code != -1)
	lpm_rhs [table [code] - 1] = atof (str + pos);
   } }
/* настройка на наше имя в секции BOUNDS */
  if (fp_bounds)
   {check = 1;
    fseek (mps1, fp_bounds, SEEK_SET);
    fgetmps (str1, 36, mps1);
   }
  else check = 0;
/* считывание матрицы и обработка BOUNDS */
#ifdef WINDOWS
  lpm_lower = (lpm_pfloat) GlobalLock (hLpm_lower);
  lpm_col_name = (name_table) GlobalLock (hLpm_col_name);
  lpm_ncol = (int *) GlobalLock (hLpm_ncol);
#endif
  lcount = 0;
  ncount = 0;
  for (i = 0; i < *pn; i++) lpm_type [i] = 0;
/* признаки наличия элементов в строке */
  for (i = 0; i < *pm; i++) lpm_ncol [i] = 0;
  fseek (mps2, fp_columns, SEEK_SET);
  while (1)
   {len = fgetmps (str, 61, mps2);
    if (!memicmp (str, "rhs", 3))
  break;
    strcpy8 (col_name, str + 4);
    if (memcmp (col_name, col_old, 8))
/* новый столбец */
     {strcpy8 (col_old, col_name);
      fixed = 0;
      _fmemcpy (lpm_col_name [ncount], col_name, 8);
      lpm_lower [ncount] = lpm_upper [ncount] = 0.;
      if (check)
/* не фиксирована ли переменная в BOUNDS */
       {while (1)
	 {if (!memicmp (str1, "endata", 6))
	break;
	  strcpy8 (cmp_name, str1 + 4);
	  if (memcmp (bounds_name, cmp_name, 8))
	   {check = 0;
	break;
	   }
	  strcpy8 (cmp_name, str1 + 14);
	  if (memcmp (col_name, cmp_name, 8))
	break;
	  val = atof (str1 + 24);
/* type для границ: */
/* 0x2 - есть числовая нижняя граница */
/* 0x1 - нижняя граница -  -бесконечность, иначе - 0 */
/* 0x8 - есть числовая верхняя граница */
/* 0x4 - верхняя граница -  0 иначе -  -бесконечность */
	  code = get_type (str1, bou_type, 6);
	  switch (code)
	   {case 0:
	      lpm_lower [ncount] = val;
	      lpm_type [ncount] |= 2;
	  break;
	    case 1:
	      lpm_upper [ncount] = val;
	      lpm_type [ncount] |= 8;
	  break;
	    case 2:
	      fixed = 1;
	      fixed_val = val;
	  break;
	    case 3:
	      lpm_type [ncount] = 1;
	  break;
	    case 4:
	      lpm_type [ncount] &= 0xc;
	      lpm_type [ncount] |= 1;
	      if (!(lpm_type [ncount] & 8))
		lpm_type [ncount] |= 4;
	  break;
	    case 5:
	      lpm_type [ncount] &= 3;
	  break;
	    case 6:
	      fprintf (prn_file, "%s %.4s\n",
			mess [lpm_LNG][6], str1);
	   }
	  fgetmps (str1, 36, mps1);
       } }
/* контроль ошибок границ */
      if ((lpm_type [ncount] & 0xa) == 0xa
		&& lpm_lower [ncount] > lpm_upper [ncount]
	|| (lpm_type [ncount] & 0xe) == 6
		&& lpm_lower [ncount] > 0.
	|| (lpm_type [ncount] & 0xb) == 8
		&& lpm_upper [ncount] < 0.)
       {fprintf (prn_file, "%s  %.8s\n",
		mess [lpm_LNG][9], lpm_col_name [ncount]);
	IOstatus = -1;
  break;
       }
      if (!fixed)
       {lpm_b [lcount] = 0.;
	lpm_ibi [lcount++] = 0;
	ncount++;
     } }
/* конец обработки нового столбца */
    for (pos = 14; pos < len; pos += 15)
     {strcpy8 (row_name, str + pos);
      pos += 10;
      code = hash (row_name, 0);
      if (code != -1)
       {i = table [code] - 1;
	val = atof (str + pos);
	if (val != 0.)
	 {if (fixed)
	    lpm_rhs [i] -= val * fixed_val;
	  else
	   {lpm_b [lcount] = val;
	    lpm_ibi [lcount++] = i + 1;
	    lpm_ncol [i] = 1;
   } } } } }
#ifdef WINDOWS
  GlobalUnlock (hLpm_rhs);
#endif
  fclose (mps2);
  if (!IOstatus)
   {lpm_b [lcount] = 0.;
    lpm_ibi [lcount++] = 0;
/* логические переменные */
    for (i = 0; i < *pm; i++)
     {if (! lpm_ncol [i])
       {fprintf (prn_file, "%s  %.8s\n",
		mess [lpm_LNG][10], lpm_row_name [i]);
	IOstatus = -1;
    break;
       }
      if (lpm_nrow [i] != 1)
       {lpm_b [lcount] = 1 - lpm_nrow [i];
	lpm_ibi [lcount++] = i + 1;
	lpm_b [lcount] = 0.;
	lpm_ibi [lcount++] = 0;
	lpm_lower [ncount] = 0.;
	lpm_upper [ncount] = 0.;
	_fmemcpy (lpm_col_name [ncount],
		lpm_row_name [i], 8);
	lpm_ncol [i] = ncount;
	lpm_ibase [i] = ++ncount;
       }
      else
	lpm_ibase [i] = 0;
   } }
#ifdef WINDOWS
  GlobalUnlock (hLpm_col_name);
  GlobalUnlock (hLpm_lower);
#endif
  if (IOstatus)
   {fclose (mps1);
#ifdef WINDOWS
    GlobalUnlock (hLpm_ncol);
    lpm_unlock ();
    GlobalUnlock (hLpm_row_name);
    GlobalUnlock (hLpm_nrow);
    GlobalUnlock (hTable);
    GlobalFree (hTable);
#else
    free (table);
#endif
return (IOstatus);
   }
  if (fp_ranges)
/* обработка RANGES */
   {fseek (mps1, fp_ranges, SEEK_SET);
    while (1)
     {len = fgetmps (str, 61, mps1);
      if (!memicmp (str, end_ranges, 6))
    break;
      strcpy8 (col_name, str + 4);
      if (memcmp (col_name, ranges_name, 8))
    break;
      for (pos = 14; pos < len; pos += 15)
       {strcpy8 (row_name, str + pos);
	pos += 10;
	code = hash (row_name, 0);
	if (code == -1)
      continue;
	val = atof (str + pos);
	i = table [code] - 1;
	if (val == 0. || lpm_nrow [i] == 1)
      continue;
	col = lpm_ncol [i];
	lpm_type [col] = 8;
	lpm_upper [col] = fabs (val);
       }	/* цикл по двум значениям */
     }	/* цикл по строкам файла */
   }
#ifdef WINDOWS
  GlobalUnlock (hLpm_ncol);
  GlobalUnlock (hLpm_row_name);
  GlobalUnlock (hLpm_nrow);
#endif
  free (table);
  fclose (mps1);
  lpm_init (*pl);
#ifdef WINDOWS
  lpm_unlock ();
#endif
return (0);
 }   /* read_mps */
