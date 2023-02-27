FUNCTION_BLOCK FB_SpeedCalculation
	(*--------------------------------------------------------------------------------------------------------------------

		Author:			Jensen Denmark
	
		Function:    	SpeedCalculation
	
		Description: 	Function to be used for meassuring speed
	
		History:		07-07-2005		V0.01		CRT
							04-12-2007		V1.00		AHO
							11-03-2010		V2.00		AHO		Bug fix: Set Speed_dMeter_Min /Speed_dFeet_Min /Speed_HMI to 0 if timeout
							02-04-2012		V3.00		AHO		Resolution changed, Cyclictime added
																														  
	--------------------------------------------------------------------------------------------------------------------
	Inputs:
					WheelCounter	UDINT 	Counting wheel signals
					Resolution 		UINT 	Resolution of measuring wheel (0,01mm pr. puls) (300=3mm pr. puls)
					CyclicTime 		REAL Task Cyclic Time 2,8/3 ms
					TimeCounter 	UDINT 	Counting time 
					MeasuringType 	USINT 	1: Pulse measurement
																		2: Time measurement
					MeasureDif 		UDINT 	Difference between either pulses or time 						
					FilterValue 	USINT 	No. of measurements that is used to average 
					OutputUnit 		USINT 	1: dMeter/minute
																2: dFeet/minute 
																3: New
		Outputs:
					Speed 				UDINT 	Speed readout in dMeter/minute (Old)
					Speed_dMeter_Min 	UDINT 	Speed readout in dMeter/minute
					Speed_dFeet_Min 	UDINT 	Speed readout in dFeet/minute 
					Speed_HMI 			REAL 	Speed readout in actual format (Meter/minute or Feet/minute) 
					FeetDisable			USINT	Feet/minute Disable/Enable (HMI)
					MeterDisable		USINT	Meter/minute Disable/Enable (HMI)
					Status 				UINT 	Status of function  
	--------------------------------------------------------------------------------------------------------------------*)
	Status := 0;
	
	IF (MeasureType <> 1) AND (MeasureType <> 2) THEN
		Status := 1;
	ELSIF (FilterValue > 16) THEN
		Status := 2;
	ELSIF (OutputUnit <> 1) AND (OutputUnit <> 2) THEN
		Status := 3;
	ELSIF (CyclicTime = 0) THEN
		Status := 4;
	END_IF
	
	IF Status = 0 THEN
		// No error 
		IF TimeOut = 0 THEN
			TimeOut := 100;
		END_IF
	
		IF WheelCounter <> OldCount THEN
			Counter := 0;
		END_IF
		OldCount := WheelCounter;
	
		IF Counter > TimeOut THEN
			Speed := 0;
			Speed_dMeter_Min := 0;
			Speed_dFeet_Min := 0;
			Speed_HMI := 0;
		ELSE
			Counter := Counter + 1;
		END_IF
	
		// Check which Filtering Type should be used 
		SpdCalcDone := FALSE;
		IF (MeasureType = 1) THEN
			PulseDif := WheelCounter - OldWheelCounter;
			IF (PulseDif > MeasureDif) THEN
				TimeDif := TimeCounter - OldTimeCounter;
				Speed := REAL_TO_UDINT(UDINT_TO_REAL(PulseDif*Resolution*2) / (UDINT_TO_REAL(TimeDif)*(CyclicTime/3))); // 0,1mm/min 
				OldWheelCounter := WheelCounter;
				OldTimeCounter := TimeCounter;
				SpdCalcDone := TRUE;
			END_IF
		ELSIF (MeasureType = 2) THEN
			TimeDif := TimeCounter - OldTimeCounter;
			IF (TimeDif > MeasureDif) THEN
				PulseDif := WheelCounter - OldWheelCounter;
				Speed := REAL_TO_UDINT(UDINT_TO_REAL(PulseDif*Resolution*2) / (UDINT_TO_REAL(TimeDif)*(CyclicTime/3))); // 0,1mm/min 
				OldWheelCounter := WheelCounter;
				OldTimeCounter := TimeCounter;
				SpdCalcDone := TRUE;
			END_IF
		END_IF
	
		IF (SpdCalcDone = TRUE) THEN
			// Check if Filtering has to be done 
			IF (FilterValue <> 0) THEN
				SpeedValues[FilterValue-1] := Speed;
				Speed := 0;
				FOR Index := 0 TO (FilterValue-1) DO
					Speed := Speed + SpeedValues[Index];
					SpeedValues[Index] := SpeedValues[Index + 1];
				END_FOR;
				Speed := Speed / FilterValue;				// dM / Min 
				Speed_dMeter_Min := Speed;					// dM / Min 
				Speed_dFeet_Min := Speed * 10000;			// dFeet / Min 
				Speed_dFeet_Min := Speed_dFeet_Min / 3048;	// dFeet / Min 
	
				// HMI Speed 
				IF (OutputUnit = 1) THEN
					Speed_HMI   := UDINT_TO_REAL(Speed_dMeter_Min)/10;
				ELSIF (OutputUnit = 2) THEN
					Speed_HMI   := UDINT_TO_REAL(Speed_dFeet_Min)/10;
				END_IF
			END_IF
		END_IF
	
		// HMI Feet/Meter 
		FeetDisable := (OutputUnit = 1);
		MeterDisable := (OutputUnit = 2);
	ELSE
		// Error 
		Speed := 0;
		Speed_dMeter_Min := 0;
		Speed_dFeet_Min := 0;
		Speed_HMI := 0;
		FeetDisable := 1;
		MeterDisable := 0;
	END_IF
END_FUNCTION_BLOCK