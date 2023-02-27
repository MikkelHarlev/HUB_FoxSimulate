/* Automation Studio generated header file */
/* Do not edit ! */
/* LogLib 0.35.1 */

#ifndef _LOGLIB_
#define _LOGLIB_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _LogLib_VERSION
#define _LogLib_VERSION 0.35.1
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
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define LOGLIB_BUSY 65535U
 #define LOGLIB_BUFFER_FULL 50410U
 #define LOGLIB_IDENT_IS_NULL 50409U
 #define LOGLIB_SIZE_TO_SMALL 50412U
 #define LOGLIB_ENABLE_IS_NULL 50400U
 #define LOGLIB_LOGINIT_FAILED 50413U
 #define LOGLIB_MAX_ENTRYS_IS_NULL 50401U
 #define LOGLIB_FILE_NAME_NOT_GIVEN 50404U
 #define LOGLIB_ERROR_SIZE_LOGBUFFER 50411U
 #define LOGLIB_LOG_BUFFER_NOT_GIVEN 50405U
 #define LOGLIB_WRITE_DATA_NOT_GIVEN 50406U
 #define LOGLIB_FILE_DEVICE_NOT_GIVEN 50403U
 #define LOGLIB_SIZE_LOG_BUFFER_IS_NULL 50402U
 #define LOGLIB_ERROR_CONTROL_FILEHEADER 50408U
 #define LOGLIB_VAR_FORMAT_NOT_SUPPORTED 50407U
 #define LOGLIB_ADDRESS_READ_DATA_IS_NULL 50412U
#else
 _GLOBAL_CONST unsigned short LOGLIB_BUSY;
 _GLOBAL_CONST unsigned short LOGLIB_BUFFER_FULL;
 _GLOBAL_CONST unsigned short LOGLIB_IDENT_IS_NULL;
 _GLOBAL_CONST unsigned short LOGLIB_SIZE_TO_SMALL;
 _GLOBAL_CONST unsigned short LOGLIB_ENABLE_IS_NULL;
 _GLOBAL_CONST unsigned short LOGLIB_LOGINIT_FAILED;
 _GLOBAL_CONST unsigned short LOGLIB_MAX_ENTRYS_IS_NULL;
 _GLOBAL_CONST unsigned short LOGLIB_FILE_NAME_NOT_GIVEN;
 _GLOBAL_CONST unsigned short LOGLIB_ERROR_SIZE_LOGBUFFER;
 _GLOBAL_CONST unsigned short LOGLIB_LOG_BUFFER_NOT_GIVEN;
 _GLOBAL_CONST unsigned short LOGLIB_WRITE_DATA_NOT_GIVEN;
 _GLOBAL_CONST unsigned short LOGLIB_FILE_DEVICE_NOT_GIVEN;
 _GLOBAL_CONST unsigned short LOGLIB_SIZE_LOG_BUFFER_IS_NULL;
 _GLOBAL_CONST unsigned short LOGLIB_ERROR_CONTROL_FILEHEADER;
 _GLOBAL_CONST unsigned short LOGLIB_VAR_FORMAT_NOT_SUPPORTED;
 _GLOBAL_CONST unsigned short LOGLIB_ADDRESS_READ_DATA_IS_NULL;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct LogSetLineRead
{
	/* VAR_INPUT (analog) */
	unsigned long ident;
	/* VAR_OUTPUT (analog) */
	unsigned short status;
	/* VAR_INPUT (digital) */
	plcbit enable;
} LogSetLineRead_typ;

typedef struct LogRead
{
	/* VAR_INPUT (analog) */
	unsigned long ident;
	unsigned long adrReadData;
	unsigned long sizeofReadData;
	/* VAR_OUTPUT (analog) */
	unsigned long entries_read;
	unsigned short status;
	/* VAR_INPUT (digital) */
	plcbit enable;
	plcbit startFirstEntry;
} LogRead_typ;

typedef struct LogStore
{
	/* VAR_INPUT (analog) */
	unsigned long ident;
	/* VAR_OUTPUT (analog) */
	unsigned short status;
	/* VAR_INPUT (digital) */
	plcbit enable;
} LogStore_typ;

typedef struct LogWrite
{
	/* VAR_INPUT (analog) */
	unsigned long ident;
	unsigned long AdrWriteData;
	/* VAR_OUTPUT (analog) */
	unsigned short status;
	/* VAR_INPUT (digital) */
	plcbit enable;
} LogWrite_typ;

typedef struct LogInit
{
	/* VAR_INPUT (analog) */
	unsigned short EntrysLogfile;
	unsigned long sizeLogbuffer;
	unsigned long pNameDevice;
	unsigned long pNameFile;
	unsigned long AdrLogbuffer;
	unsigned long pNameWriteData;
	unsigned long pIndexName;
	/* VAR_OUTPUT (analog) */
	unsigned long ident;
	unsigned long Ident_JenXML;
	unsigned long AdrNameArray;
	unsigned long CountVariables;
	plcstring ErrStringInfo[33];
	plcstring ErrStringDetail[33];
	unsigned short status;
	/* VAR_INPUT (digital) */
	plcbit enable;
} LogInit_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC void LogSetLineRead(struct LogSetLineRead* inst);
_BUR_PUBLIC void LogRead(struct LogRead* inst);
_BUR_PUBLIC void LogStore(struct LogStore* inst);
_BUR_PUBLIC void LogWrite(struct LogWrite* inst);
_BUR_PUBLIC void LogInit(struct LogInit* inst);


#ifdef __cplusplus
};
#endif
#endif /* _LOGLIB_ */

