#include <conio.h>

extern int ch_LNG;
extern float ch_max_all_est;
extern int ch_facetCOUNT, ch_topCOUNT, ch_estCOUNT;
extern int ch_estTOTAL, ch_facetTOTAL;

char *ch_inform (int);

void ch_inf_print (signes)
  /* information print */
unsigned int signes;
 {static unsigned int unit = 040;
  static int pospr[] = {1,18,26,34,42,50};
  static int *adrpr[] =
   {&ch_facetCOUNT,
    &ch_topCOUNT,
    &ch_estCOUNT,
    &ch_estTOTAL,
    &ch_facetTOTAL
   };
  int y;
  int i,new_line;

  if (!signes)  /* title print  */
   {////window (1, 1, 80, 1);
    //////clrscr ();
    //gotoxy (4, 1);
    //textcolor (3);
    printf (ch_inform (-9));
    ////window (1, 2, 80, 25);
   }
  else
   {if (signes == 077)
     {//textcolor (7);
      new_line = 1;
     }
    else
     {//textcolor (4);
      new_line = 0;
     }
    //y = wherey ();
    for (i = 0; i < 6; i++)
     {if (signes & unit)
       {//gotoxy (pospr [i], y);
	if(i)
	  printf ("%5d", *adrpr [i-1]);
	else
	  printf ("%#14.7G", ch_max_all_est);
       }
      signes <<= 1;
     }
    if (new_line)
     {printf ("\n\r");
      ////clreol ();
     }
   }
 }    /* ch_inf_print */

char *ch_inform (IOstatus)
  /* message for number */
int IOstatus;
 {static char *inform [2][9] = {
   {"Ž–…‘‘ ŽŠŽ—…",          /* -1 */
    "‚‘… ‘„…‹€Ž",              /* -2 */
    "’Ž—Ž‘’œ …„Ž‘’€’Ž—€",    /* -3 */
    "‚…˜ˆ€ ‚“’ˆ ŒŽ†…‘’‚€", /* -4 */
    "Œ€‹Ž €ŒŸ’ˆ",              /* -5 */
    "ŒŽ†…‘’‚Ž … ’…‹…‘Ž",     /* -6 */
    "…›‚€ˆ…",               /* -7 */
    "…’ …‡“‹œ’€’€",           /* -8 */
    "â®ç­®áâì   ­¥à ¢¥­áâ¢  ¢¥àè¨­  ®æ¥­®ª ®æ¥­¥­® ¯®áâà®¥­®"
   },
   {"THE PROCESS IS OVER",      /* -1 */
    "TOP LIMIT IS ACHIEVED",    /* -2 */
    "INSUFFICIENT PRECISION",   /* -3 */
    "TOP INSIDE THE SET",       /* -4 */
    "NOT ENOUGH MEMORY",        /* -5 */
    "THE SET IS NOT BODILY",    /* -6 */
    "INTERRUPTION",             /* -7 */
    "NO RESULT",                /* -8 */
    "discrepancy   facets    tops   estim all_est all_facets"
   }};

return (inform [ch_LNG][ - (1 + IOstatus)]);
 }    /* ch_inform */
