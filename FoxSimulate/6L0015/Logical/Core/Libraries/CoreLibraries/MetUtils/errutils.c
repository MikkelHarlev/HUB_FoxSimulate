/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*\
| errutils.c : functions to output information to the log book													 |
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Version 1.0 NS19990701																						 |
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| The constant 'MKlogprintfBufferSize' controls the size of a temporary buffer that holds the formated string.	 |
| Since the text field in the log book only holds 31 characters, this is more than necessary. Trying to format	 |
| a long string will result in a truncation. However, if the buffer isn't large enougth to hold the formated	 |
| output, a memory corruption will occur. In that case, a fatal error is raised and the last log is the length of|
| the output string (65535,length,""). It is up to the user to make a rational use of logprintf.				 |
| The constant 'MKwarningBufferSize' should be equal to the size of the 'Extended information' field in the log	 |
| book. Change this constant to reflect changes in the log book settings.										 |
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/

#include <bur/plctypes.h>
#include <sys_lib.h>
#include <stdarg.h>
#include <string.h>

#include <errdef.h>
#include "metutils.h"

#define NDEBUG													/* no debug code included in the build			*/
#include <errutils.h>

/*———[ Constants ]——————————————————————————————————————————————————————————————————————————————————————————————*/

#define MKlogprintfBufferSize 255								/* size of the local buffer for formating		*/

/*———[ Methods ]————————————————————————————————————————————————————————————————————————————————————————————————*/

_BUR_PUBLIC void logprintf( UINT errornr, UDINT errorinfo, const char *fmt, ... )	/* formated output to log book			*/
{
	va_list args;
	int i;
	char buf[MKlogprintfBufferSize+1];							/* local buffer to hold the formated string		*/

	va_start( args, fmt );
	i = metvsprintf( buf, fmt, args );								/* conversion									*/
	va_end( args );
	buf[MKwarningBufferSize] = '\0';							/* trim the buffer size to the field size		*/
	ERRxwarning( errornr, errorinfo, buf );						/* output the log record						*/
	if ( i>=MKlogprintfBufferSize )								/* if buffer overflow when converting ...		*/
		ERR_fatal( -1, i );										/* memory is messed up > trigger emergency stop	*/
}

/*··············································································································*/

_BUR_PUBLIC void logassert( UDINT line, const char *file, const char *check )	/* log nicely an assertion failure			*/
{
	size_t LF = strlen( file );
	UDINT i, j;

	if (line>99999999)						/* 99999999 = max line number										*/
		i = -1;								/* if line number too large: 16#FFFFFFFF will be shown				*/
	else									/* else convert it to be read in base 10 when displayed in base 16	*/
		for ( i=0, j=1; line>0; i+=(line%10)*j, j*=16, line/=10 );
	if ( LF>MKwarningBufferSize )			/* >31 "~end\of\path\file.ext"										*/
		logprintf( MKAssertTrace, i, "~%.*s", (int)MKwarningBufferSize-1, file+(LF+1-MKwarningBufferSize) );
	else if ( LF<(MKwarningBufferSize-1) )	/* <30 "complete\path\file.ext:beginingofTEST"						*/
		logprintf( MKAssertTrace, i, "%s:%.*s", file, (int)(MKwarningBufferSize-1-LF), check );
	else									/* [31..30] "complete\path\file.ext"								*/
		logprintf( MKAssertTrace, i, "%.*s", (int)MKwarningBufferSize, file );
}

/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/
