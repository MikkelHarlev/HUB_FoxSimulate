/* Automation Studio generated header file */
/* Do not edit ! */

#ifndef _XML_IVS_
#define _XML_IVS_
#ifdef __cplusplus
extern "C" 
{
#endif

#include <bur/plctypes.h>

#ifdef _SG4
		#include "DataObj.h"
		#include "AsString.h"
		#include "SYS_LIB.h"
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
 #ifndef _GLOBAL_CONST
  #define _GLOBAL_CONST _WEAK const
 #endif
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
unsigned short XMLpvread(unsigned long ID, unsigned long pName, unsigned long pStream, unsigned long pSize, unsigned long str);
unsigned short XMLpvwrite(unsigned long ID, unsigned long pName, unsigned long pStruct);
unsigned short XML_init(unsigned long pID, unsigned long pCfgName, unsigned long pDiag);
unsigned short XML_deinit(unsigned long ID);
signed long XMLobjinv(unsigned long ID, unsigned long pStream, unsigned long pSize);


__asm__(".section \".plc\"");

__asm__(".previous");

#ifdef __cplusplus
};
#endif
#endif /* _XML_IVS_ */

