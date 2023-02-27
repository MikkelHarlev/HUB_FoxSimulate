(* Function block for download the safety application to the safety controller.. *)
FUNCTION_BLOCK brdk_safety_application

	IF NOT enable THEN
		internal.state := BRDKSAFETY_DISABLED;
	END_IF
	
	CASE internal.state OF
			
		BRDKSAFETY_DISABLED:
				
			error := busy := done := waitForAcknowledge := FALSE;
			status.lastErrorID := 0;
			status.applicationCRC := 0;
			brsmemset(ADR(cmd), 0, SIZEOF(cmd));
			brsmemset(ADR(internal), 0, SIZEOF(internal));
			
			IF DiagCpuIsSimulated() THEN
				status.status := 'Simulation is not supported';
			ELSIF enable THEN
				internal.state := BRDKSAFETY_IDLE;
			ELSE
				status.status := 'Function Block is disabled';
			END_IF
			
		BRDKSAFETY_IDLE:
			
			status.status := 'Waiting for CMD';
				
			busy := done := error := waitForAcknowledge := cmd.acknowledge := cmd.cancelDownload := cmd.reset := internal.AsIOAccRead_0.enable :=
			internal.EplSDORead_0.enable := internal.downloadApplication.Execute := FALSE;
			status.applicationCRC := 0;
				
			IF cmd.download AND setup.SLXused AND brsstrlen(ADR(setup.safeKEYpassword)) > 5 AND setup.safeLogicID <> 0 AND brsstrlen(ADR(setup.SLXstation)) > 5 THEN
				cmd.download 	:= FALSE;
				internal.state 	:= BRDKSAFETY_READ_UDID_LOW_SLX;
			ELSIF cmd.download AND NOT setup.SLXused AND brsstrlen(ADR(setup.safeKEYpassword)) > 5 AND setup.safeLogicID <> 0 AND brsstrlen(ADR(setup.SLinterface)) > 2 AND setup.SLnode <> 0 THEN
				cmd.download 	:= FALSE;
				internal.state 	:= BRDKSAFETY_READ_UDID_LOW_SL;
			ELSIF cmd.download THEN
				cmd.download 	:= FALSE;
				status.status 	:= 'Setup parameters not set correctly';
			END_IF
				
			IF setup.downloadFromFile THEN
				internal.downloadCmdApplicationType.ApplicationID 	:= 0; 					// ApplicationID must be 0 if download from file
				internal.downloadCmdApplicationType.Device			:= setup.devicename;
				internal.downloadCmdApplicationType.File			:= setup.filename;
			ELSE
				internal.downloadCmdApplicationType.ApplicationID 	:= setup.safeLogicID; 	// Safety application ID - corresponds to SafeLOGIC controller ID
				internal.downloadCmdApplicationType.Device			:= '';
				internal.downloadCmdApplicationType.File			:= '';
			END_IF
			
		BRDKSAFETY_READ_UDID_LOW_SLX:
			
			status.status := 'Busy Downloading Application';
				
			busy := TRUE;
			done := error := waitForAcknowledge := cmd.download := cmd.acknowledge :=
			cmd.cancelDownload := cmd.reset := internal.downloadApplication.Execute := FALSE;
			
			internal.AsIOAccRead_0.enable 		:= TRUE;
			internal.AsIOAccRead_0.pDeviceName 	:= ADR(setup.SLXstation);
			internal.AsIOAccRead_0.pChannelName := ADR('UDID_low');
								
			IF internal.AsIOAccRead_0.status = ERR_OK THEN
				internal.AsIOAccRead_0.enable 	:= FALSE;
				internal.UDID_Low 				:= internal.AsIOAccRead_0.value;
				internal.state 					:= BRDKSAFETY_READ_UDID_HIGH_SLX;
			ELSIF internal.AsIOAccRead_0.status <> ERR_FUB_BUSY AND internal.AsIOAccRead_0.status <> ERR_FUB_ENABLE_FALSE THEN
				internal.AsIOAccRead_0.enable 	:= FALSE;
				status.lastErrorID				:= internal.AsIOAccRead_0.status;
				internal.state 					:= BRDKSAFETY_ERROR;	
			END_IF
				
		BRDKSAFETY_READ_UDID_HIGH_SLX:
				
			status.status := 'Busy Downloading Application';
				
			busy := TRUE;
			done := error := waitForAcknowledge := cmd.download := cmd.acknowledge :=
			cmd.cancelDownload := cmd.reset := internal.downloadApplication.Execute := FALSE;
							
			internal.AsIOAccRead_0.enable 		:= TRUE;
			internal.AsIOAccRead_0.pDeviceName 	:= ADR(setup.SLXstation);
			internal.AsIOAccRead_0.pChannelName := ADR('UDID_high');
				
			IF internal.AsIOAccRead_0.status = ERR_OK THEN
				internal.AsIOAccRead_0.enable 	:= FALSE;
				internal.UDID_High 				:= UDINT_TO_UINT(internal.AsIOAccRead_0.value);
				internal.state 					:= BRDKSAFETY_CMD_DOWNLOAD_APP;
			ELSIF internal.AsIOAccRead_0.status <> ERR_FUB_BUSY AND internal.AsIOAccRead_0.status <> ERR_FUB_ENABLE_FALSE THEN
				internal.AsIOAccRead_0.enable 	:= FALSE;
				status.lastErrorID				:= internal.AsIOAccRead_0.status;
				internal.state 					:= BRDKSAFETY_ERROR;	
			END_IF
				
		BRDKSAFETY_READ_UDID_LOW_SL:
				
			status.status := 'Busy Downloading Application';
				
			busy := TRUE;
			done := error := waitForAcknowledge := cmd.download := cmd.acknowledge :=
			cmd.cancelDownload := cmd.reset := internal.downloadApplication.Execute := FALSE;
				
			internal.EplSDORead_0.enable 	:= TRUE;
			internal.EplSDORead_0.pDevice 	:= ADR(setup.SLinterface);
			internal.EplSDORead_0.node 		:= setup.SLnode;
			internal.EplSDORead_0.index 	:= 16#2000;
			internal.EplSDORead_0.subindex 	:= 6;
			internal.EplSDORead_0.pData 	:= ADR(internal.UDID_Low);
			internal.EplSDORead_0.datalen 	:= SIZEOF(internal.UDID_Low);
								
			IF internal.EplSDORead_0.status = ERR_OK THEN
				internal.EplSDORead_0.enable 	:= FALSE;
				internal.state 					:= BRDKSAFETY_READ_UDID_HIGH_SL;
			ELSIF internal.EplSDORead_0.status <> ERR_FUB_BUSY AND internal.EplSDORead_0.status <> ERR_FUB_ENABLE_FALSE THEN
				internal.EplSDORead_0.enable 	:= FALSE;
				status.lastErrorID				:= internal.EplSDORead_0.status;
				internal.state 					:= BRDKSAFETY_ERROR;	
			END_IF
				
		BRDKSAFETY_READ_UDID_HIGH_SL:
				
			status.status := 'Busy Downloading Application';
				
			busy := TRUE;
			done := error := waitForAcknowledge := cmd.download := cmd.acknowledge :=
			cmd.cancelDownload := cmd.reset := internal.downloadApplication.Execute := FALSE;
								
			internal.EplSDORead_0.enable 	:= TRUE;
			internal.EplSDORead_0.pDevice 	:= ADR(setup.SLinterface);
			internal.EplSDORead_0.node 		:= setup.SLnode;
			internal.EplSDORead_0.index 	:= 16#2000;
			internal.EplSDORead_0.subindex	:= 7;
			internal.EplSDORead_0.pData 	:= ADR(internal.UDID_High);
			internal.EplSDORead_0.datalen 	:= SIZEOF(internal.UDID_High);
				
			IF internal.EplSDORead_0.status = ERR_OK THEN
				internal.EplSDORead_0.enable 	:= FALSE;
				internal.state 					:= BRDKSAFETY_CMD_DOWNLOAD_APP;
			ELSIF internal.EplSDORead_0.status <> ERR_FUB_BUSY AND internal.EplSDORead_0.status <> ERR_FUB_ENABLE_FALSE THEN
				internal.EplSDORead_0.enable 	:= FALSE;
				status.lastErrorID				:= internal.EplSDORead_0.status;
				internal.state 					:= BRDKSAFETY_ERROR;	
			END_IF
				
		BRDKSAFETY_CMD_DOWNLOAD_APP:
				
			busy := TRUE;
			done := error := cmd.download := cmd.reset := FALSE;
				
			internal.downloadCmdApplicationType.Version 	:= safeVERSION_R107;
			internal.downloadCmdApplicationType.UDID_Low	:= internal.UDID_Low;
			internal.downloadCmdApplicationType.UDID_High 	:= internal.UDID_High;
			internal.downloadCmdApplicationType.Password 	:= setup.safeKEYpassword;
				
			internal.downloadApplication.SafeLOGICID 		:= setup.safeLogicID;
			internal.downloadApplication.Execute 			:= TRUE;
			internal.downloadApplication.pCommandData 		:= ADR(internal.downloadCmdApplicationType);
				
			IF internal.downloadApplication.UnlockRequired THEN
					
				status.status 			:= 'Waiting for acknowledge';
				waitForAcknowledge 		:= TRUE;
				status.applicationCRC 	:= internal.downloadApplication.ApplicationCRC;
					
				IF cmd.acknowledge THEN
					cmd.acknowledge 							:= FALSE;
					internal.downloadCmdApplicationType.Unlock 	:= 1;
				ELSIF cmd.cancelDownload THEN
					cmd.cancelDownload 							:= FALSE;
					internal.downloadCmdApplicationType.Unlock 	:= 2;
				END_IF
					
			ELSE
				status.status 								:= 'Busy Downloading Application';
				waitForAcknowledge 							:= FALSE;
				cmd.acknowledge 							:= FALSE;
				cmd.cancelDownload 							:= FALSE;
				internal.downloadCmdApplicationType.Unlock 	:= 0;
			END_IF
	
			IF internal.downloadApplication.Done THEN
				internal.state 							:= BRDKSAFETY_DONE;
				internal.downloadApplication.Execute 	:= FALSE;
			ELSIF internal.downloadApplication.Error THEN
				internal.state 							:= BRDKSAFETY_ERROR;
				status.lastErrorID 						:= internal.downloadApplication.StatusID;
				internal.downloadApplication.Execute 	:= FALSE;
			END_IF
				
		BRDKSAFETY_DONE:
				
			status.status 	:= 'Done. The SafeLogic will reboot now. Waiting for new CMD';
			
			done := TRUE;
			busy := error := waitForAcknowledge := cmd.acknowledge := cmd.cancelDownload := cmd.reset :=
			internal.AsIOAccRead_0.enable := internal.EplSDORead_0.enable := internal.downloadApplication.Execute := FALSE;
			internal.downloadCmdApplicationType.Unlock := 0;
				
			IF cmd.download THEN
				internal.state := BRDKSAFETY_IDLE;
			END_IF
							
		BRDKSAFETY_ERROR:
			
			CASE status.lastErrorID OF
				36122: status.status := 'Error: Incorrect password or password not set.';
				ELSE
					status.status 	:= 'Error: Check the last error ID and set cmd.reset';
			END_CASE
						
			error := TRUE;
			busy := done := waitForAcknowledge := cmd.download := cmd.acknowledge := cmd.cancelDownload :=
			internal.AsIOAccRead_0.enable := internal.EplSDORead_0.enable := internal.downloadApplication.Execute := FALSE;
			internal.UDID_Low := internal.UDID_High := 0;
			status.applicationCRC := 0;
			internal.downloadCmdApplicationType.Unlock := 0;
				
			IF cmd.reset THEN
				cmd.reset 			:= FALSE;
				status.lastErrorID 	:= 0;
				internal.state 		:= BRDKSAFETY_IDLE;
			END_IF
			
	END_CASE
	
	internal.AsIOAccRead_0();
	internal.EplSDORead_0();
	internal.downloadApplication();
	
END_FUNCTION_BLOCK
