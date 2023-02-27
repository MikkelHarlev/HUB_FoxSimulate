/* Automation Studio generated header file */
/* Do not edit ! */
/* ScanLib 4.51.4 */

#ifndef _SCANLIB_
#define _SCANLIB_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _ScanLib_VERSION
#define _ScanLib_VERSION 4.51.4
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG3
		#include "SYS_LIB.h"
		#include "DVFrame.h"
		#include "brsystem.h"
		#include "CacheLib.h"
		#include "MetUtils.h"
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
		#include "DVFrame.h"
		#include "brsystem.h"
		#include "CacheLib.h"
		#include "MetUtils.h"
#endif
#ifdef _SGC
		#include "SYS_LIB.h"
		#include "DVFrame.h"
		#include "brsystem.h"
		#include "CacheLib.h"
		#include "MetUtils.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define COMBUS_COMMODULE_MESSAGE_LENGTH 80U
 #define COMBUS_COMUNIT_MESSAGE_LENGTH 80U
 #define COMBUS_HIGHEST_COMUNIT_ID 253U
 #define COMBUS_MAX_COMUNITS 100U
 #define COMBUS_TYPE_SIOX 2U
 #define COMBUS_TYPE_X67 1U
 #define COMUNIT_FUNCTION_TYPE_JENCOM 2U
 #define COMUNIT_FUNCTION_TYPE_TAG 1U
 #define COMUNIT_FUNCTION_TYPE_TEXT 3U
#else
 _GLOBAL_CONST unsigned short COMBUS_COMMODULE_MESSAGE_LENGTH;
 _GLOBAL_CONST unsigned short COMBUS_COMUNIT_MESSAGE_LENGTH;
 _GLOBAL_CONST unsigned short COMBUS_HIGHEST_COMUNIT_ID;
 _GLOBAL_CONST unsigned short COMBUS_MAX_COMUNITS;
 _GLOBAL_CONST unsigned short COMBUS_TYPE_SIOX;
 _GLOBAL_CONST unsigned short COMBUS_TYPE_X67;
 _GLOBAL_CONST unsigned short COMUNIT_FUNCTION_TYPE_JENCOM;
 _GLOBAL_CONST unsigned short COMUNIT_FUNCTION_TYPE_TAG;
 _GLOBAL_CONST unsigned short COMUNIT_FUNCTION_TYPE_TEXT;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct ComPort_Type
{	signed short Id;
	unsigned short State;
	unsigned short ReadState;
	unsigned long Ident;
	unsigned long Device;
	unsigned long Param;
	unsigned long Count;
	unsigned long CycelCounter;
	unsigned char RcvPoll;
	unsigned char ReadStr[126];
	struct HangerID_Type ReadId;
	signed char ComUnitIndex[255];
	unsigned long ComUnitPtr;
	unsigned short ComModuleMaxIncompleteCounter;
	signed long CurrentId;
	unsigned short NumberOfComUnits;
	signed long WaitCycle;
	signed long RecCounter;
	unsigned char DiagLastInMsg[81];
	unsigned char DiagLastOutMsg[81];
} ComPort_Type;

typedef struct ComUnit_Type
{	signed short Id;
	unsigned short FunctionType;
	unsigned char RcvPoll;
	unsigned long Ident;
	unsigned short DiagFlag;
	unsigned short FrameState;
	unsigned short Delimiter1;
	unsigned short Delimiter2;
	plcstring TagId[25];
	unsigned short NumberOfBuffers;
	unsigned short RecCounter;
	signed char Mode;
	unsigned long ScanPortPointer;
} ComUnit_Type;

typedef struct ScanPort_Type
{	unsigned short State;
	struct ComPort_Type ComPort;
	struct ComUnit_Type ComUnit[101];
	unsigned long InitState;
	unsigned long RunState;
	unsigned short BusType;
} ScanPort_Type;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC signed short SendToNode(struct ScanPort_Type* ScanPort, unsigned char NodeId, unsigned long SendMessage, unsigned char Delimiter);
_BUR_PUBLIC signed short GetTelegramFromNode(struct ScanPort_Type* ScanPort, unsigned char NodeId, unsigned long ReturnMsg, unsigned short FixMsgLen, unsigned char Delimiter);
_BUR_PUBLIC signed short ReadScan(struct ScanPort_Type* ScanPort, unsigned char ScannerId, plcstring* ReaderData);
_BUR_PUBLIC signed long InitComBus(struct ScanPort_Type* ComBus);
_BUR_PUBLIC signed long InitComUnit(struct ScanPort_Type* ComBus, unsigned short ComUnitId, unsigned short FunctionType, plcstring* DeviceString, plcstring* ParamString, unsigned short IdleCount, unsigned short DelimCharacter1, unsigned short DelimCharacter2, unsigned short MaxMessageLength);
_BUR_PUBLIC signed long RunComBus(struct ScanPort_Type* ComBus);


__asm__(".section \".plc\"");

/* Additional IEC dependencies */
__asm__(".ascii \"iecdep \\\"Logical/Core/Libraries/CoreLibraries/CacheLib/CacheLib.var\\\" scope \\\"global\\\"\\n\"");

__asm__(".previous");

#ifdef __cplusplus
};
#endif
#endif /* _SCANLIB_ */

