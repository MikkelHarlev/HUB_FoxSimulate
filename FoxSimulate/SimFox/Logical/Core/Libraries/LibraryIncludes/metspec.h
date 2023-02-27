/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*\
| Metspec.h : functions to format strings
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Version 1.0 2005-04-18
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/

#ifndef MetUtilsHeader
#define MetUtilsHeader


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





#endif


