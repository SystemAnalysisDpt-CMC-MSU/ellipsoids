#include <math.h>
#include "lpm_var.def"

#define THR_PAR 0.1
#define THR_MIN 0.001
#define COEF 100
#define MIN_EPS 1.e-6
/* abs (w) > THR_PAR - паретовские, w - вес */
/* abs (w) < THR_PAR - непаретовские, знак несущественен */
/* при abs (w) > THR_MIN - вес = w * COEF */

static int nonpar;

void rfp_size
 (int ch_N,	      /* число критериев */
  int *pdm,	/* число доп.ограничений */
  int *pdn,	 /* число доп.переменных */
  lpm_num *pdl,	    /* доп.длина матрицы */
  float *w	       /* веса критериев */
 )
/* выяснение размеров задачи rfp */
/*  по размерам исходной задачи  */
 {int i;

  nonpar = 0;
  for (i = 0; i < ch_N; i++)
    if (fabs (w [i]) < THR_PAR) nonpar++;
  lpm_auxrfp = (nonpar != 0) + (nonpar != ch_N);
  *pdm = ch_N + nonpar;
  *pdl = 4 * ch_N + 4 * nonpar + lpm_auxrfp;
  *pdn = ch_N + nonpar + lpm_auxrfp;
 }    /* rfp_size */

void rfp_set
 (int ch_N,
  int *objnums,
  float  *x,
  float *w,
  double eps,
  int m,
  int n
 )
/* запись точки в матрицу */
 {int i, j, k, m0, n0;
  lpm_num l0;
  float ww, wwm;
  double s;
  lpm_pfloat prhs;

  m0 = m - (ch_N + nonpar);
  n0 = n - (ch_N + nonpar + lpm_auxrfp);
  prhs = m0 +
#ifdef WINDOWS
	(lpm_pfloat) GlobalLock (hLpm_rhs);
  lpm_a = (lpm_pdouble) GlobalLock (hLpm_a);
  lpm_lower = (lpm_pfloat) GlobalLock (hLpm_lower);
#else
	lpm_rhs;
#endif
/* цикл по критериальным столбцам */
  for (j = 0; j < ch_N; j++)
   {k = objnums [j] - 1;
    l0 = lpm_num_abs (lpm_icol [k]);
				/* начало столбца */
    ww = w [j];
    wwm = fabs (ww);
    if (wwm < THR_PAR)
      ww = (ww < THR_MIN) ? 1 : (COEF * wwm);
    s = 0.;
    while (1)
     {i = lpm_ibi [l0]; /* номер строки, счет от единицы */
      if (i == 0)
    break;
      if (i < 0) i = -i;
      if (i > m0) lpm_b [l0] = ww;
      s += lpm_b [l0++]; /* основная строка */
     }
    if (fabs (w [j]) > THR_PAR)
      lpm_b [l0] = ww * eps; /* целевая функция */
    lpm_a [k] = s;
    if (wwm > lpm_cmax) lpm_cmax = wwm;
/* правые части */
    s = x [j];
    if (lpm_type [k] & 0x2) s = -s;
    s -= lpm_lower [k];
    for (i = 0; i <= (wwm < THR_PAR); i++)
      *(prhs++) = s * ww;
   }
#ifdef WINDOWS
  GlobalUnlock (hLpm_lower);
  GlobalUnlock (hLpm_a);
  GlobalUnlock (hLpm_rhs);
#endif
/* целевая функция для вспомогательной непаретовских */
  if (nonpar)
   {l0 = lpm_num_abs (lpm_icol [n0 + 1]) - 1;
    lpm_b [l0] = -1 / ((eps > MIN_EPS) ? eps : MIN_EPS);
   }
/* правые части */
  lpm_ipovt = 0;
  lpm_iold = 0;
 }    /* rfp_set */

void rfp_shift
 (int m,    /* число ограничений исходной задачи */
  int n,     /* число переменных исходной задачи */
  lpm_num l,    /* длина матрицы исходной задачи */
  int ch_N, /* число критериев */
  int  *objnums, /* номера критериальных переменных */
  float *w  /* веса критериев */
 )
