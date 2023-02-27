/* Automation Studio generated header file */
/* Do not edit ! */
/* jedata 1.30.1 */

#ifndef _JEDATA_
#define _JEDATA_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _jedata_VERSION
#define _jedata_VERSION 1.30.1
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG3
		#include "standard.h"
		#include "brsystem.h"
		#include "AsTime.h"
		#include "AsString.h"
		#include "AsMem.h"
		#include "jenxml.h"
		#include "LogLib.h"
#endif
#ifdef _SG4
		#include "standard.h"
		#include "brsystem.h"
		#include "AsTime.h"
		#include "AsString.h"
		#include "AsMem.h"
		#include "jenxml.h"
		#include "LogLib.h"
#endif
#ifdef _SGC
		#include "standard.h"
		#include "brsystem.h"
		#include "AsTime.h"
		#include "AsString.h"
		#include "AsMem.h"
		#include "jenxml.h"
		#include "LogLib.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define LOADID 53U
 #define ADR_RECIPE_TEXT 52U
 #define ADR_CUSTOMER_TEXT 51U
 #define ADR_ARTICLE_TEXT 50U
 #define RCP_LOGGED_TIME 40U
 #define ADR_MACHINE_NAME 30U
 #define OPERATOR_NUMBER 31U
 #define PU_STATUS 29U
 #define MACHINE_TYPE 28U
 #define OPERATOR_LOG_STATUS 27U
 #define NUMBER_OF_ATTENDANTS 26U
 #define NORM 25U
 #define RECIPE_NUMBER 24U
 #define CUSTOMER_NUMBER 23U
 #define ARTICLE_NUMBER 22U
 #define NUMBER_OF_LANES 21U
 #define OPERATOR_LOGGED_TIME 20U
 #define PRODUCTION_OPERATOR 12U
 #define OPERATOR 11U
 #define EVENT 10U
 #define METADATA_INTERNAL_PUS 66U
 #define FLOW_MACHINE_IDLE 65U
 #define FLOW_MACHINE_FEEDING_PROHIBITED 64U
 #define FLOW_MACHINE_WAITING_FOR_OVERLAP 63U
 #define FLOW_STATION_LINEN_PRESENCE 62U
 #define FLOW_STATION_FEED_END 61U
 #define FLOW_STATION_FEED_START 60U
 #define FLOW_NOFLOW 9U
 #define PRODUCTION_EXTRA_3 77U
 #define PRODUCTION_EXTRA_2 76U
 #define PRODUCTION_EXTRA_1 75U
 #define PRODUCTION_TOO_CLOSE 74U
 #define PRODUCTION_MIS_FEED 73U
 #define PRODUCTION_SORT 72U
 #define PRODUCTION_THICK_ITEM 71U
 #define PRODUCTION_TRASH 70U
 #define PRODUCTION_OVERSIZE 7U
 #define PRODUCTION_QUALITY 6U
 #define PRODUCTION_DROP 5U
 #define PRODUCTION_PREPRODUCTION 4U
 #define PRODUCTION_REPAIR 3U
 #define PRODUCTION_REWASH 2U
 #define PRODUCTION_PRODUCTION 1U
