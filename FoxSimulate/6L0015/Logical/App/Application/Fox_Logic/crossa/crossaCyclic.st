PROGRAM _CYCLIC
(* cyclic program *)

(*-------------------------------------------------------------------------------------

Author:   				Sten Flystedt

FileName:				CrossA.scr

Desription:				CrossA

Reference:

Interfaces:				No interfaces.

Watch debugg:			Name OF important watch configurations.

History:
10-05-06				V1.11.6 PO Nilsson		Changed fold 14 so it use FixDimLeadEdge AND NOT FixDimRearEdge..	
10-01-25				V1.11.5 PO Nilsson		Made changes TO Fix folds, do NOT need TO recalculate the Size in the Fox...	
09-11-04				V1.11.4 PO Nilsson		Logic FOR delaying the knife..Is togheter with change in Lateral...
09-10-27				V1.11.3	PO Nilsson		Removed machine manager index from init part OF xa.
09-10-21				V1.11.2 PO Nilsson		Used the BeltAdjustDummy also in the output set case..
09-10-01				V1.11.1 PO Nilsson		Bug fixes on site Holbaek
09-09-01				V1.11 	PO Nilsson		Changed the gap FUNCTION TO just one cylinder...	
09-03-10				V1.10 	PO Nilsson		Adapted TO Fox.

08-07-01				V1.01 	Sten Flystedt		First edition...
---------------------------------------------------------------------------------------*)


