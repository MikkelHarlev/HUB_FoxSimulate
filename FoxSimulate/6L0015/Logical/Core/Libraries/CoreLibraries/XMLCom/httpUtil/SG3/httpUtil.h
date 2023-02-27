/* Automation Studio generated header file */
/* Do not edit ! */
/* httpUtil 0.10.0 */

#ifndef _HTTPUTIL_
#define _HTTPUTIL_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _httpUtil_VERSION
#define _httpUtil_VERSION 0.10.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG4
		#include "AsString.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define HTTP_OK 255U
 #define HTTP_RPC 2U
 #define HTTP_USR 16U
 #define HTTP_CONT 128U
 #define HTTP_HOST 8U
 #define HTTP_HTTP 4U
 #define HTTP_POST 1U
 #define htpNOPRIO (-1)
 #define HTTP_CONTL 64U
 #define HTTP_CONTT 32U
 #define htpLOWPRIO 0
 #define htpSYSPRIO 2
 #define HTTP_MINLEN 5U
 #define htpHIGHPRIO 1
 #define htpNOREQUEST 222U
#else
 _GLOBAL_CONST unsigned char HTTP_OK;
 _GLOBAL_CONST unsigned char HTTP_RPC;
 _GLOBAL_CONST unsigned char HTTP_USR;
 _GLOBAL_CONST unsigned char HTTP_CONT;
 _GLOBAL_CONST unsigned char HTTP_HOST;
 _GLOBAL_CONST unsigned char HTTP_HTTP;
 _GLOBAL_CONST unsigned char HTTP_POST;
 _GLOBAL_CONST signed char htpNOPRIO;
 _GLOBAL_CONST unsigned char HTTP_CONTL;
 _GLOBAL_CONST unsigned char HTTP_CONTT;
 _GLOBAL_CONST signed char htpLOWPRIO;
 _GLOBAL_CONST signed char htpSYSPRIO;
 _GLOBAL_CONST unsigned char HTTP_MINLEN;
 _GLOBAL_CONST signed char htpHIGHPRIO;
 _GLOBAL_CONST unsigned char htpNOREQUEST;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct HTTP_Header_typ
{	unsigned long prio;
	unsigned long clen;
	unsigned long host;
	unsigned long cont;
	unsigned long ctype;
	unsigned long restlen;
	unsigned char res[32];
} HTTP_Header_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC unsigned long httpGenHeader(unsigned long buffer, unsigned long content, unsigned long clen, signed char prio);
_BUR_PUBLIC unsigned char httpParseHeader(unsigned long string, unsigned long len, struct HTTP_Header_typ* head);
_BUR_PUBLIC unsigned long httpHeaderGen(unsigned long buff, unsigned long clen, signed char prio);
_BUR_PUBLIC unsigned long httpSetIpHeader(unsigned long ipaddr);
_BUR_PUBLIC unsigned long httpStripHeader(unsigned long string, unsigned short* len);


#ifdef __cplusplus
};
#endif
#endif /* _HTTPUTIL_ */

