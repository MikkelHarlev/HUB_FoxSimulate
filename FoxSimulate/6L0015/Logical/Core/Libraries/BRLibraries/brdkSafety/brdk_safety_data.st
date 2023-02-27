(* Function block for download & read data such as machine options to the safety controller. *)
FUNCTION_BLOCK brdk_safety_data
	
	IF NOT enable THEN
		internal.state := BRDKSAFETY_DISABLED;
	END_IF
			
	CASE internal.state OF
		
		BRDKSAFETY_DISABLED:
		
			error := busy := done := waitForAcknowledge := FALSE;
			status.lastErrorID := 0;
			status.lastTimestamp := 0;
			brsmemset(ADR(cmd), 							0, SIZEOF(cmd));
			brsmemset(ADR(internal), 						0, SIZEOF(internal));
			brsmemset(ADR(status.machineOptions), 			0, SIZEOF(status.machineOptions));
			brsmemset(ADR(status.extendedMachineOptions),	0, SIZEOF(status.extendedMachineOptions));
			
			IF DiagCpuIsSimulated() THEN
				status.status := 'Simulation is not supported';
			ELSIF enable THEN
				internal.state := BRDKSAFETY_IDLE;
			ELSE
				status.status := 'Function Block is disabled';
			END_IF
			
		BRDKSAFETY_IDLE:
			
			status.status := 'Waiting for CMD';
				
			busy 									:= FALSE;
			done 									:= FALSE;
			error									:= FALSE;
			waitForAcknowledge 						:= FALSE;
			cmd.acknowledge 						:= FALSE;
			cmd.cancelDownload 						:= FALSE;
			cmd.reset 								:= FALSE;
			status.lastTimestamp 					:= 0;
			internal.downloadCmdMaOpType.Unlock 	:= 0;
			internal.downloadCmdExtMaOpType.Unlock 	:= 0;
			internal.downloadCmdTableType.Unlock 	:= 0;
			internal.AsIOAccRead_0.enable 			:= FALSE;
			internal.EplSDORead_0.enable 			:= FALSE;
			internal.downloadData.Execute 			:= FALSE;
			internal.readData.Execute 				:= FALSE;
			brsmemset(ADR(par.machineOptions.acknBoolOptions), 		0, SIZEOF(par.machineOptions.acknBoolOptions));
			brsmemset(ADR(par.extendedMachineOptions.acknOptions), 	0, SIZEOF(par.extendedMachineOptions.acknOptions));
			brsmemset(ADR(internal.acknowledgeMachineOptions), 		0, SIZEOF(internal.acknowledgeMachineOptions));
			brsmemset(ADR(internal.acknowledgeExtMachineOptions), 	0, SIZEOF(internal.acknowledgeExtMachineOptions));
				
			IF (setup.SLXused AND par.type = BRDKSAFETY_TYPE_OPTIONS AND brsstrlen(ADR(setup.safeKEYpassword)) > 5 AND setup.safeLogicID <> 0 AND brsstrlen(ADR(setup.SLXstation)) > 5) OR
				(NOT setup.SLXused AND brsstrlen(ADR(setup.safeKEYpassword)) > 5 AND setup.safeLogicID <> 0 AND brsstrlen(ADR(setup.SLinterface)) > 2 AND setup.SLnode <> 0) THEN
				
				(* Download data *)
				IF cmd.download THEN
					
					cmd.download := FALSE;
				
					CASE setup.machineOptions OF
						BRDKSAFETY_SET_OPTIONS_AND_FLAGS:
							internal.downloadCmdMaOpType.pMachineOptionsInput 	:= ADR(internal.optionsBoolIn);
							internal.downloadCmdMaOpType.pModuleFlagsInput 		:= ADR(internal.moduleFlagsIn);
						BRDKSAFETY_SET_OPTIONS_ONLY:
							internal.downloadCmdMaOpType.pMachineOptionsInput 	:= ADR(internal.optionsBoolIn);
							internal.downloadCmdMaOpType.pModuleFlagsInput 		:= 0;
						BRDKSAFETY_SET_FLAGS_ONLY:
							internal.downloadCmdMaOpType.pMachineOptionsInput 	:= 0;
							internal.downloadCmdMaOpType.pModuleFlagsInput 		:= ADR(internal.moduleFlagsIn);
					END_CASE
					
					CASE par.type OF
					
						BRDKSAFETY_TYPE_OPTIONS:
						
							// Set bits in internal structure according to par structure where Bool[0] is bit 0 in byte 1. Bool[9] is bit 1 in byte 2 and so on:
							internal.i := internal.j := internal.k := 0;
							FOR internal.i := 0 TO BRDKSAFETY_MAX_OPTIONS DO
								IF internal.j > 7 THEN
									internal.j := 0;
									internal.k := internal.k + 1;
								END_IF
								IF par.machineOptions.optionsBool[internal.i] THEN
									internal.optionsBoolIn.BitData[internal.k] := internal.optionsBoolIn.BitData[internal.k] OR SHL(1, internal.j); 		// set bit, use bitwise OR. Set bit at j position
								ELSE
									internal.optionsBoolIn.BitData[internal.k] := internal.optionsBoolIn.BitData[internal.k] AND NOT SHL(1, internal.j);	// clear bit, use bitwise AND and bitwise NOT. Clear bit at j position
								END_IF
								internal.j := internal.j + 1;
							END_FOR
						
							internal.i := internal.k := 0;
							internal.j := 1; // start at bit 1, since it corresponds to SafeModule 1
							FOR internal.i := 0 TO BRDKSAFETY_MAX_MODULES DO
								IF internal.j > 7 THEN
									internal.j := 0;
									internal.k := internal.k + 1;
								END_IF
								CASE par.machineOptions.moduleFlags[internal.i] OF
									BRDKSAFETY_FLAG_NONE:
										internal.moduleFlagsIn.NotPresent[internal.k] 	:= internal.moduleFlagsIn.NotPresent[internal.k] 	AND NOT SHL(1, internal.j); // clear bit, use bitwise AND and bitwise NOT. Clear bit at j position
										internal.moduleFlagsIn.Optional[internal.k] 	:= internal.moduleFlagsIn.Optional[internal.k] 		AND NOT SHL(1, internal.j); // clear bit, use bitwise AND and bitwise NOT. Clear bit at j position
										internal.moduleFlagsIn.Startup[internal.k] 		:= internal.moduleFlagsIn.Startup[internal.k] 		AND NOT SHL(1, internal.j); // clear bit, use bitwise AND and bitwise NOT. Clear bit at j position
									BRDKSAFETY_FLAG_NOTPRESENT:
										internal.moduleFlagsIn.NotPresent[internal.k] 	:= internal.moduleFlagsIn.NotPresent[internal.k] 	OR SHL(1, internal.j); 		// set bit, use bitwise OR. Set bit at j position
										internal.moduleFlagsIn.Optional[internal.k] 	:= internal.moduleFlagsIn.Optional[internal.k] 		AND NOT SHL(1, internal.j); // clear bit, use bitwise AND and bitwise NOT. Clear bit at j position
										internal.moduleFlagsIn.Startup[internal.k] 		:= internal.moduleFlagsIn.Startup[internal.k] 		AND NOT SHL(1, internal.j); // clear bit, use bitwise AND and bitwise NOT. Clear bit at j position
									BRDKSAFETY_FLAG_OPTIONAL:
										internal.moduleFlagsIn.Optional[internal.k] 	:= internal.moduleFlagsIn.Optional[internal.k] 		OR SHL(1, internal.j); 		// set bit, use bitwise OR. Set bit at j position
										internal.moduleFlagsIn.NotPresent[internal.k] 	:= internal.moduleFlagsIn.NotPresent[internal.k] 	AND NOT SHL(1, internal.j); // clear bit, use bitwise AND and bitwise NOT. Clear bit at j position
										internal.moduleFlagsIn.Startup[internal.k] 		:= internal.moduleFlagsIn.Startup[internal.k] 		AND NOT SHL(1, internal.j); // clear bit, use bitwise AND and bitwise NOT. Clear bit at j position
									BRDKSAFETY_FLAG_STARTUP:
										internal.moduleFlagsIn.Startup[internal.k] 		:= internal.moduleFlagsIn.Startup[internal.k] 		OR SHL(1, internal.j); 		// set bit, use bitwise OR. Set bit at j position
										internal.moduleFlagsIn.NotPresent[internal.k] 	:= internal.moduleFlagsIn.NotPresent[internal.k] 	AND NOT SHL(1, internal.j); // clear bit, use bitwise AND and bitwise NOT. Clear bit at j position
										internal.moduleFlagsIn.Optional[internal.k] 	:= internal.moduleFlagsIn.Optional[internal.k] 		AND NOT SHL(1, internal.j); // clear bit, use bitwise AND and bitwise NOT. Clear bit at j position
								END_CASE
								internal.j := internal.j + 1;
							END_FOR
						
						BRDKSAFETY_TYPE_EXTOPTIONS:
					
							FOR internal.i:=0 TO BRDKSAFETY_MAX_OPTIONS DO
								internal.optionsIntIn[internal.i].ID 		:= internal.i;
								internal.optionsIntIn[internal.i].Value 	:= par.extendedMachineOptions.optionsInt[internal.i];
								internal.optionsUintIn[internal.i].ID 		:= internal.i;
								internal.optionsUintIn[internal.i].Value 	:= par.extendedMachineOptions.optionsUint[internal.i];
								internal.optionsDintIn[internal.i].ID 		:= internal.i;
								internal.optionsDintIn[internal.i].Value 	:= par.extendedMachineOptions.optionsDint[internal.i];
								internal.optionsUdintIn[internal.i].ID 		:= internal.i;
								internal.optionsUdintIn[internal.i].Value 	:= par.extendedMachineOptions.optionsUdint[internal.i];
							END_FOR
				
						BRDKSAFETY_TYPE_TABLEOBJECTS:
					
							FOR internal.i:=0 TO BRDKSAFETY_MAX_TABLES DO
								internal.downloadTableType[internal.i].Device	:= setup.devicenameForTableObjects;
								internal.downloadTableType[internal.i].File 	:= setup.filenameOfTableObject[internal.i];
							END_FOR
									
					END_CASE
				
					IF setup.SLXused THEN
						internal.state := BRDKSAFETY_READ_UDID_LOW_SLX;
					ELSE
						internal.state := BRDKSAFETY_READ_UDID_LOW_SL;
					END_IF
				
				ELSIF cmd.read THEN
					cmd.read 		:= FALSE;
					internal.state 	:= BRDKSAFETY_CMD_READ_DATA;
				END_IF
				
			ELSE
				cmd.download 										:= FALSE;
				cmd.read 											:= FALSE;
				status.status 										:= 'Setup parameters not set correctly';
				internal.downloadCmdMaOpType.pMachineOptionsInput 	:= 0;
				internal.downloadCmdMaOpType.pModuleFlagsInput 		:= 0;
			END_IF
			
		BRDKSAFETY_READ_UDID_LOW_SLX:
			
			status.status := 'Busy Downloading Data';
				
			busy 							:= TRUE;
			done 							:= FALSE;
			error							:= FALSE;
			waitForAcknowledge 				:= FALSE;
			cmd.download					:= FALSE;
			cmd.read						:= FALSE;
			cmd.acknowledge 				:= FALSE;
			cmd.cancelDownload 				:= FALSE;
			cmd.reset 						:= FALSE;
			internal.downloadData.Execute 	:= FALSE;
			internal.readData.Execute 		:= FALSE;
			
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
				
			status.status := 'Busy Downloading Data';
				
			busy 							:= TRUE;
			done 							:= FALSE;
			error							:= FALSE;
			waitForAcknowledge 				:= FALSE;
			cmd.download					:= FALSE;
			cmd.read						:= FALSE;
			cmd.acknowledge 				:= FALSE;
			cmd.cancelDownload 				:= FALSE;
			cmd.reset 						:= FALSE;
			internal.downloadData.Execute 	:= FALSE;
			internal.readData.Execute 		:= FALSE;
							
			internal.AsIOAccRead_0.enable 		:= TRUE;
			internal.AsIOAccRead_0.pDeviceName 	:= ADR(setup.SLXstation);
			internal.AsIOAccRead_0.pChannelName := ADR('UDID_high');
				
			IF internal.AsIOAccRead_0.status = ERR_OK THEN
				internal.AsIOAccRead_0.enable 	:= FALSE;
				internal.UDID_High 				:= UDINT_TO_UINT(internal.AsIOAccRead_0.value);
				internal.state 					:= BRDKSAFETY_CMD_DOWNLOAD_DATA;
			ELSIF internal.AsIOAccRead_0.status <> ERR_FUB_BUSY AND internal.AsIOAccRead_0.status <> ERR_FUB_ENABLE_FALSE THEN
				internal.AsIOAccRead_0.enable 	:= FALSE;
				status.lastErrorID				:= internal.AsIOAccRead_0.status;
				internal.state 					:= BRDKSAFETY_ERROR;	
			END_IF
				
		BRDKSAFETY_READ_UDID_LOW_SL:
				
			status.status := 'Busy Downloading Data';
				
			busy 							:= TRUE;
			done 							:= FALSE;
			error							:= FALSE;
			waitForAcknowledge 				:= FALSE;
			cmd.download					:= FALSE;
			cmd.read						:= FALSE;
			cmd.acknowledge 				:= FALSE;
			cmd.cancelDownload 				:= FALSE;
			cmd.reset 						:= FALSE;
			internal.downloadData.Execute 	:= FALSE;
			internal.readData.Execute 		:= FALSE;
				
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
				
			status.status := 'Busy Downloading Data';
				
			busy 							:= TRUE;
			done 							:= FALSE;
			error							:= FALSE;
			waitForAcknowledge 				:= FALSE;
			cmd.download					:= FALSE;
			cmd.read						:= FALSE;
			cmd.acknowledge 				:= FALSE;
			cmd.cancelDownload 				:= FALSE;
			cmd.reset 						:= FALSE;
			internal.downloadData.Execute 	:= FALSE;
			internal.readData.Execute 		:= FALSE;
								
			internal.EplSDORead_0.enable 	:= TRUE;
			internal.EplSDORead_0.pDevice 	:= ADR(setup.SLinterface);
			internal.EplSDORead_0.node 		:= setup.SLnode;
			internal.EplSDORead_0.index 	:= 16#2000;
			internal.EplSDORead_0.subindex	:= 7;
			internal.EplSDORead_0.pData 	:= ADR(internal.UDID_High);
			internal.EplSDORead_0.datalen 	:= SIZEOF(internal.UDID_High);
				
			IF internal.EplSDORead_0.status = ERR_OK THEN
				internal.EplSDORead_0.enable 	:= FALSE;
				internal.state 					:= BRDKSAFETY_CMD_DOWNLOAD_DATA;
			ELSIF internal.EplSDORead_0.status <> ERR_FUB_BUSY AND internal.EplSDORead_0.status <> ERR_FUB_ENABLE_FALSE THEN
				internal.EplSDORead_0.enable 	:= FALSE;
				status.lastErrorID				:= internal.EplSDORead_0.status;
				internal.state 					:= BRDKSAFETY_ERROR;	
			END_IF
				
		BRDKSAFETY_CMD_DOWNLOAD_DATA:
				
			busy 						:= TRUE;
			done 						:= FALSE;
			error						:= FALSE;
			cmd.download				:= FALSE;
			cmd.read					:= FALSE;
			cmd.reset 					:= FALSE;
			internal.readData.Execute	:= FALSE;
				
			CASE par.type OF
					
				BRDKSAFETY_TYPE_OPTIONS:
						
					internal.downloadData.Type 							:= safeDATA_TYPE_MAOP;
					internal.downloadData.pCommandData 					:= ADR(internal.downloadCmdMaOpType);
						
					internal.downloadCmdMaOpType.Version 				:= safeVERSION_R107;
					internal.downloadCmdMaOpType.UDID_Low 				:= internal.UDID_Low;
					internal.downloadCmdMaOpType.UDID_High 				:= internal.UDID_High;
					internal.downloadCmdMaOpType.Password 				:= setup.safeKEYpassword;
					internal.downloadCmdMaOpType.pAcknMachineOptions 	:= ADR(internal.acknowledgeMachineOptions);
												
				BRDKSAFETY_TYPE_EXTOPTIONS:
						
					internal.downloadData.Type 							:= safeDATA_TYPE_EXTMAOP;
					internal.downloadData.pCommandData 					:= ADR(internal.downloadCmdExtMaOpType);
						
					internal.downloadCmdExtMaOpType.Version 			:= safeVERSION_R107;
					internal.downloadCmdExtMaOpType.UDID_Low 			:= internal.UDID_Low;
					internal.downloadCmdExtMaOpType.UDID_High 			:= internal.UDID_High;
					internal.downloadCmdExtMaOpType.Password 			:= setup.safeKEYpassword;
					internal.downloadCmdExtMaOpType.pIntDataInput		:= ADR(internal.optionsIntIn);
					internal.downloadCmdExtMaOpType.pUintDataInput		:= ADR(internal.optionsUintIn);
					internal.downloadCmdExtMaOpType.pDintDataInput		:= ADR(internal.optionsDintIn);
					internal.downloadCmdExtMaOpType.pUdintDataInput		:= ADR(internal.optionsUdintIn);
					internal.downloadCmdExtMaOpType.pAcknMachineOptions := ADR(internal.acknowledgeExtMachineOptions);
					internal.downloadCmdExtMaOpType.NumberIntInput		:= setup.extendedMachineOptions.numberOfInt;
					internal.downloadCmdExtMaOpType.NumberUintInput		:= setup.extendedMachineOptions.numberOfUint;
					internal.downloadCmdExtMaOpType.NumberDintInput		:= setup.extendedMachineOptions.numberOfDint;
					internal.downloadCmdExtMaOpType.NumberUdintInput	:= setup.extendedMachineOptions.numberOfUdint;
				
				BRDKSAFETY_TYPE_TABLEOBJECTS:
					
					internal.downloadData.Type 							:= safeDATA_TYPE_TABLE;
					internal.downloadData.pCommandData 					:= ADR(internal.downloadCmdTableType);
				
					internal.downloadCmdTableType.Version 				:= safeVERSION_R107;
					internal.downloadCmdTableType.UDID_Low 				:= internal.UDID_Low;
					internal.downloadCmdTableType.UDID_High 			:= internal.UDID_High;
					internal.downloadCmdTableType.Password			 	:= setup.safeKEYpassword;
					internal.downloadCmdTableType.NumberTablesInput 	:= setup.numberOfTableObjects;
					internal.downloadCmdTableType.pTableDataInput 		:= ADR(internal.downloadTableType);

			END_CASE
						
			internal.downloadData.Execute 		:= TRUE;
			internal.downloadData.SafeLOGICID 	:= setup.safeLogicID;
				
			IF internal.downloadData.UnlockRequired THEN
					
				status.status 			:= 'Waiting for acknowledge';
				waitForAcknowledge 		:= TRUE;
				status.lastTimestamp 	:= internal.downloadData.Timestamp;
					
				CASE par.type OF
					
					BRDKSAFETY_TYPE_OPTIONS:
					
						internal.i := internal.j := internal.k := 0;
						FOR internal.i := 0 TO BRDKSAFETY_MAX_OPTIONS DO
							IF internal.j > 7 THEN
								internal.j := 0;
								internal.k := internal.k + 1;
							END_IF
							IF par.machineOptions.acknBoolOptions[internal.i] THEN
								internal.acknowledgeMachineOptions.AcknBitOptions[internal.k] := internal.acknowledgeMachineOptions.AcknBitOptions[internal.k] OR SHL(1, internal.j); // set bit, use bitwise OR. Set bit at j position
							ELSE
								internal.acknowledgeMachineOptions.AcknBitOptions[internal.k] := internal.acknowledgeMachineOptions.AcknBitOptions[internal.k] AND NOT SHL(1, internal.j); // clear bit, use bitwise AND and bitwise NOT. Clear bit at j position
							END_IF
							internal.j := internal.j + 1;
						END_FOR
						
					BRDKSAFETY_TYPE_EXTOPTIONS:
						
						FOR internal.i := 0 TO BRDKSAFETY_MAX_OPTIONS DO
							internal.acknowledgeExtMachineOptions.AcknIntOptions[internal.i] 	:= par.extendedMachineOptions.acknOptions.acknIntOptions[internal.i];
							internal.acknowledgeExtMachineOptions.AcknUintOptions[internal.i] 	:= par.extendedMachineOptions.acknOptions.acknUintOptions[internal.i];
							internal.acknowledgeExtMachineOptions.AcknDintOptions[internal.i] 	:= par.extendedMachineOptions.acknOptions.acknDintOptions[internal.i];
							internal.acknowledgeExtMachineOptions.AcknUdintOptions[internal.i]	:= par.extendedMachineOptions.acknOptions.acknUdintOptions[internal.i];
						END_FOR
					
					BRDKSAFETY_TYPE_TABLEOBJECTS:
												 
				END_CASE

				IF cmd.acknowledge THEN
					cmd.acknowledge 						:= FALSE;
					internal.downloadCmdMaOpType.Unlock 	:= 1;
					internal.downloadCmdExtMaOpType.Unlock 	:= 1;
					internal.downloadCmdTableType.Unlock 	:= 1;
				ELSIF cmd.cancelDownload THEN
					cmd.cancelDownload 						:= FALSE;
					internal.downloadCmdMaOpType.Unlock 	:= 2;
					internal.downloadCmdExtMaOpType.Unlock 	:= 2;
					internal.downloadCmdTableType.Unlock 	:= 2;
				END_IF
					
			ELSE
				status.status 							:= 'Busy Downloading Data';
				cmd.acknowledge 						:= FALSE;
				cmd.cancelDownload 						:= FALSE;
				waitForAcknowledge 						:= FALSE;
				internal.downloadCmdMaOpType.Unlock 	:= 0;
				internal.downloadCmdExtMaOpType.Unlock 	:= 0;
				internal.downloadCmdTableType.Unlock 	:= 0;
			END_IF
	
			IF internal.downloadData.Done THEN
				internal.state 					:= BRDKSAFETY_DONE;
				internal.downloadData.Execute 	:= FALSE;
			ELSIF internal.downloadData.Error THEN
				internal.state 					:= BRDKSAFETY_ERROR;
				status.lastErrorID 				:= internal.downloadData.StatusID;
				internal.downloadData.Execute 	:= FALSE;
			END_IF
			
		BRDKSAFETY_CMD_READ_DATA:
				
			status.status := 'Busy Reading Data';
			
			busy 							:= TRUE;
			done 							:= FALSE;
			error							:= FALSE;
			waitForAcknowledge 				:= FALSE;
			cmd.download					:= FALSE;
			cmd.read						:= FALSE;
			cmd.acknowledge 				:= FALSE;
			cmd.cancelDownload 				:= FALSE;
			cmd.reset 						:= FALSE;
			internal.downloadData.Execute 	:= FALSE;
				
			CASE par.type OF
					
				BRDKSAFETY_TYPE_OPTIONS:
						
					internal.readData.Type 									:= safeDATA_TYPE_MAOP;
					internal.readData.pCommandData 							:= ADR(internal.configurationCmdMaOpType);
						
					internal.configurationCmdMaOpType.Version 				:= safeVERSION_R110;
					internal.configurationCmdMaOpType.Password 				:= setup.safeKEYpassword;
					internal.configurationCmdMaOpType.pMachineOptionsOutput := ADR(internal.optionsBoolOut);
					internal.configurationCmdMaOpType.pModuleFlagsOutput 	:= ADR(internal.moduleFlagsOut);
						
				BRDKSAFETY_TYPE_EXTOPTIONS:
						
					internal.readData.Type 									:= safeDATA_TYPE_EXTMAOP;
					internal.readData.pCommandData 							:= ADR(internal.configurationCmdExtMaOpType);
						
					internal.configurationCmdExtMaOpType.Version 			:= safeVERSION_R110;
					internal.configurationCmdExtMaOpType.Password 			:= setup.safeKEYpassword;
					internal.configurationCmdExtMaOpType.pIntDataOutput		:= ADR(internal.optionsIntOut);
					internal.configurationCmdExtMaOpType.pUintDataOutput	:= ADR(internal.optionsUintOut);
					internal.configurationCmdExtMaOpType.pDintDataOutput	:= ADR(internal.optionsDintOut);
					internal.configurationCmdExtMaOpType.pUdintDataOutput	:= ADR(internal.optionsUdintOut);
					internal.configurationCmdExtMaOpType.NumberIntOutput	:= BRDKSAFETY_MAX_OPTIONS;
					internal.configurationCmdExtMaOpType.NumberUintOutput	:= BRDKSAFETY_MAX_OPTIONS;
					internal.configurationCmdExtMaOpType.NumberDintOutput	:= BRDKSAFETY_MAX_OPTIONS;
					internal.configurationCmdExtMaOpType.NumberUdintOutput	:= BRDKSAFETY_MAX_OPTIONS;
				
				BRDKSAFETY_TYPE_TABLEOBJECTS: // TODO: Can't get it to work. Error number 36132
	
			END_CASE
						
			internal.readData.Execute 		:= TRUE;
			internal.readData.SafeLOGICID 	:= setup.safeLogicID;
				
			IF internal.readData.Done THEN
				internal.state 				:= BRDKSAFETY_DONE;
				internal.readData.Execute 	:= FALSE;
					
				status.lastTimestamp := internal.readData.Timestamp;
					
				CASE par.type OF
					
					BRDKSAFETY_TYPE_OPTIONS:
						
						// Copy bits in bytes into booleans status structure:
						internal.i := internal.j := internal.k := 0;
						FOR internal.i := 0 TO BRDKSAFETY_MAX_OPTIONS DO
							IF internal.j > 7 THEN
								internal.j := 0;
								internal.k := internal.k + 1;
							END_IF
							internal.temp := internal.optionsBoolOut.BitData[internal.k] AND SHL(1, internal.j);
							IF internal.temp > 0 THEN
								status.machineOptions.optionsBool[internal.i] := TRUE;
							ELSE
								status.machineOptions.optionsBool[internal.i] := FALSE;
							END_IF
							internal.j := internal.j + 1;
						END_FOR
														
						internal.i := internal.k := 0;
						internal.j := 1;
						FOR internal.i := 0 TO BRDKSAFETY_MAX_OPTIONS DO
							IF internal.j > 7 THEN
								internal.j := 0;
								internal.k := internal.k + 1;
							END_IF
							status.machineOptions.moduleFlags[internal.i] 		:= BRDKSAFETY_FLAG_NONE;
							internal.temp := internal.moduleFlagsOut.NotPresent[internal.k] AND SHL(1, internal.j);
							IF internal.temp > 0 THEN
								status.machineOptions.moduleFlags[internal.i] 	:= BRDKSAFETY_FLAG_NOTPRESENT;
							END_IF
							internal.temp := internal.moduleFlagsOut.Optional[internal.k] AND SHL(1, internal.j);
							IF internal.temp > 0 THEN
								status.machineOptions.moduleFlags[internal.i] 	:= BRDKSAFETY_FLAG_OPTIONAL;
							END_IF
							internal.temp := internal.moduleFlagsOut.Startup[internal.k] AND SHL(1, internal.j);
							IF internal.temp > 0 THEN
								status.machineOptions.moduleFlags[internal.i] 	:= BRDKSAFETY_FLAG_STARTUP;
							END_IF
							internal.j := internal.j + 1;
						END_FOR
						
					BRDKSAFETY_TYPE_EXTOPTIONS:
							
						FOR internal.i := 0 TO BRDKSAFETY_MAX_OPTIONS DO
							status.extendedMachineOptions.optionsInt[internal.i] 	:= internal.optionsIntOut[internal.i].Value;
							status.extendedMachineOptions.optionsUint[internal.i] 	:= internal.optionsUintOut[internal.i].Value;
							status.extendedMachineOptions.optionsDint[internal.i] 	:= internal.optionsDintOut[internal.i].Value;
							status.extendedMachineOptions.optionsUdint[internal.i] 	:= internal.optionsUdintOut[internal.i].Value;
						END_FOR
					
					BRDKSAFETY_TYPE_TABLEOBJECTS: // TODO: Getting error number 36132 each time...
										
				END_CASE
					
			ELSIF internal.readData.Error THEN
				internal.state 				:= BRDKSAFETY_ERROR;
				status.lastErrorID 			:= internal.readData.StatusID;
				internal.readData.Execute 	:= FALSE;
			END_IF

		BRDKSAFETY_DONE:
				
			status.status := 'Last cmd DONE, if data change then the SafeLogic will reboot. Waiting for CMD';
				
			busy 									:= FALSE;
			done 									:= TRUE;
			error									:= FALSE;
			waitForAcknowledge 						:= FALSE;
			cmd.acknowledge							:= FALSE;
			cmd.cancelDownload 						:= FALSE;
			cmd.reset 								:= FALSE;
			internal.downloadCmdMaOpType.Unlock 	:= 0;
			internal.downloadCmdExtMaOpType.Unlock 	:= 0;
			internal.downloadCmdTableType.Unlock 	:= 0;
			internal.AsIOAccRead_0.enable 			:= FALSE;
			internal.EplSDORead_0.enable 			:= FALSE;
			internal.downloadData.Execute 			:= FALSE;
			internal.readData.Execute 				:= FALSE;
			brsmemset(ADR(par.machineOptions.acknBoolOptions), 		0, SIZEOF(par.machineOptions.acknBoolOptions));
			brsmemset(ADR(par.extendedMachineOptions.acknOptions), 	0, SIZEOF(par.extendedMachineOptions.acknOptions));
			brsmemset(ADR(internal.acknowledgeMachineOptions), 		0, SIZEOF(internal.acknowledgeMachineOptions));
			brsmemset(ADR(internal.acknowledgeExtMachineOptions), 	0, SIZEOF(internal.acknowledgeExtMachineOptions));
				
			IF cmd.download OR cmd.read THEN
				internal.state := BRDKSAFETY_IDLE;
			END_IF
							
		BRDKSAFETY_ERROR:
			
			CASE status.lastErrorID OF
				37511: status.status 	:= 'Error: Close the opened Remote Control in SafeDESIGNER.';
				36127: status.status 	:= 'Error: Check acknowledged data = ExternalMachineOptions or different module flags to same module.';
				36122: status.status 	:= 'Error: Incorrect password or password not set.';
				20708: status.status 	:= 'Error: File(s) doesnt exist on target';
				36138: status.status 	:= 'Error: Incorrect password or password not set.';
				ELSE
					status.status 		:= 'Error: Check the last error ID and set cmd.reset';
			END_CASE
				
			error 									:= TRUE;
			busy 									:= FALSE;
			done 									:= FALSE;
			waitForAcknowledge 						:= FALSE;
			cmd.download				 			:= FALSE;
			cmd.read 								:= FALSE;
			cmd.acknowledge 						:= FALSE;
			cmd.cancelDownload 						:= FALSE;
			internal.UDID_Low 						:= 0;
			internal.UDID_High 						:= 0;
			status.lastTimestamp 					:= 0;
			internal.downloadCmdMaOpType.Unlock 	:= 0;
			internal.downloadCmdExtMaOpType.Unlock 	:= 0;
			internal.downloadCmdTableType.Unlock 	:= 0;
			internal.AsIOAccRead_0.enable 			:= FALSE;
			internal.EplSDORead_0.enable 			:= FALSE;
			internal.downloadData.Execute 			:= FALSE;
			internal.readData.Execute 				:= FALSE;
			brsmemset(ADR(par.machineOptions.acknBoolOptions), 		0, SIZEOF(par.machineOptions.acknBoolOptions));
			brsmemset(ADR(par.extendedMachineOptions.acknOptions), 	0, SIZEOF(par.extendedMachineOptions.acknOptions));
			brsmemset(ADR(internal.acknowledgeMachineOptions), 		0, SIZEOF(internal.acknowledgeMachineOptions));
			brsmemset(ADR(internal.acknowledgeExtMachineOptions),	0, SIZEOF(internal.acknowledgeExtMachineOptions));
			brsmemset(ADR(status.machineOptions), 					0, SIZEOF(status.machineOptions));
			brsmemset(ADR(status.extendedMachineOptions), 			0, SIZEOF(status.extendedMachineOptions));
			
			IF cmd.reset THEN
				cmd.reset 			:= FALSE;
				status.lastErrorID 	:= 0;
				internal.state 		:= BRDKSAFETY_IDLE;
			END_IF
				
	END_CASE
	
	internal.AsIOAccRead_0();
	internal.EplSDORead_0();
	internal.downloadData();
	internal.readData();

END_FUNCTION_BLOCK