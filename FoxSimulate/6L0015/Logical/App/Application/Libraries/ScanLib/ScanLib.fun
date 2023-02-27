FUNCTION SendToNode : INT 
VAR_INPUT
		ScanPort	:ScanPort_Type;	
		NodeId	:USINT;	
		SendMessage	:UDINT;	
		Delimiter	:USINT;	
	END_VAR
END_FUNCTION
FUNCTION GetTelegramFromNode : INT 
VAR_INPUT
		ScanPort	:ScanPort_Type;	
		NodeId	:USINT;	
		ReturnMsg	:UDINT;	
		FixMsgLen	:UINT;	
		Delimiter	:USINT;	
	END_VAR
END_FUNCTION
(*FUNCTION PickupMsgFromComModule : INT 
VAR_INPUT
		ComModule	:ComModule_Type;	
	END_VAR
END_FUNCTION*)
FUNCTION ReadScan : INT 
VAR_INPUT
		ScanPort	:ScanPort_Type;	
		ScannerId	:USINT;	
		ReaderData	:STRING[IDLength];	
	END_VAR
END_FUNCTION
FUNCTION InitComBus : DINT 
VAR_INPUT
		ComBus	:ScanPort_Type;	
	END_VAR
END_FUNCTION
FUNCTION InitComUnit : DINT 
VAR_INPUT
		ComBus	:ScanPort_Type;	
		ComUnitId	:UINT;	
		FunctionType	:UINT;	
		DeviceString	:STRING[41];	
		ParamString	:STRING[41];	
		IdleCount	:UINT;	
		DelimCharacter1	:UINT;	
		DelimCharacter2	:UINT;	
		MaxMessageLength	:UINT;	
	END_VAR
END_FUNCTION
FUNCTION RunComBus : DINT 
VAR_INPUT
		ComBus	:ScanPort_Type;	
	END_VAR
END_FUNCTION
