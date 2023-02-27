//--------------------------------------------------------------------------------------------------------------------
//
//	Author:			Jensen Denmark
//
//	Filename:    	masterInit.st
//
//	Description: 	Master Acopos Handling
//
//	History:		17-03-2011		V1.00.0		Kc 		First Edition
//
//--------------------------------------------------------------------------------------------------------------------
// Set Conditions For Start Of Acopos 
//--------------------------------------------------------------------------------------------------------------------

PROGRAM _INIT

	rInit := TRUE;
END_PROGRAM

PROGRAM _CYCLIC

	IF (g_Core.Services.Hardware.Runtime.initState <> RUNTIME) OR g_sim.Test THEN
		RETURN;
	END_IF

	IF rInit THEN
		rInit := FALSE;
		FOR AXi := 0 TO g_MaxAxis DO
			g_Axis[AXi].axisRef := ADR(gAxis01);
		END_FOR
	END_IF

	// Fox- Specific ----------------
	
	// Delay Clamps Startup 
	TStartSq(Set:= EDGEPOS (g_Core.System.Runtime.isRunning) OR EDGEPOS(g_HMIHangerSetup > 0), Delay:= 1800, Comp:=0, CntAdr:=ADR (g_MilliSeconds));
	IF g_Core.System.Interface.alarms.isAcoposError THEN
		QKStartOk := FALSE;
	END_IF
	AcoposStartOk := (NOT g_Halted AND NOT TStartSq.Out AND NOT g_Core.Services.AcoposAlarm.Runtime.Error);
	// ----------------

	//--------------------------------------------------------------------------------------------------------------------
	// Error Handling 
	//--------------------------------------------------------------------------------------------------------------------

	// Acopos Error (Check Alarm Acopos Info) 
	g_Core.System.Interface.alarms.isAcoposError := g_Axis[AX1].interface.isErrorReset;
	IF g_Core.System.Interface.alarms.isAcoposError THEN
		QKStartOk := FALSE;
	END_IF
	F_TRIG_Alarm[AX1](CLK := g_Core.System.Interface.alarms.isAcoposError);
	IF F_TRIG_Alarm[AX1].Q OR g_Core.System.Interface.alarms.isAcoposErrorCleared THEN
		g_Axis[AX1].interface.isErrorReset := FALSE;
	END_IF
	
	//	FOR AXi := AX1 TO g_MaxAxis DO 
	//		IF (g_Axis[AXi].axisRef > 0) THEN
	//			g_Axis[AXi].interface.cmdDisableAlarm := FALSE;
//			F_TRIG_Alarm[AXi](CLK := g_Core.Services.Alarmhandler.Interface.AlarmGroup[MACHINE_ALARMS].Ack[AXi + 61]);
//			g_Core.Services.Alarmhandler.Interface.AlarmGroup[MACHINE_ALARMS].Alarm   [AXi + 61] := g_Axis[AXi].interface.isErrorReset;
//			g_Core.Services.Alarmhandler.Interface.AlarmGroup[MACHINE_ALARMS].Priority[AXi + 61] := 250;
//			// Reset	
//			IF F_TRIG_Alarm[AXi].Q THEN
//				g_Axis[AXi].interface.isErrorReset := FALSE;
//			END_IF
//		END_IF     
//	END_FOR
 (* g_Core.Services.AcoposAlarm.Runtime.Error := g_Axis[AX1].interface.isErrorReset OR g_Axis[AX2].interface.isErrorReset OR 
	g_Axis[AX3].interface.isErrorReset OR g_Axis[AX4].interface.isErrorReset OR g_Axis[AX5].interface.isErrorReset OR g_Axis[AX6].interface.isErrorReset; *)
							
