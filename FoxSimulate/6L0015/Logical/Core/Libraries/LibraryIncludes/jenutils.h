/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*\
| Utils.h : functions to format strings
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Version 1.0 SF copied Metrics MetUtils to this file to avoid dependencies to MEtutils when other
				Jensen companies used this library.
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/

#ifndef JenUtilsHeader
#define JenUtilsHeader


/*———[ Includes ]———————————————————————————————————————————————————————————————————————————————————————————————*/

#include <bur/plc.h>
#include <sys_lib.h>
#include <stdarg.h>
#include <stddef.h>
#include <limits.h>

/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*\
| Commons.h : declare true and false																		 |
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Version 1.0 19990720																						 |
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/

/*———[ Typedefs ]———————————————————————————————————————————————————————————————————————————————————————————————*/
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



/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*\
| JenUtils.h : functions to format strings																		 |
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Version 1.0 19990720																						 |
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/
/* Datatypes */

/*———[ Methods ]————————————————————————————————————————————————————————————————————————————————————————————————*/

size_t strnlen( const char *s, size_t count );
unsigned long simple_strtoul( const char *cp, char **endp, unsigned int base );
int vsprintf( char *buf, const char *fmt, va_list args ) __attribute__ ((format (printf, 2, 0)));
int jensprintf( char *buf, const char *fmt, ... ) __attribute__ ((format (printf, 2, 3)));
int strtrimend(char* instr); /* trims the end of instr from spaces */
void logprintf( UINT errornr, UDINT errorinfo, const char *fmt, ... ) __attribute__ ((format (printf, 3, 4)));

/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*\
| Util.h : functions to handle timer     																		 |
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Version 1.0            				     																	 |
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/

unsigned short int	getcurtimer();
/* returns the current time in time ticks (= 10ms)
   up tp 9 min 59 seconds and 999 ms
*/

unsigned short int elapsedtime(unsigned short int starttime,unsigned short int comparetime);
/* Checks the time that have elapsed since 'starttime' compared to comparetime. Time is in tick (1tick = 10ms) */
/* used for timers up to 10 minutes */

#endif


