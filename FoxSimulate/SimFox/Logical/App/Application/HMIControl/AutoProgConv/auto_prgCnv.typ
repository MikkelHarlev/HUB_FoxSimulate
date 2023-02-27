(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: auto_prg
 * File: auto_prg.typ
 * Author: jspernil
 * Created: May 28, 2009
 ********************************************************************
 * Local data types of program auto_prg
 ********************************************************************)

TYPE
	CopyProgram_Type : 	STRUCT 
		Cmd : UINT;
		FromProgram : UINT;
		ToProgram : UINT;
		EndProgram : UINT;
	END_STRUCT;
	AutoProgramFile_Type : 	STRUCT 
		State : UINT;
		CurrentIndex : UINT;
		HideInfo : UINT;
		Info : STRING[121];
		Input : AutoProgramInput_Type;
	END_STRUCT;
	AutoProgramCmd_Type : 	STRUCT 
		ForceRestore : BOOL;
		ForceWrite : BOOL;
		ForceFactory : BOOL;
		IconShowed : BOOL;
		KeyDownCount : UINT;
		Convert : BOOL;
	END_STRUCT;
	AutoProgramStatus_Type : 	STRUCT 
		DeviceName : STRING[40];
		DeviceParameters : STRING[40];
		FileName : STRING[40];
		EnableChecksum : BOOL;
	END_STRUCT;
	AutoProgramInput_Type : 	STRUCT 
		Status : AutoProgramStatus_Type;
		Cmd : AutoProgramCmd_Type;
	END_STRUCT;
END_TYPE
