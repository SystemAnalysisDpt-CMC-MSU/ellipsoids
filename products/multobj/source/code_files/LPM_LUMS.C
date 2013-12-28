#include <math.h>
#include "lpm_var.def"

int lpm_lumult
 (int m, /* число ограничений */
  int n, /* число переменных преобр.задачи */
  lpm_num l /* длина матрицы преобр.задачи */
 )
/* мультипликативное разложение базисной матрицы */
 {int i, i1, i2, i21, ir, is, j, jj, j2, jis;
  int k, k1, il, nk, nr, it, itb, iun, nml;
  int  *pnum;
  lpm_num l0, l1, ls, nuel, r1, rs;
  lpm_pibi pibi;
  double u;
  float b2, b3, z, zm, xm;
#ifdef WINDOWS
  int IOstatus;

  if (!lpm_WND)
ERR_RET (lpm_to_wnd ());
  lpm_ncol = (int *) GlobalLock (hLpm_ncol);
  lpm_nrow = (int *) GlobalLock (hLpm_nrow);
#endif
  for (i = 0; i < m; i++)
   {lpm_ncol [i] = 0;
    lpm_nrow [i] = 0;
   }
  it  = 0;  /* счетчик элементов треугольной матрицы */
  il  = 0;  /* счетчик базисных столбцов */
  itb = 0;  /* счетчик элементов базисной матрицы */
#ifdef WINDOWS
  lpm_iacol = (lpm_num *) GlobalLock (hLpm_iacol);
#endif
  for (i = 0; i < m; i++)
   {ir = lpm_ibase [i];
/*    if (ir == 0)    исправлено 24.04.96 */
    if (ir == 0 || ir == -(n + 1))    
     {lpm_nrow [i] -= 0x4000;/* пустые места в исх.базисе */
  continue;
     }
    if (ir < 0) ir = -ir;
    l0 = lpm_icol [ir - 1];	/* начало столбца */
    l1 = lpm_icol [ir] - 2;	/* конец столбца */
    lpm_iacol [il] = l0; /* позиции начал столбцов базиса */
/* подсчет числа элементов базисной матрицы */
    for (ls = l0; ls <= l1; ls++)
     {lpm_ncol [il]++;		/* в столбцах */
      itb++;			/* всего */
      i21 = lpm_ibi [ls];
      k = abs (i21) - 1;
      lpm_nrow [k]++;		/* в строках */
     }
    if (i != il) lpm_ibase [i] = 0;
    lpm_ibase [il] = ir;	/* уплотнение ibase */
    il++;
   }
  if ((unsigned int)(itb + l) > lpm_space)
   {
#ifdef WINDOWS
    GlobalUnlock (hLpm_iacol);
    GlobalUnlock (hLpm_nrow);
    GlobalUnlock (hLpm_ncol);
#endif
return (-5);
   }
/* расчет транспонированной матрицы */
  lpm_ips [0] = 0;	/* в ibj весь счет от нуля */
#ifdef WINDOWS
  lpm_iarow = (lpm_num *) GlobalLock (hLpm_iarow);
#endif
  lpm_iarow [0] = 0;
/* позиции начал строк транспонированной матрицы */
  for (i = 1; i <= m; i++)
   {j = lpm_nrow [i - 1];
    if (j < 0) j += 0x4000;
    lpm_ips [i] = lpm_ips [i - 1] + j;
    lpm_iarow [i] = lpm_ips [i];
   }
  for (j = 0; j < il; j++) /* цикл по базисным столбцам */
   {ls = lpm_iacol [j];
    while (1)
     {ir = lpm_ibi [ls];	/* номер строки */
      if (ir == 0)
    break;     /* кончился столбец */
      if (ir < 0) ir = -ir;
      ir--;
      l0 = lpm_ips [ir];
      lpm_ibj [l0] = j;  /* запись номера столбца */
      lpm_ips [ir]++;	/* текущая позиция строки в ibj */
      ls++;
   } }
  for (i = 0; i < lpm_nips; i++) lpm_ips [i] = 0;
  nk = 0;		/* счетчик спайков */
  nr = 0;		/* счетчик треугольных */
  while (nr + nk < il) /* цикл разбора на треуг. и спайки */
   {while (1)	/* цикл занесения столбцов в спайки */
     {
#ifdef WINDOWS
      if (lpm_WND)
       {GlobalUnlock (hLpm_iarow);
	GlobalUnlock (hLpm_iacol);
	GlobalUnlock (hLpm_nrow);
	GlobalUnlock (hLpm_ncol);
ERR_RET (lpm_to_wnd ());
	lpm_ncol = (int *) GlobalLock (hLpm_ncol);
	lpm_nrow = (int *) GlobalLock (hLpm_nrow);
	lpm_iacol = (lpm_num *) GlobalLock (hLpm_iacol);
	lpm_iarow = (lpm_num *) GlobalLock (hLpm_iarow);
       }
#endif
/* поиск минимального числа элементов в строке */
      ir = 0;
      is = 0x4000;
      for (i = 0; i < m; i++)
       {jis = lpm_nrow [i];
	if (jis > 0 && jis < is)
	 {ir = i + 1;	/* строка, счет от единицы */
	  is = jis;	/* число элементов */
	  if (is == 1)
      break; /* есть строка с одним элементом */
       } }
      if (is == 1 || ir == 0)
    break;
/* в каком базисном столбце, пересекающемся со строкой */
/* длины is, число элементов максимально */
      k1 = 0;
      k = -1;
      for (j = 0; j < il; j++)
       {i = lpm_ncol [j];
	if (i == 0 || i < k1)
      continue;
	ls = lpm_iacol [j];
	xm = 0.;	/* max среди строк длины is */
	j2 = 0;
	while (1)   /* поросмотр j-го базисного столбца */
	 {i1 = lpm_ibi [ls];
	  if (i1 == 0)
	break;
	  if (lpm_nrow [i1 - 1] == is)
	   {j2 = 1;   /* этот столбец - кандидат в спайки */
	    zm = fabs (lpm_b [ls]);
	    if (rough(zm) > rough(xm)) xm = zm;
	    if (i != k1)
	     {k1 = i;	/* число элементов */
	      k = j;/* номер базисн.столбца, счет от нуля */
	   } }
	  ls++;
	 }
	if (k == j || j2 && rough(xm) < rough(z))
	 {z = xm;
	  k = j;
       } }
/* столбец k заносится в спайк */
      lpm_ncol [k] = 0;
      nk++;
/* заносим номера столбцов-спайков в ips с (m-1)-го назад */
      lpm_ips [m - nk] = k;	/* счет столбцов от нуля */
/* элементы включенного столбца снимаем с учета в nrow */
      ir = 0;
      ls = lpm_iacol [k];
      while (1)
       {i = lpm_ibi [ls];
	if (i == 0)
      break;
	pnum = lpm_nrow + i - 1;
	if (*pnum > 0) (*pnum)--;
	if (*pnum == 1) ir = i;  /* появилась строка ir */
	ls++;	  /* с одним элементом, счет от единицы */
       }
      if (ir != 0)
    break;
     }  	/* конец цикла спайков */
    if (ir == 0)
  break;
/* цикл занесения столбцов в треугольные */
    while (1)	/* ir - номер строки, отсчет от единицы */
     {
#ifdef WINDOWS
      if (lpm_WND)
       {GlobalUnlock (hLpm_iarow);
	GlobalUnlock (hLpm_iacol);
	GlobalUnlock (hLpm_nrow);
	GlobalUnlock (hLpm_ncol);
ERR_RET (lpm_to_wnd ());
	lpm_ncol = (int *) GlobalLock (hLpm_ncol);
	lpm_nrow = (int *) GlobalLock (hLpm_nrow);
	lpm_iacol = (lpm_num *) GlobalLock (hLpm_iacol);
	lpm_iarow = (lpm_num *) GlobalLock (hLpm_iarow);
       }
#endif
      rs = lpm_iarow [ir - 1]; /* начало строки  в ibj */
      r1 = lpm_iarow [ir];    /* начало следующей строки */
/* поиск в ir-й строке столбца ненулевой длины */
      while (1)
       {i = lpm_ibj [rs];    /* номер базисного столбца */
	k1 = lpm_ncol [i]; /* число элементов в столбце */
	if (k1 > 0)
	 {k = i; /* найденный базисный столбец, */
      break;			/* счет от нуля */
	 }
	rs++;
	if (rs >= r1)	/* не нашли ни одного столбца */
	 {
#ifdef WINDOWS
	  GlobalUnlock (hLpm_iarow);
	  GlobalUnlock (hLpm_iacol);
	  GlobalUnlock (hLpm_nrow);
	  GlobalUnlock (hLpm_ncol);
#endif
return (-8);  /* в ir-й строке */
       } }
      lpm_ncol [k] = 0;
      l0 = ls = lpm_iacol [k];/* начало столбца в матрице */
      xm = 0.;		/* max по столбцу */
      z = lpm_EPSpiv; /* max по кандидатам в гл.элементы */
      is = 0;		/* гл.строка для следующего шага */
      ir = 0;	   /* ищем гл.строку среди всех nrow = 1 */
      while (1)     /* просмотр нового базисного столбца */
       {i = lpm_ibi [ls];
	if (i == 0)
      break;
	zm = fabs (lpm_b [ls]);
	if (rough(zm) > rough(xm)) xm = zm;
	pnum = lpm_nrow + i - 1;
	if (*pnum > 0)
	 {if (*pnum == 1 && rough (zm) > rough (z))
	   {z = zm;
	    ir = i;  /* кандидат в гл.элементы */
	    l1 = ls;  /* его место в матрице */
	   }
	  (*pnum)--;  /* снимаем с учета в nrow */
	  if (*pnum == 1) is = i; /* появилась строка  */
	 }			  /* с одним элементом */
	ls++;
       }	/* конец цикла нового базисного столбца */
      if (ir == 0)
       {
#ifdef WINDOWS
	GlobalUnlock (hLpm_iarow);
	GlobalUnlock (hLpm_iacol);
	GlobalUnlock (hLpm_nrow);
	GlobalUnlock (hLpm_ncol);
#endif
return (-7);
       }
      if (rough(xm) != 0)
	rough(xm) = rough(lpm_ETMLt) rough_mult rough(xm);
      if (rough(z) <= rough(xm)) /* мал гл.элемент */
       {nk++;	   /* включить столбец в спайки */
	lpm_ips [m - nk] = k;
    break;
       }
/* теперь базисный столбец хороший */
      it += k1;
      u = lpm_b [l1];	/* главный элемент */
      lpm_nrow [ir - 1] = -lpm_ibase [k];  /* настоящий */
			/* номер k-го базисного столбца */
      if (k1 == 1)	/* в столбце всего один элемент */
       {b3 = fabs (u - 1.0);	  /* и он равен единице */
	if (rough(b3) <= rough(lpm_EPSrel))
	 {if (lpm_PRNT > 2) fprintf(prn_file, "        *1");
	  nr++;
    break;
       } }
      else  /* перенос главного элемента в начало столбца */
       {if (l0 != l1)
	 {lpm_b [l1] = lpm_b[l0];
	  lpm_ibi [l1] = lpm_ibi[l0];
	  lpm_b [l0] = u;
	  lpm_ibi [l0] = ir;
       } }
      lpm_ips [nr++] = l0;	 /* включаем столбец */
				/* в мультипликаторы */
/* минус-пометка в конце мультипликатора */
      pibi = lpm_ibi + ls - 1;
      *pibi = - *pibi;
      if (lpm_PRNT > 2) fprintf (prn_file, " %9g", u);
      if (is == 0)
    break;
      ir = is;
     }			/* конец цикла треугольных */
   }	/* конец цикла разбора на треугольные и спайки */
#ifdef WINDOWS
  GlobalUnlock (hLpm_iarow);
  GlobalUnlock (hLpm_iacol);
#endif
  lpm_ipovt++;
  if (lpm_PRNT > 1)
   {if (lpm_PRNT > 2) fprintf (prn_file, "\n");
    fprintf (prn_file, "%s\n  %6d %6d %6d %6d %6d\n",
	lpm_inform (-20),lpm_ipovt,il, nk,itb, it);
   }
  nuel = l;	/* последнее занятое место в матрице */
  nml = m + nk; /* свободный ips после окончания всего */
  iun = nml;	/* ips для U-мультипликаторов */
  while (nk) /* цикл разрешения спайков */
   {
#ifdef WINDOWS
    if (lpm_WND)
     {GlobalUnlock (hLpm_nrow);
      GlobalUnlock (hLpm_ncol);
ERR_RET (lpm_to_wnd ());
      lpm_ncol = (int *) GlobalLock (hLpm_ncol);
      lpm_nrow = (int *) GlobalLock (hLpm_nrow);
     }
#endif
    i21 = m - nk;	/* забираем спайк из стека */
    k = lpm_ips [i21];	  /* номер спайка в базисе */
    lpm_ips [i21] = 0;
    nk--;
    jj = lpm_ibase [k] - 1;
    ls = lpm_icol [jj];    /* начало спайка в матрице */
/* запись спайка в xk */
    for (i = 0; i < m; i++) lpm_xk [i] = 0.;
    while (1)
     {i1 = lpm_ibi [ls];
      if (i1 == 0)
    break;
      lpm_xk [i1 - 1] = lpm_b [ls];
      ls++;
     }
/* разложение спайка по базису */
    lpm_nml = nr;
    lpm_d = 1;
    lpm_solve ();
    nuel++;
    i1 = 0;
    ir = 0;	/* номер гл.строки */
    xm = 0.;	/* max abs (xk [i]) */
    z = 0.;	/* abs (гл.элемента) */
    l0 = nuel; /* место для единицы в начале U-мульт-ра */
    for (i = 0; i < m; i++)
     {b2 = fabs (lpm_xk [i]);
      if (rough(b2) <= rough(lpm_EPS))
    continue;
      if (rough(b2) > rough(xm)) xm = b2;
      if (lpm_nrow [i] >= 0)
/* вакантное место в базисе: */
/* запоминание L-мультипликатора в xk и ncol */
       {lpm_xk [i1] = lpm_xk [i];  /* b - в начало xk */
	lpm_ncol [i1] = i + 1;   /* ibi - в начало ncol */
	if (rough(b2) > rough(z))
	 {i2 = i1;	/* место гл.элемента в xk, ncol */
	  z = b2;	/* abs (гл.элемента) */
	  ir = i + 1;	/* гл.строка, счет от единицы */
	  u = lpm_xk [i];  /* гл.элемент */
	 }
	i1++;
       }
      else
/* не вакантное место в базисе: */
/* заполнение U-мультипликатора */
       {nuel++;
	if (nuel > lpm_space)
	 {
#ifdef WINDOWS
	  GlobalUnlock (hLpm_nrow);
	  GlobalUnlock (hLpm_ncol);
#endif
return (-5);
	 }
	lpm_b [nuel] = lpm_xk [i];
	lpm_ibi [nuel] = i + 1;
     } }
    if (rough(xm) != 0)
      rough(xm) = rough(lpm_ETMLs) rough_mult rough(xm);
    if (rough (z) <= rough(xm))
      ir = 0;		/* гл.элемент мал */
    if (ir == 0)	/* L-мультипликатор пуст */
/* эти L- и U-мультипликаторы уничтожить */
     {nuel = l0 - 1;
      if (lpm_PRNT > 2) fprintf (prn_file, lpm_inform(-16));
  continue;
     }
    if (lpm_PRNT > 2) fprintf (prn_file, " %9g", u);
    lpm_b [l0] = 1.;	/* гл.элемент U-мультипликатора */
    lpm_ibi [l0] = ir;
    lpm_ips [--iun] = l0;	/* U-мультипликатор */
    pibi = lpm_ibi + nuel; /* минус-пометка в конце */
    *pibi = - *pibi;	   /*    мультипликатора    */
/* заполнение L-мультипликатора */
    lpm_ips [nr++] = nuel + 1;	/* L-мультипликатор */
    if (i2 != 0)
/* перенос гл.элемента в начало xk, ncol */
     {lpm_xk [i2]   = lpm_xk [0];
      lpm_ncol [i2] = lpm_ncol [0];
      lpm_xk [0]   = u;
      lpm_ncol [0] = ir;
     }
    pnum = lpm_ncol + i1 - 1; /* минус-пометка в конце */
    *pnum = - *pnum;	      /*    мультипликатора    */
    for (i = 0; i < i1; i++)
     {nuel++;
      if (nuel > lpm_space)
       {
#ifdef WINDOWS
	GlobalUnlock (hLpm_nrow);
	GlobalUnlock (hLpm_ncol);
#endif
return (-5);
       }
      lpm_b [nuel] = lpm_xk [i];
      lpm_ibi [nuel] = lpm_ncol [i];
     }
    lpm_nrow [ir - 1] = -lpm_ibase [k];/* настоящий номер */
				/* k-го базисного столбца */
   }			/* конец цикла разрешения спайков */
#ifdef WINDOWS
  GlobalUnlock (hLpm_ncol);
#endif
  lpm_nml = nml;
  lpm_ibase [m - 1] = 0; /* признак переделывания базиса */
  for (i = 0; i < m; i++)
   {ir = -lpm_nrow [i];
    lpm_ibase [i] = (ir <= 0 || ir > n) ? 0 : ir;
   }
#ifdef WINDOWS
  GlobalUnlock (hLpm_nrow);
#endif
  lpm_ips [lpm_nml] = nuel + 1;
  if (lpm_PRNT > 2) fprintf (prn_file, "\n");
return (0);
 }    /* lpm_lumult */

