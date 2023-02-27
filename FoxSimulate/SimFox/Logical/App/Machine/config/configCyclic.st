PROGRAM _CYCLIC
	IF NOT g_Core.System.Runtime.isInitDone THEN
		RETURN;
	END_IF
	
	IF NOT RInitDone THEN
		RInitDone := 1;

		// Activate the duo VNC
		IF g_HCfg.DuoInlet THEN
			VA_StartVisuByName(g_HCfg.DuoInlet,'duo');
			HideDuoHmi := 0;	// Duo hmi show
		ELSE
			HideDuoHmi := 1;	// Duo hmi hide
		END_IF
	END_IF

	IF AnalogModuleIndex > 0 THEN
		g_Core.Services.IO.Interface.isIgnoreX20Module[AnalogModuleIndex] := TRUE;		
	END_IF
END_PROGRAM