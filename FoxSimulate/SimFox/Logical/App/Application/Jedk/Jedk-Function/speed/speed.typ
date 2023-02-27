(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Program: speed
 * File: speed.typ
 * Author: mha
 * Created: July 20, 2012
 ********************************************************************
 * Local data types of program speed
 ********************************************************************)

TYPE
	HangerConveyorCounter_Type : {REDUND_UNREPLICABLE} 	STRUCT  (* *) (* *) (*13*)
		Counter : {REDUND_UNREPLICABLE} UDINT; (* *) (* *) (*14*)
		CounterMovedRest : {REDUND_UNREPLICABLE} LREAL; (* *) (* *) (*15*)
		CounterMoved : {REDUND_UNREPLICABLE} LREAL; (* *) (* *) (*16*)
		InverterFactor : {REDUND_UNREPLICABLE} LREAL := 0.00060717; (* *) (* *) (*17*)
	END_STRUCT;
	GearAdjust_Type : 	STRUCT 
		Adjust : BOOL;
		DelayAdjust : UDINT;
		MaxValue_DelayAdjust : UINT;
		SpeedFactor : REAL := 3.0;
		OldSpeedFactor : REAL;
		SpeedIroner : UDINT;
		SpeedFolder : UDINT;
		SpeedPercentage : USINT;
		SaveHCfg : BOOL;
	END_STRUCT;
END_TYPE
