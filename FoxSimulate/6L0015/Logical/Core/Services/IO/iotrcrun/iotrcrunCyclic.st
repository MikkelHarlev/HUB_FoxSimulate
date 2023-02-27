PROGRAM _CYCLIC
	
	IF	g_Core.Services.IOTrace.Runtime.Mode = 0 OR g_Core.Services.IOTrace.Runtime.Mode > 9 THEN (* No more rcording to be done *)
		RETURN;
	END_IF
	// Only run every ms if task class is lower than 1 ms
	// Cycle time is meassured in micro seconds
	CycleCount := CycleCount + RTInfo_0.cycle_time;
	IF CycleCount < 1000 THEN
		RETURN;
	END_IF
	CycleCount := 0;
		
	g_Core.Services.IOTrace.Runtime.CycleCounter := g_Core.Services.IOTrace.Runtime.CycleCounter + 1;(* Increase ms cycle counter *)
	IF g_Core.Services.IOTrace.Runtime.CycleCounter >= MAXTRACECYCLES THEN
		g_Core.Services.IOTrace.Runtime.CycleCounter := 0;
	END_IF
	
	
	CASE g_Core.Services.IOTrace.Runtime.Mode OF
		1:  (* Wait for start trig *)
			IF (g_Core.Services.IOTrace.Runtime.TrigIndex >= 0) AND (* Trig on one of the IO *)
				g_Core.Services.IOTrace.Runtime.IoData[g_Core.Services.IOTrace.Runtime.TrigIndex].Pointer > 0 THEN
				tmp ACCESS g_Core.Services.IOTrace.Runtime.IoData[g_Core.Services.IOTrace.Runtime.TrigIndex].Pointer;
				g_Core.Services.IOTrace.Runtime.IoData[g_Core.Services.IOTrace.Runtime.TrigIndex].CurrentValue := tmp;
				IF g_Core.Services.IOTrace.Runtime.CycleCounter > 1 THEN (* Only after old value has been stored once *)
					IF g_Core.Services.IOTrace.Runtime.IoData[g_Core.Services.IOTrace.Runtime.TrigIndex].CurrentValue <> g_Core.Services.IOTrace.Runtime.IoData[g_Core.Services.IOTrace.Runtime.TrigIndex].OldValue THEN (* store value changes *)
						g_Core.Services.IOTrace.Runtime.TrigStart := TRUE;(* to record current cycles data further down in task *)
					END_IF
				END_IF
				g_Core.Services.IOTrace.Runtime.IoData[g_Core.Services.IOTrace.Runtime.TrigIndex].OldValue := g_Core.Services.IOTrace.Runtime.IoData[g_Core.Services.IOTrace.Runtime.TrigIndex].CurrentValue;
			END_IF
			IF g_Core.Services.IOTrace.Runtime.TrigStart OR g_Core.Services.IOTrace.Runtime.ExternTrig THEN (* time to Trig *)
				g_Core.Services.IOTrace.Runtime.TrigStart := TRUE;(* to record current cycles data further down in task *)
				g_Core.Services.IOTrace.Runtime.CycleCounter := 0;(* Restart cycle counter *)
				g_Core.Services.IOTrace.Runtime.TrigStartCycle := g_Core.Services.IOTrace.Runtime.CycleCounter;
				g_Core.Services.IOTrace.Runtime.RecordEnable := TRUE; (* To enable recording of data *)
				g_Core.Services.IOTrace.Runtime.Mode := 2; (* Trace is started *)
			END_IF
			IF g_Core.Services.IOTrace.Runtime.cmdStop = 1 THEN (* Manual stop activated *)
				g_Core.Services.IOTrace.Runtime.Mode := 2; 		(* Stop task next cycle *)
			END_IF
		2:
			IF (g_Core.Services.IOTrace.Runtime.CycleCounter = g_Core.Services.IOTrace.Runtime.TrigStartCycle) OR (g_Core.Services.IOTrace.Runtime.cmdStop = 1) THEN (* A lap was completed, do not over write old data *)
				g_Core.Services.IOTrace.Runtime.TrigStopCycle := (g_Core.Services.IOTrace.Runtime.CycleCounter+MAXTRACECYCLES-1)MOD MAXTRACECYCLES;(* Stop point just before start point *)
				g_Core.Services.IOTrace.Runtime.Mode := 10; (* Full circle completed. stop recording *)
				g_Core.Services.IOTrace.Runtime.cmdStop := 0;
			END_IF
		5:	(* Wait for stop trig *)
			IF g_Core.Services.IOTrace.Runtime.TrigStart OR g_Core.Services.IOTrace.Runtime.ExternTrig OR (g_Core.Services.IOTrace.Runtime.cmdStop = 1) THEN
				g_Core.Services.IOTrace.Runtime.TrigStopCycle := (g_Core.Services.IOTrace.Runtime.CycleCounter+10)MOD MAXTRACECYCLES;(* Stop point 10 cycles later *)
				g_Core.Services.IOTrace.Runtime.Mode := 6; (* Wait another 10 cycles before stop recording *)
				g_Core.Services.IOTrace.Runtime.cmdStop := 0;
			END_IF
		6:	(* wait another 10 cycles before stop recording *)
			IF g_Core.Services.IOTrace.Runtime.CycleCounter =	g_Core.Services.IOTrace.Runtime.TrigStopCycle THEN
				g_Core.Services.IOTrace.Runtime.Mode := 10; (* trig stop + 10 extra completed, stop recording *)
			END_IF
	END_CASE
	
	(* If trace is running this must always be done cyclic *)
	FOR i := 0 TO (g_Core.Services.IOTrace.Runtime.numberOfTraceIO-1) DO
		IF g_Core.Services.IOTrace.Runtime.IoData[i].Pointer > 0 THEN
			tmp ACCESS g_Core.Services.IOTrace.Runtime.IoData[i].Pointer;
			g_Core.Services.IOTrace.Runtime.IoData[i].CurrentValue := UINT_TO_BOOL(tmp);
			(*IoPointer[i] ACCESS g_Core.Services.IOTrace.Runtime.IoData[i].Pointer;
			g_Core.Services.IOTrace.Runtime.IoData[i].CurrentValue := UINT_TO_BOOL(IoPointer[i]);*)
			IF g_Core.Services.IOTrace.Runtime.RecordEnable THEN
				IF (g_Core.Services.IOTrace.Runtime.IoData[i].CurrentValue <> g_Core.Services.IOTrace.Runtime.IoData[i].OldValue) OR g_Core.Services.IOTrace.Runtime.TrigStart THEN (* store value changes *)
					g_Core.Services.IOTrace.Runtime.IoData[i].Value[g_Core.Services.IOTrace.Runtime.IoData[i].Index] := g_Core.Services.IOTrace.Runtime.IoData[i].CurrentValue;
					g_Core.Services.IOTrace.Runtime.IoData[i].StartCycle[g_Core.Services.IOTrace.Runtime.IoData[i].Index] := g_Core.Services.IOTrace.Runtime.CycleCounter;
					IF g_Core.Services.IOTrace.Runtime.IoData[i].Index < MAXTRACELOGITEMS THEN
						g_Core.Services.IOTrace.Runtime.IoData[i].Index := g_Core.Services.IOTrace.Runtime.IoData[i].Index + 1;
					ELSE
						g_Core.Services.IOTrace.Runtime.cmdStop := 1;(* Stop recording next loop *)
					END_IF
				END_IF
				g_Core.Services.IOTrace.Runtime.IoData[i].OldValue := g_Core.Services.IOTrace.Runtime.IoData[i].CurrentValue;(* save last value *)
			END_IF
		ELSE
			i:= g_Core.Services.IOTrace.Runtime.numberOfTraceIO; (* exit *)
		END_IF
	END_FOR
	g_Core.Services.IOTrace.Runtime.TrigStart := FALSE;
	g_Core.Services.IOTrace.Runtime.ExternTrig := FALSE;
END_PROGRAM