#else
 _GLOBAL_CONST unsigned char LOADID;
 _GLOBAL_CONST unsigned char ADR_RECIPE_TEXT;
 _GLOBAL_CONST unsigned char ADR_CUSTOMER_TEXT;
 _GLOBAL_CONST unsigned char ADR_ARTICLE_TEXT;
 _GLOBAL_CONST unsigned char RCP_LOGGED_TIME;
 _GLOBAL_CONST unsigned char ADR_MACHINE_NAME;
 _GLOBAL_CONST unsigned char OPERATOR_NUMBER;
 _GLOBAL_CONST unsigned char PU_STATUS;
 _GLOBAL_CONST unsigned char MACHINE_TYPE;
 _GLOBAL_CONST unsigned char OPERATOR_LOG_STATUS;
 _GLOBAL_CONST unsigned char NUMBER_OF_ATTENDANTS;
 _GLOBAL_CONST unsigned char NORM;
 _GLOBAL_CONST unsigned char RECIPE_NUMBER;
 _GLOBAL_CONST unsigned char CUSTOMER_NUMBER;
 _GLOBAL_CONST unsigned char ARTICLE_NUMBER;
 _GLOBAL_CONST unsigned char NUMBER_OF_LANES;
 _GLOBAL_CONST unsigned char OPERATOR_LOGGED_TIME;
 _GLOBAL_CONST unsigned char PRODUCTION_OPERATOR;
 _GLOBAL_CONST unsigned char OPERATOR;
 _GLOBAL_CONST unsigned char EVENT;
 _GLOBAL_CONST unsigned char METADATA_INTERNAL_PUS;
 _GLOBAL_CONST unsigned char FLOW_MACHINE_IDLE;
 _GLOBAL_CONST unsigned char FLOW_MACHINE_FEEDING_PROHIBITED;
 _GLOBAL_CONST unsigned char FLOW_MACHINE_WAITING_FOR_OVERLAP;
 _GLOBAL_CONST unsigned char FLOW_STATION_LINEN_PRESENCE;
 _GLOBAL_CONST unsigned char FLOW_STATION_FEED_END;
 _GLOBAL_CONST unsigned char FLOW_STATION_FEED_START;
 _GLOBAL_CONST unsigned char FLOW_NOFLOW;
 _GLOBAL_CONST unsigned char PRODUCTION_EXTRA_3;
 _GLOBAL_CONST unsigned char PRODUCTION_EXTRA_2;
 _GLOBAL_CONST unsigned char PRODUCTION_EXTRA_1;
 _GLOBAL_CONST unsigned char PRODUCTION_TOO_CLOSE;
 _GLOBAL_CONST unsigned char PRODUCTION_MIS_FEED;
 _GLOBAL_CONST unsigned char PRODUCTION_SORT;
 _GLOBAL_CONST unsigned char PRODUCTION_THICK_ITEM;
 _GLOBAL_CONST unsigned char PRODUCTION_TRASH;
 _GLOBAL_CONST unsigned char PRODUCTION_OVERSIZE;
 _GLOBAL_CONST unsigned char PRODUCTION_QUALITY;
 _GLOBAL_CONST unsigned char PRODUCTION_DROP;
 _GLOBAL_CONST unsigned char PRODUCTION_PREPRODUCTION;
 _GLOBAL_CONST unsigned char PRODUCTION_REPAIR;
 _GLOBAL_CONST unsigned char PRODUCTION_REWASH;
 _GLOBAL_CONST unsigned char PRODUCTION_PRODUCTION;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct JenViewTmpRealTimeData_Type
{	unsigned long RcpTime;
	unsigned long OprTime;
	unsigned long OprCnt;
	unsigned long RcpCnt;
	plcbit Clear;
	unsigned long RewashCnt;
	unsigned long RepairCnt;
} JenViewTmpRealTimeData_Type;

typedef struct AlarmEvent_Type
{	unsigned short ID;
	unsigned short GroupID;
	unsigned char Status;
	plcstring Description[41];
	unsigned short Severity;
} AlarmEvent_Type;

typedef struct DataLoggerElement_Type
{	unsigned long Data;
	plcstring MessageA[41];
	plcstring MessageB[41];
	signed long Info1;
	unsigned long OprTotal;
	unsigned long RcpTotal;
	unsigned long Info2;
} DataLoggerElement_Type;

typedef struct DataLoggerProduction_Type
{	struct DataLoggerElement_Type Production;
	struct DataLoggerElement_Type Rewash;
	struct DataLoggerElement_Type Repair;
	struct DataLoggerElement_Type PreProduction;
	struct DataLoggerElement_Type Drop;
	struct DataLoggerElement_Type Quality;
	struct DataLoggerElement_Type Oversize;
	struct DataLoggerElement_Type Trash;
	struct DataLoggerElement_Type ThickItem;
	struct DataLoggerElement_Type Sort;
	struct DataLoggerElement_Type MisFeed;
	struct DataLoggerElement_Type TooClose;
	struct DataLoggerElement_Type Extra1;
	struct DataLoggerElement_Type Extra2;
	struct DataLoggerElement_Type Extra3;
} DataLoggerProduction_Type;

