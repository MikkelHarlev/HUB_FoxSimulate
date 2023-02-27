/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*\
| errutils.h : functions to output information to the log book													 |
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Version 1.0 NS19990720																						 |
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Requirements : strutils V1.0																					 |
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/

#ifndef ERRUtilsHeader
#define ERRUtilsHeader

/*———[ Includes ]———————————————————————————————————————————————————————————————————————————————————————————————*/

#include <bur\plctypes.h>
#include <metutils.h>

/*———[ Constants ]——————————————————————————————————————————————————————————————————————————————————————————————*/


/*———[ Methods ]————————————————————————————————————————————————————————————————————————————————————————————————*/


/*———[ Macros ]—————————————————————————————————————————————————————————————————————————————————————————————————*/

#ifdef NDEBUG													/* specific implementation of the assert macro	*/
	#define assert(p)   ((void)0)
#else
	#ifndef NDEBUGWARNING
		#warning Debugging macros active
		#define NDEBUGWARNING
	#endif
	void logassert( UDINT line, const char *file, const char *check );
	#define assert(p)   ((p) ? (void)0 : logassert( __LINE__, __FILE__, #p ))
#endif

#endif
