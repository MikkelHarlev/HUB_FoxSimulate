/* Automation Studio generated header file */
/* Do not edit ! */
/* XMLPVs 0.15.0 */

#ifndef _XMLPVS_
#define _XMLPVS_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _XMLPVs_VERSION
#define _XMLPVs_VERSION 0.15.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG3
		#include "XML_IVs.h"
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
		#include "DataObj.h"
		#include "AsString.h"
		#include "SAX_RPC.h"
		#include "XML_IVs.h"
		#include "XMLRPC.h"
#endif
#ifdef _SGC
		#include "XML_IVs.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define XMLPVS_BUSY 65535U
 #define XMLPVS_RPCD 65004U
 #define XMLPVS_REGFUNC 65003U
 #define XML_SALLR_INIT 65000U
 #define XMLPVS_WRDATAMOD 65001U
 #define XMLPVS_NOFUNCTION 65004U
#else
 _GLOBAL_CONST unsigned short XMLPVS_BUSY;
 _GLOBAL_CONST unsigned short XMLPVS_RPCD;
 _GLOBAL_CONST unsigned short XMLPVS_REGFUNC;
 _GLOBAL_CONST unsigned short XML_SALLR_INIT;
 _GLOBAL_CONST unsigned short XMLPVS_WRDATAMOD;
 _GLOBAL_CONST unsigned short XMLPVS_NOFUNCTION;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct XMLPVsinit_int_typ
{	unsigned long rpc2dident;
	unsigned long IV_ident;
	unsigned long rpc_ident;
	unsigned long step;
} XMLPVsinit_int_typ;

typedef struct XMLPVsinit_typ
{	plcstring ParamModule[81];
	struct xml_diag diag;
	struct XMLPVsinit_int_typ internal;
} XMLPVsinit_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC signed long XMLPVsportinit(unsigned long ident, unsigned long pparam, unsigned short port);
_BUR_PUBLIC signed long XMLPVsinit(unsigned long ident, unsigned long pparam);


#ifdef __cplusplus
};
#endif
#endif /* _XMLPVS_ */