//--------------------------------------------------------------------------------------------------------------------
// Master Case 
//--------------------------------------------------------------------------------------------------------------------

	CASE g_MasterStep OF
		0:	// Ready - Wait For Start Signal 
			FOR AXi := AX1 TO g_MaxAxis DO 
				g_Axis[AXi].interface.cmdStart := FALSE;	
				g_Axis[AXi].interface.cmdStop := TRUE;	
			END_FOR

			IF ((g_Core.System.Runtime.isRunning OR g_HMIHangerSetup > 0) AND AcoposStartOk) OR g_AcoposStart THEN
				allDone := TRUE;
				FOR AXi := AX1 TO g_MaxAxis DO
					IF ((g_Axis[AXi].interface.isStopped = FALSE) OR g_Axis[AXi].interface.isErrorReset) AND (g_Axis[AXi].axisRef > 0) THEN
						allDone := FALSE;
					END_IF
				END_FOR							
				IF allDone THEN
					g_Axis[AX1].parameter.parID	:= ACP10PAR_UDC_ACT;			// 298
					g_Axis[AX1].parameter.DataAddress := ADR (UDCValue);
					g_Axis[AX1].parameter.DataType := ncPAR_TYP_REAL;
					g_Axis[AX1].state := AXIS_CMD_READ;
					g_MasterStep := 1;
				END_IF
			END_IF

		1:	// Wait For UDC Value 
			allDone := TRUE;
			FOR AXi := AX1 TO g_MaxAxis DO
				IF (g_Axis[AXi].state <> AXIS_IDLE) AND (g_Axis[AXi].axisRef > 0) THEN
					allDone := FALSE;
				END_IF
			END_FOR
			// Set UDC Value 
			IF allDone THEN
				UDCValue := UDCValue * 0.95;
				IF UDCValue > 400 THEN 
					// 340 To 500 VAC
					UDCValue := LIMIT(475,UDCValue,675);
					g_TorqueFactor := 1;
				ELSE	
					// 180 To 260 VAC
					UDCValue := LIMIT(250,UDCValue,322);
					g_TorqueFactor := 2;
				END_IF				
				FOR AXi := AX1 TO g_MaxAxis DO
					g_Axis[AXi].parameter.parID	:= ACP10PAR_UDC_NOMINAL;	    // 390
					g_Axis[AXi].parameter.DataAddress := ADR (UDCValue);
					g_Axis[AXi].parameter.DataType := ncPAR_TYP_REAL;
					g_Axis[AXi].state := AXIS_CMD_WRITE;
				END_FOR
				g_MasterStep := 2;
			END_IF

		2:	// Wait For UDC Value Done 
			allDone := TRUE;
			FOR AXi := AX1 TO g_MaxAxis DO
				IF (g_Axis[AXi].state <> AXIS_IDLE) AND (g_Axis[AXi].axisRef > 0) THEN
					allDone := FALSE;
				END_IF
			END_FOR
			// Set Power On 
			IF allDone THEN
				FOR AXi := AX1 TO g_MaxAxis DO 
					g_Axis[AXi].interface.cmdStart := TRUE;	
				END_FOR		
				g_MasterStep := 3;
			END_IF	

		3: // Starting All Acopos
			allDone := TRUE;
			FOR AXi := AX1 TO g_MaxAxis DO 
				IF (g_Axis[AXi].interface.isStarted = FALSE) AND (g_Axis[AXi].axisRef > 0) THEN
					allDone := FALSE;
				END_IF							
			END_FOR
			IF allDone THEN
				g_MasterStep := 100;
			END_IF
			IF (NOT g_Core.System.Runtime.isRunning AND g_HMIHangerSetup = 0 AND NOT g_HangerTestInProgress) AND NOT g_AcoposStart THEN
				g_MasterStep := 0;
			END_IF

			//--------------------------------------------------------------------------------------------------------------------
			// Start Up Done 
			//--------------------------------------------------------------------------------------------------------------------

		100:	// All Axis Ready 
			IF NOT g_Core.System.Runtime.isRunning AND g_HMIHangerSetup = 0 AND NOT g_HangerTestInProgress THEN
				g_MasterStep := 0;
			END_IF
		
	END_CASE
	//--------------------------------------------------------------------------------------------------------------------
END_PROGRAM
//--------------------------------------------------------------------------------------------------------------------

