/* Automation Studio generated header file */
/* Do not edit ! */
/* BRSE_STF 1.03.0 */

#ifndef _BRSE_STF_
#define _BRSE_STF_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _BRSE_STF_VERSION
#define _BRSE_STF_VERSION 1.03.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG3
		#include "SYS_LIB.h"
		#include "FileIO.h"
		#include "AsTime.h"
		#include "AsString.h"
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
		#include "FileIO.h"
		#include "AsTime.h"
		#include "AsString.h"
#endif
#ifdef _SGC
		#include "SYS_LIB.h"
		#include "FileIO.h"
		#include "AsTime.h"
		#include "AsString.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define FUNCTION_BUSY 65535U
 #define PAR_DELIM "."
 #define LOG_MAX 50U
 #define BRSE_LINE_DELIM "\r\n"
 #define BRSE_LINE_COMMENT "/"
 #define BRSE_PARAM_DELIM ","
 #define BRSE_PARAM_DELIM_V2 ";"
 #define STF_ERR_FILE_NOT_FOUND 20708U
 #define STF_ERR_EOF_CORRUPT 5020U
 #define STF_ERR_CHECKSUM 5021U
 #define STF_NO_VERSION 5022U
 #define STF_WARN_OLD_VERSION 31U
 #define STF_WARN_TYPE_ERROR 34U
#else
 _GLOBAL_CONST unsigned short FUNCTION_BUSY;
 _GLOBAL_CONST plcstring PAR_DELIM[2];
 _GLOBAL_CONST unsigned short LOG_MAX;
 _GLOBAL_CONST plcstring BRSE_LINE_DELIM[5];
 _GLOBAL_CONST plcstring BRSE_LINE_COMMENT[2];
 _GLOBAL_CONST plcstring BRSE_PARAM_DELIM[2];
 _GLOBAL_CONST plcstring BRSE_PARAM_DELIM_V2[2];
 _GLOBAL_CONST unsigned short STF_ERR_FILE_NOT_FOUND;
 _GLOBAL_CONST unsigned short STF_ERR_EOF_CORRUPT;
 _GLOBAL_CONST unsigned short STF_ERR_CHECKSUM;
 _GLOBAL_CONST unsigned short STF_NO_VERSION;
 _GLOBAL_CONST unsigned short STF_WARN_OLD_VERSION;
 _GLOBAL_CONST unsigned short STF_WARN_TYPE_ERROR;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct StructState_typ
{	plcstring StructName[34];
	unsigned short CurrentItemNbr;
	unsigned short Dimension;
	unsigned char ItemType;
} StructState_typ;

typedef struct BRSE_STF_GetFullName
{
	/* VAR_INPUT (analog) */
	struct StructState_typ (*pStructStates)[10];
	unsigned long pFullName;
	unsigned long FullNameSize;
	unsigned char* CurrentDepth;
	/* VAR (analog) */
	unsigned char TmpUsint;
	plcstring TmpString[21];
} BRSE_STF_GetFullName_typ;

typedef struct BRSE_STF_AppendStructToFile
{
	/* VAR_INPUT (analog) */
	struct StructState_typ (*pStructStates)[10];
	unsigned long pFullName;
	struct FileWrite* pFB_FileWrite;
	unsigned long* pFileOffset;
	unsigned long pMemBuf;
	unsigned long MemBufSize;
	unsigned long MaxExecutionMs;
	unsigned char Options;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	signed long Checksum;
	unsigned long StructToFileSize;
	unsigned char Progress;
	/* VAR (analog) */
	unsigned short Step;
	unsigned char CurrentDepth;
	unsigned long DataType;
	unsigned long DataLen;
	unsigned long DataAdr;
	unsigned short ErrorStatus;
	signed long TmpDint;
	float TmpReal;
	unsigned long TmpAdr;
	plcstring TmpString[21];
	struct BRSE_STF_GetFullName GetFullName;
	unsigned char TmpByte;
	unsigned long StructSize;
	unsigned long WrittenSize;
	plctime TEnter;
	plctime TElapsed;
	unsigned long TmpOffset;
	unsigned short NextStep;
	/* VAR (digital) */
	plcbit CanRepeat;
} BRSE_STF_AppendStructToFile_typ;

