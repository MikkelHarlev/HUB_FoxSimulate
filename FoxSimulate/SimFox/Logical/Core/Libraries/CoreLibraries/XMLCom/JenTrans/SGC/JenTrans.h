/* Automation Studio generated header file */
/* Do not edit ! */
/* JenTrans 4.01.5 */

#ifndef _JENTRANS_
#define _JENTRANS_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _JenTrans_VERSION
#define _JenTrans_VERSION 4.01.5
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG3
		#include "SYS_LIB.h"
		#include "brsystem.h"
		#include "AsTime.h"
		#include "httpUtil.h"
		#include "JenVar.h"
		#include "rpc2d.h"
		#include "SAX_RPC.h"
		#include "XML_clnt.h"
		#include "XMLRPC.h"
		#include "base64.h"
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
		#include "brsystem.h"
		#include "AsTime.h"
		#include "httpUtil.h"
		#include "JenVar.h"
		#include "rpc2d.h"
		#include "SAX_RPC.h"
		#include "XML_clnt.h"
		#include "XMLRPC.h"
		#include "base64.h"
#endif
#ifdef _SGC
		#include "SYS_LIB.h"
		#include "brsystem.h"
		#include "AsTime.h"
		#include "httpUtil.h"
		#include "JenVar.h"
		#include "rpc2d.h"
		#include "SAX_RPC.h"
		#include "XML_clnt.h"
		#include "XMLRPC.h"
		#include "base64.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define JENTRANS_COMSTATE_NO_RESPONSE 4
 #define JENTRANS_COMSTATE_REFRESH 3
 #define JENTRANS_COMSTATE_UPDATE 2
 #define JENTRANS_COMSTATE_UPDATED 5
 #define JENTRANS_CONNECT_CLOSE 7
 #define JENTRANS_CONNECT_ERROR 99
 #define JENTRANS_CONNECT_IDLE 2
 #define JENTRANS_CONNECT_INIT 0
 #define JENTRANS_CONNECT_OPEN 1
 #define JENTRANS_CONNECT_PARSE 6
 #define JENTRANS_CONNECT_READ 5
 #define JENTRANS_CONNECT_TIMEOUT 90U
 #define JENTRANS_CONNECT_WAIT 4
 #define JENTRANS_DATATYP_DINT 4
 #define JENTRANS_DATATYP_INT 3
 #define JENTRANS_DATATYP_SINT 2
 #define JENTRANS_DATATYP_STRING 9
 #define JENTRANS_DATATYP_UDINT 7
 #define JENTRANS_DATATYP_UINT 6
 #define JENTRANS_DATATYP_USINT 5
 #define JENTRANS_ERROR_SEND_20 20
 #define JENTRANS_ERROR_TIME_OUT_21 21
 #define JENTRANS_FLAG_CLEAR_AFTER_TRANS 8
 #define JENTRANS_FLAG_CLOSE_ERR_LOGGED 32
 #define JENTRANS_FLAG_CONNECT_ERR_LOGGED 16
 #define JENTRANS_FLAG_STRINGS_AS_BASE64 4
 #define JENTRANS_FLAG_SUPRESS_UNKNOWNTAG 2
 #define JENTRANS_FLAG_UPDATE_ON_STATUS 1
 #define JENTRANS_LAST_OBJECT_TYPE 10
 #define JENTRANS_NOT_FINISHED 8
 #define JENTRANS_STATE_NOCOM (-1)
 #define JENTRANS_STATE_STARTUP 1
