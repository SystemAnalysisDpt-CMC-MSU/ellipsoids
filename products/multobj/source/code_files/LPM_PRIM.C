#include <math.h>
#include "lpm_var.def"

static int kbest;
static float zbest;

int lpm_primal
 (int m, /* число ограничений */
  int n, /* число переменных преобр. задачи */
  lpm_num l /* длина матрицы преобр. задачи */
 )
/* симплекс-метод */
 {int IOstatus, iold, ii, ir, i1, i21, i, j, k, err;
  int old_dir, new_dir;
  lpm_num l0, ls;
  lpm_pibi pibi;
  lpm_num *pnum;
  double z, z1, h, th, b2;
  float b1, b3, fmax, zm, xr, xrk, xm, shag, EPSbas;

  fmax = - 1024 * lpm_cmax;
  while (1)	/* цикл с пересчетом матрицы */
   {while (lpm_ipovt)	/* цикл без пересчета матрицы */
     {
#ifdef WINDOWS
      if (!lpm_WND)
ERR_RET (lpm_to_wnd());
#endif
/* решение двойственной системы */
      lpm_dinfea = 0;
      for (i = 0; i < m; i++)
       {ii = lpm_ibase [i];
	if (ii > 0)
	 {l0 = lpm_icol [ii];/* начало следующего столбца */
	  if (l0 < 0) l0 = -l0;
	  z = lpm_b [l0 - 1]; /* коэффициент функционала */
	 }
	else
	 {z = fmax;
	  lpm_dinfea = 1;
	 }
	lpm_xk [i] = z;
       }
      lpm_d = 0;
      lpm_solve ();
/* расчет оценок замещения */
      lpm_k = 0;	/* номер вводимого столбца */
      shag = 0.;
      EPSbas = 0.;
      iold = lpm_iold - 1;
      for (j = 0; j < n; j++)
       {if (j == iold)
      continue;
#ifdef WINDOWS
	if (lpm_WND)
ERR_RET (lpm_to_wnd());
#endif
	l0 = lpm_icol [j];
	if (lpm_type [j] & 0x10)
      continue;
	z = 0.;
	ls = lpm_num_abs (l0);
	while (1)	/* оценка замещения */
	 {ir = lpm_ibi [ls];
	  if (ir == 0)
	break;
	  if (ir < 0) ir = -ir;
	  lpm_subtr (&z, lpm_xk [ir - 1] * lpm_b [ls++]);
	 }
	z1 = (lpm_dinfea && l0 < 0 && z < -512)
		? fmax : -lpm_b [ls];
	lpm_subtr (&z, z1);
	if (l0 < 0)
	 {b3 = fabs (z);
	  if (rough(b3) > rough(EPSbas)) EPSbas = b3;
	 }
	else
	 {b1 = b3 = z;
	  if ((lpm_type [j] & 8)
		|| (lpm_type [j] & 1) && rough (b3) < 0)
	    b3 = -b3;
	  if(rough(b3) > rough(shag))
	   {shag = b3;
	    lpm_k = j + 1;
	    new_dir = (rough (b1) > 0);
	/* 1 - вводимая возрастает, 0 - убывает */
       } } }
      b3 = EPSbas;
      if (rough(b3) != 0)
	rough (b3) = rough(b3) rough_mult rough(lpm_EPSopt);
      if (lpm_k == 0 || rough(shag) <= rough(b3))
       {if ((lpm_dsol & 1) == 0) /* замороженных нет */
	 {lpm_status = 1;
return (1);				/* оптимум */
	 }
	for (j = 0; j < n; j++) lpm_type [j] &= 0xf;
	if (lpm_PRNT > 1)
	  fprintf (prn_file, "%s\n", lpm_inform(-12));
	if (lpm_dsol == 1)	/* пришлось взять */
	 {lpm_k = kbest;	/* малый гл.элемент */
	  lpm_dsol = 4;
	 }
	else
	 {lpm_dsol = 0;
    continue;
       } }
/* разложение вводимого столбца по базису */
      k = lpm_k - 1;
      for (i = 0; i < m; i++) lpm_xk [i] = 0;
      ls = lpm_icol [k];
      while (1)
       {ir = abs (lpm_ibi [ls]);
	if (ir == 0)
      break;
	lpm_xk [ir - 1] = lpm_b [ls++];
       }
      lpm_d = 1;
      lpm_solve ();
/* расчет номера столбца, выводимого из базиса */
      ir = -2; 	/* номер выводимого базисного столбца */
				/* счет от нуля */
      if (lpm_type [k] & 4)
/* переход на другую границу переменной, вводимой в базис */
       {ir = -1;
	xm = 1.;
	th = xr = lpm_upper [k];
       }
      else
       {xm = 0.;	/* max abs (xk [i]) */
	xr = 0.;	/* x [i] для выбранного */
       }
      xrk = xm;		/* xk [i] для выбранного */
      for (i = 0; i < m; i++)
       {i1 = lpm_ibase [i];
	if (i1 > 0 && (lpm_type [i1 - 1] & 1))
      continue;
	b1 = z = lpm_xk [i];
	if (!new_dir) b1 = -b1;
	zm = z = fabs (z);
	z1 = lpm_x [i];
	if (rough(zm) > rough(xm)) xm = zm;
	if (rough(b1) <= rough(lpm_EPSpiv))
	 {if (i1 > 0 && (lpm_type [i1 - 1] & 4))
	    z1 = lpm_upper [i1 - 1] - z1;
	  else
	continue;
	 }
	if (rough(zm) > rough(xrk))
		/* новое xk [i] лучше старого */
	 {b3 = xrk * (z1 / zm) - xr;
	  if (rough(b3) >= rough(lpm_EPSrhs))
      continue;
	 }
	else	/* новое xk [i] хуже старого */
	 {b3 = z * th - z1;
	  if (rough(b3) < rough(lpm_EPSrhs))
      continue;
	 }
	old_dir = (rough(b1) > 0);
	/* 1 - выводимая убывает, 0 - возрастает */
	ir = i;
	xrk = zm;
	xr = z1;
	th = z1 / z; /* величина минимального шага */
       }
      if (ir == -2)
return (-2);
      if (!new_dir)
	th = -th;
      if (lpm_dsol == 4)
	lpm_dsol = 0;
      else
       {b3 = xm;
	if (b3 != 0)
	  rough (b3) = rough (b3)
		rough_mult rough(lpm_ETMLu);
	if (rough(xrk) <= rough(b3))
	 {if (lpm_dsol == 0
		|| lpm_dsol == 1 && xrk > xm * zbest)
	   {kbest = lpm_k; /* лучший из малых гл.элементов */
	    zbest = xrk / xm;
	   }
	  lpm_dsol |= 1;	/* есть замороженные */
	  lpm_type [k] |= 0x10;
	  if (lpm_PRNT > 1)
	   {fprintf (prn_file, "%s, %d%s\n", lpm_inform(-6),
		lpm_k, lpm_inform(-11));
	    if (lpm_PRNT > 2)
	      fprintf (prn_file, "%s %g, %s %g\n",
		lpm_inform(-17), xrk, lpm_inform(-18), xm);
	   }
    continue;
       } }
      lpm_dsol |= 2; /* есть итерация с незамороженным */
/* проверка точности по суммарному уравнению */
      err = 0;
#ifdef WINDOWS
      lpm_a = (lpm_pdouble) GlobalLock (hLpm_a);
#endif
      z1 = lpm_a [k];
      for (i = 0; i < m; i++)
       {i1 = i21 = lpm_ibase [i];
	if (i21 < 0) i1 = -i21;
	i1--;
	z = lpm_xk [i];
	if (i1 == -1 || i1 == n) h = 1.;
	else
	 {h = lpm_a [i1];
	  if (i21 < 0 && (lpm_type [i1] & 8))
	    z -= lpm_upper [i1];
	 }
	if (i21 < 0) h = -h;
	lpm_subtr (&z1, z * h);
       }
#ifdef WINDOWS
      GlobalUnlock (hLpm_a);
#endif
      b3 = fabs (z1);
      if (lpm_dinfea == 0 && rough(b3) > rough(lpm_TOCHN))
	err = -3;
      ls = lpm_ips [lpm_nml];/* свободное место в матрице */
      if (ir != -1)
/* добавление нового мультипликатора */
       {if (ls >= lpm_space)/* а вдруг всего 1 элемент ! */
	  err = -10;
	z = lpm_xk [ir];	/* гл.элемент */
       }
      if (err)
       {if (lpm_PRNT > 1)
	  fprintf (prn_file, "%s\n", lpm_inform (err));
	lpm_nml = lpm_nips;
       }
      else
       {if (ir != -1)
	 {lpm_b [ls] = z;
	  lpm_ibi [ls] = ir + 1;
/* знач. для нового эл-та базиса */
	  lpm_x [ir] = th;
	  if (lpm_type [k] & 8)
	    lpm_x [ir] += lpm_upper [k];
	  lpm_xk [ir] = 0.; /* гл.элемент уже обработан */
	  for (i = 0; i < m; i++)
	   {b2 = lpm_xk[i];
	    b3 = fabs (b2);
	    if (rough(b3) <= rough(lpm_EPS))
	  continue;
	    if (++ls >= lpm_space)
	     {if (lpm_PRNT > 1)
		fprintf (prn_file, "%s\n", lpm_inform(-10));
	      lpm_nml = lpm_nips;
	  break;
	     }
	    lpm_b [ls] = b2;
	    lpm_ibi [ls] = i + 1;
	 } }
/* пересчет решения */
	for (i = 0; i < m; i++)
	  lpm_subtr (lpm_x + i, th * lpm_xk [i]);
       }
      lpm_type [k] &= 7;
      if (ir != -1)	/* счет lpm_iold от единицы */
       {lpm_iold = lpm_ibase [ir];
	lpm_ibase [ir] = lpm_k;
	if (!old_dir)
	  lpm_type [lpm_iold - 1] |= 8;
	else
	  if (lpm_iold > 0)
	    lpm_type [lpm_iold - 1] &= 7;
       }
      else
       {ls--;
	lpm_iold = lpm_k;
	if (new_dir)
	  lpm_type [k] |= 8;
       }
      lpm_iter++;
      if (lpm_PRNT >1)
/* расчет значения целевой функции */
       {h = 0.;
	for (i = 0; i < m; i++)
	 {ii = lpm_ibase [i];
	  if (ii <= 0)
	    b1 = fmax;
	  else
	   {l0 = lpm_icol [ii]; /* начало след.столбца */
	    if (l0 < 0) l0 = -l0;
	    b1 = lpm_b [l0 - 1];
	   }
	  lpm_subtr (&h, lpm_x [i] * b1);
	 }
	for (j = 0; j < n; j++)
	  if (lpm_type [j] & 8)
	   {l0 = lpm_icol [j + 1];
	    if (l0 < 0) l0 = -l0;
	    lpm_subtr (&h, lpm_upper[j] * lpm_b [l0 - 1]);
	   }
	fprintf (prn_file,"%8.2lG%10.4G%8.2G%10.4lG%10.4lG",
			     z1,   shag,EPSbas, z, -h);
	fprintf (prn_file, " %5d %5d %5d %5d %5d\n",
		lpm_k, lpm_iold, ir + 1, ls, lpm_iter);
       }
      if (ir == -1)
    continue;
      if (lpm_nml >= lpm_nips)
    break;
/* завершение формирования мультипликатора */
      lpm_ips [++lpm_nml] = ls + 1;
      pibi = lpm_ibi + ls;
      *pibi = - *pibi;
/* коррекция минус-пометок в icol */
      if (lpm_iold != 0)
       {i = abs (lpm_iold);
	pnum = lpm_icol + i - 1;
	lpm_abs (pnum, ls);
       }
      pnum = lpm_icol + k;
      *pnum = - *pnum;
      if (lpm_status == 2)
return (2);
     }  	/* конец цикла без пересчета матрицы */
/* стирание минус-пометок в icol */
    pnum = lpm_icol;
    for (j = 0; j < n; j++)
     {lpm_abs (pnum, ls);
      pnum++;
     }
/* стирание минус-пометок в матрице */
    for (j = 1; j <= n; j++)
     {pibi = lpm_ibi + lpm_icol [j] - 2;
      lpm_abs (pibi, i21);
     }

ERR_RET (lpm_lumult (m, n, l));

/* расчет первого решения */
#ifdef WINDOWS
    lpm_rhs = (lpm_pfloat) GlobalLock (hLpm_rhs);
#endif
    for (i = 0; i < m; i++) lpm_xk [i] = lpm_rhs [i];
#ifdef WINDOWS
    GlobalUnlock (hLpm_rhs);
#endif
/* учет небазисных на верхних границах */
    for (j = 0; j < n; j++)
      if (lpm_type [j] & 8)
       {l0 = lpm_icol [j];
	ls = lpm_num_abs (l0);
	while (1)
	 {ir = lpm_ibi [ls];
	  if (ir == 0)
	break;
	  lpm_subtr (lpm_xk + ir - 1,
		lpm_upper [j] * lpm_b [ls++]);
       } }
    lpm_d = 1;
    lpm_solve ();

    ir = 0;
    b1 = 0.;
/* обработка элементов решения вне границ */
    for (i = 0; i < m; i++)
     {z = -(lpm_x [i] = lpm_xk [i]);
      i1 = lpm_ibase [i];
      if (i1 > 0 && (lpm_type [i1 - 1] & 1))
    continue;
      b3 = z;
      if (rough(b3) <= rough(lpm_EPSrhs))
       {if (i1 > 0 && (lpm_type [i1 - 1] & 4))
	 {b3 = z = -z - lpm_upper [i1 - 1];
	  if (rough(b3) <= rough(lpm_EPSrhs))
    continue;
	  else
	    lpm_type [i1 - 1] |= 8;
	 }
	else
    continue;
       }
      else
       {l0 = lpm_ips [lpm_nml];
	 /*  nml - число активных мультипликаторов  */
	 /* ips [nml] - свободная позиция в матрице */
	if (l0 > lpm_space)
return (-5);
	lpm_b [l0] = -1;
	lpm_ibi [l0] = - (i + 1);
	lpm_ips [++lpm_nml] = l0 + 1;
       }
      lpm_x [i] = z;
      if (i1 == 0) i1 = n + 1;
      lpm_ibase [i] = -i1;
      if (rough(b3) > rough(b1))
       {b1 = b3;
	ir = i + 1;
     } }
    lpm_dinfea = (ir != 0);
    if (lpm_dinfea && lpm_PRNT > 1)
      fprintf (prn_file, "%s %g %s %d\n",
		lpm_inform(-13), b1, lpm_inform(-19), ir);
/* минус-пометки базисных столбцов в icol */
    for (i = 0; i < m; i++)
     {i21 = lpm_ibase [i];
      if (i21 == 0 || i21 == - (n + 1))
    continue;
      if (i21 < 0) i21 = -i21;
      pnum = lpm_icol + i21 - 1;
      *pnum = - *pnum;
     }
    if (lpm_PRNT > 1)
      fprintf (prn_file, "%s\n", lpm_inform(-21));
    if (lpm_status == 2)
return (2);
   }	/* конец цикла с пересчетом матрицы */
 }  /* lpm_primal */
