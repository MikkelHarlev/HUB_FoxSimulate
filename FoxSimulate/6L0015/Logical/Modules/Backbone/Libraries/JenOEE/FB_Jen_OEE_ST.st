
(* Jensen OEE Data Average for the last hour of production *)
FUNCTION_BLOCK FB_Jen_OEE_ST
	
	//sampleRate := 3600/SAMPLES_PR_HOUR;
	
	IF enable THEN
		
		(********************************************************************************************
		*										Save new data set									*
		*********************************************************************************************)
		//Check to see if a new data sample should be saved
		IF saveSample THEN
			status := ERR_FUB_BUSY;
			
			IF (DT_TO_UDINT(OEESamples[Head].timeStamp) > 0) THEN	//don't increment the head index there is no saved data on the head index position.
				//Calculate the index of the new sample data to be saved
				Head := (Head + 1) MOD ST_BUFFER_SIZE;
			END_IF
			
			//Save OEE data
			OEESamples[Head].OEEData	:= data;

			//save the time stamp
			OEESamples[Head].timeStamp	:= currentTime;
			
			//reset input to indicate "operation done"
			memset(ADR(data),0,SIZEOF(data));
			saveSample	:= FALSE;
		END_IF		
			
		
		(************************************************************************************************************
		*							Calculate the avarage OEE value over the last hour								*
		*************************************************************************************************************)
		
		IF extractOEEData <> 0 THEN
			
			status := ERR_FUB_BUSY;
			
			//Set the Tail index of the buffer to the newest sample index prior to searching for the oldest sample index
			Tail := Head;
			
			//Find the index of the oldest sample within the specified extract time
			FOR idx := 0 TO (SIZEOF(OEESamples)/SIZEOF(OEESamples[0]))-1 DO
				IF ((DT_TO_UDINT(OEESamples[idx].timeStamp)) > (DT_TO_UDINT(currentTime) - TIME_TO_UDINT(extractOEEData)/1000)) THEN	//Check if the sample time stamp is from within last the specified extract time 
					IF ((DT_TO_UDINT(OEESamples[idx].timeStamp)) < (DT_TO_UDINT(OEESamples[Tail].timeStamp))) THEN				//Check if the sample time stamp is older than the oldest time stamp found so far 
						
						Tail	:= idx;																	//If it is, then update the index for the oldest sample within the hour avarage
						
					END_IF;
				END_IF;
			END_FOR;
			
			//Availability calculations
			tempRT		:= OEESamples[Head].OEEData.runTime - OEESamples[Tail].OEEData.runTime;
			tempST		:= OEESamples[Head].OEEData.stopTime.total - OEESamples[Tail].OEEData.stopTime.total;

			tempPPT 	:= tempRT + tempST;
			
			//Availability output
			IF tempPPT <= 0 THEN
				averageOEEValues.averageAvailability := 1;
			ELSE
				averageOEEValues.averageAvailability := DINT_TO_REAL(tempRT) / DINT_TO_REAL(tempPPT);
			END_IF
			
			
			
			//Performance calculations
			memset(ADR(OEEPerfCalculation),0,SIZEOF(OEEPerfCalculation));		//reset the account of registered Optimal Product Count (OPC)
			
			FOR idx := Tail TO Head BY 1 DO
				IF idx = ST_BUFFER_SIZE THEN
					idx := 0;
				END_IF
				
				IF idx = Tail THEN																	//Last valid sample. Works as a baseline of the diff. calculations of the actualProductCount 
					OEEPerfCalculation[0].idealCycleTime		:= OEESamples[idx].OEEData.idealCycleTime;
