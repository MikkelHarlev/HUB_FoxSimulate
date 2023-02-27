/* Automation Studio generated header file */
/* Do not edit ! */
/* SAX_RPC 0.13.0 */

#ifndef _SAX_RPC_
#define _SAX_RPC_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _SAX_RPC_VERSION
#define _SAX_RPC_VERSION 0.13.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
		#include "AsString.h"
		#include "base64.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define SAX_PARSERR 1U
 #define SAX_FINISHED 4U
 #define SAX_NEEDRESP 2U
#else
 _GLOBAL_CONST unsigned char SAX_PARSERR;
 _GLOBAL_CONST unsigned char SAX_FINISHED;
 _GLOBAL_CONST unsigned char SAX_NEEDRESP;
#endif







/* Prototyping of functions and function blocks */
_BUR_PUBLIC unsigned char saxSetCBIdent(unsigned long handle, unsigned long cbptr);
_BUR_PUBLIC unsigned long saxGetEndElementHandler(void);
_BUR_PUBLIC unsigned char saxSetSingleRespCB(unsigned long handle, unsigned long cbFunc, unsigned char originType, unsigned long originData);
_BUR_PUBLIC signed short saxReset(unsigned long handle);
_BUR_PUBLIC unsigned char saxResponseNeed(unsigned long handle);
_BUR_PUBLIC unsigned char saxAddResultCBFunc(unsigned long funcPtr);
_BUR_PUBLIC unsigned long saxGetStartElementHandler(void);
_BUR_PUBLIC unsigned long saxGetCharHandler(void);
_BUR_PUBLIC signed short saxClose(unsigned long handle);
_BUR_PUBLIC unsigned char saxFinished(unsigned long handle);
_BUR_PUBLIC unsigned long saxOpen(unsigned long fcallMaxSize, unsigned short fMaxNameLen, unsigned short pMaxNum, unsigned short aMaxNum);
_BUR_PUBLIC unsigned char saxAddCBFunc(unsigned long funcPtr, unsigned long fname);
_BUR_PUBLIC unsigned char saxAddUndefCBFunc(unsigned long funcPtr);


#ifdef __cplusplus
};
#endif
#endif /* _SAX_RPC_ */