typedef struct FlowMachine_Type
{	unsigned char WaitingForOverlap;
	unsigned char FeedingProhibited;
	unsigned char Idle;
} FlowMachine_Type;

typedef struct FlowStation_Type
{	plcbit FeedStart;
	plcbit FeedEnd;
	plcbit NoFlow;
	plcbit LinenPresence;
} FlowStation_Type;

typedef struct DataLoggerFlow_Type
{	struct FlowMachine_Type Machine;
	struct FlowStation_Type Station;
} DataLoggerFlow_Type;

typedef struct JDOperatorID_Type
{	unsigned short ID;
	plcstring Name[81];
} JDOperatorID_Type;

typedef struct DataLoggerMetaData_Type
{	unsigned char RcpNo;
	plcstring RcpText[33];
	unsigned short ArtNo;
	plcstring ArtText[33];
	unsigned short CustNo;
	plcstring CustText[33];
	unsigned long Primary;
	unsigned long Reference;
	unsigned short TNorm;
	unsigned short FlowTimeOut;
	unsigned char PUStatus;
	unsigned long BatchID;
	unsigned long SourceID;
} DataLoggerMetaData_Type;

typedef struct CommonDataLogger_Type
{	struct DataLoggerProduction_Type Production;
	struct DataLoggerFlow_Type Flow;
	struct AlarmEvent_Type Alarm[10];
	struct JDOperatorID_Type Operator[10];
	plcbit Active;
	plcbit ChangeType;
	plcbit Change;
	struct DataLoggerMetaData_Type MetaData;
	struct DataLoggerMetaData_Type OldMetaData;
	unsigned long OprLoggedTime;
	unsigned long RcpLoggedTime;
	unsigned short Mode;
	plcbit SingleLaneOp;
	plcdt TimeStart;
	unsigned long LoadID;
} CommonDataLogger_Type;

typedef struct JDWideLog_Type
{	unsigned long Index;
	plcdt TimeStamp;
	unsigned char PositionID;
	signed short SubID;
	unsigned char RegType;
	unsigned char SubRegType;
	signed short SubRegTypeID;
	signed short State;
	plcstring MessageA[41];
	plcstring MessageB[41];
	signed long BatchID;
	unsigned long SourceID;
	unsigned long ProcessCode;
	plcstring ProcessName[33];
	unsigned long CustNo;
	signed long SortCategoryID;
	unsigned long ArtNo;
	unsigned long OperatorNo;
	float Value;
	signed short Unit;
} JDWideLog_Type;

typedef struct JDLog_Type
{	unsigned short Index;
	plcdt TimeStamp;
	unsigned char Mode;
	unsigned char ValueID;
	unsigned long Value;
	signed long Info;
	plcstring MessageA[41];
	plcstring MessageB[41];
} JDLog_Type;

typedef struct JenViewDataObject
{	plcdt DateTimeLog[5];
	struct JDOperatorID_Type Operator[10];
	unsigned long Ident;
} JenViewDataObject;

typedef struct JenViewInterfaceInternal_Type
{	unsigned long AdrArrJenViewWriteWideLogVar;
	unsigned long AdrArrJenViewWriteLogVar;
	unsigned long AdrArrIdentJenViewWideLogInit;
	unsigned long AdrArrIdentJenViewLogInit;
	unsigned long AdrArrRealTimeExchange;
	unsigned long MemPartIdent;
	unsigned long AdrLoggerSetup;
} JenViewInterfaceInternal_Type;