#else
 _GLOBAL_CONST signed short JENTRANS_COMSTATE_NO_RESPONSE;
 _GLOBAL_CONST signed short JENTRANS_COMSTATE_REFRESH;
 _GLOBAL_CONST signed short JENTRANS_COMSTATE_UPDATE;
 _GLOBAL_CONST signed short JENTRANS_COMSTATE_UPDATED;
 _GLOBAL_CONST signed short JENTRANS_CONNECT_CLOSE;
 _GLOBAL_CONST signed short JENTRANS_CONNECT_ERROR;
 _GLOBAL_CONST signed short JENTRANS_CONNECT_IDLE;
 _GLOBAL_CONST signed short JENTRANS_CONNECT_INIT;
 _GLOBAL_CONST signed short JENTRANS_CONNECT_OPEN;
 _GLOBAL_CONST signed short JENTRANS_CONNECT_PARSE;
 _GLOBAL_CONST signed short JENTRANS_CONNECT_READ;
 _GLOBAL_CONST unsigned short JENTRANS_CONNECT_TIMEOUT;
 _GLOBAL_CONST signed short JENTRANS_CONNECT_WAIT;
 _GLOBAL_CONST signed short JENTRANS_DATATYP_DINT;
 _GLOBAL_CONST signed short JENTRANS_DATATYP_INT;
 _GLOBAL_CONST signed short JENTRANS_DATATYP_SINT;
 _GLOBAL_CONST signed short JENTRANS_DATATYP_STRING;
 _GLOBAL_CONST signed short JENTRANS_DATATYP_UDINT;
 _GLOBAL_CONST signed short JENTRANS_DATATYP_UINT;
 _GLOBAL_CONST signed short JENTRANS_DATATYP_USINT;
 _GLOBAL_CONST signed short JENTRANS_ERROR_SEND_20;
 _GLOBAL_CONST signed short JENTRANS_ERROR_TIME_OUT_21;
 _GLOBAL_CONST signed short JENTRANS_FLAG_CLEAR_AFTER_TRANS;
 _GLOBAL_CONST signed short JENTRANS_FLAG_CLOSE_ERR_LOGGED;
 _GLOBAL_CONST signed short JENTRANS_FLAG_CONNECT_ERR_LOGGED;
 _GLOBAL_CONST signed short JENTRANS_FLAG_STRINGS_AS_BASE64;
 _GLOBAL_CONST signed short JENTRANS_FLAG_SUPRESS_UNKNOWNTAG;
 _GLOBAL_CONST signed short JENTRANS_FLAG_UPDATE_ON_STATUS;
 _GLOBAL_CONST signed short JENTRANS_LAST_OBJECT_TYPE;
 _GLOBAL_CONST signed short JENTRANS_NOT_FINISHED;
 _GLOBAL_CONST signed short JENTRANS_STATE_NOCOM;
 _GLOBAL_CONST signed short JENTRANS_STATE_STARTUP;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct JenTransClientInfo_Type
{	signed short ObjectStatus;
	plcstring Version[11];
	unsigned long ConnectionId;
	signed short ConnectionState;
	unsigned long ConnectionError;
	unsigned short MessageId;
	plcbit MessageIdEnable;
} JenTransClientInfo_Type;

typedef struct JenTransServerInfo_Type
{	signed short ObjectStatus;
	plcstring Version[11];
	plcstring IPAddress[26];
	plcstring LastIPAddress[26];
} JenTransServerInfo_Type;

typedef struct JenTransStatisticCounters
{	unsigned short ConnectedOkCounter;
	unsigned short ClosedCounter;
	unsigned short UpdateCounter;
	unsigned short UpdateOkCounter;
	unsigned short StatusTransmitCounter;
	unsigned short StatusOkCounter;
	unsigned short NoAnswerCounter;
	unsigned short ErrorCounter;
	unsigned short WrongMessageIdCounter;
	unsigned short UnknownTagCounter;
} JenTransStatisticCounters;

typedef struct JenTransCommonInfo_Type
{	unsigned short ObjectType;
	signed short ObjectId;
	unsigned short StatusRefreshTime;
	unsigned short StatusRefreshTimer;
	unsigned short RequestTimeOutTime;
	unsigned short RequestTimeOutTimer;
	unsigned short LastResponseTime;
	signed short ComState;
	unsigned short UpdateTrigger;
	unsigned short Flag;
	struct JenTransClientInfo_Type ClientInfo;
	struct JenTransServerInfo_Type ServerInfo;
	unsigned long DataVariableAddressListPointer;
	unsigned long DataFieldNameListPointer;
	unsigned short DataVariableFields;
	unsigned short DataFieldNameStartPos;
	struct JenTransStatisticCounters Statistic;
} JenTransCommonInfo_Type;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC signed long freexmlmemory(void);
_BUR_PUBLIC signed long SetXMLPortNumber(unsigned short PortNumber);
_BUR_PUBLIC signed long ClearJenTransData(struct JenTransCommonInfo_Type* XMLCommInfoPointer);
_BUR_PUBLIC signed long InitAllXMLServerAndClients(void);
_BUR_PUBLIC signed long InitDynaXMLServerAndClients(unsigned short numberOfObjects);
_BUR_PUBLIC signed long RegisterXMLFunctions(signed long ServerStatus, unsigned long wrback_adr);
_BUR_PUBLIC signed long RunXMLServer(unsigned long XMLCommInfoPointer);
_BUR_PUBLIC signed long RunXMLClient(unsigned long XMLCommInfoPointer);
_BUR_PUBLIC signed long InitXMLServer(unsigned short ObjectType, unsigned short ObjectId, unsigned long XMLCommInfoPointer, plcstring* DataVariableName, unsigned short StatusRefreshTime);
_BUR_PUBLIC signed long InitXMLClient(unsigned short ObjectType, unsigned short ObjectId, unsigned long XMLCommInfoPointer, plcstring* DataVariableName, plcstring* ServerIpAddress, unsigned short StatusRefreshTime);
_BUR_PUBLIC signed long XMLTransferDataWithStatus(unsigned long XMLCommInfoPointer, signed short Activate);
_BUR_PUBLIC signed long XMLSupressUnknownTag(unsigned long XMLCommInfoPointer);


#ifdef __cplusplus
};
#endif
#endif /* _JENTRANS_ */

