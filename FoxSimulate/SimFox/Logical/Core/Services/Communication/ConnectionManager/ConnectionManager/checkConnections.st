(* member function for check if the connections are valid *)
ACTION checkIpAddress:
	// Decode IP-adresses 
	EthGenUDINT := inet_addr(ADR(connectionDetails.serverAdr));
	// Split Ip-Adresses 
	FOR countByte := 0 TO 3 DO
		pEthernetCfg ACCESS (ADR(EthGenUDINT) + countByte);
		serverIPSegments[countByte] := pEthernetCfg;
	END_FOR
	
	// For all Octects in the Ip. 
	FOR countByte := 0 TO 3 DO
		// If any part of the IP-Address is invalid then set it to default and restart 
		IF (serverIPSegments[countByte] < pThis.Interface.serverIPSegmentMin[countByte]) OR (serverIPSegments[countByte] > pThis.Interface.serverIPSegmentMax[countByte]) THEN
			invalidIP := TRUE;
		END_IF
	END_FOR
END_ACTION

ACTION checkConnectionID:
		// Check if the connection ID is valid.
		IF ( connectionDetails.connectionID > pThis.Interface.connection[connectionDetails.displayConnectionNo - 1 + ((connectionPage - 1) * 5)].maxConnectionID) OR connectionDetails.connectionID < 1 THEN
			invalidConnectionID := TRUE;
		END_IF
END_ACTION

ACTION getConnectionStatus:
	// Display Client connection status
	IF (pThis.Interface.connection[connectionStatus.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].status.clientState = 1) THEN
		connectionStatus.stateClientConnectedToServer	:= 1;
	ELSIF (pThis.Runtime.connection[connectionStatus.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].initState = INIT) THEN
		connectionStatus.stateClientConnectedToServer	:= 2;
	ELSE
		connectionStatus.stateClientConnectedToServer	:= 3;
	END_IF
	// Display Server connection status
	IF (pThis.Interface.connection[connectionStatus.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].status.serverState = 1) THEN
		connectionStatus.stateServerConnectedToClient	:= 1;
	ELSIF (pThis.Runtime.connection[connectionStatus.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].initState = INIT) THEN
		connectionStatus.stateServerConnectedToClient	:= 2;
	ELSE
		connectionStatus.stateServerConnectedToClient	:= 3;
	END_IF
	connectionStatus.packagesRX					:= pThis.Interface.connection[connectionStatus.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].status.rxCounts;
	connectionStatus.packagesTX					:= pThis.Interface.connection[connectionStatus.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].status.txCounts;
	connectionStatus.packagesError				:= pThis.Interface.connection[connectionStatus.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].status.txErrors;	
	// Set status string from handler / logic.
	memset(ADR(connectionStatus.statusString),0,SIZEOF(connectionStatus.statusString));
	IF ((pThis.Interface.connection[connectionStatus.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].status.adrStatusString) > 0) THEN
 		memcpy(ADR(connectionStatus.statusString),pThis.Interface.connection[connectionStatus.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].status.adrStatusString ,SIZEOF(connectionStatus.statusString)-1);
	END_IF
	
END_ACTION

ACTION getConnectionDetails:
	connectionDetails.port					:= pThis.Runtime.connection[connectionDetails.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].metaData.port;
	connectionDetails.isPortHidden			:= (pThis.Interface.connection[connectionDetails.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].modePort <> OFF);
	connectionDetails.isPortEditable		:= (pThis.Interface.connection[connectionDetails.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].modePort = SELECTABLE);
	connectionDetails.serverAdr				:= pThis.Runtime.connection[connectionDetails.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].metaData.address;
	connectionDetails.connectionID			:= pThis.Runtime.connection[connectionDetails.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].metaData.connectionID;
	connectionDetails.descriptionID			:= pThis.Interface.connection[connectionDetails.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].descriptionID;
	connectionDetails.isBase64OptionHidden	:= (pThis.Interface.connection[connectionDetails.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].modeBASE64 = SELECTABLE);
	connectionDetails.isBase64Enabled		:= pThis.Runtime.connection[connectionDetails.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].metaData.isBASE64Enabled;
	connectionDetails.isConnectionIDEditable:= (pThis.Interface.connection[connectionDetails.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].modeID = SELECTABLE);
	connectionDetails.isAddressEditable		:= (pThis.Interface.connection[connectionDetails.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].modeAddress = SELECTABLE);
	connectionDetails.isOptionsEditable		:= (pThis.Interface.connection[connectionDetails.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].modeOptions = SELECTABLE);
	connectionDetails.refreshTime			:= pThis.Runtime.connection[connectionDetails.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].metaData.refreshTime;
	connectionDetails.options				:= pThis.Runtime.connection[connectionDetails.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].metaData.options;
	connectionDetails.isRefreshTimeEditable := (pThis.Interface.connection[connectionDetails.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].modeRefreshTime = SELECTABLE);
	connectionDetails.sysID				    := UINT_TO_USINT((pThis.Interface.connection[connectionDetails.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].sysID));
END_ACTION