typedef struct LogAddOn_Type
{	plcstring AddOnName[81];
	unsigned long MinValue;
	unsigned long MaxValue;
	unsigned long MultiplierValue;
	unsigned long DividerValue;
	unsigned char Type;
	unsigned char Mode;
	unsigned long ValueID;
	plcstring VarName[81];
	unsigned long Limiter;
	unsigned long Ident;
	plcbit Log;
	plcbit Reset;
	unsigned short TimeOut;
	unsigned char RegType;
	unsigned char SubRegType;
	signed short SubRegTypeID;
	plcstring MessageA[41];
	plcstring MessageB[41];
	unsigned short Value;
	signed short Unit;
} LogAddOn_Type;

typedef struct JenViewLogSetup_Type
{	unsigned char Attendants;
	unsigned char MachineType;
	unsigned char ProductionUnits;
	unsigned char Type;
	unsigned short PulseLogInterval;
	plcbit Init;
	unsigned long AdrDataLogger;
	plcstring ExternalInitVarName[81];
	plcstring CounterVarName[81];
	plcbit SingeLaneOp[10];
	plcbit OperatorDelay;
	plcstring MachineName[81];
	plcbit DisableOperatorLog;
	struct LogAddOn_Type AddOn[20];
	plcstring LogTaskName[20][33];
	plcstring RunTimeDataEntry[81];
	unsigned short NoFlowTimeOut;
	unsigned long ChangeDelay;
	plcbit NoneProduction;
	plcbit TakeoffStation;
	plcstring RunningStatus[81];
	plcstring EmergencyStatus[81];
	plcbit CloneMasterEvents;
	unsigned short AlarmIgnoreList[20];
} JenViewLogSetup_Type;

typedef struct JenViewTaskInterface_Type
{	struct JenViewInterfaceInternal_Type Internal;
	unsigned char ServersRunning;
	plcbit XMLRPCServerStarted;
	unsigned short Status;
	plcstring StatusString[81];
	plcstring MsgString[201];
	unsigned short MsgStatus;
} JenViewTaskInterface_Type;

typedef struct LoadID_Type
{	unsigned long LoadID[10];
	unsigned long BatchID[10];
} LoadID_Type;

typedef struct M2JenData_Type
{	unsigned long LoadID[10];
	unsigned char RcpNo[10];
	unsigned long ArtNo[10];
	unsigned long CustNo[10];
	plcstring RcpText[10][33];
	plcstring ArtText[10][33];
	plcstring CustText[10][33];
	unsigned short Norm[10];
	unsigned short FlowTimeOut[10];
	unsigned short Primary[10];
	unsigned short Reference[10];
	unsigned char Active[10];
	plcbit DisableOperatorLog;
	unsigned short OperatorLogDelay;
	unsigned long OperatingHours;
	unsigned short Status;
	plcstring StatusString[41];
	unsigned long BatchID[10];
	unsigned long SourceID[10];
} M2JenData_Type;

typedef struct OperatorFifo_Type
{	unsigned short Operator;
	unsigned long Delay;
	unsigned char Info;
	plcstring OperatorName[81];
} OperatorFifo_Type;

typedef struct ReadLogVar10_Type
{	struct JDLog_Type Log[40];
} ReadLogVar10_Type;

typedef struct RealTimeElement_Type
{	plcstring Key[11];
	plcstring Data[21];
} RealTimeElement_Type;

typedef struct AddToWideLog
{
	/* VAR_INPUT (analog) */
	unsigned long AdrArrIdentJenViewWideLogInit;
	unsigned long AdrArrJenViewWriteWideLogVar;
	unsigned char ServerNo;
	struct JDWideLog_Type Data;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	/* VAR (analog) */
	struct DTGetTime InternalTimer;
	struct LogWrite JenViewWideLogWrite;
	/* VAR_INPUT (digital) */
	plcbit Setup;
	plcbit OverWriteTimeStamp;
	/* VAR (digital) */
	plcbit InitDone;
} AddToWideLog_typ;

