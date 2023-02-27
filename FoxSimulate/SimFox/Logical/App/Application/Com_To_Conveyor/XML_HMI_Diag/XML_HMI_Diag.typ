(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: XML_HMI_Diag
 * File: XML_HMI_Diag.typ
 * Author: jspernil
 * Created: June 23, 2009
 ********************************************************************
 * Local data types of program XML_HMI_Diag
 ********************************************************************)

TYPE
	XMLDiag_Type : 	STRUCT 
		MainIconState : UINT;
		cmdComState : UINT;
		ConnectionState : XMLConnectionState_Type;
		StatusSignals : XMLStatusSignal_Type;
		GarmentData : XMLGarmentData_Type;
		Counters : XMLCounters_Type;
	END_STRUCT;
	XMLCounters_Type : 	STRUCT 
		StatusSend : UINT;
		TimeOut : UINT;
		RequestCounter : UINT;
		AwayCounter : UINT;
	END_STRUCT;
	XMLStatusSignal_Type : 	STRUCT 
		InletActive : INT;
		InletFull : INT;
		OutletFull : INT;
		HangerWaiting : INT;
	END_STRUCT;
	XMLConnectionState_Type : 	STRUCT 
		ComState : UINT;
		ServerVersion : STRING[10];
		ClientVersion : STRING[10];
		ClientMachineStatus : UINT;
	END_STRUCT;
	XMLGarmentData_Type : 	STRUCT 
		Program : UINT;
		Article : UINT;
		Customer : UDINT;
		Stack : UINT;
		Destination : UINT;
		GarmentId : STRING[40];
		HangerStatus : UINT;
	END_STRUCT;
END_TYPE
