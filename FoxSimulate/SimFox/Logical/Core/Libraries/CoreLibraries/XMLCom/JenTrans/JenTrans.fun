
FUNCTION freexmlmemory : DINT
END_FUNCTION

FUNCTION SetXMLPortNumber : DINT
	VAR_INPUT
		PortNumber : UINT;
	END_VAR
END_FUNCTION

FUNCTION ClearJenTransData : DINT
	VAR_INPUT
		XMLCommInfoPointer : JenTransCommonInfo_Type;
	END_VAR
END_FUNCTION

FUNCTION InitAllXMLServerAndClients : DINT
END_FUNCTION

FUNCTION InitDynaXMLServerAndClients : DINT
	VAR_INPUT
		numberOfObjects : UINT;
	END_VAR
END_FUNCTION

FUNCTION RegisterXMLFunctions : DINT
	VAR_INPUT
		ServerStatus : DINT;
		wrback_adr : UDINT;
	END_VAR
END_FUNCTION

FUNCTION RunXMLServer : DINT
	VAR_INPUT
		XMLCommInfoPointer : UDINT;
	END_VAR
END_FUNCTION

FUNCTION RunXMLClient : DINT
	VAR_INPUT
		XMLCommInfoPointer : UDINT;
	END_VAR
END_FUNCTION

FUNCTION InitXMLServer : DINT
	VAR_INPUT
		ObjectType : UINT;
		ObjectId : UINT;
		XMLCommInfoPointer : UDINT;
		DataVariableName : STRING[80];
		StatusRefreshTime : UINT;
	END_VAR
END_FUNCTION

FUNCTION InitXMLClient : DINT
	VAR_INPUT
		ObjectType : UINT;
		ObjectId : UINT;
		XMLCommInfoPointer : UDINT;
		DataVariableName : STRING[80];
		ServerIpAddress : STRING[21];
		StatusRefreshTime : UINT;
	END_VAR
END_FUNCTION

FUNCTION XMLTransferDataWithStatus : DINT
	VAR_INPUT
		XMLCommInfoPointer : UDINT;
		Activate : INT;
	END_VAR
END_FUNCTION

FUNCTION XMLSupressUnknownTag : DINT
	VAR_INPUT
		XMLCommInfoPointer : UDINT;
	END_VAR
END_FUNCTION
