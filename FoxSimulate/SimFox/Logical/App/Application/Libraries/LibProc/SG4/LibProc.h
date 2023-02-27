/* Automation Studio generated header file */
/* Do not edit ! */
/* LibProc  */

#ifndef _LIBPROC_
#define _LIBPROC_
#ifdef __cplusplus
extern "C" 
{
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
/* Datatypes and datatypes of function blocks */
typedef struct HMI_CUR_ALRMLIST
{	unsigned long TimePerTrig;
	unsigned long Time;
	unsigned long Time_Sec;
	unsigned char Count;
	unsigned long Timer_10ms;
	plcbit AlarmSaved;
	plcbit FirstAlarm;
	plcbit Alarm;
	unsigned long Index;
} HMI_CUR_ALRMLIST;

typedef struct HMIStatistic_ALM
{	struct HMI_CUR_ALRMLIST CurrentAlrmList[71];
	unsigned char CurLayer;
	plcdt Date;
	plcbit Delete;
	unsigned long NumberOfPiecesTotal;
} HMIStatistic_ALM;

typedef struct FunFilter2
{
	/* VAR_INPUT (analog) */
	unsigned long FilterPos;
	unsigned long FilterNeg;
	/* VAR (analog) */
	unsigned long Timer1;
	unsigned long Timer2;
	/* VAR_INPUT (digital) */
	plcbit IN;
	/* VAR_OUTPUT (digital) */
	plcbit OUT;
	/* VAR (digital) */
	plcbit IN_Last;
} FunFilter2_typ;

typedef struct FunFilter
{
	/* VAR_INPUT (analog) */
	unsigned long Count;
	/* VAR (analog) */
	unsigned long Timer;
	/* VAR_INPUT (digital) */
	plcbit IN;
	/* VAR_OUTPUT (digital) */
	plcbit OUT;
	/* VAR (digital) */
	plcbit IN_Last;
} FunFilter_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC void FunFilter2(struct FunFilter2* inst);
_BUR_PUBLIC void FunFilter(struct FunFilter* inst);


#ifdef __cplusplus
};
#endif
#endif /* _LIBPROC_ */