typedef struct AddToLog
{
	/* VAR_INPUT (analog) */
	unsigned long AdrArrIdentJenViewLogInit;
	unsigned long AdrArrJenViewWriteLogVar;
	unsigned char ServerNo;
	unsigned char Mode;
	unsigned char ValueID;
	unsigned long Value;
	plcdt TimeStamp;
	unsigned long Info;
	plcstring MessageA[41];
	plcstring MessageB[41];
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	/* VAR (analog) */
	struct DTGetTime InternalTimer;
	struct LogWrite JenViewLogWrite;
	/* VAR_INPUT (digital) */
	plcbit Setup;
	plcbit OverWriteTimeStamp;
	/* VAR (digital) */
	plcbit InitDone;
} AddToLog_typ;

typedef struct PulseLog
{
	/* VAR_INPUT (analog) */
	unsigned short TimeOut;
	unsigned long AdrCounterVarName;
	/* VAR_OUTPUT (analog) */
	unsigned long PulseCount;
	/* VAR (analog) */
	unsigned long Timer;
	unsigned long InternalCount;
	unsigned short Status;
	unsigned long MemAdrWheelCounter;
	unsigned long WheelCounterLen;
	unsigned long CycleTime;
	/* VAR_INPUT (digital) */
	plcbit Run;
	plcbit Reset;
	plcbit ForceOut;
	/* VAR_OUTPUT (digital) */
	plcbit Out;
	/* VAR (digital) */
	plcbit InitDone;
} PulseLog_typ;

typedef struct LogData
{
	/* VAR_INPUT (analog) */
	unsigned char Type;
	unsigned char Lane;
	unsigned long Info1;
	unsigned long Info2;
	unsigned long Info3;
	unsigned long Info4;
	unsigned long MessageA;
	unsigned long MessageB;
	/* VAR_OUTPUT (analog) */
	plcstring StatusString[33];
	unsigned short Status;
	unsigned long AdrJenViewServerInterface;
	/* VAR (analog) */
	unsigned long LoggerAdr;
	unsigned char Operators;
	/* VAR (digital) */
	plcbit InitDone;
} LogData_typ;

typedef struct JenDataServer
{
	/* VAR_INPUT (analog) */
	unsigned long InterfaceIdent;
	struct JDWideLog_Type JenViewWriteWideLogVar[5];
	struct JDLog_Type JenViewWriteLogVar[5];
	unsigned long adrWideBufferIdents[5];
	struct JenLogging_Type JenViewCommandStruct[5];
	struct RealTimeElement_Type RealTime0[40];
	struct RealTimeElement_Type RealTime1[40];
	struct RealTimeElement_Type RealTime2[40];
	struct RealTimeElement_Type RealTime3[40];
	struct RealTimeElement_Type RealTime4[40];
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	/* VAR (analog) */
	unsigned long Ident;
	struct ReadLogVar10_Type JenViewReadLog[5];
	/* VAR_INPUT (digital) */
	plcbit isSQLEnabled;
	plcbit isXMLRPCEnabled;
} JenDataServer_typ;

typedef struct AddToRealTime
{
	/* VAR_INPUT (analog) */
	unsigned long pText;
	unsigned char Displacement;
	unsigned long RealTimeIdent;
	unsigned long DataText;
	unsigned long DataNo;
	/* VAR_OUTPUT (analog) */
	plcstring StatusString[33];
	unsigned char Status;
	/* VAR (analog) */
	unsigned char Iter;
	/* VAR_INPUT (digital) */
	plcbit Init;
} AddToRealTime_typ;

typedef struct JDDelay
{
	/* VAR_INPUT (analog) */
	unsigned long Delay;
	unsigned long CntAdr;
	unsigned long Comp;
	/* VAR_OUTPUT (analog) */
	unsigned char ErrorCode;
	plcstring ErrorString[17];
	/* VAR (analog) */
	unsigned long OutCounter;
	/* VAR_INPUT (digital) */
	plcbit Set;
	/* VAR_OUTPUT (digital) */
	plcbit Out;
	plcbit Trig;
	/* VAR (digital) */
	plcbit InitDone;
} JDDelay_typ;

