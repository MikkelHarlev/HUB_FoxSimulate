/* Automation Studio generated header file */
/* Do not edit ! */
/* XML 0.05.0 */

#ifndef _XML_
#define _XML_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _XML_VERSION
#define _XML_VERSION 0.05.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG3
		#include "SYS_LIB.h"
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
#endif
#ifdef _SGC
		#include "SYS_LIB.h"
#endif


/* Datatypes and datatypes of function blocks */
typedef struct xmlHandler_t
{	unsigned char cnt;
	unsigned char type;
} xmlHandler_t;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC signed long xmlParse(unsigned long Parser, unsigned long buffer, signed long len, plcbit isFinal);
_BUR_PUBLIC unsigned long xmlCreateParser(unsigned long encoding);
_BUR_PUBLIC unsigned char xmlFreeParser(unsigned long Parser);
_BUR_PUBLIC unsigned long xmlGetNextH(void);
_BUR_PUBLIC unsigned char xmlSAXActivate(void);
_BUR_PUBLIC unsigned long xmlHash(unsigned long key);
_BUR_PUBLIC plcbit xmlSetElemH(unsigned long parser, unsigned long startH, unsigned long endH);
_BUR_PUBLIC unsigned long xmlSetCharH(unsigned long parser, unsigned long dataH);
_BUR_PUBLIC plcbit xmlSetUserData(unsigned long parser, unsigned long userdata);
_BUR_PUBLIC signed char xmlGetError(unsigned long parser);
_BUR_PUBLIC signed short xmlGetLine(unsigned long parse);
_BUR_PUBLIC signed long xmlGetCol(unsigned long parser);
_BUR_PUBLIC signed long xmlGetByteIdx(unsigned long parser);
_BUR_PUBLIC plcbit xmlErr2Str(signed char err, plcstring** errString);
_BUR_PUBLIC unsigned long xmlParserReset(unsigned long parser);
_BUR_PUBLIC plcbit xmlSetCommH(unsigned long parser, unsigned long commentH);


#ifdef __cplusplus
};
#endif
#endif /* _XML_ */

