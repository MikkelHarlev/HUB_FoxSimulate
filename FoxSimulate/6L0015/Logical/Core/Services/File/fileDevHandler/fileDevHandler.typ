(********************************************************************
 * COPYRIGHT -- Jensen Denmark A/S
 ********************************************************************
 * Program: fileDevHandler
 * File: fileDevHandler.typ
 * Author: EG
 * Created: February 04, 2011
 ********************************************************************
 * Local data types of program fileDevHandler
 ********************************************************************)

TYPE
	fileDeviceMount_type : 	STRUCT 
		folderName : STRING[32];
		fileDeviceName : STRING[32];
		initState : initState_enum;
	END_STRUCT;
END_TYPE
