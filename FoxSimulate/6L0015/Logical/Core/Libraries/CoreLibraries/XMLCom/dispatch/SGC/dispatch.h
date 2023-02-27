/* Automation Studio generated header file */
/* Do not edit ! */
/* dispatch 0.05.0 */

#ifndef _DISPATCH_
#define _DISPATCH_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _dispatch_VERSION
#define _dispatch_VERSION 0.05.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define MAX_NODES 32U
 #define INVALID_TICKET 64U
#else
 _GLOBAL_CONST unsigned char MAX_NODES;
 _GLOBAL_CONST unsigned char INVALID_TICKET;
#endif







/* Prototyping of functions and function blocks */
_BUR_PUBLIC unsigned long dispatchBorrow(unsigned long handle, unsigned char* ticket);
_BUR_PUBLIC unsigned long dispatchClose(unsigned long handle);
_BUR_PUBLIC unsigned long dispatchInit(unsigned long cb_create, unsigned long cb_delete);
_BUR_PUBLIC unsigned long dispatchRestore(unsigned long handle, unsigned char* ticket);


#ifdef __cplusplus
};
#endif
#endif /* _DISPATCH_ */

