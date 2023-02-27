(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Program: HangerSetup
 * File: HangerSetup.typ
 * Author: mha
 * Created: September 26, 2012
 ********************************************************************
 * Local data types of program HangerSetup
 ********************************************************************)

TYPE
	HangerLift_Type : 	STRUCT 
		Enable : BOOL;
		State : UINT;
		IsEnabled : BOOL;
		Timeout : UDINT;
		Cycles : UINT;
	END_STRUCT;
END_TYPE