//					OEEPerfCalculation[0].timeProcessed			:= 0;
					OEEPerfCalculation[0].SUM_actualProdCount	:= 0;
					numOfICT									:= 1;
					prevIdx										:= Tail;
					
				ELSE																				//Calculation of the rest of the samples
					
					isICTregistered := FALSE;														//reset the test if the Optimal Product Count (OPC) has been registered.
					
					FOR i := 0 TO numOfICT - 1 DO													//Look through the registered OPCs
						IF OEEPerfCalculation[i].idealCycleTime = OEESamples[idx].OEEData.idealCycleTime THEN	//if the ICT of the current sample is already registered, add the sample data to the registered data set.
							isICTregistered := TRUE;
							//OEEPerfCalculation[i].timeProcessed			:= OEEPerfCalculation[i].timeProcessed	+ OEESamples[idx].OEEData.plannedProcTime - OEESamples[prevIdx].OEEData.plannedProcTime;
							OEEPerfCalculation[i].SUM_actualProdCount	:= OEEPerfCalculation[i].SUM_actualProdCount + OEESamples[idx].OEEData.actualProdCount - OEESamples[prevIdx].OEEData.actualProdCount;
						END_IF
					END_FOR
					
					IF NOT isICTregistered THEN																			//if the OPC is not registered already, add the OPC to the register.
						//OEEPerfCalculation[numOfOPC].runTime				:= OEEPerfCalculation[numOfOPC].runTime + OEESamples[idx].OEEData. - OEESamples[prevIdx].OEEData.plannedProcTime;
						OEEPerfCalculation[numOfICT].SUM_actualProdCount	:= OEESamples[idx].OEEData.actualProdCount - OEESamples[prevIdx].OEEData.actualProdCount;
						OEEPerfCalculation[numOfICT].idealCycleTime			:= OEESamples[idx].OEEData.idealCycleTime;
						numOfICT											:= numOfICT + 1;
					END_IF
					
					prevIdx := idx;
					
				END_IF
				
			END_FOR
			

			tempOptimalProdTime		:= 0;
			tempActualProdCount		:= 0;
			FOR i := 0 TO numOfICT - 1 DO

				tempOptimalProdTime		:= tempOptimalProdTime + (OEEPerfCalculation[i].idealCycleTime * UDINT_TO_REAL(OEEPerfCalculation[i].SUM_actualProdCount));
				tempActualProdCount		:= tempActualProdCount + UDINT_TO_REAL(OEEPerfCalculation[i].SUM_actualProdCount);

			END_FOR

			
			//Quality calculations
			tempGPC		:= UDINT_TO_REAL(OEESamples[Head].OEEData.goodProdCount - OEESamples[Tail].OEEData.goodProdCount);
			tempTPC		:= UDINT_TO_REAL(OEESamples[Head].OEEData.totalProdCount - OEESamples[Tail].OEEData.totalProdCount);
			
			
			(************************************************************************************************************************
			*													Outputs																*
			*************************************************************************************************************************)
			

			//Performance output
			IF tempRT = 0 THEN
				averageOEEValues.averagePerformance := 1;
			ELSE
				averageOEEValues.averagePerformance		:= tempOptimalProdTime / DINT_TO_REAL(tempRT);
			END_IF
			
			//Quality output
			IF tempTPC = 0 THEN
				averageOEEValues.averageQuality := 1;
			ELSE
				averageOEEValues.averageQuality	:= tempGPC/tempTPC;
			END_IF
			
			
			
			//Delta times for the average data output
			averageOEEData.OEEData.runTime						:= tempRT;
			averageOEEData.OEEData.stopTime.total				:= tempST;
			averageOEEData.OEEData.stopTime.internal			:= OEESamples[Head].OEEData.stopTime.internal - OEESamples[Tail].OEEData.stopTime.internal;
			averageOEEData.OEEData.stopTime.externalUpstream	:= OEESamples[Head].OEEData.stopTime.externalUpstream - OEESamples[Tail].OEEData.stopTime.externalUpstream;
			averageOEEData.OEEData.stopTime.externalDownstream	:= OEESamples[Head].OEEData.stopTime.externalDownstream - OEESamples[Tail].OEEData.stopTime.externalDownstream;
			averageOEEData.OEEData.waitTime.internal			:= OEESamples[Head].OEEData.waitTime.internal - OEESamples[Tail].OEEData.waitTime.internal;
			averageOEEData.OEEData.waitTime.externalUpstream	:= OEESamples[Head].OEEData.waitTime.externalUpstream - OEESamples[Tail].OEEData.waitTime.externalUpstream;
			averageOEEData.OEEData.waitTime.externalDownstream	:= OEESamples[Head].OEEData.waitTime.externalDownstream - OEESamples[Tail].OEEData.waitTime.externalDownstream;
			
			//Delta production data output
			averageOEEData.OEEData.actualProdCount				:= OEESamples[Head].OEEData.actualProdCount - OEESamples[Tail].OEEData.actualProdCount;
			IF tempActualProdCount = 0 THEN
				averageOEEData.OEEData.idealCycleTime			:= 0;
			ELSE
				averageOEEData.OEEData.idealCycleTime			:= averageOEEValues.averagePerformance * DINT_TO_REAL(tempRT)/tempActualProdCount;
			END_IF
			averageOEEData.OEEData.totalProdCount				:= OEESamples[Head].OEEData.totalProdCount - OEESamples[Tail].OEEData.totalProdCount;
			averageOEEData.OEEData.goodProdCount				:= OEESamples[Head].OEEData.goodProdCount - OEESamples[Tail].OEEData.goodProdCount;
			
			//Timestamp and duration of the delta average output
			averageOEEData.timeStamp							:= OEESamples[Head].timeStamp;
			averageOEEData.duration								:= UDINT_TO_TIME((DT_TO_UDINT(OEESamples[Head].timeStamp) - DT_TO_UDINT(OEESamples[Tail].timeStamp))*1000);
			//averageOEEData.duration								:= extractOEEData;
			
			extractOEEData	:= 0;
			
		END_IF	//end calculate OEE
		
		status := 0;
	ELSE
		status := ERR_FUB_ENABLE_FALSE;
	END_IF	//end enable
	
END_FUNCTION_BLOCK
