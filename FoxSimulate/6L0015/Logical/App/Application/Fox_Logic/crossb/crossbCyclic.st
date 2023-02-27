PROGRAM _CYCLIC
(* cyclic program *)

(*-------------------------------------------------------------------------------------

Author:   				Sten Flystedt

FileName:				CrossB.scr

Desription:				CrossB

Reference:

Interfaces:				No interfaces.

Watch debugg:			Name OF important watch configurations.

History:
10-05-06				V1.13.9	PO Nilsson		Increased the WatchDogTimeOut TO 3 seconds...
												Changed in parameter OF fold 14 so Size is FixDimLeadEdge..
10-03-24				V1.13.8	PO Nilsson		NOT global stack change on FoldProgram change.. But specified stacker...
10-03-12				V1.13.7	PO Nilsson		Added alarm IF photocell is covered at start OF fold.
												Shortened Watchdog time from 10 TO 2 seconds.
10-02-04				V1.13.6	PO Nilsson		Removed some commented parts.
10-01-27				V1.13.5	PO Nilsson		In fold _13 booth air blast where set.
												Curtimer FOR running RunIOCounter insensor was the Curtimer OF Lateral..
10-01-26				V1.13.4	PO Nilsson		Now the Photocell sets the FoldPoint AND LeadEdge.
10-01-25				V1.13.3	PO NIlsson		More fix fold...
10-01-24				V1.13.2 PO Nilsson		Fixed the fold type 13 Fix...	
10-01-14				V1.13.1	PO Nilsson		Removed the total counter FOR the stat, and placed it in stacker with the rest..
09-12-09				V1.13.0	PO Nilsson		Changed structure OF CategoryData_Type, not so many parameters in StackerBelt...
09-12-03				V1.12.3	PO Nilsson		Fix FOR the Fix dimension folding, it's done in FoldCombination 14 and 15 Check the rest as well...
09-12-02				V1.12.2	PO Nilsson		Increased the xit time FOR Third folds, and Slope reset when XB reverse fold is executed..
												Removed alarm that photocells is covered at start, sins fold has already been executed from XA..
09-11-04				V1.12.1	PO Nilsson		Bug fixing FOR Multistacker stack change..
09-10-28				V1.12.0	Sten Flystedt	StackChange now handles multiple stack AND items on its way TO stacker.
09-10-27				V1.11.2	PO Nilsson		Removed machine manager index from init part OF xb..
09-10-21				V1.11.1 PO Nilsson		Merge from Holbaek..
09-10-15				V1.11.0 PO Nilsson		Started with MultiStacker
09-10-01				V1.10.2 PO Nilsson		Bug fixes on site Holbaek
09-08-13				V1.10.1 SF/PO Nilsson	Making pre-check IF stack change is needed.
09-03-11				V1.10 PO Nilsson		Adapted TO Fox..

08-07-01				V1.01 Sten Flystedt		First edition...

---------------------------------------------------------------------------------------*)
	
	MHATest;

	g_EnableJDLogData;
	IF g_TestLogData OR TestLogData THEN
		TestLogData := FALSE;
		LogData_0(Type := 1, Lane := 1, Info1 := g_Core.Services.CAR.Runtime.No[0].RecipeNumber - 1, Info2 := ADR(g_Core.Services.CAR.Runtime.No[0].RecipeName));
	END_IF
	

