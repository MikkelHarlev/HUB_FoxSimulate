/* Automation Studio generated header file */
/* Do not edit ! */
/* FoldXML 4.02.3 */

#ifndef _FOLDXML_
#define _FOLDXML_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _FoldXML_VERSION
#define _FoldXML_VERSION 4.02.3
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG3
		#include "SYS_LIB.h"
		#include "SYS_LIB.h"
		#include "SAX_RPC.h"
		#include "XML_clnt.h"
		#include "XMLRPC.h"
		#include "CacheLib.h"
		#include "MetUtils.h"
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
		#include "SYS_LIB.h"
		#include "SAX_RPC.h"
		#include "XML_clnt.h"
		#include "XMLRPC.h"
		#include "CacheLib.h"
		#include "MetUtils.h"
#endif
#ifdef _SGC
		#include "SYS_LIB.h"
		#include "SYS_LIB.h"
		#include "SAX_RPC.h"
		#include "XML_clnt.h"
		#include "XMLRPC.h"
		#include "CacheLib.h"
		#include "MetUtils.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define MKTraceASSERT 0
 #define FOLDXML_ERROR_SEND_20 20
 #define FOLDXML_ERROR_TIMEOUT_21 21
 #define FOLD_COMSTATE_DATA_OK 10
 #define FOLD_COMSTATE_HANGER_AWAY_MADE 3
 #define FOLD_COMSTATE_NO_RESPONSE 99
 #define FOLD_COMSTATE_REQUEST_MADE 1
 #define FOLD_COMSTATE_STATUS_REQUEST 2
 #define HANGER_READ_STATE_NO_DATA 3U
 #define HANGER_READ_STATE_NO_HANGER 0U
 #define HANGER_READ_STATE_NO_READ 2U
 #define HANGER_READ_STATE_OK 1U
 #define HANGER_READ_STATE_NO_GARMENT_4 4U
 #define HANGER_READ_STATE_WAIT_5 5U
 #define HANGER_READ_STATE_WAIT_NEXT_6 6U
 #define HANGER_READ_STATE_WAIT_NEXT_7 7U
 #define MACHINE_STATE_AUTOMATIC 7
 #define MACHINE_STATE_MANUAL 4
 #define MACHINE_STATE_NOCOM (-1)
 #define MACHINE_STATE_OFF 0
 #define MACHINE_STATE_SEMI_AUTOMATIC 5
 #define MACHINE_STATE_SERVICE 1
 #define MACHINE_STATE_STANDBY 3
 #define MACHINE_STATE_STARTUP 2
 #define MACHINE_STATE_STOP_AUTOMATIC 6
 #define METRIC_COMSTATE_DATA_REQUESTED 1
 #define METRIC_COMSTATE_DATA_SENT 2
 #define METRIC_COMSTATE_HANGER_AWAY 3
 #define METRIC_COMSTATE_STATUS_REQUEST 4
 #define XML_CONNECT_STATE_CLOSE 7
 #define XML_CONNECT_STATE_ERROR 99
 #define XML_CONNECT_STATE_IDLE 2
 #define XML_CONNECT_STATE_INIT 0
 #define XML_CONNECT_STATE_OPEN 1
 #define XML_CONNECT_STATE_PARSE 6
 #define XML_CONNECT_STATE_READ 5
 #define XML_CONNECT_STATE_SEND 3
 #define XML_CONNECT_STATE_WAIT 4
 #define XML_MACHINE_TYPE_FINISHER 2
 #define XML_MACHINE_TYPE_FOLDER 1