/* раздвижка матрицы LPM для работы c rfp */
/* память должна быть выделена заранее с избытком */
 {int i, i0, i21, j, shift, row, add;
  lpm_num  l1;
  lpm_pibi pibi;
  double t;

  shift =  ch_N + nonpar;
/* сдвиг всей матрицы вперед */
  for (l1 = l; l1 > 0; l1--)
   {lpm_b [l1 + shift] = lpm_b [l1];
    lpm_ibi [l1 + shift] = lpm_ibi [l1];
   }
  for (i = 1; i <= n; i++)
    lpm_icol [i] += shift;
  l1 = 1;      /* куда */
  j = 0;      /* номер столбца */
  while (shift)
   {i0 = abs (lpm_ibi [l1 + shift]);
    if (i0 == 0)
     {j++;
      row = m + 1;
      for (i0 = 0; i0 < ch_N; i0++)
       {if (objnums [i0] == j)
      break;
	if (fabs (w [i0]) < THR_PAR) row++;
	row++;
       }
      if (i0 != ch_N)
/* вставка доп. строк */
       {lpm_b [l1 + shift] = 0.;
	pibi = lpm_ibi + l1 - 1;
	lpm_abs (pibi, i21);
	if (fabs (w [i0]) < THR_PAR)
	 {lpm_b [l1] = 1.;
	  lpm_ibi [l1++] = row++;
	  shift--;
	 }
	lpm_b [l1] = 1.;
	lpm_ibi [l1++] = row;
	shift--;
       }
      lpm_icol [j] -= shift;
     }
    lpm_b [l1] = lpm_b [l1 + shift];
    lpm_ibi [l1] = lpm_ibi [l1 + shift];
    l1++;
   }
/* столбцы вспомогательных переменных */
#ifdef WINDOWS
  lpm_lower = (lpm_pfloat) GlobalLock (hLpm_lower);
#endif
  l += ch_N + nonpar;
  for (j = 0; j <= 1; j++)
   {row = m;
    add = 0;
    for (i = 0; i < ch_N; i++)
     {++row;
      if ((fabs (w [i]) < THR_PAR) == j)
    continue;
      add++;
      lpm_b [++l] = 1;
      lpm_ibi [l] = row;
      if (fabs (w [i]) < THR_PAR)
       {lpm_b [++l] = -1.;
	lpm_ibi [l] = ++row;
       }
     }
    if (add)
     {lpm_b [++l] = -1.;
      lpm_ibi [l] = 0;
      lpm_a [n] = j ? add : 0;
      lpm_type [n] = j;
      lpm_lower [n] = 0.;
      lpm_icol [++n] = l + 1;
     }
   }
/* добавление логических переменых */
  for (i = 0; i < ch_N; i++)
   {for (j = 0; j <= (fabs (w [i]) < THR_PAR); j++)
     {t = j ? 1. : -1.;
      lpm_type [n] = 0;
      lpm_lower[n] = 0.;
      lpm_a    [n] = t;
      lpm_ibase [m] = ++n;
      lpm_b [++l] = t;
      lpm_ibi [l] = ++m;
      lpm_b [++l] = 0.;
      lpm_ibi [l] = 0;
      lpm_icol [n] = l + 1;
     }
   }
#ifdef WINDOWS
  GlobalUnlock (hLpm_lower);
#endif
  lpm_iter = 0;
  lpm_status = 0;
  lpm_dsol = 0;
 }    /* rfp_shift */
/* Структура задачи RFP:
основные перем.║дополн.  логические RHS
┌непарето──────╫────┬fr┐ ┌──┬──┬──┐ ┌──┐
│   │w│        ║  1 │  │ │-1│  │  │ │wx│
├───┼─┼────────╫────┼──┤ ├──┼──┼──┤ ├──┤
│   │w│        ║ -1 │  │ │  │ 1│  │ │wx│
└───┴─┴────────╨────┴──┘ └──┴──┴──┘ └──┘
┌парето──┬──┬──╥────┬──┐ ┌──┬──┬──┐ ┌──┐
│        │ w│  ║    │ 1│ │  │  │-1│ │wx│
└────────┴──┴──╨────┴──┘ └──┴──┴──┘ └──┘
┌целевая функция────┬──┐
│        │we│  ║-1/e│-1│
└────────┴──┴──╨────┴──┘
w - веса критериев
e - малый параметр для избежания слабо-паретовских
x - базовая точка */
