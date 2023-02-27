
PROGRAM _INIT
	
	// Sntp Server parameters
	CfgSetSntpServer_0.enable 			:= 0;
	CfgSetSntpServer_0.start 			:= 0;
	CfgSetSntpServer_0.option 			:= 0;
	
	// Sntp Client parameters - TEST
	CfgSetSntpClient_0.enable 			:= 0;
	CfgSetSntpClient_0.run 				:= 0;
	CfgSetSntpClient_0.sntpcInterval	:= 9;
	CfgSetSntpClient_0.rtcInterval 		:= 11;
	CfgSetSntpClient_0.option 			:= 0;

END_PROGRAM


PROGRAM _CYCLIC

	// Run timeserver on plc.
	IF (CfgSetSntpServer_0.enable) THEN
		CfgSetSntpServer_0();
		IF CfgSetSntpServer_0.status = 0 THEN
			CfgSetSntpServer_0.enable := 0;
		END_IF
	END_IF
	
	// Check for a connection behind the machine and get the ip of that machine.
	IF NOT isConnectionFound THEN
		IF (g_Core.Services.Communication.ConnectionManager.Runtime.availableConnections > 0) THEN
			FOR no := 0 TO g_Core.Services.Communication.ConnectionManager.Runtime.availableConnections - 1 DO
				// Catch first connection behind which is active.
				IF ( (g_Core.Services.Communication.ConnectionManager.Interface.connection[no].hierarchy = BEHIND OR g_Core.Services.Communication.ConnectionManager.Interface.connection[no].hierarchy = GLOBAL) AND g_Core.Services.Communication.ConnectionManager.Runtime.connection[no].metaData.isEnabled) THEN
					isConnectionFound := TRUE;
					// Get server address
					timeServerAddress := g_Core.Services.Communication.ConnectionManager.Runtime.connection[no].metaData.address;
					CfgSetSntpClient_0.pServerAddr := ADR(timeServerAddress);
					CfgSetSntpClient_0.enable := 1;
					EXIT;
				END_IF
			END_FOR
		END_IF
	END_IF
	
	// Run timserver client if enabled.
	IF isConnectionFound THEN
		IF CfgSetSntpClient_0.enable THEN
			CfgSetSntpClient_0();
			IF ((CfgSetSntpClient_0.status = 0 AND CfgSetSntpClient_0.syncStatus = 2)) THEN
				CfgSetSntpClient_0.enable := 0;
			END_IF
		END_IF
	END_IF
	
END_PROGRAM