#else
 _GLOBAL_CONST signed short MKTraceASSERT;
 _GLOBAL_CONST signed short FOLDXML_ERROR_SEND_20;
 _GLOBAL_CONST signed short FOLDXML_ERROR_TIMEOUT_21;
 _GLOBAL_CONST signed short FOLD_COMSTATE_DATA_OK;
 _GLOBAL_CONST signed short FOLD_COMSTATE_HANGER_AWAY_MADE;
 _GLOBAL_CONST signed short FOLD_COMSTATE_NO_RESPONSE;
 _GLOBAL_CONST signed short FOLD_COMSTATE_REQUEST_MADE;
 _GLOBAL_CONST signed short FOLD_COMSTATE_STATUS_REQUEST;
 _GLOBAL_CONST unsigned short HANGER_READ_STATE_NO_DATA;
 _GLOBAL_CONST unsigned short HANGER_READ_STATE_NO_HANGER;
 _GLOBAL_CONST unsigned short HANGER_READ_STATE_NO_READ;
 _GLOBAL_CONST unsigned short HANGER_READ_STATE_OK;
 _GLOBAL_CONST unsigned short HANGER_READ_STATE_NO_GARMENT_4;
 _GLOBAL_CONST unsigned short HANGER_READ_STATE_WAIT_5;
 _GLOBAL_CONST unsigned short HANGER_READ_STATE_WAIT_NEXT_6;
 _GLOBAL_CONST unsigned short HANGER_READ_STATE_WAIT_NEXT_7;
 _GLOBAL_CONST signed short MACHINE_STATE_AUTOMATIC;
 _GLOBAL_CONST signed short MACHINE_STATE_MANUAL;
 _GLOBAL_CONST signed short MACHINE_STATE_NOCOM;
 _GLOBAL_CONST signed short MACHINE_STATE_OFF;
 _GLOBAL_CONST signed short MACHINE_STATE_SEMI_AUTOMATIC;
 _GLOBAL_CONST signed short MACHINE_STATE_SERVICE;
 _GLOBAL_CONST signed short MACHINE_STATE_STANDBY;
 _GLOBAL_CONST signed short MACHINE_STATE_STARTUP;
 _GLOBAL_CONST signed short MACHINE_STATE_STOP_AUTOMATIC;
 _GLOBAL_CONST signed short METRIC_COMSTATE_DATA_REQUESTED;
 _GLOBAL_CONST signed short METRIC_COMSTATE_DATA_SENT;
 _GLOBAL_CONST signed short METRIC_COMSTATE_HANGER_AWAY;
 _GLOBAL_CONST signed short METRIC_COMSTATE_STATUS_REQUEST;
 _GLOBAL_CONST signed char XML_CONNECT_STATE_CLOSE;
 _GLOBAL_CONST signed short XML_CONNECT_STATE_ERROR;
 _GLOBAL_CONST signed char XML_CONNECT_STATE_IDLE;
 _GLOBAL_CONST signed char XML_CONNECT_STATE_INIT;
 _GLOBAL_CONST signed char XML_CONNECT_STATE_OPEN;
 _GLOBAL_CONST signed char XML_CONNECT_STATE_PARSE;
 _GLOBAL_CONST signed short XML_CONNECT_STATE_READ;
 _GLOBAL_CONST signed short XML_CONNECT_STATE_SEND;
 _GLOBAL_CONST signed short XML_CONNECT_STATE_WAIT;
 _GLOBAL_CONST signed short XML_MACHINE_TYPE_FINISHER;
 _GLOBAL_CONST signed short XML_MACHINE_TYPE_FOLDER;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct JenXMLFoldClientInfo_Type
{	signed short MachineStatus;
	plcstring Version[11];
	signed short InletActive;
	signed short InletFull;
	signed short InternalAlarm;
	signed short RequestHangerData;
	signed short AwayHangerUpdate;
	plcstring HangerId[25];
	signed short ConnectionState;
	unsigned long ConnectionError;
	plcbit MessageIdEnable;
} JenXMLFoldClientInfo_Type;

typedef struct JenXMLFoldServerInfo_Type
{	signed short MachineStatus;
	plcstring Version[11];
	signed short OutletFull;
	signed short OutletHalfFull;
	signed short HangersWaiting;
	signed short TableUpdate;
	plcstring IPAddress[25];
	unsigned long CacheClientPointer;
} JenXMLFoldServerInfo_Type;

typedef struct XMLFoldGarmentData_Type
{	signed short Program;
	signed short ArticleId;
	signed long CustomerId;
	signed short Destination;
	signed short StackChange;
	plcstring GarmentId[25];
	plcstring HangerId[25];
	signed short SeqId;
	unsigned short MetricHangerReadStatus;
} XMLFoldGarmentData_Type;

typedef struct StatisticCounters
{	unsigned short ConnectedOkCounter;
	unsigned short ClosedCounter;
	unsigned short RequestCounter;
	unsigned short RequestOkCounter;
	unsigned short AwayCounter;
	unsigned short AwayOkCounter;
	unsigned short StatusTransmitCounter;
	unsigned short StatusOkCounter;
	unsigned short NoAnswerCounter;
	unsigned short ErrorCounter;
	unsigned short WrongMessageIdCounter;
	unsigned short UnknownTagCounter;
} StatisticCounters;

typedef struct JenXMLCommInfo_Type
{	unsigned short MachineType;
	signed short MachineId;
	unsigned short StatusRefreshTime;
	unsigned short StatusRefreshTimer;
	unsigned short RequestTimeOutTime;
	unsigned short RequestTimeOutTimer;
	unsigned short LastResponseTime;
	signed short ComState;
	struct JenXMLFoldClientInfo_Type ClientInfo;
	struct JenXMLFoldServerInfo_Type ServerInfo;
	struct XMLFoldGarmentData_Type GarmentData;
	struct StatisticCounters Statistic;
} JenXMLCommInfo_Type;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC signed long AddCacheClientToFoldServer(struct JenXMLCommInfo_Type* XMLCommInfoPointer, unsigned long CacheclientPointer);
_BUR_PUBLIC signed long InitAllFolderServers(void);
_BUR_PUBLIC signed long InitFoldClient(unsigned short MachineType, unsigned short MachineId, unsigned long XMLCommInfoPointer, plcstring* ServerIpAddress, unsigned short StatusRefreshTime);
_BUR_PUBLIC signed long InitFoldServer(unsigned short MachineType, unsigned short MachineId, unsigned long XMLCommInfoPointer, unsigned short StatusRefreshTime);
_BUR_PUBLIC signed long RunFoldClient(unsigned long XMLCommInfoPointer);
_BUR_PUBLIC signed long RunFoldServer(unsigned long XMLCommInfoPointer);
_BUR_PUBLIC signed long RegisterFoldFunctions(signed long ServerStatus, unsigned long wrback_adr);
_BUR_PUBLIC signed long SetFoldXMLPortNumber(unsigned short PortNumber);


__asm__(".section \".plc\"");

/* Additional IEC dependencies */
__asm__(".ascii \"iecdep \\\"Logical/Core/Libraries/CoreLibraries/CacheLib/CacheLib.var\\\" scope \\\"global\\\"\\n\"");

__asm__(".previous");

#ifdef __cplusplus
};
#endif
#endif /* _FOLDXML_ */

