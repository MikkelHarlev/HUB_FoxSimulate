PROGRAM _INIT
	(* Get out number of modules which could be handled by this task *)
	NumberX2XModules := SIZEOF (IoAlarmCheck.Io.Module) / SIZEOF(IoAlarmCheck.Io.Module[0])-1;
	
	(* Find All Modules where the Description ends with 'ModuleOk' *)
	ListIoPoint.enable := 1;
	ListIoPoint.pLastDatapoint := 0;
	g_Core.Services.IO.Runtime.numberOfInverters := 0;
	g_Core.System.Configuration.isArrayZeroBased := TRUE;
	REPEAT
		ListIoPoint();
		ListIoPoint.pLastDatapoint := ListIoPoint.pDatapoint;
		memcpy(pDest := ADR(TestStringCopy), pSrc := ADR(ListIoPoint.buffer), length := 128);
		IF memcmp(ADR('ModuleOk'), ADR(TestStringCopy) + strlen(ADR(TestStringCopy)) - 8, 8) = 0 THEN
			IF memcmp(ADR('ST'), ADR(TestStringCopy) + strlen(ADR(TestStringCopy)) - 14, 2) = 0 THEN
				g_Core.Services.IO.Runtime.numberOfInverters := g_Core.Services.IO.Runtime.numberOfInverters + 1;
			ELSE
				NumberHwX2XModules := NumberHwX2XModules + 1;
			END_IF;
		END_IF;
		UNTIL ListIoPoint.pDatapoint = 0
	END_REPEAT;
	
	(* Decide for Number of Modules to loop *)
	IF NumberHwX2XModules > NumberX2XModules THEN
		NumberX2XModLoop := NumberX2XModules;
	ELSIF NumberHwX2XModules > 0 THEN
		NumberX2XModLoop := NumberHwX2XModules - 1;
	ELSE
		NumberX2XModLoop := 0;
	END_IF;
	// Tell Core how many IO modules we have.
	g_Core.Services.IO.Runtime.numberOfIOModules := NumberX2XModLoop;
END_PROGRAM

