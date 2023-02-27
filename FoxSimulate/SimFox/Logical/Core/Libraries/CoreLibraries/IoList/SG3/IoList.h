/* Automation Studio generated header file */
/* Do not edit ! */
/* IoList  */

#ifndef _IOLIST_
#define _IOLIST_
#ifdef __cplusplus
extern "C" 
{
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG3
		#include "SYS_LIB.h"
		#include "FileIO.h"
		#include "DataObj.h"
		#include "AsTime.h"
		#include "AsString.h"
		#include "AsMem.h"
		#include "AsIO.h"
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
		#include "FileIO.h"
		#include "DataObj.h"
		#include "AsTime.h"
		#include "AsString.h"
		#include "AsMem.h"
		#include "AsIO.h"
#endif
#ifdef _SGC
		#include "SYS_LIB.h"
		#include "FileIO.h"
		#include "DataObj.h"
		#include "AsTime.h"
		#include "AsString.h"
		#include "AsMem.h"
		#include "AsIO.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define IOLIST_ADDRESS_INFO_STRING 50114U
 #define IOLIST_DESCR_TABLE_MISSING 50113U
 #define IOLIST_DMNAMES_STRLEN_TOO_SHORT 50111U
 #define IOLIST_ENABLE_0 50100U
 #define IOLIST_FORCE_ANALOG_NOT_CONFIG 50119U
 #define IOLIST_FORCE_DIGITAL_NOT_CONFIG 50118U
 #define IOLIST_FORCE_IO_NOT_ENABLE 50120U
 #define IOLIST_FORCE_SELECT_IO_TYPE 50117U
 #define IOLIST_NO_IDENT 50101U
 #define IOLIST_VARSIZE_AI_STATE 50107U
 #define IOLIST_VARSIZE_AO_STATE 50108U
 #define IOLIST_VARSIZE_ARRAYINFO_SET 50112U
 #define IOLIST_VARSIZE_A_FORCE 50116U
 #define IOLIST_VARSIZE_A_SET 50110U
 #define IOLIST_VARSIZE_DI_STATE 50105U
 #define IOLIST_VARSIZE_DO_STATE 50106U
 #define IOLIST_VARSIZE_D_FORCE 50115U
 #define IOLIST_VARSIZE_D_SET 50109U
 #define IOLIST_WINDOW_ARRAY_MISSING 50104U
 #define IOLIST_WRONG_IDENT 50102U
 #define IOLIST_WRONG_IOTYPE 50103U
 #define IO_LIST_AI_LIST 2U
 #define IO_LIST_ALL_LIST 6U
 #define IO_LIST_AO_LIST 3U
 #define IO_LIST_A_LIST 5U
 #define IO_LIST_DI_LIST 0U
 #define IO_LIST_DO_LIST 1U
 #define IO_LIST_D_LIST 4U
#else
 _GLOBAL_CONST unsigned short IOLIST_ADDRESS_INFO_STRING;
 _GLOBAL_CONST unsigned short IOLIST_DESCR_TABLE_MISSING;
 _GLOBAL_CONST unsigned short IOLIST_DMNAMES_STRLEN_TOO_SHORT;
 _GLOBAL_CONST unsigned short IOLIST_ENABLE_0;
 _GLOBAL_CONST unsigned short IOLIST_FORCE_ANALOG_NOT_CONFIG;
 _GLOBAL_CONST unsigned short IOLIST_FORCE_DIGITAL_NOT_CONFIG;
 _GLOBAL_CONST unsigned short IOLIST_FORCE_IO_NOT_ENABLE;
 _GLOBAL_CONST unsigned short IOLIST_FORCE_SELECT_IO_TYPE;
 _GLOBAL_CONST unsigned short IOLIST_NO_IDENT;
 _GLOBAL_CONST unsigned short IOLIST_VARSIZE_AI_STATE;
 _GLOBAL_CONST unsigned short IOLIST_VARSIZE_AO_STATE;
 _GLOBAL_CONST unsigned short IOLIST_VARSIZE_ARRAYINFO_SET;
 _GLOBAL_CONST unsigned short IOLIST_VARSIZE_A_FORCE;
 _GLOBAL_CONST unsigned short IOLIST_VARSIZE_A_SET;
 _GLOBAL_CONST unsigned short IOLIST_VARSIZE_DI_STATE;
 _GLOBAL_CONST unsigned short IOLIST_VARSIZE_DO_STATE;
 _GLOBAL_CONST unsigned short IOLIST_VARSIZE_D_FORCE;
 _GLOBAL_CONST unsigned short IOLIST_VARSIZE_D_SET;
 _GLOBAL_CONST unsigned short IOLIST_WINDOW_ARRAY_MISSING;
 _GLOBAL_CONST unsigned short IOLIST_WRONG_IDENT;
 _GLOBAL_CONST unsigned short IOLIST_WRONG_IOTYPE;
 _GLOBAL_CONST unsigned char IO_LIST_AI_LIST;
 _GLOBAL_CONST unsigned char IO_LIST_ALL_LIST;
 _GLOBAL_CONST unsigned char IO_LIST_AO_LIST;
 _GLOBAL_CONST unsigned char IO_LIST_A_LIST;
 _GLOBAL_CONST unsigned char IO_LIST_DI_LIST;
 _GLOBAL_CONST unsigned char IO_LIST_DO_LIST;
 _GLOBAL_CONST unsigned char IO_LIST_D_LIST;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct IoInfo_Type
{	plcstring Description[7][21];
	plcstring Value[7][5];
	unsigned short ElementActLevel;
	unsigned short NumbElementsActLevel;
	unsigned long ActIoAdr;
	plcstring PathScrollLevel[121];
	plcstring ActIoName[65];
	unsigned char SelectedLevel;
} IoInfo_Type;

typedef struct IoDescLoad
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned long pDevice;
	unsigned long pFileName;
	unsigned long pDescString;
	unsigned long SizeDescString;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	plcstring ErrStringInfo[65];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} IoDescLoad_typ;