void lpm_solve (void)
/* решение системы линейных уравнений на основе */
/* мультипликативного представления матрицы */
 {double u, u1;
  int l, i, ir, ir1;
  lpm_num ls;
  lpm_num  *pips;

  if (lpm_d) pips = lpm_ips;
  else pips = lpm_ips + lpm_nml - 1;

  for (l = 0; l < lpm_nml; l++)
   {ls = *pips;   /* начало мультипликатора в матрице */
    if (lpm_d) pips++;
    else pips--;
    if (ls == 0)
  continue;
    ir1 = lpm_ibi [ls];
    ir = abs (ir1) - 1;/* номер гл.строки, счет от нуля */
    u = lpm_b [ls];
    u1 = lpm_xk [ir];
    if (lpm_d)
/* решение прямой системы */
     {u1 /= u;
      lpm_xk [ir] = u1;
      while (ir1 > 0)
       {ir1 = lpm_ibi [++ls];
	i = abs (ir1) - 1;
	lpm_subtr (lpm_xk + i, u1 * lpm_b [ls]);
     } }
    else
/* решение двойственной системы */
     {while (ir1 > 0)
       {ir1 = lpm_ibi [++ls];
	i = abs (ir1) - 1;
	lpm_subtr (&u1, lpm_xk [i] * lpm_b [ls]);
       }
      lpm_xk [ir] = u1 / u;
   } }
 }    /* lpm_solve */

void lpm_subtr (lpm_pdouble s, double x)
/* добавление члена  x  к сумме  *s */
 {float z, z1;
  z  = fabs (*s);
  z1 = fabs (*s -= x);
  if (rough (z) != 0)
    rough (z) = rough(z) rough_mult rough(lpm_EPSrel);
  if (rough(z1) <= rough(z)) *s = 0.;
 }    /* lpm_subtr */
