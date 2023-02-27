PROGRAM _CYCLIC
(* cyclic program *)

(*-------------------------------------------------------------------------------------

Author:   				Sten Flystedt

FileName:				Stacker.scr

Desription:				Stacker

Reference:

Interfaces:				No interfaces.

Watch debugg:			Name OF important watch configurations.

History:
10-12-01				V1.05.1	PO Nilsson			Start release OF next garment into XB AND XA one step earlier..
10-05-03				V1.05.0	PO Nilsson			State could be in _81 AND Next.Transferstatus = _0 so made resolve FOR that...	
10-03-30				V1.04.9	PO Nilsson			More error resolve FOR 40-6006..
10-03-15				V1.04.8	PO Nilsson			Removed the "Time out 2" had no effect...
10-03-12				V1.04.7	PO Nilsson			Shorten the watchdog time from 5 TO 2 seconds	
10-02-04				V1.04.6	PO Nilsson			Added code TO resolve error situation in state _80. Transferstatus was =1.
10-01-29				V1.04.5	PO Nilsson			Put the _98 part back again, it was needed...
10-01-28				V1.04.4	PO Nilsson			Added a check that Stacker was waitning FOR lead EDGE before alarm TO long covered...
10_01-27				V1.04.3	PO Nilsson			Removed _98 sins it did NOT work...
10-01-26				V1.04.2	PO Nilsson			Added photocell TO check that no hanger is over the tower when flaps should close.
													On online machines...
10-01-11				V1.04.1	PO Nilsson			Fixes from Holbaek...
09-12-09				V1.04.0	PO Nilsson			New format OF CategoryData_Type where Stacker AND StackerBelt is splitted..	
09-12-02				V1.03.8	PO Nilsson			Alarm IF Inlet photocell is covered TO long...
													Changed the trigger OF the Airpipe before flaps, was TO late..
09-11-30				V1.03.7	PO Nilsson			Removed alarm om photocell covered at Foldpoint...
09-11-23				V1.03.6	PO Nilsson			Bug fixes FOR holdpoint caused garment TO stop between stacker groups..
09-11-18				V1.03.5	PO Nilsson			Added an Air blast before the stacker flaps FOR Micro fiber garments..
09-11-11				V1.03.4	PO Nilsson			Moved the check in inlet photocell from root OF _20 TO after the first request step 
													has been made.
09-11-05				V1.03.3	PO Nilsson			Special output FOR airpipe before stacker flaps, for Marcel test..
09-11-04				V1.03.2	PO Nilsson			Clear lenght part OF product when data is copied TO next STG OR Outlet... New stack change FUNCTION
09-10-28				V1.03.1	PO Nilsson			Created alarm[6] when photocell is covered at foldpoint, was
													alarm[5] before same as photocell covered at start _20... 
09-10-15				V1.03.0 PO Nilsson			Start work on Multi stacker
09-10-01				V1.02.1 PO Nilsson			Bug fixes on site Holbaek
09-08-13				V1.02 	Sten Flystedt		First close doors,wait AND THEN give ok signal FOR outlet
08-07-01				V1.01 	Sten Flystedt		First edition...
---------------------------------------------------------------------------------------*)

	#pragma warning(disable: 1281)
	
	IF NOT g_SystemInitialized THEN
		RETURN;
	END_IF	
	
	IF g_TestLogData OR TestLogData THEN
		TestLogData := FALSE;
		LogData_0(Type := 1, Lane := 1, Info1 := TestInfo1, Info2 := ADR(g_Core.Services.CAR.Runtime.No[0].RecipeName));
	END_IF		
	g_TestLogData := FALSE;
	
	(*#####################*)
	(* Get current time... *)
	(*#####################*)

	FOR StackerGroup := 1 TO NUMBER_OF_STACKERGROUPS DO
		g_StackerProcess[StackerGroup].Common.CurTimer 					:= g_Timers._1_ms;			(* Get current time *)
		IF g_StackerProcess[StackerGroup].Common.LogBookFlag > 0 THEN
			strcpy(ADR(TmpStr),ADR(g_StackerProcess[StackerGroup].Common.Description));
		END_IF
	END_FOR


	IF NOT (g_Core.Services.Recipe.Runtime.recipePointer > 0) THEN			(* Check that pointer is bigger then Null *)
		RETURN;									(* Do not run task before pointer is assigned... *)
	END_IF

	(*#################################*)
	(* copy status of exchange objects *)
	(*#################################*)

	// Stacker belt to stacker belt connection.
	g_StackerProcess[1].Common.Previous		:= g_CrossFoldBProcess.Common.Next;
	// Se also end of task for copy back transferstatus..


	(*########################################*)
	(* Connect inputs to the module structure *)
	(*########################################*)
	FOR i := 1 TO NUMBER_OF_STACKERGROUPS DO

		// Stacker belt to lift connection
		g_StackerProcess[i].Common.Next			:= g_OutletProcess.StackerGroupLink[i].Previous;

		g_StackerProcess[i].Common.InSensor.OffDelay		:= 20;
		g_StackerProcess[i].Common.InSensor.OnDelay			:= 20;
		g_StackerProcess[i].Common.InSensor.Input			:= IBStacker[i] OR g_sim.IBStacker[i];

		// Jam if photocell covered to long..
		g_StackerProcess[i].JamSensor.OffDelay		:= 50;
		g_StackerProcess[i].JamSensor.OnDelay		:= g_MCfg.Stacker.JamOnDelay;
		g_StackerProcess[i].JamSensor.Input			:= IBStacker[i];

	END_FOR

	IF EDGEPOS(g_StackerProcess[1].Common.InSensor.Output) THEN
		PhPos := g_MilliSeconds;
	END_IF
	IF EDGENEG(g_StackerProcess[1].Common.InSensor.Output) THEN
		PhNeg := g_MilliSeconds;
		FOR i := SIZEOF(Length) / SIZEOF(Length[0]) - 2 TO 0 BY -1 DO
			Length[i+1] := Length[i]; 
		END_FOR	
		Length[0] := PhNeg - PhPos;
		PhI := PhI + 1;
		IF PhI > SIZEOF(Length) / SIZEOF(Length[0]) - 1 THEN
			PhI := 0;
		END_IF	
	END_IF

	// Photocell to check that the garment will not fall on Lift tower, only if Online one stacker..
	g_StackerProcess[1].CheckSensor.OffDelay	:= 10;
	g_StackerProcess[1].CheckSensor.OnDelay		:= 10;
	g_StackerProcess[1].CheckSensor.Input		:= IBStackerCheck;


	FOR StackerGroup := 1 TO NUMBER_OF_STACKERGROUPS DO


		(*######################*)
		(* Connect timer values *)
		(*######################*)
		g_StackerProcess[StackerGroup].Common.WatchDogStartupTime		:= 4000;
		g_StackerProcess[StackerGroup].Common.WatchDogRunTime			:= 2000;
		g_StackerProcess[StackerGroup].Common.Motor.RunTime				:= g_MCfg.ConveyorRunTime;


		// Copy transferstatus..
		g_StackerProcess[1].NextStackerGroup	:= g_StackerProcess[2].Common.Previous;
		g_StackerProcess[2].NextStackerGroup	:= g_StackerProcess[3].Common.Previous;
		g_StackerProcess[3].NextStackerGroup	:= g_StackerProcess[4].Common.Previous;
		g_StackerProcess[4].NextStackerGroup	:= g_StackerProcess[5].Common.Previous;



		IF g_StackerProcess[StackerGroup].Common.ReadParameters	THEN
			g_StackerProcess[StackerGroup].Common.ReadParameters				:= FALSE;
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses,  'Stack Start read param');
			IF g_Core.Services.Recipe.Runtime.recipePointer > 0 THEN			(* Check that pointer is bigger then Null *)
				LocalFoldProgram ACCESS(g_Core.Services.Recipe.Runtime.recipePointer + (SIZEOF(LocalFoldProgram) * LIMIT(0, (g_StackerProcess[StackerGroup].Common.Product.FoldProgram - 1), MAX_NUMBER_OF_CATEGORIES)));
			ELSE
				RETURN;		(* Can not access LocalFoldProgram before pointer is ok. *)
			END_IF

		
			CASE StackerGroup OF 
				1: 	
					g_StackerProcess[1].Parameters						:= LocalFoldProgram.StackerBelt1;
					g_StackerProcess[1].StackerParameter				:= LocalFoldProgram.Stacker;
					// PMU: Xtreme Heavy Option
					g_StackerProcess[1].XtremeHeavy 					:= LocalFoldProgram.XtremeHeavy.FRaiseStackerBelt;//g_AutoProgramData[g_AutoProgram.SelectedAutoProgram].XtremeHeavy;
					g_StackerProcess[1].XtremeSlackBelt 				:= LocalFoldProgram.XtremeHeavy.FSlackStackerBelt;
				2:	
					g_StackerProcess[2].Parameters						:= LocalFoldProgram.StackerBelt2;
					g_StackerProcess[2].StackerParameter				:= LocalFoldProgram.Stacker;
				3:	
					g_StackerProcess[3].Parameters						:= LocalFoldProgram.StackerBelt3;
					g_StackerProcess[3].StackerParameter				:= LocalFoldProgram.Stacker;
				4:	
					g_StackerProcess[4].Parameters						:= LocalFoldProgram.StackerBelt4;
					g_StackerProcess[4].StackerParameter				:= LocalFoldProgram.Stacker;
				5:	
					g_StackerProcess[5].Parameters						:= LocalFoldProgram.StackerBelt5;
					g_StackerProcess[5].StackerParameter				:= LocalFoldProgram.Stacker;
				
			END_CASE		
	
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses,  'Stack Start read param 1');
	
			// Stack is already selected in CrossB and stored in product data
			g_StackerProcess[StackerGroup].SelectedStacker := g_StackerProcess[StackerGroup].Common.Product.Stack;		

			IF g_StackerProcess[StackerGroup].SelectedStacker > g_HCfg.NumberOfStackers THEN
				g_StackerProcess[StackerGroup].SelectedStacker := 1;
			END_IF
			IF g_StackerProcess[StackerGroup].SelectedStacker < 1 THEN
				g_StackerProcess[StackerGroup].SelectedStacker := 1;
			END_IF					

			// Air blast timers
			g_StackerProcess[StackerGroup].AirBlastFlaps.StartDelayTime 	:= g_StackerProcess[StackerGroup].Parameters.AirBlastStartDelay;
			g_StackerProcess[StackerGroup].AirBlastFlaps.OnTime				:= g_StackerProcess[StackerGroup].Parameters.AirBlastOnTime;

			// Calculate to wich stacker in the stacker group...
			Stacker			:= g_StackerProcess[StackerGroup].SelectedStacker MOD 2;
			IF Stacker = 1 THEN		// Make it more compact...
				Stacker := 1;
			ELSE
				Stacker := 2;
			END_IF	

			IF g_StackerProcess[StackerGroup].StackerParameter.StopLeadingOrRearEdge = TRIG_MODE_RAISING_FLANK_0 THEN	
				g_StackerProcess[StackerGroup].Common.TrigMode 		:= TRIG_MODE_RAISING_FLANK_0;
			ELSE
				g_StackerProcess[StackerGroup].Common.TrigMode 		:= TRIG_MODE_FALLING_FLANK_2;
			END_IF


			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_StackerProcess[StackerGroup].SelectedStacker, 'Calc New stack value');


			(* Calculate stop position *)
			IF g_StackerProcess[StackerGroup].Common.TrigMode = TRIG_MODE_RAISING_FLANK_0 THEN
				(*SFX Need to calculate minimum time to avoid trail end still is inside XB *)
				g_StackerProcess[StackerGroup].Common.FoldPointTime 	:= g_MCfg.Stacker.TransportOffSetTime + REAL_TO_UINT((MM_TO_MS_FACTOR*UINT_TO_INT(g_MCfg.Stacker.StopPosition[g_StackerProcess[StackerGroup].SelectedStacker] - g_StackerProcess[StackerGroup].StackerParameter.StopPosition))/10000);
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_StackerProcess[StackerGroup].Common.FoldPointTime, 'Calc for Raising');
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, StackerGroup, 'Calc for STG');		
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_StackerProcess[StackerGroup].SelectedStacker, 'Calc for Stacker');
			ELSE
				g_StackerProcess[StackerGroup].Common.FoldPointTime 	:= g_MCfg.Stacker.TransportOffSetTime + REAL_TO_UINT((MM_TO_MS_FACTOR*UINT_TO_INT(g_MCfg.Stacker.StartPosition[g_StackerProcess[StackerGroup].SelectedStacker] + g_StackerProcess[StackerGroup].StackerParameter.StopPosition))/10000);
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_StackerProcess[StackerGroup].Common.FoldPointTime, 'Calc for Trailing');
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, StackerGroup, 'Calc for STG');		
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_StackerProcess[StackerGroup].SelectedStacker, 'Calc for Stacker');
			END_IF
	
			g_StackerProcess[StackerGroup].Common.Product.JenWayDestination := g_StackerProcess[StackerGroup].StackerParameter.JenWayDestination;
		
			g_StackerProcess[StackerGroup].Common.ExitTime					:= g_MCfg.Stacker.FlapsRestartDelay;
		END_IF


		ActivateFoldIO(g_StackerProcess[StackerGroup].AirBlastFlaps, g_StackerProcess[StackerGroup].Common.CurTimer);
		RunFoldTask(g_MCfg.Trace2File, ADR(T2FD), g_StackerProcess[StackerGroup].Common,g_MachineManager[g_StackerProcess[StackerGroup].Common.MachineManagerIndex]);
		RunIOCounter(g_StackerProcess[StackerGroup].JamSensor, g_StackerProcess[StackerGroup].Common.CurTimer);
		RunIOCounter(g_StackerProcess[StackerGroup].CheckSensor, g_StackerProcess[StackerGroup].Common.CurTimer);

		CASE g_StackerProcess[StackerGroup].Common.State OF

			(*####################################*)
			(* Start Up Machine, Home Axels etc.. *)
			(*####################################*)

			MACHPROC_INIT_0:
				g_StackerProcess[StackerGroup].FlapsClose						:= FALSE;

			MACHPROC_STARTUP_1:

				(* Run for a while to ensure process is clean *)
				g_StackerProcess[StackerGroup].Common.WatchDogRunTimer 			:= g_StackerProcess[StackerGroup].Common.CurTimer;							(* start watchdog timer for process *)
				g_StackerEarlyRelease := FALSE;
				g_StackerNormRelease := FALSE;
				g_StackerProcess[StackerGroup].Common.Previous.TransferStatus 	:= EXC_STANDBY_0;
			
				// Lägg in nolsställ av NextStacker group om det behövs...
			
				g_StackerProcess[StackerGroup].FlapsClose						:= TRUE;
				g_StackerProcess[StackerGroup].Common.State 					:= MACHPROC_RUN_20;

			(*###############################################################*)
			(* Machine Stop case, to handle shut down process of the module  *)
			(*###############################################################*)

			MACHPROC_STOP_15:
				;
				(* Reset output and handle the shutdown procedure *)
				(* Extra stop cases may be needed.. *)

				g_StackerProcess[StackerGroup].Common.State 						:= MACHPROC_INIT_0;
				g_StackerProcess[StackerGroup].Common.Motor.cmdStop					:= TRUE;

			(*#####################*)
			(* Main running state  *)
			(*#####################*)

			MACHPROC_RUN_20:

   				
				(* Start the flow of goods *)
				IF g_StackerProcess[StackerGroup].Common.Previous.TransferStatus = EXC_WANT_TO_UNLOAD_1 THEN

					g_StackerEarlyRelease := FALSE;
					g_StackerNormRelease := FALSE;
					g_StackerProcess[StackerGroup].Common.AlarmList.Alarm[5] := FALSE;
					g_StackerProcess[StackerGroup].Common.AlarmList.Alarm[6] := FALSE;
					IF g_StackerProcess[StackerGroup].Common.InSensor.Output AND NOT g_StackerEarlyRelease THEN
						IF NOT g_StackerProcess[StackerGroup].Common.AlarmList.Alarm[5] THEN
							g_StackerProcess[StackerGroup].Common.AlarmList.Alarm[5] 	:= TRUE;
							g_StackerProcess[StackerGroup].Common.State 				:= MACHPROC_TRIG_ERROR_98;	
						END_IF
					ELSE
						g_StackerProcess[StackerGroup].Common.Motor.cmdForward			:= TRUE;			// 09-11-23..
						g_StackerProcess[StackerGroup].Common.Previous.TransferStatus 	:= EXC_READY_TO_RECIEVE_2;
						g_StackerProcess[StackerGroup].Common.State						:= MACHPROC_WAIT_FOR_JOB_22;
					END_IF				
				ELSE
					g_StackerProcess[StackerGroup].Common.Previous.TransferStatus 	:= EXC_STANDBY_0;
				END_IF

			MACHPROC_WAIT_FOR_JOB_22:

				(* Previous task is ready to unload*)
				IF g_StackerProcess[StackerGroup].Common.Previous.TransferStatus = EXC_UNLOADING_3 THEN	
					GetIOCounterEdgeFlank(g_StackerProcess[StackerGroup].Common.InSensor);
					GetIOCounterTrailFlank(g_StackerProcess[StackerGroup].Common.InSensor);
					g_StackerProcess[StackerGroup].Common.Product					:= g_StackerProcess[StackerGroup].Common.Previous.Product;
					g_StackerProcess[StackerGroup].Common.ReadParameters			:= TRUE;
					g_StackerProcess[StackerGroup].Common.Previous.TransferStatus 	:= EXC_RECIVING_4;  
					g_StackerProcess[StackerGroup].Common.Motor.cmdForward			:= TRUE;
					g_StackerProcess[StackerGroup].Common.InSensor.OldCounter 		:= g_StackerProcess[StackerGroup].Common.InSensor.Counter;
					g_StackerProcess[StackerGroup].Common.InSensor.OldTrailCounter 	:= g_StackerProcess[StackerGroup].Common.InSensor.TrailCounter;
					g_StackerProcess[StackerGroup].Common.InSensor.OldEdgeCounter	:= g_StackerProcess[StackerGroup].Common.InSensor.EdgeCounter;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, Trig air blast');
					g_StackerProcess[StackerGroup].AirBlastFlaps.State := FOLDIO_STATE_START_1;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, data OK from XB');
					g_StackerProcess[StackerGroup].Common.WatchDogRunTimer 			:= g_StackerProcess[StackerGroup].Common.CurTimer;				
					g_StackerProcess[StackerGroup].Common.State 					:= MACHPROC_WAIT_FOR_TRIG_23;
				END_IF


			MACHPROC_WAIT_FOR_TRIG_23:

				// To trigger the flow of goods
				IF g_StackerProcess[StackerGroup].Common.TrigMode = TRIG_MODE_RAISING_FLANK_0 THEN
					IF GetIOCounterEdgeFlank(g_StackerProcess[StackerGroup].Common.InSensor) = 1 THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, Flanktrig');
						g_StackerProcess[StackerGroup].Common.FoldPointTimer 		:= g_StackerProcess[StackerGroup].Common.CurTimer;
					END_IF
					IF g_StackerProcess[StackerGroup].Common.InSensor.EdgeCounter <> g_StackerProcess[StackerGroup].Common.InSensor.OldEdgeCounter THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, Sensor ok');
						IF g_StackerProcess[StackerGroup].Common.Product.SortOut = SORTOUT_AFTER_STACKER_2 THEN
							g_StackerProcess[StackerGroup].Common.State 				:= MACHPROC_SORTOUT_40;
							// Stack to next stacker group, double code se below	
						ELSIF g_StackerProcess[StackerGroup].Common.Product.Stack > (StackerGroup) THEN	// special case only one stack per module
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, Go to next stg');
							g_StackerProcess[StackerGroup].Common.FoldPointTimer		:= g_StackerProcess[StackerGroup].Common.CurTimer;
							HoldPointNext												:= 800;
							g_StackerProcess[StackerGroup].Common.State 				:= MACHPROC_SORTOUT_40;
						ELSE
							g_StackerProcess[StackerGroup].Common.State 				:= MACHPROC_WAIT_FOLD_POINT_25;
						END_IF
						g_StackerProcess[StackerGroup].Common.WatchDogRunTimer := g_StackerProcess[StackerGroup].Common.CurTimer;				
					END_IF
				ELSE
					IF GetIOCounterTrailFlank(g_StackerProcess[StackerGroup].Common.InSensor) = 1 THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, Trailtrig');
						g_StackerProcess[StackerGroup].Common.FoldPointTimer 		:= g_StackerProcess[StackerGroup].Common.CurTimer;
					END_IF
					IF g_StackerProcess[StackerGroup].Common.InSensor.TrailCounter <> g_StackerProcess[StackerGroup].Common.InSensor.OldTrailCounter THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, Trailok');
						IF g_StackerProcess[StackerGroup].Common.Product.SortOut = SORTOUT_AFTER_STACKER_2 THEN
							g_StackerProcess[StackerGroup].Common.State 				:= MACHPROC_SORTOUT_40;
							// Stack to next stacker group, double code se above	
						ELSIF g_StackerProcess[StackerGroup].Common.Product.Stack > (StackerGroup) THEN	// special case only one stack per module
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, Go to next stg');
							g_StackerProcess[StackerGroup].Common.FoldPointTimer		:= g_StackerProcess[StackerGroup].Common.CurTimer;	
							HoldPointNext												:= 300;
							g_StackerProcess[StackerGroup].Common.State 				:= MACHPROC_SORTOUT_40;
						ELSE
							g_StackerProcess[StackerGroup].Common.State 				:= MACHPROC_WAIT_FOLD_POINT_25;
						END_IF
						g_StackerProcess[StackerGroup].Common.WatchDogRunTimer := g_StackerProcess[StackerGroup].Common.CurTimer;				
					END_IF
				END_IF

			// To trigger the air pipe before the stacker flaps...
			//IF g_StackerProcess[StackerGroup].Common.InSensor.EdgeCounter > g_StackerProcess[StackerGroup].Common.InSensor.OldEdgeCounter THEN
			//IF g_StackerProcess[StackerGroup].Common.InSensor.Input > OldInsensor[StackerGroup] THEN
			//				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, Trig air blast');
			//				g_StackerProcess[StackerGroup].AirBlastFlaps.State := FOLDIO_STATE_START_1;
			//			END_IF
			//			OldInsensor[StackerGroup] := g_StackerProcess[StackerGroup].Common.InSensor.Input;



			MACHPROC_WAIT_FOLD_POINT_25:

				IF ElapsedMsTime(g_StackerProcess[StackerGroup].Common.CurTimer, g_StackerProcess[StackerGroup].Common.FoldPointTimer) >= g_StackerProcess[StackerGroup].Common.FoldPointTime THEN (* Cycle should be ended *)
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, Foldpoint');
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_StackerProcess[StackerGroup].Common.FoldPointTime, 'Stack, Fold point');
					g_StackerProcess[StackerGroup].FlapDelayReached			:= FALSE;
					g_StackerProcess[StackerGroup].FlapsDelayOpenTimer 		:= g_StackerProcess[StackerGroup].Common.CurTimer;
					g_StackerProcess[StackerGroup].Common.Motor.cmdHold		:= TRUE;
					g_StackerProcess[StackerGroup].Common.State 				:= MACHPROC_DELIVER_PACKAGE_80;
				END_IF



			// Check next stacker group 
			MACHPROC_SORTOUT_40:
			
				// Update here can wait long time for next stg...
				g_StackerProcess[StackerGroup].Common.WatchDogRunTimer := g_StackerProcess[StackerGroup].Common.CurTimer;				
			
				// Check hold point, to stop stacker belt before exit to next stacker group...
				IF ElapsedMsTime(g_StackerProcess[StackerGroup].Common.CurTimer, g_StackerProcess[StackerGroup].Common.FoldPointTimer) >= HoldPointNext THEN 
					IF g_StackerProcess[StackerGroup].Common.Motor.Run THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, StackerGroup, 'Stack, reached hold point');
						g_StackerProcess[StackerGroup].Common.Motor.cmdHold := TRUE;
					END_IF	
				END_IF

				// Start handshake whit next stacker group..
				IF g_StackerProcess[StackerGroup].NextStackerGroup.TransferStatus = EXC_STANDBY_0 THEN
					g_StackerProcess[StackerGroup].NextStackerGroup.Product			:= g_StackerProcess[StackerGroup].Common.Product;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, StackerGroup, 'Stack, product to next stg');
					g_StackerProcess[StackerGroup].NextStackerGroup.TransferStatus 	:= EXC_WANT_TO_UNLOAD_1;
				ELSIF g_StackerProcess[StackerGroup].NextStackerGroup.TransferStatus = EXC_READY_TO_RECIEVE_2 OR StackerGroup+1 > NUMBER_OF_STACKERGROUPS THEN				
					g_StackerProcess[StackerGroup].NextStackerGroup.TransferStatus 	:= EXC_UNLOADING_3;		// Next is waiting for photocell..	
					g_StackerProcess[StackerGroup].Common.Product.Length			:= 0;		// Reset after copied data to next group to indicate if valid...
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, StackerGroup, 'Stack, continue forward');
					g_StackerProcess[StackerGroup].Common.Motor.cmdForward			:= TRUE;
					g_StackerProcess[StackerGroup].Common.ExitTime					:= 1900;
					g_StackerProcess[StackerGroup].Common.ExitTimer					:= g_StackerProcess[StackerGroup].Common.CurTimer;
					g_StackerProcess[StackerGroup].Common.Previous.TransferStatus := EXC_STANDBY_0;		// Release next garment into XB, XA...
					g_StackerEarlyRelease := TRUE;
					g_StackerProcess[StackerGroup].Common.State 					:= MACHPROC_DELIVER_NEXT_STG_45;
				END_IF

			
			
			// Wait for stack to leave this stacker group...
			MACHPROC_DELIVER_NEXT_STG_45:	
			
				// Stack has left this stacker group...
				IF ElapsedMsTime(g_StackerProcess[StackerGroup].Common.CurTimer, g_StackerProcess[StackerGroup].Common.ExitTimer) >= g_StackerProcess[StackerGroup].Common.ExitTime THEN 
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, StackerGroup, 'Stack, delivered to next stg');
					g_StackerProcess[StackerGroup].Common.Motor.cmdStop				:= TRUE;
					g_StackerProcess[StackerGroup].NextStackerGroup.TransferStatus	:= EXC_STANDBY_0;	
					g_StackerProcess[StackerGroup].Common.Previous.TransferStatus := EXC_STANDBY_0;		// Release next garment into XB, XA...
					g_StackerNormRelease := TRUE;
					g_StackerProcess[StackerGroup].Common.State 					:= MACHPROC_RUN_20;
				END_IF
			
			// Can this fail do we need any fault controll ???
			
			

			MACHPROC_DELIVER_PACKAGE_80:
	
				(* Even if outlet is ready direct must Flap delay run so Stacker is stoped ok before doors are opened *)
				IF NOT g_StackerProcess[StackerGroup].FlapDelayReached AND ElapsedMsTime(g_StackerProcess[StackerGroup].Common.CurTimer, g_StackerProcess[StackerGroup].FlapsDelayOpenTimer) >= g_MCfg.Stacker.FlapsDelayOpen THEN (* Cycle should be ended *)
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, Flap delay reached 1');
					g_StackerProcess[StackerGroup].FlapDelayReached			:= TRUE;
				END_IF

				// 09-08-10 If error reset transfer status...
				IF g_StackerProcess[StackerGroup].Common.Next.TransferStatus = EXC_READY_TO_RECIEVE_2 THEN	
					g_StackerProcess[StackerGroup].Common.Next.TransferStatus :=  EXC_STANDBY_0;
				END_IF	


				// 10-20-04 If error reset transfer status...
				IF g_StackerProcess[StackerGroup].Common.Next.TransferStatus = EXC_WANT_TO_UNLOAD_1 THEN	
					g_StackerProcess[StackerGroup].Common.Next.TransferStatus :=  EXC_STANDBY_0;
				END_IF	


				// 10-03-30 If error reset transfer status...
				IF g_StackerProcess[StackerGroup].Common.Next.TransferStatus = EXC_ERROR_99 THEN	
					g_StackerProcess[StackerGroup].Common.Next.TransferStatus :=  EXC_STANDBY_0;
				END_IF	



				// Wait for next task to prepare to take over product. 
				IF g_StackerProcess[StackerGroup].Common.Next.TransferStatus = EXC_STANDBY_0 THEN
					g_StackerProcess[StackerGroup].Common.Next.Product 			:= g_StackerProcess[StackerGroup].Common.Product;
					//g_StackerProcess[StackerGroup].Common.Product.Length		:= 0;		// Reset after copied data to next group to indicate if valid...
					g_StackerProcess[StackerGroup].Common.Next.TransferStatus 	:= EXC_WANT_TO_UNLOAD_1;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, start deliver');
					g_StackerProcess[StackerGroup].Common.State 				:= MACHPROC_PACKAGE_DELIVERED_81;
				END_IF
			g_StackerProcess[StackerGroup].Common.WatchDogRunTimer 	:= g_StackerProcess[StackerGroup].Common.CurTimer;							(* start watchdog timer for process *)

			MACHPROC_PACKAGE_DELIVERED_81:
		
				// 10-05-03 If error reset transfer status...
				IF g_StackerProcess[StackerGroup].Common.Next.TransferStatus = EXC_STANDBY_0 THEN	
					g_StackerProcess[StackerGroup].Common.Next.TransferStatus :=  EXC_WANT_TO_UNLOAD_1;
				END_IF	
		

				(* Even if outlet is ready direct must Flap delay run so Stacker is stoped ok before doors are opened *)
				IF NOT g_StackerProcess[StackerGroup].FlapDelayReached AND ElapsedMsTime(g_StackerProcess[StackerGroup].Common.CurTimer, g_StackerProcess[StackerGroup].FlapsDelayOpenTimer) >= g_MCfg.Stacker.FlapsDelayOpen THEN (* Cycle should be ended *)
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, Flap delay reached 2');
					g_StackerProcess[StackerGroup].FlapDelayReached			:= TRUE;
				END_IF

				IF g_StackerProcess[StackerGroup].Common.Next.TransferStatus = EXC_READY_TO_RECIEVE_2 THEN
					IF g_StackerProcess[StackerGroup].Common.InSensor.Output = 0 THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, sensor free. ok next');
					END_IF
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, Outlet is ready');
					g_StackerProcess[StackerGroup].Common.State 					:= MACHPROC_FLAP_DELAY_90;
				END_IF
			g_StackerProcess[StackerGroup].Common.WatchDogRunTimer 			:= g_StackerProcess[StackerGroup].Common.CurTimer;							(* start watchdog timer for process *)

			MACHPROC_FLAP_DELAY_90:

				// Wait for belt to stop before flaps are opened 
				IF g_StackerProcess[StackerGroup].FlapDelayReached OR ElapsedMsTime(g_StackerProcess[StackerGroup].Common.CurTimer, g_StackerProcess[StackerGroup].FlapsDelayOpenTimer) >= g_MCfg.Stacker.FlapsDelayOpen THEN 
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, Open flap');
					IF g_EnableRecipeLogData THEN
						LogData_0(Type := 1, Lane := UINT_TO_USINT(g_StackerProcess[StackerGroup].Common.Product.Stack), Info1 := g_StackerProcess[StackerGroup].Common.Product.FoldProgram, Info2 := ADR(g_StackerProcess[StackerGroup].Common.Product.RecipeName));
					ELSE
						LogData_0(Type := 1, Lane := UINT_TO_USINT(g_StackerProcess[StackerGroup].Common.Product.Stack));
					END_IF						
					g_StackerProcess[StackerGroup].Common.Next.TransferStatus 	:= EXC_UNLOADING_3;
					g_StackerProcess[StackerGroup].FlapsClose						:= FALSE;
					g_StackerProcess[StackerGroup].Common.State 					:= MACHPROC_EXECUTE_FOLDPOINT_91;
				END_IF
				g_StackerProcess[StackerGroup].Common.WatchDogRunTimer 			:= g_StackerProcess[StackerGroup].Common.CurTimer;							(* start watchdog timer for process *)
				g_StackerProcess[StackerGroup].Common.Previous.TransferStatus := EXC_STANDBY_0;		// Release next garment into XB, XA...
				g_StackerEarlyRelease := TRUE;

			MACHPROC_EXECUTE_FOLDPOINT_91:

				g_StackerProcess[StackerGroup].FlapsClose								:= FALSE;		(* Keep open all the time until ok from outlet *)
		
				// FOX.. To resolve error situation..
				IF g_StackerProcess[StackerGroup].Common.Next.TransferStatus = EXC_STANDBY_0 THEN
					g_StackerProcess[StackerGroup].Common.Next.TransferStatus := EXC_WANT_TO_UNLOAD_1;
				ELSIF g_StackerProcess[StackerGroup].Common.Next.TransferStatus = EXC_READY_TO_RECIEVE_2 THEN
					g_StackerProcess[StackerGroup].Common.Next.TransferStatus := EXC_UNLOADING_3;
				END_IF
			
				// Lift has got the garment and is below photocell...	
				IF g_StackerProcess[StackerGroup].Common.Next.TransferStatus = EXC_RECIVING_4 THEN
					// Add statistics here 
					IF g_MCfg.StatisticStackOrSection = STATISTICS_ON_STACK_0 THEN
						IF (g_StackerProcess[StackerGroup].Common.Product.FoldProgram > 0) AND (g_StackerProcess[StackerGroup].Common.Product.FoldProgram < 100)THEN
							g_Statistic[g_StackerProcess[StackerGroup].Common.Product.FoldProgram].Pieces[g_StackerProcess[StackerGroup].Common.Product.Stack] 	:= g_Statistic[g_StackerProcess[StackerGroup].Common.Product.FoldProgram].Pieces[g_StackerProcess[StackerGroup].Common.Product.Stack] + 1;
						END_IF
						g_Statistic[0].Pieces[g_StackerProcess[StackerGroup].Common.Product.Stack]	:= g_Statistic[0].Pieces[g_StackerProcess[StackerGroup].Common.Product.Stack] + 1;
						g_PieceCount[g_StackerProcess[StackerGroup].Common.Product.Stack]			:= g_PieceCount[g_StackerProcess[StackerGroup].Common.Product.Stack] + 1;
					ELSE
						g_Statistic[g_StackerProcess[StackerGroup].Common.Product.FoldProgram].Pieces[g_StackerProcess[StackerGroup].Section] 	:= g_Statistic[g_StackerProcess[StackerGroup].Common.Product.FoldProgram].Pieces[g_StackerProcess[StackerGroup].Section] + 1;
						g_Statistic[0].Pieces[g_StackerProcess[StackerGroup].Section]				:= g_Statistic[0].Pieces[g_StackerProcess[StackerGroup].Section] + 1;
						g_PieceCount[g_StackerProcess[StackerGroup].Section]						:= g_PieceCount[g_StackerProcess[StackerGroup].Section] + 1;
					END_IF
					// Statistic for Article...
					g_Statistic[g_StackerProcess[StackerGroup].Common.Product.FoldProgram].Pieces[0] 			:= g_Statistic[g_StackerProcess[StackerGroup].Common.Product.FoldProgram].Pieces[0] + 1;
					// Statistic for Autoprogram...
					g_Statistic[g_StackerProcess[StackerGroup].Common.Product.SelectedAutoProg].AutoProgPieces[0]													:= g_Statistic[g_StackerProcess[StackerGroup].Common.Product.SelectedAutoProg].AutoProgPieces[0] + 1;			
					g_Statistic[g_StackerProcess[StackerGroup].Common.Product.SelectedAutoProg].AutoProgPieces[g_StackerProcess[StackerGroup].Common.Product.Stack] 	:= g_Statistic[g_StackerProcess[StackerGroup].Common.Product.SelectedAutoProg].AutoProgPieces[g_StackerProcess[StackerGroup].Common.Product.Stack] + 1;

					(* JenView Count compare *)
					g_PieceCount[0]														:= g_PieceCount[0] + 1;
					g_StackerProcess[StackerGroup].Common.ExitTimer 					:= g_StackerProcess[StackerGroup].Common.CurTimer;
					g_StackerProcess[StackerGroup].Common.State 						:= MACHPROC_WAIT_BEFORE_CLOSE_92;
				END_IF
				g_StackerProcess[StackerGroup].Common.WatchDogRunTimer 					:= g_StackerProcess[StackerGroup].Common.CurTimer;

			// This is really wait before close...
			MACHPROC_WAIT_BEFORE_CLOSE_92:

				IF ElapsedMsTime(g_StackerProcess[StackerGroup].Common.CurTimer, g_StackerProcess[StackerGroup].Common.ExitTimer) >= g_MCfg.Stacker.FlapsTimeOpen THEN
					//g_StackerProcess[StackerGroup].Common.ExitTimer 				:= g_StackerProcess[StackerGroup].Common.CurTimer;
					//				g_StackerProcess[StackerGroup].FlapsClose						:= TRUE;
					//				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, Tell lift to go down');
					//				g_StackerProcess[StackerGroup].Common.State 					:= MACHPROC_WAIT_BEFORE_RESTART_93;
					//				g_StackerProcess[StackerGroup].Common.WatchDogRunTimer 			:= g_StackerProcess[StackerGroup].Common.CurTimer;
				
					// Moved here 10-12-01 by POX, to speed up the machine..			
					g_StackerProcess[StackerGroup].Common.Previous.TransferStatus := EXC_STANDBY_0;		// Release next garment into XB, XA...
					g_StackerNormRelease := TRUE;
					// 10-01-27 To check additional sensor before we close flaps to se that no garment is stucked.
					IF g_StackerProcess[StackerGroup].CheckSensor.Output THEN
						g_StackerProcess[StackerGroup].Common.AlarmList.Alarm[6] 	:= TRUE;
						g_StackerProcess[StackerGroup].Common.State 				:= MACHPROC_TRIG_ERROR_98;		
					ELSE
						g_StackerProcess[StackerGroup].Common.ExitTimer 				:= g_StackerProcess[StackerGroup].Common.CurTimer;
						g_StackerProcess[StackerGroup].FlapsClose						:= TRUE;
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, Tell lift to go down');
						g_StackerProcess[StackerGroup].Common.State 					:= MACHPROC_WAIT_BEFORE_RESTART_93;
						g_StackerProcess[StackerGroup].Common.WatchDogRunTimer 			:= g_StackerProcess[StackerGroup].Common.CurTimer;
					END_IF	
				END_IF

			// Wait for lift to go down...
			MACHPROC_WAIT_BEFORE_RESTART_93:
				IF ElapsedMsTime(g_StackerProcess[StackerGroup].Common.CurTimer, g_StackerProcess[StackerGroup].Common.ExitTimer) >= g_StackerProcess[StackerGroup].Common.ExitTime THEN
					g_StackerProcess[StackerGroup].Common.ExitTimer 				:= g_StackerProcess[StackerGroup].Common.CurTimer;
					g_StackerProcess[StackerGroup].Common.Next.TransferStatus 		:= EXC_FINISHED_UNLOADING_5;
					g_StackerProcess[StackerGroup].Common.Product.Length			:= 0;		// Reset after copied data to next group to indicate if valid...
					g_StackerProcess[StackerGroup].FlapsClose						:= TRUE;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, Wait fot lift down');
					// 09-09-29 POX To have no garment in XB...
					//g_StackerProcess[StackerGroup].Common.Previous.TransferStatus := EXC_STANDBY_0;  // Moved one step up to speed up machine POX 10-12-01...
					g_StackerProcess[StackerGroup].Common.State 					:= MACHPROC_WAIT_CLOSE_94;
					g_StackerProcess[StackerGroup].Common.WatchDogRunTimer 			:= g_StackerProcess[StackerGroup].Common.CurTimer;
				END_IF
		
			// Wait for flaps to close	
			MACHPROC_WAIT_CLOSE_94:
	
				IF ElapsedMsTime(g_StackerProcess[StackerGroup].Common.CurTimer, g_StackerProcess[StackerGroup].Common.ExitTimer) >= g_StackerProcess[StackerGroup].Common.ExitTime THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, Flaps are closed');
					g_StackerProcess[StackerGroup].Common.Motor.cmdForward		:= TRUE;
					g_StackerProcess[StackerGroup].Common.State 				:= MACHPROC_RUN_20;
					g_StackerProcess[StackerGroup].Common.WatchDogRunTimer 		:= g_StackerProcess[StackerGroup].Common.CurTimer;
				END_IF
			
			MACHPROC_TRIG_ERROR_98:
				g_StackerProcess[StackerGroup].FlapsClose := FALSE;
				g_StackerProcess[StackerGroup].Common.Next.TransferStatus := EXC_ERROR_99;

			MACHPROC_ERROR_99:	
				g_StackerProcess[StackerGroup].FlapsClose := FALSE;
				g_StackerProcess[StackerGroup].Common.Next.TransferStatus := EXC_ERROR_99;

					
		
		END_CASE

		//V1.06.0				
		(*special solution for the alarm Jam SGT 1*)
		JamBugFix;	



		// Check what this is doing ?? POX 09-12-02..	
		(* Detect if error occurs and what to do *)
		IF 	g_StackerProcess[StackerGroup].Common.State >= MACHPROC_RUN_20 AND
			g_StackerProcess[StackerGroup].Common.State < MACHPROC_TRIG_ERROR_98 THEN
			IF ElapsedMsTime(g_StackerProcess[StackerGroup].Common.CurTimer, g_StackerProcess[StackerGroup].Common.WatchDogRunTimer) > (g_StackerProcess[StackerGroup].Common.WatchDogRunTime-100) THEN
				IF g_StackerProcess[StackerGroup].Common.State <= MACHPROC_WAIT_FOR_TRIG_23 THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, Timeout 1');
					// Removed this 10-03-12 POX
					//g_StackerProcess[StackerGroup].Common.State := MACHPROC_RUN_20;
				ELSIF g_StackerProcess[StackerGroup].Common.State >= MACHPROC_DELIVER_PACKAGE_80 THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_StackerProcess[0].Common.LogBookFlag, g_DummyPulses, 'Stack, Timeout 2');
					// Removed this 10-03-15 POX
					//g_StackerProcess[StackerGroup].Common.State := MACHPROC_RUN_20;
				ELSE
					; (* Do nothing, this is a true timeout *)
				END_IF
			END_IF
		END_IF

		// If inlet photocell covered to long trigger an alarm...
		IF g_StackerProcess[StackerGroup].JamSensor.Output THEN
			// Photocell can be covered when XB does a long pieces and rewerse before delivery...
			IF g_StackerProcess[StackerGroup].Common.State > MACHPROC_WAIT_FOR_JOB_22 AND (g_StackerProcess[StackerGroup].Common.State < MACHPROC_TRIG_ERROR_98) THEN
				g_StackerProcess[StackerGroup].Common.ErrorCode				:= 7;
				g_StackerProcess[StackerGroup].Common.State 				:= MACHPROC_TRIG_ERROR_98;
			END_IF	
		END_IF	



		g_StackerProcess[StackerGroup].Common.InSensor.OldCounter			:= g_StackerProcess[StackerGroup].Common.InSensor.Counter;
		g_StackerProcess[StackerGroup].Common.InSensor.OldEdgeCounter		:= g_StackerProcess[StackerGroup].Common.InSensor.EdgeCounter;
		g_StackerProcess[StackerGroup].Common.InSensor.OldTrailCounter 	:= g_StackerProcess[StackerGroup].Common.InSensor.TrailCounter;


		// To make sure transferstatus is copied back when StackerGroup has runned it's cycle and not before...
		CASE StackerGroup OF 
			1:
				g_StackerProcess[2].Common.Previous     := g_StackerProcess[1].NextStackerGroup;
			2: 
				g_StackerProcess[3].Common.Previous     := g_StackerProcess[2].NextStackerGroup;
			3: 
				g_StackerProcess[4].Common.Previous     := g_StackerProcess[3].NextStackerGroup;
			4: 
				g_StackerProcess[5].Common.Previous     := g_StackerProcess[4].NextStackerGroup;	
		END_CASE

	END_FOR

	// Outputs
	FOR i := 1 TO NUMBER_OF_STACKERGROUPS DO
		QMStacker[i]		:= g_StackerProcess[i].Common.Motor.Run AND g_Core.System.Runtime.isRunning;
		QYStackerFlap[i]	:= NOT g_StackerProcess[i].FlapsClose AND g_Core.System.Runtime.isRunning;			
		QYBrakeStacker[i]	:= NOT QMStacker[i] AND g_Core.System.Runtime.isRunning;
		QYStackerAir[i]		:= g_StackerProcess[i].AirBlastFlaps.Output;
		// PMU: Xtreme Heavy Option
		QYRaiseStackerBelt	:= (g_StackerProcess[i].XtremeHeavy AND g_Core.System.Runtime.isRunning) OR g_XtremeHeavy.RaiseStackerBelt;
		QYSlackStackerBelt 	:= (g_StackerProcess[i].XtremeSlackBelt AND g_Core.System.Runtime.isRunning) OR g_XtremeHeavy.SlackStackerBelt;
	END_FOR

END_PROGRAM

