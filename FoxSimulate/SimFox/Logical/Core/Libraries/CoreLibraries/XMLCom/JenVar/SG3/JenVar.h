/* Automation Studio generated header file */
/* Do not edit ! */
/* JenVar 0.24.0 */

#ifndef _JENVAR_
#define _JENVAR_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _JenVar_VERSION
#define _JenVar_VERSION 0.24.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
		#include "AsString.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define JENVAR_STRUCT_TO_BIG 50307U
 #define JENVAR_ENABLE_IS_NULL 50300U
 #define JENVAR_NO_IDENT_GIVEN 50301U
 #define JENVAR_STRUCT_TO_SMALL 50306U
 #define JENVAR_ERROR_GETVARDATA 50309U
 #define JENVAR_NO_VARIABLE_NAME 50302U
 #define JENVAR_NO_VARIABLE_STRUCTUR 50303U
 #define JENVAR_PVARSTRUCT_NOT_GIVEN 50304U
 #define JENVAR_VAR_NUMBER_NOT_GIVEN 50305U
#else
 _GLOBAL_CONST unsigned short JENVAR_STRUCT_TO_BIG;
 _GLOBAL_CONST unsigned short JENVAR_ENABLE_IS_NULL;
 _GLOBAL_CONST unsigned short JENVAR_NO_IDENT_GIVEN;
 _GLOBAL_CONST unsigned short JENVAR_STRUCT_TO_SMALL;
 _GLOBAL_CONST unsigned short JENVAR_ERROR_GETVARDATA;
 _GLOBAL_CONST unsigned short JENVAR_NO_VARIABLE_NAME;
 _GLOBAL_CONST unsigned short JENVAR_NO_VARIABLE_STRUCTUR;
 _GLOBAL_CONST unsigned short JENVAR_PVARSTRUCT_NOT_GIVEN;
 _GLOBAL_CONST unsigned short JENVAR_VAR_NUMBER_NOT_GIVEN;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct JenVarStruct_typ
{	unsigned long pName;
	unsigned short Dimension;
	unsigned long Type;
	unsigned long Len;
	unsigned long VarAddress;
	unsigned long Adr_Parent;
	unsigned long Adr_NextSister;
	unsigned long Adr_PrevSister;
	unsigned long Adr_Child;
} JenVarStruct_typ;

typedef struct JenVarAdrList_typ
{	unsigned long DataTyp;
	unsigned long Address;
	unsigned long Len;
} JenVarAdrList_typ;

typedef struct JenVarNameList_typ
{	unsigned long Adr;
	unsigned long Size;
} JenVarNameList_typ;

typedef struct CreateVariableAddressList
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	/* VAR_OUTPUT (analog) */
	unsigned long Adr_VariableAddressList;
	unsigned short status;
	/* VAR_INPUT (digital) */
	plcbit enable;
	plcbit createOffset;
} CreateVariableAddressList_typ;

typedef struct GetVariableData
{
	/* VAR_INPUT (analog) */
	unsigned long pVarName;
	/* VAR_OUTPUT (analog) */
	unsigned long pVarStruct;
	unsigned long CountVariables;
	unsigned long Ident;
	unsigned short status;
	/* VAR_INPUT (digital) */
	plcbit enable;
} GetVariableData_typ;

typedef struct CreateVariableNameList
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	/* VAR_OUTPUT (analog) */
	unsigned long AdrVariableNameList;
	unsigned short status;
	/* VAR_INPUT (digital) */
	plcbit enable;
} CreateVariableNameList_typ;

typedef struct DestroyVariableData
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	/* VAR_OUTPUT (analog) */
	unsigned short status;
	/* VAR_INPUT (digital) */
	plcbit enable;
} DestroyVariableData_typ;

typedef struct GetVariableData_Mem
{
	/* VAR_INPUT (analog) */
	unsigned long pVarName;
	unsigned long oldIdent;
	/* VAR_OUTPUT (analog) */
	unsigned long pVarStruct;
	unsigned long countVariables;
	unsigned long ident;
	unsigned short status;
	/* VAR_INPUT (digital) */
	plcbit enable;
} GetVariableData_Mem_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC void CreateVariableAddressList(struct CreateVariableAddressList* inst);
_BUR_PUBLIC void GetVariableData(struct GetVariableData* inst);
_BUR_PUBLIC void CreateVariableNameList(struct CreateVariableNameList* inst);
_BUR_PUBLIC void DestroyVariableData(struct DestroyVariableData* inst);
_BUR_PUBLIC void GetVariableData_Mem(struct GetVariableData_Mem* inst);


#ifdef __cplusplus
};
#endif
#endif /* _JENVAR_ */

