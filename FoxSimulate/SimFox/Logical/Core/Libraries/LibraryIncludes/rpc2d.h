/* Automation Studio Generated Header File, Format Version 1.00 */
/* do not change */
#ifndef RPC2D_H_
#define RPC2D_H_
#define _WEAK	__attribute__((__weak__))

#include <bur/plctypes.h>



/* Constants */


/* Datatypes */


/* Datatypes of function blocks */


/* Prototyping of functions and function blocks */
unsigned long rpc2dCBGet();
unsigned long rpc2dBoot(unsigned long cfgPtr);
signed short rpc2dState(unsigned long ident);
plcbit rpc2dDown(unsigned long ident);
signed long dbgrpc2dsetDebug(unsigned long ident);
signed long dbgrpc2dVM(unsigned char from, unsigned char to, unsigned long cbID, unsigned long cbSTR, unsigned long cbNL, unsigned long cbCLR);
signed long dbgrpc2dTHconn(unsigned long cbID, unsigned long cbSTR, unsigned long cbNL, unsigned long cbCLR);



#endif /* RPC2D_H_ */

