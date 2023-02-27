FUNCTION AddCacheClientToFoldServer : DINT 
VAR_INPUT
		XMLCommInfoPointer	:JenXMLCommInfo_Type;	
		CacheclientPointer	:UDINT;	
	END_VAR
END_FUNCTION
FUNCTION InitAllFolderServers : DINT 

END_FUNCTION
FUNCTION InitFoldClient : DINT 
VAR_INPUT
		MachineType	:UINT;	
		MachineId	:UINT;	
		XMLCommInfoPointer	:UDINT;	
		ServerIpAddress	:STRING[40];	
		StatusRefreshTime	:UINT;	
	END_VAR
END_FUNCTION
FUNCTION InitFoldServer : DINT 
VAR_INPUT
		MachineType	:UINT;	
		MachineId	:UINT;	
		XMLCommInfoPointer	:UDINT;	
		StatusRefreshTime	:UINT;	
	END_VAR
END_FUNCTION
FUNCTION RunFoldClient : DINT 
VAR_INPUT
		XMLCommInfoPointer	:UDINT;	
	END_VAR
END_FUNCTION
FUNCTION RunFoldServer : DINT 
VAR_INPUT
		XMLCommInfoPointer	:UDINT;	
	END_VAR
END_FUNCTION
FUNCTION RegisterFoldFunctions : DINT 
VAR_INPUT
		ServerStatus	:DINT;	
		wrback_adr	:UDINT;	
	END_VAR
END_FUNCTION
FUNCTION SetFoldXMLPortNumber : DINT 
VAR_INPUT
		PortNumber	:UINT;	
	END_VAR
END_FUNCTION
