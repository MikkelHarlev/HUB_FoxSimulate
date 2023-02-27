/* Automation Studio generated header file */
/* Do not edit ! */
/* XML_Interf 1.00.3 */

#ifndef _XML_INTERF_
#define _XML_INTERF_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _XML_Interf_VERSION
#define _XML_Interf_VERSION 1.00.3
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
/* Datatypes and datatypes of function blocks */
typedef struct XML_Jensen_Type
{	signed short Tx1;
	signed short Tx2;
	signed short Tx3;
	signed short ProtocolVersionNumber;
	plcstring InformationString[81];
	signed long CustomerNumber;
	signed long ArticleNumber;
	signed short CategoryNumber;
	signed short ArticleCount;
	signed short ExpectedCount;
	signed short ExitNumber;
	signed long Option;
	signed short LastBatch;
	signed long BatchID;
	signed long SourceID;
	signed short Weight;
	plcstring HangerId[26];
	plcstring GarmentId[26];
} XML_Jensen_Type;

typedef struct XML_Jensen_Data_Type
{	signed long CustomerNumber;
	signed long ArticleNumber;
	signed short CategoryNumber;
	signed short ArticleCount;
	signed short ExpectedCount;
	signed short ExitNumber;
	signed long Option;
	signed short LastBatch;
	signed long BatchID;
	signed long SourceID;
	signed short Weight;
	plcstring HangerId[26];
	plcstring GarmentId[26];
} XML_Jensen_Data_Type;

typedef struct udtInlet
{	plcbit xIN_ClientReadyToUnload;
	plcbit xIN_ClientUnloading;
	plcbit xIN_ClientUnloadingDone;
	plcbit xOUT_ServerCallForLoad;
	plcbit xOUT_ServerReadyToLoad;
	plcbit xOUT_ServerUnloadingDone;
} udtInlet;

typedef struct udtServerConnectionControl_type
{	struct udtInlet arrInlet[10];
	struct XML_Jensen_Data_Type udtServerData;
	plcbit xAbortFlag;
	signed short iSelectedInlet;
	plcbit xIN_ClientOP_ModeOff;
	plcbit xIN_ClientError;
	plcbit xIN_ClientExternalError;
	plcstring xIN_InformationString[81];
	plcbit xIN_ClientAborted;
	plcbit xOUT_ServerOP_ModeOff;
	plcbit xOUT_ServerError;
	plcbit xOUT_ServerExternalError;
	plcstring xOUT_InformationString[81];
	unsigned short uiUserErrorCounter;
	unsigned short uiAbortCounter;
	plcbit xActivate;
	plcbit xActive;
	plcbit xResetAbortCounter;
	plcbit xResetUserErrorCounter;
} udtServerConnectionControl_type;

typedef struct udtOutlet
{	plcbit xIN_ServerCallForLoad;
	plcbit xIN_ServerReadyToLoad;
	plcbit xIN_ServerUnloadingDone;
	plcbit xOUT_ClientReadyToUnload;
	plcbit xOUT_ClientUnloading;
	plcbit xOUT_ClientUnloadingDone;
} udtOutlet;

typedef struct udtClientConnectionControl_type
{	struct udtOutlet arrOutlet[10];
	struct XML_Jensen_Data_Type udtClientData;
	plcbit xAbortFlag;
	plcbit xOUT_ClientOP_ModeOff;
	plcbit xOUT_ClientError;
	plcbit xOUT_ClientExternalError;
	plcstring xOUT_InformationString[81];
	plcbit xIN_ServerOP_ModeOff;
	plcbit xIN_ServerError;
	plcbit xIN_ServerExternalError;
	plcstring xIN_InformationString[81];
	plcbit xIN_ServerAborted;
	unsigned short uiUserErrorCounter;
	unsigned short uiAbortCounter;
	plcbit xActivate;
	plcbit xActive;
	plcbit xResetAbortCounter;
	plcbit xResetUserErrorCounter;
} udtClientConnectionControl_type;

typedef struct XML_ServerConnection
{
	/* VAR_INPUT (analog) */
	unsigned long pSendStruct;
	unsigned long pReceiveStruct;
	unsigned long pServerConnectionControl;
	unsigned long pClientUpdateTrigger;
	unsigned long pServerUpdateTrigger;
	unsigned long pConnected;
	/* VAR (analog) */
	plcbit* xConnected;
	signed short iStep;
	struct XML_Jensen_Type* udtReceiveStruct;
	struct XML_Jensen_Type* udtSendStruct;
	struct udtServerConnectionControl_type* udtServerConnectionControl;
	signed short i;
	struct TON TON_3000ms;
	struct TON TON_1000ms;
	signed short iSelectedInlet;
	struct F_TRIG F_TRIG_UpdateTrigger;
	signed short iSendCounter;
	struct TOF TOF_ConnectionTimeout;
	struct TON TON_CommunicationTimeout;
	struct R_TRIG R_TRIG_ResetAbortCounter;
	struct R_TRIG R_TRIG_ResetUserErrorCounter;
	plcbit* xClientUpdateTrigger;
	plcbit* xServerUpdateTrigger;
	signed short oldServerTx3;
	struct R_TRIG R_TRIG_AbortFlag;
	signed short iOldStep;
	/* VAR_OUTPUT (digital) */
	plcbit xConnectionTimeout;
	/* VAR (digital) */
	plcbit xFlagInletCallForLoad;
	plcbit xStartCommunicationTimeout;
	plcbit xStepChange;
	plcbit serverCallForLoad;
} XML_ServerConnection_typ;

typedef struct XML_ClientConnection
{
	/* VAR_INPUT (analog) */
	unsigned long pSendStruct;
	unsigned long pReceiveStruct;
	unsigned long pClientConnectionControl;
	unsigned long pClientUpdateTrigger;
	unsigned long pServerUpdateTrigger;
	unsigned long pConnected;
	/* VAR (analog) */
	plcbit* xConnected;
	signed short iStep;
	struct XML_Jensen_Type* udtReceiveStruct;
	struct XML_Jensen_Type* udtSendStruct;
	signed short i;
	struct TON TON_3000ms;
	struct TON TON_1000ms;
	signed short iInitStep;
	struct F_TRIG F_TRIG_UpdateTrigger;
	struct TOF TOF_ConnectionTimeout;
	struct TON TON_CommunicationTimeout;
	struct udtClientConnectionControl_type* udtClientConnectionControl;
	signed short iSelectedOutlet;
	struct R_TRIG R_TRIG_ResetAbortCounter;
	struct R_TRIG R_TRIG_ResetUserErrorCounter;
	plcbit* xClientUpdateTrigger;
	plcbit* xServerUpdateTrigger;
	signed short OldTx3;
	/* VAR (digital) */
	plcbit xResult;
	plcbit xConnectionTimeout;
	plcbit xStartCommunicationTimeout;
	plcbit xFlagOutletReadyToUnload;
	plcbit zzEdge00000;
	plcbit zzEdge00001;
	plcbit zzEdge00002;
	plcbit zzEdge00003;
	plcbit zzEdge00004;
} XML_ClientConnection_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC void XML_ServerConnection(struct XML_ServerConnection* inst);
_BUR_PUBLIC void XML_ClientConnection(struct XML_ClientConnection* inst);
_BUR_PUBLIC plcbit SET_BIT_IN_INT(unsigned long pINT, signed short iIndex, plcbit xValue);
_BUR_PUBLIC plcbit GET_BIT_IN_INT(unsigned long pINT, signed short iIndex);


#ifdef __cplusplus
};
#endif
#endif /* _XML_INTERF_ */

