#define NUM 16

#include <stdio.h>
#include <string.h>
#include "ch_main.h"
#include "ch_var.def"

extern int add_top;

extern char *par_name;

struct

 {char *name;

  char type;  /* 0 - char [], 1 - int, 2 - float */

  union 

   { char *ch;

    int   *in;

    float *fl;

   } point; 

 }datum [NUM]=

 {{"ch_MAXtop",    1, (char *) &ch_max_topCOUNT},                  //1

  {"ch_MAXfacet",1, (char *) &ch_max_facetCOUNT},        //2 

  {"ch_LNG",     1, (char *) &ch_LNG},                   //3 

  {"ch_PRNT",    1, (char *) &ch_PRNT},                  //4

  {"ch_RCHECK",  1, (char *) &ch_RCHECK},                //5

  {"ch_INCHECK", 1, (char *) &ch_INCHECK},               //6

  {"ch_RHYPER",  1, (char *) &ch_RHYPER},                //7 

  {"ch_EPSrel",  2, (char*) &ch_EPSrel},                 //8

  {"ch_EPSdif",  2, (char*) &ch_EPSdif},                 //9  

  {"ch_EPScheck",2, (char*) &ch_EPScheck},               //10 

  {"ch_EPSset",  2, (char*) &ch_EPSset},                 //11

  {"ch_EPSin",   2, (char*) &ch_EPSin},                  //12

  {"ch_EPSest",  2, (char*) &ch_EPSest},                 //13
   
  {"ch_INF",     2, (char*) &ch_INF},                    //14
   
//  {"in_name", 0 , in_name},                              //15
   
//  {"model_name", 0, model_name},                          
    
//  {"out_name",   0, out_name},                           //16 
   
    
 /*,                  

  {"lpm_LNG",    1, (char*)&lpm_LNG},

  {"lpm_PRNT",   1, (char*)&lpm_PRNT},

  {"lpm_res",    2, (char*)&lpm_res},

  {"lpm_EPS",    2, (char*)&lpm_EPS},

  {"lpm_EPSrel", 2, (char*)&lpm_EPSrel},

  {"lpm_EPSpiv", 2, (char*)&lpm_EPSpiv},

  {"lpm_EPSopt", 2, (char*)&lpm_EPSopt},

  {"lpm_TOCHN",  2, (char*)&lpm_TOCHN},

  {"lpm_EPSrhs", 2, (char*)&lpm_EPSrhs},

  {"lpm_ETMLt",  2, (char*)&lpm_ETMLt},

  {"lpm_ETMLs",  2, (char*)&lpm_ETMLs},

  {"lpm_ETMLu",  2, (char*)&lpm_ETMLu} */

 };



void read_par (float * controlParams)

 {
  
	 add_top = controlParams[0];
     ch_EPSset = controlParams[1];
	 ch_RCHECK =(int) controlParams[2];
	 ch_RFREE =(int) controlParams[3];
	 ch_INCHECK =(int) controlParams[4];
	 ch_RHYPER =(int) controlParams[5];
	 ch_EPSdif = controlParams[6];
	 ch_EPSin = controlParams[7];
	 ch_EPSest = controlParams[8];
	 ch_EPScheck = controlParams[9];
	 ch_EPSrel = controlParams[10];
	 ch_INF=controlParams[11];
	 ch_PRNT=controlParams[12];

	 
 }  /* read_par */

