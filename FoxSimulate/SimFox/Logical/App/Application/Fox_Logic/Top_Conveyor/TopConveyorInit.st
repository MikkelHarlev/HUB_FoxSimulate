PROGRAM _INIT
(* init program *)
(* Common settings for the task *)

	ForcedHoldTest := 0;	// Used for forcing a hold point in the TC for testing the meassuring...	
	Discount := 0.97;		// Discount when garment is stopped in the TC...

	BTurn[0](FMode:=1, TMode:=0, Filter:=50, CntAdr:=ADR(g_MilliSeconds));
	BTurn[1](FMode:=3, TMode:=0, Filter:=10, CntAdr:=ADR(g_MilliSeconds));

	BTurnVertical(FMode:=0, TMode:=0, Filter:=5, CntAdr:=ADR(g_WheelCounter));
	BTurnHorizontal(FMode:=0, TMode:=0, Filter:=5, CntAdr:=ADR(g_WheelCounter));

	(* Individual settings for the task *)
	g_TopConveyorProcess.Common.Description 									:= 'Top Conveyor';
	InitFoldTask(g_TopConveyorProcess.Common, g_MachineManager[g_TopConveyorProcess.Common.MachineManagerIndex]);

	DistOrgNewPh := 90;

	ExpectedOffSet := 15;
	StartXAOffset := 75;

	RVerticalANDPhA := 0;
	RVerticalANDPhB := 0;
	RBXAFold;
	
	InletBrake_TOF.PT := T#500ms;
	TopConveyorBrake_TOF.PT := T#70ms;
	
END_PROGRAM

