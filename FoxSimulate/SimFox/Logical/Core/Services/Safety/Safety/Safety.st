PROGRAM _INIT	
	hmi.data.machineOptionsChange_SDP.0		:= TRUE;
	hmi.data.machineOptionsRead_SDP.0 		:= TRUE;

	delayCyclic := TRUE;	
END_PROGRAM

PROGRAM _CYCLIC
	
IF NOT g_HCfg.BRSafety	THEN
	IF delayCyclic THEN
		delayCyclic	:= FALSE;
		UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, 9, 5, 0, 0, 0);	// Hide safety page		
	END_IF	
RETURN;		
END_IF	
	TON_delayCyclic(IN:= delayCyclic, PT := T#20s);

	IF NOT g_Core.System.Runtime.isInitDone OR NOT TON_delayCyclic.Q THEN
		RETURN;
	END_IF
	
	brdk_safety_remote_control_0.enable						:= TRUE;
	brdk_safety_remote_control_0.setup.safeLogicID 			:= 1;
	brdk_safety_remote_control_0.setup.safeKEYpassword 		:= hmi.safeKEYpassword;
	brdk_safety_remote_control_0.setup.safeKEYnewPassword 	:= hmi.safeKEYnewPassword;
	brdk_safety_remote_control_0();
		
	brdk_safety_application_0.enable						:= TRUE;
	brdk_safety_application_0.setup.safeLogicID 			:= 1;
	brdk_safety_application_0.setup.safeKEYpassword 		:= hmi.safeKEYpassword;
	brdk_safety_application_0.setup.SLXused					:= TRUE;
	brdk_safety_application_0.setup.SLXstation 				:= 'IF6.ST1';
	brdk_safety_application_0.setup.devicename				:= 'SAFETY';
	brdk_safety_application_0.setup.filename	 			:= g_Core.System.Configuration.SafetyFileName; 	//'assl1.bin'  PATH: "Physical\<CONFIGURATION_NAME>\X20CP0484\Safety\DLFiles\assl1.bin" 
																											// REMARK: This file should be copied from laptop TO Safety folder on CF card in order TO load Safety from PLC
	brdk_safety_application_0.setup.downloadFromFile		:= TRUE;
	brdk_safety_application_0();
		
	brdk_safety_data_0.enable								:= TRUE;
	brdk_safety_data_0.setup.safeLogicID 					:= 1;
	brdk_safety_data_0.setup.safeKEYpassword 				:= hmi.safeKEYpassword;
	brdk_safety_data_0.setup.SLXused						:= TRUE;
	brdk_safety_data_0.setup.SLXstation 					:= 'IF6.ST1';
	brdk_safety_data_0.setup.machineOptions					:= BRDKSAFETY_SET_OPTIONS_ONLY;
	brdk_safety_data_0.par.type		 						:= BRDKSAFETY_TYPE_OPTIONS;
	brdk_safety_data_0();
		
	// Remote Control:
	hmi.remoteControl.reset_SDP.0 := NOT brdk_safety_remote_control_0.error;
		
	IF brdk_safety_remote_control_0.error OR brdk_safety_remote_control_0.cmd.clearData OR brdk_safety_remote_control_0.cmd.firmwareAcknowledge OR brdk_safety_remote_control_0.cmd.moduleExchange1 OR
		brdk_safety_remote_control_0.cmd.moduleExchange2 OR brdk_safety_remote_control_0.cmd.moduleExchange3 OR brdk_safety_remote_control_0.cmd.moduleExchange4 OR brdk_safety_remote_control_0.cmd.moduleExchangeN OR
		brdk_safety_remote_control_0.cmd.readStatus OR brdk_safety_remote_control_0.cmd.resetSafeLogic OR brdk_safety_remote_control_0.cmd.safeKeyExchange OR brdk_safety_remote_control_0.cmd.safeKeyFormat OR
		brdk_safety_remote_control_0.cmd.scan OR brdk_safety_remote_control_0.cmd.setPassword OR brdk_safety_remote_control_0.cmd.setupModeDisable OR brdk_safety_remote_control_0.cmd.setupModeEnable OR brdk_safety_remote_control_0.cmd.test THEN
		hmi.remoteControl.clearData_SDP.1			:= TRUE;
		hmi.remoteControl.firmwareAcknowledge_SDP.1	:= TRUE;
		hmi.remoteControl.moduleExchange1_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange2_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchange3_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange4_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchangeN_SDP.1	 	:= TRUE;
		hmi.remoteControl.monitorStatus_SDP.1	 	:= TRUE;
		hmi.remoteControl.readStatus_SDP.1			:= TRUE;
		hmi.remoteControl.resetSafeLogic_SDP.1 		:= TRUE;
		hmi.remoteControl.safeKeyExchange_SDP.1 	:= TRUE;
		hmi.remoteControl.safeKeyFormat_SDP.1	 	:= TRUE;
		hmi.remoteControl.setPassword_SDP.1	 		:= TRUE;
			
	ELSIF NOT brdk_safety_remote_control_0.status.firstRead THEN
		hmi.remoteControl.clearData_SDP.1			:= TRUE;
		hmi.remoteControl.firmwareAcknowledge_SDP.1	:= TRUE;
		hmi.remoteControl.moduleExchange1_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange2_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchange3_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange4_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchangeN_SDP.1	 	:= TRUE;
		hmi.remoteControl.monitorStatus_SDP.1	 	:= FALSE;
		hmi.remoteControl.readStatus_SDP.1			:= FALSE;
		hmi.remoteControl.resetSafeLogic_SDP.1 		:= TRUE;
		hmi.remoteControl.safeKeyExchange_SDP.1 	:= TRUE;
		hmi.remoteControl.safeKeyFormat_SDP.1	 	:= TRUE;
		hmi.remoteControl.setPassword_SDP.1	 		:= FALSE;
			
	ELSIF brdk_safety_remote_control_0.cmd.monitorStatus THEN
		hmi.remoteControl.monitorStatus_SDP.1 		:= FALSE;
		hmi.remoteControl.clearData_SDP.1			:= TRUE;
		hmi.remoteControl.firmwareAcknowledge_SDP.1	:= TRUE;
		hmi.remoteControl.moduleExchange1_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange2_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchange3_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange4_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchangeN_SDP.1	 	:= TRUE;
		hmi.remoteControl.readStatus_SDP.1	 		:= TRUE;
		hmi.remoteControl.resetSafeLogic_SDP.1 		:= TRUE;
		hmi.remoteControl.safeKeyExchange_SDP.1 	:= TRUE;
		hmi.remoteControl.safeKeyFormat_SDP.1 		:= TRUE;
		hmi.remoteControl.setPassword_SDP.1	 		:= TRUE;
			
	ELSIF brdk_safety_remote_control_0.status.cmdRequest.setPassword THEN
		hmi.remoteControl.clearData_SDP.1			:= TRUE;
		hmi.remoteControl.firmwareAcknowledge_SDP.1	:= TRUE;
		hmi.remoteControl.moduleExchange1_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange2_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchange3_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange4_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchangeN_SDP.1	 	:= TRUE;
		hmi.remoteControl.monitorStatus_SDP.1	 	:= FALSE;
		hmi.remoteControl.readStatus_SDP.1			:= FALSE;
		hmi.remoteControl.resetSafeLogic_SDP.1 		:= TRUE;
		hmi.remoteControl.safeKeyExchange_SDP.1 	:= TRUE;
		hmi.remoteControl.safeKeyFormat_SDP.1	 	:= TRUE;
		hmi.remoteControl.setPassword_SDP.1	 		:= FALSE;
			
	ELSIF brdk_safety_remote_control_0.status.cmdRequest.firmwareAcknowledge THEN
		hmi.remoteControl.clearData_SDP.1			:= FALSE;
		hmi.remoteControl.firmwareAcknowledge_SDP.1	:= FALSE;
		hmi.remoteControl.moduleExchange1_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange2_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchange3_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange4_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchangeN_SDP.1	 	:= TRUE;
		hmi.remoteControl.monitorStatus_SDP.1	 	:= FALSE;
		hmi.remoteControl.readStatus_SDP.1			:= FALSE;
		hmi.remoteControl.resetSafeLogic_SDP.1 		:= FALSE;
		hmi.remoteControl.safeKeyExchange_SDP.1 	:= TRUE;
		hmi.remoteControl.safeKeyFormat_SDP.1	 	:= FALSE;
		hmi.remoteControl.setPassword_SDP.1	 		:= FALSE;
			
	ELSIF brdk_safety_remote_control_0.status.cmdRequest.moduleExchange1 THEN
		hmi.remoteControl.clearData_SDP.1			:= FALSE;
		hmi.remoteControl.firmwareAcknowledge_SDP.1	:= TRUE;
		hmi.remoteControl.moduleExchange1_SDP.1	 	:= FALSE;
		hmi.remoteControl.moduleExchange2_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchange3_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange4_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchangeN_SDP.1	 	:= TRUE;
		hmi.remoteControl.monitorStatus_SDP.1	 	:= FALSE;
		hmi.remoteControl.readStatus_SDP.1			:= FALSE;
		hmi.remoteControl.resetSafeLogic_SDP.1 		:= FALSE;
		hmi.remoteControl.safeKeyExchange_SDP.1 	:= TRUE;
		hmi.remoteControl.safeKeyFormat_SDP.1	 	:= FALSE;
		hmi.remoteControl.setPassword_SDP.1	 		:= FALSE;
			
	ELSIF brdk_safety_remote_control_0.status.cmdRequest.moduleExchange2 THEN
		hmi.remoteControl.clearData_SDP.1			:= FALSE;
		hmi.remoteControl.firmwareAcknowledge_SDP.1	:= TRUE;
		hmi.remoteControl.moduleExchange1_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange2_SDP.1 	:= FALSE;
		hmi.remoteControl.moduleExchange3_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange4_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchangeN_SDP.1	 	:= TRUE;
		hmi.remoteControl.monitorStatus_SDP.1	 	:= FALSE;
		hmi.remoteControl.readStatus_SDP.1			:= FALSE;
		hmi.remoteControl.resetSafeLogic_SDP.1 		:= FALSE;
		hmi.remoteControl.safeKeyExchange_SDP.1 	:= TRUE;
		hmi.remoteControl.safeKeyFormat_SDP.1	 	:= FALSE;
		hmi.remoteControl.setPassword_SDP.1	 		:= FALSE;
			
	ELSIF brdk_safety_remote_control_0.status.cmdRequest.moduleExchange3 THEN
		hmi.remoteControl.clearData_SDP.1			:= FALSE;
		hmi.remoteControl.firmwareAcknowledge_SDP.1	:= TRUE;
		hmi.remoteControl.moduleExchange1_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange2_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchange3_SDP.1	 	:= FALSE;
		hmi.remoteControl.moduleExchange4_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchangeN_SDP.1	 	:= TRUE;
		hmi.remoteControl.monitorStatus_SDP.1	 	:= FALSE;
		hmi.remoteControl.readStatus_SDP.1			:= FALSE;
		hmi.remoteControl.resetSafeLogic_SDP.1 		:= FALSE;
		hmi.remoteControl.safeKeyExchange_SDP.1 	:= TRUE;
		hmi.remoteControl.safeKeyFormat_SDP.1	 	:= FALSE;
		hmi.remoteControl.setPassword_SDP.1	 		:= FALSE;
			
	ELSIF brdk_safety_remote_control_0.status.cmdRequest.moduleExchange4 THEN
		hmi.remoteControl.clearData_SDP.1			:= FALSE;
		hmi.remoteControl.firmwareAcknowledge_SDP.1	:= TRUE;
		hmi.remoteControl.moduleExchange1_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange2_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchange3_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange4_SDP.1 	:= FALSE;
		hmi.remoteControl.moduleExchangeN_SDP.1	 	:= TRUE;
		hmi.remoteControl.monitorStatus_SDP.1	 	:= FALSE;
		hmi.remoteControl.readStatus_SDP.1			:= FALSE;
		hmi.remoteControl.resetSafeLogic_SDP.1 		:= FALSE;
		hmi.remoteControl.safeKeyExchange_SDP.1 	:= TRUE;
		hmi.remoteControl.safeKeyFormat_SDP.1	 	:= FALSE;
		hmi.remoteControl.setPassword_SDP.1	 		:= FALSE;
			
	ELSIF brdk_safety_remote_control_0.status.cmdRequest.moduleExchangeN THEN
		hmi.remoteControl.clearData_SDP.1			:= FALSE;
		hmi.remoteControl.firmwareAcknowledge_SDP.1	:= TRUE;
		hmi.remoteControl.moduleExchange1_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange2_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchange3_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange4_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchangeN_SDP.1	 	:= FALSE;
		hmi.remoteControl.monitorStatus_SDP.1	 	:= FALSE;
		hmi.remoteControl.readStatus_SDP.1			:= FALSE;
		hmi.remoteControl.resetSafeLogic_SDP.1 		:= FALSE;
		hmi.remoteControl.safeKeyExchange_SDP.1 	:= TRUE;
		hmi.remoteControl.safeKeyFormat_SDP.1	 	:= FALSE;
		hmi.remoteControl.setPassword_SDP.1	 		:= FALSE;
			
	ELSIF brdk_safety_remote_control_0.status.cmdRequest.safeKeyExchange THEN
		hmi.remoteControl.clearData_SDP.1			:= FALSE;
		hmi.remoteControl.firmwareAcknowledge_SDP.1	:= TRUE;
		hmi.remoteControl.moduleExchange1_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange2_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchange3_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange4_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchangeN_SDP.1	 	:= TRUE;
		hmi.remoteControl.monitorStatus_SDP.1	 	:= FALSE;
		hmi.remoteControl.readStatus_SDP.1			:= FALSE;
		hmi.remoteControl.resetSafeLogic_SDP.1 		:= FALSE;
		hmi.remoteControl.safeKeyExchange_SDP.1 	:= FALSE;
		hmi.remoteControl.safeKeyFormat_SDP.1	 	:= FALSE;
		hmi.remoteControl.setPassword_SDP.1	 		:= FALSE;
			
	ELSE
		hmi.remoteControl.clearData_SDP.1			:= FALSE;
		hmi.remoteControl.firmwareAcknowledge_SDP.1	:= TRUE;
		hmi.remoteControl.moduleExchange1_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange2_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchange3_SDP.1	 	:= TRUE;
		hmi.remoteControl.moduleExchange4_SDP.1 	:= TRUE;
		hmi.remoteControl.moduleExchangeN_SDP.1	 	:= TRUE;
		hmi.remoteControl.monitorStatus_SDP.1	 	:= FALSE;
		hmi.remoteControl.readStatus_SDP.1			:= FALSE;
		hmi.remoteControl.resetSafeLogic_SDP.1 		:= FALSE;
		hmi.remoteControl.safeKeyExchange_SDP.1 	:= TRUE;
		hmi.remoteControl.safeKeyFormat_SDP.1	 	:= FALSE;
		hmi.remoteControl.setPassword_SDP.1	 		:= FALSE;
			
	END_IF
			
	// Application:
	hmi.application.reset_SDP.0					:= NOT brdk_safety_application_0.error;
	hmi.application.acknowledge_SDP.0			:= NOT brdk_safety_application_0.waitForAcknowledge;
		
	// Data:
	hmi.data.reset_SDP.0 		:= NOT brdk_safety_data_0.error;
	hmi.data.acknowledge_SDP.0 	:= NOT brdk_safety_data_0.waitForAcknowledge;
		
	IF hmi.data.exit THEN
		hmi.data.exit	 						:= FALSE;
		hmi.data.machineOptionsChange_SDP.0 	:= TRUE;
		hmi.data.machineOptionsRead_SDP.0 		:= TRUE;
	ELSIF hmi.data.change THEN
		hmi.data.change	 						:= FALSE;
		hmi.data.machineOptionsChange_SDP.0 	:= FALSE;
		hmi.data.machineOptionsRead_SDP.0 		:= TRUE;
	ELSIF hmi.data.read THEN
		hmi.data.read	 						:= FALSE;
		hmi.data.machineOptionsRead_SDP.0 		:= FALSE;
		hmi.data.machineOptionsChange_SDP.0 	:= TRUE;
	END_IF


//-------------------------------------------------------------------------
// AUTOMATIC SAFETY LOAD
//-------------------------------------------------------------------------
IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = 703 THEN
	IF autoLoad.init THEN
		autoLoad.filename := brdk_safety_application_0.setup.filename;
	//	hmi.safeKEYnewPassword := hmi.safeKEYpassword := '123456';	
	END_IF
	autoLoad.init := FALSE;

	CASE autoLoad.state OF
		0:
		IF brdk_safety_remote_control_0.internal.state = BRDKSAFETY_ERROR THEN
			autoLoad.infoText := brdk_safety_remote_control_0.status.status;

			IF autoLoad.cmdReset THEN
				brdk_safety_remote_control_0.cmd.reset := TRUE;
			END_IF
		ELSIF brdk_safety_application_0.internal.state = BRDKSAFETY_ERROR THEN
			autoLoad.infoText := brdk_safety_application_0.status.status;
			IF autoLoad.cmdReset THEN
				brdk_safety_application_0.cmd.reset := TRUE;
			END_IF
		ELSIF autoLoad.cmdRead AND (hmi.safeKEYpassword <> '') THEN
			autoLoad.state := 1;
		ELSE
			autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		END_IF
		autoLoad.cmdRead := FALSE;
		autoLoad.cmdReset := FALSE;
	
		1:
		brdk_safety_remote_control_0.cmd.monitorStatus := TRUE;
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		autoLoad.state := 2;
	
		2:
		IF brdk_safety_remote_control_0.internal.state = BRDKSAFETY_CMD_MONITOR_STATUS THEN
			autoLoad.state := 3;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		
		3:
		IF brdk_safety_remote_control_0.internal.TON_MonitorStatus.Q THEN
			brdk_safety_remote_control_0.cmd.monitorStatus := FALSE;
			autoLoad.state := 4;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
	
		4: // Wait for commands
		IF brdk_safety_remote_control_0.status.cmdRequest.downloadApplication AND brdk_safety_remote_control_0.internal.state = BRDKSAFETY_IDLE THEN
			IF autoLoad.cmdLoad THEN
				autoLoad.state := 5;
			END_IF
		END_IF
		IF autoLoad.cmdRead AND (hmi.safeKEYpassword <> '') THEN
			autoLoad.state := 1;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		autoLoad.cmdLoad := FALSE;
		autoLoad.cmdRead := FALSE;
	
		5: 
		IF brdk_safety_remote_control_0.internal.state = BRDKSAFETY_IDLE THEN
			hmi.safeKEYnewPassword := hmi.safeKEYpassword;
			brdk_safety_remote_control_0.cmd.setPassword := TRUE;
			autoLoad.state := 6;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		
		6: 
		IF brdk_safety_remote_control_0.internal.state = BRDKSAFETY_CMD_SET_PASSWORD THEN
			autoLoad.state := 7;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		
		7: 
		IF brdk_safety_remote_control_0.internal.state = BRDKSAFETY_DONE THEN
			autoLoad.state := 8;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
	
		8:
		brdk_safety_remote_control_0.cmd.monitorStatus := TRUE; 
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		autoLoad.state := 9;
	
		9:
		IF brdk_safety_remote_control_0.internal.state = BRDKSAFETY_CMD_MONITOR_STATUS THEN
			autoLoad.state := 10;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		
		10:
		IF brdk_safety_remote_control_0.internal.TON_MonitorStatus.Q THEN
			brdk_safety_remote_control_0.cmd.monitorStatus := FALSE;
			autoLoad.state := 11;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;

		11:
		IF brdk_safety_remote_control_0.status.cmdRequest.downloadApplication THEN
			brdk_safety_application_0.cmd.download := TRUE;
			autoLoad.state := 12;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		
		12:
		IF brdk_safety_application_0.internal.state = BRDKSAFETY_CMD_DOWNLOAD_APP THEN
			autoLoad.state := 13;
		END_IF
		autoLoad.infoText := brdk_safety_application_0.status.status;
	
		13:
		IF brdk_safety_application_0.waitForAcknowledge = TRUE THEN
			brdk_safety_application_0.cmd.acknowledge := TRUE;
			brdk_safety_remote_control_0.cmd.monitorStatus := TRUE;
			autoLoad.state := 14;
		END_IF
		autoLoad.infoText := brdk_safety_application_0.status.status;
		
		14:
		IF brdk_safety_remote_control_0.internal.state = BRDKSAFETY_CMD_MONITOR_STATUS THEN
			autoLoad.state := 15;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		
		15:
		IF brdk_safety_remote_control_0.status.cmdRequest.safeKeyExchange THEN
			brdk_safety_remote_control_0.cmd.monitorStatus := FALSE;
			autoLoad.state := 16;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		
		16:
		IF brdk_safety_remote_control_0.internal.state = BRDKSAFETY_IDLE THEN
			brdk_safety_remote_control_0.cmd.safeKeyExchange := TRUE;
			autoLoad.state := 17;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		
		17:
		IF brdk_safety_remote_control_0.internal.state = BRDKSAFETY_CMD_SAFEKEY_EXCH THEN
			autoLoad.state := 18;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		
		18:
		IF brdk_safety_remote_control_0.internal.state = BRDKSAFETY_DONE THEN
			brdk_safety_remote_control_0.cmd.monitorStatus := TRUE;
			autoLoad.state := 19;
		END_IF 
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		
		19:
		IF brdk_safety_remote_control_0.status.cmdRequest.moduleExchange1 OR
			brdk_safety_remote_control_0.status.cmdRequest.moduleExchange2 OR
			brdk_safety_remote_control_0.status.cmdRequest.moduleExchange3 OR
			brdk_safety_remote_control_0.status.cmdRequest.moduleExchange4 OR
			brdk_safety_remote_control_0.status.cmdRequest.moduleExchangeN THEN
			
			brdk_safety_remote_control_0.cmd.monitorStatus := FALSE;
			autoLoad.state := 20;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		
		20:
		IF brdk_safety_remote_control_0.internal.state = BRDKSAFETY_IDLE THEN
			brdk_safety_remote_control_0.cmd.moduleExchange1 := brdk_safety_remote_control_0.status.cmdRequest.moduleExchange1;
			brdk_safety_remote_control_0.cmd.moduleExchange2 := brdk_safety_remote_control_0.status.cmdRequest.moduleExchange2;
			brdk_safety_remote_control_0.cmd.moduleExchange3 := brdk_safety_remote_control_0.status.cmdRequest.moduleExchange3;
			brdk_safety_remote_control_0.cmd.moduleExchange4 := brdk_safety_remote_control_0.status.cmdRequest.moduleExchange4;
			brdk_safety_remote_control_0.cmd.moduleExchangeN := brdk_safety_remote_control_0.status.cmdRequest.moduleExchangeN;
			autoLoad.state := 21;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
	
		21:
		IF brdk_safety_remote_control_0.internal.state = BRDKSAFETY_CMD_MODULE_EXCH_2 THEN
			autoLoad.state := 22;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		
		22:
		IF brdk_safety_remote_control_0.internal.state = BRDKSAFETY_DONE THEN
			brdk_safety_remote_control_0.cmd.monitorStatus := TRUE;
			autoLoad.state := 23;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		
		23:
		IF brdk_safety_remote_control_0.status.cmdRequest.firmwareAcknowledge THEN
			brdk_safety_remote_control_0.cmd.monitorStatus := FALSE;
			autoLoad.state := 24;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		
		24:
		IF brdk_safety_remote_control_0.internal.state = BRDKSAFETY_IDLE THEN
			brdk_safety_remote_control_0.cmd.firmwareAcknowledge := TRUE;
			autoLoad.state := 25;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		
		25:
		IF brdk_safety_remote_control_0.internal.state = BRDKSAFETY_CMD_FIRMWARE_ACK THEN
			autoLoad.state := 26;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		
		26:
		IF brdk_safety_remote_control_0.internal.state = BRDKSAFETY_DONE THEN
			brdk_safety_remote_control_0.cmd.monitorStatus := TRUE;
			autoLoad.state := 27;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
		
		27:
		IF brdk_safety_remote_control_0.internal.TON_MonitorStatus.Q AND brdk_safety_remote_control_0.status.operationMode = 'Operational' THEN
			hmi.safeKEYnewPassword := hmi.safeKEYpassword := '';
			brdk_safety_remote_control_0.cmd.monitorStatus := FALSE;

			Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, 20, 25); // Good
			autoLoad.state := 0;
		END_IF
		autoLoad.infoText := brdk_safety_remote_control_0.status.status;
	END_CASE
	
	// Error
	IF brdk_safety_remote_control_0.internal.state = BRDKSAFETY_ERROR OR brdk_safety_application_0.internal.state = BRDKSAFETY_ERROR THEN
		autoLoad.state := 0;
	END_IF
	
	// Show/Hide buttons
	IF hmi.safeKEYpassword = '' OR (autoLoad.state <> 4) OR NOT brdk_safety_remote_control_0.status.cmdRequest.downloadApplication OR brdk_safety_remote_control_0.internal.state = BRDKSAFETY_ERROR OR brdk_safety_application_0.internal.state = BRDKSAFETY_ERROR OR brdk_safety_remote_control_0.internal.state = BRDKSAFETY_CMD_MONITOR_STATUS THEN
		autoLoad.cmdLoadStatus := 2;
	ELSE
		autoLoad.cmdLoadStatus := 0;
	END_IF
	IF hmi.safeKEYpassword = '' OR brdk_safety_remote_control_0.internal.state = BRDKSAFETY_ERROR OR brdk_safety_application_0.internal.state = BRDKSAFETY_ERROR OR brdk_safety_remote_control_0.internal.state = BRDKSAFETY_CMD_MONITOR_STATUS OR ((autoLoad.state <> 0) AND (autoLoad.state <> 4)) THEN
		autoLoad.cmdReadStatus := 2;
	ELSE
		autoLoad.cmdReadStatus := 0;
	END_IF
	IF autoLoad.state = 0 AND brdk_safety_remote_control_0.internal.state = BRDKSAFETY_ERROR OR brdk_safety_application_0.internal.state = BRDKSAFETY_ERROR THEN
		autoLoad.cmdResetStatus := 0;
	ELSE
		autoLoad.cmdResetStatus := 2;
	END_IF
	
	// Info text
	IF (hmi.safeKEYpassword = '') THEN 
		autoLoad.infoText := 'Type password'; 
	END_IF

	// Status color
	IF brdk_safety_remote_control_0.status.operationMode = 'Needs to read status for 1st time' THEN
		autoLoad.statLedColor := 201; // Blue
	ELSIF brdk_safety_remote_control_0.status.operationMode = 'Operational' THEN
		autoLoad.statLedColor := 10; // Green
	ELSIF brdk_safety_remote_control_0.status.operationMode = 'Pre-operational' THEN
		autoLoad.statLedColor := 46; // Yellow
	ELSE
		autoLoad.statLedColor := 44; // Red
	END_IF

	// Progress bar
	autoLoad.progressBar := autoLoad.state;
	autoLoad.progressBarHide := autoLoad.state <= 4;
ELSE
	autoLoad.init := TRUE;
	autoLoad.state := 0;
END_IF
IF EDGENEG(g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = 703) THEN
	brdk_safety_remote_control_0.cmd.monitorStatus := FALSE;
END_IF

END_PROGRAM