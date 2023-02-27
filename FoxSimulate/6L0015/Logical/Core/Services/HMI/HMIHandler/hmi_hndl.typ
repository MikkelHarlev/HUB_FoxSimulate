(********************************************************************
 * COPYRIGHT -- Jensen Denmark A/S
 ********************************************************************
 * Program: hmi_hndl
 * File: hmitask.typ
 * Author: eg
 * Created: November 18, 2010
 ********************************************************************
 * Local data types of program hmi_hndl
 ********************************************************************)

TYPE
	HMIButtonTheme_Type : 	STRUCT 
		Pressed : UINT;
		Active : UINT;
		InActive : UINT;
	END_STRUCT;
	HMIMagicButtons_Type : 	STRUCT 
		Locked : ARRAY[0..15] OF UINT;
		Key : ARRAY[0..15] OF UINT;
	END_STRUCT;
END_TYPE
