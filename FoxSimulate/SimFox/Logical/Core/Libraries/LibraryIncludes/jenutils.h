/*覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧*\
| Utils.h : functions to format strings
+覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧+
| Version 1.0 SF copied Metrics MetUtils to this file to avoid dependencies to MEtutils when other
				Jensen companies used this library.
\*覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧*/

#ifndef JenUtilsHeader
#define JenUtilsHeader


/*覧夕 Includes ]覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?*/

#include <bur/plc.h>
#include <sys_lib.h>
#include <stdarg.h>
#include <stddef.h>
#include <limits.h>

/*覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧*\
| Commons.h : declare true and false																		 |
+覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧+
| Version 1.0 19990720																						 |
\*覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧*/

/*覧夕 Typedefs ]覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?*/
/*覧夕 Constants ]覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧*/
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



/*覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧*\
| JenUtils.h : functions to format strings																		 |
+覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧+
| Version 1.0 19990720																						 |
\*覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧*/
/* Datatypes */

/*覧夕 Methods ]覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧*/

size_t strnlen( const char *s, size_t count );
unsigned long simple_strtoul( const char *cp, char **endp, unsigned int base );
int vsprintf( char *buf, const char *fmt, va_list args ) __attribute__ ((format (printf, 2, 0)));
int jensprintf( char *buf, const char *fmt, ... ) __attribute__ ((format (printf, 2, 3)));
int strtrimend(char* instr); /* trims the end of instr from spaces */
void logprintf( UINT errornr, UDINT errorinfo, const char *fmt, ... ) __attribute__ ((format (printf, 3, 4)));

/*覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧*\
| Util.h : functions to handle timer     																		 |
+覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧+
| Version 1.0            				     																	 |
\*覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧*/

unsigned short int	getcurtimer();
/* returns the current time in time ticks (= 10ms)
   up tp 9 min 59 seconds and 999 ms
*/

unsigned short int elapsedtime(unsigned short int starttime,unsigned short int comparetime);
/* Checks the time that have elapsed since 'starttime' compared to comparetime. Time is in tick (1tick = 10ms) */
/* used for timers up to 10 minutes */

#endif


