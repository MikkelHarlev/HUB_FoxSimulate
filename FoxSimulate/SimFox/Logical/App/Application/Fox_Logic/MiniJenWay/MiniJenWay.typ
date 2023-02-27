(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: MiniJenWay
 * File: MiniJenWay.typ
 * Author: jspernil
 * Created: June 02, 2009
 ********************************************************************
 * Local data types of program MiniJenWay
 ********************************************************************)

TYPE
	BeltController_Type : 	STRUCT 
		Input : BeltInput_Type;
		Timers : BeltTimer_Type;
		Output : BeltOutput_Type;
		State : UINT;
		CurTimer : UINT;
		InitDone : BOOL;
		FilterPhotocell : Full_Type;
		OffdelayPhotocell : Full_Type;
	END_STRUCT;
	BeltInput_Type : 	STRUCT 
		Photocell : BOOL;
		PrevToUnload : BOOL;
		NextIsReady : BOOL;
	END_STRUCT;
	BeltTimer_Type : 	STRUCT 
		MaxRunTime : UINT;
		MaxRunTimer : UINT;
		WaitAfterRXTimer : UINT;
	END_STRUCT;
	BeltOutput_Type : 	STRUCT 
		Motor : BOOL;
		IsReady : BOOL;
		WantToUnload : BOOL;
	END_STRUCT;
END_TYPE
