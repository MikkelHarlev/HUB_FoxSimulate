/* Automation Studio generated header file */
/* Do not edit ! */
/* FlatXML 0.35.0 */

#ifndef _FLATXML_
#define _FLATXML_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _FlatXML_VERSION
#define _FlatXML_VERSION 0.35.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
		#include "brsystem.h"
		#include "AsString.h"
		#include "rpc2d.h"
		#include "SAX_RPC.h"
		#include "XML_clnt.h"
		#include "XMLPVs.h"
		#include "XMLRPC.h"
		#include "base64.h"
#endif
#ifdef _SGC
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define MACHINE_STATE_READY 2
 #define MACHINE_STATE_NOCOM (-1)
 #define FLATXML_COMSTATE_DATA_SENT 3
 #define FLATXML_COMSTATE_DATA_REQUESTED 2
 #define FLATXML_COMSTATE_STATUS_REQUEST 20
 #define FLATXML_COMSTATE_REQUEST_OK 16
 #define FLATXML_COMSTATE_REQUEST_MADE 11
 #define FLATXML_COMSTATE_NO_RESPONSE 99
 #define FLATXML_COMSTATE_NO_READ 15
 #define FLATXML_COMSTATE_IDLE 100
#else
 _GLOBAL_CONST signed short MACHINE_STATE_READY;
 _GLOBAL_CONST signed short MACHINE_STATE_NOCOM;
 _GLOBAL_CONST signed short FLATXML_COMSTATE_DATA_SENT;
 _GLOBAL_CONST signed short FLATXML_COMSTATE_DATA_REQUESTED;
 _GLOBAL_CONST signed short FLATXML_COMSTATE_STATUS_REQUEST;
 _GLOBAL_CONST signed short FLATXML_COMSTATE_REQUEST_OK;
 _GLOBAL_CONST signed short FLATXML_COMSTATE_REQUEST_MADE;
 _GLOBAL_CONST signed short FLATXML_COMSTATE_NO_RESPONSE;
 _GLOBAL_CONST signed short FLATXML_COMSTATE_NO_READ;
 _GLOBAL_CONST signed short FLATXML_COMSTATE_IDLE;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct XMLFlatworkData_Type
{	unsigned char RcpNo;
	unsigned char SortingClassNo;
	unsigned char Status;
	unsigned char Info;
	unsigned short Speed;
	unsigned short OperatorNo;
	unsigned short CustomerNo;
	unsigned short ArticleNo;
	unsigned char TextNo;
	plcstring Text[81];
	unsigned char SpareUSINT;
	unsigned short SpareUINT;
	unsigned long SpareUDINT;
	float SpareREAL;
	plcdt SpareDATE;
	plctime SpareTIME;
} XMLFlatworkData_Type;

typedef struct FlatStatisticCounters
{	unsigned short ConnectedOkCounter;
	unsigned short ClosedCounter;
	unsigned short RequestCounter;
	unsigned short RequestOkCounter;
	unsigned short StatusTransmitCounter;
	unsigned short StatusOkCounter;
	unsigned short NoAnswerCounter;
	unsigned short ErrorCounter;
	unsigned short WrongMessageIdCounter;
	unsigned short UnknownTagCounter;
} FlatStatisticCounters;

typedef struct MachineInfo_Type
{	signed short ServerMachineStatus;
	signed short ClientMachineStatus;
	signed short MachineId;
	plcstring IpAddress[22];
	signed short ConnectionState;
	unsigned long ConnectionError;
	plcstring ServerVersion[11];
	plcstring ClientVersion[11];
	unsigned short StatusRefreshTime;
	unsigned short StatusRefreshTimer;
	unsigned short RequestTimeOutTime;
	unsigned short RequestTimeOutTimer;
	signed short ComState;
	plcbit RequestFlatworkData;
	plcbit SendFlatworkData;
	plcbit RequestOk;
	plcbit RequestFail;
	unsigned char LaneNo;
	unsigned short NewLaneData[9];
	struct XMLFlatworkData_Type FlatworkData[9];
	struct FlatStatisticCounters Statistic;
} MachineInfo_Type;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC signed long InitAllFlatServers(void);
_BUR_PUBLIC signed long InitFlatClient(unsigned short MachineId, unsigned long XMLCommInfoPointer, plcstring* ServerIpAddress, unsigned short StatusRefreshTime, plcbit CreateLogentries, plcbit UseBase64);
_BUR_PUBLIC signed long InitFlatServer(unsigned short MachineId, unsigned long XMLCommInfoPointer, unsigned short StatusRefreshTime, plcbit CreateLogentries, plcbit UseBase64);
_BUR_PUBLIC signed long RunFlatClient(unsigned long XMLCommInfoPointer, unsigned short PortNumber);
_BUR_PUBLIC signed long RunFlatServer(unsigned long XMLCommInfoPointer);
_BUR_PUBLIC signed long RegisterFlatFunctions(signed long ServerStatus, unsigned long wrback_adr);


#ifdef __cplusplus
};
#endif
#endif /* _FLATXML_ */

