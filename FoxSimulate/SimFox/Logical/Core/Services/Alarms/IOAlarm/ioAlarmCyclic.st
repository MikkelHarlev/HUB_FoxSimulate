PROGRAM _CYCLIC
	IF NOT g_Core.System.Runtime.isInitDone THEN
		RETURN;
	END_IF;
	
	(* cyclic check if there is any Error on the X2X Bus *)
	ErrorOnModule := ErrorOnPSwarnOverCurrent := ErrorOnPSwarnFromHW := 0;
	IF g_Core.Services.IO.Runtime.Module[0].ModuleId = 7966 THEN
		PWL_2_X2X_isUsed := TRUE;
	END_IF
	IF (NumberX2XModLoop > 0) THEN
		// Moved here so it will only check is there is modules
		ErrorX2XBusOff := 1;
	
		FOR CountModule := 1 TO NumberX2XModLoop DO

			IF PWL_2_X2X_isUsed THEN // 0-based list
				IoAlarmCheck.Io.Module[CountModule] := g_Core.Services.IO.Runtime.Module[CountModule] ;
			ELSE
				IF (g_Core.System.Configuration.isArrayZeroBased) THEN
					g_Core.Services.IO.Runtime.Module[CountModule] := IoAlarmCheck.Io.Module[CountModule-1];
				ELSE						
					IoAlarmCheck.Io.Module[CountModule] := g_Core.Services.IO.Runtime.Module[CountModule+1] ;
				END_IF
			END_IF	
	
			IF (g_Core.System.Configuration.isArrayZeroBased) THEN
				IF g_Core.Services.IO.Interface.isIgnoreX20Module[CountModule-1] THEN IoAlarmCheck.Io.Module[CountModule-1].ModuleOk := TRUE; END_IF
				pModule ACCESS ADR(IoAlarmCheck.Io.Module[CountModule-1]);
			ELSE		
			IF g_Core.Services.IO.Interface.isIgnoreX20Module[CountModule] THEN IoAlarmCheck.Io.Module[CountModule-1].ModuleOk := TRUE; END_IF
			pModule ACCESS ADR(IoAlarmCheck.Io.Module[CountModule]);
			END_IF
			(* Module OK bit *)
			ErrorOnModule := ErrorOnModule OR (NOT pModule.ModuleOk);
			// Get Module ID
			IF NOT pModule.ModuleOk AND NOT disableSearch THEN
				ErrorModulID := UINT_TO_USINT(CountModule);
				disableSearch := TRUE;
			END_IF
			(* Bus is off if all modules have an error *)
			ErrorX2XBusOff := ErrorX2XBusOff AND (NOT pModule.ModuleOk);
	
			(* Power Supply overcurrent warning *)
			ErrorOnPSwarnOverCurrent := ErrorOnPSwarnOverCurrent OR pModule.PSwarnOverCurrent;
	
			(* Power Supply Hardware warning *)
			ErrorOnPSwarnFromHW := ErrorOnPSwarnFromHW OR pModule.PSwarnFromHW;
		END_FOR;
	END_IF
	(* cyclic check if there is any Error on the X2X Bus *)
	IoAlarmCheck.Vc.Trigger[0] := ErrorOnModule AND NOT g_Core.System.Runtime.isSimulation;
	IoAlarmCheck.Vc.Trigger[1] := ErrorOnPSwarnOverCurrent AND NOT g_Core.System.Runtime.isSimulation;
	IoAlarmCheck.Vc.Trigger[2] := ErrorOnPSwarnFromHW AND NOT g_Core.System.Runtime.isSimulation;
	IoAlarmCheck.Vc.Trigger[3] := ErrorX2XBusOff AND NOT g_Core.System.Runtime.isSimulation;
	
	(* An IO module error *)
	g_Core.Services.Alarmhandler.Interface.AlarmGroup[CORE_ALARMS].Alarm   [40] := IoAlarmCheck.Vc.Trigger[0] OR IoAlarmCheck.Vc.Trigger[1] OR IoAlarmCheck.Vc.Trigger[2] OR IoAlarmCheck.Vc.Trigger[3];
	g_Core.Services.Alarmhandler.Interface.AlarmGroup[CORE_ALARMS].Priority[40] := 254;
	
	g_Core.System.Interface.alarms.isPLCHalted  := g_Core.Services.IO.Interface.isHaltPlc;

END_PROGRAM

