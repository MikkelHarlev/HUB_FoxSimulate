/* Automation Studio generated header file */
/* Do not edit ! */
/* XML_clnt 0.30.0 */

#ifndef _XML_CLNT_
#define _XML_CLNT_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _XML_clnt_VERSION
#define _XML_clnt_VERSION 0.30.0
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
		#include "httpUtil.h"
		#include "AsIecCon.h"
#endif
#ifdef _SGC
		#include "AsIecCon.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define XML_ERR_BUSY 30004
 #define XML_ERR_NODATA 30001
 #define XML_ERR_WIDENT 30000
 #define XML_ERR_BUFSIZE 30002
 #define XML_ERR_OPENFAIL 30003
 #define XML_NOT_FINISHED 65535
#else
 _GLOBAL_CONST signed long XML_ERR_BUSY;
 _GLOBAL_CONST signed long XML_ERR_NODATA;
 _GLOBAL_CONST signed long XML_ERR_WIDENT;
 _GLOBAL_CONST signed long XML_ERR_BUFSIZE;
 _GLOBAL_CONST signed long XML_ERR_OPENFAIL;
 _GLOBAL_CONST signed long XML_NOT_FINISHED;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct XML_sendint_typ
{	unsigned long already_sent;
	unsigned long headerlen;
	plcstring header[201];
	plcbit header_gen;
	plcbit finished;
	unsigned char step;
} XML_sendint_typ;

typedef struct XML_send_typ
{	unsigned long data_ptr;
	unsigned long len;
	unsigned char priority;
	struct XML_sendint_typ internal;
} XML_send_typ;

typedef struct XML_readint_typ
{	unsigned long read_step;
	unsigned long next_buffer;
	unsigned char headstat;
	struct HTTP_Header_typ head;
} XML_readint_typ;

typedef struct XML_read_typ
{	unsigned long buffer;
	unsigned long size;
	struct XML_readint_typ internal;
} XML_read_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC signed long XMLclose(signed long ident);
_BUR_PUBLIC signed long XMLread(signed long ident, unsigned long pparam);
_BUR_PUBLIC signed long XMLstatus(signed long ident, unsigned long data);
_BUR_PUBLIC signed long XMLsend(signed long ident, unsigned long pparam);
_BUR_PUBLIC signed long XMLconnect(signed long ident, unsigned long ip_address, unsigned short port);
_BUR_PUBLIC signed long XMLlisten(signed long ident, signed long cident, unsigned short port);


#ifdef __cplusplus
};
#endif
#endif /* _XML_CLNT_ */

