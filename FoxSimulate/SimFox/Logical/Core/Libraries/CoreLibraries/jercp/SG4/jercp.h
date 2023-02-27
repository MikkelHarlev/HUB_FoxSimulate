/* Automation Studio generated header file */
/* Do not edit ! */
/* jercp 6.01.0 */

#ifndef _JERCP_
#define _JERCP_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _jercp_VERSION
#define _jercp_VERSION 6.01.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
		#include "FileIO.h"
		#include "AsTime.h"
		#include "AsString.h"
		#include "AsMem.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define JERCP_BUSY 65535U
 #define JERCP_FILENAME_TOO_LONG 50240U
 #define JERCP_GETNAMES_ARRAY_TOO_SMALL 50239U
 #define JERCP_GETNAMES_LINES_ARRAY 50238U
 #define JERCP_GETNAMES_SIZE_ARRAY 50237U
 #define JERCP_GETNAMES_NO_ARRAY 50236U
 #define JERCP_NO_FILENAME 50235U
 #define JERCP_ACT_PAR_VALUE_SIZE_0 50234U
 #define JERCP_ACT_PAR_VALUE_MISSING 50233U
 #define JERCP_FUNC_NOT_CONFIGURED 50232U
 #define JERCP_PAR_NAME_STRING_SIZE 50231U
 #define JERCP_PAR_NAME_ARRAY_SIZE_0 50230U
 #define JERCP_PAR_NAME_ARRAY_MISSING 50229U
 #define JERCP_COPY_RANGE_TOO_HIGH 50228U
 #define JERCP_ADD_NOT_POSSIBLE 50227U
 #define JERCP_NO_POINTERIDENT 50226U
 #define JERCP_RCPDIRLIST_NOT_DONE 50225U
 #define JERCP_ARRAY_SIZE_0 50224U
 #define JERCP_VAR_SIZE_0 50223U
 #define JERCP_NO_POINTER_NAME 50222U
 #define JERCP_RECIPEINDEX_TO_BIG 50221U
 #define JERCP_RECIPE_NOT_EXIST 50220U
 #define JERCP_NO_RECIPE_FILE_LOADED 50219U
 #define JERCP_PARSCROINIT_FUB_NOT_DONE 50216U
 #define JERCP_PAR_VALUE_ARRAY_SIZE_0 50215U
 #define JERCP_LINES_PAR_SCROLL_0 50214U
 #define JERCP_PAR_SCROLL_SIZE_0 50213U
 #define JERCP_PAR_VALUE_ARRAY_MISSING 50212U
 #define JERCP_PAR_SCROLL_ARRAY_MISSING 50211U
 #define JERCP_LOAD_INVALID_STRUCT 50210U
 #define JERCP_LOAD_VAR_NO_STRUCT 50209U
 #define JERCP_ERROR_IN_CSV_FILE 50208U
 #define JERCP_NO_DEVICE 50206U
 #define JERCP_SIZE_RECIPE_INFO_STRUCT 50205U
 #define JERCP_NO_RECIPE_INFO_STRUCT_NAME 50204U
 #define JERCP_NO_RECIPE_STRUCT_NAME 50203U
 #define JERCP_WRONG_IDENT 50202U
 #define JERCP_NO_IDENT 50201U
 #define JERCP_ENABLE_0 50200U
 #define JERCP_LANG_NUMBERS 20U
 #define JERCP_LEVEL_NOT_ALLOWED 0U
