(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: RealTime
 * File: RealTime.typ
 * Author: fuglsah
 * Created: November 10, 2014
 ********************************************************************
 * Local data types of program RealTime
 ********************************************************************)

TYPE
	RealTimeSetup_Type : 	STRUCT 
		MachineID : UDINT;
		Status : UDINT;
		Piececount : UDINT;
		OnTime : UDINT;
		RunTime : UDINT;
		ErrorID : UDINT;
		ErrorString_Local : STRING[100];
		ErrorString_GB : STRING[100];
	END_STRUCT;
	SubID_Type : 	STRUCT 
		MachineID : UDINT;
		SubID : UDINT;
		Operator : UDINT;
		Customer : UDINT;
		Article : UDINT;
	END_STRUCT;
	Setup_Type : 	STRUCT 
		Setup : RealTimeSetup_Type;
		SubIDPrep : SubID_Type;
	END_STRUCT;
END_TYPE
