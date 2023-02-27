(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: M2M
 * File: M2M.typ
 * Author: eg
 * Created: May 23, 2014
 ********************************************************************
 * Local data types of program M2M
 ********************************************************************)

TYPE
	M2MLogicCom_typ : 	STRUCT 
		TxLane : USINT;
		TxLaneOld : USINT;
		TxSend : BOOL;
		FlatworkData : ARRAY[0..8] OF XMLFlatworkData_Type;
		TxResendCounter : UDINT;
		TxResend : ARRAY[0..8] OF UDINT;
		RSrt : ARRAY[0..8] OF BOOL;
		RInfo : ARRAY[0..8] OF BOOL;
		RResendEnable : ARRAY[0..8] OF BOOL;
		TxWait : BOOL;
		TimeOut : UDINT;
		Update : USINT;
		ResendInterval : UDINT;
	END_STRUCT;
END_TYPE
