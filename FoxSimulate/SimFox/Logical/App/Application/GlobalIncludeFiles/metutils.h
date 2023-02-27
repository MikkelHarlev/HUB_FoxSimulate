/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*\
| MetUtils.h : functions to format strings																		 
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Version 1.0 20010411																						 
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————
| Version 1.02 20020419		Added datatype MSHangerID and the functions DataSetNull(MSHangerID* a),
							DataIsNull(MSHangerID* a), DataEqual(MSHangerID* a, MSHangerID* b).
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————
| Version 1.03 20020426		getcurtimer() and gettimestamp() is now  working with i386 processor and theby the 
								whole library.
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————
| Version 1.04 20020430		DataMakeStr() to convert a hanger Id into a string
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/

#ifndef MetUtilsHeader
#define MetUtilsHeader


/*———[ Includes ]———————————————————————————————————————————————————————————————————————————————————————————————*/

#include <bur/plc.h>
#include <sys_lib.h>
#include <stdarg.h>
#include <stddef.h>
#include <limits.h>
#include <errdef.h>


/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*\
| Commons.h : declare true and false																		 |
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Version 1.0 19990720																						 |
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/

/*———[ Typedefs ]———————————————————————————————————————————————————————————————————————————————————————————————*/

typedef unsigned long				MTPointerView;				/* workaround for storing pointers in the DPR	*/

/*———[ Constants ]——————————————————————————————————————————————————————————————————————————————————————————————*/
#ifndef TRUE
#define TRUE		((BOOL)(0==0))								/* a 'true' boolean								*/
#endif

#ifndef FALSE
#define FALSE		((BOOL)(1==0))								/* a 'false' boolean							*/
#endif

#ifndef true
#define true		((BOOL)(0==0))								/* a 'true' boolean								*/
#endif

#ifndef false
#define false		((BOOL)(1==0))								/* a 'false' boolean							*/
#endif

#ifndef NULL
#define NULL		((void*)0UL)								/* a NULL pointer								*/
#endif

#define MKwarningBufferSize 31									/* 31 c. in the extended information field		*/


enum MKPesenceSensorType
{
	SENSOR_STATE_INITIATED 			= 1,
	SENSOR_STATE_SET				= 2,
	SENSOR_STATE_LASTSTATE_WAS_SET	= 4,
	SENSOR_STATE_RELEASED			= 8,
	SENSOR_STATE_TRIGGED 			= 16,
};	

/*enum MKMotorFlags
{
	MOTOR_FLAG_LONG_CLOCK 			= 1,*/	/* A long clock is detected during last run of motor */
/*};	*/

/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*\
| MetUtils.h : functions to format strings																		 |
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Version 1.0 19990720																						 |
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/
/* Datatypes */
typedef struct HangerID_Type
{
	unsigned long Low;											/* least significant part of the ID#            */
	unsigned long High;											/* most significant part of the ID#             */
} HangerID_Type;

/*typedef HangerID_Type HangerID_Type;*/
typedef HangerID_Type * HangerIDPtr;								/* type to point over a hangers id record       */

typedef struct Garment_Type
{
	plcstring Description[20+1];
	unsigned short ArticleId;
	unsigned short FinisherAccum;
	unsigned short FinisherCategory;
	unsigned short FolderAccum;
	unsigned short FolderRail;
	unsigned short FolderCategory;
	unsigned short FolderBelt;
	unsigned short Inspection;
	unsigned short PictureIndex;
	unsigned short Reserve1;
	unsigned short Reserve2;
} Garment_Type;


typedef struct PresenceSensor_Type
{
	unsigned short RunTimer;
	unsigned short State;
	plcbit Input;
	unsigned short OnDelay;
	unsigned short OffDelay;
} PresenceSensor_Type;

typedef struct DelayedOutput_Type
{
	plcbit State;
	unsigned short StartTimer;
	unsigned short Delay;
} DelayedOutput_Type;


/*———[ Methods ]————————————————————————————————————————————————————————————————————————————————————————————————*/

size_t strnlen( const char *s, size_t count );
unsigned long simple_strtoul( const char *cp, char **endp, unsigned int base );
int metvsprintf( char *buf, const char *fmt, va_list args ) __attribute__ ((format (printf, 2, 0)));
int metsprintf( char *buf, const char *fmt, ... ) __attribute__ ((format (printf, 2, 3)));
int strtrimend(char* instr); /* trims the end of instr from spaces */ 
void logprintf( UINT errornr, UDINT errorinfo, const char *fmt, ... ) __attribute__ ((format (printf, 3, 4)));
plcbit CheckSensor(PresenceSensor_Type* sensor, unsigned short curtimer);

signed short DataSetNull(HangerID_Type* a);
plcbit DataIsNull(HangerID_Type* a);
plcbit DataEqual(HangerID_Type* a, HangerID_Type* b);
plcbit DataMakeStr(HangerID_Type* HangerId, unsigned long HangerStr);
plcbit DataMakeIdOfStr(HangerID_Type* HangerId, unsigned long HangerStr);

signed long CheckDelayedOutput(DelayedOutput_Type* Output, unsigned short curtimer);
signed long SetDelayedOutput(DelayedOutput_Type* output, unsigned short starttimer, unsigned short delay);



/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*\
| Util.h : functions to handle timer     																		 |
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Version 1.0            				     																	 |
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/

unsigned short int	getcurtimer();
/* returns the current time in time ticks (= 10ms)
   up tp 9 min 59 seconds and 999 ms
*/

unsigned long getcurlongtimer();
/* returns the current time in time ticks (= 10ms) since start of PLC
   0-0hFFFF FFFF (UDINT)
*/

unsigned long int	gettimestamp();
/* returns a time stamp in the format yydddhhm */
/* yy is the last 2 digits of the year. ddd is month*31+day. hh is the hour and m is the 10 part of the minute */
/* Like 2001-11-25 13:42:23 will be 01-366(11*31+25)-13-4. or shortly  just '1366134'  */

unsigned short int elapsedtime(unsigned short int starttime,unsigned short int comparetime);
/* Checks the time that have elapsed since 'starttime' compared to comparetime. Time is in tick (1tick = 10ms) */
/* used for timers up to 10 minutes */

unsigned long elapsedlongtime(unsigned long curtime, unsigned long starttime);
/* Checks the time that have elapsed since 'starttime' compared to comparetime. Time is in tick (1tick = 10ms) */
/* used for timers up to 1.3 years after start of PLC */


#endif