#else
 _GLOBAL_CONST unsigned short JERCP_BUSY;
 _GLOBAL_CONST unsigned short JERCP_FILENAME_TOO_LONG;
 _GLOBAL_CONST unsigned short JERCP_GETNAMES_ARRAY_TOO_SMALL;
 _GLOBAL_CONST unsigned short JERCP_GETNAMES_LINES_ARRAY;
 _GLOBAL_CONST unsigned short JERCP_GETNAMES_SIZE_ARRAY;
 _GLOBAL_CONST unsigned short JERCP_GETNAMES_NO_ARRAY;
 _GLOBAL_CONST unsigned short JERCP_NO_FILENAME;
 _GLOBAL_CONST unsigned short JERCP_ACT_PAR_VALUE_SIZE_0;
 _GLOBAL_CONST unsigned short JERCP_ACT_PAR_VALUE_MISSING;
 _GLOBAL_CONST unsigned short JERCP_FUNC_NOT_CONFIGURED;
 _GLOBAL_CONST unsigned short JERCP_PAR_NAME_STRING_SIZE;
 _GLOBAL_CONST unsigned short JERCP_PAR_NAME_ARRAY_SIZE_0;
 _GLOBAL_CONST unsigned short JERCP_PAR_NAME_ARRAY_MISSING;
 _GLOBAL_CONST unsigned short JERCP_COPY_RANGE_TOO_HIGH;
 _GLOBAL_CONST unsigned short JERCP_ADD_NOT_POSSIBLE;
 _GLOBAL_CONST unsigned short JERCP_NO_POINTERIDENT;
 _GLOBAL_CONST unsigned short JERCP_RCPDIRLIST_NOT_DONE;
 _GLOBAL_CONST unsigned short JERCP_ARRAY_SIZE_0;
 _GLOBAL_CONST unsigned short JERCP_VAR_SIZE_0;
 _GLOBAL_CONST unsigned short JERCP_NO_POINTER_NAME;
 _GLOBAL_CONST unsigned short JERCP_RECIPEINDEX_TO_BIG;
 _GLOBAL_CONST unsigned short JERCP_RECIPE_NOT_EXIST;
 _GLOBAL_CONST unsigned short JERCP_NO_RECIPE_FILE_LOADED;
 _GLOBAL_CONST unsigned short JERCP_PARSCROINIT_FUB_NOT_DONE;
 _GLOBAL_CONST unsigned short JERCP_PAR_VALUE_ARRAY_SIZE_0;
 _GLOBAL_CONST unsigned short JERCP_LINES_PAR_SCROLL_0;
 _GLOBAL_CONST unsigned short JERCP_PAR_SCROLL_SIZE_0;
 _GLOBAL_CONST unsigned short JERCP_PAR_VALUE_ARRAY_MISSING;
 _GLOBAL_CONST unsigned short JERCP_PAR_SCROLL_ARRAY_MISSING;
 _GLOBAL_CONST unsigned short JERCP_LOAD_INVALID_STRUCT;
 _GLOBAL_CONST unsigned short JERCP_LOAD_VAR_NO_STRUCT;
 _GLOBAL_CONST unsigned short JERCP_ERROR_IN_CSV_FILE;
 _GLOBAL_CONST unsigned short JERCP_NO_DEVICE;
 _GLOBAL_CONST unsigned short JERCP_SIZE_RECIPE_INFO_STRUCT;
 _GLOBAL_CONST unsigned short JERCP_NO_RECIPE_INFO_STRUCT_NAME;
 _GLOBAL_CONST unsigned short JERCP_NO_RECIPE_STRUCT_NAME;
 _GLOBAL_CONST unsigned short JERCP_WRONG_IDENT;
 _GLOBAL_CONST unsigned short JERCP_NO_IDENT;
 _GLOBAL_CONST unsigned short JERCP_ENABLE_0;
 _GLOBAL_CONST unsigned short JERCP_LANG_NUMBERS;
 _GLOBAL_CONST unsigned short JERCP_LEVEL_NOT_ALLOWED;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct RcpExtInfo_Type
{	unsigned long Ident;
	unsigned long adrActRcpData;
	unsigned short NumberOfRecipes;
	unsigned char NumberOfFiles;
	unsigned char MaxNumberOfFiles;
	plcstring RcpStructName[33];
	plcstring ErrStringInfo[41];
	plcstring ErrStringDetail[41];
	unsigned short Status;
} RcpExtInfo_Type;

typedef struct RcpShowLevel
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	plcstring VarName[201];
	unsigned char VarLevel;
	/* VAR_OUTPUT (analog) */
	unsigned char Status;
	unsigned short LineNumber;
	unsigned short ChangeCount;
	plcstring ChangeVarName[201];
	/* VAR (analog) */
	unsigned long pStart;
	unsigned long pEnd;
	/* VAR (digital) */
	plcbit InitState;
} RcpShowLevel_typ;

typedef struct RcpGetMemInfo
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned char cmdGetMemInfo;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	unsigned long NumberBytesFree;
	unsigned long MaxBlockSizeFree;
} RcpGetMemInfo_typ;

typedef struct RcpGetNames
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned long pRcpNameArray;
	unsigned short SizeRcpNameArray;
	unsigned short LinesRcpNameArray;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	plcstring ErrStringInfo[33];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} RcpGetNames_typ;

typedef struct RcpCopy
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned short RcpSourceNumber;
	unsigned short RcpDestBegin;
	unsigned short RcpDestEnd;
	unsigned char optCopySelectedPar;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	unsigned short NewRecipeNumber;
	plcstring ErrStringInfo[33];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} RcpCopy_typ;

typedef struct RcpNameList
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned char cmdInit;
	unsigned char cmdScrollUp;
	unsigned char cmdScrollDown;
	unsigned short cmdGotoIndex;
	/* VAR_OUTPUT (analog) */
	unsigned char SelectedItem;
	unsigned short RcpNumber;
	plcstring ErrStringInfo[33];
	unsigned short Status;
	/* VAR_INPUT (digital) */
	plcbit Enable;
} RcpNameList_typ;

typedef struct RcpPointInit
{
	/* VAR_INPUT (analog) */
	unsigned long pPointerName;
	unsigned long RcpInitIdent;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	unsigned long PointerIdent;
	plcstring ErrStringInfo[33];
} RcpPointInit_typ;

typedef struct RcpAdd
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	unsigned short NewRecipeNumber;
	plcstring ErrStringInfo[33];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} RcpAdd_typ;

