/* Automation Studio generated header file */
/* Do not edit ! */
/* CLib 0.15.0 */

#ifndef _CLIB_
#define _CLIB_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _CLib_VERSION
#define _CLib_VERSION 0.15.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
		#include "standard.h"
		#include "FileIO.h"
		#include "AsTime.h"
		#include "AsString.h"
		#include "AsMem.h"
		#include "AsUSB.h"
		#include "JEGR_Coop.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define IDLE 0U
 #define CONNECT_FILE 61U
 #define DISCONNECT_FILE 51U
 #define MAP_DATA_TO_BUFFER 4U
 #define MAP_FILE_TO_BUFFER 41U
 #define ENABLE_SECURE_WRITE 91U
 #define MAP_STRUCT_TO_BUFFER 3U
 #define WRITE_BUFFER_TO_FILE 31U
#else
 _GLOBAL_CONST unsigned char IDLE;
 _GLOBAL_CONST unsigned char CONNECT_FILE;
 _GLOBAL_CONST unsigned char DISCONNECT_FILE;
 _GLOBAL_CONST unsigned char MAP_DATA_TO_BUFFER;
 _GLOBAL_CONST unsigned char MAP_FILE_TO_BUFFER;
 _GLOBAL_CONST unsigned char ENABLE_SECURE_WRITE;
 _GLOBAL_CONST unsigned char MAP_STRUCT_TO_BUFFER;
 _GLOBAL_CONST unsigned char WRITE_BUFFER_TO_FILE;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct JFESettings_Type
{	unsigned char ColumnNameLevel;
	plcbit SecureWrite;
	unsigned long HeaderIdent;
	unsigned long SplitChar;
	plcbit CreateFile;
} JFESettings_Type;

typedef struct Element_Type
{	plcstring FullName[65];
	plcstring Name[33];
	unsigned long Address;
	unsigned long Length;
	unsigned char Type;
} Element_Type;

typedef struct Entry_Type
{	plcstring Name[33];
	unsigned short Elements;
	struct Element_Type Element[64];
} Entry_Type;

typedef struct FileHandler_Type
{	unsigned short wStatus;
	unsigned short wError;
	unsigned char fCommand;
	unsigned long dwIdent;
	unsigned long FOpen;
	unsigned long FCreate;
	unsigned long FWrite;
	unsigned long FRead;
	unsigned long FClose;
	unsigned long FDelete;
	unsigned long DCreate;
	unsigned long DClose;
	unsigned long FCopy;
	unsigned char FileStatus;
	plcstring arrDirs[10][81];
	unsigned char NumDirs;
	unsigned char NumCurDir;
	plcbit DirStatus;
	plcstring FullFileName[81];
	unsigned long SplitChar;
	unsigned long Offset;
	unsigned char Buffer[4000];
	unsigned long BufferLen;
	unsigned long DevLink;
	unsigned long MemPartIdent;
	unsigned long ReadMemIdent;
	unsigned long BufferMemIdent;
} FileHandler_Type;

typedef struct FlatVar_Type
{	unsigned long Data_Len;
	unsigned long Data_Type;
	unsigned short Data_Dimensions;
	unsigned long Length;
	plcstring StatusString[81];
	unsigned char State;
	struct Entry_Type Entries;
	struct FileHandler_Type FileHandler;
	unsigned long FileHeaderLines;
	unsigned long FileDataLines;
	unsigned long HeaderIdent;
} FlatVar_Type;

typedef struct FlattenVar
{
	/* VAR_INPUT (analog) */
	unsigned char Command;
	struct JFESettings_Type Settings;
	unsigned long pDirectory;
	unsigned long pFile;
	unsigned long pDeviceCreator;
	unsigned long pDevice;
	plcstring VarName[81];
	unsigned long memAllocSize;
	/* VAR_OUTPUT (analog) */
	unsigned char Status;
	/* VAR (analog) */
	unsigned long Ident;
} FlattenVar_typ;

typedef struct USBDisk
{
	/* VAR_INPUT (analog) */
	unsigned short PullInterval;
	plcstring USBDevice[33];
	unsigned long FileDeviceName;
	/* VAR_OUTPUT (analog) */
	plcstring StatusString[81];
	unsigned short Status;
	unsigned long ProductID;
	unsigned long VendorID;
	/* VAR (analog) */
	unsigned long Ident;
	/* VAR_INPUT (digital) */
	plcbit Run;
} USBDisk_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC void FlattenVar(struct FlattenVar* inst);
_BUR_PUBLIC void USBDisk(struct USBDisk* inst);
_BUR_PUBLIC unsigned short ConvIntToAscii(unsigned short Conv_Type, unsigned long AdrValueString, unsigned short StringLength, unsigned long AdrVar);


#ifdef __cplusplus
};
#endif
#endif /* _CLIB_ */

