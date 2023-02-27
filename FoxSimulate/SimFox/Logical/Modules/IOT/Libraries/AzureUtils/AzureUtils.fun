
FUNCTION_BLOCK toJSON
	VAR_INPUT
		varName : STRING[80];
	END_VAR
	VAR
		entries : JSONEntry_type;
		Length : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION AESDecrypt : USINT
END_FUNCTION

FUNCTION generateSASToken : USINT
	VAR_INPUT
		adrResult : UDINT;
		adrPrivatekey : UDINT;
		adrUser : UDINT;
		expiry : UDINT;
	END_VAR
END_FUNCTION

FUNCTION_BLOCK IOTLoggerSimple
	VAR_INPUT
		json : STRING[5000];
		adrIOTLogIdent : UDINT;
		event : IOTLog_Type;
		eventType : STRING[20];
		timeStamp : STRING[30];
		version : STRING[10];
	END_VAR
	VAR_OUTPUT
		status : USINT;
	END_VAR
	VAR
		IOTLogWrite : LogWrite;
		initDone : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK IOTLogger
	VAR_INPUT
		adrIOTLogIdent : UDINT;
		event : IOTLog_Type;
		IOTStructName : STRING[80];
		eventType : STRING[20];
		timeStamp : STRING[30];
		version : STRING[10];
	END_VAR
	VAR_OUTPUT
		status : USINT;
	END_VAR
	VAR
		IOTLogWrite : LogWrite;
		toJSON_0 : toJSON;
		initDone : BOOL;
	END_VAR
	VAR_INPUT
		isString : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION prepLoginInfo : USINT
	VAR_INPUT
		adrLoginInfo : UDINT;
	END_VAR
END_FUNCTION
