(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Package: InterCom
 * File: InterCom.typ
 * Author: eg
 * Created: March 04, 2013
 ********************************************************************
 * Data types of package InterCom
 ********************************************************************)

TYPE
	InletComControlIn_type : 	STRUCT 
		isCallingForLoad : BOOL;
		isRequesting : BOOL;
		isAborted : BOOL;
		isReceiving : BOOL;
		isReceivingDone : BOOL;
	END_STRUCT;
	InletComControlOut_type : 	STRUCT 
		isCallForLoad : BOOL;
		isAbort : BOOL;
		isReady : BOOL;
		isAbortAcknowledged : BOOL;
		isReceived : BOOL;
	END_STRUCT;
	OutletComControlOut_type : 	STRUCT 
		isAbort : BOOL;
		isAbortAcknowledged : BOOL;
		isRequesting : BOOL;
		isTransfering : BOOL;
		isTransferingDone : BOOL;
		isAborting : BOOL;
	END_STRUCT;
	OutletComControlIn_type : 	STRUCT 
		isReady : BOOL;
		isAborted : BOOL;
		isTransfered : BOOL;
		isRequesting : BOOL;
	END_STRUCT;
	ComControlStep_enum : 
		(
		INTERCOM_IDLE := 0,
		INTERCOM_REQUESTING_TRANSFER := 1,
		INTERCOM_READY_TO_TRANSFER := 2,
		INTERCOM_TRANSFERING := 3,
		INTERCOM_TRANSFERED := 4,
		INTERCOM_RESET := 5,
		INTERCOM_ABORTED := 10,
		INTERCOM_OFFLINE := 11,
		INTERCOM_CALL_FOR_LOAD := 12
		);
	ComDebug_type : 	STRUCT 
		aborts : UINT;
		userErrors : UINT;
	END_STRUCT;
	InletComSub_type : 	STRUCT 
		data : XML_Jensen_Data_Type;
		runtime : InletComControlIn_type;
		interface : InletComControlOut_type;
		step : ComControlStep_enum;
	END_STRUCT;
	OutletComSub_type : 	STRUCT 
		data : XML_Jensen_Data_Type;
		runtime : OutletComControlIn_type;
		interface : OutletComControlOut_type;
		step : ComControlStep_enum;
	END_STRUCT;
	OutletCom_type : 	STRUCT 
		outlet : ARRAY[0..9]OF OutletComSub_type;
		isConnected : BOOL;
		isRunning : BOOL;
		isError : BOOL;
		isExternalError : BOOL;
		InfomationString : STRING[80];
		debug : ComDebug_type;
	END_STRUCT;
	InletCom_type : 	STRUCT 
		inlet : ARRAY[0..9]OF InletComSub_type;
		isConnected : BOOL;
		isRunning : BOOL;
		isError : BOOL;
		isExternalError : BOOL;
		InfomationString : STRING[80];
		debug : ComDebug_type;
	END_STRUCT;
END_TYPE
