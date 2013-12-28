#include <math.h>
#include "lpm_var.def"

#ifndef WINDOWS
#include <alloc.h>
#endif

static lpm_num l0;

int lpm_col_mem
 (int m, /* число ограничений */
  int n, /* число переменных преобразованной задачи */
  lpm_num l /* длина матрицы преобразованной задачи */
 )
/* выделение памяти для массивов по числу переменных */
 {l0 = l;
  lpm_space = l * (1. + lpm_res);
  if (lpm_space > LPM_MAX_SPACE || m > LPM_MAX_ROW
				|| n > LPM_MAX_ROW)
return (-5);
  lpm_nips  = (m * 7) / 3;
#ifdef WINDOWS
  hLpm_type  = GlobalAlloc (GMEM_MOVEABLE, n);
  hLpm_col_name = GlobalAlloc (GMEM_MOVEABLE, n * 8);
  hLpm_lower = GlobalAlloc (GMEM_MOVEABLE,
		n * sizeof (float));
  hLpm_upper = GlobalAlloc (GMEM_MOVEABLE,
		n * sizeof (float));
  hLpm_a     = GlobalAlloc (GMEM_MOVEABLE,
		n * sizeof (double));
  hLpm_icol  = GlobalAlloc (GMEM_MOVEABLE,
		(n + 1) * sizeof (lpm_num));
  hLpm_ibi   = GlobalAlloc (GMEM_MOVEABLE,
		(lpm_space + 2) * sizeof (int));
  hLpm_b     = GlobalAlloc (GMEM_MOVEABLE,
		(lpm_space + 2) * sizeof (double));
return ((!hLpm_b) ? -5 : 0);
 }    /* lpm_col_mem */

int lpm_row_mem (int m /* число ограничений */)
/* выделение памяти для для массивов по числу ограничений */
 {hLpm_ibase = GlobalAlloc (GMEM_MOVEABLE,
		m * sizeof (int));
  hLpm_ncol  = GlobalAlloc (GMEM_MOVEABLE,
		m * sizeof (int));
  hLpm_nrow  = GlobalAlloc (GMEM_MOVEABLE,
		m * sizeof (int));
  hLpm_iacol = GlobalAlloc (GMEM_MOVEABLE,
		m * sizeof (lpm_num));
  hLpm_iarow = GlobalAlloc (GMEM_MOVEABLE,
		(m + 1) * sizeof (lpm_num));
  hLpm_row_name = GlobalAlloc (GMEM_MOVEABLE, m * 8);
  hLpm_rhs   = GlobalAlloc (GMEM_MOVEABLE,
		m * sizeof (float));
  hLpm_x     = GlobalAlloc (GMEM_MOVEABLE,
		m * sizeof (double));
  hLpm_xk    = GlobalAlloc (GMEM_MOVEABLE,
		m * sizeof (double));
  hLpm_ips   = GlobalAlloc (GMEM_MOVEABLE,
		((m * 3) + 1) * sizeof (lpm_num));
return ((!hLpm_ips || !hLpm_xk) ? -5 : 0);
 }    /* lpm_row_mem */

void lpm_lock (void)
/* фиксация памяти для LPM */
 {lpm_upper= (lpm_pfloat) GlobalLock (hLpm_upper);
  lpm_x    = (lpm_pdouble) GlobalLock (hLpm_x);
  lpm_xk   = (lpm_pdouble) GlobalLock (hLpm_xk);
  lpm_ibi  = (lpm_pibi)    GlobalLock (hLpm_ibi);
  lpm_ibj  = lpm_ibi + l0 + 1;
  lpm_icol = (lpm_num *)GlobalLock (hLpm_icol);
  lpm_type = (char *)   GlobalLock (hLpm_type);
  lpm_ips  = (lpm_num *)GlobalLock (hLpm_ips);
  lpm_ibase= (int *)    GlobalLock (hLpm_ibase);
  lpm_b    = (lpm_pb)      GlobalLock (hLpm_b);
 }    /* lpm_lock */

void lpm_unlock (void)
  /* расфиксация памяти  LPM */
 {if (!hLpm_b)
return;
  GlobalUnlock (hLpm_b);
  GlobalUnlock (hLpm_ibase);
  GlobalUnlock (hLpm_ips);
  GlobalUnlock (hLpm_type);
  GlobalUnlock (hLpm_icol);
  GlobalUnlock (hLpm_ibi);
  GlobalUnlock (hLpm_xk);
  GlobalUnlock (hLpm_x);
  GlobalUnlock (hLpm_upper);
 }    /* lpm_unlock */

int lpm_to_wnd (void)
 {MSG waitmsg;

  lpm_unlock ();
  while (PeekMessage (&waitmsg, NULL, 0, 0, PM_NOREMOVE))
   {if (!hLpm_b || waitmsg.message == WM_QUIT)
return (-8);
    else
     {if (PeekMessage (&waitmsg, NULL, 0, 0, PM_REMOVE))
       {TranslateMessage (&waitmsg);
	DispatchMessage (&waitmsg);
   } } }
  if (!hLpm_b)
return (-8);
  lpm_lock ();
return (0);
 }  /* lpm_to_wnd */

