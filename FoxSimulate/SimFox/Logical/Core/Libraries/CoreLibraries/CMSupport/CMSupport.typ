(********************************************************************
 * COPYRIGHT -- JENSEN Denmark A/S
 ********************************************************************
 * Library: CMSupport
 * File: CMSupport.typ
 * Author: eg
 * Created: June 13, 2013
 ********************************************************************
 * Data types of library CMSupport
 ********************************************************************)

TYPE
	SystemFile_Connection_Type : 	STRUCT 
		isBASE64Enabled : BOOL;
		isEnabled : BOOL;
		connectionID : UDINT;
		address : STRING[80];
		options : STRING[20];
		refreshTime : UDINT;
		port : UINT;
	END_STRUCT;
	XMLComServiceInterfaceCon_Type : 	STRUCT 
		serverIPSegments : ARRAY[0..3] OF USINT;
		initState : initState_enum;
		changeID : UINT;
		isConnected : BOOL;
		enableStateTextID : USINT;
		metaData : SystemFile_Connection_Type;
		logicState : initState_enum;
		pServerHandler : UDINT;
		pClientHandler : UDINT;
		pServerLogic : UDINT;
		pClientLogic : UDINT;
	END_STRUCT;
	ComCMIFConStatus_Type : 	STRUCT 
		txErrors : UDINT;
		rxErrors : UDINT;
		serverState : UDINT;
		clientState : UDINT;
		rxCounts : UDINT;
		txCounts : UDINT;
		RefreshTime : UDINT;
		adrStatusString : UDINT;
	END_STRUCT;
	modeCom_Enum : 
		(
		OFF := 0,
		ON := 1,
		SELECTABLE := 2
		);
	ComCMCT_Enum : 
		(
		NO_ROLE_TYPE := 0,
		SERVER := 1,
		CLIENT := 2
		);
	XMLComServiceType_Enum : 
		(
		NO_PROTOCOL_TYPE := 0,
		M2M := 1,
		FUTURAIL := 2,
		JENWAYV1 := 3,
		INTERCOM := 4,
		REMOTECOM := 5,
		COCKPIT := 6,
		ARCNET := 7,
		CUSTOM := 8
		);
	runtimeState_enum : 
		(
		RS_IDLE := 0,
		RS_LOAD := 1,
		RS_SAVE := 2,
		RS_EDIT := 3,
		RS_ERROR := 4,
		RS_STATUS := 5
		);
	ComSettings_Enum : 
		(
		BASE64ENABLED := 0,
		ENABLE := 1,
		CONNECTIONID := 2,
		ADDRESS := 3,
		OPTIONS := 4,
		REFRESHTIME := 5,
		PORT := 6
		);
	ComHierarchy_Enum : 
		(
		GLOBAL := 0,
		BEHIND := 1,
		AFTER := 2
		);
	ComCMLT_Enum : 
		(
		NO_TRANSPORT_TYPE := 0,
		FLATXML := 1,
		JENTRANS := 2,
		JENTRANS_LOOPBACK := 3,
		SERIAL := 4,
		BCD := 5,
		FOLDXML := 6,
		TCPIP := 7,
		UDP := 8,
		SQL := 9
		);
	initState_enum : 
		(
		INIT := 0,
		RUNTIME := 1, (*IDLE?*)
		ERROR := 2,
		NA := 3,
		LOAD := 4, (*Not used*)
		SAVE := 5, (*Not used*)
		CHECK := 6, (*CHECK that everything is OK*)
		EDIT := 7,
		SETUP := 8
		);
	ComCMIFCon_Type : 	STRUCT 
		isEnabled : BOOL;
		descriptionID : UINT;
		transportType : ComCMLT_Enum;
		logicType : XMLComServiceType_Enum;
		sysID : UINT;
		roleType : ComCMCT_Enum;
		modeAddress : modeCom_Enum;
		modeID : modeCom_Enum;
		modeBASE64 : modeCom_Enum;
		status : ComCMIFConStatus_Type;
		maxConnectionID : UDINT;
		modeOptions : modeCom_Enum;
		modeRefreshTime : modeCom_Enum;
		pServerLogic : UDINT;
		pClientLogic : UDINT;
		pServerHandler : UDINT;
		pClientHandler : UDINT;
		hierarchy : ComHierarchy_Enum;
		modePort : modeCom_Enum;
		connectionID : UDINT;
		adrOptions : UDINT;
		adrAddress : UDINT;
	END_STRUCT;
	XMLRPCCLRuntime_Type : 	STRUCT 
		initState : initState_enum;
		connection : ARRAY[0..99] OF XMLComServiceInterfaceCon_Type;
		serversRunning : USINT;
		maxConnections : USINT;
		loadState : initState_enum;
		saveState : initState_enum;
		availableConnections : USINT;
		addedConnections : USINT;
		state : runtimeState_enum;
		semaIdent : UDINT;
		semaName : STRING[4];
	END_STRUCT;
	COMCLCMDType_Enum : 
		(
		CMD_NONE := 0,
		CMD_SAVE := 1,
		CMD_SAVE_AND_REBOOT := 2,
		CMD_LOAD := 3,
		CMD_REFRESH := 4
		);
	XMLRPCCLInterface_Type : 	STRUCT 
		cmd : COMCLCMDType_Enum;
		serverIPSegmentMin : ARRAY[0..3] OF USINT;
		serverIPSegmentMax : ARRAY[0..3] OF USINT;
		connection : ARRAY[0..99] OF ComCMIFCon_Type;
	END_STRUCT;
	XMLRPCCL_Type : 	STRUCT 
		Interface : XMLRPCCLInterface_Type;
		Runtime : XMLRPCCLRuntime_Type;
	END_STRUCT;
END_TYPE