(*#####################*)
(* Get current time... *)
(*#####################*)
	g_CrossFoldAProcess.Common.CurTimer 		:= g_Timers._1_ms;			(* Get current time *)
	IF g_CrossFoldAProcess.Common.LogBookFlag > 0 THEN
		strcpy(ADR(TmpStr),ADR(g_CrossFoldAProcess.Common.Description));
	END_IF

	IF NOT (g_Core.Services.Recipe.Runtime.recipePointer > 0) THEN		(* Check that pointer is bigger then Null *)
		RETURN;									(* Do not run task before pointer is assigned... *)
	END_IF

	IBXAFoldHorizontal;

	(*#################################*)
	(* copy status of exchange objects *)
	(*#################################*)
	g_CrossFoldAProcess.Common.Previous		:= g_LateralProcess.Common.Next;
	g_CrossFoldAProcess.Common.Next			:= g_CrossFoldBProcess.Common.Previous;

	(*########################################*)
	(* Connect inputs to the module structure *)
	(*########################################*)



	(*######################*)
	(* Connect timer values *)
	(*######################*)
	g_CrossFoldAProcess.Common.WatchDogStartupTime			:= 2000;
	g_CrossFoldAProcess.Common.WatchDogRunTime				:= 10000;

	// Adjust stop earlier by - timer for Bathrobe folding
	g_CrossFoldAProcess.Common.Motor.RunTime				:= 5000 + g_MCfg.XFold.XAMotorStoptime;


	IF g_CrossFoldAProcess.Common.ReadParameters THEN
		g_CrossFoldAProcess.Common.ReadParameters := FALSE;

		IF g_Core.Services.Recipe.Runtime.recipePointer > 0 THEN			(* Check that pointer is bigger then Null *)
			LocalFoldProgram ACCESS(g_Core.Services.Recipe.Runtime.recipePointer + (SIZEOF(LocalFoldProgram) * LIMIT(0, (g_CrossFoldAProcess.Common.Product.FoldProgram - 1), MAX_NUMBER_OF_CATEGORIES)));
		ELSE
			RETURN;		(* Can not access LocalFoldProgram before pointer is ok. *)
		END_IF
	
		g_CrossFoldAProcess.Parameters							:= LocalFoldProgram.CrossFoldA;
		g_CrossFoldAProcess.CrossParameters						:= LocalFoldProgram.CrossFold;
	
		BeltAdjustDummy 										:= LocalFoldProgram.Lateral.BeltAdjust;

		(*####################################*)
		(* BeltOpen, Extend gap between belts *)
		(*####################################*)

		//CASE g_LateralProcess.Parameters.BeltAdjust OF
		CASE BeltAdjustDummy OF
			

			//	If the leading EDGE has crossed the closed gap the xa adjust TO open 
			//	then the knife / air blows then after a TIME the gap closes
			// 	or
			//  If the leading EDGE has crossed the closed gap the xa remains closed
			//	then the knife / air blows
			//	then after a TIME the gap opens (special used BY B&B Overalls, DO avoid jaming OF the shoulder belt lockers) 
			//	so we need the buttons: 
			//	close > close
			//	Open > close
			//	close > open
			//	Open > open
		
			// Option not installed on Health care machine
			XA_BELT_NOT_USED_0:
				g_CrossFoldAProcess.BeltOpen1.StartDelayTime 	:= 0;
				g_CrossFoldAProcess.BeltOpen1.OnTime 			:= 0;
				// Gap is closed during the fold	
			XA_BELT_CLOSE_CLOSE_1:	
				g_CrossFoldAProcess.BeltOpen1.StartDelayTime 	:= 0;
				g_CrossFoldAProcess.BeltOpen1.OnTime 			:= 0;
				// Gap is open at start and closes after a time.
			XA_BELT_OPEN_CLOSE_2:	
				g_CrossFoldAProcess.BeltOpen1.StartDelayTime 	:= 1;
				g_CrossFoldAProcess.BeltOpen1.OnTime 			:= g_CrossFoldAProcess.Parameters.Belt1DelayTime;
				// Gap is closed and opens after a time
			XA_BELT_CLOSE_OPEN_3:	
				g_CrossFoldAProcess.BeltOpen1.StartDelayTime 	:= g_CrossFoldAProcess.Parameters.Belt1DelayTime;
				g_CrossFoldAProcess.BeltOpen1.OnTime 			:= 2800;
				// Gap is open during the fold	
			XA_BELT_OPEN_OPEN_4:	
				g_CrossFoldAProcess.BeltOpen1.StartDelayTime 	:= 0;
			g_CrossFoldAProcess.BeltOpen1.OnTime 			:= 2800;		// How to reset
					


		END_CASE


		(*#########################*)
		(*  Set Air and Knife time *)
		(*#########################*)

		IF (g_CrossFoldAProcess.Parameters.FoldDevice = FOLD_DEVICE_AIR_0) OR
			(g_CrossFoldAProcess.Parameters.FoldDevice = FOLD_DEVICE_AIR_KNIFE_2) THEN
			g_CrossFoldAProcess.Common.FoldUnit1.StartDelayTime 	:= g_CrossFoldAProcess.Parameters.BlowDelay;
			g_CrossFoldAProcess.Common.FoldUnit1.OnTime				:= g_CrossFoldAProcess.Parameters.BlowTime;
		ELSE
			g_CrossFoldAProcess.Common.FoldUnit1.OnTime				:= 0;
		END_IF
		IF (g_CrossFoldAProcess.Parameters.FoldDevice = FOLD_DEVICE_KNIFE_1) OR
			(g_CrossFoldAProcess.Parameters.FoldDevice = FOLD_DEVICE_AIR_KNIFE_2) THEN
			g_CrossFoldAProcess.Common.FoldUnit2.StartDelayTime 	:= g_CrossFoldAProcess.Parameters.KnifeDelay;
			g_CrossFoldAProcess.Common.FoldUnit2.OnTime				:= g_CrossFoldAProcess.Parameters.KnifeTime;
		ELSE
			g_CrossFoldAProcess.Common.FoldUnit2.OnTime				:= 0;
		END_IF

		(* SFX Fake to get at least some length to calculate with *)
		IF g_CrossFoldAProcess.Common.Product.Length = 0 THEN
			g_CrossFoldAProcess.Common.Product.Length := 1000;
		END_IF
		(* Get Fold Type to calculate timer values *)
		IF g_CrossFoldAProcess.Common.Product.SortOut > SORTOUT_AFTER_CROSSA_1 THEN
			g_CrossFoldAProcess.CrossParameters.FoldCombination := FOLD_COMB_BYPASS_UP_0;
		END_IF

		CASE g_CrossFoldAProcess.CrossParameters.FoldCombination OF

			FOLD_COMB_BYPASS_UP_0,
			FOLD_COMB_BYPASS_DOWN_1,
			FOLD_COMB_HALFFOLD_B_UP_4,
			FOLD_COMB_HALFFOLD_B_DOWN_5:
				//g_CrossFoldAProcess.FoldMode 							:= FOLD_MODE_BYPASS_1;
				g_CrossFoldAProcess.Common.ExitTime						:= (g_CrossFoldAProcess.Common.Product.Length * 100)/WHEEL_INC_TO_DISTANCE_MM;
				g_CrossFoldAProcess.Common.Product.Size					:= g_CrossFoldAProcess.Common.Product.Length;
				(* Always air on bypass *)
				g_CrossFoldAProcess.Common.FoldUnit1.StartDelayTime 	:= g_CrossFoldAProcess.Parameters.BlowDelay;
				g_CrossFoldAProcess.Common.FoldUnit1.OnTime				:= g_CrossFoldAProcess.Parameters.BlowTime;
				(* No knife if ByPass *)
				g_CrossFoldAProcess.Common.FoldUnit2.OnTime				:= 0;

				FOLD_COMB_HALFFOLD_A_UP_2,
				FOLD_COMB_HALFFOLD_A_DOWN_3,
				FOLD_COMB_FOURFOLD_INSIDE_10,
			FOLD_COMB_FOURFOLD_OUTSIDE_11:
				//g_CrossFoldAProcess.FoldMode	 						:= FOLD_MODE_DIRECT_3;
				g_CrossFoldAProcess.Common.Product.Size					:= g_CrossFoldAProcess.Common.Product.Length/2;
				g_CrossFoldAProcess.Common.ExitTime						:= ((g_CrossFoldAProcess.Common.Product.Length/2)*100)/WHEEL_INC_TO_DISTANCE_MM;
				//g_CrossFoldAProcess.Common.FoldPointTime				:= (((g_CrossFoldAProcess.Common.Product.Length/2) + g_CrossFoldAProcess.Parameters.FoldDistance)*100)/WHEEL_INC_TO_DISTANCE_MM;

				FOLD_COMB_THIRDFOLD_F_DIRECT_6,
			FOLD_COMB_THIRDFOLD_S_REVERSE_9:
				//g_CrossFoldAProcess.FoldMode	 						:= FOLD_MODE_DIRECT_3;
				g_CrossFoldAProcess.Common.Product.Size					:= g_CrossFoldAProcess.Common.Product.Length - (g_CrossFoldAProcess.Common.Product.Length/3);
				g_CrossFoldAProcess.Common.ExitTime						:= ((g_CrossFoldAProcess.Common.Product.Length - (g_CrossFoldAProcess.Common.Product.Length/3))*100)/WHEEL_INC_TO_DISTANCE_MM;
				//g_CrossFoldAProcess.Common.FoldPointTime				:= (((g_CrossFoldAProcess.Common.Product.Length/3) + g_CrossFoldAProcess.Parameters.FoldDistance)*100)/WHEEL_INC_TO_DISTANCE_MM;

				FOLD_COMB_THIRDFOLD_F_REVERSE_7,
			FOLD_COMB_THIRDFOLD_S_DIRECT_8:
				//g_CrossFoldAProcess.FoldMode	 						:= FOLD_MODE_DIRECT_3;
				g_CrossFoldAProcess.Common.Product.Size					:= g_CrossFoldAProcess.Common.Product.Length-(g_CrossFoldAProcess.Common.Product.Length/3);
				g_CrossFoldAProcess.Common.ExitTime						:= ((g_CrossFoldAProcess.Common.Product.Length-(g_CrossFoldAProcess.Common.Product.Length/3))*100)/WHEEL_INC_TO_DISTANCE_MM;
				//g_CrossFoldAProcess.Common.FoldPointTime				:= ((g_CrossFoldAProcess.Common.Product.Length - (g_CrossFoldAProcess.Common.Product.Length/3) + g_CrossFoldAProcess.Parameters.FoldDistance)*100)/WHEEL_INC_TO_DISTANCE_MM;

				FOLD_COMB_FIX_REAREDGE_INSIDE_12,
			FOLD_COMB_FIX_REAREDGE_OUTSID_13:
			g_CrossFoldAProcess.Common.Product.Size					:= g_CrossFoldAProcess.Common.Product.Length/2;
			g_CrossFoldAProcess.Common.ExitTime						:= ((g_CrossFoldAProcess.Common.Product.Length/2)*100)/WHEEL_INC_TO_DISTANCE_MM;
				(* Always air on bypass *)
				g_CrossFoldAProcess.Common.FoldUnit1.StartDelayTime 	:= g_CrossFoldAProcess.Parameters.BlowDelay;
				g_CrossFoldAProcess.Common.FoldUnit1.OnTime				:= g_CrossFoldAProcess.Parameters.BlowTime;
				(* No knife if ByPass *)
				//g_CrossFoldAProcess.Common.FoldUnit2.OnTime				:= 0;


				FOLD_COMB_FIX_LEADEDGE_INSIDE_14,
			FOLD_COMB_FIX_LEADEDGE_OUTSID_15:
			
				// 10-05-06 POX..
//				g_CrossFoldAProcess.Common.Product.Size					:= (2 * g_CrossFoldAProcess.CrossParameters.FixDimLeadEdge);
				//				g_CrossFoldAProcess.Common.ExitTime						:= ((2 * g_CrossFoldAProcess.CrossParameters.FixDimLeadEdge)*100)/WHEEL_INC_TO_DISTANCE_MM;
				g_CrossFoldAProcess.Common.Product.Size					:= g_CrossFoldAProcess.Common.Product.Length/2;
				g_CrossFoldAProcess.Common.ExitTime						:= ((g_CrossFoldAProcess.Common.Product.Length/2)*100)/WHEEL_INC_TO_DISTANCE_MM;
				g_CrossFoldAProcess.Common.FoldUnit1.StartDelayTime 	:= g_CrossFoldAProcess.Parameters.BlowDelay;
				g_CrossFoldAProcess.Common.FoldUnit1.OnTime				:= g_CrossFoldAProcess.Parameters.BlowTime;
				(* No knife if ByPass *)
				//g_CrossFoldAProcess.Common.FoldUnit2.OnTime				:= 0;


			FOLD_COMB_FIX_AB_16:
				//g_CrossFoldAProcess.FoldMode	 						:= FOLD_MODE_DIRECT_3;
				//g_CrossFoldAProcess.Common.Product.Size					:= BiggestResult(g_CrossFoldAProcess.Common.Product.Length, g_CrossFoldAProcess.Parameters.FoldDistance);
				g_CrossFoldAProcess.Common.Product.Size					:= BiggestResult(g_CrossFoldAProcess.Common.Product.Length, g_LateralProcess.Parameters.FoldDistance);
				g_CrossFoldAProcess.Common.ExitTime						:= ((g_CrossFoldAProcess.Common.Product.Length- g_LateralProcess.Parameters.FoldDistance)*100)/WHEEL_INC_TO_DISTANCE_MM;
			//g_CrossFoldAProcess.Common.FoldPointTime				:= (g_CrossFoldAProcess.Parameters.FoldDistance*100)/WHEEL_INC_TO_DISTANCE_MM;

		END_CASE

		IF g_CrossFoldAProcess.Common.Product.SortOut = SORTOUT_AFTER_CROSSA_1 THEN
			//g_CrossFoldAProcess.FoldMode 							:= FOLD_MODE_BYPASS_OUT_6;
			g_CrossFoldAProcess.Common.ExitTime						:= (g_CrossFoldAProcess.Common.Product.Length*100)/WHEEL_INC_TO_DISTANCE_MM;
			(* No Air or Knife *)
			g_CrossFoldAProcess.Common.FoldUnit1.OnTime				:= 0;
			g_CrossFoldAProcess.Common.FoldUnit2.OnTime				:= 0;
		END_IF
	
		// PMU: Extreme Heavy Option:
		g_CrossFoldAProcess.XtremeGap := LocalFoldProgram.XtremeHeavy.FXtremeGap;
	
	END_IF

	RunFoldTask(g_MCfg.Trace2File, ADR(T2FD), g_CrossFoldAProcess.Common,g_MachineManager[g_CrossFoldAProcess.Common.MachineManagerIndex]);
	CASE g_CrossFoldAProcess.Common.State OF

		(*####################################*)
		(* Start Up Machine, Home Axels etc.. *)
		(*####################################*)

		MACHPROC_STARTUP_1:

			(* Run for a while to ensure process is clean *)
			g_CrossFoldAProcess.Common.WatchDogRunTimer 		:= g_CrossFoldAProcess.Common.CurTimer;							(* start watchdog timer for process *)
			g_CrossFoldAProcess.Common.Previous.TransferStatus 	:= EXC_STANDBY_0;
			g_CrossFoldAProcess.Common.State 					:= MACHPROC_RUN_20;

			(*###############################################################*)
			(* Machien Stop case, to handle shut down process of the module  *)
			(*###############################################################*)

		MACHPROC_STOP_15:
			;
			(* Reset output and handle the shutdown procedure *)
			(* Extra stop cases may be needed.. *)

			g_CrossFoldAProcess.Common.State 							:= MACHPROC_INIT_0;

			(*#####################*)
			(* Main running state  *)
			(*#####################*)

		MACHPROC_RUN_20:
		
			(* Start the flow of goods *)
			IF g_RCfg[LIMIT(1, g_CrossFoldAProcess.Common.Previous.Product.FoldProgram, 99) - 1].CrossFold.FoldCombination = FOLD_COMB_THIRDFOLD_S_DIRECT_8 OR g_RCfg[LIMIT(1, g_CrossFoldAProcess.Common.Previous.Product.FoldProgram, 99) - 1].CrossFold.FoldCombination = FOLD_COMB_HALFFOLD_A_DOWN_3 OR g_RCfg[LIMIT(1, g_CrossFoldAProcess.Common.Previous.Product.FoldProgram, 99) - 1].CrossFold.FoldCombination = FOLD_COMB_FOURFOLD_INSIDE_10 THEN
				ReadyToNextPiece := g_StackerNormRelease OR g_StackerProcess[1].Common.State = 20 AND g_CrossFoldBProcess.Common.State = 20;
			ELSE
				ReadyToNextPiece := g_StackerEarlyRelease OR g_StackerProcess[1].Common.State = 20 AND g_CrossFoldBProcess.Common.State = 20;
			END_IF		
			IF g_CrossFoldAProcess.Common.Previous.TransferStatus = EXC_WANT_TO_UNLOAD_1 AND g_CrossFoldAProcess.Common.Next.TransferStatus = EXC_STANDBY_0 
				AND (ManualStop = 0) AND ReadyToNextPiece AND NOT g_Core.System.Interface.alarms.isLowAirPressure THEN
				//g_CrossFoldAProcess.Common.Previous.TransferStatus := EXC_READY_TO_RECIEVE_2;				// Lateral start motor forward
				g_CrossFoldAProcess.Common.State					:= MACHPROC_ENABLE_PARAM_READ_22;
				g_CrossFoldAProcess.Common.Product					:= g_CrossFoldAProcess.Common.Previous.Product;
				g_CrossFoldAProcess.Common.ReadParameters			:= TRUE;

			END_IF


			(*##################################################*)
			(* Module specific states for running of the module *)
			(*##################################################*)


		MACHPROC_ENABLE_PARAM_READ_22:
			// Just to wait one cycle until all paramerers are read correctly and check if knif is needed..

			IF (g_CrossFoldAProcess.Parameters.FoldDevice = FOLD_DEVICE_KNIFE_1) OR	(g_CrossFoldAProcess.Parameters.FoldDevice = FOLD_DEVICE_AIR_KNIFE_2) THEN
				g_CrossFoldAProcess.Common.FoldUnit2.State	:= FOLDIO_STATE_KICKSTART_4;	// Knife 
				g_CrossFoldAProcess.WaitKnifeTimer			:= g_CrossFoldAProcess.Common.CurTimer;
				g_CrossFoldAProcess.Common.State			:= MACHPROC_START_KNIFE_23;
			ELSE
				g_CrossFoldAProcess.Common.State			:= MACHPROC_FOLD_POINT_25;
			END_IF	


		MACHPROC_START_KNIFE_23:
	
		
			IF ElapsedMsTime(g_CrossFoldAProcess.Common.CurTimer, g_CrossFoldAProcess.WaitKnifeTimer) >= g_CrossFoldAProcess.Common.FoldUnit2.StartDelayTime THEN
				g_CrossFoldAProcess.Common.State		:= MACHPROC_FOLD_POINT_25;
			END_IF


		MACHPROC_FOLD_POINT_25:
	
			// Flow is already started above but we must wait for the knife before starting motor..
			IF g_CrossFoldAProcess.Common.Previous.TransferStatus = EXC_WANT_TO_UNLOAD_1 THEN
				g_CrossFoldAProcess.Common.Previous.TransferStatus := EXC_READY_TO_RECIEVE_2;				// Lateral start motor forward
				(* Wait for data from previous task *)
			ELSIF g_CrossFoldAProcess.Common.Previous.TransferStatus = EXC_UNLOADING_3 THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldAProcess.Common.LogBookFlag, g_DummyPulses, 'XA foldpoint');
				g_CrossFoldAProcess.BeltOpen1.State	 				:= FOLDIO_STATE_START_1;	// Gap adjust start	
				g_CrossFoldAProcess.Common.FoldUnit1.State			:= FOLDIO_STATE_START_1;	(* Air pipe *)
				g_CrossFoldAProcess.Common.Motor.cmdReverse			:= TRUE;
				g_CrossFoldAProcess.Common.Motor.StopTimer 			:= g_CrossFoldAProcess.Common.CurTimer;
				g_CrossFoldAProcess.Folding 						:= TRUE;
				g_CrossFoldAProcess.Common.Previous.TransferStatus 	:= EXC_RECIVING_4;						
				g_CrossFoldAProcess.Common.State 					:= MACHPROC_WAIT_FOLD_DONE_28;
			END_IF




		MACHPROC_WAIT_FOLD_DONE_28:

			g_LateralProcess.SetGap										:= FALSE;	// Reset gap here, then timer should be started...

			IF (g_CrossFoldAProcess.Common.Previous.TransferStatus = EXC_FINISHED_UNLOADING_5) THEN	(* I have the goods *)
				g_CrossFoldAProcess.Common.Previous.TransferStatus		:= EXC_RECIVING_DONE_6;
				g_CrossFoldAProcess.Common.WatchDogRunTimer 			:= g_CrossFoldAProcess.Common.CurTimer;							(* start watchdog timer for process *)
				g_CrossFoldAProcess.Common.State 						:= MACHPROC_DELIVER_PACKAGE_80;
				g_CrossFoldAProcess.Common.ExitTimer 					:= g_DummyPulses;
			END_IF




		MACHPROC_DELIVER_PACKAGE_80:

			(* Wait for next task to prepare to take over product. *)
			IF g_CrossFoldAProcess.Common.Next.TransferStatus = EXC_STANDBY_0 THEN
				g_CrossFoldAProcess.Common.WatchDogRunTimer 	:= g_CrossFoldAProcess.Common.CurTimer;							(* start watchdog timer for process *)
				g_CrossFoldAProcess.Common.Next.Product 		:= g_CrossFoldAProcess.Common.Product;
				g_CrossFoldAProcess.Common.Next.TransferStatus 	:= EXC_WANT_TO_UNLOAD_1;
				g_CrossFoldAProcess.Common.State 				:= MACHPROC_PACKAGE_DELIVERED_81;
			END_IF
			g_CrossFoldAProcess.Common.WatchDogRunTimer 		:= g_CrossFoldAProcess.Common.CurTimer;							(* start watchdog timer for process *)

		MACHPROC_PACKAGE_DELIVERED_81:

			IF g_CrossFoldAProcess.Common.Next.TransferStatus = EXC_READY_TO_RECIEVE_2 THEN
				g_CrossFoldAProcess.Common.Next.TransferStatus 	:= EXC_UNLOADING_3;
			ELSIF g_CrossFoldAProcess.Common.Next.TransferStatus = EXC_RECIVING_4 THEN
				g_CrossFoldAProcess.Common.Next.TransferStatus 	:= EXC_FINISHED_UNLOADING_5;
				g_CrossFoldAProcess.Common.State 				:= MACHPROC_WAIT_BEFORE_EXIT_82;
				g_CrossFoldAProcess.Common.WatchDogRunTimer 	:= g_CrossFoldAProcess.Common.CurTimer;							(* start watchdog timer for process *)
			END_IF

		MACHPROC_WAIT_BEFORE_EXIT_82:

			(* Normal case... *)
			IF g_CrossFoldAProcess.Common.Next.TransferStatus = EXC_STANDBY_0 THEN
				g_CrossFoldAProcess.Common.Previous.TransferStatus 	:= EXC_STANDBY_0;
				g_CrossFoldAProcess.Common.Motor.State 				:= MOTOR_STATE_IDLE_1;
				g_CrossFoldAProcess.Common.State 					:= MACHPROC_RUN_20;
				g_CrossFoldAProcess.Common.WatchDogRunTimer 		:= g_CrossFoldAProcess.Common.CurTimer;
			END_IF
		
			(* Error in Cross B go back to restart next piece *)
			IF g_CrossFoldAProcess.Common.Next.TransferStatus = EXC_ERROR_99 THEN
				g_CrossFoldAProcess.Common.Previous.TransferStatus 	:= EXC_STANDBY_0;
				g_CrossFoldAProcess.Common.Motor.State 				:= MOTOR_STATE_IDLE_1;
				g_CrossFoldAProcess.Common.State 					:= MACHPROC_RUN_20;
				g_CrossFoldAProcess.Common.WatchDogRunTimer 		:= g_CrossFoldAProcess.Common.CurTimer;
			END_IF
		
			g_CrossFoldAProcess.Common.WatchDogRunTimer 			:= g_CrossFoldAProcess.Common.CurTimer;					(* start watchdog timer for process *)


		MACHPROC_ERROR_99:

			g_CrossFoldAProcess.Common.Motor.cmdStop		:= TRUE;
			g_CrossFoldAProcess.Folding := FALSE;

	END_CASE

	TOF_BXBFold(IN := IBXBFold, PT := T#200ms);

	// Reverse immediately after folding - Fox-1200
	IF g_CrossFoldAProcess.Folding AND EDGENEG(TOF_BXBFold.Q) THEN
		g_CrossFoldAProcess.Folding := FALSE;
		g_CrossFoldAProcess.Common.Motor.cmdForward := TRUE;
	END_IF


	(* Detect if error occurs and what to do *)
	IF 	g_CrossFoldAProcess.Common.State >= MACHPROC_RUN_20 AND
		g_CrossFoldAProcess.Common.State < MACHPROC_TRIG_ERROR_98 THEN
		IF ElapsedMsTime(g_CrossFoldAProcess.Common.CurTimer, g_CrossFoldAProcess.Common.WatchDogRunTimer) > (g_CrossFoldAProcess.Common.WatchDogRunTime-100) THEN
			IF g_CrossFoldAProcess.Common.State <= MACHPROC_WAIT_FOR_TRIG_23 THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldAProcess.Common.LogBookFlag, g_CrossFoldAProcess.Common.State, 'XA timeout 1');
				g_CrossFoldAProcess.Common.State 					:= MACHPROC_RUN_20;
				g_CrossFoldAProcess.Common.Previous.TransferStatus 	:= EXC_STANDBY_0;
			ELSIF g_CrossFoldAProcess.Common.State >= MACHPROC_DELIVER_PACKAGE_80 THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldAProcess.Common.LogBookFlag, g_CrossFoldAProcess.Common.State, 'XA timeout 2');
				g_CrossFoldAProcess.Common.State 					:= MACHPROC_RUN_20;
				g_CrossFoldAProcess.Common.Previous.TransferStatus 	:= EXC_STANDBY_0;
			ELSE
				; (* Do nothing, this is a true timeout *)
			END_IF
		END_IF
	END_IF



	ActivateFoldIO(g_CrossFoldAProcess.BeltOpen1, g_CrossFoldAProcess.Common.CurTimer);



	IF g_CrossFoldAProcess.Common.Motor.Run THEN
		IF g_CrossFoldAProcess.Common.Motor.Direction = MOTOR_DIRECTION_FORWARD THEN
			QMXAFoldForward		:= NOT g_XBStopMotor;
			QMXAFoldReverse		:= FALSE;
		ELSE
			QMXAFoldForward		:= FALSE;
			QMXAFoldReverse		:= NOT g_XBStopMotor;
		END_IF
		QMXAFold2 := TRUE;
	ELSE
		QMXAFoldForward			:= FALSE;
		QMXAFoldReverse			:= FALSE;
		QMXAFold2 := FALSE;
	END_IF


	QYAirXAFold		:= g_CrossFoldAProcess.Common.FoldUnit1.Output;
	QYXAFoldKnife			:= g_CrossFoldAProcess.Common.FoldUnit2.Output AND g_HCfg.CrossFoldingKnife;
	QYXAOpen[0]				:= (g_CrossFoldAProcess.BeltOpen1.Output OR g_LateralProcess.SetGap) AND g_HCfg.CrossFoldingGapAdjust;					

	// PMU: Xtreme Heavy Option
	QYXAOpen[1] := (g_LateralProcess.SetGap AND g_HCfg.CrossFoldingGapAdjust AND g_CrossFoldAProcess.XtremeGap) OR g_XtremeHeavy.Gap; 

END_PROGRAM

