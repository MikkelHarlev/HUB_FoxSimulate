PROGRAM _CYCLIC
//------------------------------------------------------------------------------------------------------------------------------------
//
//	Project Name: 		JENSEN Common HMI Project
//
//	Task Name:			PhoenixCyclic.st	
//
//	Description:		Safety Plc Handling Task
//
//	History:			19-01-2012		V1.00.0		JEDK 	First Edition
//
//------------------------------------------------------------------------------------------------------------------------------------
// Phoenix Safety Relay
//------------------------------------------------------------------------------------------------------------------------------------

IF NOT g_UseSafePlc THEN RETURN; END_IF


// Transfer Data Bits 
IF NewData THEN
	NewData := 0;
 	Data[Cnt] := NOT ISafeSBit1;
	IF Cnt < 8 THEN 
		Cnt := Cnt + 1;
 	END_IF	
END_IF

// Delay Error Signal Off 
FOR No := 0 TO 7 DO
 	TOFData[No](IN := Data[No], PT := T#1s500ms);
END_FOR	

// Delay External Emergency Stop On
TOFDataOn(IN := EDGEPOS (Data[0]), PT := T#500ms);

// Delay No Input Signal
TOFSignal(IN := ISafeSBit0 OR ISafeSBit1, PT := T#2s);

// Decode Errors 
IF NOT RDisableAllSafetyPlc THEN
	g_PhoenixAlarm.isExtEStopActive := TOFData[0].Q AND NOT ISEmergencyOk AND NOT TOFDataOn.Q AND NOT TOFData[1].Q AND NOT TOFData[2].Q;
	g_PhoenixAlarm.isEStopActive := TOFData[1].Q AND NOT ISEmergencyOk;
	g_PhoenixAlarm.isSafety1Active := TOFData[2].Q AND NOT ISEmergencyOk;
	g_PhoenixAlarm.isSafety2Active := TOFData[3].Q AND NOT ISEmergencyOk;
	g_PhoenixAlarm.isSafety3Active := TOFData[4].Q AND NOT ISEmergencyOk;
	g_PhoenixAlarm.isSafety4Active := TOFData[5].Q AND NOT ISEmergencyOk;
	g_PhoenixAlarm.isSafety5Active := TOFData[6].Q AND NOT ISEmergencyOk;
	g_PhoenixAlarm.isSafety6Active := TOFData[7].Q AND NOT ISEmergencyOk;
	g_PhoenixAlarm.isSafetyPlcError := Data[8] AND REnableSafetyError OR NOT TOFSignal.Q;
END_IF

// Detect Pulselength And New Bit 
IF NOT ISafeSBit0 THEN
	Temp := Temp + 3;
END_IF
IF EDGEPOS(ISafeSBit0) THEN
	IF Temp > (6 * Timeout) THEN
		Timeout := 65000;
 		Cnt := 0;
	END_IF
	IF Temp < Timeout THEN
		Timeout := Temp;
	END_IF
	Temp := 0;	
	NewData := TRUE;
END_IF

//------------------------------------------------------------------------------------------------------------------------------------
END_PROGRAM
//------------------------------------------------------------------------------------------------------------------------------------
