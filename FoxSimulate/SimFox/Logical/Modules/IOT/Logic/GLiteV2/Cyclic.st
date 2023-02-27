
PROGRAM _CYCLIC

	CASE runtimeStep OF	
	
		INIT:
			// Init state
			IF g_Core.Services.Blackbox.Runtime.server.ServersRunning = 0 OR g_Core.Services.Blackbox.Runtime.server.Status <> 0 OR g_Core.System.Runtime.isInitDone = 0 THEN
				// The modules is not yet running. Return and wait for the modules to be ready
				RETURN;
			END_IF
			
			IF g_Core.System.Runtime.isInitDone AND g_HCfg.IOT.isLiteInterfaceEnabled THEN		
				// Setup server numbers
				serverNoInlet 			:= 1;
				IF g_Core.Services.Blackbox.Runtime.server.ServersRunning = 1 THEN
					serverNoOutlet 		:= 1;
				ELSE
					serverNoOutlet 		:= 2;
				END_IF;
				
				// How many lanes do we have?
				numberPosInlet 													:= UDINT_TO_USINT(GetData(ServerNo := serverNoInlet, Type:= NUMBER_OF_LANES, Lane:= 1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)));
				numberPosOutlet 												:= UDINT_TO_USINT(GetData(ServerNo := serverNoOutlet, Type:= NUMBER_OF_LANES, Lane:= 1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)));
				
				GetAdr(ADR(adrAlarmCache),ADR('AlarmHandl:AlarmCache'));
				IF (adrAlarmCache > 0) THEN
					pAlarmCache ACCESS adrAlarmCache;
				END_IF
				
				// Set command to make initial bucket
				FOR no := 0 TO numberPosInlet -1 DO
					bucketHoldingDataInlet[no].bucket.doMake					:= TRUE;
				END_FOR
				
				FOR no := 0 TO numberPosOutlet -1 DO
					bucketHoldingDataOutlet[no].bucket.doMake					:= TRUE;
				END_FOR
	
				// Setup the IoT loggers
				IF (gAdrIOTLogIdent > 0 ) THEN
					// Init status logger
					IOTLogger_0.adrIOTLogIdent 									:= gAdrIOTLogIdent;
					IOTLogger_0.IOTStructName 									:= 'GLiteV2:status';
					IOTLogger_0.event.publish.type 								:= 1;
					IOTLogger_0.eventType 										:= 'statusData';
					IOTLogger_0.version  										:= 'B';	
					IOTLogger_0.isString 										:= TRUE;
					
					// Init data logger
					IOTLogger_1.adrIOTLogIdent 									:= gAdrIOTLogIdent;
					IOTLogger_1.IOTStructName 									:= 'GLiteV2:data';
					IOTLogger_1.event.publish.type 								:= 1;
					IOTLogger_1.eventType 										:= 'productionData';
					IOTLogger_1.version 										:= 'A';

					// Finished in init state. Go to Runtime state
					runtimeStep 												:= RUNTIME;
				END_IF
			END_IF
		
		RUNTIME:
			// Runtime state
			//////////////////////////////////////////////////////////
			//														//
			//	Timers and flags									//
			//														//
			//////////////////////////////////////////////////////////
			// Second counter mastery.
			IF (oldSecond <> g_Core.Services.Time.Runtime.Seconds) THEN
				addSecond 														:= TRUE;
				oldSecond 														:= g_Core.Services.Time.Runtime.Seconds;
			ELSE
				addSecond 														:= FALSE;
			END_IF
			
			// Set sample interval - needs to be checked!
			timeoutData 														:= LIMIT(600,g_HCfg.IOT.liteInterfaceSampleInterval,7200)*1000;
			timeoutStatus 														:= 3600*1000; // 1 hour
			
			TON_DataRefreshInterval.PT											:= UDINT_TO_TIME(timeoutData);
			TON_DataRefreshInterval.IN											:= NOT(TON_DataRefreshInterval.Q);
			TON_DataRefreshInterval();
			
			TON_StatusRefreshInterval.PT										:= UDINT_TO_TIME(timeoutStatus);
			TON_StatusRefreshInterval.IN										:= NOT(TON_StatusRefreshInterval.Q);
			TON_StatusRefreshInterval();
			
			// Catch machines stop.
			edgeNegISControlPlc 												:= EDGENEG(g_Core.System.Runtime.isRunning);
			
			// Update command flag for the IoTLogger. This is used on the modules that fills data, to enable logs for IoT when there is a change ready
			makeUpdateStatus													:= FALSE;
			makeUpdateData														:= FALSE;
			
			//////////////////////////////////////////////////////////
			//////////////////////////////////////////////////////////
			//	IoT Logger for Status								//
			//////////////////////////////////////////////////////////
			//////////////////////////////////////////////////////////
			//////////////////////////////////////////////////////////
			//														//
			//	Machine states (IoT Logger for Status)				//
			//														//
			//////////////////////////////////////////////////////////
			//	0 = available - no error codes
			//	1 = Error state (NOT able TO run) - with error codes
			//	2 = warm up - can have error codes
			//	3 = idle - able TO start - can have error codes - ready to start.
			//	4 = Running but nothing TO process - can have error codes
			//	5 = Running with Errors - with error codes
			//	6 = Running without Errors - no error codes	
			IF (g_Core.System.Runtime.isRunning) THEN
				IF g_Core.Services.Alarmhandler.Runtime.Event[0].Status > 0 THEN
					machineState 												:= 5; 		
				ELSIF (g_Core.System.Runtime.isPowerSave) THEN
					machineState 												:= 4;
				ELSE
					machineState 												:= 6;
				END_IF
				//ERROR?
			ELSIF (g_Core.Services.Alarmhandler.Runtime.Event[0].Status > 0) THEN
				machineState 													:= 1;	
			ELSIF NOT g_Core.System.Runtime.isAppReady THEN
				machineState 													:= 2;
			ELSE
				machineState 													:= 3;
			END_IF
			// Update the IoT Logger for the machine state
			status.statusId														:= machineState;
			
			// Check if the status flag has changed
			IF machineState <> statusOldValues.machineState THEN
				statusOldValues.machineState									:= machineState;
				makeUpdateStatus												:= TRUE;
			END_IF
			
			
			//////////////////////////////////////////////////////////
			//														//
			// Running Customer / Articlei / Process code			//
			// (IoT Logger for Status)								//
			//														//
			//////////////////////////////////////////////////////////
			// Update IoT Logger for running Customer / Article / Process code
			status.processCodeId												:= g_Core.Services.CAR.Runtime.No[0].RecipeNumber;
			status.customerId													:= g_Core.Services.CAR.Runtime.No[0].CustomerNumber;
			status.articleId													:= g_Core.Services.CAR.Runtime.No[0].ArticleNumber;
			
			
			//////////////////////////////////////////////////////////
			//														//
			// Alarms (IoT Logger for Status)						//
			//														//
			//////////////////////////////////////////////////////////
			// Get all active alarms and convet them into JSON format
			oldJson := json;
			memset(ADR(json),0,SIZEOF(json));
			IF (adrAlarmCache > 0) THEN
				FOR i:= 0 TO 9 DO
					alarmId := (pAlarmCache[i].GroupID * 1000) + pAlarmCache[i].AlarmID;
					
					IF (alarmId > 0) THEN
						IF strlen(ADR(json)) = 0 THEN
							json := '[';
						ELSE
							strcat(ADR(json), ADR(','));
						END_IF
						// Parse the data into JSON format
						// - ID
						strcat(ADR(json), ADR('{ "id":'));
						memset(ADR(tmpString),0,SIZEOF(tmpString));
						itoa(alarmId, ADR(tmpString));
						strcat(ADR(json), ADR(tmpString));
						
						// - Name
						strcat(ADR(json), ADR(', "name":"'));
						strcat(ADR(json), ADR(pAlarmCache[i].DescAscii));
							
						// FLAG
						strcat(ADR(json), ADR('", "flag":'));
						memset(ADR(tmpString),0,SIZEOF(tmpString));
						itoa(pAlarmCache[i].Priority, ADR(tmpString));
						strcat(ADR(json), ADR(tmpString));
						
						// Close the element
						strcat(ADR(json), ADR('}'));
					END_IF
				END_FOR
				IF strlen(ADR(json)) > 0 THEN
					strcat(ADR(json), ADR(']'));
				END_IF
			END_IF
			IF 0 <> strcmp(ADR(json),ADR(oldJson)) THEN
				oldJson 			:= json;
				makeUpdateStatus 	:= TRUE;
			END_IF
			
			
			//			MpAlarmXQuery_0.MpLink 												:= ADR(gAlarmXFrameWork);
			//			MpAlarmXQuery_0.Enable 												:= xEnableQuery;
			//			MpAlarmXQuery_0.ErrorReset 											:= xResetQuery;
			//			MpAlarmXQuery_0.Language 											:= ADR('en');
			//			MpAlarmXQuery_0.Mode 												:= mpALARMX_QUERY_MODE_ALL;
			//			MpAlarmXQuery_0.Name 												:= ADR(strAlarmQuery);
			//			MpAlarmXQuery_0.Execute 											:= xExecuteQuery;
			//			MpAlarmXQuery_0.Next 												:= xNextQuery;
			//			MpAlarmXQuery_0();
			//			memset(ADR(json),0,SIZEOF(json));
			//			RETURN;
			//			IF MpAlarmXQuery_0.Info.AvailableSpace > 0 THEN
			//				json := '[';
			//				FOR queryElement := 0 TO MpAlarmXQuery_0.Info.AvailableSpace DO
			//					// We already got the PV updated from previous call.
			//					// Parse the data into JSON format
			//					// - ID
			//					strcat(ADR(json), ADR('{ "id":'));
			//					memset(ADR(tmpString),0,SIZEOF(tmpString));
			//					itoa(queryAlarmOutput.alarmCode, ADR(tmpString));
			//					strcat(ADR(json), ADR(tmpString));
			//					
			//					// - Name
			//					strcat(ADR(json), ADR(', "name":"'));
			//					memset(ADR(tmpLongString),0,SIZEOF(tmpLongString));
			//					tmpLongString												:= WSTRING_TO_STRING(queryAlarmOutput.alarmMessage);
			//					strcat(ADR(json), ADR(tmpLongString));
			//					
			//					// - Severity
			//					strcat(ADR(json), ADR('", "flag":'));
			//					memset(ADR(tmpString),0,SIZEOF(tmpString));
			//					itoa(queryAlarmOutput.alarmSeverity, ADR(tmpString));
			//					strcat(ADR(json), ADR(tmpString));
			//					
