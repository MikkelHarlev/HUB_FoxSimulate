/* Automation Studio generated header file */
/* Do not edit ! */
/* XML_Mrsh 0.03.0 */

#ifndef _XML_MRSH_
#define _XML_MRSH_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _XML_Mrsh_VERSION
#define _XML_Mrsh_VERSION 0.03.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
		#include "base64.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define XML_C_MODE 2
 #define XML_BIN_MODE 0
 #define XML_IEC_MODE 1
 #define XML_PTR_REPR 1
 #define XML_VAL_REPR 0
 #define XML_BOOL_TYPE 2
 #define XML_INT2_TYPE 0
 #define XML_INT4_TYPE 1
 #define XML_TIME_TYPE 5
 #define XML_ARRAY_TYPE 8
 #define XML_BIG_ENDIAN 0
 #define XML_BINARY_TYPE 6
 #define XML_DOUBLE_TYPE 4
 #define XML_STRING_TYPE 3
 #define XML_STRUCT_TYPE 7
 #define XML_LITTLE_ENDIAN 1
#else
 _GLOBAL_CONST signed short XML_C_MODE;
 _GLOBAL_CONST signed short XML_BIN_MODE;
 _GLOBAL_CONST signed short XML_IEC_MODE;
 _GLOBAL_CONST signed short XML_PTR_REPR;
 _GLOBAL_CONST signed short XML_VAL_REPR;
 _GLOBAL_CONST signed short XML_BOOL_TYPE;
 _GLOBAL_CONST signed short XML_INT2_TYPE;
 _GLOBAL_CONST signed short XML_INT4_TYPE;
 _GLOBAL_CONST signed short XML_TIME_TYPE;
 _GLOBAL_CONST signed short XML_ARRAY_TYPE;
 _GLOBAL_CONST signed short XML_BIG_ENDIAN;
 _GLOBAL_CONST signed short XML_BINARY_TYPE;
 _GLOBAL_CONST signed short XML_DOUBLE_TYPE;
 _GLOBAL_CONST signed short XML_STRING_TYPE;
 _GLOBAL_CONST signed short XML_STRUCT_TYPE;
 _GLOBAL_CONST signed short XML_LITTLE_ENDIAN;
#endif







/* Prototyping of functions and function blocks */
_BUR_PUBLIC unsigned long xml_MakeStream(unsigned long ident, unsigned long* len, unsigned long data);
_BUR_PUBLIC unsigned long xml_MakeCmdStream(unsigned long ident, unsigned long* len, unsigned long data, unsigned long str);
_BUR_PUBLIC plcbit xml_DeleteStream(unsigned long ident, unsigned long xmlstr, unsigned long len);
_BUR_PUBLIC unsigned long xml_LoadMIdent(unsigned long ident);
_BUR_PUBLIC unsigned long xml_DumpMIdent(unsigned long ident);
_BUR_PUBLIC plcbit xml_MEnd(unsigned long ident);
_BUR_PUBLIC plcbit xml_StructClose(unsigned long ident);
_BUR_PUBLIC plcbit xml_AddStruct(unsigned long ident, signed short reprtype, signed short numelem);
_BUR_PUBLIC plcbit xml_CloseArray(unsigned long ident);
_BUR_PUBLIC plcbit xml_AddArray(unsigned long ident, signed short reptype, unsigned long namestr, unsigned long numelem);
_BUR_PUBLIC plcbit xml_AddValue(unsigned long ident, signed short valtype, signed short reptype, unsigned long nameStr, unsigned long len);
_BUR_PUBLIC unsigned long xml_MCreate(unsigned long name, signed short type, signed short arch, unsigned long len, signed short isNoPtr);


#ifdef __cplusplus
};
#endif
#endif /* _XML_MRSH_ */

