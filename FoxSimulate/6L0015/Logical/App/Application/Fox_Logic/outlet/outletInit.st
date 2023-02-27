PROGRAM _INIT

	RInit := 1;

	LogEntry(g_MCfg.Trace2File, ADR(T2FD), 1, 1, 64738, 'Outlet init');

	RInitReadParameters := 1;
	REnableOrgJECHStop := 1;
	ManualStop := 0;		// Test flag to stop the flow of goods from the stacker groups...

	FOR i := 0 TO MAX_NUMBER_OF_STACKERS DO
		LiftOutputDelay[i](Filter := 75, FMode := 3, TMode := 0, CntAdr := ADR(g_MilliSeconds));
	END_FOR
	
	Count;

	// Why is this not in the Stacker Task ??? POX 09-12-08
	g_StackerGroup[1].FirstStack 	:= 1;	
	g_StackerGroup[1].LastStack 	:= 2;	
	g_StackerGroup[2].FirstStack 	:= 3;	
	g_StackerGroup[2].LastStack 	:= 4;
	g_StackerGroup[3].FirstStack 	:= 5;	
	g_StackerGroup[3].LastStack 	:= 6;
	g_StackerGroup[4].FirstStack 	:= 7;	
	g_StackerGroup[4].LastStack 	:= 8;
	g_StackerGroup[5].FirstStack 	:= 9;	
	g_StackerGroup[5].LastStack 	:= 10;

	WaitingPhotocellOK.CntAdr := ADR(g_MilliSeconds);
	WaitingPhotocellOK.Delay := 10000;
	WaitingPhotocellOK.Set := 1;
	WaitingPhotocellOK();
	
	(* init program *)
	(* Common settings for the task *)

	g_HMIStackCountStr[0] := '0';
	FOR i := 1 TO MAX_NUMBER_OF_STACKERS DO
		// JEDK FIX: To avoid stacker banging
		g_OutletProcess.StackerUnit[i].LiftMode := LIFT_MODE_DOWN_2;
		g_HMIStackCountStr[i] := '0';
	END_FOR


	//MAX_STACK_SIZE 										:= 8;
	MAX_STACK_SIZE 										:= 15;
	g_OutletProcess.Common.MachineManagerIndex 			:= 6;
	g_OutletProcess.Common.WatchDogStartupTime			:= 4000;
	g_OutletProcess.Common.WatchDogRunTime				:= 10000;

	(* Individual settings for the task *)
	g_OutletProcess.Common.Description 					:= 'Outlet';
	g_OutletProcess.StackerUnit[1].Motor.Name			:= 'BeltA';
	g_OutletProcess.StackerUnit[2].Motor.Name			:= 'BeltB';
	g_OutletProcess.StackerUnit[3].Motor.Name			:= 'BeltC';
	g_OutletProcess.StackerUnit[4].Motor.Name			:= 'BeltD';


	// Make empty zero data variables for use in the application....

	ZeroStackData.BatchId 		:= 0;
	ZeroStackData.CustomerId 	:= 0;
	ZeroStackData.ArticleId		:= 0;
	ZeroStackData.Count			:= 0;
	ZeroStackData.FoldProgram 	:= 0;
	ZeroStackData.Destination 	:= 0;

	FOR Index := 0 TO STACK_ITEM_MAX_20 DO
		ZeroStackData.ItemData[Index].ArticleId 	:= 0;
		ZeroStackData.ItemData[Index].CustomerId	:= 0;
		ZeroStackData.ItemData[Index].FoldProgram	:= 0;
		ZeroStackData.ItemData[Index].GarmentId		:= '';
		ZeroStackData.ItemData[Index].HangerId		:= '';
		//ZeroStackData.ItemData[Index].Id			:= 0;
	END_FOR


	GarbageStackData.BatchId 		:= 999;
	GarbageStackData.CustomerId 	:= 999;
	GarbageStackData.ArticleId		:= 99;
	GarbageStackData.Count			:= 0;
	GarbageStackData.FoldProgram 	:= 99;
	GarbageStackData.Destination 	:= 0;

	FOR Index := 0 TO STACK_ITEM_MAX_20 DO
		GarbageStackData.ItemData[Index].ArticleId 		:= 0;
		GarbageStackData.ItemData[Index].CustomerId		:= 0;
		GarbageStackData.ItemData[Index].FoldProgram	:= 0;
		GarbageStackData.ItemData[Index].GarmentId		:= '';
		GarbageStackData.ItemData[Index].HangerId		:= '';
		//GarbageStackData.ItemData[Index].Id				:= 0;
	END_FOR

	InitFoldTask(g_OutletProcess.Common,g_MachineManager[g_OutletProcess.Common.MachineManagerIndex]);

	StackIndexNumber 			:= 1;				// Added POX 09-10-14..
	PrinterSimulation 			:= FALSE;			// POX 10-11-15..
	g_PrinterCom.FolderStatus 	:= PP_STANDBY_10;	// Folder init status POX 10-11-15..

	g_OutletProcess.JenwayExchange[i].TransferStatus := EXC_STANDBY_0;
	MaxBufferSize :=4; // max stack on outlet belt
END_PROGRAM

