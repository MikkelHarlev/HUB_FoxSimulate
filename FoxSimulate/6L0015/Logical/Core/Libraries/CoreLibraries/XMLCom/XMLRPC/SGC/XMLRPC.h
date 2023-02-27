/* Automation Studio generated header file */
/* Do not edit ! */
/* XMLRPC 0.12.0 */

#ifndef _XMLRPC_
#define _XMLRPC_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _XMLRPC_VERSION
#define _XMLRPC_VERSION 0.12.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
		#include "dispatch.h"
		#include "SAX_RPC.h"
#endif
#ifdef _SGC
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define RPC_OK 0
 #define RPC_BUSY (-1)
 #define XML_PARSE_ERROR 65533U
 #define XML_PARSE_FINISHED 65534U
#else
 _GLOBAL_CONST signed char RPC_OK;
 _GLOBAL_CONST signed char RPC_BUSY;
 _GLOBAL_CONST unsigned short XML_PARSE_ERROR;
 _GLOBAL_CONST unsigned short XML_PARSE_FINISHED;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct xml_cbData_type
{	unsigned long cbFunc;
	unsigned char cbDataType;
	unsigned long cbpData;
} xml_cbData_type;

typedef struct XMLCBIDENT_typ
{	unsigned long ticket;
	signed long status;
	unsigned long parser;
	unsigned char internal;
} XMLCBIDENT_typ;

typedef struct xml_sax_para_t
{	unsigned long fcallMaxSize;
	unsigned short fMaxNameLen;
	unsigned short pMaxNum;
	unsigned short aMaxNum;
} xml_sax_para_t;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC signed long xmlResetCB(unsigned long ident);
_BUR_PUBLIC signed long xmlStateCB(unsigned long ident);
_BUR_PUBLIC signed long xmlUnlockCB(unsigned long ident);
_BUR_PUBLIC signed long xmlLockCB(unsigned long* ident);
_BUR_PUBLIC signed long xmlProcessorCB(unsigned long ident, unsigned long wr_id, unsigned long pBuff, unsigned long len);
_BUR_PUBLIC unsigned long getDbgPtr(void);
_BUR_PUBLIC signed long xmlRPCParse(unsigned long buffer, unsigned long len);
_BUR_PUBLIC unsigned long xmlRpcInit(unsigned long calldata);
_BUR_PUBLIC unsigned long XMLParser(unsigned long buf, unsigned long len, unsigned long cbData);
_BUR_PUBLIC plcbit xmlRpcFree(unsigned long handle);
_BUR_PUBLIC signed char xmlRPCGetError(unsigned long handle);


#ifdef __cplusplus
};
#endif
#endif /* _XMLRPC_ */

