
(* TODO: Add your comment here *)
FUNCTION_BLOCK FB_Jen_OEE_LT
	
	IF enable THEN
		
		
		(********************************************************************************************
		*									Save new data set										*
		*********************************************************************************************)
		//Check to see if a new data sample should be saved
		IF (saveSample) THEN
			status := ERR_FUB_BUSY;
				
			IF (DT_TO_UDINT(OEESamples[Head].timeStamp) > 0) THEN	//don't increment the head index there is no saved data on the head index position.
				//Calculate the index of the new sample data to be saved
				Head := (Head + 1) MOD LT_BUFFER_SIZE;
			END_IF
				
			//Save OEE data
			OEESamples[Head]	:= data;
			
			//reset input to indicate "operation done"
			memset(ADR(data),0,SIZEOF(data));
			saveSample	:= FALSE;
			
		END_IF			
		
		
		
		(************************************************************************************************************
		*							Calculate the avarage OEE for the selected period of time						*
		*************************************************************************************************************)
		//if extractOEEData is set, a new calculation of the OEE values has been requested
		IF extractOEEData <> 0 THEN
				
			status := ERR_FUB_BUSY;
				
			//Set the Tail index of the buffer to the newest sample index prior to searching for the oldest sample index within the given timeframe
			Tail := Head;
				
			//Find the index of the oldest sample within the specified extract time
			FOR idx := 0 TO (SIZEOF(OEESamples)/SIZEOF(OEESamples[0]))-1 DO
				IF ((DT_TO_UDINT(OEESamples[idx].timeStamp)) > (DT_TO_UDINT(OEESamples[Head].timeStamp) - TIME_TO_UDINT(extractOEEData)/1000)) AND		//Check if the sample time stamp is from within last the specified extract time 
					((DT_TO_UDINT(OEESamples[idx].timeStamp)) < (DT_TO_UDINT(OEESamples[Tail].timeStamp))) THEN							//Check if the sample time stamp is older than the oldest time stamp found so far 
							
					Tail	:= idx;																										//If it is, then update the index for the oldest sample within the hour avarage
							
					
				END_IF;
			END_FOR;
				
			//reset the calculation variables
			//Availability calculations
			memset(ADR(OEEAvailCalculation),0,SIZEOF(OEEAvailCalculation));
			
			//Performance calculations
			memset(ADR(OEEPerfCalculation),0,SIZEOF(OEEPerfCalculation));	
			
			//Quality calculations
			memset(ADR(OEEQualCalculation),0,SIZEOF(OEEQualCalculation));		
			
			//output variables
			memset(ADR(averageOEEData),0,SIZEOF(averageOEEData));		
			
			//Calculations
			FOR idx := Tail TO Head BY 1 DO
				IF idx = LT_BUFFER_SIZE THEN	//check if we reach the end of the sample buffer
					idx := 0;					//if so, wrap the index to the bottom to form a ring buffer effect
				END_IF
					
				//since the input is assumed to be Delta values (only changes/values that occured within the sample duration), a simple summing operation is all that is needed to get the correct values for the OEE
				
				//Availability summing
				OEEAvailCalculation.runTime			 				:= OEEAvailCalculation.runTime + OEESamples[idx].OEEData.runTime;
				OEEAvailCalculation.stopTime						:= OEEAvailCalculation.stopTime + OEESamples[idx].OEEData.stopTime.total;
				
				averageOEEData.OEEData.stopTime.total				:= averageOEEData.OEEData.stopTime.total + OEESamples[idx].OEEData.stopTime.total;
				averageOEEData.OEEData.stopTime.internal			:= averageOEEData.OEEData.stopTime.internal + OEESamples[idx].OEEData.stopTime.internal;
				averageOEEData.OEEData.stopTime.externalUpstream	:= averageOEEData.OEEData.stopTime.externalUpstream + OEESamples[idx].OEEData.stopTime.externalUpstream;
				averageOEEData.OEEData.stopTime.externalDownstream	:= averageOEEData.OEEData.stopTime.externalDownstream + OEESamples[idx].OEEData.stopTime.externalDownstream;
				
				averageOEEData.OEEData.waitTime.total				:= averageOEEData.OEEData.waitTime.total + OEESamples[idx].OEEData.waitTime.total;
				averageOEEData.OEEData.waitTime.internal			:= averageOEEData.OEEData.waitTime.internal + OEESamples[idx].OEEData.waitTime.internal;
				averageOEEData.OEEData.waitTime.externalUpstream	:= averageOEEData.OEEData.waitTime.externalUpstream + OEESamples[idx].OEEData.waitTime.externalUpstream;
				averageOEEData.OEEData.waitTime.externalDownstream	:= averageOEEData.OEEData.waitTime.externalDownstream + OEESamples[idx].OEEData.waitTime.externalDownstream;
				
				//Performance summing
				OEEPerfCalculation.idealCycleTime			:= OEEPerfCalculation.idealCycleTime + OEESamples[idx].OEEData.idealCycleTime * UDINT_TO_REAL(OEESamples[idx].OEEData.actualProdCount); //sum of #products times idealCycleTime. Not IdealCycleTime.
				OEEPerfCalculation.SUM_actualProdCount		:= OEEPerfCalculation.SUM_actualProdCount + OEESamples[idx].OEEData.actualProdCount;
				OEEPerfCalculation.runTime					:= OEEAvailCalculation.runTime;
				
				//Quality summing
				OEEQualCalculation.goodProdCount			:= OEEQualCalculation.goodProdCount + OEESamples[idx].OEEData.goodProdCount;
				OEEQualCalculation.totalProdCount			:= OEEQualCalculation.totalProdCount + OEESamples[idx].OEEData.totalProdCount;
					
			END_FOR
				
	
			(************************************************************************************************************************
			*													Outputs																*
			*************************************************************************************************************************)
				
			//Availability output
			IF OEEAvailCalculation.runTime = 0 THEN
				averageOEEValues.averageAvailability := 1;
			ELSE
				averageOEEValues.averageAvailability := DINT_TO_REAL(OEEAvailCalculation.runTime)/(DINT_TO_REAL(OEEAvailCalculation.runTime) + DINT_TO_REAL(OEEAvailCalculation.stopTime));
			END_IF
			
			//Performance output
			IF OEEPerfCalculation.runTime = 0 THEN
				averageOEEValues.averagePerformance := 1;
			ELSE
				averageOEEValues.averagePerformance		:= OEEPerfCalculation.idealCycleTime / DINT_TO_REAL(OEEPerfCalculation.runTime);
			END_IF
				
			//Quality output
			IF OEEQualCalculation.totalProdCount = 0 THEN
				averageOEEValues.averageQuality := 1;
			ELSE
				averageOEEValues.averageQuality	:= DINT_TO_REAL(OEEQualCalculation.goodProdCount)/DINT_TO_REAL(OEEQualCalculation.totalProdCount);
			END_IF
				
			
			//Delta times for the average data output
			averageOEEData.OEEData.runTime						:= OEEAvailCalculation.runTime;
				
			//Delta production data output
			averageOEEData.OEEData.actualProdCount				:= OEEPerfCalculation.SUM_actualProdCount;
			IF OEEPerfCalculation.SUM_actualProdCount <> 0 THEN
				averageOEEData.OEEData.idealCycleTime				:= averageOEEValues.averagePerformance * DINT_TO_REAL(OEEAvailCalculation.runTime)/UDINT_TO_REAL(OEEPerfCalculation.SUM_actualProdCount);
			ELSE
				averageOEEData.OEEData.idealCycleTime				:= 0;
			END_IF
			averageOEEData.OEEData.totalProdCount				:= OEEQualCalculation.totalProdCount;
			averageOEEData.OEEData.goodProdCount				:= OEEQualCalculation.goodProdCount;
				
			//Timestamp and duration of the delta average output
			averageOEEData.timeStamp							:= OEESamples[Head].timeStamp;
			averageOEEData.duration								:= DINT_TO_TIME(OEEPerfCalculation.runTime*1000);
			//averageOEEData.duration								:= extractOEEData;
			
			
			extractOEEData	:= 0;
				
		END_IF	//end calculate OEE
			
			status := 0;
	ELSE	//not enabled
		status := ERR_FUB_ENABLE_FALSE;
	END_IF	//end enable
	
END_FUNCTION_BLOCK