#define CHECK_FREE(x) if(hLpm_##x)\
		{GlobalFree(hLpm_##x); hLpm_##x = 0;}
#else
  lpm_type = (char *)   malloc (n);
  lpm_col_name = (name_table) malloc (n * 8);
  lpm_lower= (lpm_pfloat) malloc (n * sizeof (float));
  lpm_upper= (lpm_pfloat) malloc (n * sizeof (float));
  lpm_a    = (lpm_pdouble) malloc (n * sizeof (double));
  lpm_icol = (lpm_num *)malloc
		((n + 1) * sizeof (lpm_num));
  lpm_ibi  = (lpm_pibi)    malloc
		((lpm_space + 2) * sizeof (int));
  lpm_ibj  = lpm_ibi + l + 1;
  lpm_b    = (lpm_pb)      malloc
		((lpm_space + 2) * sizeof (double));
return ((lpm_b == NULL)? -5 : 0);
 }    /* lpm_col_mem */

int lpm_row_mem (int m /* число ограничений */)
/* выделение памяти для для массивов по числу ограничений */
 {lpm_ibase= (int *)    malloc (m * sizeof (int));
  lpm_ncol = (int *)    malloc (m * sizeof (int));
  lpm_nrow = (int *)    malloc (m * sizeof (int));
  lpm_iacol= (lpm_num *)malloc (m * sizeof (lpm_num));
  lpm_iarow= (lpm_num *)malloc ((m + 1)
			* sizeof (lpm_num));
  lpm_row_name = (name_table) malloc (m * 8);
  lpm_rhs  = (lpm_pfloat) malloc (m * sizeof (float));
  lpm_x    = (lpm_pdouble) malloc (m * sizeof (double));
  lpm_xk   = (lpm_pdouble) malloc (m * sizeof (double));
  lpm_ips  = (lpm_num *)malloc
		(((m * 3) + 1) * sizeof (lpm_num));
return ((lpm_ips == NULL || lpm_xk == NULL) ? -5 : 0);
 }    /* lpm_row_mem */

#define CHECK_FREE(x) if(lpm_##x != NULL)\
		{free(lpm_##x); lpm_##x = NULL;}
#endif

void lpm_free (void)
  /* освобождение памяти  LPM */
 {
#ifdef WINDOWS
  if (!hLpm_b)
#else
  if (lpm_b == NULL)
#endif
return;
  CHECK_FREE (b);
  CHECK_FREE (ibi);
  CHECK_FREE (icol);
  CHECK_FREE (a);
  CHECK_FREE (upper);
  CHECK_FREE (lower);
  CHECK_FREE (col_name);
  CHECK_FREE (type);

  CHECK_FREE (ips);
  CHECK_FREE (xk);
  CHECK_FREE (x);
  CHECK_FREE (rhs);
  CHECK_FREE (row_name);
  CHECK_FREE (iarow);
  CHECK_FREE (iacol);
  CHECK_FREE (nrow);
  CHECK_FREE (ncol);
  CHECK_FREE (ibase);
 }    /* lpm_free */

void lpm_init
 (lpm_num l /* длина матрицы преобразованной задачи */
 )
/* Преобразование переменных, */
/* установка icol и cmax , вычисление  a */
 {int n, j;
  char old_type, new_type;
  lpm_num ls;
  double z, z1;
  float b3;

  lpm_ipovt = 0;
  lpm_iter = 0;
  lpm_status = 0;
  lpm_dsol = 0;
#ifdef WINDOWS
  lpm_rhs  = (lpm_pfloat) GlobalLock (hLpm_rhs);
  lpm_lower= (lpm_pfloat) GlobalLock (hLpm_lower);
  lpm_a = (lpm_pdouble) GlobalLock (hLpm_a);
#endif
/* типы в процессе решения: */
/* 0x1 - неограниченный */
/* 0x2 - с обратным знаком */
/* 0x4 - ограниченный сверху */
/* 0x8 - не в базисе на верхней границе */
/* 0x10 - замороженный */
  n = -1;	/* номер столбца */
  lpm_cmax = 0.;
  j = 0;
  for (ls = 0; ls < l; ls++)
   {if (ls != 0)
      j = abs (lpm_ibi [ls]);
    if (j == 0)
     {if (ls != 0) lpm_a [n] = z1;
/* начало обработки столбца */
      z1 = 0.;	/* накопитель суммы столбца */
      lpm_icol [++n] = ls + 1;
      old_type = lpm_type [n];
      new_type = 0;
      if ((old_type & 0xe) == 0)
  continue;	/* тип x >= 0 или free */
      if ((old_type & 3) == 1
		|| (old_type & 0xc) == 4)
/* сменить знак переменной */
       {old_type = 0xa &
		((old_type >> 2) | ((old_type & 3) << 2));
	new_type |= 2;
	lpm_lower [n] = -lpm_upper [n];
       }
      if (old_type & 8)
       {lpm_upper [n] -= lpm_lower [n];
	new_type |= 4;
       }
      lpm_type [n] = new_type;
     }
    else
/* обработка элемента столбца */
     {z = lpm_b [ls];
      if (new_type & 2)
	lpm_b [ls] = z = -z;
      if (old_type & 2)
	lpm_rhs [j - 1] -= z * lpm_lower [n];
      z1 += z;
      b3 = fabs (z);
      if (rough(b3) < rough(lpm_EPS))
       {if (lpm_PRNT > 1)
	  fprintf (prn_file, "%s %d %d\n",
			lpm_inform(-14), j, n + 1);
       }
      else
	if (rough(b3) > rough(lpm_cmax)) lpm_cmax = b3;
   } }
  lpm_a [n] = z1;
  lpm_icol [++n] = l + 1;
#ifdef WINDOWS
  GlobalUnlock (hLpm_a);
  GlobalUnlock (hLpm_lower);
  GlobalUnlock (hLpm_rhs);
#endif
 }    /* lpm_init */

void lpm_objfun
 (float  *c,
  int    *objnums,
  int    n
 )
/* запись коэффициентов целевой функции */
 {int i;
  lpm_num ls;

  lpm_iold = 0;

  for (i = 0; i < n; i++)
   {ls = lpm_num_abs (lpm_icol [objnums [i]]) - 1;
    lpm_b [ls] = (lpm_type [i] & 2) ? -c [i] : c [i];
   }
 }    /* lpm_objfun */

int lpm_getsol
 (float  *x, /* массив для записи решения */
  int  *objnums,   /* номера по LP-модели */
   /* для записи на данное место в массив  x */
	      /* если NULL, то номера подряд */
  int n,
  int m
 )
/* получение решения */
 {int i, j, k;
  float b1;

#ifdef WINDOWS
  lpm_lower = (lpm_pfloat) GlobalLock (hLpm_lower);
#endif
  for (k = 0; k < n; k++) x [k] = 0.;
  for (i = 0; i < m; i++)
   {j = lpm_ibase [i];
    if (j <= 0)
     {b1 = lpm_x [i];
      if (rough(b1) < rough(lpm_EPSrhs))
  continue;
#ifdef WINDOWS
  GlobalUnlock (hLpm_lower);
#endif
return (-1);
     }
    if (objnums)
     {for (k = 0; k < n; k++)
	if (j == objnums [k])
      break;
     }
    else
      k = j - 1;
    if (k < n) x [k] = lpm_x [i];
   }
  for (k = 0; k < n; k++)
   {j = objnums ? objnums [k] - 1 : k;
    if (lpm_type [j] & 8) x [k] = lpm_upper [j];
    x [k] += lpm_lower [j];
    if (lpm_type [j] & 2) x [k] = -x [k];
   }
#ifdef WINDOWS
  GlobalUnlock (hLpm_lower);
#endif
return (0);
 }    /* lpm_getsol */

#include <string.h>

void lpm_read_basis (char* file_name, int m, int n)
 {FILE *fp;
  char str [6];
  int i, d, up, res, IOstatus;

  fp = fopen (file_name, "r");
  if (!fp)
return;
  fscanf (fp, "%5s", str);
  IOstatus = stricmp (str, "basis");
  if (!IOstatus)
   {for (i = 0; i < m; i++)
     {res = fscanf (fp, "%d", &d);
      if (res != 1 || d > n || d < - (n + 1))
       {IOstatus = -1;
    break;
   } } }
  up = 0;
  if (!IOstatus)
   {if (fscanf (fp, "%2s", str) == 1)
     {if (stricmp (str, "up"))
	IOstatus = -1;
      else
	up = 1;
   } }
  if (up)
   {while (1)
     {res = fscanf (fp, "%d", &d);
      if (res != 1)
    break;
      if (d > n || !(lpm_type [d - 1] & 4))
       {IOstatus = -1;
    break;
   } } }
  if (IOstatus)
   {fclose (fp);
return;
   }
  rewind (fp);
  fscanf (fp, "%5s", str);
  for (i = 0; i < m; i++)
   {fscanf (fp, "%d", &d);
    lpm_ibase [i] = d;
   }
  if (up)
   {fscanf (fp, "%2s", str);
    while (1)
     {res = fscanf (fp, "%d", &d);
      if (res != 1)
  break;
      lpm_type [d - 1] |= 8;
   } }
  fclose (fp);
 }  /* lpm_read_basis */

void lpm_write_basis (char* file_name, int m, int n)
 {FILE *fp;
  int i, up, d;

  fp = fopen (file_name, "w");
  if (!fp)
return;
  fprintf (fp, "basis\n");
  for (i = 0; i < m; i++)
   {d = lpm_ibase [i];
    if (d < 0) d = 0;
    fprintf (fp, "%d\n", d);
   }
  up = 0;
  for (i = 0; i < n; i++)
   {if (lpm_type [i] & 8)
     {if (!up)
       {fprintf (fp, "up\n");
	up = 1;
       }
      fprintf (fp, "%d\n", i + 1);
   } }
  fclose (fp);
 }  /* lpm_write_basis */
