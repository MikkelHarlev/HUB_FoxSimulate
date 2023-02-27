(********************************************************************
 * COPYRIGHT -- IT
 ********************************************************************
 * Program: h_opener
 * File: h_opener.st
 * Author: mariw
 * Created: May 26, 2011
 ********************************************************************
 * Implementation OF program h_opener
 ********************************************************************) 

ACTION HangerOpenerInit :
	
	// Always set the ForcedNoCom to false at startup...
	g_HangerInletProcess.ForcedNoCom 	:= 0;			

	// Individual settings for the task 
	g_HangerOpenerProcess.Common.Description 			:= 'Hanger opener';
	InitFoldTask(g_HangerOpenerProcess.Common, g_MachineManager[g_HangerOpenerProcess.Common.MachineManagerIndex]);

	HangerInDUChecked := FALSE; 
	HangerValue[2] := 25;
	HangerValue[3] := 25;
	
	Preset.WatchDogStartupTime := 5000;
	Preset.WatchDogRunTime := 3000;
	
	DelayDown.CntAdr := ADR(g_MilliSeconds);
	DelayDown.Delay := 500;
	DelayDown();
	
	g_TopConveyorProcess;
	
	HangerClamp_Delay.Delay := 150;
	
	HangerHammer_Delay.Delay := 100;

	HornRelease_Delay.Delay := 100;
	
END_ACTION


(*Add a new action to your IEC program or library*)
ACTION HangerOpener: 


//#############################################################################################################################
// Note:
// When we have the option Combi Hanger the g_HangerOpenerProcess.HangerResetLower is used as the hanger reset output
// and the g_HangerOpenerProcess.HangerResetUpper is not used for any thing..
//#############################################################################################################################


