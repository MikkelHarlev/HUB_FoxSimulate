(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: XML_Interf
 * File: XML_Interf.typ
 * Author: freundorfer
 * Created: June 25, 2012
 ********************************************************************
 * Data types of library XML_Interf
 ********************************************************************)

TYPE
	XML_Jensen_Type : 	STRUCT 
		Tx1 : INT;
		Tx2 : INT;
		Tx3 : INT;
		ProtocolVersionNumber : INT;
		InformationString : STRING[80];
		CustomerNumber : DINT;
		ArticleNumber : DINT;
		CategoryNumber : INT;
		ArticleCount : INT;
		ExpectedCount : INT;
		ExitNumber : INT;
		Option : DINT;
		LastBatch : INT;
		BatchID : DINT;
		SourceID : DINT;
		Weight : INT;
		HangerId : STRING[25];
		GarmentId : STRING[25];
	END_STRUCT;
	XML_Jensen_Data_Type : 	STRUCT 
		CustomerNumber : DINT;
		ArticleNumber : DINT;
		CategoryNumber : INT;
		ArticleCount : INT;
		ExpectedCount : INT;
		ExitNumber : INT;
		Option : DINT;
		LastBatch : INT;
		BatchID : DINT;
		SourceID : DINT;
		Weight : INT;
		HangerId : STRING[25];
		GarmentId : STRING[25];
	END_STRUCT;
	udtServerConnectionControl_type : 	STRUCT 
		arrInlet : ARRAY[0..9]OF udtInlet;
		udtServerData : XML_Jensen_Data_Type;
		xAbortFlag : BOOL;
		iSelectedInlet : INT;
		xIN_ClientOP_ModeOff : BOOL;
		xIN_ClientError : BOOL;
		xIN_ClientExternalError : BOOL;
		xIN_InformationString : STRING[80];
		xIN_ClientAborted : BOOL;
		xOUT_ServerOP_ModeOff : BOOL;
		xOUT_ServerError : BOOL;
		xOUT_ServerExternalError : BOOL;
		xOUT_InformationString : STRING[80];
		uiUserErrorCounter : UINT;
		uiAbortCounter : UINT;
		xActivate : BOOL;
		xActive : BOOL;
		xResetAbortCounter : BOOL;
		xResetUserErrorCounter : BOOL;
	END_STRUCT;
	udtOutlet : 	STRUCT 
		xIN_ServerCallForLoad : BOOL;
		xIN_ServerReadyToLoad : BOOL;
		xIN_ServerUnloadingDone : BOOL;
		xOUT_ClientReadyToUnload : BOOL;
		xOUT_ClientUnloading : BOOL;
		xOUT_ClientUnloadingDone : BOOL;
	END_STRUCT;
	udtInlet : 	STRUCT 
		xIN_ClientReadyToUnload : BOOL;
		xIN_ClientUnloading : BOOL;
		xIN_ClientUnloadingDone : BOOL;
		xOUT_ServerCallForLoad : BOOL;
		xOUT_ServerReadyToLoad : BOOL;
		xOUT_ServerUnloadingDone : BOOL;
	END_STRUCT;
	udtClientConnectionControl_type : 	STRUCT 
		arrOutlet : ARRAY[0..9]OF udtOutlet;
		udtClientData : XML_Jensen_Data_Type;
		xAbortFlag : BOOL;
		xOUT_ClientOP_ModeOff : BOOL;
		xOUT_ClientError : BOOL;
		xOUT_ClientExternalError : BOOL;
		xOUT_InformationString : STRING[80];
		xIN_ServerOP_ModeOff : BOOL;
		xIN_ServerError : BOOL;
		xIN_ServerExternalError : BOOL;
		xIN_InformationString : STRING[80];
		xIN_ServerAborted : BOOL;
		uiUserErrorCounter : UINT;
		uiAbortCounter : UINT;
		xActivate : BOOL;
		xActive : BOOL;
		xResetAbortCounter : BOOL;
		xResetUserErrorCounter : BOOL;
	END_STRUCT;
END_TYPE