(*#####################*)
(* Get current time... *)
(*#####################*)
	g_CrossFoldBProcess.Common.CurTimer 					:= g_Timers._1_ms;			(* Get current time *)
	IF g_CrossFoldBProcess.Common.LogBookFlag > 0 THEN
		strcpy(ADR(TmpStr),ADR(g_CrossFoldBProcess.Common.Description));
	END_IF

	IF NOT (g_Core.Services.Recipe.Runtime.recipePointer > 0) THEN			(* Check that pointer is bigger then Null *)
		RETURN;									(* Do not run task before pointer is assigned... *)
	END_IF

	(*#################################*)
	(* copy status of exchange objects *)
	(*#################################*)

	g_CrossFoldBProcess.Common.Previous		:= g_CrossFoldAProcess.Common.Next;
	g_CrossFoldBProcess.Common.Next			:= g_StackerProcess[1].Common.Previous;


	(*########################################*)
	(* Connect inputs to the module structure *)
	(*########################################*)

	g_CrossFoldBProcess.Common.InSensor.Input	:= IBXBFoldEdge OR g_sim.IBXBFold;		(* Photocell between XA and XB... *)


	(*######################*)
	(* Connect timer values *)
	(*######################*)
	g_CrossFoldBProcess.Common.WatchDogStartupTime			:= 3000;
	g_CrossFoldBProcess.Common.WatchDogRunTime				:= JamTimeGenerel;
	g_CrossFoldBProcess.Common.Motor.RunTime				:= g_MCfg.ConveyorRunTime;

	g_CrossFoldBProcess.Common.InSensor.OnDelay				:= 2;
	g_CrossFoldBProcess.Common.InSensor.OffDelay			:= g_MCfg.SensorFilterTime;

	IF g_CrossFoldBProcess.Common.ReadParameters THEN
		g_CrossFoldBProcess.Common.ReadParameters := FALSE;

		IF g_Core.Services.Recipe.Runtime.recipePointer > 0 THEN			(* Check that pointer is bigger then Null *)
			LocalFoldProgram ACCESS(g_Core.Services.Recipe.Runtime.recipePointer + (SIZEOF(LocalFoldProgram) * LIMIT(0, (g_CrossFoldBProcess.Common.Product.FoldProgram - 1), MAX_NUMBER_OF_CATEGORIES)));
		ELSE
			RETURN;		(* Can not access LocalFoldProgram before pointer is ok. *)
		END_IF

		g_CrossFoldBProcess.Parameters							:= LocalFoldProgram.CrossFoldB;
		g_CrossFoldBProcess.CrossParameters						:= LocalFoldProgram.CrossFold;

		CROSSB_EXTRA_REVERSE_TIME								:= g_MCfg.XFold.CrossBExtraRewerseTime + g_CrossFoldBProcess.Parameters.ReverseTimeAdjust;
		
		//FixFold- tmp test
		FixFoldAdjusting	:= g_MCfg.XFold.DistanceXB_FoldPoint -100;
		// XtremeHeavy - PMU 01.03.16
		g_CrossFoldBProcess.RaiseTiltConv := LocalFoldProgram.XtremeHeavy.FRaiseTiltConv;

		(* Set Time for Lead Blow and Trail Blow *)
		g_CrossFoldBProcess.LeadBlowForward.StartDelayTime 	:= g_CrossFoldBProcess.Parameters.BlowDelayLeading;
		g_CrossFoldBProcess.LeadBlowForward.OnTime			:= g_CrossFoldBProcess.Parameters.BlowTimeLeading;
		g_CrossFoldBProcess.LeadBlowReverse.StartDelayTime 	:= g_CrossFoldBProcess.Parameters.BlowDelayLeading;
		g_CrossFoldBProcess.LeadBlowReverse.OnTime			:= g_CrossFoldBProcess.Parameters.BlowTimeLeading;
		g_CrossFoldBProcess.ReverseBlow.StartDelayTime 		:= g_CrossFoldBProcess.Parameters.BlowDelayReversing;
		g_CrossFoldBProcess.ReverseBlow.OnTime				:= g_CrossFoldBProcess.Parameters.BlowTimeReversing;

		(* Reset FoldBlow time, To be set below due to fold conditions *)
		g_CrossFoldBProcess.Common.FoldUnit1.OnTime				:= 0;
		g_CrossFoldBProcess.Common.FoldUnit2.OnTime				:= 0;

		g_CrossFoldBProcess.LeadEdgeTime						:= ((g_MCfg.XFold.DistanceXB_FoldPoint(*mm*) - g_MCfg.XFold.CrossBByPassPrestartFoldPoint(*mm*) )*100)/WHEEL_INC_TO_DISTANCE_MM;

		g_CrossFoldBProcess.Common.HoldingPointTime				:= g_MCfg.XFold.DistanceXBFoldPoint_XBExit;

		g_CrossFoldBProcess.SlopeDownTime 						:= g_CrossFoldBProcess.Parameters.SlopeOnTime;


		(* Get Fold Type to calculate timer values *)
		CASE g_CrossFoldBProcess.CrossParameters.FoldCombination OF
			FOLD_COMB_BYPASS_UP_0,
			FOLD_COMB_HALFFOLD_A_UP_2:
				g_CrossFoldBProcess.FoldMode 							:= FOLD_MODE_BYPASS_REVERSE_2;
				g_CrossFoldBProcess.Common.Product.Size					:= g_CrossFoldBProcess.Common.Product.Size;

				FOLD_COMB_BYPASS_DOWN_1,
			FOLD_COMB_HALFFOLD_A_DOWN_3:
				g_CrossFoldBProcess.FoldMode 							:= FOLD_MODE_BYPASS_DIRECT_1;
				g_CrossFoldBProcess.Common.Product.Size					:= g_CrossFoldBProcess.Common.Product.Size;

				FOLD_COMB_HALFFOLD_B_DOWN_5,
				FOLD_COMB_THIRDFOLD_F_DIRECT_6,
				FOLD_COMB_THIRDFOLD_S_DIRECT_8,
			FOLD_COMB_FOURFOLD_INSIDE_10:
				g_CrossFoldBProcess.FoldMode 							:= FOLD_MODE_DIRECT_3;
				g_CrossFoldBProcess.Common.FoldPointTime				:= ((g_MCfg.XFold.DistanceXB_FoldPoint(*mm*) + (g_CrossFoldBProcess.Common.Product.Size/2) + g_CrossFoldBProcess.Parameters.FoldDistance)*100)/WHEEL_INC_TO_DISTANCE_MM;
				g_CrossFoldBProcess.Common.Product.Size					:= g_CrossFoldBProcess.Common.Product.Size/2;
				g_CrossFoldBProcess.Common.FoldUnit1.OnTime				:= g_CrossFoldBProcess.Parameters.BlowTimeFolding;
				g_CrossFoldBProcess.Common.FoldUnit1.StartDelayTime		:= g_CrossFoldBProcess.Parameters.BlowDelayFolding;

				FOLD_COMB_HALFFOLD_B_UP_4,
				FOLD_COMB_THIRDFOLD_F_REVERSE_7,
				FOLD_COMB_THIRDFOLD_S_REVERSE_9,
			FOLD_COMB_FOURFOLD_OUTSIDE_11:
				g_CrossFoldBProcess.FoldMode 							:= FOLD_MODE_REVERSE_4;
				g_CrossFoldBProcess.Common.FoldPointTime				:= ((g_MCfg.XFold.DistanceXB_FoldPoint(*mm*) + (g_CrossFoldBProcess.Common.Product.Size/2) + g_CrossFoldBProcess.Parameters.FoldDistance)*100)/WHEEL_INC_TO_DISTANCE_MM;
				g_CrossFoldBProcess.Common.Product.Size					:= g_CrossFoldBProcess.Common.Product.Size/2;
				g_CrossFoldBProcess.Common.FoldUnit2.OnTime				:= g_CrossFoldBProcess.Parameters.BlowTimeFolding;
				g_CrossFoldBProcess.Common.FoldUnit2.StartDelayTime		:= g_CrossFoldBProcess.Parameters.BlowDelayFolding;

			FOLD_COMB_FIX_REAREDGE_INSIDE_12:
				g_CrossFoldBProcess.FoldMode 							:= FOLD_MODE_DIRECT_3;
				g_CrossFoldBProcess.Common.FoldPointTime				:= ((g_MCfg.XFold.DistanceXB_FoldPoint(*mm*)+g_CrossFoldBProcess.Common.Product.Size-g_CrossFoldBProcess.CrossParameters.FixDimRearEdge)*100)/WHEEL_INC_TO_DISTANCE_MM;
				g_CrossFoldBProcess.Common.FoldUnit1.OnTime				:= g_CrossFoldBProcess.Parameters.BlowTimeFolding;
				g_CrossFoldBProcess.Common.FoldUnit1.StartDelayTime		:= g_CrossFoldBProcess.Parameters.BlowDelayFolding;
				g_CrossFoldBProcess.Common.Product.Size					:= BiggestResult(g_CrossFoldBProcess.Common.Product.Size,g_CrossFoldBProcess.CrossParameters.FixDimRearEdge);


			FOLD_COMB_FIX_REAREDGE_OUTSID_13:
				g_CrossFoldBProcess.FoldMode 							:= FOLD_MODE_REVERSE_4;;
				g_CrossFoldBProcess.Common.FoldPointTime				:= ((FixFoldAdjusting(*mm*) + (g_CrossFoldBProcess.CrossParameters.FixDimRearEdge) + g_CrossFoldBProcess.Parameters.FoldDistance)*100)/WHEEL_INC_TO_DISTANCE_MM;
				g_CrossFoldBProcess.Common.Product.Size					:= g_CrossFoldBProcess.Common.Product.Size/2;

				g_CrossFoldBProcess.Common.FoldUnit2.OnTime				:= g_CrossFoldBProcess.Parameters.BlowTimeFolding;
				g_CrossFoldBProcess.Common.FoldUnit2.StartDelayTime		:= g_CrossFoldBProcess.Parameters.BlowDelayFolding;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_CrossFoldBProcess.Common.LogBookFlag, g_CrossFoldBProcess.Common.Product.Size, 'XB, Fix Rear Size from XA');
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_CrossFoldBProcess.Common.FoldPointTime, 'XB, Fix Rear prev Fold point..');


			FOLD_COMB_FIX_LEADEDGE_INSIDE_14:
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_CrossFoldBProcess.Common.FoldPointTime, 'XB, Fix Lead prev Fold point..');
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_CrossFoldBProcess.Common.LogBookFlag, g_CrossFoldBProcess.Common.Product.Size, 'XB, Fix Lead Size from XA');
				g_CrossFoldBProcess.FoldMode 							:= FOLD_MODE_DIRECT_3;

				g_CrossFoldBProcess.Common.FoldPointTime				:= ((FixFoldAdjusting(*mm*) + (g_CrossFoldBProcess.CrossParameters.FixDimLeadEdge) + g_CrossFoldBProcess.Parameters.FoldDistance)*100)/WHEEL_INC_TO_DISTANCE_MM;
				g_CrossFoldBProcess.Common.Product.Size					:= g_CrossFoldBProcess.Common.Product.Size/2;				
				g_CrossFoldBProcess.Common.FoldUnit1.OnTime				:= g_CrossFoldBProcess.Parameters.BlowTimeFolding;
				g_CrossFoldBProcess.Common.FoldUnit1.StartDelayTime		:= g_CrossFoldBProcess.Parameters.BlowDelayFolding;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_CrossFoldBProcess.Common.FoldPointTime, 'XB, Fix Lead.. Fold point..');

			
			FOLD_COMB_FIX_LEADEDGE_OUTSID_15:
				g_CrossFoldBProcess.FoldMode 							:= FOLD_MODE_REVERSE_4;
				g_CrossFoldBProcess.Common.FoldPointTime				:= ((g_MCfg.XFold.DistanceXB_FoldPoint(*mm*)+g_CrossFoldBProcess.Common.Product.Size-g_CrossFoldBProcess.CrossParameters.FixDimLeadEdge + g_CrossFoldBProcess.Parameters.FoldDistance)*100)/WHEEL_INC_TO_DISTANCE_MM;
				g_CrossFoldBProcess.Common.Product.Size					:= BiggestResult(g_CrossFoldBProcess.Common.Product.Size,g_CrossFoldBProcess.CrossParameters.FixDimLeadEdge);
				g_CrossFoldBProcess.Common.FoldUnit1.StartDelayTime		:= g_CrossFoldBProcess.Parameters.BlowDelayFolding;
				g_CrossFoldBProcess.Common.FoldUnit1.OnTime				:= g_CrossFoldBProcess.Parameters.BlowTimeFolding;

			FOLD_COMB_FIX_AB_16:
				g_CrossFoldBProcess.FoldMode 							:= FOLD_MODE_REVERSE_4;
				g_CrossFoldBProcess.Common.Product.Size					:= BiggestResult(g_CrossFoldBProcess.Common.Product.Size,g_CrossFoldBProcess.Parameters.FoldDistance);
				g_CrossFoldBProcess.Common.FoldPointTime				:= ((g_MCfg.XFold.DistanceXB_FoldPoint(*mm*)+g_CrossFoldBProcess.Parameters.FoldDistance)*100)/WHEEL_INC_TO_DISTANCE_MM;
				g_CrossFoldBProcess.Common.FoldUnit2.OnTime				:= g_CrossFoldBProcess.Parameters.BlowTimeFolding;
				g_CrossFoldBProcess.Common.FoldUnit2.StartDelayTime		:= g_CrossFoldBProcess.Parameters.BlowDelayFolding;

		END_CASE

		(* Calculate Exit Time after folding or bypass. *)
		g_CrossFoldBProcess.Common.ExitTime						:= ((g_CrossFoldBProcess.Common.Product.Size)*100)/WHEEL_INC_TO_DISTANCE_MM;

		(* Calculate Reverse Time after folding or bypass. Use the current size of the towel plus some extra *)
		g_CrossFoldBProcess.ReverseTime							:= ((g_CrossFoldBProcess.Common.Product.Size + CROSSB_EXTRA_REVERSE_TIME)*100)/WHEEL_INC_TO_DISTANCE_MM;

		IF g_CrossFoldBProcess.Common.Product.SortOut = SORTOUT_AFTER_CROSSB_3 THEN
			g_CrossFoldBProcess.FoldMode 							:= FOLD_MODE_BYPASS_REVERSE_OUT_5;
		ELSIF g_CrossFoldBProcess.Common.Product.SortOut > 0 THEN
			g_CrossFoldBProcess.FoldMode 							:= FOLD_MODE_BYPASS_DIRECT_1;
		END_IF
	END_IF


	(* Run IO Counter function *)
	RunIOCounter(g_CrossFoldBProcess.Common.InSensor, g_CrossFoldBProcess.Common.CurTimer);



	RunFoldTask(g_MCfg.Trace2File, ADR(T2FD), g_CrossFoldBProcess.Common,g_MachineManager[g_CrossFoldBProcess.Common.MachineManagerIndex]);
	CASE g_CrossFoldBProcess.Common.State OF

		(*####################################*)
		(* Start Up Machine, Home Axels etc.. *)
		(*####################################*)

		MACHPROC_STARTUP_1:

			(* Run for a while to ensure process is clean *)
			g_CrossFoldBProcess.Common.WatchDogRunTimer 		:= g_CrossFoldBProcess.Common.CurTimer;
			g_CrossFoldBProcess.Common.Previous.TransferStatus 	:= EXC_STANDBY_0;
			g_CrossFoldBProcess.Common.State 					:= MACHPROC_RUN_20;

			(*###############################################################*)
			(* Machien Stop case, to handle shut down process of the module  *)
			(*###############################################################*)

		MACHPROC_STOP_15:
			;
			(* Reset output and handle the shutdown procedure *)
			(* Extra stop cases may be needed.. *)

			g_CrossFoldBProcess.Common.State 							:= MACHPROC_INIT_0;
			g_CrossFoldBProcess.Common.Motor.cmdStop					:= TRUE;
			gXAFold2Motor.CountReset := g_MilliSeconds;
			gXAFold2Motor.Set := FALSE;
			gXAFold2Motor.Reset := TRUE;
			g_CrossFoldBProcess.SlopeLift								:= FALSE;

			(*#####################*)
			(* Main running state  *)
			(*#####################*)

		MACHPROC_RUN_20:

		
			// Trigger alarm if photocell is covered...
			IF g_CrossFoldBProcess.Common.InSensor.Output  AND NOT g_sim.Test THEN
				g_CrossFoldBProcess.Common.ErrorCode 	:= 5;
				g_CrossFoldBProcess.Common.State		:= MACHPROC_TRIG_ERROR_98;	
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB, Photocell active at start _22');
			END_IF	
		
		

			(* Start the flow of goods *)
			IF g_CrossFoldBProcess.Common.Previous.TransferStatus = EXC_WANT_TO_UNLOAD_1 AND NOT g_Core.System.Interface.alarms.isLowAirPressure THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB, Req from XA');
				g_CrossFoldBProcess.Common.Previous.TransferStatus 	:= EXC_READY_TO_RECIEVE_2;
				g_CrossFoldBProcess.Common.WatchDogRunTimer 		:= g_CrossFoldBProcess.Common.CurTimer;
				g_CrossFoldBProcess.Common.State					:= MACHPROC_WAIT_FOR_JOB_22;
			END_IF

			(*##################################################*)
			(* Module specific states for running of the module *)
			(*##################################################*)


		MACHPROC_WAIT_FOR_JOB_22:

			(* Previous task is ready to unload*)
			IF g_CrossFoldBProcess.Common.Previous.TransferStatus = EXC_UNLOADING_3 THEN
				g_CrossFoldBProcess.Common.Product						:= g_CrossFoldBProcess.Common.Previous.Product;
				g_CrossFoldBProcess.Common.ReadParameters 				:= TRUE;
				g_CrossFoldBProcess.Common.Previous.TransferStatus 		:= EXC_RECIVING_4;
				g_CrossFoldBProcess.Common.State 						:= MACHPROC_WAIT_EVALUATE_23;
			END_IF

		
		

		MACHPROC_WAIT_EVALUATE_23:
			(* Just a single loop to evaluate new fold parameters *)
			g_CrossFoldBProcess.SlopeLift							:= g_CrossFoldBProcess.Parameters.SlopeMode = SLOPEMODE_ACTIVE_1;
			g_LateralProcess.SetSlope								:= FALSE;	// Is set from Lateral process
			g_CrossFoldBProcess.SlopeDownTimer 						:= g_CrossFoldBProcess.Common.CurTimer;
			g_CrossFoldBProcess.GarmentDetected 					:= FALSE;
		
			FoldPointIsSet											:= FALSE;
			g_CrossFoldBProcess.Common.InSensor.OldEdgeCounter 		:= g_CrossFoldBProcess.Common.InSensor.EdgeCounter;
		
			g_CrossFoldBProcess.Common.State 						:= MACHPROC_WAIT_FOR_LEAD_EDGE_24;
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB Data rec');


		MACHPROC_WAIT_FOR_LEAD_EDGE_24:
		

			// Sync with photocell
			IF g_CrossFoldBProcess.Common.InSensor.Output AND NOT FoldPointIsSet THEN	
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_CrossFoldBProcess.Common.FoldPointTime, 'XB, Photocell Sync.. Fold point..');
				g_CrossFoldBProcess.Common.InSensor.OldEdgeCounter 		:= g_CrossFoldBProcess.Common.InSensor.EdgeCounter;
				g_CrossFoldBProcess.LeadEdgeTimer						:= g_DummyPulses;
				g_CrossFoldBProcess.Common.FoldPointTimer				:= g_DummyPulses;
				StopMotor.Delay 										:= g_CrossFoldBProcess.Parameters.StopMotorDelay;
				StopMotor.On 											:= g_CrossFoldBProcess.Parameters.StopMotorTime;
				StopMotor.Set 											:= g_CrossFoldBProcess.Parameters.StopMotorEnable;
				FoldPointIsSet											:= TRUE;
			END_IF
		
			// V2.3.6 - We set the dommand to run XB Motor earlier 
			CASE g_CrossFoldBProcess.FoldMode OF
				FOLD_MODE_BYPASS_DIRECT_1,FOLD_MODE_REVERSE_4:
					g_CrossFoldBProcess.Common.Motor.cmdReverse		:= TRUE;

				FOLD_MODE_BYPASS_REVERSE_2, FOLD_MODE_BYPASS_REVERSE_OUT_5,FOLD_MODE_DIRECT_3:
					g_CrossFoldBProcess.Common.Motor.cmdForward		:=	TRUE;
			END_CASE



			// Lead edge blast when garment comes to XB begining, Not fold point
			IF (ElapsedMsTime(g_DummyPulses, g_CrossFoldBProcess.LeadEdgeTimer) >= g_CrossFoldBProcess.LeadEdgeTime) AND FoldPointIsSet	THEN (* Cycle should be ended *)
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB leadedge');
				CASE g_CrossFoldBProcess.FoldMode OF
					FOLD_MODE_BYPASS_DIRECT_1:
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB, BP direct');
						g_CrossFoldBProcess.LeadBlowReverse.State 		:= FOLDIO_STATE_START_1;
						g_CrossFoldBProcess.Common.ExitTimer			:= g_DummyPulses;
						g_CrossFoldBProcess.Common.HoldingPointTimer	:= g_DummyPulses;
						g_CrossFoldBProcess.SlopeDownTimer 				:= g_CrossFoldBProcess.Common.CurTimer;
						g_CrossFoldBProcess.Common.State 				:= MACHPROC_DELIVER_PACKAGE_80;

					FOLD_MODE_BYPASS_REVERSE_2, FOLD_MODE_BYPASS_REVERSE_OUT_5:
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB, BP reverse');
						g_CrossFoldBProcess.LeadBlowForward.State 		:= FOLDIO_STATE_START_1;
						g_CrossFoldBProcess.ReverseTimer				:= g_DummyPulses;
						g_CrossFoldBProcess.Common.State 				:= MACHPROC_WAIT_REVERSE_POINT_30;

					FOLD_MODE_DIRECT_3:
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB, Fold direct');
						g_CrossFoldBProcess.LeadBlowForward.State 		:= FOLDIO_STATE_START_1;
						g_CrossFoldBProcess.Common.State 				:= MACHPROC_WAIT_FOLD_POINT_25;

					FOLD_MODE_REVERSE_4:
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB,Fold reverse');
						g_CrossFoldBProcess.LeadBlowReverse.State 		:= FOLDIO_STATE_START_1;
						g_CrossFoldBProcess.Common.State 				:= MACHPROC_WAIT_FOLD_POINT_25;					
				END_CASE
			

				// Stack change needed ?
				g_CrossFoldBProcess.StackChangeControl.SelectedStacker 	:= 0;
				g_CrossFoldBProcess.StackChangeControl.DoStackChange 	:= 0; // No stack change default

				// Find out what stacker will be used 
				IF (g_MCfg.Outlet.StackSelectMode = STACK_CHANGE_ARTICLE_DYNAMIC_4) THEN // Dynamic stack change on article 
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_CrossFoldBProcess.Common.LogBookFlag, i, 'XB, Start dyn select');	
					g_CrossFoldBProcess.StackChangeControl.SelectedStacker 	:= 0;
					g_CrossFoldBProcess.StackChangeControl.EmptyStacker 	:= 0;
					g_CrossFoldBProcess.StackChangeControl.BestAgeStack 	:= 0;
					g_CrossFoldBProcess.StackChangeControl.BestAgeCount 	:= 32000;
					FOR i := 1 TO g_HCfg.NumberOfStackers DO
						IF g_CrossFoldBProcess.Common.Product.Article = g_CrossFoldBProcess.StackChangeControl.ArticleOnStack[i] THEN 
							g_CrossFoldBProcess.StackChangeControl.SelectedStacker := i;
						ELSIF g_CrossFoldBProcess.StackChangeControl.ArticleOnStack[i] = 0 THEN
							g_CrossFoldBProcess.StackChangeControl.EmptyStacker := i;
						ELSIF g_CrossFoldBProcess.StackChangeControl.AgeCountOnStack[i] <  g_CrossFoldBProcess.StackChangeControl.BestAgeCount THEN
							g_CrossFoldBProcess.StackChangeControl.BestAgeCount  := g_CrossFoldBProcess.StackChangeControl.AgeCountOnStack[i];
							g_CrossFoldBProcess.StackChangeControl.BestAgeStack  := i;
							g_CrossFoldBProcess.StackChangeControl.DoStackChange := i;// Stack change on only one stack
						END_IF	
					END_FOR
					IF g_CrossFoldBProcess.StackChangeControl.SelectedStacker = 0 THEN
						IF g_CrossFoldBProcess.StackChangeControl.EmptyStacker > 0 THEN				
							g_CrossFoldBProcess.StackChangeControl.SelectedStacker := g_CrossFoldBProcess.StackChangeControl.EmptyStacker;
						ELSIF g_CrossFoldBProcess.StackChangeControl.BestAgeStack > 0 THEN				
							g_CrossFoldBProcess.StackChangeControl.SelectedStacker := g_CrossFoldBProcess.StackChangeControl.BestAgeStack;
						ELSE 	
							g_CrossFoldBProcess.StackChangeControl.SelectedStacker := 1;
						END_IF	
					END_IF		
					g_CrossFoldBProcess.StackChangeControl.AgeCount 																:= g_CrossFoldBProcess.StackChangeControl.AgeCount + 1; 
					g_CrossFoldBProcess.StackChangeControl.AgeCountOnStack[g_CrossFoldBProcess.StackChangeControl.SelectedStacker] 	:= g_CrossFoldBProcess.StackChangeControl.AgeCount;
					g_CrossFoldBProcess.StackChangeControl.ArticleOnStack[g_CrossFoldBProcess.StackChangeControl.SelectedStacker] 	:= g_CrossFoldBProcess.Common.Product.Article; 
				ELSIF g_CrossFoldBProcess.Common.Product.Stack > 0 THEN // Stack selected already at inlet. ie. Metricon
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_CrossFoldBProcess.Common.LogBookFlag, i, 'XB, Metricon select stack');	
					g_CrossFoldBProcess.StackChangeControl.SelectedStacker 	:= g_CrossFoldBProcess.Common.Product.Stack;
				ELSE	// Selected by Recipe
					// Get Stacker parameters to be used for this garment
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_CrossFoldBProcess.Common.LogBookFlag, i, 'XB, Recipe select stack');	
					IF g_Core.Services.Recipe.Runtime.recipePointer > 0 THEN			(* Check that pointer is bigger then Null *)
						LocalFoldProgram ACCESS(g_Core.Services.Recipe.Runtime.recipePointer + (SIZEOF(LocalFoldProgram) * LIMIT(0, (g_CrossFoldBProcess.Common.Product.FoldProgram - 1), MAX_NUMBER_OF_CATEGORIES)));
					ELSE
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_CrossFoldBProcess.Common.LogBookFlag, i, 'XB, Stacker access return');	
						RETURN;		(* Can not access LocalFoldProgram before pointer is ok. *)
					END_IF
					//StackerParameters							:= LocalFoldProgram.StackerBelt1;
					StackerParameters							:= LocalFoldProgram.Stacker;
					CASE StackerParameters.SelectSection OF
						STACKER_SECTION_FIX_4: 
							g_CrossFoldBProcess.StackChangeControl.SelectedStacker := StackerParameters.StackerSelection;
						ELSE
							g_CrossFoldBProcess.StackChangeControl.SelectedStacker := StackerParameters.StackerSelection;
					END_CASE		
				END_IF
			
				// Security to always have a valid stack 
				IF (g_CrossFoldBProcess.StackChangeControl.SelectedStacker = 0) OR (g_CrossFoldBProcess.StackChangeControl.SelectedStacker > g_HCfg.NumberOfStackers) THEN
					g_CrossFoldBProcess.StackChangeControl.SelectedStacker 	:= 1; 		
				END_IF	
				// Store stack selected on product
				g_CrossFoldBProcess.Common.Product.Stack					:= g_CrossFoldBProcess.StackChangeControl.SelectedStacker;
			
				// Control if stack change is needed
				IF (g_MCfg.Outlet.StackChangeMode = OUTLET_STACK_CHANGE_NONE_0) THEN //AND (g_CrossFoldBProcess.Common.Product.PreStackChange = 0)) THEN
					;
				ELSIF (g_MCfg.Outlet.StackChangeMode = OUTLET_STACK_CHANGE_CUSTART_2) AND 
					(g_OutletProcess.StackerUnit[g_CrossFoldBProcess.StackChangeControl.SelectedStacker].StackData[0].CustomerId > 0) AND
					(g_CrossFoldBProcess.Common.Product.Customer <> g_CrossFoldBProcess.StackChangeControl.CustomerId) THEN
					g_CrossFoldBProcess.StackChangeControl.DoStackChange := 99;// Stack change on all stacks
				ELSIF (g_MCfg.Outlet.StackChangeMode = OUTLET_STACK_CHANGE_CUSTART_2) AND
					(g_OutletProcess.StackerUnit[g_CrossFoldBProcess.StackChangeControl.SelectedStacker].StackData[0].ArticleId > 0) AND
					(g_CrossFoldBProcess.Common.Product.Article <> g_CrossFoldBProcess.StackChangeControl.ArticleId) THEN
					g_CrossFoldBProcess.StackChangeControl.DoStackChange := 99;// Stack change on all stacks
				ELSIF (g_MCfg.Outlet.StackChangeMode = OUTLET_STACK_CHANGE_FOLDPROG_1) AND
					(g_OutletProcess.StackerUnit[g_CrossFoldBProcess.StackChangeControl.SelectedStacker].StackData[0].FoldProgram > 0) AND (g_CrossFoldBProcess.Common.Product.Stack = g_CrossFoldBProcess.StackChangeControl.OldSelectedStack )AND
					(g_CrossFoldBProcess.Common.Product.FoldProgram <> g_CrossFoldBProcess.StackChangeControl.FoldProgram) THEN
					g_CrossFoldBProcess.StackChangeControl.DoStackChange := g_CrossFoldBProcess.StackChangeControl.SelectedStacker;	// Only stack change the specific stacker 10-03-24..
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_CrossFoldBProcess.Common.LogBookFlag, g_CrossFoldBProcess.Common.CurTimer, 'XB, StackChange programm');		
					// Stack change from Metricon				
				ELSIF (g_MCfg.Outlet.StackChangeMode = OUTLET_STACK_CHANGE_METRICON_3)  THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_CrossFoldBProcess.Common.LogBookFlag, g_CrossFoldBProcess.Common.CurTimer, 'XB, Check index value');
					IF g_CrossFoldBProcess.Common.Product.StackChangeIndex <> g_CrossFoldBProcess.StackChangeControl.OldStackChangeIndex THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_CrossFoldBProcess.Common.LogBookFlag, g_CrossFoldBProcess.Common.Product.StackChangeIndex, 'XB, Index was different');	
						g_CrossFoldBProcess.StackChangeControl.DoStackChange := 99;// Stack change on all stacks
					END_IF
					//////////////////////////////////
				ELSIF (g_MCfg.Outlet.StackChangeMode = OUTLET_STACK_CHANGE_RESET_4) OR g_CrossFoldBProcess.Common.Product.PreStackChange AND NOT (g_MCfg.Outlet.StackChangeMode = OUTLET_STACK_CHANGE_LENGTH_6) THEN //MP - Manual StackChange or Special Case (Metric and Reset)
					IF (g_CrossFoldBProcess.Common.Product.StackChangeIndex <> g_CrossFoldBProcess.StackChangeControl.OldStackChangeIndex) AND (NOT g_HangerInletProcess.CustomerStackChange) THEN
						g_CrossFoldBProcess.StackChangeControl.DoStackChange := g_CrossFoldBProcess.StackChangeControl.SelectedStacker;	// Only stack change the specific stacker 10-03-24..
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_CrossFoldBProcess.Common.LogBookFlag, g_CrossFoldBProcess.Common.CurTimer, 'XB, StackChange programm');
					END_IF
				ELSIF g_MCfg.Outlet.StackChangeMode = OUTLET_STACK_CHANGE_MET_FPROG_5 THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_CrossFoldBProcess.Common.LogBookFlag, g_CrossFoldBProcess.Common.CurTimer, 'XB, Check index value');		
					IF g_CrossFoldBProcess.Common.Product.StackChangeIndex <> g_CrossFoldBProcess.StackChangeControl.OldStackChangeIndex THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_CrossFoldBProcess.Common.LogBookFlag, g_CrossFoldBProcess.Common.Product.StackChangeIndex, 'XB, Index was different');	
						g_CrossFoldBProcess.StackChangeControl.DoStackChange := 99;// Stack change on all stacks
					END_IF	
				ELSIF g_MCfg.Outlet.StackChangeMode = OUTLET_STACK_CHANGE_LENGTH_6 THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_CrossFoldBProcess.Common.LogBookFlag, g_CrossFoldBProcess.Common.CurTimer, 'XB, Check index value');
					IF g_CrossFoldBProcess.Common.Product.StackChangeIndex <> g_CrossFoldBProcess.StackChangeControl.OldStackChangeIndex AND (g_CrossFoldBProcess.Common.Product.PreStackChange = FALSE) THEN
						IF (g_CrossFoldBProcess.Common.Product.AutoProgram <> g_CrossFoldBProcess.StackChangeControl.AutoProgram) OR NOT g_MCfg.Outlet.StackChangeOnlyPrgChange THEN
							g_CrossFoldBProcess.StackChangeControl.DoStackChange := g_CrossFoldBProcess.StackChangeControl.SelectedStacker;	// Only stack change the specific stacker 10-03-24..
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_CrossFoldBProcess.Common.LogBookFlag, g_CrossFoldBProcess.Common.CurTimer, 'XB, StackChange programm');
						END_IF
					ELSIF g_CrossFoldBProcess.Common.Product.StackChangeIndex <> g_CrossFoldBProcess.StackChangeControl.OldStackChangeIndex AND (g_CrossFoldBProcess.Common.Product.PreStackChange = TRUE) THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_CrossFoldBProcess.Common.LogBookFlag, g_CrossFoldBProcess.Common.Product.StackChangeIndex, 'XB, Index was different');	
						g_CrossFoldBProcess.StackChangeControl.DoStackChange := 99;// Stack change on all stacks
					END_IF
					//			ELSIF ((g_MCfg.Outlet.StackChangeMode = OUTLET_STACK_CHANGE_MANUAL_6) AND (g_CrossFoldBProcess.Common.Product.StackChangeIndex <> g_CrossFoldBProcess.StackChangeControl.OldStackChangeIndex)) THEN 
					//				g_CrossFoldBProcess.StackChangeControl.DoStackChange := 99;
					// PWC: If Customer Change was pressed in Duo Inlet, make stack change
					//			ELSIF (g_MCfg.Outlet.StackChangeMode = OUTLET_STACK_CHANGE_MANUAL_6) AND (g_CrossFoldBProcess.Common.Product.DuoStackChangeIndex <> g_CrossFoldBProcess.StackChangeControl.DuoOldStackChangeIndex) AND (g_CrossFoldBProcess.Common.Product.DuoStackChangeIndex > 0) THEN
					//				g_CrossFoldBProcess.StackChangeControl.DoStackChange := 99;// Stack change on all stacks
				END_IF

				// Execute any prestarted stack change 
				IF (g_CrossFoldBProcess.StackChangeControl.DoStackChange > 0) THEN
					// Clear last rounds settings
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_CrossFoldBProcess.Common.LogBookFlag, g_CrossFoldBProcess.Common.CurTimer, 'XB, Make Stack change');	
					FOR i := 1 TO g_HCfg.NumberOfStackers DO
						g_CrossFoldBProcess.StackChangeControl.StackerHasItemsOnItsWay[i] := 0;
					END_FOR
					// Search for items on its way but not yet delivered to a stack
					FOR i := 1 TO NUMBER_OF_STACKERGROUPS DO
						IF g_StackerProcess[i].Common.Product.Length > 0 THEN	// Check that stacker groups has valid data in the product.
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_CrossFoldBProcess.Common.LogBookFlag, i, 'XB, StGroup has an item');	
							IF g_CrossFoldBProcess.StackChangeControl.StackerHasItemsOnItsWay[g_StackerProcess[i].Common.Product.Stack] = 0 THEN // Last item to this stack
								IF  (g_CrossFoldBProcess.StackChangeControl.DoStackChange = 99) OR
									(g_CrossFoldBProcess.StackChangeControl.DoStackChange = g_StackerProcess[i].Common.Product.Stack) THEN
								
									LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_CrossFoldBProcess.Common.LogBookFlag, g_StackerProcess[i].Common.Product.Stack, 'XB, Item last sent to that stack');	
									g_StackerProcess[i].Common.Product.LastItemOnStack := 1;
									i := NUMBER_OF_STACKERGROUPS;
								END_IF	
								// always mark all stack that has items on its way even if it is not the last one. To avoid direct stacking
								g_CrossFoldBProcess.StackChangeControl.StackerHasItemsOnItsWay[g_StackerProcess[i].Common.Product.Stack] := 1;
							END_IF
						ELSE
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_CrossFoldBProcess.Common.LogBookFlag, i, 'XB, StGroup has no valid item');							
						END_IF	
					END_FOR	
					// Activate direct stack change on stack when no items is on its way to the stacker
					FOR i := 1 TO g_HCfg.NumberOfStackers DO
						IF g_CrossFoldBProcess.StackChangeControl.StackerHasItemsOnItsWay[i] = 0 THEN
							IF (g_CrossFoldBProcess.StackChangeControl.DoStackChange = 99) OR (g_CrossFoldBProcess.StackChangeControl.DoStackChange = i) THEN
								IF g_OutletProcess.StackerUnit[i].Counter > 0 THEN			// Is there any garments already on stack
									IF g_CrossFoldBProcess.StackChangeControl.DoStackChange = 99 THEN
										LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_CrossFoldBProcess.Common.LogBookFlag, i, 'XB,Pre-stack change all lift');	
										g_OutletProcess.StackerUnit[i].cmdIndex := 1;
									ELSE
										LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_CrossFoldBProcess.Common.LogBookFlag, g_CrossFoldBProcess.StackChangeControl.SelectedStacker, 'XB,Pre-stack change one lift');	
										g_OutletProcess.StackerUnit[g_CrossFoldBProcess.StackChangeControl.SelectedStacker].cmdIndex := 1;
										i := g_HCfg.NumberOfStackers;
									END_IF	
									LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_CrossFoldBProcess.Common.LogBookFlag, i, 'XB,Pre-stack change');	
								ELSE // If stack has none garments a stack change is not needed....
									LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_CrossFoldBProcess.Common.LogBookFlag, i, 'XB,Pre-stack, but null stack');	
								END_IF
							END_IF	
						ELSE
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_CrossFoldBProcess.Common.LogBookFlag, i, 'Metric NO stack change');	
						END_IF											
					END_FOR
				END_IF
				// Remember what was last sent to stackers
				g_CrossFoldBProcess.StackChangeControl.CustomerId 			:= g_CrossFoldBProcess.Common.Product.Customer;
				g_CrossFoldBProcess.StackChangeControl.ArticleId 			:= g_CrossFoldBProcess.Common.Product.Article;
				g_CrossFoldBProcess.StackChangeControl.AutoProgram			:= g_CrossFoldBProcess.Common.Product.AutoProgram;
				g_CrossFoldBProcess.StackChangeControl.FoldProgram 			:= g_CrossFoldBProcess.Common.Product.FoldProgram;
				g_CrossFoldBProcess.StackChangeControl.OldSelectedStack	:= g_CrossFoldBProcess.StackChangeControl.SelectedStacker;
				
				// PWC: Here we need to only copy StackChangeIndex number for the part (Fox inlet or Duo Inlet) that did the index
				IF g_CrossFoldBProcess.Common.Product.StackChangeIndex > 0 THEN 
					g_CrossFoldBProcess.StackChangeControl.OldStackChangeIndex 	:= g_CrossFoldBProcess.Common.Product.StackChangeIndex;
				END_IF
				IF 	g_CrossFoldBProcess.Common.Product.DuoStackChangeIndex > 0 THEN
					g_CrossFoldBProcess.StackChangeControl.DuoOldStackChangeIndex	:= g_CrossFoldBProcess.Common.Product.DuoStackChangeIndex; 
				END_IF
			END_IF

	
	

		MACHPROC_WAIT_FOLD_POINT_25:

			IF ElapsedMsTime(g_DummyPulses, g_CrossFoldBProcess.Common.FoldPointTimer) >= g_CrossFoldBProcess.Common.FoldPointTime THEN (* Cycle should be ended *)
				g_CrossFoldBProcess.Common.FoldUnit1.State		:= FOLDIO_STATE_START_1;
				g_CrossFoldBProcess.Common.FoldUnit2.State		:= FOLDIO_STATE_START_1;
				IF g_CrossFoldBProcess.FoldMode = FOLD_MODE_DIRECT_3 THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB, Foldpoint,direct');
					g_CrossFoldBProcess.Common.Motor.StopTimer 	:= g_CrossFoldBProcess.Common.CurTimer;
					g_CrossFoldBProcess.Common.Motor.cmdHold	:= TRUE;
					g_CrossFoldBProcess.SlopeDownTimer 			:= g_CrossFoldBProcess.Common.CurTimer;
					g_CrossFoldBProcess.Common.State 			:= MACHPROC_WAIT_EXIT_START_40;

				ELSIF g_CrossFoldBProcess.FoldMode = FOLD_MODE_REVERSE_4 THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB, Foldpoint,reverse');
					g_CrossFoldBProcess.Common.Motor.StopTimer 	:= g_CrossFoldBProcess.Common.CurTimer;
					g_CrossFoldBProcess.Common.Motor.cmdHold	:= TRUE;
					g_CrossFoldBProcess.Common.State 			:= MACHPROC_WAIT_REVERSE_FOLD_28;
				END_IF
			END_IF
		
		
			(* Check if photocell is activated during this time *)
			IF g_CrossFoldBProcess.Common.InSensor.Output THEN
				IF NOT g_CrossFoldBProcess.GarmentDetected THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB, Detected garment _25');
				END_IF	
				g_CrossFoldBProcess.GarmentDetected := TRUE;
			END_IF		
				
		
		MACHPROC_WAIT_REVERSE_FOLD_28:

			IF 	g_CrossFoldBProcess.Common.Motor.StopTime = 0 OR
				ElapsedMsTime(g_CrossFoldBProcess.Common.CurTimer, g_CrossFoldBProcess.Common.Motor.StopTimer) >= g_CrossFoldBProcess.Common.Motor.StopTime THEN (* Cycle should be ended *)
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB, start forward');
				g_CrossFoldBProcess.Common.Motor.cmdForward		:= TRUE;
				g_CrossFoldBProcess.ReverseTimer				:= g_DummyPulses;
				g_CrossFoldBProcess.Common.State 				:= MACHPROC_WAIT_REVERSE_POINT_30;
			END_IF

		MACHPROC_WAIT_REVERSE_START_29:

			IF 	g_CrossFoldBProcess.Common.Motor.StopTime = 0 OR
				ElapsedMsTime(g_CrossFoldBProcess.Common.CurTimer, g_CrossFoldBProcess.Common.Motor.StopTimer) >= g_CrossFoldBProcess.Common.Motor.StopTime THEN (* Cycle should be ended *)
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB , start reverse');
				g_CrossFoldBProcess.Common.Motor.cmdReverse		:= TRUE;
				g_CrossFoldBProcess.ReverseTimer				:= g_DummyPulses;
				g_CrossFoldBProcess.Common.State 				:= MACHPROC_WAIT_REVERSE_POINT_30;
			END_IF

		MACHPROC_WAIT_REVERSE_POINT_30:


			IF ElapsedMsTime(g_DummyPulses, g_CrossFoldBProcess.ReverseTimer) >= g_CrossFoldBProcess.ReverseTime THEN
				(* Faulty pieces should exit out here *)
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB, reverse point');
				IF g_CrossFoldBProcess.FoldMode = FOLD_MODE_BYPASS_REVERSE_OUT_5 THEN
					//				IF (g_CrossFoldBProcess.Common.Product.FoldProgram > 0) AND (g_CrossFoldBProcess.Common.Product.FoldProgram < 100)THEN
					//					g_Statistic[g_CrossFoldBProcess.Common.Product.FoldProgram].Pieces[0] 	:= g_Statistic[g_CrossFoldBProcess.Common.Product.FoldProgram].Pieces[0] + 1;
					//				END_IF
					//g_Statistic[0].Pieces[0] 							:= g_Statistic[0].Pieces[0] + 1;  
					g_CrossFoldBProcess.Common.ExitTimer 				:= g_DummyPulses;							(* start watchdog timer for process *)
					//				g_CrossFoldBProcess.Common.State 					:= MACHPROC_WAIT_BEFORE_EXIT_82;
					g_CrossFoldBProcess.Common.State 				:= 31;
				ELSE (* Correct pieces should now go forward end exit through stacker. *)
					g_CrossFoldBProcess.Common.Motor.cmdHold		:= TRUE;
					g_CrossFoldBProcess.SlopeLift					:= FALSE;
					g_CrossFoldBProcess.ReverseBlow.State 			:= FOLDIO_STATE_START_1;		
					g_CrossFoldBProcess.Common.Motor.StopTimer 		:= g_CrossFoldBProcess.Common.CurTimer;
					g_CrossFoldBProcess.Common.State 				:= MACHPROC_WAIT_EXIT_START_40;
				END_IF
			END_IF
		
		31:
			(* to insure that motor won't stop before we completly sortOut the garment/Towel out of the belt to the floor*)
			g_CrossFoldBProcess.Common.WatchDogRunTimer 		:= g_CrossFoldBProcess.Common.CurTimer;
			IF (g_DummyPulses > g_CrossFoldBProcess.Common.ExitTimer + 200) THEN
				//		g_CrossFoldBProcess.Common.ExitTimer 				:= g_DummyPulses;							(* start watchdog timer for process *)
				hasLogged := 0;
				g_CrossFoldBProcess.Common.State 					:= MACHPROC_WAIT_BEFORE_EXIT_82;	
			END_IF;
	

		

		MACHPROC_WAIT_EXIT_START_40:

			IF 	g_CrossFoldBProcess.Common.Motor.StopTime = 0 OR
				ElapsedMsTime(g_CrossFoldBProcess.Common.CurTimer, g_CrossFoldBProcess.Common.Motor.StopTimer) >= g_CrossFoldBProcess.Common.Motor.StopTime THEN (* Cycle should be ended *)
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB, exit start');
				g_CrossFoldBProcess.Common.Motor.cmdReverse		:=	TRUE;
				g_CrossFoldBProcess.Common.HoldingPointTimer	:= g_DummyPulses;
				StopXADelay.Delay								:= g_CrossFoldBProcess.Parameters.StopXADelay;
				StopXADelay.Set									:= g_CrossFoldBProcess.Parameters.StopXAEnable;
				g_CrossFoldBProcess.Common.State 				:= MACHPROC_DELIVER_PACKAGE_80;
				g_CrossFoldBProcess.SlopeDownTimer 				:= g_CrossFoldBProcess.Common.CurTimer;
				g_CrossFoldBProcess.Common.ExitTimer 			:= g_DummyPulses;							(* start watchdog timer for process *)
			END_IF

		MACHPROC_DELIVER_PACKAGE_80:

			g_CrossFoldBProcess.Common.WatchDogRunTimer			:= g_CrossFoldBProcess.Common.CurTimer;
		

			(* Wait for next task to prepare to take over product. *)
			IF g_CrossFoldBProcess.Common.Next.TransferStatus = EXC_STANDBY_0 THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB, deliver package');
				IF NOT DisableCrossBLog THEN
					IF g_EnableRecipeLogData THEN
						LogData_0(Type := 1, Lane := 1, Info1 := g_CrossFoldBProcess.Common.Product.FoldProgram, Info2 := ADR(g_CrossFoldBProcess.Common.Product.RecipeName));
					ELSE
						LogData_0(Type := 1, Lane := 1);
					END_IF
				END_IF
				
				g_CrossFoldBProcess.Common.Next.Product 		:= g_CrossFoldBProcess.Common.Product;
				g_CrossFoldBProcess.Common.Next.TransferStatus 	:= EXC_WANT_TO_UNLOAD_1;	
				g_CrossFoldBProcess.Common.State 				:= MACHPROC_PACKAGE_DELIVERED_81;	
			END_IF
		
			(* Hold motor stack is not ready... *)
			IF g_CrossFoldBProcess.Common.Motor.Run AND ElapsedMsTime(g_DummyPulses, g_CrossFoldBProcess.Common.HoldingPointTimer) >= g_CrossFoldBProcess.Common.HoldingPointTime THEN (* Cycle should be ended *)
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB, hold Stack not ready');
				g_CrossFoldBProcess.Common.Motor.cmdHold		:=	TRUE;
			END_IF
		
	

		MACHPROC_PACKAGE_DELIVERED_81:

			(* Wait for my clamp to open *)
			IF g_CrossFoldBProcess.Common.Next.TransferStatus = EXC_STANDBY_0 THEN
				g_CrossFoldBProcess.Common.Next.TransferStatus 	:= EXC_WANT_TO_UNLOAD_1;
			ELSIF g_CrossFoldBProcess.Common.Next.TransferStatus = EXC_READY_TO_RECIEVE_2 THEN
				g_CrossFoldBProcess.Common.Next.TransferStatus 	:= EXC_UNLOADING_3;
			ELSIF g_CrossFoldBProcess.Common.Next.TransferStatus = EXC_RECIVING_4 THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB, package delivered');
				g_CrossFoldBProcess.Common.Next.TransferStatus 		:= EXC_FINISHED_UNLOADING_5;
				hasLogged := FALSE;
				g_CrossFoldBProcess.Common.State 					:= MACHPROC_WAIT_BEFORE_EXIT_82;
				g_CrossFoldBProcess.Common.WatchDogRunTimer 		:= g_CrossFoldBProcess.Common.CurTimer;							(* start watchdog timer for process *)
				g_CrossFoldBProcess.Common.Motor.cmdReverse			:= TRUE;
			END_IF

			IF ElapsedMsTime(g_DummyPulses, g_CrossFoldBProcess.Common.HoldingPointTimer) >= g_CrossFoldBProcess.Common.HoldingPointTime THEN (* Cycle should be ended *)
				g_CrossFoldBProcess.Common.Motor.cmdHold		:=	TRUE;
			END_IF
			g_CrossFoldBProcess.Common.WatchDogRunTimer 		:= g_CrossFoldBProcess.Common.CurTimer;							(* start watchdog timer for process *)

		MACHPROC_WAIT_BEFORE_EXIT_82:

			// Stacker has to have stacked the previous before we let XA in again
			IF g_CrossFoldBProcess.Common.Next.TransferStatus = EXC_STANDBY_0 THEN
				g_CrossFoldBProcess.Common.Previous.TransferStatus 	:= EXC_STANDBY_0;
				g_CrossFoldBProcess.Common.Motor.State 				:= MOTOR_STATE_IDLE_1;
				g_CrossFoldBProcess.Common.State 					:= MACHPROC_RUN_20;
				g_CrossFoldBProcess.Common.WatchDogRunTimer 		:= g_CrossFoldBProcess.Common.CurTimer;
				//			IF (g_CrossFoldBProcess.Common.Product.FoldProgram > 0) AND (g_CrossFoldBProcess.Common.Product.FoldProgram < 100)THEN
				//				g_Statistic[g_CrossFoldBProcess.Common.Product.FoldProgram].Pieces[0] 			:= g_Statistic[g_CrossFoldBProcess.Common.Product.FoldProgram].Pieces[0] + 1;
				//				g_Statistic[g_CrossFoldBProcess.Common.Product.FoldProgram].AutoProgPieces[0]	:= g_Statistic[g_CrossFoldBProcess.Common.Product.FoldProgram].AutoProgPieces[0] + 1;
				//				FOR i:= 1 TO g_HCfg.NumberOfStackers DO
				//					IF g_CrossFoldBProcess.Common.Product.Stack = i THEN			
				//						g_Statistic[g_CrossFoldBProcess.Common.Product.FoldProgram].AutoProgPieces[i] 	:= g_Statistic[g_CrossFoldBProcess.Common.Product.FoldProgram].AutoProgPieces[i] + 1;
				//					END_IF
				//				END_FOR g
				//			END_IF
			END_IF
			g_CrossFoldBProcess.Common.WatchDogRunTimer			:= g_CrossFoldBProcess.Common.CurTimer;

			(* Check if photocell is activated during this time *)
			// It might be so that this can not be here if garment runs shortest way this might happen and is correct... POX
			// Is it corrected now???
			IF g_CrossFoldBProcess.FoldMode <> FOLD_MODE_BYPASS_DIRECT_1 THEN 
				IF g_CrossFoldBProcess.Common.InSensor.Output AND NOT hasLogged THEN
					hasLogged := TRUE;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB, Photocell active at end _82');
				END_IF	
			END_IF

		
	
		MACHPROC_ERROR_99:
	
			g_CrossFoldBProcess.Common.Previous.TransferStatus 	:= EXC_ERROR_99;
			g_CrossFoldBProcess.SlopeLift						:= FALSE;
		
		
	END_CASE


	IF g_CrossFoldBProcess.SlopeLift AND ((g_CrossFoldBProcess.Common.State = MACHPROC_INIT_0) OR (g_CrossFoldBProcess.Common.State > MACHPROC_TRIG_ERROR_98)) THEN
		g_CrossFoldBProcess.SlopeLift 		:= FALSE;
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB, slope down error');
	END_IF

	IF g_CrossFoldBProcess.SlopeLift AND (g_CrossFoldBProcess.SlopeDownTimer > 0) AND (ElapsedMsTime(g_CrossFoldBProcess.Common.CurTimer, g_CrossFoldBProcess.SlopeDownTimer) >= g_CrossFoldBProcess.SlopeDownTime) THEN
		g_CrossFoldBProcess.SlopeDownTimer 		:= 0;
		g_CrossFoldBProcess.SlopeLift 			:= FALSE;
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB slope down time');
	END_IF



	(* Detect if error occurs and what to do *)
	IF 	g_CrossFoldBProcess.Common.State >= MACHPROC_RUN_20 AND
		g_CrossFoldBProcess.Common.State < MACHPROC_TRIG_ERROR_98 THEN
		IF ElapsedMsTime(g_CrossFoldBProcess.Common.CurTimer, g_CrossFoldBProcess.Common.WatchDogRunTimer) > (g_CrossFoldBProcess.Common.WatchDogRunTime-100) THEN
			IF g_CrossFoldBProcess.Common.State >= MACHPROC_DELIVER_PACKAGE_80 THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_CrossFoldBProcess.Common.LogBookFlag, g_DummyPulses, 'XB timeout 1');
				g_CrossFoldBProcess.Common.State := MACHPROC_RUN_20;
			ELSE
				; (* Do nothing, this is a true timeout *)
			END_IF
		END_IF
	END_IF

	(* Copy back counters *)
	g_CrossFoldBProcess.Common.InSensor.OldEdgeCounter 	:= g_CrossFoldBProcess.Common.InSensor.EdgeCounter;
	g_CrossFoldBProcess.Common.InSensor.OldTrailCounter := g_CrossFoldBProcess.Common.InSensor.TrailCounter;
	g_CrossFoldBProcess.Common.InSensor.OldCounter 		:= g_CrossFoldBProcess.Common.InSensor.Counter;


	StopXADelay(CntAdr := ADR(g_MilliSeconds));
	IF StopXADelay.Trig THEN
		g_CrossFoldAProcess.Common.Motor.cmdHold := TRUE;
	END_IF


	(* Control output *)
	ActivateFoldIO(g_CrossFoldBProcess.LeadBlowForward, g_CrossFoldBProcess.Common.CurTimer);
	ActivateFoldIO(g_CrossFoldBProcess.LeadBlowReverse, g_CrossFoldBProcess.Common.CurTimer);
	ActivateFoldIO(g_CrossFoldBProcess.ReverseBlow, g_CrossFoldBProcess.Common.CurTimer);



	QYAirXBFoldInlet		:= 	g_CrossFoldBProcess.Common.FoldUnit1.Output OR
	g_CrossFoldBProcess.ReverseBlow.Output		OR
	g_CrossFoldBProcess.LeadBlowReverse.Output;

	QYAirXBFoldOutlet		:= 	g_CrossFoldBProcess.Common.FoldUnit2.Output OR
	g_CrossFoldBProcess.LeadBlowForward.Output;

	QYXBFoldDoffer	:= (g_CrossFoldBProcess.SlopeLift OR g_LateralProcess.SetSlope) AND (g_CrossFoldBProcess.Common.State <> MACHPROC_ERROR_99);

	// Xtreme Heavy - PMU 01.03.16
	QYRaiseTiltingConveyor := g_CrossFoldBProcess.RaiseTiltConv OR g_XtremeHeavy.RaiseTiltingConv;

	StopMotor();
	g_XBStopMotor := StopMotor.Out;

	IF g_CrossFoldBProcess.Common.Motor.Run THEN
		IF g_CrossFoldBProcess.Common.Motor.Direction = MOTOR_DIRECTION_FORWARD THEN
			QMXBFoldForward		:= TRUE;
			QMXBFoldReverse		:= FALSE;
		ELSE
			QMXBFoldForward		:= FALSE;
			QMXBFoldReverse		:= TRUE;
		END_IF
	ELSE
		QMXBFoldForward			:= FALSE;
		QMXBFoldReverse			:= FALSE;
	END_IF
END_PROGRAM