(*#####################*)
(* Get current time... *)
(*#####################*)
	g_HangerOpenerProcess.Common.CurTimer 						:= g_Timers._1_ms;						(* Get current time *)
	IF g_HangerOpenerProcess.Common.LogBookFlag > 0 THEN
		strcpy(ADR(TmpStr),ADR(g_HangerOpenerProcess.Common.Description));
	END_IF

	ACfgProgram := LIMIT(0, g_HangerOpenerProcess.Common.Product.FoldProgram - 1, 98);
	
	g_MCfg.Deloading.dwPos := LIMIT(-300, g_MCfg.Deloading.dwPos, 500);
	g_MCfg.Deloading.upPos := LIMIT(3500, g_MCfg.Deloading.upPos, 5000);

	g_HangerOpenerProcess.DelayHornTime		:= 10;
	BeltStartTime							:= 200;
	g_HangerOpenerProcess.BlockDelayTime	:= 50;

	(*#################################*)
	(* copy status of exchange objects *)
	(*#################################*)

	g_HangerOpenerProcess.Common.Previous		:= g_HangerInletProcess.Common.Next;
	g_HangerOpenerProcess.Common.Next			:= g_TopConveyorProcess.Common.Previous;


	(*########################################*)
	(* Connect inputs to the module structure *)
	(*########################################*)

	g_HangerOpenerProcess.HangerInPosition.Input			:= IBHangerDeloadReady OR g_sim.IBHangerDeloadReady;
	//g_HangerOpenerProcess.HangerJam.Input					:= X_GarmentStillOnHanger; // Old name was to long...
	g_HangerOpenerProcess.HangerJam.Input					:= IBHangerMove OR g_sim.IBHangerMove;
	g_HangerOpenerProcess.CheckHangerInDU.Input				:= IBJamDeloading OR g_sim.IBJamDeloading;
	g_HangerOpenerProcess.HangerOutOfMachine.Input			:= IIJamDeloadingOut OR g_sim.IIJamDeloadingOut;

	(*######################*)
	(* Connect timer values *)
	(*######################*)

	g_HangerOpenerProcess.Common.WatchDogStartupTime			:= Preset.WatchDogStartupTime; // 4000;
	g_HangerOpenerProcess.Common.WatchDogRunTime					:= Preset.WatchDogRunTime; // 3000;
	g_HangerOpenerProcess.Common.InSensor.OnDelay				:= 2;
	g_HangerOpenerProcess.Common.InSensor.OffDelay				:= 2;



	g_HangerOpenerProcess.HangerJam.OnDelay						:= HangerValue[2];	//10-01-27
	g_HangerOpenerProcess.HangerJam.OffDelay					:= HangerValue[3];	//10-01-27
	g_HangerOpenerProcess.HangerOutOfMachine.OnDelay			:= 1;
	g_HangerOpenerProcess.HangerOutOfMachine.OffDelay			:= 1;
	g_HangerOpenerProcess.StartDelayLifterTime					:= g_MCfg.Deloading.StartLiftTime;
	g_HangerOpenerProcess.StartDelayOpenerTime					:= g_MCfg.Deloading.HangerInPlateTime;
	g_HangerOpenerProcess.HangerCloseTime						:= g_MCfg.Deloading.HangerResetTime;			// Reset time of hanger, start at PreUpper sensor 
	g_HangerOpenerProcess.HangerSlideOutTime					:= g_MCfg.Deloading.HangerSlideOutTime;		
	g_HangerOpenerProcess.HangerResetTime						:= g_MCfg.Deloading.HangerResetDelay;		// Time after Photocell to start reset of hanger 

	g_HangerOpenerProcess.PajamasMotorRunTime					:= g_MCfg.Deloading.PajamasStopPos;	
	g_HangerOpenerProcess.PajamasDelayLiftTime					:= g_MCfg.Deloading.PajamasRestartDelay;
	g_HangerOpenerProcess.PajamePreBreaking.OnTime				:= g_MCfg.Deloading.PajamePreBreakingTime;	

	g_HangerOpenerProcess.PressResetTime 						:= g_MCfg.Deloading.PressResetTime;			
	IF g_HCfg.KGHanger THEN
		g_HangerOpenerProcess.HangerInPosition.OnDelay			:= 0;
	ELSE
		g_HangerOpenerProcess.HangerInPosition.OnDelay			:= 8;
	END_IF
	
	g_HangerOpenerProcess.HangerInPosition.OffDelay				:= 100;//300;

	g_HangerOpenerProcess.CheckHangerInDU.OnDelay				:= 8;
	g_HangerOpenerProcess.CheckHangerInDU.OffDelay				:= 30;//160;
	g_HangerOpenerProcess.NextHangerTime						:= 400;
	
	g_HangerOpenerProcess.CheckHangerFunction					:= TRUE;
	g_HangerOpenerProcess.CombiHanger							:= g_HCfg.CombiHanger;

 
	(*KG-Option*)
	IF g_HCfg.KGHanger THEN
		g_HangerOpenerProcess.KG_HangerDetectedToOpen.Input 	:= X_KG_OpenExtern_PH;
	
		g_HangerOpenerProcess.KG_HangerOpen.OnTime 				:= g_MCfg.Deloading.KG.OpenHangerTimeOn;
		g_HangerOpenerProcess.KG_HangerOpen.StartDelayTime 		:= g_MCfg.Deloading.KG.OpenHangerDelay;
	
		g_HangerOpenerProcess.KG_StopExtMotor.OnTime 			:= g_MCfg.Deloading.KG.StopExtMotorTimeOn;
		g_HangerOpenerProcess.KG_StopExtMotor.StartDelayTime 	:= g_MCfg.Deloading.KG.StopExtMotorDelay;
	
		//Set outputs	
		IF  EDGEPOS(g_HangerOpenerProcess.KG_HangerDetectedToOpen.Output) THEN
			g_HangerOpenerProcess.KG_HangerOpen.State := FOLDIO_STATE_START_1;
		END_IF;
		IF EDGEPOS(g_HangerOpenerProcess.KG_HangerDetectedToOpen.Output) THEN
			g_HangerOpenerProcess.KG_StopExtMotor.State := FOLDIO_STATE_START_1;
		END_IF;
	END_IF;




	(* Handle Input signals *)

	RunIOCounter(g_HangerOpenerProcess.HangerInPosition, g_HangerOpenerProcess.Common.CurTimer);
	RunIOCounter(g_HangerOpenerProcess.HangerJam, g_HangerOpenerProcess.Common.CurTimer);
	RunIOCounter(g_HangerOpenerProcess.HangerOutOfMachine, g_HangerOpenerProcess.Common.CurTimer);
	RunIOCounter(g_HangerOpenerProcess.CheckHangerInDU, g_HangerOpenerProcess.Common.CurTimer);
	RunIOCounter(g_HangerOpenerProcess.KG_HangerDetectedToOpen, g_HangerOpenerProcess.Common.CurTimer);

	IF NOT g_Core.System.Runtime.isRunning THEN
		g_MachineManager[g_HangerOpenerProcess.Common.MachineManagerIndex].Run := FALSE;
	END_IF

	IF EDGEPOS(HangerIsPresent) THEN
		g_HangerInletProcess.InFeedBeltRun.State		:= FOLDIO_STATE_IDLE_0;
		HangerInPositionActive := TRUE;
	END_IF
	IF NOT g_HangerOpenerProcess.HangerInPosition.Output THEN
		HangerInPositionActive := FALSE;
	END_IF	

	RunFoldTask(g_MCfg.Trace2File, ADR(T2FD), g_HangerOpenerProcess.Common, g_MachineManager[g_HangerOpenerProcess.Common.MachineManagerIndex]);

	CASE g_HangerOpenerProcess.Common.State OF

		(*####################################*)
		(* Start Up Machine, Home Axels etc.. *)
		(*####################################*)

		MACHPROC_INIT_0:

			g_HangerOpenerProcess.HangerClamp						:= FALSE;
			g_HangerOpenerProcess.HangerResetLower					:= FALSE;
			g_HangerOpenerProcess.HangerResetUpper					:= TRUE;
			g_HangerOpenerProcess.HangerHammer						:= FALSE;
			g_HangerOpenerProcess.HangerBlockClamp					:= FALSE;
			g_HangerOpenerProcess.Press 							:= FALSE;
			g_HangerOpenerProcess.WaitingRestart 					:= FALSE;
			Logged := FALSE;
			


		MACHPROC_STARTUP_1:

			g_HangerOpenerProcess.HangerClamp						:= FALSE;
			g_HangerOpenerProcess.HangerResetLower					:= FALSE;
			g_HangerOpenerProcess.HangerResetUpper					:= TRUE;
			g_HangerOpenerProcess.HangerHammer						:= FALSE;
			g_HangerOpenerProcess.HangerBlockClamp					:= FALSE;
			g_HangerOpenerProcess.Press 							:= FALSE;
			EdgePos_CheckHangerInDU									:= FALSE;
		
			g_HangerOpenerProcess.Common.Previous.TransferStatus 	:= EXC_STANDBY_0;
			g_HangerOpenerProcess.Common.Next.TransferStatus		:= EXC_STANDBY_0;	// 09-11-22

			g_HangerOpenerProcess.Common.WatchDogStartupTimer	:= g_HangerOpenerProcess.Common.CurTimer;
			
			// Simulation
			IF g_sim.Test THEN
				g_HangerOpenerProcess.Common.State 				:= MACHPROC_RUN_20;
			ELSE
				g_HangerOpenerProcess.Common.State 						:= 4;
			END_IF;

		4:	// Wait master homed and generel ready
			IF g_MasterStep = 100 THEN
				g_HangerOpenerProcess.Common.State 						:= 5;
			END_IF
			IF ElapsedMsTime(g_HangerOpenerProcess.Common.CurTimer, g_HangerOpenerProcess.Common.WatchDogStartupTimer) > g_HangerOpenerProcess.Common.WatchDogStartupTime THEN (* Machine started before Acopos is ready *)
				g_HangerOpenerProcess.Common.Previous.TransferStatus 	:= EXC_STANDBY_0;
				g_HangerOpenerProcess.Common.State 						:= MACHPROC_TRIG_ERROR_98;
				g_HangerOpenerProcess.Common.ErrorCode					:= 3;
			END_IF

		5:	// Move up.
			g_HangerOpenerProcess.Common.WatchDogStartupTimer	:= g_HangerOpenerProcess.Common.CurTimer;
			IF g_Axis[0].state = AXIS_IDLE THEN
				g_Axis[0].move.deceleration := g_MCfg.Deloading.decUp;
				g_Axis[0].move.acceleration := g_MCfg.Deloading.accUp;
				g_Axis[0].move.velocity := g_MCfg.Deloading.speedUp;
				g_Axis[0].move.position := g_MCfg.Deloading.upPos;
				g_Axis[0].state := AXIS_ABS; 
				DelayDown.Set := 1;
				g_HangerOpenerProcess.Common.State 						:= MACHPROC_STARTUP_2;
			END_IF

			(* Going up if not ok *)
		MACHPROC_STARTUP_2:

			g_HangerOpenerProcess.HangerClamp					:= TRUE;

			IF g_Axis[0].state = AXIS_IDLE AND NOT DelayDown.Out THEN
				g_HangerOpenerProcess.HangerBlockClamp				:= TRUE;
				g_HangerOpenerProcess.Common.WatchDogStartupTimer	:= g_HangerOpenerProcess.Common.CurTimer;
				DelayDown.Set := 1;
				g_HangerOpenerProcess.Common.State 					:= MACHPROC_STARTUP_3;
			END_IF

			IF ElapsedMsTime(g_HangerOpenerProcess.Common.CurTimer, g_HangerOpenerProcess.Common.WatchDogStartupTimer) > g_HangerOpenerProcess.Common.WatchDogStartupTime THEN (* Cycle should be ended *)
				g_HangerOpenerProcess.Common.WatchDogRunTimer 			:= g_HangerOpenerProcess.Common.CurTimer;			(* start watchdog timer for process *)
				g_HangerOpenerProcess.Common.Previous.TransferStatus 	:= EXC_STANDBY_0;
				g_HangerOpenerProcess.Common.State 						:= MACHPROC_TRIG_ERROR_98;
				g_HangerOpenerProcess.Common.ErrorCode					:= 3;
			END_IF


		MACHPROC_STARTUP_3:

			IF NOT DelayDown.Out THEN
				// There is a garment on the hanger
				IF g_HangerOpenerProcess.HangerJam.Output THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'HO, Garment on hanger startup');
					g_HangerOpenerProcess.Common.ErrorCode		:= 7;
					g_HangerOpenerProcess.Common.State 			:= MACHPROC_TRIG_ERROR_98;
				ELSIF g_HangerOpenerProcess.HangerOutOfMachine.Output THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'HO, Hanger out error startup');
					g_HangerOpenerProcess.Common.ErrorCode		:= 5;
					g_HangerOpenerProcess.Common.State 			:= MACHPROC_TRIG_ERROR_98;
				ELSIF g_Axis[0].state = AXIS_IDLE THEN
					g_Axis[0].move.deceleration := g_MCfg.Deloading.decDw;
					g_Axis[0].move.acceleration := g_MCfg.Deloading.accDw;
					g_Axis[0].move.velocity := g_MCfg.Deloading.speedDw;
					g_Axis[0].move.position := g_MCfg.Deloading.dwPos + g_ACfg[ACfgProgram].DeloaderDwPos;
					g_Axis[0].state := AXIS_ABS;
					DelayDown.Set := 1;
					g_HangerOpenerProcess.Common.WatchDogRunTimer 	:= g_HangerOpenerProcess.Common.CurTimer;					(* start watchdog timer for process *)
					g_HangerOpenerProcess.Common.State 			:= 6;
				END_IF				
			END_IF
		
			IF ElapsedMsTime(g_HangerOpenerProcess.Common.CurTimer, g_HangerOpenerProcess.Common.WatchDogStartupTimer) > g_HangerOpenerProcess.Common.WatchDogStartupTime THEN (* Cycle should be ended *)
				g_HangerOpenerProcess.Common.WatchDogRunTimer 			:= g_HangerOpenerProcess.Common.CurTimer;			(* start watchdog timer for process *)
				g_HangerOpenerProcess.Common.Previous.TransferStatus 	:= EXC_STANDBY_0;
				g_HangerOpenerProcess.Common.State 						:= MACHPROC_TRIG_ERROR_98;
				g_HangerOpenerProcess.Common.ErrorCode					:= 3;
			END_IF

		
		
		6:	// Down position.
			IF g_Axis[0].state = AXIS_IDLE AND NOT DelayDown.Out THEN
				g_HangerOpenerProcess.HangerClamp				:= FALSE;
				g_HangerOpenerProcess.Common.State 				:= 7;
			END_IF
		
		7: // Delay ready
			TON_DelayIdle(IN := TRUE, PT := T#500ms);
			IF TON_DelayIdle.Q THEN
				TON_DelayIdle(IN := FALSE, PT := T#500ms);
				g_HangerOpenerProcess.Common.State := MACHPROC_RUN_20;
			END_IF
		
  			
			(*###############################################################*)
			(* Machine Stop case, to handle shut down process of the module  *)
			(*###############################################################*)

		MACHPROC_STOP_15:
			;
			(* Reset output and handle the shutdown procedure *)
			(* Extra stop cases may be needed.. *)
			g_HangerOpenerProcess.Common.State 						:= MACHPROC_INIT_0;
			g_HangerOpenerProcess.Common.FoldUnit1.State			:= 0;
			g_HangerOpenerProcess.Common.FoldUnit2.State			:= 0;
			g_HangerOpenerProcess.Common.Motor.cmdStop				:= TRUE;
			g_HangerOpenerProcess.Press 							:= FALSE;



			(*#####################*)
			(* Main running state  *)
			(*#####################*)

		MACHPROC_RUN_20:
		
			// Reset the hanger trig flag..
			HangerIsPresent := FALSE;
			KG_HangerClampTimer := 0; 
			// Check if long garment in inlet and no long garments from Turn around that cover photocell in plate	// Added g_HangerOpenerProcess.HangerInPosition.Output 10-10-14 POX
			IF g_MasterStep <> 100 AND NOT g_sim.Test THEN
				;
			ELSIF NOT HangerInPositionActive THEN
				IF (g_HangerOpenerProcess.Common.Previous.TransferStatus = EXC_WANT_TO_UNLOAD_1) AND (g_TopConveyorProcess.Common.ErrorCode = 0) AND g_TopConveyorProcess.Common.State >= MACHPROC_RUN_20 THEN		(* Hanger ready to be loaded in to opener *)
					g_HangerOpenerProcess.Common.Previous.TransferStatus 	:= EXC_READY_TO_RECIEVE_2;
					g_HangerOpenerProcess.Common.State 						:= MACHPROC_HANGER_IS_COMING_25;
				END_IF

				// 09-08-05
				(* Hanger already sent on way down *)
				IF (g_HangerOpenerProcess.Common.Previous.TransferStatus > EXC_WANT_TO_UNLOAD_1) AND (g_HangerOpenerProcess.Common.Previous.TransferStatus < EXC_ERROR_99) AND (g_TopConveyorProcess.Common.ErrorCode = 0) AND g_TopConveyorProcess.Common.State >= MACHPROC_RUN_20 AND (g_HangerOpenerProcess.Common.Next.TransferStatus < EXC_ERROR_99) THEN
					g_HangerOpenerProcess.Common.State 						:= MACHPROC_HANGER_IS_COMING_25;
				END_IF

			ELSIF g_HangerOpenerProcess.Common.Next.TransferStatus = EXC_STANDBY_0 AND HangerInPositionActive THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'HangerInPosition covered too long');
				g_HangerOpenerProcess.Common.ErrorCode	:= 11;
				g_HangerOpenerProcess.Common.State 		:= MACHPROC_TRIG_ERROR_98;
			END_IF

			// Wait for hanger in plate photocell...
		MACHPROC_HANGER_IS_COMING_25:

			// If soft stop is attempted go back to state _20..	
			IF g_Machine.StopAttempt AND g_HangerInletProcess.Common.State = MACHPROC_RUN_20 THEN
				g_HangerOpenerProcess.Common.Previous.TransferStatus	:= EXC_STANDBY_0;	
				g_HangerOpenerProcess.Common.State 						:= MACHPROC_RUN_20;
			END_IF			
		
			// Hand shake with H_Inlet to release hanger..
			IF (g_HangerOpenerProcess.Common.Previous.TransferStatus = EXC_WANT_TO_UNLOAD_1) THEN
				g_HangerOpenerProcess.Common.Previous.TransferStatus 	:= EXC_READY_TO_RECIEVE_2;
			END_IF		
		
			// If photocell is triggered before handshake with HangerInlet set a flag.
			IF g_HangerOpenerProcess.HangerInPosition.Output AND g_HangerInletProcess.Common.State > 35 THEN
				HangerIsPresent := TRUE;
			END_IF	
				
			// Wait for photocell.. 
			g_HangerOpenerProcess.Common.WatchDogRunTimer 		:= g_HangerOpenerProcess.Common.CurTimer;					
			IF g_HangerOpenerProcess.Common.Previous.TransferStatus = EXC_UNLOADING_3 THEN
				IF HangerIsPresent THEN
					g_HangerOpenerProcess.StartDelayOpenerTimer				:= g_HangerOpenerProcess.Common.CurTimer;
					g_HangerOpenerProcess.Press								:= TRUE;
					g_HangerOpenerProcess.Common.Previous.TransferStatus 	:= EXC_RECIVING_4;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'Hanger in pos');
					HI_HasSet_5 											:= FALSE;	
					g_HangerOpenerProcess.Common.State 						:= MACHPROC_OPEN_HANGER_30;
					// WM reset Value 
					g_HangerOpenerProcess.PajamePreBreaking.State := FOLDIO_STATE_IDLE_0;
				END_IF
			END_IF
		
			// If error in Hanger Inlet go back to try again.. 09-09-30...		
			IF g_HangerOpenerProcess.Common.Previous.TransferStatus = EXC_ERROR_99 THEN
				g_HangerOpenerProcess.Common.Previous.TransferStatus	:= EXC_STANDBY_0; 
				g_HangerOpenerProcess.Common.State 						:= MACHPROC_RUN_20;
			END_IF	

			// If e-stop when waiting for new hanger we must trigger a restart...
			// Beacuse the hanger block needs to syncronized again...
			IF (g_HangerOpenerProcess.Common.Previous.TransferStatus = EXC_STANDBY_0) OR (g_HangerOpenerProcess.Common.Previous.TransferStatus = EXC_RECIVING_DONE_6) THEN
				IF g_Machine.EStopActivated OR NOT g_Core.System.Runtime.isRunning THEN
					g_HangerOpenerProcess.Common.State 	:= MACHPROC_INIT_0;
				END_IF			
			END_IF
		

			// Open the hanger 
		MACHPROC_OPEN_HANGER_30:

			g_HangerOpenerProcess.Common.WatchDogRunTimer 		:= g_HangerOpenerProcess.Common.CurTimer;			
		
			// Reset StartPreBreaking
			StartPreBreaking:= FALSE;
			// Must be a flag in between, sins Hanger Inlet can go into reading error when we are waiting for DelayStart timer...
			IF g_HangerOpenerProcess.Common.Previous.TransferStatus = EXC_FINISHED_UNLOADING_5 THEN
				HI_HasSet_5 := TRUE;	
			END_IF

			IF HI_HasSet_5 THEN
				g_HangerOpenerProcess.Common.Product					:= g_HangerOpenerProcess.Common.Previous.Product;
				g_HangerOpenerProcess.Common.Product.AutoProgram		:= g_HangerOpenerProcess.Common.Previous.Product.FoldProgram;

				IF ElapsedMsTime(g_HangerOpenerProcess.Common.CurTimer, g_HangerOpenerProcess.StartDelayOpenerTimer) >= g_HangerOpenerProcess.StartDelayOpenerTime THEN
					// Trouser do not need to collapse the hanger 
					IF g_HangerOpenerProcess.Common.Product.ProductType = TROUSER_TYPE_0 THEN
					
						IF g_HangerOpenerProcess.CombiHanger = 0  THEN			// It is a Lobster...			
							g_HangerOpenerProcess.HangerHammer		:= TRUE;
						END_IF	
						g_HangerOpenerProcess.DelayHornTimer				:= g_HangerOpenerProcess.Common.CurTimer;
						LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'Troser not open');
						g_HangerOpenerProcess.Common.State 					:= MACHPROC_WAIT_HORN_33;
						// It is a Shirt...	
					ELSIF g_HangerOpenerProcess.Common.Product.ProductType = SHIRT_TYPE_1 THEN
						IF g_HangerOpenerProcess.CombiHanger = 0 THEN			// It is a Lobster
							g_HangerOpenerProcess.HangerResetLower 		:= TRUE;
							g_HangerOpenerProcess.HangerResetUpper 		:= TRUE;
						END_IF	
					
						g_HangerOpenerProcess.HangerClamp			:= TRUE;					

						IF g_HangerOpenerProcess.CombiHanger = 1 THEN			
							g_HangerOpenerProcess.HangerHammer			:= FALSE;
						ELSE
							g_HangerOpenerProcess.HangerHammer			:= TRUE;
						END_IF	
						LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'Shirt open');
						IF g_HangerOpenerProcess.CombiHanger = 0 THEN			// It is a Lobster
							g_HangerOpenerProcess.Common.State 					:= MACHPROC_REMOVE_HANGER_35;
						ELSE
							g_HangerOpenerProcess.DelayHornTimer				:= g_HangerOpenerProcess.Common.CurTimer;
							g_HangerOpenerProcess.Common.State 					:= MACHPROC_WAIT_HORN_33;
						END_IF	
						// Pyjamas is handel differently goes in to another step...	
					ELSE // PYJAMAS_TYPE_2
						IF g_HCfg.CombiHanger = 1 THEN
							g_HangerOpenerProcess.HangerClamp			:= TRUE;		
							g_HangerOpenerProcess.HangerHammer			:= FALSE;
							g_HangerOpenerProcess.HangerResetLower 		:= TRUE;
							LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'Pyjamas open Combi');
							g_HangerOpenerProcess.DelayPyjamasTimer		:= g_HangerOpenerProcess.Common.CurTimer;
							g_HangerOpenerProcess.Common.State 			:= MACHPROC_PYJAMAS_OPENING_34;
						ELSE	// Lobster
							g_HangerOpenerProcess.HangerClamp			:= TRUE;		
							g_HangerOpenerProcess.HangerHammer			:= TRUE;
							//g_HangerOpenerProcess.HangerResetLower 		:= TRUE;
							g_HangerOpenerProcess.HangerResetUpper 		:= FALSE; //Enable this if pyjamas is hard to separate from Lobster-hanger
							LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'Pyjamas open lobster');
							//g_HangerOpenerProcess.DelayPyjamasTimer		:= g_HangerOpenerProcess.Common.CurTimer;
							g_HangerOpenerProcess.PajamasMotorRunTimer	:= g_HangerOpenerProcess.Common.CurTimer;
						
							g_HangerOpenerProcess.Common.State 			:= 37; //MACHPROC_PYJAMAS_OPENING_34;
						
							// WM: Special for Breaking Motor when Pyjame
							StartPreBreaking := TRUE;
						END_IF	
					END_IF
					g_HangerOpenerProcess.Common.WatchDogRunTimer 		:= g_HangerOpenerProcess.Common.CurTimer;					(* start watchdog timer for process *)
					g_HangerOpenerProcess.StartDelayLifterTimer			:= g_HangerOpenerProcess.Common.CurTimer;
				END_IF
			ELSE
				g_HangerOpenerProcess.StartDelayOpenerTimer				:= g_HangerOpenerProcess.Common.CurTimer;
			END_IF
		


			// If error in Hanger Inlet go back to try again.. 09-09-30...		
			// Fixed for hanger reading error POX 10-04-28
			IF (g_HangerOpenerProcess.Common.Previous.TransferStatus = EXC_ERROR_99) AND (g_HangerInletProcess.Common.ErrorCode <> 7) THEN
				g_HangerOpenerProcess.Common.Previous.TransferStatus	:= EXC_STANDBY_0; 
				g_HangerOpenerProcess.Common.State 						:= MACHPROC_RUN_20;
			END_IF	

			// --------------------Fix by MHA: DU Short stop, just before colapsing Lobster-hanger
		37:
			IF ElapsedMsTime(g_HangerOpenerProcess.Common.CurTimer, g_HangerOpenerProcess.StartDelayLifterTimer) >= g_HangerOpenerProcess.StartDelayLifterTime AND (g_Axis[0].state = AXIS_IDLE OR g_sim.Test) THEN
				g_HangerOpenerProcess.StartDelayLifterTimer	:= g_HangerOpenerProcess.Common.CurTimer;
				g_HangerOpenerProcess.PajamasMotorRunTimer	:= g_HangerOpenerProcess.Common.CurTimer;

				g_Axis[0].move.deceleration := g_MCfg.Deloading.decUp;
				g_Axis[0].move.acceleration := g_MCfg.Deloading.accUp;
				g_Axis[0].move.velocity := g_MCfg.Deloading.speedUp;
				g_Axis[0].move.position := g_MCfg.Deloading.PajamasStopPos;
				g_Axis[0].state := AXIS_ABS; 

				g_HangerOpenerProcess.Press		:= FALSE; // release pressing for a short period
				g_HangerOpenerProcess.Common.State 			:= MACHPROC_PYJAMAS_OPENING_34;
			END_IF


			// Let the Horns cylinders go down before start going up..
		MACHPROC_WAIT_HORN_33:

			IF ElapsedMsTime(g_HangerOpenerProcess.Common.CurTimer, g_HangerOpenerProcess.DelayHornTimer) >= g_HangerOpenerProcess.DelayHornTime THEN
				// It's a Lobster
				IF g_HangerOpenerProcess.CombiHanger = 0 THEN
					g_HangerOpenerProcess.HangerResetLower 		:= FALSE;
					g_HangerOpenerProcess.HangerResetUpper 		:= FALSE;			
					g_HangerOpenerProcess.StartDelayLifterTimer	:= g_HangerOpenerProcess.Common.CurTimer;
					g_HangerOpenerProcess.Common.State 			:= MACHPROC_REMOVE_HANGER_35;	
					// It's a Combi hanger
				ELSE											
					g_HangerOpenerProcess.HangerHammer		:= TRUE;	
					IF g_HangerOpenerProcess.Common.Product.ProductType = TROUSER_TYPE_0 THEN	// 09-11-25	
						g_HangerOpenerProcess.DelayHornTimer		:= g_HangerOpenerProcess.Common.CurTimer;
						g_HangerOpenerProcess.Common.State 			:= MACHPROC_WAIT_OPENER_31;	
					ELSE	
						g_HangerOpenerProcess.StartDelayLifterTimer	:= g_HangerOpenerProcess.Common.CurTimer;
						g_HangerOpenerProcess.Common.State 			:= MACHPROC_REMOVE_HANGER_35;	
					END_IF
				END_IF	
			END_IF	

			// Combi hanger wait for Hanger opener cylinder before removing hanger
		MACHPROC_WAIT_OPENER_31:
	
			IF ElapsedMsTime(g_HangerOpenerProcess.Common.CurTimer, g_HangerOpenerProcess.DelayHornTimer) >= g_HangerOpenerProcess.DelayHornTime THEN
				g_HangerOpenerProcess.HangerResetLower 		:= TRUE;
				g_HangerOpenerProcess.StartDelayLifterTimer	:= g_HangerOpenerProcess.Common.CurTimer;
				g_HangerOpenerProcess.Common.State 			:= MACHPROC_REMOVE_HANGER_35;	
			END_IF	
				
			
			// Pyjamas opening of Combi hanger
		MACHPROC_PYJAMAS_OPENING_34:

			IF g_HCfg.CombiHanger = 1 THEN				
				// Open the hangers trouser clamp to release the pyjamas before the hanger is opened with the hammer.		
				IF g_Axis[0].state = AXIS_IDLE THEN
					g_HangerOpenerProcess.HangerHammer				:= TRUE;
					g_HangerOpenerProcess.HangerResetLower 			:= FALSE;
					g_HangerOpenerProcess.Common.WatchDogRunTimer 	:= g_HangerOpenerProcess.Common.CurTimer;		
					g_HangerOpenerProcess.StartDelayLifterTimer		:= g_HangerOpenerProcess.Common.CurTimer;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'Pyjamas is done');
					g_HangerOpenerProcess.Common.State 				:= MACHPROC_REMOVE_HANGER_35;;
				END_IF
			ELSE	// Lobster
				IF g_Axis[0].state = AXIS_IDLE THEN
					g_HangerOpenerProcess.Press		:= TRUE;
					g_HangerOpenerProcess.HangerResetLower	:= TRUE;
				(*	g_HangerOpenerProcess.HangerResetUpper	:= TRUE;*)
					g_HangerOpenerProcess.HangerResetUpper	:= FALSE;
					g_HangerOpenerProcess.PajamasDelayLiftTimer	:= g_HangerOpenerProcess.Common.CurTimer;
					
					IF g_MCfg.Deloading.TwoStepsPjamaOpening THEN 	// 2 steps/stops for pjama opening
						g_HangerOpenerProcess.Common.State 			:= MACHPROC_PAJAMAS_2ndSTOP_38;
					ELSE	
						g_HangerOpenerProcess.Common.State 			:= MACHPROC_PAJAMAS_STOP_36;	
					END_IF	
				END_IF
			END_IF

			// Delay before hanger continues upwards...
		MACHPROC_PAJAMAS_STOP_36:

			IF ElapsedMsTime(g_HangerOpenerProcess.Common.CurTimer, g_HangerOpenerProcess.PajamasDelayLiftTimer) >= g_HangerOpenerProcess.PajamasDelayLiftTime AND g_Axis[0].state = AXIS_IDLE THEN
				g_HangerOpenerProcess.StartDelayLifterTimer	:= g_HangerOpenerProcess.Common.CurTimer;
				g_HangerOpenerProcess.HangerResetUpper	:= TRUE;
				g_HangerOpenerProcess.Common.State 			:= MACHPROC_REMOVE_HANGER_35;	
			END_IF

		MACHPROC_PAJAMAS_2ndSTOP_38:	
			g_HangerOpenerProcess.StartDelayLifterTimer	:= g_HangerOpenerProcess.Common.CurTimer;
			g_HangerOpenerProcess.PajamasMotorRunTimer	:= g_HangerOpenerProcess.Common.CurTimer;

			g_Axis[0].move.deceleration := g_MCfg.Deloading.decUp;
			g_Axis[0].move.acceleration := g_MCfg.Deloading.accUp;
			g_Axis[0].move.velocity := g_MCfg.Deloading.speedUp;
			g_Axis[0].move.position := g_MCfg.Deloading.PajamasStopPos2;	// 2ND STEP POSITION
			g_Axis[0].state := AXIS_ABS; 
			g_HangerOpenerProcess.Common.State 			:= MACHPROC_PAJAMAS_STOP_36;
			
			// Start removing hanger from garment by going up with plate
		MACHPROC_REMOVE_HANGER_35:
			
			(* Start motor to lift hanger *)
			g_HangerOpenerProcess.Common.WatchDogRunTimer 	:= g_HangerOpenerProcess.Common.CurTimer;			
		
			IF ElapsedMsTime(g_HangerOpenerProcess.Common.CurTimer, g_HangerOpenerProcess.StartDelayLifterTimer) >= g_HangerOpenerProcess.StartDelayLifterTime AND (g_Axis[0].state = AXIS_IDLE OR g_sim.Test) THEN

				IF g_HangerOpenerProcess.Common.Product.IsFlapTrousers THEN
					ShirtDetectedHMI := 2;	// Shirt icon
				ELSIF (g_HangerOpenerProcess.Common.Product.ProductType = SHIRT_TYPE_1) OR (g_HangerOpenerProcess.Common.Product.ProductType = PYJAMAS_TYPE_2) THEN
					ShirtDetectedHMI := 1;	// Shirt icon
				ELSE
					ShirtDetectedHMI := 3;	// Trouser icon 
				END_IF	

				g_Axis[0].move.deceleration := g_MCfg.Deloading.decUp;
				g_Axis[0].move.acceleration := g_MCfg.Deloading.accUp;
				g_Axis[0].move.velocity := g_MCfg.Deloading.speedUp;
				g_Axis[0].move.position := g_MCfg.Deloading.upPos;
				g_Axis[0].state := AXIS_ABS; 
				g_HangerOpenerProcess.HangerBlockClamp 			:= FALSE;
				g_HangerOpenerProcess.Common.WatchDogRunTimer 	:= g_HangerOpenerProcess.Common.CurTimer;	
				g_HangerOpenerProcess.PressResetTimer			:= g_HangerOpenerProcess.Common.CurTimer;	// Delay reset press.
				BeltStartTimer									:= g_HangerOpenerProcess.Common.CurTimer;	// When to start Infeed belt to speed up before we reach top..	
				g_HangerOpenerProcess.HangerResetTimer			:= g_HangerOpenerProcess.Common.CurTimer;	// Delay reset of hanger..
				GarmentHasGoneToTopConveyor						:= FALSE;	
				LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'Start lift');

				HangerResetPos := 0;	
				HangerSetPos := 0;	
				HangerResetTime := HangerSetTime := 0;
				HangerMoveUpStartTime := g_MilliSeconds;
				HangerSetPosEarly := 0;

				g_HangerOpenerProcess.Common.State 				:= MACHPROC_LIFT_GOING_UP_40;
				g_HangerOpenerProcess.HangerClamp := TRUE; 

			END_IF
		

			// Going up wait for upper pre sensor
		MACHPROC_LIFT_GOING_UP_40:

			IF EDGEPOS(g_HangerOpenerProcess.CheckHangerInDU.Output) THEN
				EdgePos_CheckHangerInDU	:= TRUE;
			END_IF	
			// Hanger is released out of deloading plate after a time..
			IF parUseEarlyHornHammer THEN
				IF ( (g_Axis[0].actValues.axisPos >= (g_MCfg.Deloading.upPos - parHornHammerOffset) AND (HangerSetPosEarly = 0) OR g_sim.Test) AND (ElapsedMsTime(g_HangerOpenerProcess.Common.CurTimer, g_HangerOpenerProcess.HangerCloseTimer) >= g_HangerOpenerProcess.HangerCloseTime)) THEN
					HangerSetPosEarly := g_Axis[0].actValues.axisPos;
					
					g_HangerOpenerProcess.HangerHammer := FALSE;
					HornRelease_Delay.Set := TRUE;
					HangerClamp_Delay(Set := TRUE);
	
					LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'HO: Early Horn, hammer');
				END_IF
			END_IF
			
			
			IF g_Axis[0].state = AXIS_IDLE OR g_sim.Test THEN
				g_HangerOpenerProcess.HangerSlideOutTimer			:= g_HangerOpenerProcess.Common.CurTimer;
				g_HangerOpenerProcess.Common.WatchDogRunTimer 		:= g_HangerOpenerProcess.Common.CurTimer;					(* start watchdog timer for process *)
				LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_HangerOpenerProcess.Common.Next.TransferStatus, 'HO, Next status');
				g_HangerOpenerProcess.HangerPassedOut 				:= FALSE;
				CheckOnlyOnce 										:= FALSE;

				HangerUpTime := g_MilliSeconds - HangerMoveUpStartTime;
				HangerOutOfMachinePosEdge := FALSE;

				g_HangerOpenerProcess.Common.State 					:= MACHPROC_WAIT_FOR_UP_45;
			END_IF
	
		
			// Reset Press after a time, due to light garments being pulled from the table 
			IF ElapsedMsTime(g_HangerOpenerProcess.Common.CurTimer, g_HangerOpenerProcess.PressResetTimer) >= g_HangerOpenerProcess.PressResetTime THEN
				g_HangerOpenerProcess.Press 						:= FALSE;
			END_IF		


			// Reset hanger after timer and Photocell
			IF (HangerResetTime = 0) AND g_Axis[0].actValues.axisPos >= UINT_TO_DINT(g_HangerOpenerProcess.HangerResetTime) THEN
				IF g_HangerOpenerProcess.CombiHanger = 1 THEN		
					g_HangerOpenerProcess.HangerResetLower		:= TRUE;	// Start reseting the Combi hanger..
				ELSE	
					g_HangerOpenerProcess.HangerResetLower		:= FALSE;
				END_IF	
				g_HangerOpenerProcess.HangerResetUpper		:= FALSE;
				g_HangerOpenerProcess.HangerCloseTimer		:= g_HangerOpenerProcess.Common.CurTimer;

				HangerResetPos := g_Axis[0].actValues.axisPos;
				HangerResetTime := g_MilliSeconds - HangerMoveUpStartTime;
				HangerResetState := g_Axis[0].state;
				HangerResetCount := HangerResetCount + 1;
				HangerResetTimePoint := g_MilliSeconds;

			END_IF


			// Start handover with turn around to speed up 10-01-25...
			IF (ElapsedMsTime(g_HangerOpenerProcess.Common.CurTimer, BeltStartTimer) >= BeltStartTime) AND NOT g_HangerOpenerProcess.HangerResetUpper THEN
				IF g_HangerOpenerProcess.Common.Product.EmpHangLength > g_MCfg.Inlet.Hanger.EmptyHangerLength THEN
					IF g_HangerOpenerProcess.Common.Next.TransferStatus = EXC_STANDBY_0 AND NOT GarmentHasGoneToTopConveyor THEN 
						g_HangerOpenerProcess.Common.Next.Product          	:= g_HangerOpenerProcess.Common.Product;							// Copy product data to next task 
						g_HangerOpenerProcess.Common.Next.TransferStatus 	:= EXC_WANT_TO_UNLOAD_1;											// Start handover with Inlet belt 
					ELSIF g_HangerOpenerProcess.Common.Next.TransferStatus =  EXC_READY_TO_RECIEVE_2 AND NOT GarmentHasGoneToTopConveyor  THEN 	// Hanger is out of the garment 
						g_HangerOpenerProcess.Common.Next.TransferStatus 	:= EXC_UNLOADING_3;													// Inlet belt starts here 
						GarmentHasGoneToTopConveyor							:= TRUE;
						LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'Handover inlet lift upp');
						IF g_HangerOpenerProcess.Common.Previous.TransferStatus = EXC_FINISHED_UNLOADING_5 THEN				// Hanger inlet is finished 
							g_HangerOpenerProcess.Common.Previous.TransferStatus 	:= EXC_RECIVING_DONE_6;
						END_IF
					END_IF
				END_IF
			END_IF	





			// Wait for upper sensor
		MACHPROC_WAIT_FOR_UP_45:

			g_HangerOpenerProcess.Common.WatchDogRunTimer 	:= g_HangerOpenerProcess.Common.CurTimer;		
		
			(* Lift is up *)
			IF g_Axis[0].state = AXIS_IDLE OR g_sim.Test THEN	
				// Time out if hanger does not come out of hanger plate
				IF (ElapsedMsTime(g_HangerOpenerProcess.Common.CurTimer, g_HangerOpenerProcess.HangerSlideOutTimer) >= g_HangerOpenerProcess.HangerSlideOutTime) AND NOT g_HangerOpenerProcess.HangerPassedOut THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'No hanger out error');
					g_HangerOpenerProcess.Common.ErrorCode	:= 5;
					g_HangerOpenerProcess.Common.State 		:= MACHPROC_TRIG_ERROR_98;
				END_IF
			
				//  Garment still on hanger trigger an alarm
				IF g_HangerOpenerProcess.HangerJam.Output THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'HO, Garment on hanger');
					g_HangerOpenerProcess.Common.ErrorCode		:= 4;
					g_HangerOpenerProcess.Common.State 			:= MACHPROC_TRIG_ERROR_98;	
				END_IF
			
				// Reset hanger hammer
				g_HangerOpenerProcess.HangerHammer			:= FALSE;
			END_IF

			// Reset hanger after delay.. 
			IF NOT g_HangerOpenerProcess.HangerPassedOut AND (ElapsedMsTime(g_HangerOpenerProcess.Common.CurTimer, g_HangerOpenerProcess.HangerResetTimer) >= g_HangerOpenerProcess.HangerResetTime) THEN
				IF g_HangerOpenerProcess.CombiHanger = 1 THEN
					g_HangerOpenerProcess.HangerResetLower		:= TRUE;	// Start reseting the Combi hanger..
				ELSE	
					g_HangerOpenerProcess.HangerResetLower		:= FALSE;
				END_IF	
				g_HangerOpenerProcess.HangerResetUpper		:= FALSE;
			END_IF

			// Reset garment press after a time, due to light garments being pulled from the table 
			IF ElapsedMsTime(g_HangerOpenerProcess.Common.CurTimer, g_HangerOpenerProcess.PressResetTimer) >= g_HangerOpenerProcess.PressResetTime THEN
				g_HangerOpenerProcess.Press 						:= FALSE;
			END_IF		


			// Hanger is released out of deloading plate after a time..
			IF (HangerSetPos = 0) AND ( (NOT g_HangerOpenerProcess.HangerPassedOut) AND (ElapsedMsTime(g_HangerOpenerProcess.Common.CurTimer, g_HangerOpenerProcess.HangerCloseTimer) >= g_HangerOpenerProcess.HangerCloseTime) ) THEN
				
				IF HangerSetPosEarly = 0 THEN
					HangerClamp_Delay(Set := TRUE);
					HornRelease_Delay.Set := TRUE;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'HO: Top Horn, hammer');
				END_IF

				// New alarm 10-02-17
				// If no hanger is present in DU trigger an alarm.
				IF g_HangerOpenerProcess.CheckHangerFunction AND NOT g_sim.Test THEN
					ftoa(g_Axis[0].actValues.axisPos, ADR(PosString));
					//		PosString;
					IF ( NOT g_HangerOpenerProcess.CheckHangerInDU.Output OR NOT EdgePos_CheckHangerInDU) AND NOT CheckOnlyOnce  THEN
					
						LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'HO, No hanger at top');
						LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses,PosString );
						g_HangerOpenerProcess.Common.ErrorCode		:= 8;
						g_HangerOpenerProcess.Common.State 			:= MACHPROC_TRIG_ERROR_98;	
					END_IF
					CheckOnlyOnce := TRUE;		// Reset before this state...
				END_IF
				HangerSetPos := g_Axis[0].actValues.axisPos;
				HangerSetCount := HangerSetCount + 1;
				HangerSetTime := g_MilliSeconds - HangerResetTimePoint;
				HangerSetState := g_Axis[0].state;
			
			END_IF

	
			// Hanger comes out of machine 
			IF EDGEPOS(g_HangerOpenerProcess.HangerOutOfMachine.Output) AND NOT HangerClamp_Delay.Out THEN
				HangerOutOfMachinePosEdge := TRUE;
			END_IF
				
			IF EDGENEG(g_HangerOpenerProcess.HangerOutOfMachine.Output) AND HangerOutOfMachinePosEdge THEN			
				HangerOutOfMachinePosEdge := FALSE;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'Hanger out of machine');
				LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_HangerOpenerProcess.Common.Next.TransferStatus, 'HO, Next status');
				g_HangerOpenerProcess.HangerClamp			:= TRUE;
				g_HangerOpenerProcess.HangerResetUpper		:= TRUE;
				g_HangerOpenerProcess.HangerResetLower		:= FALSE;
				g_HangerOpenerProcess.BlockDelayTimer		:= g_HangerOpenerProcess.Common.CurTimer;
				g_HangerOpenerProcess.HangerPassedOut 		:= TRUE;
			END_IF
		
			// Stop process here if error has stopped machine down stream...	
			IF (g_HangerOpenerProcess.Common.Next.TransferStatus < EXC_FINISHED_UNLOADING_5) AND g_HangerOpenerProcess.HangerPassedOut OR g_sim.IIJamDeloadingOut THEN
				g_HangerOpenerProcess.Common.State 			:= MACHPROC_LIFT_WAIT_INLET_48;
			END_IF	

			IF (NOT g_Core.System.Runtime.isRunning OR g_Machine.EStopActivated) AND RestartDeloader THEN
				RestartDeloaderWaitUp := TRUE;
				g_HangerOpenerProcess.WaitingRestart := TRUE;
				g_HangerOpenerProcess.HangerClamp						:= FALSE;
				g_HangerOpenerProcess.HangerResetLower					:= FALSE;
				g_HangerOpenerProcess.HangerResetUpper					:= TRUE;
				g_HangerOpenerProcess.HangerHammer						:= FALSE;
				g_HangerOpenerProcess.HangerBlockClamp					:= FALSE;
				g_HangerOpenerProcess.Press 							:= FALSE;
				g_HangerOpenerProcess.Common.State := 46;
			END_IF
			

			(* Try to Handover with next task, can be waiting for previous garment *)
			IF g_HangerOpenerProcess.Common.Product.EmpHangLength > g_MCfg.Inlet.Hanger.EmptyHangerLength THEN
				// Handshake with top conveyor and that the garment has not already left and we are waiting for hanger out signal	
				IF (g_HangerOpenerProcess.Common.Next.TransferStatus = EXC_STANDBY_0) AND NOT GarmentHasGoneToTopConveyor THEN
					g_HangerOpenerProcess.Common.Next.TransferStatus 	:= EXC_WANT_TO_UNLOAD_1;											// Start handover with Inlet belt 
					g_HangerOpenerProcess.Common.Next.Product          	:= g_HangerOpenerProcess.Common.Product;							// Copy product data to next task 
				ELSIF g_HangerOpenerProcess.Common.Next.TransferStatus =  EXC_READY_TO_RECIEVE_2 AND NOT GarmentHasGoneToTopConveyor THEN	// Hanger is out of the garment 
					g_HangerOpenerProcess.Common.Next.TransferStatus 	:= EXC_UNLOADING_3;													// Inlet belt starts here 
					GarmentHasGoneToTopConveyor 						:= TRUE;
					// 09-08-02 To speed up the inlet some more
					IF g_HangerOpenerProcess.Common.Previous.TransferStatus = EXC_FINISHED_UNLOADING_5 THEN			// Hanger inlet is finished 					
						g_HangerOpenerProcess.Common.Previous.TransferStatus 	:= EXC_RECIVING_DONE_6;
					END_IF	
					LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'Handover inlet lift upp');
				END_IF
			END_IF	


			
		46: // Wait Emergency or safety door ok
			g_HangerOpenerProcess.Common.WatchDogRunTimer 	:= g_HangerOpenerProcess.Common.CurTimer;
			IF g_Core.System.Runtime.isRunning AND (g_MasterStep = 100) AND (g_Axis[0].state = AXIS_IDLE) THEN
				g_HangerOpenerProcess.HangerClamp := TRUE;
				g_Axis[0].move.deceleration := g_MCfg.Deloading.decUp;
				g_Axis[0].move.acceleration := g_MCfg.Deloading.accUp;
				g_Axis[0].move.velocity := g_MCfg.Deloading.speedUp;
				g_Axis[0].move.position := g_MCfg.Deloading.upPos;
				g_Axis[0].state := AXIS_ABS; 
				g_HangerOpenerProcess.Common.State := 47;
			END_IF
			

		47:
			IF (g_Axis[0].state = AXIS_IDLE) THEN
				g_HangerOpenerProcess.HangerBlockClamp := TRUE;
				g_HangerOpenerProcess.WaitingRestart := FALSE;
				g_HangerOpenerProcess.HangerPassedOut := TRUE;
				IF RestartDeloaderWaitInlet THEN
					g_HangerOpenerProcess.Common.State := MACHPROC_LIFT_WAIT_INLET_48;
				ELSE
					g_HangerOpenerProcess.Common.State := MACHPROC_WAIT_FOR_UP_45;
				END_IF
				RestartDeloaderWaitInlet := FALSE;
				RestartDeloaderWaitUp := FALSE;
			END_IF
			
		// Wait for Top conveyor to be ready 	
		MACHPROC_LIFT_WAIT_INLET_48:

			g_HangerOpenerProcess.Common.WatchDogRunTimer 	:= g_HangerOpenerProcess.Common.CurTimer;								// start watchdog timer for process 

			(* Handover with next task *)
			IF g_HangerOpenerProcess.Common.Product.EmpHangLength > g_MCfg.Inlet.Hanger.EmptyHangerLength OR g_sim.Test THEN
				IF g_HangerOpenerProcess.Common.Next.TransferStatus = EXC_STANDBY_0 THEN
					g_HangerOpenerProcess.Common.Next.TransferStatus 	:= EXC_WANT_TO_UNLOAD_1;									// Start handover with Inlet belt 
					g_HangerOpenerProcess.Common.Next.Product          	:= g_HangerOpenerProcess.Common.Product;					// Copy product data to next task 
				ELSIF g_HangerOpenerProcess.Common.Next.TransferStatus =  EXC_READY_TO_RECIEVE_2 THEN								// Hanger is out of the garment 
					g_HangerOpenerProcess.Common.Next.TransferStatus 	:= EXC_UNLOADING_3;											// Inlet belt starts here 
					// 09-08-02 To speed up the inlet some more
					IF g_HangerOpenerProcess.Common.Previous.TransferStatus = EXC_FINISHED_UNLOADING_5 THEN							// Hanger inlet is finished 
						g_HangerOpenerProcess.Common.Previous.TransferStatus 	:= EXC_RECIVING_DONE_6;
					END_IF		
					LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'Handover inlet wait _48');
				ELSIF ( (g_HangerOpenerProcess.Common.Next.TransferStatus = EXC_RECIVING_4) OR (g_HangerOpenerProcess.Common.Next.TransferStatus = EXC_UNLOADING_3) AND g_ACfg[ACfgProgram].DeloaderHeavyGarment AND NOT g_HangerOpenerProcess.HangerInPosition.Input ) AND (g_Axis[0].state = AXIS_IDLE OR g_sim.Test) THEN										// Lift is up, wait inlet belt to be free 
					g_HangerOpenerProcess.Common.Next.TransferStatus 	:= EXC_FINISHED_UNLOADING_5;								// Inlet belt is free 
					g_HangerOpenerProcess.HangerBlockClamp				:= TRUE;
				
					g_Axis[0].move.deceleration := g_MCfg.Deloading.decDw;
					g_Axis[0].move.acceleration := g_MCfg.Deloading.accDw;
					g_Axis[0].move.velocity := g_MCfg.Deloading.speedDw;
					g_Axis[0].move.position := g_MCfg.Deloading.dwPos + g_ACfg[ACfgProgram].DeloaderDwPos;
					g_Axis[0].state := AXIS_ABS;
				
					g_HangerOpenerProcess.NextHangerTimer				:= g_HangerOpenerProcess.Common.CurTimer;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_HangerOpenerProcess.Common.Next.TransferStatus, 'HO, Next status');
					RLogBookSet := FALSE;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'HO, Inletbelt started');
					g_HangerOpenerProcess.Common.State 					:= MACHPROC_LIFT_GOING_DOWN_50;
				END_IF
			ELSE	
				// Empty hanger just deliver out of machine no hand shake with Top Conveyor
				IF ElapsedMsTime(g_HangerOpenerProcess.Common.CurTimer, g_HangerOpenerProcess.BlockDelayTimer) >= g_HangerOpenerProcess.BlockDelayTime THEN		// Delay the block from the clamp so they not collide..
					IF g_HangerOpenerProcess.Common.Previous.TransferStatus = EXC_FINISHED_UNLOADING_5 AND (g_Axis[0].state = AXIS_IDLE OR g_sim.Test) THEN						// Hanger inlet is finished 
						g_HangerOpenerProcess.Common.Previous.TransferStatus 	:= EXC_RECIVING_DONE_6;
					END_IF
					g_HangerOpenerProcess.HangerBlockClamp				:= TRUE;

					g_Axis[0].move.deceleration := g_MCfg.Deloading.decDw;
					g_Axis[0].move.acceleration := g_MCfg.Deloading.accDw;
					g_Axis[0].move.velocity := g_MCfg.Deloading.speedDw;
					g_Axis[0].move.position := g_MCfg.Deloading.dwPos + g_ACfg[ACfgProgram].DeloaderDwPos;
					g_Axis[0].state := AXIS_ABS;
					ShirtDetectedHMI := 66;		// Empty hanger detected at Hanger inlet...
					g_HangerOpenerProcess.NextHangerTimer				:= g_HangerOpenerProcess.Common.CurTimer;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'HO, Empty hanger');
					RLogBookSet := FALSE;
					g_HangerOpenerProcess.Common.State 					:= MACHPROC_LIFT_GOING_DOWN_50;
				END_IF	
			END_IF
	
			// If error in TC go down with HO... Otherwise look situation, we try to unload the garment again when it already has been feed into TC..
			//IF g_HangerOpenerProcess.Common.Next.TransferStatus =  EXC_ERROR_99 THEN	POX 2010-08-10..
			IF (g_HangerOpenerProcess.Common.Next.TransferStatus =  EXC_ERROR_99) (* AND (g_TopConveyorProcess.Common.ErrorCode <> 2)*) THEN	
				g_HangerOpenerProcess.HangerBlockClamp				:= TRUE;

				IF g_Axis[0].state = AXIS_IDLE THEN	
					g_Axis[0].move.deceleration := g_MCfg.Deloading.decDw;
					g_Axis[0].move.acceleration := g_MCfg.Deloading.accDw;
					g_Axis[0].move.velocity := g_MCfg.Deloading.speedDw;
					g_Axis[0].move.position := g_MCfg.Deloading.dwPos + g_ACfg[ACfgProgram].DeloaderDwPos;
					g_Axis[0].state := AXIS_ABS;
				END_IF

				g_HangerOpenerProcess.NextHangerTimer				:= g_HangerOpenerProcess.Common.CurTimer;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'HO, Error in TC');
				RLogBookSet := FALSE;

				g_HangerOpenerProcess.Common.State 					:= MACHPROC_LIFT_GOING_DOWN_50;
				// If the leading edge of the garment never comes to the photocells of turn around, garment is stuck some where before do not travel down with deloading unit..		
			ELSIF (g_HangerOpenerProcess.Common.Next.TransferStatus =  EXC_ERROR_99) AND (g_TopConveyorProcess.Common.ErrorCode = 2) THEN		
				g_HangerOpenerProcess.Common.ErrorCode		:= 9;
				g_HangerOpenerProcess.Common.State 			:= MACHPROC_TRIG_ERROR_98;	
			END_IF

			IF (NOT g_Core.System.Runtime.isRunning OR g_Machine.EStopActivated) AND RestartDeloader THEN
				RestartDeloaderWaitInlet := TRUE;
				g_HangerOpenerProcess.WaitingRestart := TRUE;
				g_HangerOpenerProcess.HangerClamp						:= FALSE;
				g_HangerOpenerProcess.HangerResetLower					:= FALSE;
				g_HangerOpenerProcess.HangerResetUpper					:= TRUE;
				g_HangerOpenerProcess.HangerHammer						:= FALSE;
				g_HangerOpenerProcess.HangerBlockClamp					:= FALSE;
				g_HangerOpenerProcess.Press 							:= FALSE;
				g_HangerOpenerProcess.Common.State := 46;
			END_IF
			
	


			// Deloading plate goes down..
		MACHPROC_LIFT_GOING_DOWN_50:

		EdgePos_CheckHangerInDU	:= FALSE;
			// Wait for lower pre sensor
			MotorStop := FALSE;
			IF g_Axis[0].state = AXIS_IDLE OR g_sim.Test THEN
				MotorStop := TRUE;
				g_HangerOpenerProcess.Common.WatchDogRunTimer 	:= g_HangerOpenerProcess.Common.CurTimer;			
				g_HangerOpenerProcess.Common.State 				:= MACHPROC_WAIT_FOR_DOWN_55;
			END_IF


			(* Start feeding next hanger *)
			IF ((ElapsedMsTime(g_HangerOpenerProcess.Common.CurTimer, g_HangerOpenerProcess.NextHangerTimer) >= g_HangerOpenerProcess.NextHangerTime) OR MotorStop OR (g_Axis[0].actValues.axisPos < parAxisPosHOpenerReady)) THEN
				IF g_HangerOpenerProcess.Common.Previous.TransferStatus = EXC_WANT_TO_UNLOAD_1 AND NOT g_HangerOpenerProcess.HangerInPosition.Output THEN		// Hanger ready to be loaded into opener 
					g_HangerOpenerProcess.Common.Previous.TransferStatus 	:= EXC_READY_TO_RECIEVE_2;
					IF NOT RLogBookSet THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, REAL_TO_UINT(g_Axis[0].actValues.axisPos), 'HO, Ready To Recieve Down');
						RLogBookSet := TRUE;
					END_IF				
				END_IF
				g_HangerOpenerProcess.HangerClamp				:= FALSE;
			END_IF




		MACHPROC_WAIT_FOR_DOWN_55:

			// Lift is in down position 
			IF g_Axis[0].state = AXIS_IDLE OR g_sim.Test THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_HangerOpenerProcess.Common.Previous.TransferStatus, 'HO, Down T-Status');
				g_HangerOpenerProcess.Common.WatchDogRunTimer 	:= g_HangerOpenerProcess.Common.CurTimer;		
				g_HangerOpenerProcess.Common.State 				:= MACHPROC_RUN_20;
			END_IF



		

		MACHPROC_ERROR_99:
		
		
			g_HangerOpenerProcess.Press								:= FALSE;
			EdgePos_CheckHangerInDU									:= FALSE;
			g_HangerOpenerProcess.Common.Next.TransferStatus 		:= EXC_ERROR_99;	// To stop the Top conveyor..
	
			// Garment on hanger error... 7 = is from startup...
			IF (g_HangerOpenerProcess.Common.ErrorCode = 4) OR (g_HangerOpenerProcess.Common.ErrorCode = 7) THEN
				g_HangerOpenerProcess.HangerClamp 					:= FALSE;				(* To unlock the clamp blocker... *)
				g_HangerOpenerProcess.HangerBlockClamp				:= FALSE;
				g_HangerOpenerProcess.HangerHammer					:= FALSE;
				g_HangerOpenerProcess.HangerResetLower				:= FALSE;
				g_HangerOpenerProcess.HangerResetUpper				:= TRUE;				//10-02-08
				// Slide out error or else...	
			ELSE	
				g_HangerOpenerProcess.HangerClamp 					:= FALSE;			// To unlock the clamp blocker... 
				g_HangerOpenerProcess.HangerBlockClamp				:= FALSE;
				g_HangerOpenerProcess.HangerHammer					:= FALSE;
				g_HangerOpenerProcess.HangerResetLower				:= FALSE;
				g_HangerOpenerProcess.HangerResetUpper				:= TRUE;			//10-02-08
				g_HangerOpenerProcess.Common.Next.TransferStatus 	:= EXC_ERROR_99;	// To stop the Top conveyor..
				IF NOT Logged THEN
					Logged := TRUE;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD),  7, g_HangerOpenerProcess.Common.LogBookFlag, g_DummyPulses, 'HO, Stop TC with error');
				END_IF
				
			END_IF
			IF g_HangerOpenerProcess.Common.ErrorCode = 10 THEN
				g_HangerOpenerProcess.Common.Previous.TransferStatus := EXC_ERROR_99;
			END_IF		

	END_CASE
	

	IF NOT g_Core.System.Runtime.isRunning AND NOT g_HangerOpenerProcess.WaitingRestart AND g_HangerOpenerProcess.Common.State < 98 THEN
		g_HangerOpenerProcess.Common.State 					:= MACHPROC_INIT_0;
	END_IF

	DelayDown();
	
	(*##############*)
	(* Check Hanger in DU *)
	(*##############*)

	IF NOT HangerInDUChecked THEN
		IF g_JamDeloadingOut THEN
			HangerInDUTimer := HangerInDUTimer+1;
		ELSE
			HangerInDUTimer := 0; 
			HangerInDUChecked := TRUE; 	
		END_IF;
		IF HangerInDUTimer > 1000 THEN // 10 sec
			// Alarm 
			g_HangerOpenerProcess.Common.ErrorCode	:= 10; // Hanger in DU
			// Done 	
			HangerInDUChecked := TRUE; 	
			HangerInDUTimer := 0; 
		END_IF;
	END_IF;


	(***********************)
	IF EDGEPOS(StartPreBreaking) THEN
		g_HangerOpenerProcess.PajamePreBreaking.State := FOLDIO_STATE_START_1;
	END_IF;
	
	HangerHammer_Delay(CntAdr := ADR(g_MilliSeconds));
	IF HangerHammer_Delay.Trig THEN
		g_HangerOpenerProcess.HangerHammer := TRUE;
	END_IF

	Horn_Delay(Delay := HangerHammer_Delay.Delay + parHornDelayTime, CntAdr := ADR(g_MilliSeconds));
	IF Horn_Delay.Trig THEN
		g_HangerOpenerProcess.HangerResetLower := TRUE;
		g_HangerOpenerProcess.HangerResetUpper := TRUE;
	END_IF
	
	HornRelease_Delay(CntAdr := ADR(g_MilliSeconds));
	IF HornRelease_Delay.Trig THEN
		g_HangerOpenerProcess.HangerResetUpper := TRUE;
		g_HangerOpenerProcess.HangerResetLower := FALSE;
	END_IF
	
	HangerClamp_Delay(Delay := HornRelease_Delay.Delay + g_MCfg.Deloading.HangerClampDelay, CntAdr := ADR(g_MilliSeconds));
	IF HangerClamp_Delay.Trig THEN
		HangerClamp_Delay_Trigged := TRUE;
	END_IF
		
	IF HangerClamp_Delay_Trigged AND (g_Axis[0].state = AXIS_IDLE) THEN
		HangerClamp_Delay_Trigged := FALSE;
		g_HangerOpenerProcess.HangerClamp := FALSE;
	END_IF
	
	
	(*########################################*)
	(* To show detection type on Service page *)
	(*########################################*)


	IF g_HangerOpenerProcess.Common.Product.FoldProgram > 0 THEN
		g_HangerOpenerProcess.HMIDetectionType := g_ACfg[ACfgProgram].ForceTrouser;
	END_IF

	(*##############*)
	(* Run FoldIO's *)
	(*##############*)

	ActivateFoldIO(g_HangerOpenerProcess.PajamePreBreaking, g_HangerOpenerProcess.Common.CurTimer);
	ActivateFoldIO(g_HangerOpenerProcess.KG_HangerOpen, g_HangerOpenerProcess.Common.CurTimer);
	ActivateFoldIO(g_HangerOpenerProcess.KG_StopExtMotor, g_HangerOpenerProcess.Common.CurTimer);

	(*#################*)
	(* Connect Outputs *)
	(*#################*)

	QYHoldDownPlate			:= g_HangerOpenerProcess.Press;

	//PWC 22-06-2016: When we use CombiHanger, we have to reverse output QYHangerOpener.
	IF g_HCfg.CombiHanger = 0 THEN
		QYHangerOpener			:= g_HangerOpenerProcess.HangerHammer;
	ELSE
		QYHangerOpener			:= NOT g_HangerOpenerProcess.HangerHammer;	
	END_IF

	QYReleaseDeloadingBrake := (g_Axis[0].power AND g_Core.System.Runtime.isRunning) OR g_HMIHangerSetup > 0 OR g_HangerTestInProgress;
	
	QYHangerClampLock 		:= g_HangerOpenerProcess.HangerBlockClamp;
	QYHangerClampBelow		:= g_HangerOpenerProcess.HangerResetLower;
	QYHangerClampTop		:= g_HangerOpenerProcess.HangerResetUpper;
	QYHangerClampDown		:= g_HangerOpenerProcess.HangerClamp;
END_ACTION