//					// Close the element
//					strcat(ADR(json), ADR('}'));
//					
//					// Check if there is more elements to read
//					IF MpAlarmXQuery_0.Info.HasMoreRows THEN
//						strcat(ADR(json), ADR(','));
//						
//						// Read next
//						MpAlarmXQuery_0.Execute 								:= TRUE;
//						MpAlarmXQuery_0.Next 									:= TRUE;
//						MpAlarmXQuery_0();
//					ELSE
//						EXIT;
//					END_IF
//				END_FOR
//				strcat(ADR(json), ADR(']'));
//			END_IF
			// Update the status for IoTLogger for all the alarms
			status.alarm														:= json;
			
			// Update the lane ID for the IoT logger
			status.index														:= 0;
			
			
			//////////////////////////////////////////////////////////
			//														//
			// Activate Logger (IoT Logger for Status)				//
			//														//
			//////////////////////////////////////////////////////////
			// Check if we need to log something to IoT
			IF makeUpdateStatus OR TON_StatusRefreshInterval.Q THEN
				IOTLogger_0.timeStamp											:= g_Core.Services.Time.Runtime.ISO;
				IOTLogger_0();
			END_IF
			
			
			//////////////////////////////////////////////////////////
			//////////////////////////////////////////////////////////
			//	IoT Logger for Data									//
			//////////////////////////////////////////////////////////
			//////////////////////////////////////////////////////////
			//////////////////////////////////////////////////////////
			//														//
			// Fill bucket for inlet								//
			//														//
			//////////////////////////////////////////////////////////
			// Master logging.
			FOR no := 0 TO numberPosInlet -1 DO
				// Get latest load ID
				bucketHoldingDataInlet[no].loadID								:= GetData(ServerNo := serverNoInlet, Type:= LOADID, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));

				// Check LoadID
				IF (((bucketHoldingDataInlet[no].loadID <> bucketHoldingDataInlet[no].oldValues.loadID) AND bucketHoldingDataInlet[no].loadID > 0)) THEN
					bucketHoldingDataInlet[no].oldValues.loadID					:= bucketHoldingDataInlet[no].loadID;
					bucketHoldingDataInlet[no].bucket.doMake					:= TRUE;
				END_IF	

				// new index Store data, empty & set new CAR info.				 
				IF (bucketHoldingDataInlet[no].bucket.doMake) THEN
					// This is the bucket.
					// BucketID is...
					// ID format = CCCCCCCAAAAAAAPP
					memset(ADR(bucketHoldingDataInlet[no].bucket.ID),0,SIZEOF(bucketHoldingDataInlet[no].bucket.ID));
					// - Customer ID
					memset(ADR(tmpString),0,SIZEOF(tmpString));
					itoa(GetData(ServerNo := serverNoInlet, Type:= CUSTOMER_NUMBER, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)) + 1000000, ADR(tmpString));
					strcat(ADR(bucketHoldingDataInlet[no].bucket.ID),ADR(tmpString));
					// - Article ID
					memset(ADR(tmpString),0,SIZEOF(tmpString));
					itoa(GetData(ServerNo := serverNoInlet, Type:= ARTICLE_NUMBER, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)) + 1000000, ADR(tmpString));
					strcat(ADR(bucketHoldingDataInlet[no].bucket.ID),ADR(tmpString));
					// - Process ID
					memset(ADR(tmpString),0,SIZEOF(tmpString));
					itoa(GetData(ServerNo := serverNoInlet, Type:= RECIPE_NUMBER, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)), ADR(tmpString));
					IF STRING_TO_USINT(tmpString) < 10 THEN
						strcat(ADR(bucketHoldingDataInlet[no].bucket.ID),ADR('0'));
					END_IF
					strcat(ADR(bucketHoldingDataInlet[no].bucket.ID),ADR(tmpString));
					
					// Access the bucket, or make a bucket
					getItem_0(adrKey := ADR(bucketHoldingDataInlet[no].bucket.ID), trackIdent := initTracker_0.trackIdent);
					IF (getItem_0.value = 0) THEN
						IF (bucketsUsed = (SIZEOF(buckets) / SIZEOF(buckets[0]))) THEN
							// We got a problem
							isError 											:= TRUE;				
						ELSE
							// Make a bucket
							addItem_0(adrKey := ADR(bucketHoldingDataInlet[no].bucket.ID),trackIdent := initTracker_0.trackIdent, value := ADR(buckets[bucketsUsed]));
							IF (addItem_0.status <> 0) THEN
								hashAddErrors 									:= hashAddErrors + 1;
							END_IF 
							bucketHoldingDataInlet[no].bucket.Ident				:= ADR(buckets[bucketsUsed]);
							buckets[bucketsUsed].bucketId 						:= bucketHoldingDataInlet[no].bucket.ID;
							bucketsUsed 										:= bucketsUsed + 1;
						END_IF
					ELSE
						// Same combination, use the same bucket
						totalLoadFactor 										:= totalLoadFactor + getItem_0.level;
						bucketHoldingDataInlet[no].bucket.Ident 				:= getItem_0.value;
					END_IF
					
					// ACCESS Bucket.
					pBucket ACCESS bucketHoldingDataInlet[no].bucket.Ident;
					// Bucket added, add metadata.
					pBucket.index[no].processCodeId 							:= 1 + UDINT_TO_USINT(GetData(ServerNo := serverNoInlet, Type:= RECIPE_NUMBER, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)));
					pBucket.index[no].articleId 								:= GetData(ServerNo := serverNoInlet, Type:= ARTICLE_NUMBER,	Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					pBucket.index[no].customerId								:= GetData(ServerNo := serverNoInlet, Type:= CUSTOMER_NUMBER, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					pBucket.index[no].processNorm 								:= GetData(ServerNo := serverNoInlet, Type:= NORM, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					pBucket.index[no].index 									:= no + 1;
					pBucket.accessTimes 										:= pBucket.accessTimes + 1;
					// Set no flow time out
					bucketHoldingDataInlet[no].TON_NoFlow10ms.PT				:= (LIMIT(10, g_RCfg[pBucket.index[no].processCodeId].NoFlowTimeout, 3600))*100;

					// Get initial values...
					bucketHoldingDataInlet[no].oldValues.productionCount		:= GetData(ServerNo := serverNoInlet, Type:= PRODUCTION_PRODUCTION, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					bucketHoldingDataInlet[no].oldValues.repairCount			:= GetData(ServerNo := serverNoInlet, Type:= PRODUCTION_REPAIR, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					bucketHoldingDataInlet[no].oldValues.reWashCount			:= GetData(ServerNo := serverNoInlet, Type:= PRODUCTION_REWASH, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					bucketHoldingDataInlet[no].oldValues.qualityCount			:= GetData(ServerNo := serverNoInlet, Type:= PRODUCTION_QUALITY, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					bucketHoldingDataInlet[no].oldValues.timeCount				:= GetData(ServerNo := serverNoInlet, Type:= RCP_LOGGED_TIME, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					
					// Get old bucket values if exists.
					bucketHoldingDataInlet[no].bucket.doMake					:= FALSE;
				END_IF
				
				IF (bucketHoldingDataInlet[no].bucket.Ident > 0) THEN
					pBucket ACCESS bucketHoldingDataInlet[no].bucket.Ident;
					// Get current values
					currentProductionCount										:= GetData(ServerNo := serverNoInlet, Type:= PRODUCTION_PRODUCTION, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					currentRepairCount											:= GetData(ServerNo := serverNoInlet, Type:= PRODUCTION_REPAIR, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					currentReWashCount 											:= GetData(ServerNo := serverNoInlet, Type:= PRODUCTION_REWASH, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					currentQualityCount											:= GetData(ServerNo := serverNoInlet, Type:= PRODUCTION_QUALITY, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					currentTimeCount											:= GetData(ServerNo := serverNoInlet, Type:= RCP_LOGGED_TIME, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
				
					pBucket.index[no].productionCountIn							:= GetDifferenceCount(currentProductionCount, bucketHoldingDataInlet[no].oldValues.productionCount, pBucket.index[no].productionCountIn);
					pBucket.index[no].repairCount								:= GetDifferenceCount(currentRepairCount, bucketHoldingDataInlet[no].oldValues.repairCount, pBucket.index[no].repairCount);
					pBucket.index[no].rewashCount								:= GetDifferenceCount(currentReWashCount, bucketHoldingDataInlet[no].oldValues.reWashCount, pBucket.index[no].rewashCount);
					pBucket.index[no].qualityCount								:= GetDifferenceCount(currentQualityCount, bucketHoldingDataInlet[no].oldValues.qualityCount, pBucket.index[no].qualityCount);
					pBucket.index[no].durationIn								:= GetDifferenceCount(currentTimeCount, bucketHoldingDataInlet[no].oldValues.timeCount, pBucket.index[no].durationIn);
					
					// No flow count logic.
					IF (currentProductionCount = bucketHoldingDataInlet[no].oldValues.productionCount) AND g_Core.System.Runtime.isRunning THEN
						// Production is the same the machine is running, No flow detected since last run, start timer.
						bucketHoldingDataInlet[no].TON_NoFlow10ms.IN 			:= TRUE;
					ELSE
						bucketHoldingDataInlet[no].TON_NoFlow10ms.IN			:= FALSE;
					END_IF
					bucketHoldingDataInlet[no].TON_NoFlow10ms();
					
					// Noflow calculation, now flow is active, add old bucket data with new added time.
					IF bucketHoldingDataInlet[no].TON_NoFlow10ms.Q THEN
						pBucket.index[no].durationNoFlow 						:= pBucket.index[no].durationNoFlow + addSecond;
					END_IF
					
					// Save old values, to detect difference
					bucketHoldingDataInlet[no].oldValues.productionCount		:= currentProductionCount;
					bucketHoldingDataInlet[no].oldValues.repairCount			:= currentRepairCount;
					bucketHoldingDataInlet[no].oldValues.reWashCount			:= currentReWashCount;
					bucketHoldingDataInlet[no].oldValues.qualityCount			:= currentQualityCount;
					bucketHoldingDataInlet[no].oldValues.timeCount				:= currentTimeCount;
				END_IF
			END_FOR
			
			
			//////////////////////////////////////////////////////////
			//														//
			// Fill bucket for outlet								//
			//														//
			//////////////////////////////////////////////////////////
			// Slave logging.
			FOR no := 0 TO numberPosOutlet -1 DO
				// Get latest load ID
				bucketHoldingDataOutlet[no].loadID								:= GetData(ServerNo := serverNoOutlet, Type:= LOADID, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));

				// Check LoadID
				IF (((bucketHoldingDataOutlet[no].loadID <> bucketHoldingDataOutlet[no].oldValues.loadID) AND bucketHoldingDataOutlet[no].loadID > 0)) THEN
					bucketHoldingDataOutlet[no].oldValues.loadID				:= bucketHoldingDataOutlet[no].loadID;
					bucketHoldingDataOutlet[no].bucket.doMake					:= TRUE;
				END_IF	

				// new index Store data, empty & set new CAR info.				 
				IF (bucketHoldingDataOutlet[no].bucket.doMake) THEN
					// This is the bucket.
					// BucketID is...
					// ID format = CCCCCCCAAAAAAAPP
					memset(ADR(bucketHoldingDataOutlet[no].bucket.ID),0,SIZEOF(bucketHoldingDataOutlet[no].bucket.ID));
					// - Customer ID
					memset(ADR(tmpString),0,SIZEOF(tmpString));
					itoa(GetData(ServerNo := serverNoOutlet, Type:= CUSTOMER_NUMBER, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)) + 1000000, ADR(tmpString));
					strcat(ADR(bucketHoldingDataOutlet[no].bucket.ID),ADR(tmpString));
					// - Article ID
					memset(ADR(tmpString),0,SIZEOF(tmpString));
					itoa(GetData(ServerNo := serverNoOutlet, Type:= ARTICLE_NUMBER, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)) + 1000000, ADR(tmpString));
					strcat(ADR(bucketHoldingDataOutlet[no].bucket.ID),ADR(tmpString));
					// - Process ID
					memset(ADR(tmpString),0,SIZEOF(tmpString));
					itoa(GetData(ServerNo := serverNoOutlet, Type:= RECIPE_NUMBER, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)), ADR(tmpString));
					IF STRING_TO_USINT(tmpString) < 10 THEN
						strcat(ADR(bucketHoldingDataOutlet[no].bucket.ID),ADR('0'));
					END_IF
					strcat(ADR(bucketHoldingDataOutlet[no].bucket.ID),ADR(tmpString));
					
					// Access the bucket, or make a bucket
					getItem_0(adrKey := ADR(bucketHoldingDataOutlet[no].bucket.ID), trackIdent := initTracker_0.trackIdent);
					IF (getItem_0.value = 0) THEN
						IF (bucketsUsed = (SIZEOF(buckets) / SIZEOF(buckets[0]))) THEN
							// We got a problem
							isError 											:= TRUE;				
						ELSE
							// Make a bucket
							addItem_0(adrKey := ADR(bucketHoldingDataOutlet[no].bucket.ID),trackIdent := initTracker_0.trackIdent, value := ADR(buckets[bucketsUsed]));
							IF (addItem_0.status <> 0) THEN
								hashAddErrors 									:= hashAddErrors + 1;
							END_IF 
							bucketHoldingDataOutlet[no].bucket.Ident			:= ADR(buckets[bucketsUsed]);
							buckets[bucketsUsed].bucketId 						:= bucketHoldingDataOutlet[no].bucket.ID;
							bucketsUsed 										:= bucketsUsed + 1;
						END_IF
					ELSE
						// Same combination, use the same bucket
						totalLoadFactor 										:= totalLoadFactor + getItem_0.level;
						bucketHoldingDataOutlet[no].bucket.Ident 				:= getItem_0.value;
					END_IF
					
					// ACCESS Bucket.
					pBucket ACCESS bucketHoldingDataOutlet[no].bucket.Ident;
					// Bucket added, add metadata.
					pBucket.index[no].processCodeId 							:= 1 + UDINT_TO_USINT(GetData(ServerNo := serverNoOutlet, Type:= RECIPE_NUMBER, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)));
					pBucket.index[no].articleId 								:= GetData(ServerNo := serverNoOutlet, Type:= ARTICLE_NUMBER,	Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					pBucket.index[no].customerId								:= GetData(ServerNo := serverNoOutlet, Type:= CUSTOMER_NUMBER, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					pBucket.index[no].processNorm 								:= GetData(ServerNo := serverNoOutlet, Type:= NORM, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					pBucket.index[no].index 									:= no + 1;
					pBucket.accessTimes 										:= pBucket.accessTimes + 1;

					// Get initial values...
					bucketHoldingDataOutlet[no].oldValues.productionCount		:= GetData(ServerNo := serverNoOutlet, Type:= PRODUCTION_PRODUCTION, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					bucketHoldingDataOutlet[no].oldValues.repairCount			:= GetData(ServerNo := serverNoOutlet, Type:= PRODUCTION_REPAIR, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					bucketHoldingDataOutlet[no].oldValues.reWashCount			:= GetData(ServerNo := serverNoOutlet, Type:= PRODUCTION_REWASH, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					bucketHoldingDataOutlet[no].oldValues.qualityCount			:= GetData(ServerNo := serverNoOutlet, Type:= PRODUCTION_QUALITY, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					bucketHoldingDataOutlet[no].oldValues.timeCount				:= GetData(ServerNo := serverNoOutlet, Type:= RCP_LOGGED_TIME, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					
					// Get old bucket values if exists.
					bucketHoldingDataOutlet[no].bucket.doMake					:= FALSE;
				END_IF
				
				IF (bucketHoldingDataOutlet[no].bucket.Ident > 0) THEN
					pBucket ACCESS bucketHoldingDataOutlet[no].bucket.Ident;
					// Get current values
					currentProductionCount										:= GetData(ServerNo := serverNoOutlet, Type:= PRODUCTION_PRODUCTION, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					currentTimeCount											:= GetData(ServerNo := serverNoOutlet, Type:= RCP_LOGGED_TIME, Lane:= no+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
				
					pBucket.index[no].productionCountOut						:= GetDifferenceCount(currentProductionCount, bucketHoldingDataOutlet[no].oldValues.productionCount, pBucket.index[no].productionCountOut);
					pBucket.index[no].durationOut								:= GetDifferenceCount(currentTimeCount, bucketHoldingDataOutlet[no].oldValues.timeCount, pBucket.index[no].durationOut);
					
					// Save old values, to detect difference
					bucketHoldingDataOutlet[no].oldValues.productionCount		:= currentProductionCount;
					bucketHoldingDataOutlet[no].oldValues.timeCount				:= currentTimeCount;
				END_IF
			END_FOR
			
			
			//////////////////////////////////////////////////////////
			//														//
			// Check for hour change and signal to update IoT Logger//
			//														//
			//////////////////////////////////////////////////////////
			CASE hourStep OF
				0:
					IF (g_Core.Services.Time.Runtime.Split.minute = 59 AND g_Core.Services.Time.Runtime.Split.second = 59) THEN
						hourStep 												:= 1;
						makeUpdateData											:= TRUE;
					END_IF
				1:
					IF (g_Core.Services.Time.Runtime.Split.minute = 0 AND g_Core.Services.Time.Runtime.Split.second = 0) THEN
						hourStep 												:= 0;
					END_IF
			END_CASE
			
			
			// Trigger log data sending
			IF (TON_DataRefreshInterval.Q OR (bucketsUsed = UDINT_TO_INT(initTracker_0.poolSize)) OR edgeNegISControlPlc) THEN
				// Get ID for Bucket, new or old. 
				makeUpdateData 													:= TRUE;
			END_IF
			
			
			//////////////////////////////////////////////////////////
			//														//
			// Activate Logger (IoT Logger for Data)				//
			//														//
			//////////////////////////////////////////////////////////
			IF (makeUpdateData) THEN
				dataLoggerUpdateCount 											:= dataLoggerUpdateCount + 1;
			
				// Check if any elements in the buckets has been used
				IF (bucketsUsed > 0) THEN
					FOR i := 0 TO bucketsUsed-1 DO
						// Access the bucket
						pBucket ACCESS ADR(buckets[i]);
						
						// For each lane, parse the data if any is pressent
						FOR no := 0 TO 9 DO
							IF (pBucket.index[no].index = 0) THEN
								EXIT;
							ELSE
								data 											:= pBucket.index[no];
								
								// Check if this bucket has production time in it
								IF data.durationIn > 0 OR data.durationOut > 0 THEN
									// Push new data to IOT
									IOTLogger_1.timeStamp 						:= g_Core.Services.Time.Runtime.ISO;
									IOTLogger_1();
								END_IF
							END_IF
						END_FOR
						
						// Clear the bucket, and move to the next one
						memset(ADR(pBucket), 0, SIZEOF(pBucket));
					END_FOR
					
					// Clear the bucket buffer completly
					bucketsUsed 												:= 0;
					memset(ADR(buckets), 0, SIZEOF(buckets));
					clearTracker_0(trackIdent := initTracker_0.trackIdent);
				END_IF
				
				// Make new buckets for inlet and outlet
				// Set command to make initial bucket
				FOR no := 0 TO numberPosInlet -1 DO
					bucketHoldingDataInlet[no].bucket.doMake					:= TRUE;
				END_FOR
				
				FOR no := 0 TO numberPosOutlet -1 DO
					bucketHoldingDataOutlet[no].bucket.doMake					:= TRUE;
				END_FOR
			END_IF	
	END_CASE
	
END_PROGRAM