typedef struct ExternalInput
{
	/* VAR_INPUT (analog) */
	unsigned long AdrInput;
	unsigned long AdrInputVarName;
	unsigned short FilterTime;
	unsigned long AdrCycleCounter;
	/* VAR_OUTPUT (analog) */
	signed char Status;
	/* VAR (analog) */
	unsigned long TCount;
	unsigned char InitDone;
	/* VAR_OUTPUT (digital) */
	plcbit DOut;
	plcbit Out;
} ExternalInput_typ;

typedef struct AddOn
{
	/* VAR_INPUT (analog) */
	unsigned short TimeOut;
	unsigned char Type;
	unsigned long Limiter;
	unsigned long MinValue;
	unsigned long MaxValue;
	unsigned long Divider;
	unsigned long Multiplier;
	plcstring VarName[81];
	unsigned char RegType;
	unsigned char SubRegType;
	signed short SubRegTypeID;
	plcstring MessageA[41];
	plcstring MessageB[41];
	signed short Unit;
	/* VAR_OUTPUT (analog) */
	unsigned long Value;
	/* VAR (analog) */
	unsigned long AdrValue;
	unsigned long OldValue;
	unsigned long CycleTime;
	unsigned long Timer;
	unsigned long DataType;
	/* VAR_INPUT (digital) */
	plcbit Reset;
	/* VAR_OUTPUT (digital) */
	plcbit Out;
	/* VAR (digital) */
	plcbit Init;
	plcbit InitRun;
} AddOn_typ;

typedef struct OperatorDelayFifo
{
	/* VAR_INPUT (analog) */
	unsigned long Delay;
	plcstring OperatorName[81];
	unsigned char Info;
	unsigned short Operator;
	unsigned long AdrCounterVarName;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	/* VAR (analog) */
	struct OperatorFifo_Type OperatorFifo[50];
	unsigned short FreeBuffers;
	unsigned short Elements;
	unsigned long AdrCounter;
	unsigned char InitDone;
	/* VAR_INPUT (digital) */
	plcbit Set;
	/* VAR_OUTPUT (digital) */
	plcbit Out;
} OperatorDelayFifo_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC void AddToWideLog(struct AddToWideLog* inst);
_BUR_PUBLIC void AddToLog(struct AddToLog* inst);
_BUR_PUBLIC void PulseLog(struct PulseLog* inst);
_BUR_PUBLIC void LogData(struct LogData* inst);
_BUR_PUBLIC void JenDataServer(struct JenDataServer* inst);
_BUR_PUBLIC void AddToRealTime(struct AddToRealTime* inst);
_BUR_PUBLIC void JDDelay(struct JDDelay* inst);
_BUR_PUBLIC void ExternalInput(struct ExternalInput* inst);
_BUR_PUBLIC void AddOn(struct AddOn* inst);
_BUR_PUBLIC void OperatorDelayFifo(struct OperatorDelayFifo* inst);
_BUR_PUBLIC unsigned char SecToText(unsigned long Seconds, unsigned long AdrText, plcbit isCompressed);
_BUR_PUBLIC unsigned long GetAdr(unsigned long DestAdr, unsigned long AdrVarName);
_BUR_PUBLIC signed long AddCountToLog(unsigned long AdrDataElement);
_BUR_PUBLIC signed short Random(unsigned short Seed);
_BUR_PUBLIC unsigned long GetData(unsigned char ServerNo, unsigned char Type, unsigned char Lane, unsigned long Ident);
_BUR_PUBLIC signed long ScrollText(unsigned long AdrText);
_BUR_PUBLIC plcbit StrCatNum(unsigned long pOutputString, unsigned char Count, unsigned long pInputString);
_BUR_PUBLIC signed long SplitString(unsigned long Dest2, unsigned long Dest1, unsigned long Source, unsigned char SplitChar);


#ifdef __cplusplus
};
#endif
#endif /* _JEDATA_ */

