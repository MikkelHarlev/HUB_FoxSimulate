FUNCTION InitAllFlatServers : DINT
END_FUNCTION
FUNCTION InitFlatClient : DINT
	VAR_INPUT
		MachineId	:UINT;
		XMLCommInfoPointer	:UDINT;
		ServerIpAddress	:STRING[40];
		StatusRefreshTime	:UINT;
		CreateLogentries	:BOOL;
		UseBase64	:BOOL;
	END_VAR
END_FUNCTION
FUNCTION InitFlatServer : DINT
	VAR_INPUT
		MachineId	:UINT;
		XMLCommInfoPointer	:UDINT;
		StatusRefreshTime	:UINT;
		CreateLogentries	:BOOL;
		UseBase64	:BOOL;
	END_VAR
END_FUNCTION
FUNCTION RunFlatClient : DINT
	VAR_INPUT
		XMLCommInfoPointer	:UDINT;
		PortNumber	:UINT;
	END_VAR
END_FUNCTION
FUNCTION RunFlatServer : DINT
	VAR_INPUT
		XMLCommInfoPointer	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION RegisterFlatFunctions : DINT
	VAR_INPUT
		ServerStatus	:DINT;
		wrback_adr	:UDINT;
	END_VAR
END_FUNCTION