typedef struct IoListScroll
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned char IoType;
	unsigned char cmdInit;
	unsigned char cmdUp;
	unsigned char cmdDown;
	unsigned char cmdScrollLevelUp;
	unsigned char cmdScrollLevelDown;
	unsigned char cmdSetOutput;
	unsigned char cmdForceEnable;
	unsigned char cmdForceDisable;
	unsigned char cmdForceSetValue;
	unsigned char cmdForceDisableAll;
	unsigned char NumbSelectLanguage;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	plcstring ErrStringInfo[33];
	unsigned short ActIoNumber;
	unsigned short NumberOfIoTotal;
	unsigned short SelectedItem;
	unsigned char ActIoForcedOn;
	unsigned char AnyIoForcedOn;
	/* VAR (analog) */
	unsigned char UpdateOutput;
	/* VAR_INPUT (digital) */
	plcbit Enable;
} IoListScroll_typ;

typedef struct IoListInit
{
	/* VAR_INPUT (analog) */
	unsigned long pStateDi;
	unsigned long pStateDo;
	unsigned long pStateAi;
	unsigned long pStateAo;
	unsigned long pVisWindow;
	unsigned long pVisVarDigitalSet;
	unsigned long pVisVarAnalogSet;
	unsigned long pVisVarDigitalForce;
	unsigned long pVisVarAnalogForce;
	unsigned long pVisStructIoInfo;
	unsigned long SizeMemAlloc;
	unsigned short SizeVisWindow;
	unsigned short SizeVisStructIoInfo;
	unsigned char SizeVisVarDigitalSet;
	unsigned char SizeVisVarAnalogSet;
	unsigned char SizeVisVarDigitalForce;
	unsigned char SizeVisVarAnalogForce;
	unsigned char LinesVisWindow;
	unsigned short LenStateDi;
	unsigned short LenStateDo;
	unsigned short LenStateAi;
	unsigned short LenStateAo;
	unsigned char UseArio;
	unsigned char IgnoreNonExistIo;
	unsigned long pDatObjName;
	/* VAR_OUTPUT (analog) */
	unsigned long Ident;
	unsigned short Status;
	unsigned long SizeMemAllocated;
	plcstring ErrStringInfo[33];
	plcstring ErrStringDetail[33];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} IoListInit_typ;

typedef struct IoGetMemInfo
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned char cmdGetMemInfo;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	unsigned long NumberBytesFree;
	unsigned long MaxBlockSizeFree;
} IoGetMemInfo_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC void IoDescLoad(struct IoDescLoad* inst);
_BUR_PUBLIC void IoListScroll(struct IoListScroll* inst);
_BUR_PUBLIC void IoListInit(struct IoListInit* inst);
_BUR_PUBLIC void IoGetMemInfo(struct IoGetMemInfo* inst);


#ifdef __cplusplus
};
#endif
#endif /* _IOLIST_ */

