(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: XML_Interf
 * File: XML_Interf.fun
 * Author: freundorfer
 * Created: June 25, 2012
 ********************************************************************
 * Functions and function blocks of library XML_Interf
 ********************************************************************)

FUNCTION_BLOCK XML_ServerConnection (*TODO: Add your comment here*)
	VAR_INPUT
		pSendStruct : UDINT;
		pReceiveStruct : UDINT;
		pServerConnectionControl : UDINT;
		pClientUpdateTrigger : UDINT;
		pServerUpdateTrigger : UDINT;
		pConnected : UDINT;
	END_VAR
	VAR_OUTPUT
		xConnectionTimeout : BOOL;
	END_VAR
	VAR
		xConnected : REFERENCE TO BOOL;
		iStep : INT;
		udtReceiveStruct : REFERENCE TO XML_Jensen_Type;
		udtSendStruct : REFERENCE TO XML_Jensen_Type;
		udtServerConnectionControl : REFERENCE TO udtServerConnectionControl_type;
		i : INT;
		TON_3000ms : TON;
		TON_1000ms : TON;
		xFlagInletCallForLoad : BOOL;
		iSelectedInlet : INT;
		F_TRIG_UpdateTrigger : F_TRIG;
		iSendCounter : INT;
		TOF_ConnectionTimeout : TOF;
		TON_CommunicationTimeout : TON;
		xStartCommunicationTimeout : BOOL;
		R_TRIG_ResetAbortCounter : R_TRIG;
		R_TRIG_ResetUserErrorCounter : R_TRIG;
		xClientUpdateTrigger : REFERENCE TO BOOL;
		xServerUpdateTrigger : REFERENCE TO BOOL;
		oldServerTx3 : INT;
		R_TRIG_AbortFlag : R_TRIG;
		xStepChange : BOOL;
		iOldStep : INT;
		serverCallForLoad : BOOL; (*19-06-2014 - JEDK - MDU - Needed this flage to see if the server was still CallForLoad*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK XML_ClientConnection (*TODO: Add your comment here*)
	VAR_INPUT
		pSendStruct : UDINT;
		pReceiveStruct : UDINT;
		pClientConnectionControl : UDINT;
		pClientUpdateTrigger : UDINT;
		pServerUpdateTrigger : UDINT;
		pConnected : UDINT;
	END_VAR
	VAR
		xConnected : REFERENCE TO BOOL;
		iStep : INT;
		udtReceiveStruct : REFERENCE TO XML_Jensen_Type;
		xResult : BOOL;
		udtSendStruct : REFERENCE TO XML_Jensen_Type;
		i : INT;
		TON_3000ms : TON;
		TON_1000ms : TON;
		iInitStep : INT;
		F_TRIG_UpdateTrigger : F_TRIG;
		TOF_ConnectionTimeout : TOF;
		xConnectionTimeout : BOOL;
		TON_CommunicationTimeout : TON;
		xStartCommunicationTimeout : BOOL;
		udtClientConnectionControl : REFERENCE TO udtClientConnectionControl_type;
		xFlagOutletReadyToUnload : BOOL;
		iSelectedOutlet : INT;
		R_TRIG_ResetAbortCounter : R_TRIG;
		R_TRIG_ResetUserErrorCounter : R_TRIG;
		xClientUpdateTrigger : REFERENCE TO BOOL;
		xServerUpdateTrigger : REFERENCE TO BOOL;
		OldTx3 : INT;
		zzEdge00000 : BOOL;
		zzEdge00001 : BOOL;
		zzEdge00002 : BOOL;
		zzEdge00003 : BOOL;
		zzEdge00004 : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION SET_BIT_IN_INT : BOOL (*TODO: Add your comment here*)
	VAR_INPUT
		pINT : UDINT;
		iIndex : INT;
		xValue : BOOL;
	END_VAR
	VAR
		iINT : REFERENCE TO INT;
	END_VAR
END_FUNCTION

FUNCTION GET_BIT_IN_INT : BOOL (*TODO: Add your comment here*)
	VAR_INPUT
		pINT : UDINT;
		iIndex : INT;
	END_VAR
	VAR
		iINT : REFERENCE TO INT;
	END_VAR
END_FUNCTION
