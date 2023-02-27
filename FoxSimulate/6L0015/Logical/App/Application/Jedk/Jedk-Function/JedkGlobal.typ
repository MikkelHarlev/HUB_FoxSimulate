(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Package: Jedk-Function
 * File: JedkGlobal.typ
 * Author: mha
 * Created: August 28, 2012
 ********************************************************************
 * Data types of package Jedk-Function
 ********************************************************************)

TYPE
	ToLatFold_Type : 	STRUCT 
		RearPoint : UDINT;
		PosBPoint : UDINT;
		Diff : UDINT;
		JamTopConv : BOOL;
	END_STRUCT;
	PhoenixAlarm_Type : 	STRUCT 
		isExtEStopActive : BOOL;
		isEStopActive : BOOL;
		isSafety1Active : BOOL;
		isSafety2Active : BOOL;
		isSafety3Active : BOOL;
		isSafety4Active : BOOL;
		isSafety5Active : BOOL;
		isSafety6Active : BOOL;
		isSafetyPlcError : BOOL;
	END_STRUCT;
	TimeStamp_Type : 	STRUCT  (* Time Stamp structure*)
		hour : USINT; (*hours (0-23)*)
		minute : USINT; (*minutes (0-59)*)
		second : USINT; (*seconds (0-59)*)
		millisec : UINT; (*milliseconds (0-999)*)
	END_STRUCT;
END_TYPE