typedef struct RcpInit
{
	/* VAR_INPUT (analog) */
	unsigned long pStructName;
	unsigned long pRcpInfoStruct;
	unsigned short LenRcpInfoStruct;
	unsigned long pFileNameArray;
	unsigned short SizeFileNameArray;
	unsigned short LinesFileNameArray;
	unsigned long SizeMemAlloc;
	unsigned char cfgWorkWithVar;
	unsigned char cfgCompressOn;
	unsigned short NumbersLang;
	/* VAR_OUTPUT (analog) */
	unsigned long Ident;
	unsigned short Status;
	unsigned long SizeMemAllocated;
	plcstring ErrStringInfo[101];
	plcstring ErrStringDetail[101];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} RcpInit_typ;

typedef struct RcpLoad
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned long pDevice;
	unsigned long pFileName;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	plcstring ErrStringInfo[101];
	plcstring ErrStringDetail[101];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} RcpLoad_typ;

typedef struct RcpSave
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned long pDevice;
	unsigned long pFileName;
	unsigned char optHeaderOnly;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	plcstring ErrStringInfo[101];
	plcstring ErrStringDetail[101];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} RcpSave_typ;

typedef struct RcpFileListScroll
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned char cmdUp;
	unsigned char cmdDown;
	unsigned char cmdInit;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	unsigned char SelectedItem;
	unsigned short ActFileNumber;
	plcstring ActFileName[33];
	plcstring ErrStringInfo[33];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} RcpFileListScroll_typ;

typedef struct ParScroInit
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned long pFileNameParLanguage;
	unsigned long pParScrollArray;
	unsigned long pParValueArray;
	unsigned long pParNameArray;
	unsigned long pParNameString;
	unsigned long pActParValue;
	unsigned long pDevice;
	unsigned short SizeParScrollArray;
	unsigned short SizeParValueArray;
	unsigned short SizeParNameArray;
	unsigned short SizeActParValue;
	unsigned short LinesParScrollArray;
	unsigned short LinesParNameArray;
	unsigned long AdrTimerVisibility;
	unsigned short SizeTimerVisibility;
	unsigned long pVarNameArray;
	unsigned short SizeVarNameArray;
	unsigned short LinesVarNameArray;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	plcstring ErrStringInfo[33];
	plcstring ErrStringDetail[33];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} ParScroInit_typ;

typedef struct ParScroCyclic
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned char cmdInit;
	unsigned char cmdUp;
	unsigned char cmdDown;
	unsigned char cmdLangSwitch;
	unsigned short cmdSearchPlace;
	unsigned short cmdSearch;
	plcstring SearchVariable[51];
	unsigned char cmdEditPar;
	unsigned char cmdRcpChange;
	unsigned char cmdJumpFirst;
	unsigned char ActLanguage;
	unsigned short SelectRcpNumber;
	unsigned char ShowLevel;
	unsigned short cmdGotoIndex;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	unsigned short ActParNumber;
	unsigned char SelectedItem;
	plcstring ErrStringInfo[33];
	unsigned short ItemCount;
	/* VAR_INPUT (digital) */
	plcbit Enable;
} ParScroCyclic_typ;

typedef struct RcpDeInit
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	plcstring ErrStringInfo[33];
	plcstring ErrStringDetail[33];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} RcpDeInit_typ;

typedef struct RcpDirList
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned long pDevice;
	unsigned long pFileExtFilter;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	plcstring ErrStringInfo[33];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} RcpDirList_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC void RcpShowLevel(struct RcpShowLevel* inst);
_BUR_PUBLIC void RcpGetMemInfo(struct RcpGetMemInfo* inst);
_BUR_PUBLIC void RcpGetNames(struct RcpGetNames* inst);
_BUR_PUBLIC void RcpCopy(struct RcpCopy* inst);
_BUR_PUBLIC void RcpNameList(struct RcpNameList* inst);
_BUR_PUBLIC void RcpPointInit(struct RcpPointInit* inst);
_BUR_PUBLIC void RcpAdd(struct RcpAdd* inst);
_BUR_PUBLIC void RcpInit(struct RcpInit* inst);
_BUR_PUBLIC void RcpLoad(struct RcpLoad* inst);
_BUR_PUBLIC void RcpSave(struct RcpSave* inst);
_BUR_PUBLIC void RcpFileListScroll(struct RcpFileListScroll* inst);
_BUR_PUBLIC void ParScroInit(struct ParScroInit* inst);
_BUR_PUBLIC void ParScroCyclic(struct ParScroCyclic* inst);
_BUR_PUBLIC void RcpDeInit(struct RcpDeInit* inst);
_BUR_PUBLIC void RcpDirList(struct RcpDirList* inst);
_BUR_PUBLIC unsigned short RcpPointRef(unsigned long RcpInitIdent, unsigned long PointerIdent, unsigned short Index);


#ifdef __cplusplus
};
#endif
#endif /* _JERCP_ */

