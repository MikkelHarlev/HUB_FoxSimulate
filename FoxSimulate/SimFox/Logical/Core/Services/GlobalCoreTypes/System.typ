
TYPE
	AlarmExtern_Type : 	STRUCT 
		isActive : BOOL;
		descriptionAscii : STRING[80];
		descriptionUnicode : ARRAY[0..69]OF UINT;
		color : UINT;
	END_STRUCT;
	AlarmHandlerEvent_Type : 	STRUCT 
		Status : USINT;
		Acknowledged : BOOL;
		AlarmID : UINT;
		GroupID : UINT;
		DescAscii : STRING[80];
		DescAsciiPrev : STRING[80];
		DescUniCode : ARRAY[0..79]OF UINT;
		Severity : UINT;
		AckStatus : STRING[1];
		Priority : USINT;
		DateTime : DATE_AND_TIME;
	END_STRUCT;
	AlarmInterface_Type : 	STRUCT 
		Runtime : AlarmServiceRuntime_Type;
		Interface : AlarmServiceInterface_Type;
	END_STRUCT;
	AlarmServiceInterface_Type : 	STRUCT 
		AlarmGroup : ARRAY[0..20]OF AlarmLog_Type;
		ExternInfo : ARRAY[0..1]OF AlarmExtern_Type;
		ExternAlarm : ARRAY[0..1]OF AlarmExtern_Type;
		FileError : FileErrorLayer_Type;
		MachineAlarmPage : UINT;
		UserGroupID : ARRAY[0..1]OF UINT;
	END_STRUCT;
	AlarmServiceRuntime_Type : 	STRUCT 
		MachineAlarmPageID : UINT;
		UserGroupID : ARRAY[0..1]OF UINT;
		AckShow : BOOL;
		Event : ARRAY[0..1]OF AlarmHandlerEvent_Type;
		InverterNames : ARRAY[0..10]OF STRING[80];
		blinkPulse : BOOL;
		isSendAlarmToTop : BOOL;
	END_STRUCT;
	BackupService_Type : 	STRUCT 
		Runtime : BackupServiceRuntime_Type;
		Interface : BackupServiceInterface_Type;
	END_STRUCT;
	BackupServiceInterface_Type : 	STRUCT 
		Dummy : BOOL;
	END_STRUCT;
	BackupServiceRuntime_Type : 	STRUCT 
		isUsbStorageAttached : BOOL;
	END_STRUCT;
	BlackboxRuntime_Type : 	STRUCT 
		Master : BlackboxMachineRuntime_Type;
		Slave : BlackboxMachineRuntime_Type;
		initState : initState_enum;
		server : JenViewTaskInterface_Type;
	END_STRUCT;
	BlackboxInterface_Type : 	STRUCT 
		Master : BlackboxMachineInterface_Type;
		Slave : BlackboxMachineInterface_Type;
	END_STRUCT;
	BlackboxService_Type : 	STRUCT 
		Runtime : BlackboxRuntime_Type;
		Configuration : BlackboxSetup_Type;
		Interface : BlackboxInterface_Type;
	END_STRUCT;
	blackBox_Enum : 
		(
		BLACKBOX_XMLRPC := 1,
		BLACKBOX_SQL := 2
		);
	BlackboxSetup_Type : 	STRUCT 
		Master : BlackboxMachineSetup_Type;
		Slave : BlackboxMachineSetup_Type;
		mode : blackBox_Enum;
	END_STRUCT;
	CARService_Type : 	STRUCT 
		Interface : CARServiceInterface_Type;
		Runtime : CARServiceRuntime_Type;
	END_STRUCT;
	CatSelectionLayer_Type : 	STRUCT 
		Caller : UINT;
		ShowLayer : UINT;
		SelectedRecipe : UINT;
		DefaultListIndex : UINT;
		ReturnStatus : UINT;
	END_STRUCT;
	CategorySelection_Type : 	STRUCT 
		cmdUp : BOOL;
		cmdDown : BOOL;
		ActualFoldProgram : UINT;
		cmdConfirmFoldProgram : BOOL;
		cmdNewFoldProgramSelected : BOOL;
		cmdDirectFoldProgramSelect : UINT;
		SelectedFoldProgram : UINT;
		MaxFoldPrograms : UINT;
		inxSelectedFoldProgram : UINT;
		cmdPageChange : UINT;
		IdString : ARRAY[0..99]OF STRING[5];
		cmdCancelSelection : BOOL;
	END_STRUCT;