typedef struct BRSE_STF_StructToFile
{
	/* VAR_INPUT (analog) */
	plcstring FullName[332];
	unsigned long pDevice;
	unsigned long pFileName;
	unsigned long MaxExecutionMs;
	unsigned short Version;
	unsigned char Options;
	/* VAR_OUTPUT (analog) */
	unsigned char Progress;
	unsigned short Status;
	/* VAR (analog) */
	struct StructState_typ StructStates[10];
	plcstring MemBuf[501];
	struct FileDelete FB_FileDelete;
	struct FileCreate FB_FileCreate;
	struct FileWrite FB_FileWrite;
	struct FileClose FB_FileClose;
	struct BRSE_STF_AppendStructToFile FB_AppendStructToFile;
	unsigned short Step;
	unsigned short ErrorStatus;
	unsigned short NextState;
	unsigned long FileOffset;
	struct DTGetTime FB_GetDT;
	plcstring TmpString[31];
	signed long Checksum;
	plctime TEnter;
	plctime TElapsed;
	/* VAR (digital) */
	plcbit CanRepeat;
} BRSE_STF_StructToFile_typ;

typedef struct BRSE_STF_GetChecksum
{
	/* VAR_INPUT (analog) */
	struct FileRead* pFB_FileRead;
	unsigned long pMemBuf;
	unsigned long MemBufSize;
	unsigned long OffsetStart;
	unsigned long OffsetEnd;
	/* VAR_OUTPUT (analog) */
	signed long Checksum;
	unsigned short Status;
	/* VAR (analog) */
	unsigned short ErrorStatus;
	unsigned short Step;
	unsigned long CurrentOffset;
	plctime TEnter;
	plctime TElapsed;
	unsigned char TmpByte;
	/* VAR (digital) */
	plcbit CanRepeat;
} BRSE_STF_GetChecksum_typ;

typedef struct BRSE_STF_FileToStruct
{
	/* VAR_INPUT (analog) */
	unsigned long pDevice;
	unsigned long pFileName;
	unsigned long MaxExecutionMs;
	/* VAR_OUTPUT (analog) */
	unsigned char Progress;
	unsigned short Status;
	unsigned short Version;
	plcstring StatusMessage[332];
	/* VAR (analog) */
	plcstring FullName[332];
	struct FileOpen FB_FileOpen;
	struct FileRead FB_FileRead;
	struct FileClose FB_FileClose;
	unsigned short Step;
	unsigned short ErrorStatus;
	unsigned char MemBuf[500];
	unsigned long FileOffset;
	unsigned char TmpByte;
	unsigned long TmpOffset;
	unsigned short NextStep;
	unsigned long ReadLen;
	plcstring TmpString[31];
	unsigned long OffsetStart;
	unsigned long DataType;
	unsigned long DataLen;
	unsigned short Dimension;
	unsigned char TmpUsint;
	signed long TmpDint;
	unsigned long TmpAdr;
	unsigned char InitialError;
	float TmpReal;
	struct BRSE_STF_GetChecksum GetChecksum;
	unsigned short WarningStatus;
	plctime TEnter;
	plctime TElapsed;
	/* VAR_INPUT (digital) */
	plcbit EnableChecksum;
	/* VAR (digital) */
	plcbit OldVersion;
	plcbit CanRepeat;
} BRSE_STF_FileToStruct_typ;

typedef struct BRSE_STF_ValidateFile
{
	/* VAR_INPUT (analog) */
	unsigned long pDevice;
	unsigned long pFileName;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	unsigned short Version;
	/* VAR (analog) */
	plcstring FullName[332];
	struct FileOpen FB_FileOpen;
	struct FileRead FB_FileRead;
	struct FileClose FB_FileClose;
	unsigned short Step;
	unsigned short ErrorStatus;
	unsigned char MemBuf[500];
	unsigned char TmpByte;
	unsigned long TmpOffset;
	plcstring TmpString[31];
	unsigned char TmpUsint;
	unsigned long OffsetStart;
	signed long TmpDint;
	struct BRSE_STF_GetChecksum GetChecksum;
	/* VAR_INPUT (digital) */
	plcbit EnableChecksum;
} BRSE_STF_ValidateFile_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC void BRSE_STF_AppendStructToFile(struct BRSE_STF_AppendStructToFile* inst);
_BUR_PUBLIC void BRSE_STF_GetFullName(struct BRSE_STF_GetFullName* inst);
_BUR_PUBLIC void BRSE_STF_StructToFile(struct BRSE_STF_StructToFile* inst);
_BUR_PUBLIC void BRSE_STF_FileToStruct(struct BRSE_STF_FileToStruct* inst);
_BUR_PUBLIC void BRSE_STF_ValidateFile(struct BRSE_STF_ValidateFile* inst);
_BUR_PUBLIC void BRSE_STF_GetChecksum(struct BRSE_STF_GetChecksum* inst);


#ifdef __cplusplus
};
#endif
#endif /* _BRSE_STF_ */

