/* Automation Studio generated header file */
/* Do not edit ! */
/* XML_IVs 0.04.0 */

#ifndef _XML_IVS_
#define _XML_IVS_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _XML_IVs_VERSION
#define _XML_IVs_VERSION 0.04.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG4
		#include "DataObj.h"
		#include "AsString.h"
		#include "XML_Mrsh.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define ERROR_WRITE_PV 30108U
 #define ERROR_ILLEGAL_ID 30105U
 #define ERROR_NAME_TO_LONG 30102U
 #define ERROR_INCORRECT_LEN 30109U
 #define ERROR_XML_MARSHALLER 30104U
 #define ERROR_ENTRY_NOT_FOUND 30106U
 #define ERROR_ILLEGAL_PV_TYPE 30101U
 #define ERROR_UNKNOWN_SERVICE 30103U
 #define ERROR_INCORRECT_PV_TYPE 30107U
 #define ERROR_KEYWORD_NOT_FOUND 30100U
#else
 _GLOBAL_CONST unsigned short ERROR_WRITE_PV;
 _GLOBAL_CONST unsigned short ERROR_ILLEGAL_ID;
 _GLOBAL_CONST unsigned short ERROR_NAME_TO_LONG;
 _GLOBAL_CONST unsigned short ERROR_INCORRECT_LEN;
 _GLOBAL_CONST unsigned short ERROR_XML_MARSHALLER;
 _GLOBAL_CONST unsigned short ERROR_ENTRY_NOT_FOUND;
 _GLOBAL_CONST unsigned short ERROR_ILLEGAL_PV_TYPE;
 _GLOBAL_CONST unsigned short ERROR_UNKNOWN_SERVICE;
 _GLOBAL_CONST unsigned short ERROR_INCORRECT_PV_TYPE;
 _GLOBAL_CONST unsigned short ERROR_KEYWORD_NOT_FOUND;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct xml_diag
{	unsigned short line_no;
	unsigned char infoText[40];
} xml_diag;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC unsigned short XMLpvread(unsigned long ID, unsigned long pName, unsigned long pStream, unsigned long pSize, unsigned long str);
_BUR_PUBLIC unsigned short XMLpvwrite(unsigned long ID, unsigned long pName, unsigned long pStruct);
_BUR_PUBLIC unsigned short XML_init(unsigned long pID, unsigned long pCfgName, unsigned long pDiag);
_BUR_PUBLIC unsigned short XML_deinit(unsigned long ID);
_BUR_PUBLIC signed long XMLobjinv(unsigned long ID, unsigned long pStream, unsigned long pSize);


#ifdef __cplusplus
};
#endif
#endif /* _XML_IVS_ */