END_TYPE

(********************************************************************
 * COPYRIGHT -- Jensen Denmark A/S
 ********************************************************************
 * Package: MachineSetup
 * File: MachineSetup.typ
 * Author: eg
 * Created: December 22, 2010
 ********************************************************************
 * Data types of package MachineSetup
 ********************************************************************)

TYPE
	CARServiceInterface_Type : 	STRUCT 
		No : ARRAY[0..9]OF CARServiceInterfaceNo_Type;
		isCmdLoad : BOOL;
	END_STRUCT;
	CARServiceInterfaceNo_Type : 	STRUCT 
		isCmdIncrementLoadID : BOOL;
		CustomerNumber : UDINT;
		ArticleNumber : UDINT;
		RecipeNumber : USINT;
		cmdSearchCustArtNo : BOOL;
	END_STRUCT;
	CARServiceRuntime_Type : 	STRUCT 
		HMIShow : UINT;
		initState : initState_enum;
		No : ARRAY[0..9]OF CARServiceRuntimeNo_Type;
		isEnabled : BOOL;
		saveCount : UDINT;
		loadCount : UDINT;
	END_STRUCT;
	CARServiceRuntimeNo_Type : 	STRUCT 
		LoadID : UDINT;
		CustomerNumber : UDINT;
		ArticleNumber : UDINT;
		RecipeNumber : USINT;
		CustomerName : STRING[80];
		ArticleName : STRING[80];
		RecipeName : STRING[80];
		Norm : UINT;
		Primary : UINT;
		Reference : UINT;
		FlowTimeout : UINT;
		RecipeNameUC : ARRAY[0..80]OF UINT;
	END_STRUCT;
	CockpitRT_type : 	STRUCT 
		Runtime : CockpitRTRuntime_Type;
	END_STRUCT;
	CockpitRTRuntime_Type : 	STRUCT 
		initState : initState_enum;
	END_STRUCT;
	Configuration_Type : 	STRUCT 
		machineType : UINT;
		ipRange : Ipcfg_Task_Range_Type;
		isHidePlcHalt : BOOL;
		isHideUnForceHMI : BOOL;
		isRemotePanelModeEnabled : BOOL;
		isRemoteEnabled : BOOL;
		SystemDescription : MachineData_Type;
		adrInOperationVarName : UDINT;
		adrEStopVarName : UDINT;
		isTimerDescriptionEnabled : BOOL;
		isSafetyPLCMonitoringEnabled : BOOL;
		userEthernetIF : STRING[4];
		adrInverterVarName : UDINT;
		adrSafeBit0VarName : UDINT;
		adrSafeBit1VarName : UDINT;
		arrSizeRCfg : UINT;
		adrMCfgVarName : UDINT;
		adrRCfgNameVarName : UDINT;
		adrRCfgNormVarName : UDINT;
		adrRCfgVarName : UDINT;
		arrSizeACfg : UINT;
		adrACfgNameVarName : UDINT;
		adrACfgVarName : UDINT;
		adrHCfgVarName : UDINT;
		isBlockSaveHCfg : BOOL;
		isBlockIcons : BOOL;
		isShowAlarmAckButton : BOOL;
		isArrayZeroBased : BOOL;
		adrAxisVarName : UDINT;
		adrBuzzerVarName : UDINT;
		hwID : UDINT;
		pecID : USINT;
		userUsbIF : STRING[10];
		SafetyFileName : STRING[80];
	END_STRUCT;
	CoreMachine_Type : 	STRUCT 
		Services : MachineServices_Type;
		System : CoreSystem_Type;
	END_STRUCT;
	CoreSystem_Type : 	STRUCT 
		Runtime : CoreSystemRuntime_Type;
		Configuration : Configuration_Type;
		Interface : CoreSystemInterface_Type;
	END_STRUCT;
	CoreSystemInterface_Type : 	STRUCT 
		alarms : CoreSystemInterfaceAlarms_Type;
		infos : CoreSystemInterfaceInfos_Type;
		setLanguage : USINT;
		cmdSaveLogBookFile : BOOL;
		isAppReady : BOOL;
		isRequestReboot : BOOL;
		timelineIntervalInSec : UINT;
		isCustomerEnabled : BOOL;
		isOperatorEnabled : BOOL;
		remotePanelMode : UINT;
		showLevel : USINT;
	END_STRUCT;
	CoreSystemInterfaceAlarms_Type : 	STRUCT 
		isEStopActive : BOOL;
		isGuardFault : BOOL;
		isThermoFault : BOOL;
		isFuseFault24V : BOOL;
		isLowAirPressure : BOOL;
		isBatteryLow : BOOL;
		isPLCHalted : BOOL;
		isBlackBoxFault : BOOL;
		isInterverDisconnected : BOOL;
		isInterverError : BOOL;
		isAcoposError : BOOL;
		isAcoposErrorCleared : BOOL;
		isAcoposErrorPowerOff : BOOL;
		isExtEStopActive : BOOL;
		isSafetyPlcError : BOOL;
		isExternAlarm : ARRAY[0..1]OF BOOL;
		isSafety1Active : BOOL;
		isSafety2Active : BOOL;
		isSafety3Active : BOOL;
		isSafety4Active : BOOL;
		isSafety5Active : BOOL;
		isSafety6Active : BOOL;
		isSafetyActive : ARRAY[0..21]OF BOOL;
		isSafetyPressReset : BOOL;
		isSafetyInitializing : BOOL;
	END_STRUCT;
	CoreSystemInterfaceInfos_Type : 	STRUCT 
		isCheckAlarm : BOOL;
		isReadyToStart : BOOL;
		isInOperation : BOOL;
		isInOperationPowerSave : BOOL;
		isInitializing : BOOL;
		isAcoposInitializing : BOOL;
		isCustomerPending : BOOL;
		isInverterInitializing : BOOL;
		isExternInfo : ARRAY[0..1]OF BOOL;
	END_STRUCT;
	CoreSystemRuntime_Type : 	STRUCT 
		isRunning : BOOL;
		isEStopActivated : BOOL;
		isInitDone : BOOL;
		showLevel : USINT;
		isCustomerEnabled : BOOL;
		isOperatorEnabled : BOOL;
		isRemoteEnabled : BOOL;
		numberOfInverters : USINT;
		isConnectionError : BOOL;
		isSimulation : BOOL;
		isRemoteReady : BOOL;
		isCondenseGraphs : BOOL; (*Fix for tematic and other that has more than one stat counter but one inlet.*)
		isPowerSave : BOOL;
		isStatisticsRunning : BOOL;
		isShowCARSearch : BOOL;
		Language : USINT;
		isAppReady : BOOL;
		nodeID : USINT;
		totalCounterSmall : UDINT;
		totalCounter : UDINT;
		operatingHours : UDINT;
		powerOnHours : UDINT;
		timelineIntervalInSec : UINT;
		isPLCHalted : BOOL;
	END_STRUCT;
	FileDevicesService_Type : 	STRUCT 
		Runtime : FileDevicesServiceRuntime_Type;
	END_STRUCT;
	FileDevicesServiceRuntime_Type : 	STRUCT 
		initState : initState_enum;
		usedDevicesFromCore : UINT;
	END_STRUCT;
	HardwareService_Type : 	STRUCT 
		Runtime : HardwareServiceRuntime_Type;
		Interface : HardwareServiceInterface_Type;
	END_STRUCT;
	HardwareServiceInterface_Type : 	STRUCT 
		isCmdLoad : BOOL;
		isCmdSave : BOOL;
		isCmdLoadFactorySettings : BOOL;
		isCmdSaveFactorySettings : BOOL;
		isCmdUpdate : BOOL;
		isCmdSearch : BOOL;
		isCmdSearchTxt : STRING[3];
		ptrConfig : UDINT;
		isCmdUpdatePar : BOOL;
		isCmdSearchVariable : STRING[50];
	END_STRUCT;
	HardwareServiceRuntime_Type : 	STRUCT 
		initState : initState_enum;
		ParIdent : UDINT;
		saveCounter : UINT;
		UpdateShowLevelEnable : BOOL;
	END_STRUCT;
	HMIService_Type : 	STRUCT 
		Runtime : HMIServiceRuntime_Type;
		Interface : HMIServiceInterface_Type;
	END_STRUCT;
	HMIServiceInterface_Type : 	STRUCT 
		Handler : ARRAY[0..9]OF HMIServiceInterfaceHandler_Type;
	END_STRUCT;
	HMIServiceInterfaceHandler_Type : 	STRUCT 
		isDisableScreenCalibration : BOOL;
	END_STRUCT;
	HMIServiceRuntime_Type : 	STRUCT 
		Handler : ARRAY[0..1]OF HMITaskInterface_Type;
		HandlersRunning : USINT;
		initState : initState_enum;
		hideSpinner : UINT;
		SpinnerIndex : USINT;
		defaultNotifyTime : UINT;
	END_STRUCT;
	IOAlarmService_Type : 	STRUCT 
		Runtime : IOAlarmServiceRuntime_Type;
		Interface : IOAlarmServiceInterface_Type;
	END_STRUCT;
	IOAlarmServiceInterface_Type : 	STRUCT 
		isHaltPlc : BOOL; (*isIgnoreX20Module : ARRAY[0..19] OF BOOL;*)
		isIgnoreX20Module : ARRAY[0..252]OF BOOL;
	END_STRUCT;
	IOAlarmServiceRuntime_Type : 	STRUCT 
		numberOfInverters : USINT;
		isPlcHaltRequest : BOOL;
		Module : ARRAY[0..252]OF IoAlarmCheckIoModule_Type;
		numberOfIOModules : UINT;
	END_STRUCT;
	IOTrace_Type : 	STRUCT 
		Runtime : IoTraceStruct_Type;
	END_STRUCT;
	M2MCHCon_Type : 	STRUCT 
		client : MachineInfo_Type;
		server : MachineInfo_Type;
		connectionManagerID : USINT;
		pServer : UDINT;
		pClient : UDINT;
		logicType : XMLComServiceType_Enum;
	END_STRUCT;
	M2MCHInterface_Type : 	STRUCT 
		connection : ARRAY[0..9]OF XMLRPCConnectionP_Type;
	END_STRUCT;
	M2MCHRuntime_Type : 	STRUCT 
		initState : initState_enum;
		serversRunning : USINT;
		connection : ARRAY[0..9]OF M2MCHCon_Type;
		maxConnections : USINT;
		statusString : STRING[80];
	END_STRUCT;
	MachineData_Type : 	STRUCT 
		MachineType : STRING[32] := 'Core Platform';
		MachineNumber : STRING[32] := 'XXXXXX';
		ProgramVersion : STRING[32] := 'Core V';
	END_STRUCT;
	MachineRuntime_Type : 	STRUCT 
		Blackbox : BlackboxRuntime_Type;
	END_STRUCT;
	MachineService_Type : 	STRUCT 
		Runtime : MachineServiceRuntime_Type;
		Interface : MachineServiceInterface_Type;
	END_STRUCT;
	MachineServiceInterface_Type : 	STRUCT 
		isCmdLoad : BOOL;
		isCmdSave : BOOL; (*SWEDISH?*)
		isCmdLoadFactorySettings : BOOL;
		isCmdSaveFactorySettings : BOOL;
		isCmdUpdate : BOOL;
		isCmdSearch : BOOL;
		isCmdSearchTxt : STRING[3];
		ptrConfig : UDINT;
		isCmdUpdatePar : BOOL;
		isCmdSearchVariable : STRING[50];
	END_STRUCT;
	MachineServiceRuntime_Type : 	STRUCT 
		initState : initState_enum;
		ParIdent : UDINT;
		saveCount : UDINT;
		UpdateShowLevelEnable : BOOL;
	END_STRUCT;
	MachineServices_Type : 	STRUCT 
		Blackbox : BlackboxService_Type;
		Alarmhandler : AlarmInterface_Type;
		HMIHandler : HMIService_Type;
		CAR : CARService_Type;
		Recipe : RecipeService_Type;
		Machine : MachineService_Type;
		Hardware : HardwareService_Type;
		AutoProg : AutoProgService_Type;
		Operator : OperatorService_Type;
		System : SystemService_Type;
		Statistics : StatisticsService_Type;
		PanConfig : PanConfigService_Type;
		IO : IOAlarmService_Type;
		AcoposAlarm : AcoposAlarmService_Type;
		Communication : XMLRPCService_Type;
		FileDevices : FileDevicesService_Type;
		Time : TimeService_Type;
		IOTrace : IOTrace_Type;
		Backup : BackupService_Type;
		Remote : RemoteService_Type;
		pAppManager : UDINT;
		Audio : AudioServices_Type;
		New_Member : CategorySelection_Type;
	END_STRUCT;
	MachineSetup_Type : 	STRUCT 
		PECID : USINT;
		Blackbox : BlackboxSetup_Type;
		AlarmHandler : AlarmInterface_Type;
	END_STRUCT;
	MCfg_Core_Type : 	STRUCT 
		EnableCustArt : BOOL;
		LogOperator : BOOL;
		TimelineIntervalInSec : UINT;
		RemotePanel : UINT;
	END_STRUCT;
	OperatorService_Type : 	STRUCT 
		Runtime : OperatorServiceRuntime_Type;
		Interface : OperatorServiceInterface_Type;
	END_STRUCT;
	OperatorInterface_Type : 	STRUCT 
		ID : UDINT;
		isLoad : BOOL;
	END_STRUCT;
	OperatorServiceInterface_Type : 	STRUCT 
		operator : ARRAY[0..9]OF OperatorInterface_Type;
	END_STRUCT;
	OperatorServiceRuntime_Type : 	STRUCT 
		HMIShow : UINT;
		initState : initState_enum;
		No : ARRAY[0..9]OF OperatorServiceRuntimeNo_Type;
		isEnabled : BOOL;
	END_STRUCT;
	OperatorServiceRuntimeNo_Type : 	STRUCT 
		Number : UDINT;
		Name : STRING[80];
		Performance : UINT;
	END_STRUCT;
	PanConfigService_Type : 	STRUCT 
		Interface : PanConfigServiceInterface_Type;
	END_STRUCT;
	PanConfigServiceInterface_Type : 	STRUCT 
		productionEvent : ARRAY[0..9]OF BOOL;
		machineInfoState : UINT;
	END_STRUCT;
	pecID_enum : 
		(
		JEDK,
		JESW,
		JECH,
		JEPR
		);
	recipeExternalCmdKey : 
		(
		RECIPE_KEY_IDLE := 0,
		RECIPE_KEY_LOAD_1 := 1,
		RECIPE_KEY_LOAD_2 := 2,
		RECIPE_KEY_SAVE_1 := 11,
		RECIPE_KEY_SAVE_2 := 12,
		RECIPE_KEY_LOAD_FACTORY := 9,
		RECIPE_KEY_SAVE_FACTORY
		);
	RecipeService_Type : 	STRUCT 
		Runtime : RecipeServiceRuntime_Type;
		Interface : RecipeServiceInterface_Type;
	END_STRUCT;
	RecipeServiceInterface_Type : 	STRUCT 
		externalCmdKey : recipeExternalCmdKey; (*Has to be removed in the future!*)
		isCmdLoad : BOOL;
		isCmdSave : BOOL;
		isCmdLoadFactorySettings : BOOL;
		isCmdSaveFactorySettings : BOOL;
		isCmdSearch : BOOL; (*Search command in Rcp list (Par names)*)
		isCmdSearchTxt : STRING[3]; (*Search text in Rcp list (Par names)*)
		cmdReadRecipeNames : BOOL;
		AutoRecipe : USINT;
		isAutoRecipe : BOOL;
		OrgRecipe : USINT;
		isCmdUpdatePar : BOOL;
		isCmdSearchVariable : STRING[50];
	END_STRUCT;
	RecipeServiceRuntime_Type : 	STRUCT 
		HMIShow : UINT;
		initState : initState_enum;
		selectedRcpNo : USINT;
		recipePointer : UDINT;
		ParIdent : UDINT;
		saveCount : UDINT;
		loadCount : UDINT;
		Select : CatSelectionLayer_Type;
		CategoryList : CategorySelection_Type;
		UpdateShowLevelEnable : BOOL;
	END_STRUCT;
	AutoProgService_Type : 	STRUCT 
		Runtime : AutoProgServiceRuntime_Type;
		Interface : AutoProgServiceInterface_Type;
	END_STRUCT;
	AutoProgServiceInterface_Type : 	STRUCT 
		externalCmdKey : recipeExternalCmdKey; (*Has to be removed in the future!*)
		isCmdLoad : BOOL;
		isCmdSave : BOOL;
		isCmdLoadFactorySettings : BOOL;
		isCmdSaveFactorySettings : BOOL;
		isCmdSearch : BOOL; (*Search command in Rcp list (Par names)*)
		isCmdSearchTxt : STRING[3]; (*Search text in Rcp list (Par names)*)
		AutoRecipe : USINT;
		isAutoRecipe : BOOL;
		OrgRecipe : USINT;
		isCmdUpdatePar : BOOL;
	END_STRUCT;
	AutoProgServiceRuntime_Type : 	STRUCT 
		HMIShow : UINT;
		initState : initState_enum;
		selectedRcpNo : USINT;
		autoprogPointer : UDINT;
		ParIdent : UDINT;
		saveCount : UDINT;
		loadCount : UDINT;
		UpdateShowLevelEnable : BOOL;
	END_STRUCT;
	RemoteServiceInterface_Type : 	STRUCT 
		remoteNode : ARRAY[0..9]OF remoteNodeRuntime_Type;
	END_STRUCT;
	RemoteService_Type : 	STRUCT 
		Interface : RemoteServiceInterface_Type;
		Runtime : RemoteServiceRuntime_type;
	END_STRUCT;
	remoteNodeRuntime_Type : 	STRUCT 
		CustomerNumber : UDINT;
		ArticleNumber : UDINT;
		RecipeNumber : USINT;
		isUpdate : BOOL;
		keyPress : USINT;
		utKey1 : ARRAY[0..19]OF UINT;
		utKey2 : ARRAY[0..19]OF UINT;
		utKey3 : ARRAY[0..19]OF UINT;
		utKey4 : ARRAY[0..19]OF UINT;
		utKey5 : ARRAY[0..19]OF UINT;
	END_STRUCT;
	RemoteServiceRuntime_type : 	STRUCT  (*Service Runtime / Interface for remote server & client*)
		initState : initState_enum;
		newConnectionID : USINT;
		connectionManagerID : ARRAY[0..9]OF USINT;
		pServerControl : ARRAY[0..9]OF UDINT;
		pClientControl : ARRAY[0..9]OF UDINT;
		remoteID : USINT;
		remoteNode : ARRAY[0..9]OF remoteNodeRuntime_Type;
	END_STRUCT;
	serviceType_enum : 
		(
		SYSTEM_SERVICE,
		RECIPE_SERVICE,
		MACHINE_SERVICE,
		HARDWARE_SERVICE,
		CUSTOMER_SERVICE,
		OPERATOR_SERVICE,
		FILEDEVICES_SERVICE
		);
	StatisticsService_Type : 	STRUCT 
		Runtime : StatisticsServiceRuntime_Type;
		Interface : StatisticsServiceInterface_Type;
	END_STRUCT;
	StatisticsServiceInterface_Type : 	STRUCT 
		configuration : StatConfig_Type;
		StatShowShift : BOOL;
		DeleteStatsAfterNoDays : UINT;
		isDeleteOldFiles : BOOL;
	END_STRUCT;
	StatisticsServiceRuntime_Type : 	STRUCT 
		initState : initState_enum;
	END_STRUCT;
	SystemService_Type : 	STRUCT 
		Runtime : SystemServiceRuntime_Type;
		Interface : SystemServiceInterface_Type;
	END_STRUCT;
	SystemServiceInterface_Type : 	STRUCT 
		isCmdSave : BOOL;
		isHmiCmdSave : BOOL;
	END_STRUCT;
	SystemServiceRuntime_Type : 	STRUCT 
		initState : initState_enum;
		isSystemFileValid : BOOL;
		saveCount : UDINT;
		file : SystemFile_Type;
	END_STRUCT;
	TimeService_Type : 	STRUCT 
		Runtime : TimeServiceRuntime_Type;
	END_STRUCT;
	TimeServiceRuntime_Type : 	STRUCT 
		Date_Time : DATE_AND_TIME;
		Split : DTStructure;
		MilliSeconds : UDINT;
		Seconds : UDINT;
		ISO : STRING[30];
	END_STRUCT;
	M2MLogic_Type : 	STRUCT 
		Interface : USINT;
		Runtime : USINT;
	END_STRUCT;
	ArcNetLogicRuntimeCon_Type : 	STRUCT 
		pArcNet : UDINT;
	END_STRUCT;
	ArcNetLogicRuntime_Type : 	STRUCT 
		connectionsRunning : USINT;
		connection : ARRAY[0..9]OF ArcNetLogicRuntimeCon_Type;
	END_STRUCT;
	ArcNetLogic_Type : 	STRUCT 
		Interface : USINT;
		Runtime : ArcNetLogicRuntime_Type;
	END_STRUCT;
	XMLApp_Type : 	STRUCT 
		Interconnect : XMLInterconnect_Type;
		CockpitRT : CockpitRT_type;
		M2M : M2MLogic_Type;
		ArcNet : ArcNetLogic_Type;
		Cockpit : UDINT;
	END_STRUCT;
	XMLComServiceRuntimeClient_Type : 	STRUCT 
		com : XML_Com_Type;
		pData : UDINT;
		size : UDINT;
	END_STRUCT;
	XMLComServiceRuntimeCon_Type : 	STRUCT 
		client : XMLComServiceRuntimeClient_Type;
		server : XMLComServiceRuntimeServer_Type;
		roleType : ComCMCT_Enum;
		logicType : XMLComServiceType_Enum;
		connectionManagerID : USINT;
		pServer : UDINT;
		pClient : UDINT;
		isLoopBack : BOOL;
	END_STRUCT;
	XMLComServiceRuntimeServer_Type : 	STRUCT 
		com : XML_Com_Type;
		pData : UDINT;
		size : UDINT;
	END_STRUCT;
	XMLInterconnect_Type : 	STRUCT 
		Runtime : XMLInterconnectRuntime_Type;
		Interface : BOOL;
	END_STRUCT;
	XMLInterconnectClient_Type : 	STRUCT 
		ident : UDINT;
		connectionManagerID : USINT;
	END_STRUCT;
	XMLInterconnectRuntime_Type : 	STRUCT 
		initState : initState_enum;
		serversRunning : USINT;
		clientsRunning : USINT;
		clients : ARRAY[0..99]OF XMLInterconnectClient_Type;
		servers : ARRAY[0..99]OF XMLInterconnectServer_Type;
		clientLogicIdents : ARRAY[0..9]OF UDINT;
		serverLogicIdents : ARRAY[0..9]OF UDINT;
	END_STRUCT;
	XMLInterconnectServer_Type : 	STRUCT 
		ident : UDINT;
		connectionManagerID : USINT;
	END_STRUCT;
	XMLRPCConnectionP_Type : 	STRUCT 
		pClient : UDINT;
		pServer : UDINT;
	END_STRUCT;
	SerialComHandler_Type : 	STRUCT 
		Interface : USINT;
		Runtime : SerialComHandlerRuntime_Type;
	END_STRUCT;
	XMLRPCFold_Type : 	STRUCT 
		Interface : XMLRPCFoldInterface_Type;
		Runtime : XMLRPCFoldRuntime_Type;
	END_STRUCT;
	SerialComHandlerConnection_type : 	STRUCT 
		connectionManagerID : USINT;
		pSerialCom : UDINT;
		logicType : XMLComServiceType_Enum;
	END_STRUCT;
	XMLRPCFoldConnection_type : 	STRUCT 
		data : JenXMLCommInfo_Type;
		connectionManagerID : USINT;
		pServer : UDINT;
		pClient : UDINT;
	END_STRUCT;
	XMLRPCFoldInterface_Type : 	STRUCT 
		connection : ARRAY[0..9]OF XMLRPCConnectionP_Type;
	END_STRUCT;
	XMLRPCFoldRuntime_Type : 	STRUCT 
		initState : initState_enum;
		serversRunning : USINT;
		connection : ARRAY[0..9]OF XMLRPCFoldConnection_type;
		maxConnections : USINT;
		statusString : STRING[80];
	END_STRUCT;
	SerialComHandlerRuntime_Type : 	STRUCT 
		initState : initState_enum;
		serversRunning : USINT;
		connection : ARRAY[0..9]OF SerialComHandlerConnection_type;
		maxConnections : USINT;
		statusString : STRING[80];
	END_STRUCT;
	XMLRPCInterCom_Type : 	STRUCT 
		ConnectionHandler : XMLRPCInterComCH_Type;
	END_STRUCT;
	XMLRPCInterComCH_Type : 	STRUCT 
		Interface : BOOL;
		Runtime : XMLRPCInterComCHRT_Type; (*Run*)
	END_STRUCT;
	XMLRPCInterComCHIF_Type : 	STRUCT 
		connection : ARRAY[0..9]OF XMLRPCConnectionP_Type;
	END_STRUCT;
	XMLRPCInterComCHRT_Type : 	STRUCT 
		initState : initState_enum;
		connection : ARRAY[0..99]OF XMLComServiceRuntimeCon_Type;
		serversRunning : USINT;
		maxConnections : USINT;
		statusString : STRING[80];
	END_STRUCT;
	XMLRPCLogic_Type : 	STRUCT 
		JenTrans : XMLRPCInterComCH_Type;
		FlatXML : XMLRPCM2MCH_Type;
		FoldXML : XMLRPCFold_Type;
		Serial : SerialComHandler_Type;
	END_STRUCT;
	XMLRPCM2M_Type : 	STRUCT 
		ConnectionHandler : XMLRPCM2MCH_Type;
	END_STRUCT;
	XMLRPCM2MCH_Type : 	STRUCT 
		Runtime : M2MCHRuntime_Type;
		Interface : M2MCHInterface_Type;
	END_STRUCT;
	XMLRPCServer_Type : 	STRUCT 
		Runtime : XMLRPCServerRuntime_Type;
	END_STRUCT;
	XMLRPCServerRuntime_Type : 	STRUCT 
		isServerStarted : BOOL;
		isConnectionError : BOOL;
		serverStatus : DINT;
		initState : initState_enum;
		statusString : STRING[80];
		port : UINT;
	END_STRUCT;
	XMLRPCService_Type : 	STRUCT 
		XMLRPCServer : XMLRPCServer_Type;
		ConnectionManager : XMLRPCCL_Type;
		ConnectionHandler : XMLRPCLogic_Type;
		ConnectionLogic : XMLApp_Type;
	END_STRUCT;
	AudioServices_Type : 	STRUCT 
		Piezo : AudioServices_Piezo_Type;
	END_STRUCT;
	AudioServices_Piezo_Type : 	STRUCT 
		Interface : Piezo_Interface_Type;
		Runtime : Piezo_Runtime_Type;
	END_STRUCT;
	Piezo_Interface_Type : 	STRUCT 
		Run : BOOL;
		ToneNumber : USINT;
		RunForCylics : USINT;
	END_STRUCT;
	Piezo_Runtime_Type : 	STRUCT 
		Running : BOOL;
		ToneNumber : USINT;
		CylicsDone : UDINT;
		initState : initState_enum;
	END_STRUCT;
END_TYPE
