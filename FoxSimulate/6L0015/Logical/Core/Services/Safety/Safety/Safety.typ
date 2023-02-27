
TYPE
	application_typ : 	STRUCT 
		reset_SDP : UINT;
		acknowledge_SDP : UINT;
	END_STRUCT;
	autoLoad_typ : 	STRUCT 
		state : USINT;
		infoText : STRING[100];
		init : BOOL;
		cmdRead : BOOL;
		cmdLoad : BOOL;
		cmdReset : BOOL;
		cmdReadStatus : USINT;
		cmdLoadStatus : USINT;
		cmdResetStatus : USINT;
		filename : STRING[80]; (*filename of the safety application*)
		progressBar : USINT;
		progressBarHide : USINT;
		statLedColor : USINT;
	END_STRUCT;
	data_typ : 	STRUCT 
		exit : BOOL;
		reset_SDP : UINT;
		acknowledge_SDP : UINT;
		read : BOOL;
		change : BOOL;
		machineOptionsRead_SDP : UINT;
		machineOptionsChange_SDP : UINT;
	END_STRUCT;
	hmi_typ : 	STRUCT 
		safeKEYnewPassword : STRING[16];
		safeKEYpassword : STRING[16];
		remoteControl : remote_control_typ;
		application : application_typ;
		data : data_typ;
	END_STRUCT;
	remote_control_typ : 	STRUCT 
		reset_SDP : UINT;
		moduleExchange1_SDP : UINT := 0;
		moduleExchange2_SDP : UINT := 0;
		moduleExchange3_SDP : UINT := 0;
		moduleExchange4_SDP : UINT := 0;
		moduleExchangeN_SDP : UINT := 0;
		monitorStatus_SDP : UINT := 0;
		readStatus_SDP : UINT := 0;
		firmwareAcknowledge_SDP : UINT := 0;
		safeKeyExchange_SDP : UINT := 0;
		clearData_SDP : UINT := 0;
		resetSafeLogic_SDP : UINT := 0;
		safeKeyFormat_SDP : UINT := 0;
		setPassword_SDP : UINT := 0;
	END_STRUCT;
END_TYPE
