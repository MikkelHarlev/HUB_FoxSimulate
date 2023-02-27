(* Function block for trigger remote safety controller actions such as acknowledging modules or reading the status. *)
FUNCTION_BLOCK brdk_safety_remote_control
	
	IF NOT enable THEN
		internal.state := BRDKSAFETY_DISABLED;
	END_IF
			
	CASE internal.state OF
		
		BRDKSAFETY_DISABLED:
			
			error := busy := done := status.firstRead := FALSE;
			status.lastErrorID 	:= 0;
			status.safeOSState 	:= status.modulesState := status.systemState := status.operationMode := '';
			brsmemset(ADR(internal), 0, SIZEOF(internal));
			brsmemset(ADR(cmd), 0, SIZEOF(cmd));
			brsmemset(ADR(status.cmdRequest), 0, SIZEOF(status.cmdRequest));
		
			IF DiagCpuIsSimulated() THEN
				status.status := 'Simulation is not supported';
			ELSIF enable THEN
				internal.state := BRDKSAFETY_IDLE;
			ELSE
				status.status := 'Function Block is disabled';
			END_IF
		
		BRDKSAFETY_IDLE:
				
			busy := done := error := internal.remoteControl.Execute := internal.TON_MonitorStatus.IN := FALSE;
				
			IF setup.safeLogicID <> 0 THEN
	
				status.status := 'Waiting for CMD';
				
				internal.remoteControl.SafeLOGICID 			:= setup.safeLogicID;
				internal.remoteControlCmdType.Password		:= setup.safeKEYpassword;
				internal.remoteControlCmdType.NewPassword	:= setup.safeKEYnewPassword;
				
				IF cmd.monitorStatus THEN
					internal.remoteControl.Execute 			:= TRUE; // call the FB 1st time before timer is set to run.
					internal.remoteControlCmdType.Command 	:= safeCMD_STATUS;
					internal.remoteControlCmdType.Data 		:= 0;
					internal.state := BRDKSAFETY_CMD_MONITOR_STATUS;
				ELSIF cmd.readStatus THEN
					internal.state := BRDKSAFETY_CMD_READ_STATUS;
				ELSIF cmd.firmwareAcknowledge THEN
					internal.state := BRDKSAFETY_CMD_FIRMWARE_ACK;
				ELSIF cmd.moduleExchange1 THEN
					internal.state := BRDKSAFETY_CMD_MODULE_EXCH_1;
				ELSIF cmd.moduleExchange2 THEN
					internal.state := BRDKSAFETY_CMD_MODULE_EXCH_2;
				ELSIF cmd.moduleExchange3 THEN
					internal.state := BRDKSAFETY_CMD_MODULE_EXCH_3;
				ELSIF cmd.moduleExchange4 THEN
					internal.state := BRDKSAFETY_CMD_MODULE_EXCH_4;
				ELSIF cmd.moduleExchangeN THEN
					internal.state := BRDKSAFETY_CMD_MODULE_EXCH_N;
				ELSIF cmd.safeKeyExchange THEN
					internal.state := BRDKSAFETY_CMD_SAFEKEY_EXCH;
				ELSIF cmd.safeKeyFormat THEN
					internal.state := BRDKSAFETY_CMD_SAFEKEY_FORMAT;
				ELSIF cmd.scan THEN
					internal.state := BRDKSAFETY_CMD_SCAN;
				ELSIF cmd.setPassword THEN
					internal.state := BRDKSAFETY_CMD_SET_PASSWORD;
				ELSIF cmd.test THEN
					internal.state := BRDKSAFETY_CMD_TEST;
				ELSIF cmd.clearData THEN
					internal.state := BRDKSAFETY_CMD_CLEAR_DATA;
				ELSIF cmd.resetSafeLogic THEN
					internal.state := BRDKSAFETY_CMD_RESET_SAFELOGIC;
				ELSIF cmd.setupModeEnable THEN
					internal.state := BRDKSAFETY_CMD_SETUP_ENABLE;
				ELSIF cmd.setupModeDisable THEN
					internal.state := BRDKSAFETY_CMD_SETUP_DISABLE;
				END_IF	
			ELSE
				status.status := 'Setup parameters not set correctly';				
			END_IF

		BRDKSAFETY_CMD_MONITOR_STATUS:
				
			status.status := 'Busy Monitoring status';
				
			busy := TRUE;
			done := error := cmd.clearData := cmd.firmwareAcknowledge := cmd.moduleExchange1 := cmd.moduleExchange2 := cmd.moduleExchange3 :=
			cmd.moduleExchange4 := cmd.moduleExchangeN := cmd.readStatus := cmd.reset := cmd.resetSafeLogic := cmd.safeKeyExchange :=
			cmd.safeKeyFormat := cmd.scan := cmd.setPassword := cmd.setupModeDisable := cmd.setupModeEnable := cmd.test := FALSE;
				
			IF cmd.monitorStatus THEN
						
				IF internal.TON_MonitorStatus.Q THEN
					internal.remoteControl.Execute 	:= TRUE;
					internal.TON_MonitorStatus.IN	:= FALSE;
				END_IF
						
				internal.remoteControlCmdType.Command 	:= safeCMD_STATUS;
				internal.remoteControlCmdType.Data 		:= 0;
						
				IF NOT internal.remoteControl.Busy THEN
					IF internal.remoteControl.Done THEN
						status.firstRead				:= TRUE;
						internal.remoteControl.Execute 	:= FALSE;
						internal.TON_MonitorStatus.IN 	:= TRUE;
						brsmemcpy(ADR(internal.remoteControlStatusType), ADR(internal.remoteControl.SafeLOGICStatus), SIZEOF(internal.remoteControl.SafeLOGICStatus));
					ELSIF internal.remoteControl.Error THEN
						internal.remoteControl.Execute 	:= FALSE;
						status.lastErrorID 				:= internal.remoteControl.StatusID;
						internal.state 					:= BRDKSAFETY_ERROR;
					END_IF
				END_IF
						
			ELSE
				internal.remoteControl.Execute 	:= FALSE;
				internal.TON_MonitorStatus.IN	:= FALSE;
				internal.state					:= BRDKSAFETY_IDLE;
			END_IF
				
		BRDKSAFETY_CMD_READ_STATUS:
				
			status.status := 'Busy Reading status';
				
			busy := TRUE;
			done := error := cmd.clearData := cmd.firmwareAcknowledge := cmd.moduleExchange1 := cmd.moduleExchange2 := cmd.moduleExchange3 :=
			cmd.moduleExchange4 := cmd.moduleExchangeN := cmd.monitorStatus := cmd.reset := cmd.resetSafeLogic := cmd.safeKeyExchange :=
			cmd.safeKeyFormat := cmd.scan := cmd.setPassword := cmd.setupModeDisable := cmd.setupModeEnable := cmd.test := FALSE;
				
			IF cmd.readStatus THEN
						
				internal.remoteControl.Execute 			:= TRUE;
				internal.remoteControlCmdType.Command 	:= safeCMD_STATUS;
				internal.remoteControlCmdType.Data 		:= 0;
						
				IF NOT internal.remoteControl.Busy THEN
					IF internal.remoteControl.Done THEN
						status.firstRead				:= TRUE;
						cmd.readStatus 					:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						brsmemcpy(ADR(internal.remoteControlStatusType), ADR(internal.remoteControl.SafeLOGICStatus), SIZEOF(internal.remoteControl.SafeLOGICStatus));
						internal.state 					:= BRDKSAFETY_DONE;
					ELSIF internal.remoteControl.Error THEN
						cmd.readStatus 					:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						status.lastErrorID 				:= internal.remoteControl.StatusID;
						internal.state 					:= BRDKSAFETY_ERROR;
					END_IF
				END_IF
						
			ELSE
				internal.remoteControl.Execute 	:= FALSE;
				internal.state					:= BRDKSAFETY_IDLE;
			END_IF
				
		BRDKSAFETY_CMD_FIRMWARE_ACK:
				
			status.status := 'Busy Acknowledge firmware';
				
			busy := TRUE;
			done := error := cmd.clearData := cmd.moduleExchange1 := cmd.moduleExchange2 := cmd.moduleExchange3 := cmd.moduleExchange4 :=
			cmd.moduleExchangeN := cmd.monitorStatus := cmd.readStatus := cmd.reset := cmd.resetSafeLogic := cmd.safeKeyExchange :=
			cmd.safeKeyFormat := cmd.scan := cmd.setPassword := cmd.setupModeDisable := cmd.setupModeEnable := cmd.test := FALSE;
			
			IF cmd.firmwareAcknowledge THEN
						
				internal.remoteControl.Execute 			:= TRUE;
				internal.remoteControlCmdType.Command 	:= safeCMD_ENTER;
				internal.remoteControlCmdType.Data 		:= safeCMD_FW_ACKN;
						
				IF NOT internal.remoteControl.Busy THEN
					IF internal.remoteControl.Done THEN
						cmd.firmwareAcknowledge			:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						brsmemcpy(ADR(internal.remoteControlStatusType), ADR(internal.remoteControl.SafeLOGICStatus), SIZEOF(internal.remoteControl.SafeLOGICStatus));
						internal.state 					:= BRDKSAFETY_DONE;
					ELSIF internal.remoteControl.Error THEN
						cmd.firmwareAcknowledge			:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						status.lastErrorID 				:= internal.remoteControl.StatusID;
						internal.state 					:= BRDKSAFETY_ERROR;
					END_IF
				END_IF
						
			ELSE
				internal.remoteControl.Execute 	:= FALSE;
				internal.state					:= BRDKSAFETY_IDLE;
			END_IF
				
		BRDKSAFETY_CMD_MODULE_EXCH_1:
				
			status.status := 'Busy Exchanging 1 module';
				
			busy := TRUE;
			done := error := cmd.clearData := cmd.firmwareAcknowledge := cmd.moduleExchange2 := cmd.moduleExchange3 := cmd.moduleExchange4 :=
			cmd.moduleExchangeN := cmd.monitorStatus := cmd.readStatus := cmd.reset := cmd.resetSafeLogic := cmd.safeKeyExchange := cmd.safeKeyFormat :=
			cmd.scan := cmd.setPassword := cmd.setupModeDisable := cmd.setupModeEnable := cmd.test := FALSE;
			
			IF cmd.moduleExchange1 THEN
						
				internal.remoteControl.Execute 			:= TRUE;
				internal.remoteControlCmdType.Command 	:= safeCMD_ENTER;
				internal.remoteControlCmdType.Data 		:= safeCMD_1_UDID_ACKN;
						
				IF NOT internal.remoteControl.Busy THEN
					IF internal.remoteControl.Done THEN
						cmd.moduleExchange1				:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						brsmemcpy(ADR(internal.remoteControlStatusType), ADR(internal.remoteControl.SafeLOGICStatus), SIZEOF(internal.remoteControl.SafeLOGICStatus));
						internal.remoteControlStatusType.NumberOfUDIDMismatches := 0; // TODO: a little fix since this variable doesn't get updated after the action is done.
						internal.state 					:= BRDKSAFETY_DONE;
					ELSIF internal.remoteControl.Error THEN
						cmd.moduleExchange1				:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						status.lastErrorID 				:= internal.remoteControl.StatusID;
						internal.state 					:= BRDKSAFETY_ERROR;
					END_IF
				END_IF
						
			ELSE
				internal.remoteControl.Execute 	:= FALSE;
				internal.state					:= BRDKSAFETY_IDLE;
			END_IF
				
		BRDKSAFETY_CMD_MODULE_EXCH_2:
				
			status.status := 'Busy Exchanging 2 modules';
				
			busy 	:= TRUE;
			done := error := cmd.clearData := cmd.firmwareAcknowledge := cmd.moduleExchange1 := cmd.moduleExchange3 := cmd.moduleExchange4 :=
			cmd.moduleExchangeN := cmd.monitorStatus := cmd.readStatus := cmd.reset := cmd.resetSafeLogic := cmd.safeKeyExchange :=
			cmd.safeKeyFormat := cmd.scan := cmd.setPassword := cmd.setupModeDisable := cmd.setupModeEnable := cmd.test := FALSE;
			
			IF cmd.moduleExchange2 THEN
						
				internal.remoteControl.Execute 			:= TRUE;
				internal.remoteControlCmdType.Command 	:= safeCMD_ENTER;
				internal.remoteControlCmdType.Data 		:= safeCMD_2_UDID_ACKN;
						
				IF NOT internal.remoteControl.Busy THEN
					IF internal.remoteControl.Done THEN
						cmd.moduleExchange2				:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						brsmemcpy(ADR(internal.remoteControlStatusType), ADR(internal.remoteControl.SafeLOGICStatus), SIZEOF(internal.remoteControl.SafeLOGICStatus));
						internal.remoteControlStatusType.NumberOfUDIDMismatches := 0; // TODO: a little fix since this variable doesn't get updated after the action is done.
						internal.state 					:= BRDKSAFETY_DONE;
					ELSIF internal.remoteControl.Error THEN
						cmd.moduleExchange2				:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						status.lastErrorID 				:= internal.remoteControl.StatusID;
						internal.state 					:= BRDKSAFETY_ERROR;
					END_IF
				END_IF
						
			ELSE
				internal.remoteControl.Execute 	:= FALSE;
				internal.state					:= BRDKSAFETY_IDLE;
			END_IF
				
		BRDKSAFETY_CMD_MODULE_EXCH_3:
				
			status.status := 'Busy Exchanging 3 modules';
				
			busy := TRUE;
			done := error := cmd.clearData := cmd.firmwareAcknowledge := cmd.moduleExchange1 := cmd.moduleExchange2 := cmd.moduleExchange4 :=
			cmd.moduleExchangeN := cmd.monitorStatus := cmd.readStatus := cmd.reset := cmd.resetSafeLogic := cmd.safeKeyExchange :=
			cmd.safeKeyFormat := cmd.scan := cmd.setPassword := cmd.setupModeDisable := cmd.setupModeEnable := cmd.test := FALSE;
			
			IF cmd.moduleExchange3 THEN
						
				internal.remoteControl.Execute 			:= TRUE;
				internal.remoteControlCmdType.Command 	:= safeCMD_ENTER;
				internal.remoteControlCmdType.Data 		:= safeCMD_3_UDID_ACKN;
						
				IF NOT internal.remoteControl.Busy THEN
					IF internal.remoteControl.Done THEN
						cmd.moduleExchange3				:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						brsmemcpy(ADR(internal.remoteControlStatusType), ADR(internal.remoteControl.SafeLOGICStatus), SIZEOF(internal.remoteControl.SafeLOGICStatus));
						internal.remoteControlStatusType.NumberOfUDIDMismatches := 0; // TODO: a little fix since this variable doesn't get updated after the action is done.
						internal.state 					:= BRDKSAFETY_DONE;
					ELSIF internal.remoteControl.Error THEN
						cmd.moduleExchange3				:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						status.lastErrorID 				:= internal.remoteControl.StatusID;
						internal.state 					:= BRDKSAFETY_ERROR;
					END_IF
				END_IF
						
			ELSE
				internal.remoteControl.Execute 	:= FALSE;
				internal.state					:= BRDKSAFETY_IDLE;
			END_IF
								
		BRDKSAFETY_CMD_MODULE_EXCH_4:
				
			status.status := 'Busy Exchanging 4 modules';
				
			busy := TRUE;
			done := error := cmd.clearData := cmd.firmwareAcknowledge := cmd.moduleExchange1 := cmd.moduleExchange2 := cmd.moduleExchange3 :=
			cmd.moduleExchangeN := cmd.monitorStatus := cmd.readStatus := cmd.reset := cmd.resetSafeLogic := cmd.safeKeyExchange :=
			cmd.safeKeyFormat := cmd.scan := cmd.setPassword := cmd.setupModeDisable := cmd.setupModeEnable := cmd.test := FALSE;
			
			IF cmd.moduleExchange4 THEN
						
				internal.remoteControl.Execute 			:= TRUE;
				internal.remoteControlCmdType.Command 	:= safeCMD_ENTER;
				internal.remoteControlCmdType.Data 		:= safeCMD_4_UDID_ACKN;
						
				IF NOT internal.remoteControl.Busy THEN
					IF internal.remoteControl.Done THEN
						cmd.moduleExchange4				:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						brsmemcpy(ADR(internal.remoteControlStatusType), ADR(internal.remoteControl.SafeLOGICStatus), SIZEOF(internal.remoteControl.SafeLOGICStatus));
						internal.remoteControlStatusType.NumberOfUDIDMismatches := 0; // TODO: a little fix since this variable doesn't get updated after the action is done.
						internal.state 					:= BRDKSAFETY_DONE;
					ELSIF internal.remoteControl.Error THEN
						cmd.moduleExchange4				:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						status.lastErrorID 				:= internal.remoteControl.StatusID;
						internal.state 					:= BRDKSAFETY_ERROR;
					END_IF
				END_IF
						
			ELSE
				internal.remoteControl.Execute 	:= FALSE;
				internal.state					:= BRDKSAFETY_IDLE;
			END_IF
								
		BRDKSAFETY_CMD_MODULE_EXCH_N:
				
			status.status := 'Busy Exchanging N modules';
				
			busy := TRUE;
			done := error := cmd.clearData := cmd.firmwareAcknowledge := cmd.moduleExchange1 := cmd.moduleExchange2 := cmd.moduleExchange3 :=
			cmd.moduleExchange4 := cmd.monitorStatus := cmd.readStatus := cmd.reset := cmd.resetSafeLogic := cmd.safeKeyExchange :=
			cmd.safeKeyFormat := cmd.scan := cmd.setPassword := cmd.setupModeDisable := cmd.setupModeEnable := cmd.test := FALSE;
			
			IF cmd.moduleExchangeN THEN
						
				internal.remoteControl.Execute 			:= TRUE;
				internal.remoteControlCmdType.Command 	:= safeCMD_ENTER;
				internal.remoteControlCmdType.Data 		:= safeCMD_N_UDID_ACKN;
						
				IF NOT internal.remoteControl.Busy THEN
					IF internal.remoteControl.Done THEN
						cmd.moduleExchangeN				:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						brsmemcpy(ADR(internal.remoteControlStatusType), ADR(internal.remoteControl.SafeLOGICStatus), SIZEOF(internal.remoteControl.SafeLOGICStatus));
						internal.remoteControlStatusType.NumberOfUDIDMismatches := 0; // TODO: a little fix since this variable doesn't get updated after the action is done.
						internal.state 					:= BRDKSAFETY_DONE;
					ELSIF internal.remoteControl.Error THEN
						cmd.moduleExchangeN				:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						status.lastErrorID 				:= internal.remoteControl.StatusID;
						internal.state 					:= BRDKSAFETY_ERROR;
					END_IF
				END_IF
						
			ELSE
				internal.remoteControl.Execute 	:= FALSE;
				internal.state					:= BRDKSAFETY_IDLE;
			END_IF
								
		BRDKSAFETY_CMD_SAFEKEY_EXCH:
				
			status.status := 'Busy Exchanging SafeKey';
				
			busy := TRUE;
			done := error := cmd.clearData := cmd.firmwareAcknowledge := cmd.moduleExchange1 := cmd.moduleExchange2 := cmd.moduleExchange3 :=
			cmd.moduleExchange4 := cmd.moduleExchangeN := cmd.monitorStatus := cmd.readStatus := cmd.reset := cmd.resetSafeLogic :=
			cmd.safeKeyFormat := cmd.scan := cmd.setPassword := cmd.setupModeDisable := cmd.setupModeEnable := cmd.test := FALSE;
			
			IF cmd.safeKeyExchange THEN
						
				internal.remoteControl.Execute 			:= TRUE;
				internal.remoteControlCmdType.Command 	:= safeCMD_ENTER;
				internal.remoteControlCmdType.Data 		:= safeCMD_SK_XCHG;
						
				IF NOT internal.remoteControl.Busy THEN
					IF internal.remoteControl.Done THEN
						cmd.safeKeyExchange				:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						brsmemcpy(ADR(internal.remoteControlStatusType), ADR(internal.remoteControl.SafeLOGICStatus), SIZEOF(internal.remoteControl.SafeLOGICStatus));
						internal.state 					:= BRDKSAFETY_DONE;
					ELSIF internal.remoteControl.Error THEN
						cmd.safeKeyExchange				:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						status.lastErrorID 				:= internal.remoteControl.StatusID;
						internal.state 					:= BRDKSAFETY_ERROR;
					END_IF
				END_IF
						
			ELSE
				internal.remoteControl.Execute 	:= FALSE;
				internal.state					:= BRDKSAFETY_IDLE;
			END_IF
								
		BRDKSAFETY_CMD_SAFEKEY_FORMAT:
				
			status.status := 'Busy Formatting SafeKey';
				
			busy := TRUE;
			done := error := cmd.clearData := cmd.firmwareAcknowledge := cmd.moduleExchange1 := cmd.moduleExchange2 := cmd.moduleExchange3 :=
			cmd.moduleExchange4 := cmd.moduleExchangeN := cmd.monitorStatus := cmd.readStatus := cmd.reset := cmd.resetSafeLogic :=
			cmd.safeKeyExchange := cmd.scan := cmd.setPassword := cmd.setupModeDisable := cmd.setupModeEnable := cmd.test := FALSE;
			
			IF cmd.safeKeyFormat THEN
						
				internal.remoteControl.Execute 			:= TRUE;
				internal.remoteControlCmdType.Command 	:= safeCMD_ENTER;
				internal.remoteControlCmdType.Data 		:= safeCMD_SK_FORMAT;
						
				IF NOT internal.remoteControl.Busy THEN
					IF internal.remoteControl.Done THEN
						cmd.safeKeyFormat				:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						internal.state 					:= BRDKSAFETY_DONE;
					ELSIF internal.remoteControl.Error AND internal.remoteControl.StatusID = safeERR_TIMEOUT THEN // TODO: this error occurs almost every time...
						cmd.safeKeyFormat				:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						status.lastErrorID 				:= internal.remoteControl.StatusID;
						internal.state 					:= BRDKSAFETY_DONE;
					ELSIF internal.remoteControl.Error THEN
						cmd.safeKeyFormat				:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						status.lastErrorID 				:= internal.remoteControl.StatusID;
						internal.state 					:= BRDKSAFETY_ERROR;
					END_IF
				END_IF
						
			ELSE
				internal.remoteControl.Execute 	:= FALSE;
				internal.state					:= BRDKSAFETY_IDLE;
			END_IF
				
		BRDKSAFETY_CMD_SCAN:
				
			status.status := 'Busy Scanning';
				
			busy := TRUE;
			done := error := cmd.clearData := cmd.firmwareAcknowledge := cmd.moduleExchange1 := cmd.moduleExchange2 := cmd.moduleExchange3 :=
			cmd.moduleExchange4 := cmd.moduleExchangeN := cmd.monitorStatus := cmd.readStatus := cmd.reset := cmd.resetSafeLogic :=
			cmd.safeKeyExchange := cmd.safeKeyFormat := cmd.setPassword := cmd.setupModeDisable := cmd.setupModeEnable := cmd.test := FALSE;
			
			IF cmd.scan THEN
						
				internal.remoteControl.Execute 			:= TRUE;
				internal.remoteControlCmdType.Command 	:= safeCMD_ENTER;
				internal.remoteControlCmdType.Data 		:= safeCMD_SCAN;
						
				IF NOT internal.remoteControl.Busy THEN
					IF internal.remoteControl.Done THEN
						cmd.scan						:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						brsmemcpy(ADR(internal.remoteControlStatusType), ADR(internal.remoteControl.SafeLOGICStatus), SIZEOF(internal.remoteControl.SafeLOGICStatus));
						internal.state 					:= BRDKSAFETY_DONE;
					ELSIF internal.remoteControl.Error THEN
						cmd.scan						:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						status.lastErrorID 				:= internal.remoteControl.StatusID;
						internal.state 					:= BRDKSAFETY_ERROR;
					END_IF
				END_IF
						
			ELSE
				internal.remoteControl.Execute 	:= FALSE;
				internal.state					:= BRDKSAFETY_IDLE;
			END_IF
				
		BRDKSAFETY_CMD_SET_PASSWORD:
				
			status.status := 'Busy Setting password';
				
			busy := TRUE;
			done := error := cmd.clearData := cmd.firmwareAcknowledge := cmd.moduleExchange1 := cmd.moduleExchange2 := cmd.moduleExchange3 :=
			cmd.moduleExchange4 := cmd.moduleExchangeN := cmd.monitorStatus := cmd.readStatus := cmd.reset := cmd.resetSafeLogic :=
			cmd.safeKeyExchange := cmd.safeKeyFormat := cmd.scan := cmd.setupModeDisable := cmd.setupModeEnable := cmd.test := FALSE;
			
			IF cmd.setPassword THEN
						
				internal.remoteControl.Execute 			:= TRUE;
				internal.remoteControlCmdType.Command 	:= safeCMD_ENTER;
				internal.remoteControlCmdType.Data 		:= safeCMD_SK_PW;
						
				IF NOT internal.remoteControl.Busy THEN
					IF internal.remoteControl.Done THEN
						cmd.setPassword					:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						brsmemcpy(ADR(internal.remoteControlStatusType), ADR(internal.remoteControl.SafeLOGICStatus), SIZEOF(internal.remoteControl.SafeLOGICStatus));
						internal.state 					:= BRDKSAFETY_DONE;
					ELSIF internal.remoteControl.Error THEN
						cmd.setPassword					:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						status.lastErrorID 				:= internal.remoteControl.StatusID;
						internal.state 					:= BRDKSAFETY_ERROR;
					END_IF
				END_IF
						
			ELSE
				internal.remoteControl.Execute 	:= FALSE;
				internal.state					:= BRDKSAFETY_IDLE;
			END_IF
				
		BRDKSAFETY_CMD_TEST:
				
			status.status := 'Busy Testing';
				
			busy := TRUE;
			done := error := cmd.clearData := cmd.firmwareAcknowledge := cmd.moduleExchange1 := cmd.moduleExchange2 := cmd.moduleExchange3 :=
			cmd.moduleExchange4 := cmd.moduleExchangeN := cmd.monitorStatus := cmd.readStatus := cmd.reset := cmd.resetSafeLogic :=
			cmd.safeKeyExchange := cmd.safeKeyFormat := cmd.scan := cmd.setPassword := cmd.setupModeDisable := cmd.setupModeEnable := FALSE;
			
			IF cmd.test THEN
						
				internal.remoteControl.Execute 			:= TRUE;
				internal.remoteControlCmdType.Command 	:= safeCMD_ENTER;
				internal.remoteControlCmdType.Data 		:= safeCMD_TEST;
						
				IF NOT internal.remoteControl.Busy THEN
					IF internal.remoteControl.Done THEN
						cmd.test						:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						brsmemcpy(ADR(internal.remoteControlStatusType), ADR(internal.remoteControl.SafeLOGICStatus), SIZEOF(internal.remoteControl.SafeLOGICStatus));
						internal.state 					:= BRDKSAFETY_DONE;
					ELSIF internal.remoteControl.Error THEN
						cmd.test						:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						status.lastErrorID 				:= internal.remoteControl.StatusID;
						internal.state 					:= BRDKSAFETY_ERROR;
					END_IF
				END_IF
						
			ELSE
				internal.remoteControl.Execute 	:= FALSE;
				internal.state					:= BRDKSAFETY_IDLE;
			END_IF
				
		BRDKSAFETY_CMD_CLEAR_DATA:
				
			status.status := 'Busy Clearing Data';
				
			busy := TRUE;
			done := error := cmd.firmwareAcknowledge := cmd.moduleExchange1 := cmd.moduleExchange2 := cmd.moduleExchange3 := cmd.moduleExchange4 :=
			cmd.moduleExchangeN := cmd.monitorStatus := cmd.readStatus := cmd.reset := cmd.resetSafeLogic := cmd.safeKeyExchange :=
			cmd.safeKeyFormat := cmd.scan := cmd.setPassword := cmd.setupModeDisable := cmd.setupModeEnable := cmd.test := FALSE;
			
			IF cmd.clearData THEN
						
				internal.remoteControl.Execute 			:= TRUE;
				internal.remoteControlCmdType.Command 	:= safeCMD_ENTER;
				internal.remoteControlCmdType.Data 		:= safeCMD_CLEAR_DATA;
						
				IF NOT internal.remoteControl.Busy THEN
					IF internal.remoteControl.Done THEN
						cmd.clearData					:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						brsmemcpy(ADR(internal.remoteControlStatusType), ADR(internal.remoteControl.SafeLOGICStatus), SIZEOF(internal.remoteControl.SafeLOGICStatus));
						internal.state 					:= BRDKSAFETY_DONE;
					ELSIF internal.remoteControl.Error THEN
						cmd.clearData					:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						status.lastErrorID 				:= internal.remoteControl.StatusID;
						internal.state 					:= BRDKSAFETY_ERROR;
					END_IF
				END_IF
						
			ELSE
				internal.remoteControl.Execute 	:= FALSE;
				internal.state					:= BRDKSAFETY_IDLE;
			END_IF
				
		BRDKSAFETY_CMD_RESET_SAFELOGIC:
				
			status.status := 'Busy Resetting SafeLOGIC';
				
			busy := TRUE;
			done := error := cmd.clearData := cmd.firmwareAcknowledge := cmd.moduleExchange1 := cmd.moduleExchange2 := cmd.moduleExchange3 :=
			cmd.moduleExchange4 := cmd.moduleExchangeN := cmd.monitorStatus := cmd.readStatus := cmd.reset := cmd.safeKeyExchange :=
			cmd.safeKeyFormat := cmd.scan := cmd.setPassword := cmd.setupModeDisable := cmd.setupModeEnable := cmd.test := FALSE;
			
			IF cmd.resetSafeLogic THEN
						
				internal.remoteControl.Execute 			:= TRUE;
				internal.remoteControlCmdType.Command 	:= safeCMD_ENTER;
				internal.remoteControlCmdType.Data 		:= safeCMD_RESET;
						
				IF NOT internal.remoteControl.Busy THEN
					IF internal.remoteControl.Done THEN
						cmd.resetSafeLogic				:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						brsmemcpy(ADR(internal.remoteControlStatusType), ADR(internal.remoteControl.SafeLOGICStatus), SIZEOF(internal.remoteControl.SafeLOGICStatus));
						internal.state 					:= BRDKSAFETY_DONE;
					ELSIF internal.remoteControl.Error THEN
						cmd.resetSafeLogic				:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						status.lastErrorID 				:= internal.remoteControl.StatusID;
						internal.state 					:= BRDKSAFETY_ERROR;
					END_IF
				END_IF
						
			ELSE
				internal.remoteControl.Execute 	:= FALSE;
				internal.state					:= BRDKSAFETY_IDLE;
			END_IF
			
		BRDKSAFETY_CMD_SETUP_ENABLE:
			
			status.status := 'Busy Enabling Setup mode';
				
			busy := TRUE;
			done := error := cmd.clearData := cmd.firmwareAcknowledge := cmd.moduleExchange1 := cmd.moduleExchange2 := cmd.moduleExchange3 :=
			cmd.moduleExchange4 := cmd.moduleExchangeN := cmd.monitorStatus := cmd.readStatus := cmd.reset := cmd.resetSafeLogic :=
			cmd.safeKeyExchange := cmd.safeKeyFormat := cmd.scan := cmd.setPassword := cmd.setupModeDisable := cmd.test := FALSE;
				
			IF cmd.setupModeEnable THEN
						
				internal.remoteControl.Execute 			:= TRUE;
				internal.remoteControlCmdType.Command 	:= safeCMD_ENTER;
				internal.remoteControlCmdType.Data 		:= safeCMD_SETUP_MODE_ACT;
						
				IF NOT internal.remoteControl.Busy THEN
					IF internal.remoteControl.Done THEN
						cmd.setupModeEnable				:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						brsmemcpy(ADR(internal.remoteControlStatusType), ADR(internal.remoteControl.SafeLOGICStatus), SIZEOF(internal.remoteControl.SafeLOGICStatus));
						internal.state 					:= BRDKSAFETY_DONE;
					ELSIF internal.remoteControl.Error THEN
						cmd.setupModeEnable				:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						status.lastErrorID 				:= internal.remoteControl.StatusID;
						internal.state 					:= BRDKSAFETY_ERROR;
					END_IF
				END_IF
						
			ELSE
				internal.remoteControl.Execute 	:= FALSE;
				internal.state					:= BRDKSAFETY_IDLE;
			END_IF
			
		BRDKSAFETY_CMD_SETUP_DISABLE:
			
			status.status := 'Busy Disabling Setup mode';
				
			busy := TRUE;
			done := error := cmd.clearData := cmd.firmwareAcknowledge := cmd.moduleExchange1 := cmd.moduleExchange2 := cmd.moduleExchange3 :=
			cmd.moduleExchange4 := cmd.moduleExchangeN := cmd.monitorStatus := cmd.readStatus := cmd.reset := cmd.resetSafeLogic :=
			cmd.safeKeyExchange := cmd.safeKeyFormat := cmd.scan := cmd.setPassword := cmd.setupModeEnable := cmd.test := FALSE;
				
			IF cmd.setupModeDisable THEN
						
				internal.remoteControl.Execute 			:= TRUE;
				internal.remoteControlCmdType.Command 	:= safeCMD_ENTER;
				internal.remoteControlCmdType.Data 		:= safeCMD_SETUP_MODE_DEACT;
						
				IF NOT internal.remoteControl.Busy THEN
					IF internal.remoteControl.Done THEN
						cmd.setupModeDisable			:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						brsmemcpy(ADR(internal.remoteControlStatusType), ADR(internal.remoteControl.SafeLOGICStatus), SIZEOF(internal.remoteControl.SafeLOGICStatus));
						internal.state 					:= BRDKSAFETY_DONE;
					ELSIF internal.remoteControl.Error THEN
						cmd.setupModeDisable			:= FALSE;
						internal.remoteControl.Execute 	:= FALSE;
						status.lastErrorID 				:= internal.remoteControl.StatusID;
						internal.state 					:= BRDKSAFETY_ERROR;
					END_IF
				END_IF
						
			ELSE
				internal.remoteControl.Execute 	:= FALSE;
				internal.state					:= BRDKSAFETY_IDLE;
			END_IF
				
		BRDKSAFETY_DONE:
				
			busy := done := error := internal.remoteControl.Execute := internal.TON_MonitorStatus.IN := FALSE;

			IF setup.safeLogicID <> 0 THEN
	
				status.status := 'Last cmd DONE. Waiting for CMD';
				
				internal.remoteControl.SafeLOGICID 			:= setup.safeLogicID;
				internal.remoteControlCmdType.Password		:= setup.safeKEYpassword;
				internal.remoteControlCmdType.NewPassword	:= setup.safeKEYnewPassword;
				
				IF cmd.monitorStatus THEN
					internal.remoteControl.Execute 			:= TRUE; // call the FB 1st time before timer is set to run.
					internal.remoteControlCmdType.Command 	:= safeCMD_STATUS;
					internal.remoteControlCmdType.Data 		:= 0;
					internal.state := BRDKSAFETY_CMD_MONITOR_STATUS;
				ELSIF cmd.readStatus THEN
					internal.state := BRDKSAFETY_CMD_READ_STATUS;
				ELSIF cmd.firmwareAcknowledge THEN
					internal.state := BRDKSAFETY_CMD_FIRMWARE_ACK;
				ELSIF cmd.moduleExchange1 THEN
					internal.state := BRDKSAFETY_CMD_MODULE_EXCH_1;
				ELSIF cmd.moduleExchange2 THEN
					internal.state := BRDKSAFETY_CMD_MODULE_EXCH_2;
				ELSIF cmd.moduleExchange3 THEN
					internal.state := BRDKSAFETY_CMD_MODULE_EXCH_3;
				ELSIF cmd.moduleExchange4 THEN
					internal.state := BRDKSAFETY_CMD_MODULE_EXCH_4;
				ELSIF cmd.moduleExchangeN THEN
					internal.state := BRDKSAFETY_CMD_MODULE_EXCH_N;
				ELSIF cmd.safeKeyExchange THEN
					internal.state := BRDKSAFETY_CMD_SAFEKEY_EXCH;
				ELSIF cmd.safeKeyFormat THEN
					internal.state := BRDKSAFETY_CMD_SAFEKEY_FORMAT;
				ELSIF cmd.scan THEN
					internal.state := BRDKSAFETY_CMD_SCAN;
				ELSIF cmd.setPassword THEN
					internal.state := BRDKSAFETY_CMD_SET_PASSWORD;
				ELSIF cmd.test THEN
					internal.state := BRDKSAFETY_CMD_TEST;
				ELSIF cmd.clearData THEN
					internal.state := BRDKSAFETY_CMD_CLEAR_DATA;
				ELSIF cmd.resetSafeLogic THEN
					internal.state := BRDKSAFETY_CMD_RESET_SAFELOGIC;
				ELSIF cmd.setupModeEnable THEN
					internal.state := BRDKSAFETY_CMD_SETUP_ENABLE;
				ELSIF cmd.setupModeDisable THEN
					internal.state := BRDKSAFETY_CMD_SETUP_DISABLE;
				END_IF	
			ELSE
				status.status := 'Setup parameters not set correctly';
			END_IF
								
		BRDKSAFETY_ERROR:
			
			CASE status.lastErrorID OF
				36108: status.status 	:= 'Error: Incorrect password.';
				36109: status.status 	:= 'Error: A new password was not set.';
				ELSE
					status.status 		:= 'Error: Check the last error ID and set cmd.reset';
			END_CASE
				
			error := TRUE;
			busy := done := cmd.clearData := cmd.firmwareAcknowledge := cmd.moduleExchange1 := cmd.moduleExchange2 := cmd.moduleExchange3 :=
			cmd.moduleExchange4 := cmd.moduleExchangeN := cmd.monitorStatus := cmd.readStatus := cmd.resetSafeLogic := cmd.safeKeyExchange :=
			cmd.safeKeyFormat := cmd.scan := cmd.setPassword := cmd.setupModeDisable := cmd.setupModeEnable := cmd.test :=
			internal.remoteControl.Execute := internal.TON_MonitorStatus.IN := FALSE;
				
			IF cmd.reset THEN
				cmd.reset 			:= FALSE;
				status.lastErrorID 	:= 0;
				internal.state 		:= BRDKSAFETY_IDLE;
			END_IF

	END_CASE
		
	(************************************************************************)
	(******************************** STATUS ********************************)
	(************************************************************************)
	IF status.firstRead THEN
					
		(* SafeOS state *)
		CASE internal.remoteControlStatusType.SafeOSState OF
			0:																									// 0x00 = 0
				IF internal.remoteControlStatusType.PasswordSet = 0 THEN
					status.safeOSState 	:= 'Invalid: no password or still booting';
				ELSIF internal.remoteControlStatusType.ProjectPresent = 0 THEN
					status.safeOSState 	:= 'Invalid: no application or still booting';
				ELSE
					status.safeOSState 	:= 'Invalid: no data or still booting';
				END_IF
			15: status.safeOSState 		:= 'ON (booting / internal initialization) or error (check logbook)';	// 0x0F = 15
			51: status.safeOSState 		:= 'Loading (booting / internal initialization)';						// 0x33 = 51
			85: status.safeOSState 		:= 'Stop [Safe]';														// 0x55 = 85
			102: status.safeOSState 	:= 'Run [Safe]';														// 0x66 = 102
			153: status.safeOSState 	:= 'Halt [Debug]';														// 0x99 = 153
			170: status.safeOSState 	:= 'Stop [Debug], no password, no data, etc.';							// 0xAA = 170
			204: status.safeOSState 	:= 'Run [Debug]';														// 0xCC = 204
			240: status.safeOSState		:= 'No execution';														// 0xF0 = 240
		END_CASE
	
		(* Modules state *)
		IF internal.remoteControlStatusType.LedTestActive = 16#01 THEN
			status.modulesState := 'LED test active';
		ELSIF internal.remoteControlStatusType.Scanning = 16#01 THEN
			status.modulesState := 'Module scan active';
		ELSIF internal.remoteControlStatusType.NumberOfUDIDMismatches = 1 THEN
			status.modulesState := '1 module exchanged. Set cmd.moduleExchange1';
		ELSIF internal.remoteControlStatusType.NumberOfUDIDMismatches = 2 THEN
			status.modulesState := '2 modules exchanged. Set cmd.moduleExchange2';
		ELSIF internal.remoteControlStatusType.NumberOfUDIDMismatches = 3 THEN
			status.modulesState := '3 modules exchanged. Set cmd.moduleExchange3';
		ELSIF internal.remoteControlStatusType.NumberOfUDIDMismatches = 4 THEN
			status.modulesState := '4 modules exchanged. Set cmd.moduleExchange4';
		ELSIF internal.remoteControlStatusType.NumberOfUDIDMismatches > 4 THEN
			status.modulesState := 'n modules exchanged. Set cmd.moduleExchangeN';
		ELSIF internal.remoteControlStatusType.NumberOfMissingModules <> 0 THEN
			status.modulesState := 'Module missing';
		ELSIF internal.remoteControlStatusType.NumberOfUDIDMismatches = 0 THEN
			status.modulesState := 'Modules OK';
		END_IF
	
		(* System state *)
		IF internal.remoteControlStatusType.SafeKEYChanged = 0 AND internal.remoteControlStatusType.NumberOfDifferentFirmware = 0 THEN
			status.systemState := 'FW / SafeKEY OK';
		ELSIF internal.remoteControlStatusType.SafeKEYChanged = 16#01 THEN
			status.systemState := 'SafeKEY exchanged. Set cmd.safeKeyExchange';
		ELSIF internal.remoteControlStatusType.NumberOfDifferentFirmware <> 0 THEN
			status.systemState := 'FW updated. Set cmd.firmwareAcknowledge';
		END_IF
	
		(* Operation mode *)
		IF internal.remoteControlStatusType.FailSafe <> 16#55 THEN
			status.operationMode := 'Fail Safe';
		ELSIF internal.remoteControlStatusType.openSAFETYstate = 0 THEN
			status.operationMode := 'Pre-operational';
		ELSIF internal.remoteControlStatusType.openSAFETYstate = 1 THEN
			status.operationMode := 'Operational';
		END_IF
		
		brsmemset(ADR(status.cmdRequest), 0, SIZEOF(status.cmdRequest));
		IF internal.remoteControlStatusType.ProjectPresent = 0 THEN
			status.cmdRequest.downloadApplication 	:= TRUE;
		ELSIF internal.remoteControlStatusType.PasswordSet = 0 THEN
			status.cmdRequest.setPassword 			:= TRUE;
		ELSIF internal.remoteControlStatusType.SafeKEYChanged = 1 THEN
			status.cmdRequest.safeKeyExchange 		:= TRUE;
		ELSIF internal.remoteControlStatusType.NumberOfUDIDMismatches = 1 AND internal.remoteControlStatusType.Scanning = 0 THEN
			status.cmdRequest.moduleExchange1 		:= TRUE;
		ELSIF internal.remoteControlStatusType.NumberOfUDIDMismatches = 2 AND internal.remoteControlStatusType.Scanning = 0 THEN
			status.cmdRequest.moduleExchange2 		:= TRUE;
		ELSIF internal.remoteControlStatusType.NumberOfUDIDMismatches = 3 AND internal.remoteControlStatusType.Scanning = 0 THEN
			status.cmdRequest.moduleExchange3 		:= TRUE;
		ELSIF internal.remoteControlStatusType.NumberOfUDIDMismatches = 4 AND internal.remoteControlStatusType.Scanning = 0 THEN
			status.cmdRequest.moduleExchange4 		:= TRUE;
		ELSIF internal.remoteControlStatusType.NumberOfUDIDMismatches > 4 AND internal.remoteControlStatusType.Scanning = 0 THEN
			status.cmdRequest.moduleExchangeN 		:= TRUE;
		ELSIF internal.remoteControlStatusType.NumberOfDifferentFirmware <> 0 AND internal.remoteControlStatusType.Scanning = 0 THEN
			brsmemset(ADR(status.cmdRequest), 0, SIZEOF(status.cmdRequest));
			status.cmdRequest.firmwareAcknowledge 	:= TRUE;
		ELSIF internal.remoteControlStatusType.SetupModeActive = 1 AND internal.remoteControlStatusType.Scanning = 0 THEN
			status.cmdRequest.setupModeEnabled 		:= TRUE;
		END_IF
		
	ELSE
			
		status.safeOSState := status.modulesState := status.systemState := status.operationMode := 'Needs to read status for 1st time';
		brsmemset(ADR(status.cmdRequest), 0, SIZEOF(status.cmdRequest));
	
	END_IF
	
	internal.TON_MonitorStatus(PT := T#5s); // waiting time for command monitor status. The timer is started after reading status is complete.
	internal.remoteControlCmdType.Version := safeVERSION_R107;
	internal.remoteControl(pCommandData := ADR(internal.remoteControlCmdType));
	
END_FUNCTION_BLOCK