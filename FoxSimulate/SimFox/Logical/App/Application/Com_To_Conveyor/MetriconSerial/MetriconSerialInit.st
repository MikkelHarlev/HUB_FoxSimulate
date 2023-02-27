
PROGRAM _INIT



// Clear send buffer...
FOR Index := 0 TO MAX_BUFFER DO
	OutBuffer[Index] := 0;
END_FOR	

PageMetSerial 							:= LookupPageID(543,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);

// Do not make loggs as default...
LogFlag := 0;


END_PROGRAM

