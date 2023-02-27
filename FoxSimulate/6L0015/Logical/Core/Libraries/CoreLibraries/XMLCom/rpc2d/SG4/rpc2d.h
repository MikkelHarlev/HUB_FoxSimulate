/* Automation Studio generated header file */
/* Do not edit ! */
/* rpc2d 0.12.0 */

#ifndef _RPC2D_
#define _RPC2D_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _rpc2d_VERSION
#define _rpc2d_VERSION 0.12.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG3
		#include "AsIecCon.h"
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
		#include "AsString.h"
		#include "EthSock.h"
		#include "dispatch.h"
		#include "httpUtil.h"
		#include "AsIecCon.h"
#endif
#ifdef _SGC
		#include "AsIecCon.h"
#endif





/* Prototyping of functions and function blocks */
_BUR_PUBLIC signed long dbgrpc2dTHconn(unsigned long cbID, unsigned long cbSTR, unsigned long cbNL, unsigned long cbCLR);
_BUR_PUBLIC signed long dbgrpc2dVM(unsigned char from, unsigned char to, unsigned long cbID, unsigned long cbSTR, unsigned long cbNL, unsigned long cbCLR);
_BUR_PUBLIC signed long dbgrpc2dsetDebug(unsigned long ident);
_BUR_PUBLIC plcbit rpc2dDown(unsigned long ident);
_BUR_PUBLIC signed short rpc2dState(unsigned long ident);
_BUR_PUBLIC unsigned long rpc2dBoot(unsigned long cfgPtr);
_BUR_PUBLIC unsigned long rpc2dCBGet(void);


#ifdef __cplusplus
};
#endif
#endif /* _RPC2D_ */

