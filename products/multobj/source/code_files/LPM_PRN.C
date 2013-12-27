extern int lpm_LNG;

char *lpm_inform (int no)
/* выдача сообщения по номеру */
 {static char *inform [2][21] = {
   {"Hет решения",			 /* -1 */
    "Решение неограничено",		 /* -2 */
    "Уход по точности", 		 /* -3 */
    "Все возможные главные элеметы малы",/* -4 */
    "Мало памяти",			 /* -5 */
    "Мал главный элемент",		 /* -6 */
    "Авария, не нашли главного элемента",/* -7 */
    "Авария",				 /* -8 */
    "Недопустимый тип строки",  	 /* -9 */
    "Нет места",			 /*-10 */
    "-й столбец замораживается",	 /*-11 */
    "Столбцы размораживаются",  	 /*-12 */
    "Недопустимость. Мах невязка",	 /*-13 */
    "Нулевой элемент",  		 /*-14 */
    "- строка", 			 /*-15 */
    "  выброшен",			 /*-16 */
    "гл.элем",  			 /*-17 */
    "max.элем", 			 /*-18 */
    "в строке", 			 /*-19 */
    "пересчет столбцы спайки  матр  треуг",
    "точность    оценка  оц.баз  вед.элем  цел.функ\
  вход выход гл.стр поле  итер"
   },
   {"LP-problem is infeasible", 	/* -1 */
    "LP-problem is unbounded",  	/* -2 */
    "Insufficient precision",		/* -3 */
    "All possible pivots are too small",/* -4 */
    "Not enough memory",		/* -5 */
    "Too small pivot",  		/* -6 */
    "Damage, pivot not found",  	/* -7 */
    "Damage",				/* -8 */
    "Wrong type of row",		/* -9 */
    "No room",  			/*-10 */
    "-th column is frozen",		/*-11 */
    "Columns are unfrozen",		/*-12 */
    "Infeasibility. Max discrepancy",   /*-13 */
    "Zero element",			/*-14 */
    "- row",				/*-15 */
    "  rejected",			/*-16 */
    "pivot",				/*-17 */
    "max in column",			/*-18 */
    "in row",				/*-19 */
    "factorzn columns spikes  matr triang",
    "precision  maxrcst basrcst     pivot objective\
    in   out pivrow room  iter"
   }};
return (inform [lpm_LNG] [-(1 + no)]);
 }    /* ch_inform */
