#include <bur/plc.h>
#include <brsystem.h>/*New sfx*/
#include <sys_lib.h>
#include <ctype.h>
#include <rtkuser.h>
#include <string.h>


#ifndef MetUtilsDefH
#define MertUtilsDefH

#include "metutils.h"					/* internal structures used */

/* Error definition */
#define MET_ERR_XTRA_PULSE			 	 21
#define MET_ERR_MOTOR_STOP			 	 22
#define MET_ERR_LONG_CLOCK			 	 23



#define MAX_DELAY 60000  		/* equal to 10 sec. 60 000 time ticks a 10 ms */

#define MKTraceASSERT MKErrTraceMetUtils

enum MTsensorstatus
{
	MKSENSOR_TRIGGED				= 	1,/* bit 0 / Sensor has been trigged */
	MKSENSOR_RELEASED				= 	2,/* bit 1 / Sensor has been released */
	MKSENSOR_SET					= 	4,/* bit 2 / Sensor is set */
};

_BUR_PUBLIC unsigned short int getcurtimer()
{	/*BRSYSTEM*/
	SysInfo_typ sys_info;
	sys_info.enable = 1; 			/* enables the function */
	SysInfo(&sys_info); 			/* gets information from the system */
	return sys_info.tick_count%60000;
}

_BUR_PUBLIC unsigned long int getcurlongtimer()
{	/*BRSYSTEM*/
	SysInfo_typ sys_info;
	sys_info.enable = 1; 			/* enables the function */
	SysInfo(&sys_info); 			/* gets information from the system */
	return sys_info.tick_count;
}

_BUR_PUBLIC unsigned long int gettimestamp()
{
	RTCtime_typ time;
	#ifdef __i386__     /* compile only for  I386 */
		RTC_gettime(&time);
	#endif
	#ifdef __arm__     /* compile only for  ARM */
		RTC_gettime(&time);
	#endif
	#ifdef __mc68000__  /* compile only for  M68K */
		SW_gettime(&time);
	#endif
	return (time.year % 100) * 1000000 + ((time.month*31 + time.day)*1000) + (time.hour*10) + (time.minute/10);
}

_BUR_PUBLIC unsigned short int elapsedtime(unsigned short int curtime ,unsigned short int comparetime)
{
	/* counts with timeticks (1 timetick = 10 ms ) */
	return (curtime+MAX_DELAY-comparetime) % MAX_DELAY;
}

_BUR_PUBLIC unsigned long int elapsedlongtime(unsigned long int curtime, unsigned long int comparetime)
{
	return curtime-comparetime;
}

_BUR_PUBLIC plcbit CheckSensor(PresenceSensor_Type* sensor, unsigned short curtimer)
{
	if (sensor == 0)			/* no  pointer to sensor */
		return false;
	/* Check for first time */
	if (sensor->State == 0)
	{
		sensor->State = SENSOR_STATE_INITIATED;
		if (sensor->Input)										/* sensor is active at init */
		{
			sensor->State |= SENSOR_STATE_SET;					/* already set */
			sensor->State |= SENSOR_STATE_LASTSTATE_WAS_SET;	/* set last state flag */
		}
	}
	/* test sensor state */
	if (sensor->Input)											/* sensor is active */
	{
		sensor->State &= ~SENSOR_STATE_RELEASED;					/* reset an previous release flag */
		if ((sensor->State) & SENSOR_STATE_SET)									/* already set */
			return true;
		if(!(sensor->State & SENSOR_STATE_TRIGGED))							/* sensor not active before */
		{
			sensor->State |= SENSOR_STATE_TRIGGED;								/* set just activated flag 	*/
			sensor->RunTimer = curtimer;												/* start timer 				*/
		}
		else if ((elapsedtime(curtimer, sensor->RunTimer)) > sensor->OnDelay)			/* sensor activated long enough */
		{
			sensor->State &= ~SENSOR_STATE_TRIGGED;								/* reset any old trigged flags */
			sensor->State |= SENSOR_STATE_SET;									/* set status set */
		}
	}
	else  																	/* no sensor active */
	{
		sensor->State &= ~SENSOR_STATE_TRIGGED;	/* reset any previous trigged flag sensor flag */
		if((sensor->State & SENSOR_STATE_SET) > 0)							/* was full before */
		{
			if (!((sensor->State) & SENSOR_STATE_RELEASED))						/* sensor was just released */
			{
				sensor->State |= SENSOR_STATE_RELEASED;							/* set just released flag */
				sensor->RunTimer = curtimer;											/* start timer */
			}
			else if (elapsedtime(curtimer, sensor->RunTimer) > sensor->OffDelay)			/* sensor released long enough */
			{
				sensor->State &= ~SENSOR_STATE_SET;								/* reset status set */
				sensor->State &= ~SENSOR_STATE_RELEASED;						/* reset just released flag */
			}
		}
	}
	if (((sensor->State) & SENSOR_STATE_SET) > 0)								/* return if set or not */
		return true;
	return false;
}

_BUR_PUBLIC signed long CheckDelayedOutput(DelayedOutput_Type* Output, unsigned short curtimer)
{
	if(Output==0)														/* Illega pointer */
		return 0;
	if (Output->State == 0)												/* Output not activated */
		return 0;
	else if (elapsedtime(curtimer, Output->StartTimer) > Output->Delay)	/* sensor activated long enough */
	{
		Output->State = 0;												/* turn off output */
		return 0;
	}
	else																/* should still be on */
		return 1;
}

_BUR_PUBLIC signed long SetDelayedOutput(DelayedOutput_Type* Output, unsigned short starttimer, unsigned short delay)
{
	if(Output==0)														/* illegal pointer */
		return 0;
	Output->StartTimer = starttimer;									/* set start timer */
	Output->Delay = delay;												/* set delay */
	Output->State = 1;													/* turn on output */
	return 0;
}

BOOL AddString( unsigned long origString, unsigned long addString, short int maxLen )
{
	if ((char*)origString == NULL)
		return false;
	strncat((char*)origString,(char*)addString,maxLen);
	return true;
}

BOOL AddValString( unsigned long origString, unsigned int value )
{
	if ((char*)origString == NULL)
		return false;
	metsprintf((char*)origString,"%s %d",(char*)origString,value);
	return true;
}


/*··············································································································*/

#endif /*MetUtilsDefH*/
