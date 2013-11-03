/* ����� ������� */
//#define ROUGH /* ������������� ����������� �������� */
#define CH_SIMPLEX 
#define CH_FREEEST
/*#define CH_VOLUMES ����� ��� ������� ����������� ���� */
/*#define CH_SURFACE ������ ������� ����������� */
/*#define CH_VOLFILE ����-�������� � ������� ��� ��������*/

/* ����������� �������� ������ CONVEX */
#ifdef CH_SIMPLEX
typedef union ch_simplex/*---------�������----------*/
 {unsigned long     ind;  /* ������ */
  union ch_simplex *next; /* ������ �� ��������� */
 } ch_simplex;
#endif

typedef struct ch_facet /*-----------�����-----------*/
 {double           dif;   /* ������� */
  float           *c;     /* ������,��.�����,�����-�� */
#ifdef CH_SIMPLEX
  ch_simplex      *simp;  /* ��������� */
#else
  unsigned long   *ind;   /* ������� */
#endif
  float           *top;   /* ��������� ������� */
  struct ch_facet *next;  /* ������ �� ��������� */
 } ch_facet;

typedef struct ch_top   /*-������� �������� ��������-*/
 {float           *c;     /* ������������ */
  struct ch_top   *next;  /* ������ �� ��������� */
 } ch_top;

typedef struct          /*-������� ������� � �������-*/
 {unsigned long    bit;   /* ������� � ������ */
  int              number;/* ���������� ����� ������ */
 } ch_position;

typedef struct          /*-------������ ������-------*/
 {ch_facet        *begin; /* ������ �� ������ */
  ch_facet       **end;   /* ������ �� ���� next ���������� */
 } ch_list;

#define ERR_RET(f) if ((IOstatus = f) != 0) return(IOstatus)
#define VIEW(p,first) for (p = first; p != NULL; p = p->next)
#ifndef CH_SIMPLEX
/* ����� ������ � ����� a */
#define ONES(pfacet) \
	for (i = 0; i <= ch_index_position.number; i++) \
	 {a = pfacet->ind [i]; \
	  while (a) {a &= (a - 1); k++;} \
	 }
#endif
#ifdef CH_SIMPLEX
#define VIEW_INDEX(psimp,pfacet) \
 for (psimp = pfacet->simp; psimp != NULL; psimp = psimp->next)
#endif

#ifdef ROUGH
#define rough(x) *(long*)&x
#define rough_mult - *(long*)&unit +
#else
#define rough(x) x
#define rough_mult *
#endif

/* ������� ������ CONVEX */
#include <stdio.h>
double ch_calc_dif      (float*, float*);
void   ch_prn_facet     (ch_facet*);
void   ch_combination   (ch_facet*, ch_facet*, ch_facet*);

int    ch_next_position (void);
int    ch_check         (ch_facet*);
void   ch_sort          (void);
int    ch_cycle_comb    (void);

void   ch_equ_search    (void);
void   ch_equ_double    (void);
int    ch_equ_comb      (void);

void   ch_est_next      (float*);
void   ch_est_max       (void);
int    ch_est_write     (float*);
void   ch_dir_write     (float*);

int    ch_init_facet    (int);
int    ch_inf_comb      (void);

void   ch_inf_print     (unsigned int);
char  *ch_inform        (int);

int    ch_add_facet     (ch_facet**);
void   ch_free_facet    (ch_facet**);
int    ch_copy_facet    (ch_facet*, ch_facet*);
void   ch_free_top      (ch_top**);
void   ch_del_top       (ch_facet*);
void   ch_move_top      (ch_facet*, ch_facet*);

void   ch_reverse       (void);
void   ch_free_mem      (void);
int    ch_read_dat      (int, int**);
int    ch_write_dat     (char*,char*);
int    ch_read_chs      (FILE*);
int    ch_write_chs     (FILE*);

int    ch_primal        (float*, float*, int);
