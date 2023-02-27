(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Program: XMLConnectionHandler
 * File: XMLConnectionHandler.typ
 * Author: eg
 * Created: April 24, 2012
 ********************************************************************
 * Local data types of program XMLConnectionHandler
 ********************************************************************)

TYPE
	connectionDetailsCmd_enum : 
		(
		CD_IDLE := 0,
		CD_UNDO := 1,
		CD_SAVE := 2,
		CD_CANCEL := 3
		);
	connectionHMI_type : 	STRUCT 
		statusTextID : UINT;
		statusColor : UINT;
		isHidden : UINT;
		isEnabled : BOOL;
		connectionNumber : UINT;
		descriptionID : UINT;
	END_STRUCT;
	connectionStatus_type : 	STRUCT 
		isHidden : UINT;
		stateServerConnectedToClient : UINT;
		stateClientConnectedToServer : UINT;
		packagesRX : UDINT;
		packagesTX : UDINT;
		packagesError : UDINT;
		cmd : USINT; (*ping / close*)
		pingStatus : USINT; (*0 = not initiated 1 = testing 2 = connection 3 = error.*)
		connectionState : USINT;
		displayConnectionNo : USINT;
		statusString : STRING[200];
		serverAdr : STRING[80];
		pingEnable : BOOL;
		pingIPNetworkByteOrdre : UDINT;
		pingColor : USINT;
		pingTimeout : UDINT;
		CCstring : STRING[80];
	END_STRUCT;
END_TYPE

(*Insert your comment here.*)

TYPE
	connectionDetails_type : 	STRUCT 
		isHidden : UINT;
		displayConnectionNo : USINT;
		cmd : connectionDetailsCmd_enum;
		serverAdr : STRING[120];
		connectionID : UDINT;
		descriptionID : UINT;
		isBase64OptionHidden : UINT;
		isConnectionIDEditable : UINT;
		isBase64Enabled : BOOL;
		isServerAdrEntered : BOOL;
		isHiddenErrorDialog : UINT;
		errorDialogString : STRING[120];
		refreshTime : UDINT;
		isRefreshTimeEditable : UINT;
		isConnectionIDEntered : BOOL;
		port : UINT;
		isPortHidden : BOOL;
		isPortEditable : BOOL;
		isPortEntered : BOOL;
		isOptionsHidden : UINT;
		isOptionsEditable : UINT;
		isAddressEditable : UINT;
		options : STRING[20];
		sysID : USINT;
	END_STRUCT;
END_TYPE
