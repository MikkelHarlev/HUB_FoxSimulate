// TODO Convert it to a genereric "pulse train" module this module is to thightly integrated to the core!

PROGRAM _CYCLIC
	IF g_HCfg.BRSafety	THEN
		RETURN;		
	END_IF	
	// Case for dynamic setup
	// local for now...
	CASE taskState OF
		INIT:
			// Check only for Safety PLC if we have IOs attached.
			IF (g_Core.System.Configuration.isSafetyPLCMonitoringEnabled AND g_Core.Services.IO.Runtime.numberOfIOModules > 0) THEN	
				// Check if names are set.
				IF (g_Core.System.Configuration.adrSafeBit0VarName > 0 AND g_Core.System.Configuration.adrSafeBit1VarName > 0) THEN
					GetAdr(ADR(adrISafeSBit0), g_Core.System.Configuration.adrSafeBit0VarName);
					GetAdr(ADR(adrISafeSBit1), g_Core.System.Configuration.adrSafeBit1VarName);
					// We most likely got the pointers :)
					IF (adrISafeSBit0 > 0 AND adrISafeSBit1 > 0) THEN
						pISafeSBit0 ACCESS adrISafeSBit0;
						pISafeSBit1 ACCESS adrISafeSBit1;
						// Set task state to runtime!
						taskState := RUNTIME; 
					END_IF
				END_IF
			ELSE
				g_Core.System.Interface.alarms.isSafetyPlcError := FALSE;
			END_IF
			
		RUNTIME:
		
			// Transfer Data Bits 
			IF NewData THEN
				NewData := 0;
				Data[Cnt] := NOT pISafeSBit1;
				IF Cnt < 8 THEN 
					Cnt := Cnt + 1;
				END_IF	
			END_IF

			// Delay Error Signal Off 
			FOR No := 0 TO 7 DO
				TOFData[No](IN := Data[No], PT := T#2s500ms);
			END_FOR	

			// Delay External Emergency Stop On
			TOFDataOn(IN := EDGEPOS (Data[0]), PT := T#500ms);

			// Delay No Input Signal
			TOFSignal(IN := pISafeSBit0 OR pISafeSBit1, PT := T#2s);

			// Decode Errors 
			g_Core.System.Interface.alarms.isExtEStopActive := TOFData[0].Q (*AND NOT g_Core.System.Runtime.isEStopActivated*) AND NOT TOFDataOn.Q AND NOT TOFData[1].Q AND NOT TOFData[2].Q AND NOT g_Core.System.Runtime.isSimulation;
			g_Core.System.Interface.alarms.isEStopActive	:= TOFData[1].Q; // AND NOT g_Core.System.Runtime.isEStopActivated;
			g_Core.System.Interface.alarms.isSafety1Active	:= TOFData[2].Q; // AND NOT g_Core.System.Runtime.isEStopActivated;
			g_Core.System.Interface.alarms.isSafety2Active	:= TOFData[3].Q; // AND NOT g_Core.System.Runtime.isEStopActivated;
			g_Core.System.Interface.alarms.isSafety3Active	:= TOFData[4].Q; // AND NOT g_Core.System.Runtime.isEStopActivated;
			g_Core.System.Interface.alarms.isSafety4Active	:= TOFData[5].Q; // AND NOT g_Core.System.Runtime.isEStopActivated;
			g_Core.System.Interface.alarms.isSafety5Active	:= TOFData[6].Q; // AND NOT g_Core.System.Runtime.isEStopActivated;
			g_Core.System.Interface.alarms.isSafety6Active	:= TOFData[7].Q; // AND NOT g_Core.System.Runtime.isEStopActivated;
			g_Core.System.Interface.alarms.isSafetyPlcError	:= (Data[8] OR NOT TOFSignal.Q) AND NOT g_Core.System.Runtime.isSimulation;

			g_Core.System.Runtime.isEStopActivated := NOT g_Core.System.Interface.alarms.isEStopActive AND ISGuardOk;
			
			// Detect Pulselength And New Bit 
			IF NOT pISafeSBit0 THEN
				Temp := Temp + 1;
			END_IF
			IF EDGEPOS(pISafeSBit0) THEN
				IF Temp > (2 * Timeout) THEN
					Timeout := 65000;
					Cnt := 0;
				END_IF
				IF Temp < Timeout THEN
					Timeout := Temp;
				END_IF
				Temp := 0;	
				NewData := TRUE;
			END_IF
			// Set the Check Alarm Flag while getting info from the safety plc.
			g_Core.System.Interface.infos.isCheckAlarm	:= g_Core.System.Interface.infos.isCheckAlarm OR NOT g_Core.System.Runtime.isEStopActivated;
	
	END_CASE
END_PROGRAM

