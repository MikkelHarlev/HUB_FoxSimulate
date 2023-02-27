PROGRAM _CYCLIC

(* cyclic program *)

(*-------------------------------------------------------------------------------------

Author:   				Sten Flystedt

FileName:				Lateral.scr

Desription:				Lateral

Reference:

Interfaces:				No interfaces.

Watch debugg:			Name OF important watch configurations.

History:
10-10-26				V1.14.4		PO Nilsson		Bug fix FOR bladback sensor..
10-10-06				V1.14.3		PO Nilsson		Corrected yesterdays bug fix..
10-10-05				V1.14.2		PO Nilsson		Added a time out IF balde is NOT back in time...
10-07-08				V1.14.1		PO Nilsson		Removed part that where made in the last version sins it was NOT needed.. 	
10-07-07				V1.14.0		PO Nilsson		Increased the Watchdog timer from 3000 TO 4000 made a timer that set XA motor TO forward after 2,5 seconds FOR long garments.. 	
10-05-10				V1.13.9		PO Nilsson		Increasde the EXIT time FOR Third folds, sins we got report OF roller folds at Holbaek 40-6001...
10-03-10				V1.13.8		PO Nilsson		Found the real bug FOR LiftBladesTimer was comparing against g_DummyPulse AND NOT curtimer.
													Changed name on output FOR TemplatesLift AND Blade up.	 
													Changed so IF no Stacker selection is made from Metricon we would get it from the recipe selected..
10-03-09				V1.13.7		PO Nilsson		Trigger the LiftBladesTimer at EXIT part OF lateral aswell, might have been a bug..
10-02-04				V1.13.6		PO Nilsson		Removed alarm code that wa NOT used, only set FALSE..
10-01-25				V1.13.5		PO Nilsson 		Changed Fix folds from 6,7 TO 8,9...
10-01-20				V1.13.4		PO Nilsson		Made comments TO folds that should NOT be used...
10-01-12				V1.13.3		PO Nilsson		Offset on rigth lateral fold blade...
													"Data" member was removed from g_AutoProgramData structure
10-01-11				V1.13.2		PO Nilsson		Bug fix from Holbaek, direction switch on XA motor failed at sertain lenghts OF garments..
09-12-10				V1.13.1		PO Nilsson		Secured code around AutoProgram search. 
09-12-03				V1.13.0		PO Nilsson		Fix dimension folding FOR fold combination 14 AND 15...
09-12-02				V1.12.9		PO Nilsson		Changed so we need booth Exittime AND LeftBladeBack sensor before we exit..
09-11-16				V1.12.8		PO Nilsson		Delay FOR lifting the template, so we can time it better...
09-11-04				V1.12.7		PO Nilsson		Delay FOR knife moved around in end OF lateral so we can have delay in XA.
09-11-02				V1.12.6		PO Nilsson		Logic FOR knife fold in XA, security TO check that LEFT balde is back..	
09-10-27				V1.12.5		PO Nilsson		Removed machine manager index from init part OF lateral.
09-10-21				V1.12.4		PO Nilsson		Fixed values FOR gap did NOT work with new counter wheel..
09-10-15				V1.12.3		PO Nilsson		Start on MultiStacker	
09-10-01				V1.12.2 	PO Nilsson		Bug fixes on site Holbaek
09-09-09				V1.12.1		PO Nilsson		Removed the old code FOR lateral blades FUNCTION, that was from Maximat manual. 
09-09-08				V1.12.0		PO Nilsson		Removed [0..1] records in AutoProgram type
09-09-08				V1.11.1		PO Nilsson		Removed "RightBladeKeepOut" AND made g_LateralProcess.KeepLeftBladeOut.
09-09-01				V1.11    	PO Nilsson		Removed one OF the gap cylinders...
09-03-10				V1.10    	PO Nilsson		Adapted TO Fox..
08-07-01				V1.01    	Sten Flystedt	First edition...
---------------------------------------------------------------------------------------*)


//########################################################## 
// Info:
// Lower the templates, Are raised at neutral valve..
//
//########################################################## 


	IF EDGEPOS(g_StartXAConveyor) THEN 
		g_CrossFoldAProcess.Common.Motor.cmdForward			:= TRUE;			(* Cross A motor forward.. *)
	END_IF

	(*#####################*)
	(* Get current time... *)
	(*#####################*)
	g_LateralProcess.Common.CurTimer 					:= g_Timers._1_ms;
	IF g_LateralProcess.Common.LogBookFlag > 0 THEN
		strcpy(ADR(TmpStr),ADR(g_LateralProcess.Common.Description));
	END_IF

	IF (g_Core.Services.Recipe.Runtime.recipePointer = 0) OR (g_Core.Services.AutoProg.Runtime.autoprogPointer = 0) THEN		(* Check that pointer is bigger then Null *)
		RETURN;								(* Do not run task before pointer is assigned... *)
	END_IF

	ACfgTopConveyorProgram := LIMIT(0, g_TopConveyorProcess.Common.Product.FoldProgram - 1, 98);

	(*#################################*)
	(* copy status of exchange objects *)
	(*#################################*)
	IF g_DuoInletProcess.requestDelivery THEN //CWH_DUO
		g_LateralProcess.Common.Previous	:= g_DuoInletProcess.Common.Next;
		DuoRequest							:= TRUE;
	ELSE
		g_LateralProcess.Common.Previous	:= g_TopConveyorProcess.Common.Next;
		//	DuoRequest							:= FALSE;
	END_IF;
	g_LateralProcess.Common.Next			:= g_CrossFoldAProcess.Common.Previous;

	(*########################################*)
	(* Connect inputs to the module structure *)
	(*########################################*)

	g_LateralProcess.KnifeIsHome.Input					:= IIKnifeHome;				(* Knife is at up / Home only if knife option *)
	g_LateralProcess.LeftBladeIsBack					:= IIBladeRightHome OR g_sim.IIBladeRightHome;


	(*######################*)
	(* Connect timer values *)
	(*######################*)
	g_LateralProcess.Common.WatchDogStartupTime			:= 2000;
	g_LateralProcess.Common.WatchDogRunTime				:= 4000;		// Increased from 3000 to 4000 2010-07-07 POX..  

	g_LateralProcess.KnifeIsHome.OnDelay				:= g_MCfg.SensorFilterTime;
	g_LateralProcess.KnifeIsHome.OffDelay				:= g_MCfg.SensorFilterTime;

	g_LateralProcess.LiftBladesTime						:= g_MCfg.LFold.LiftBladesTime;
	g_LateralProcess.Common.Motor.RunTime				:= 5000;		// Was set to zero before why???

	//BladeBackTime := 1800;
	IF g_LateralProcess.LeftBladeIsBack OR QYLFoldBladeRight OR NOT g_Core.System.Runtime.isRunning THEN
		BladeBackTimer := g_LateralProcess.Common.CurTimer;
	END_IF
	IF ElapsedMsTime(g_LateralProcess.Common.CurTimer, BladeBackTimer) >= BladeBackTime THEN
		g_LateralProcess.Common.ErrorCode := 4;
		g_LateralProcess.Common.State := MACHPROC_TRIG_ERROR_98;	
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Lat, Blade back sensor not active alarm');
	END_IF
	


	(*#################*)
	(* Read parameters *)
	(*#################*)

	IF g_LateralProcess.Common.State <> state_history[i] THEN	//CWH_DUO
		i := i +1;
		IF i = 49 THEN
			i := 0;
		END_IF;
		state_history[i] := UINT_TO_USINT(g_LateralProcess.Common.State);
	END_IF;

	IF g_LateralProcess.Common.ReadParameters THEN
		g_LateralProcess.Common.ReadParameters 			:= FALSE;
		IF g_Core.Services.Recipe.Runtime.recipePointer > 0 THEN			(* Check that pointer is bigger then Null *)
			LocalFoldProgram ACCESS(g_Core.Services.Recipe.Runtime.recipePointer + (SIZEOF(LocalFoldProgram) * LIMIT(0, (g_LateralProcess.Common.Product.FoldProgram - 1), MAX_NUMBER_OF_CATEGORIES)));
		ELSE
			RETURN;		(* Can not access LocalFoldProgram before pointer is ok. *)
		END_IF
		
		IF g_MCfg.XFold.FixedDimSpeedFactor = 0 THEN
			g_MCfg.XFold.FixedDimSpeedFactor := 1;
		END_IF

		RShiftTemplateSize								:= TRUE;// PWC
		g_LateralProcess.Parameters						:= LocalFoldProgram.Lateral;
		g_LateralProcess.CrossParameters				:= LocalFoldProgram.CrossFold;
		g_LateralProcess.CrossAFoldDevice				:= LocalFoldProgram.CrossFoldA.FoldDevice;
	
	
		g_LateralProcess.Common.Motor.RunTime			:= g_MCfg.ConveyorRunTime;
		g_LateralProcess.WaitBladeBackTime				:= LocalFoldProgram.Lateral.BladeBackTime;
	
		SetSlopeDummy 	 								:= LocalFoldProgram.CrossFoldB.SlopeMode;		// To get this parameter already in Lateral section POX 09-09-30
	
		g_LateralProcess.Common.ExitTime				:= 20;	// Value used for Half and Four folds

		//EXIT_TIME_THIRDFOLDS							:= 160;	// To have more Exit time before next garment when third fold, otherwise roll fold in XA-B..	
		// 09-12-22
		//EXIT_TIME_THIRDFOLDS							:= 320;	// To have more Exit time before next garment when third fold, otherwise roll fold in XA-B..	
		// Increased after problems at Holbaek 40-6001 2010-05-01
		//EXIT_TIME_THIRDFOLDS						:= 250;	// To have more Exit time before next garment when third fold, otherwise roll fold in XA-B..		


		//###########################################
		// 2010-01-20 
		// Ben removed fold 0,1,4,5,8,9,12,13 
		// Leave them in the software for now but they are removed from the HMI. POX	
		//###########################################


		(* Calculate the stop point for the lateral fold based on Cross A fold type... *)
		RDistanceIBLA_FoldPoint := g_MCfg.LFold.DistanceIBLA_FoldPoint;
		RFoldPointAdjust := g_LateralProcess.Parameters.FoldDistance;
//		g_MCfg.LFold.FoldPosition := g_MCfg.LFold.DistanceIBLA_FoldPoint; 		// For now
		RFoldPosition := g_MCfg.LFold.FoldPosition;

		CASE g_LateralProcess.CrossParameters.FoldCombination OF

			FOLD_COMB_BYPASS_UP_0,			// Not used fold
			FOLD_COMB_BYPASS_DOWN_1,		// Not used fold
			FOLD_COMB_HALFFOLD_B_UP_4,		// Not used fold	
			FOLD_COMB_HALFFOLD_B_DOWN_5:	// Not used fold	
				g_LateralProcess.CrossAFoldMode							:= FOLD_MODE_BYPASS_1;
				g_LateralProcess.Common.ExitTime						:= (g_LateralProcess.Common.Product.Length*100)/WHEEL_INC_TO_DISTANCE_MM;
				g_LateralProcess.Common.Product.Size					:= g_LateralProcess.Common.Product.Length;
				g_LateralProcess.Common.FoldPointTime					:= ((g_LateralProcess.Common.Product.Length + RFoldPosition + RFoldPointAdjust)*100)/WHEEL_INC_TO_DISTANCE_MM;
				(* Always air on bypass *)
			

				FOLD_COMB_HALFFOLD_A_UP_2,
				FOLD_COMB_HALFFOLD_A_DOWN_3,
				FOLD_COMB_FOURFOLD_INSIDE_10,
			FOLD_COMB_FOURFOLD_OUTSIDE_11:
				g_LateralProcess.CrossAFoldMode							:= FOLD_MODE_DIRECT_3;
				g_LateralProcess.Common.Product.Size					:= g_LateralProcess.Common.Product.Length/2;		// New Size -> CrossB
				g_LateralProcess.Common.FoldPointTime					:= (((g_LateralProcess.Common.Product.Length/2) + RFoldPosition + RFoldPointAdjust)*100)/WHEEL_INC_TO_DISTANCE_MM;
				CASE g_LateralProcess.CrossParameters.FoldCombination OF
					FOLD_COMB_HALFFOLD_A_UP_2,
					FOLD_COMB_HALFFOLD_A_DOWN_3,
					FOLD_COMB_FOURFOLD_INSIDE_10:
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Lat, Short Exit');
						g_LateralProcess.Common.ExitTime						:= (((g_LateralProcess.Common.Product.Length + 1000/2))*100)/WHEEL_INC_TO_DISTANCE_MM;	
					FOLD_COMB_FOURFOLD_OUTSIDE_11:
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Lat, Long Exit');
						g_LateralProcess.Common.ExitTime						:= (((g_LateralProcess.Common.Product.Length + 1000)/2)*100)/WHEEL_INC_TO_DISTANCE_MM;
				END_CASE		

				// OK	
				FOLD_COMB_THIRDFOLD_F_DIRECT_6,		// Not used fold
			FOLD_COMB_THIRDFOLD_S_REVERSE_9:	
				g_LateralProcess.CrossAFoldMode	 						:= FOLD_MODE_DIRECT_3;
				g_LateralProcess.Common.Product.Size					:= g_LateralProcess.Common.Product.Length - (g_LateralProcess.Common.Product.Length/3);
				g_LateralProcess.Common.ExitTime						:= ((g_LateralProcess.Common.Product.Length - (g_LateralProcess.Common.Product.Length/3))*100)/WHEEL_INC_TO_DISTANCE_MM;
				g_LateralProcess.Common.FoldPointTime					:= (((g_LateralProcess.Common.Product.Length/3)*2 + RFoldPosition + RFoldPointAdjust)*100)/WHEEL_INC_TO_DISTANCE_MM;
				g_LateralProcess.Common.ExitTime						:= EXIT_TIME_THIRDFOLDS;	

				// OK
				FOLD_COMB_THIRDFOLD_F_REVERSE_7,	// Not used fold
			FOLD_COMB_THIRDFOLD_S_DIRECT_8:		
				g_LateralProcess.CrossAFoldMode	 						:= FOLD_MODE_DIRECT_3;
				g_LateralProcess.Common.Product.Size					:= g_LateralProcess.Common.Product.Length - (g_LateralProcess.Common.Product.Length/3);
				g_LateralProcess.Common.ExitTime						:= ((g_LateralProcess.Common.Product.Length - (g_LateralProcess.Common.Product.Length/3))*100)/WHEEL_INC_TO_DISTANCE_MM;
				g_LateralProcess.Common.FoldPointTime					:= (((g_LateralProcess.Common.Product.Length/3) + RFoldPosition + RFoldPointAdjust)*100)/WHEEL_INC_TO_DISTANCE_MM;
				g_LateralProcess.Common.ExitTime						:= EXIT_TIME_THIRDFOLDS;	

				FOLD_COMB_FIX_REAREDGE_INSIDE_12,	// Not used folds
			FOLD_COMB_FIX_REAREDGE_OUTSID_13:		
				IF g_LateralProcess.Common.Product.Length > (3*g_LateralProcess.CrossParameters.FixDimRearEdge) THEN
					g_LateralProcess.CrossAFoldMode							:= FOLD_MODE_DIRECT_3;
					g_LateralProcess.Common.Product.Size					:= g_LateralProcess.Common.Product.Length - (g_LateralProcess.Common.Product.Length/3);//g_LateralProcess.Common.Product.Length/2;		// New Size -> CrossB
					g_LateralProcess.Common.FoldPointTime					:= (((g_LateralProcess.Common.Product.Length/3)*2 +RFoldPosition + RFoldPointAdjust -FixFoldXAAdjust)*100)/WHEEL_INC_TO_DISTANCE_MM;

				ELSE
					g_LateralProcess.CrossAFoldMode 					:= FOLD_MODE_DIRECT_3;
					g_LateralProcess.Common.FoldPointTime					:= (((g_LateralProcess.Common.Product.Length/3)*2 + RFoldPosition + RFoldPointAdjust)*100)/WHEEL_INC_TO_DISTANCE_MM;
					g_LateralProcess.Common.Product.Size				:= g_LateralProcess.Common.Product.Length/2;
				END_IF
				g_LateralProcess.Common.ExitTime						:= EXIT_TIME_THIRDFOLDS;	
			
				FOLD_COMB_FIX_LEADEDGE_INSIDE_14,
			FOLD_COMB_FIX_LEADEDGE_OUTSID_15:		// Not used folds				
				IF g_LateralProcess.Common.Product.Length > (3*g_LateralProcess.CrossParameters.FixDimLeadEdge) THEN	//(2*g_LateralProcess.CrossParameters.FixDimLeadEdge) 
					g_LateralProcess.CrossAFoldMode							:= FOLD_MODE_DIRECT_3;
					g_LateralProcess.Common.Product.Size					:= g_LateralProcess.Common.Product.Length - (g_LateralProcess.Common.Product.Length/3);//g_LateralProcess.Common.Product.Length/2;		// New Size -> CrossB
					g_LateralProcess.Common.FoldPointTime					:= (((g_LateralProcess.Common.Product.Length/2) +RFoldPosition + RFoldPointAdjust -FixFoldXAAdjust)*100)/WHEEL_INC_TO_DISTANCE_MM;
				ELSE
					g_LateralProcess.Common.FoldPointTime				:=  (((g_LateralProcess.Common.Product.Length/3)+ RFoldPointAdjust)*100)/WHEEL_INC_TO_DISTANCE_MM;
					g_LateralProcess.CrossAFoldMode						:= FOLD_MODE_DIRECT_3;
					g_LateralProcess.Common.Product.Size				:= g_LateralProcess.Common.Product.Length/2;	
				END_IF
				g_LateralProcess.Common.ExitTime						:= EXIT_TIME_THIRDFOLDS;			

			FOLD_COMB_FIX_AB_16:			// Not used fold
				g_LateralProcess.CrossAFoldMode							:= FOLD_MODE_DIRECT_3;
				g_LateralProcess.Common.Product.Size					:= BiggestResult(g_LateralProcess.Common.Product.Length,g_LateralProcess.Parameters.FoldDistance);
				g_LateralProcess.Common.ExitTime						:= ((g_LateralProcess.Common.Product.Length-g_LateralProcess.Parameters.FoldDistance)*100)/WHEEL_INC_TO_DISTANCE_MM;
				g_LateralProcess.Common.FoldPointTime					:= ((RDistanceIBLA_FoldPoint - g_LateralProcess.Parameters.FoldDistance)*100)/WHEEL_INC_TO_DISTANCE_MM;

		END_CASE
			
		// Extra run time before fold is measured when using extended measurment
		FoldPointTimeNoExtra := g_LateralProcess.Common.FoldPointTime;
		//g_LateralProcess.Common.FoldPointTime := LIMIT(20, g_LateralProcess.Common.FoldPointTime - g_LateralProcess.Common.Product.TCExtraRunTime, g_LateralProcess.Common.FoldPointTime);
	
		// Set timer values for Lateral blades...

		g_LateralProcess.Common.FoldUnit2.StartDelayTime 	:= g_LateralProcess.Parameters.StartDelayRightBlade;
		g_LateralProcess.Common.FoldUnit1.StartDelayTime 	:= g_LateralProcess.Parameters.StartDelayLeftBlade;
		g_LateralProcess.Common.FoldUnit2.OnTime			:= g_LateralProcess.Parameters.OnTimeRightBlade;
		g_LateralProcess.Common.FoldUnit1.OnTime			:= g_LateralProcess.Parameters.OnTimeLeftBlade;

	END_IF


	(* Run IO Counter function *)
	RunIOCounter(g_LateralProcess.KnifeIsHome, g_LateralProcess.Common.CurTimer);

	RunFoldTask(g_MCfg.Trace2File, ADR(T2FD), g_LateralProcess.Common, g_MachineManager[g_LateralProcess.Common.MachineManagerIndex]);

	(* Additional case statement not covered by RunFoldTask() *)
	CASE g_LateralProcess.Common.State OF

		(*####################################*)
		(* Start Up Machine, Home Axels etc.. *)
		(*####################################*)

		MACHPROC_STARTUP_1:

			g_StartXAConveyor := FALSE;
			g_LateralProcess.Common.Previous.TransferStatus 							:= EXC_STANDBY_0;
			IF g_LateralProcess.Common.SaveState = MACHPROC_DELIVER_PACKAGE_80 THEN
				BladeBackTimer										:= g_LateralProcess.Common.CurTimer;
				g_LateralProcess.Common.State 						:= MACHPROC_DELIVER_PACKAGE_80;
				g_LateralProcess.Common.Previous.TransferStatus 	:= EXC_RECIVING_4;
			ELSE
				g_LateralProcess.Common.State 						:= MACHPROC_RUN_20;
				g_LateralProcess.Common.Previous.TransferStatus 	:= EXC_STANDBY_0;
			END_IF
			(*SFX savestate start is not working 090202*)
			g_LateralProcess.Common.State 							:= MACHPROC_RUN_20;
			g_LateralProcess.Common.Previous.TransferStatus 		:= EXC_STANDBY_0;



		MACHPROC_MANUAL_8:

			;


			(*###############################################################*)
			(* Machine Stop case, to handle shut down process of the module  *)
			(*###############################################################*)


		MACHPROC_STOP_15:
			;
			(* Reset output and handle the shutdown procedure *)
			(* Extra stop cases may be needed.. *)

			g_LateralProcess.SetSlope								:= FALSE;
			g_LateralProcess.Common.State 							:= MACHPROC_INIT_0;
			g_LateralProcess.Common.FoldUnit1.State					:= FOLDIO_STATE_IDLE_0;
			g_LateralProcess.Common.FoldUnit2.State					:= FOLDIO_STATE_IDLE_0;
			g_LateralProcess.Common.Motor.cmdStop					:= TRUE;
			IF g_MachineManager[g_LateralProcess.Common.Id].ForcedStop THEN
				g_LateralProcess.Common.SaveState := 0;
			END_IF
			IF LatJam THEN
				g_LateralProcess.Common.Next.TransferStatus := EXC_STANDBY_0;
				g_LateralProcess.Common.Previous.TransferStatus := EXC_STANDBY_0;
				LatJam := FALSE;
			END_IF		



			(*#####################*)
			(* Main running state  *)
			(*#####################*)

		MACHPROC_RUN_20:
			//PWC 26-11-2018: Reset Templates before next garment arives 
			g_LateralProcess.Template1_40			:= FALSE;
			g_LateralProcess.Template1_20			:= FALSE;
			g_LateralProcess.Template1_10			:= TRUE;
			g_LateralProcess.Template1_05			:= FALSE;

			g_LateralProcess.Template2_40			:= FALSE;
			g_LateralProcess.Template2_20			:= FALSE;
			g_LateralProcess.Template2_10			:= TRUE;
			g_LateralProcess.Template2_05			:= FALSE;

		
			g_LateralProcess.KeepLeftBladeOut 	:= FALSE;
			g_AutoProgram.IsFlapTrousers		:= FALSE; 

			(* Stop Motor if all process are idle... *)

			IF NOT g_StartXAConveyor AND (g_LateralProcess.Common.State = MACHPROC_RUN_20) AND g_CrossFoldAProcess.Common.State = MACHPROC_RUN_20 AND g_CrossFoldBProcess.Common.State = MACHPROC_RUN_20 AND g_StackerProcess[1].Common.State = MACHPROC_RUN_20 THEN
				IF g_LateralProcess.Common.Motor.Run OR g_CrossFoldAProcess.Common.Motor.Run OR g_CrossFoldBProcess.Common.Motor.Run THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Lat, Stop all idle');
				END_IF	
				g_LateralProcess.Common.Motor.cmdStop 		:= TRUE;
				g_CrossFoldAProcess.Common.Motor.cmdStop 	:= TRUE;
				g_CrossFoldBProcess.Common.Motor.cmdStop 	:= TRUE;
			END_IF

			IF g_StartXAConveyor THEN 
				// Photocell covered at start
				IF (IBXAFoldHorizontal OR IBXAFold) THEN
					g_LateralProcess.Common.ErrorCode := 6;
					g_LateralProcess.Common.State := MACHPROC_TRIG_ERROR_98;
				ELSE
					g_CrossFoldAProcess.Common.Motor.cmdForward			:= TRUE;			(* Cross A motor forward.. *)
				END_IF				
			END_IF
		
			IF g_LateralProcess.Common.State = MACHPROC_ERROR_99 OR g_CrossFoldAProcess.Common.State = MACHPROC_ERROR_99 OR g_CrossFoldBProcess.Common.State = MACHPROC_ERROR_99 THEN
				IF g_LateralProcess.Common.Motor.Run OR g_CrossFoldAProcess.Common.Motor.Run OR g_CrossFoldBProcess.Common.Motor.Run THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Lat, Stop one error');
				END_IF	
				g_LateralProcess.Common.Motor.cmdStop 		:= TRUE;
				g_CrossFoldAProcess.Common.Motor.cmdStop 	:= TRUE;
				g_CrossFoldBProcess.Common.Motor.cmdStop 	:= TRUE;
				gXAFold2Motor.CountReset := g_MilliSeconds;
				gXAFold2Motor.Set := FALSE;
				gXAFold2Motor.Reset := TRUE;
			END_IF


			// Lift blades by timer, i also lifted when the garment is fully on the lateral belt has left Turn Around...
			IF ElapsedMsTime(g_LateralProcess.Common.CurTimer, g_LateralProcess.LiftBladesTimer) >= g_LateralProcess.LiftBladesTime THEN
				IF NOT g_LateralProcess.LiftTemplate THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Lat, Timer lift blades');
				END_IF
				g_LateralProcess.LiftTemplate					:= TRUE;
				rLiftRearTemplates	:= TRUE;
			END_IF	
		
			IF g_HCfg.DuoInlet THEN	// CWH_DUO
				rLiftRearTemplates	:= TRUE;
			END_IF


			(* Start the flow of goods *)
			g_LateralProcess.Common.SaveState 				:= 0;
			g_LateralProcess.Common.WatchDogRunTimer 		:= g_LateralProcess.Common.CurTimer;
			IF (g_LateralProcess.Common.Previous.TransferStatus = EXC_WANT_TO_UNLOAD_1 OR g_LateralProcess.Common.Previous.TransferStatus = EXC_UNLOADING_3) AND g_CrossFoldBProcess.Common.State < 98 AND NOT g_Core.System.Interface.alarms.isLowAirPressure THEN
				g_ToLatFold_StopJam := FALSE;
				//20-11-2018 PWC: If template is set to a low value, we move them in, but the final calculation is still done in state MACHPROC_SET_TEMPLATE_28
				IF (g_LateralProcess.TemplateSizeFirstPart < 21) THEN
					g_LateralProcess.Template1_20			:= FALSE;
				END_IF
				IF (g_LateralProcess.TemplateSizeFirstPart < 11) THEN
					g_LateralProcess.Template1_10			:= FALSE;
				END_IF
				IF (g_LateralProcess.TemplateSizeFirstPart < 6) THEN
					g_LateralProcess.Template1_05			:= FALSE;
				END_IF
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Lat,inlet ready');
				IF g_LateralProcess.Common.Previous.TransferStatus = EXC_WANT_TO_UNLOAD_1 THEN
					g_LateralProcess.Common.Previous.TransferStatus := EXC_READY_TO_RECIEVE_2;
				END_IF
				g_LateralProcess.Common.State					:= MACHPROC_WAIT_FOR_DATA_21;
				g_LateralProcess.SequenceBusy 					:= TRUE;// Pre start Duo Inlet Belt Motor. Garment would be wrinkled if not.	//CWH_DUO
				g_LateralProcess.Common.Motor.cmdForward		:= TRUE;						(* Lateral motor forward.. *)
				g_DuoInletMotorPreStart							:= TRUE;
			END_IF

			(*##################################################*)
			(* Module specific states for running of the module *)
			(*##################################################*)


		MACHPROC_WAIT_FOR_DATA_21:

			(* I'm in position *)
			(* Previous task is ready to unload*)
			//09-12-12
			IF g_LateralProcess.Common.Previous.TransferStatus = EXC_UNLOADING_3 AND g_CrossFoldBProcess.Common.State < 98 THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Lat,inlet send data');
				g_LateralProcess.Common.WatchDogRunTimer			:= g_LateralProcess.Common.CurTimer;
				g_LateralProcess.Common.State 						:= MACHPROC_WAIT_FOR_JOB_22;
			END_IF



		MACHPROC_WAIT_FOR_JOB_22:


			g_LateralProcess.Common.WatchDogRunTimer 			:= g_LateralProcess.Common.CurTimer;
			g_LateralProcess.LiftBladesTimer					:= g_LateralProcess.Common.CurTimer;
			g_LateralProcess.Common.Product.Length 				:= 0;
			g_LateralProcess.Common.Product.LengthStart			:= 0;
			g_LateralProcess.Common.Motor.cmdForward			:= TRUE;						(* Lateral motor forward.. *)
			g_LateralProcess.Common.Previous.TransferStatus 	:= EXC_RECIVING_4;
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Lat,template ok');
			g_AutoProgram.ProgramFound							:= FALSE;
			g_AutoProgram.IsFlapTrousers						:= FALSE;
			rLiftRearTemplates									:= TRUE; 
			rLiftDuoInlet										:= TRUE;	//CWH_DUO
			g_LateralProcess.Common.State 						:= MACHPROC_WAIT_START_INLET_26;

		
			// Some trouser needs to be passed under the lateral blades..
			// We need to look at the Top Conveyor data, otherwise we be to late after the Rear edge on TopConveyor...
			IF g_ACfg[ACfgTopConveyorProgram].BypassLateralBlades = 1 THEN
				IF (g_TopConveyorProcess.Common.Product.ProductType = TROUSER_TYPE_0) THEN
					g_LateralProcess.RaiseBlades				:= TRUE;			(* Lower the template baldes down *)
				END_IF		
			ELSIF g_ACfg[ACfgTopConveyorProgram].BypassLateralBlades = 2 THEN	
				g_LateralProcess.RaiseBlades					:= TRUE;			(* Lower the template baldes down *)
			ELSE
				g_LateralProcess.RaiseBlades					:= FALSE;
			END_IF
			
			// XtremeHeavy blades
			g_LateralProcess.XtremeRaiseBlades :=   g_ACfg[ACfgTopConveyorProgram].XtremeRaiseBlades;	

			// Offset rigth blade if trouser and Autoprogram has it activated..
			//			IF g_ACfg[ACfgTopConveyorProgram].OffsetBlade = 1 THEN
			IF (g_TopConveyorProcess.Common.Product.ProductType = TROUSER_TYPE_0) THEN
				g_LateralProcess.OffsetBlade := TRUE;
			ELSE
				g_LateralProcess.OffsetBlade := FALSE;
			END_IF				
			//			ELSE
			//				g_LateralProcess.OffsetBlade := FALSE;
			//			END_IF


			(* Garment have no left the Inlet belt and is on the lateral belt only.. Check this POX... *)
		MACHPROC_WAIT_START_INLET_26:
			g_DuoInletMotorPreStart								:= FALSE;// Only used for starting Duo Inlet Belt earlier. Make sure it's not forcing motor On.	//CWH_DUO
			// Lift blades by timer, i also lifted when the garment is fully on the lateral belt has left Turn Around...
			IF ElapsedMsTime(g_LateralProcess.Common.CurTimer, g_LateralProcess.LiftBladesTimer) >= g_LateralProcess.LiftBladesTime THEN
				IF NOT g_LateralProcess.LiftTemplate THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Lat, Timer lift blades');
				END_IF
				g_LateralProcess.LiftTemplate					:= TRUE;
				rLiftRearTemplates	:= TRUE;
			END_IF	

			(* Fold point is calculated here... *)
			IF g_LateralProcess.Common.Previous.TransferStatus = EXC_FINISHED_UNLOADING_5 THEN
				//g_LateralProcess.Common.Previous.TransferStatus := EXC_RECIVING_DONE_6;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Lat,wait trig');
				g_LateralProcess.LiftTemplate					:= TRUE;
				rLiftRearTemplates	:= TRUE;
				g_LateralProcess.Common.FoldPointTimer 			:= g_DummyPulses;
				g_AutoProgram.ProgramFound 						:= FALSE;
				g_LateralProcess.Common.Product					:= g_LateralProcess.Common.Previous.Product;
				g_LateralProcess.Common.Product.SelectedAutoProg	:= g_LateralProcess.Common.Product.FoldProgram;
				g_AutoProgram.AutoProgramToSearch				:= g_LateralProcess.Common.Product.FoldProgram;		// Send Auto program to be searched for recipe...
				g_AutoProgram.MeasuredLenght					:= g_LateralProcess.Common.Product.Length;			// Data to Auto program select function 
				g_AutoProgram.ShirtDetected						:= g_LateralProcess.Common.Product.ProductType;		// 1 = Shirt, 0 = Trouser... 
				g_AutoProgram.IsFlapTrousers					:= g_LateralProcess.Common.Product.IsFlapTrousers;		 
				
				TrigSelectionAct;
				IF g_LateralProcess.Common.Product.IsFlapTrousers THEN
					ShirtDetectedHMI := 2;	// Shirt icon
				ELSIF (g_LateralProcess.Common.Product.ProductType = SHIRT_TYPE_1) OR (g_LateralProcess.Common.Product.ProductType = PYJAMAS_TYPE_2) THEN
					ShirtDetectedHMI := 1;	// Shirt icon
				ELSE
					ShirtDetectedHMI := 3;	// Trouser icon 
				END_IF	
				g_LateralProcess.SetGap							:= FALSE;											// Reset it at start of goods flow...
				g_LateralProcess.CloseGapTimer 					:= g_DummyPulses;
				g_LateralProcess.Common.Previous.TransferStatus := EXC_STANDBY_0;						(* Free inlet belt to take next garment... *)
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_LateralProcess.Common.FoldPointTimer, 'Lat, FoldPoint value');
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_LateralProcess.Common.Product.Length, 'Lat, Lenght value');
			ELSIF g_LateralProcess.Common.Previous.TransferStatus = 7 THEN
				g_LateralProcess.Common.Previous.TransferStatus := EXC_STANDBY_0;
				g_LateralProcess.SequenceBusy 					:= FALSE;
				g_LateralProcess.Common.State 					:= MACHPROC_RUN_20;
				g_LateralProcess.Common.WatchDogRunTimer 		:= g_LateralProcess.Common.CurTimer;
			ELSIF g_ToLatFold_StopJam THEN
				g_ToLatFold_StopJam := FALSE;
				g_LateralProcess.Common.Previous.TransferStatus := EXC_STANDBY_0;
				g_LateralProcess.Common.Motor.cmdStop := TRUE;			
				g_CrossFoldAProcess.Common.Motor.cmdStop := TRUE;			
				g_LateralProcess.Common.State 					:= MACHPROC_RUN_20;
			ELSIF g_TopConveyorProcess.Common.ErrorCode = 2 THEN
				g_LateralProcess.Common.Previous.TransferStatus := EXC_STANDBY_0;
				g_LateralProcess.Common.WatchDogRunTimer 		:= g_LateralProcess.Common.CurTimer;
				g_LateralProcess.Common.State 					:= MACHPROC_RUN_20;
			END_IF
		
			IF g_AutoProgram.ProgramFound THEN
				g_AutoProgram.ProgramFound := FALSE;
				g_LateralProcess.Common.Product.FoldProgram		:= g_AutoProgram.SelectedProgram;	
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_AutoProgram.SelectedProgram, 'Lat, Selected Autoprogram');
				g_LateralProcess.Common.ReadParameters 			:= TRUE;
				g_Core.Services.CAR.Interface.No[0].RecipeNumber := UINT_TO_USINT(g_LateralProcess.Common.Product.FoldProgram);
				g_LateralProcess.Common.State 					:= MACHPROC_SET_TEMPLATE_28;
			END_IF		

		MACHPROC_SET_TEMPLATE_28:

			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Lat, Set template ');


			// To get selected stacker right from Metricon or from Recipe setting..
			IF g_LateralProcess.Common.Product.Stack = 0 THEN		// No data comes from Metricon
				IF (LocalFoldProgram.SelectedStack > 0) AND (LocalFoldProgram.SelectedStack <= g_HCfg.NumberOfStackers) THEN
					g_LateralProcess.Common.Product.Stack 	:= LocalFoldProgram.SelectedStack;
				ELSE	
					g_LateralProcess.Common.Product.Stack 	:= 1;
				END_IF	
			END_IF	
		
			// If bad stacker destination send to stacker 1...
			IF (g_LateralProcess.Common.Product.Stack < 1) AND (g_LateralProcess.Common.Product.Stack > g_HCfg.NumberOfStackers) THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_LateralProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Lat, Bad stacker destination');
				g_LateralProcess.Common.Product.Stack 	:= 1;
			END_IF		
		

		
			(*####################################*)
			(* Calculate the size of the template *)
			(*####################################*)


			IF (g_LateralProcess.Parameters.WidthFirst > g_MCfg.LFold.WidthIncrementOffset) THEN
				g_LateralProcess.TemplateSizeFirstPart			:= (g_LateralProcess.Parameters.WidthFirst - g_MCfg.LFold.WidthIncrementOffset) / 2;			
			ELSE
				g_LateralProcess.TemplateSizeFirstPart			:= 0;			
			END_IF
		
			IF (g_LateralProcess.Parameters.WidthLast > g_MCfg.LFold.WidthIncrementOffset) THEN
				g_LateralProcess.TemplateSizeLastPart			:= (g_LateralProcess.Parameters.WidthLast - g_MCfg.LFold.WidthIncrementOffset) / 2;
			ELSE
				g_LateralProcess.TemplateSizeLastPart			:= 0;
			END_IF

			g_LateralProcess.Template1_40			:= FALSE;
			g_LateralProcess.Template1_20			:= FALSE;
			g_LateralProcess.Template1_10			:= FALSE;
			g_LateralProcess.Template1_05			:= FALSE;

			g_LateralProcess.Template2_40			:= FALSE;
			g_LateralProcess.Template2_20			:= FALSE;
			g_LateralProcess.Template2_10			:= FALSE;
			g_LateralProcess.Template2_05			:= FALSE;

			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_LateralProcess.Parameters.WidthFirst, 'Lat, Param size first ');
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_LateralProcess.Parameters.WidthLast, 'Lat, Parem size last ');

			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_LateralProcess.TemplateSizeFirstPart, 'Lat, Temp size first ');
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_LateralProcess.TemplateSizeLastPart, 'Lat, Temp size last ');

			(*#############*)
			(* First part  *)
			(*#############*)
			CalcSize 								:= g_LateralProcess.TemplateSizeFirstPart;
			IF CalcSize >= 40 THEN
				g_LateralProcess.Template1_40	:= TRUE;
				CalcSize := CalcSize - 40;
			END_IF
			IF CalcSize >= 20 THEN
				g_LateralProcess.Template1_20	:= TRUE;
				CalcSize := CalcSize - 20;
			END_IF
			IF CalcSize >= 10 THEN
				g_LateralProcess.Template1_10	:= TRUE;
				CalcSize := CalcSize - 10;
			END_IF
			IF CalcSize >= 5 THEN
				g_LateralProcess.Template1_05	:= TRUE;
				CalcSize := CalcSize - 5;
			END_IF

			CalcSize 								:= g_LateralProcess.TemplateSizeLastPart;

			(*############*)
			(* Last part  *)
			(*############*)
			IF CalcSize >= 40 THEN
				g_LateralProcess.Template2_40	:= TRUE;
				CalcSize := CalcSize - 40;
			END_IF
			IF CalcSize >= 20 THEN
				g_LateralProcess.Template2_20	:= TRUE;
				CalcSize := CalcSize - 20;
			END_IF
			IF CalcSize >= 10 THEN
				g_LateralProcess.Template2_10	:= TRUE;
				CalcSize := CalcSize - 10;
			END_IF
			IF CalcSize >= 5 THEN
				g_LateralProcess.Template2_05	:= TRUE;
				CalcSize := CalcSize - 5;
			END_IF

			g_LateralProcess.Common.State 					:= MACHPROC_WAIT_FOLD_POINT_35;

			Dummy := FALSE;

			IF g_LateralProcess.Common.Product.ProductType = TOWELS_TYPE_3 THEN	// CWH_DUO
				RLowerBlades := TRUE;
			END_IF;


		MACHPROC_WAIT_FOLD_POINT_35:
			DuoRequest											:= FALSE; 		
			rLiftRearTemplates	:= FALSE;
			rLiftDuoInlet		:= FALSE;
						
			g_LateralProcess.CloseGapTime := LIMIT(10, g_LateralProcess.Common.FoldPointTime - 100, g_LateralProcess.Common.FoldPointTime);

			IF ElapsedMsTime(g_DummyPulses, g_LateralProcess.CloseGapTimer) >= g_LateralProcess.CloseGapTime THEN
				CASE g_LateralProcess.Parameters.BeltAdjust OF
					// Not insatlled
					XA_BELT_NOT_USED_0:
						g_LateralProcess.SetGap					:= FALSE;
						// Gap is closed during the fold	
					XA_BELT_CLOSE_CLOSE_1:	
						g_LateralProcess.SetGap					:= FALSE;
						// Gap is open at start and closes after a time.
					XA_BELT_OPEN_CLOSE_2:	
						g_LateralProcess.SetGap					:= TRUE;
						// Gap is closed and opens after a time
					XA_BELT_CLOSE_OPEN_3:	
						g_LateralProcess.SetGap					:= FALSE;
						// Gap is open during the fold	
					XA_BELT_OPEN_OPEN_4:	
						g_LateralProcess.SetGap					:= TRUE;		

				END_CASE
			END_IF
		
			IF g_LateralProcess.Common.Product.ProductType = TOWELS_TYPE_3 THEN	//CWH_DUO
				IF g_MCfg.Duo.TowelsXADistanceFactor <> 0 THEN
					runExtra := (g_LateralProcess.Common.Product.Length * REAL_TO_UINT(g_MCfg.Duo.TowelsXADistanceFactor) / 100); 
				ELSE
					runExtra := (g_LateralProcess.Common.Product.Length * REAL_TO_UINT(1.0) / 100);
				END_IF;
			ELSE
				runExtra := 0;
			END_IF;
		
			pmu_Test[0] := ElapsedMsTime(g_DummyPulses, g_LateralProcess.Common.FoldPointTimer);
			(* Check time to stop belt at fold point *)
			Position := ElapsedMsTime(g_DummyPulses, g_LateralProcess.Common.Product.LeadEdgeXA);
			IF Position >= g_LateralProcess.Common.FoldPointTime + runExtra THEN // RunExtra if linen comes from duo inlet
				linenSeenAtXA := FALSE;
				IF g_LateralProcess.Common.Product.ProductType = TOWELS_TYPE_3 THEN
					g_LateralProcess.RaiseBlades := FALSE;
				ELSE
					g_LateralProcess.RaiseBlades := TRUE;
				END_IF;
				pmu_Test[1] := ElapsedMsTime(g_DummyPulses, g_LateralProcess.Common.FoldPointTimer);
				pmu_Test[2] := ElapsedMsTime(g_DummyPulses, g_LateralProcess.Common.Product.LeadEdgeXA);
				pmu_Test[3] := g_LateralProcess.Common.FoldPointTimer;
				pmu_Test[4] := g_LateralProcess.Common.FoldPointTime;
			
			
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_DummyPulses, 'Lat at f-point');
				g_LateralProcess.Common.Motor.cmdHold		:= 1;
				checkCount[5] := 1;
				IF g_LateralProcess.CrossParameters.XAMotorExtraTime > 0 THEN
					g_LateralProcess.XAMotorExtraTimer := g_LateralProcess.Common.CurTimer;
				ELSE
					g_CrossFoldAProcess.Common.Motor.cmdStop	:= 1;				(* Stop Cross A motor.. *)
				END_IF
				g_LateralProcess.StartFold 					:= TRUE;			(* Do we need this?? POX *)
				g_LateralProcess.Common.State 				:= MACHPROC_WAIT_TEMPLATE_DOWN_36;
			END_IF
			
			(* If long garment make a new calculation *)	
			IF UINT_TO_INT(g_LateralProcess.Common.Product.Length + 200) >	g_MCfg.LFold.DistanceIBLA_FoldPoint THEN
				XA_Motor_StartPoint := 1;
			ELSE
				//09-12-21... Denna formel kunde slå minus om man hade plagg längd på 1250mm..
				//XA_Motor_StartPoint := (((g_MCfg.DistanceIBLA_FoldPoint - (g_LateralProcess.Common.Product.Length + 350 ))*100)/WHEEL_INC_TO_DISTANCE_MM);
				XA_Motor_StartPoint := 50;
			END_IF			


			(* When to start the Cross A motor forward *)
			IF ElapsedMsTime(g_DummyPulses, g_LateralProcess.Common.FoldPointTimer) >= XA_Motor_StartPoint THEN
				IF NOT Dummy THEN
					Dummy := TRUE;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_DummyPulses, 'Lat, start XA forward');
				END_IF
				g_CrossFoldAProcess.Common.Motor.cmdForward			:= TRUE;			(* Cross A motor forward.. *)
				g_CrossFoldAProcess.BeltOpen1.State					:= FOLDIO_STATE_IDLE_0;
			END_IF

			(* Check When to lower templates *)
			IF ElapsedMsTime(g_DummyPulses, g_LateralProcess.Common.FoldPointTimer) >= LIMIT(1, g_LateralProcess.Common.FoldPointTime - 20, g_LateralProcess.Common.FoldPointTime) THEN
				IF g_LateralProcess.LiftTemplate THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_DummyPulses, 'Lat Lower template');
				END_IF
				g_LateralProcess.RaiseBlades		:= TRUE;			(* Lower the template baldes down *)
				g_LateralProcess.LiftTemplate	:= FALSE;

				g_LateralProcess.SetSlope 		:= SetSlopeDummy = SLOPEMODE_ACTIVE_1;
			END_IF




		MACHPROC_WAIT_TEMPLATE_DOWN_36:


			(* Stop XA motor later *)
			IF ElapsedMsTime(g_LateralProcess.Common.CurTimer, g_LateralProcess.XAMotorExtraTimer) >= g_LateralProcess.CrossParameters.XAMotorExtraTime THEN
				g_CrossFoldAProcess.Common.Motor.cmdStop	:= 1;				(* Stop Cross A motor.. *)
			END_IF

			(* If motor is stopped go ahead *)
			IF g_CrossFoldAProcess.Common.Motor.State = MOTOR_STATE_STOP_3 THEN
				IF (IBXAFold OR IBXAFoldHorizontal  OR g_sim.IBXAFold) OR NOT g_HCfg.DuoInlet THEN	// CWH_DUO
					g_LateralProcess.Common.State 				:= MACHPROC_MAKE_LATERAL_FOLD_37;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_DummyPulses, 'Lat Temp lowered');
				ELSE
					g_LateralProcess.Common.ErrorCode 	:= 5;
					g_LateralProcess.Common.State				:= MACHPROC_TRIG_ERROR_98;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_DummyPulses, 'No Garment at X-A or Ph defect');
				END_IF
			END_IF


			(* Right blade first *)
		MACHPROC_MAKE_LATERAL_FOLD_37:

			(* Calculate the FoldUnit times in the read parameters *)
			IF (g_LateralProcess.Common.FoldUnit1.State = FOLDIO_STATE_IDLE_0) AND (g_LateralProcess.Common.FoldUnit2.State = FOLDIO_STATE_IDLE_0) THEN
				g_LateralProcess.Common.FoldUnit1.State 	:= FOLDIO_STATE_START_1;
				g_LateralProcess.Common.FoldUnit2.State 	:= FOLDIO_STATE_START_1;
				//g_LateralProcess.SetSlope					:= g_CrossFoldBProcess.Parameters.SlopeMode = SLOPEMODE_ACTIVE_1; (* To set the Slope already here is reset by Cross B task *)			
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_DummyPulses, 'Lat Start blades');
				g_LateralProcess.Common.State 				:= MACHPROC_WAIT_SECOND_BLADE_40;
			END_IF

			(* Stop XA motor later *)
			IF ElapsedMsTime(g_LateralProcess.Common.CurTimer, g_LateralProcess.XAMotorExtraTimer) >= g_LateralProcess.CrossParameters.XAMotorExtraTime THEN
				g_CrossFoldAProcess.Common.Motor.cmdStop	:= 1;				(* Stop Cross A motor.. *)
			END_IF




		MACHPROC_WAIT_SECOND_BLADE_40:

			g_LateralProcess.Common.WatchDogRunTimer 		:= g_LateralProcess.Common.CurTimer;


			// Booth baldes back, if knif folding blades must get back..
			IF (g_LateralProcess.Parameters.FoldMode = 1) OR ((g_LateralProcess.CrossAFoldDevice = FOLD_DEVICE_KNIFE_1) OR (g_LateralProcess.CrossAFoldDevice = FOLD_DEVICE_AIR_KNIFE_2))THEN
				IF (g_LateralProcess.Common.FoldUnit1.State = FOLDIO_STATE_IDLE_0) AND (g_LateralProcess.Common.FoldUnit2.State = FOLDIO_STATE_IDLE_0) THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_DummyPulses, 'Lat, Booth blades done');
					g_LateralProcess.Common.State 				:= MACHPROC_WAIT_TIME_45;
					g_LateralProcess.WaitBladeBackTimer			:= g_LateralProcess.Common.CurTimer;
				END_IF
				// Left blade stay out during XA fold	
			ELSE
				IF (g_LateralProcess.Common.FoldUnit1.State = FOLDIO_STATE_IDLE_0) THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_DummyPulses, 'Lat, Blades Out');
					g_LateralProcess.WaitBladeOutTime			:= g_LateralProcess.Common.FoldUnit2.OnTime;				
					g_LateralProcess.WaitBladeOutTimer			:= g_LateralProcess.Common.CurTimer;
					g_LateralProcess.WaitBladeBackTimer			:= g_LateralProcess.Common.CurTimer;
					g_LateralProcess.KeepLeftBladeOut			:= TRUE;		
					g_LateralProcess.Common.State 				:= MACHPROC_WAIT_BLADEOUT_42;	
				END_IF
			END_IF



		MACHPROC_WAIT_BLADEOUT_42:
	
			IF ElapsedMsTime(g_LateralProcess.Common.CurTimer, g_LateralProcess.WaitBladeOutTimer) >= g_LateralProcess.WaitBladeOutTime THEN
				BladeBackTimer								:= g_LateralProcess.Common.CurTimer;
				g_LateralProcess.Common.State 				:= MACHPROC_DELIVER_PACKAGE_80;
			END_IF


		MACHPROC_WAIT_TIME_45:

			IF ElapsedMsTime(g_LateralProcess.Common.CurTimer, g_LateralProcess.WaitBladeBackTimer) >= g_LateralProcess.WaitBladeBackTime THEN
				BladeBackTimer								:= g_LateralProcess.Common.CurTimer;
				g_LateralProcess.Common.State 				:= MACHPROC_DELIVER_PACKAGE_80;
			END_IF


		MACHPROC_DELIVER_PACKAGE_80:

			g_LateralProcess.Common.WatchDogRunTimer 		:= g_LateralProcess.Common.CurTimer;
			g_LateralProcess.Common.SaveState 				:= MACHPROC_DELIVER_PACKAGE_80;

			// Wait for next task to prepare to take over product. 
			// And check on knife and left blade home...
			IF g_LateralProcess.Common.Next.TransferStatus = EXC_STANDBY_0 THEN
				g_LateralProcess.Common.Product.RecipeName := g_Core.Services.CAR.Runtime.No[0].RecipeName;
				IF ((g_LateralProcess.CrossAFoldDevice = FOLD_DEVICE_KNIFE_1) 
					OR (g_LateralProcess.CrossAFoldDevice = FOLD_DEVICE_AIR_KNIFE_2))
					AND g_LateralProcess.LeftBladeIsBack THEN 
					g_LateralProcess.Common.Next.Product 		:= g_LateralProcess.Common.Product;
					g_LateralProcess.Common.Next.TransferStatus := EXC_WANT_TO_UNLOAD_1;
					g_LateralProcess.Common.State 				:= MACHPROC_PACKAGE_DELIVERED_81;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_DummyPulses, 'Lat knife 80->81');
				ELSIF g_LateralProcess.CrossAFoldDevice = FOLD_DEVICE_AIR_0 THEN
					g_LateralProcess.Common.Next.Product 		:= g_LateralProcess.Common.Product;
					g_LateralProcess.Common.Next.TransferStatus := EXC_WANT_TO_UNLOAD_1;
					g_LateralProcess.Common.State 				:= MACHPROC_PACKAGE_DELIVERED_81;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_DummyPulses, 'Lat air 80->81');	
				END_IF	
				// POX 10-10-05.. Time out if the Blade back sensor is not activated..
				IF ElapsedMsTime(g_LateralProcess.Common.CurTimer, BladeBackTimer) >= BladeBackTime THEN
					g_LateralProcess.Common.ErrorCode 	:= 4;
					g_LateralProcess.Common.State 		:= MACHPROC_TRIG_ERROR_98;	
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_DummyPulses, 'Lat Bladeback senor error');
				END_IF
			END_IF
			BladeBackTimer := g_LateralProcess.Common.CurTimer;// PWC: Always reset Timer at this point to avoid what POX describes below.
		
			//		// POX 2010-10-26, to reset timer is sensor is activated, to not trigger error if machine is locking backwards...
			//		IF g_LateralProcess.LeftBladeIsBack THEN 
			//			BladeBackTimer := g_LateralProcess.Common.CurTimer;
			//		END_IF			
			//




		MACHPROC_PACKAGE_DELIVERED_81:

			g_LateralProcess.Common.WatchDogRunTimer 		:= g_LateralProcess.Common.CurTimer;
			RLowerBlades										:= TRUE;							// Raise the template baldes
			IF g_LateralProcess.KeepLeftBladeOut THEN
				DelayFoldbladeBack.Set := 1;
				g_LateralProcess.KeepLeftBladeOut				:= FALSE;							// Reset balde if still out..	
				g_LateralProcess.Common.ExitTime				:= g_LateralProcess.Common.ExitTime + g_MCfg.LFold.BladeBackTime;
			END_IF	
			
			IF g_LateralProcess.Common.Next.TransferStatus = EXC_STANDBY_0 THEN					// If e-stop restart i Cross A it can be needed to start from _0 
				g_LateralProcess.Common.Next.TransferStatus 		:= EXC_WANT_TO_UNLOAD_1;		
			ELSIF g_LateralProcess.Common.Next.TransferStatus = EXC_READY_TO_RECIEVE_2 THEN
				g_LateralProcess.Common.Next.TransferStatus 		:= EXC_UNLOADING_3;	
				g_LateralProcess.Common.Motor.cmdForward			:= 1;						// Start Lateral motor for Cross A fold.. 
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_DummyPulses, 'Lat Start XA Motor');
			ELSIF g_LateralProcess.Common.Next.TransferStatus = EXC_RECIVING_4 THEN
				g_LateralProcess.Common.Next.TransferStatus 		:= EXC_FINISHED_UNLOADING_5;
				g_LateralProcess.Common.WatchDogRunTimer 			:= g_LateralProcess.Common.CurTimer;
				g_LateralProcess.Common.ExitTimer 					:= g_LateralProcess.Common.CurTimer;
				g_LateralProcess.TemplateResetFlag					:= TRUE;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_DummyPulses, 'Lat 81->82');
				g_LateralProcess.Common.State 					:= MACHPROC_WAIT_BEFORE_EXIT_82;
			END_IF


		MACHPROC_WAIT_BEFORE_EXIT_82:

			// Wait blade back sensor
			IF g_LateralProcess.LeftBladeIsBack THEN													// Speed up 1200
				g_LateralProcess.LiftBladesTimer				:= g_LateralProcess.Common.CurTimer;	// POX 10-03-09...
				g_LateralProcess.Common.WatchDogRunTimer 		:= g_LateralProcess.Common.CurTimer;
				g_LateralProcess.SequenceBusy 					:= FALSE;	//CWH_DUO
				g_LateralProcess.Common.State 					:= MACHPROC_RUN_20;
			END_IF


		MACHPROC_ERROR_99:

			g_StartXAConveyor := FALSE;
			g_LateralProcess.Common.Motor.cmdStop		:= TRUE;
			g_LateralProcess.SetSlope					:= FALSE;
			g_LateralProcess.KeepLeftBladeOut			:= FALSE;
			g_LateralProcess.Common.FoldUnit1.Output	:= 0;
			g_LateralProcess.Common.FoldUnit2.Output	:= 0;
			rLiftRearTemplates							:= FALSE;	//CWH_DUO
		rLiftDuoInlet								:= FALSE;	//CWH_DUO


	END_CASE

	(* Take care of timeout errors *)
	IF 	g_LateralProcess.Common.State >= MACHPROC_RUN_20 AND
		g_LateralProcess.Common.State < MACHPROC_TRIG_ERROR_98 THEN
		IF 	ElapsedMsTime(g_LateralProcess.Common.CurTimer, g_LateralProcess.Common.WatchDogRunTimer) >= (g_LateralProcess.Common.WatchDogRunTime-100) THEN
			IF 	g_LateralProcess.Common.State < MACHPROC_WAIT_FOR_TRIG_23 THEN
				g_LateralProcess.Common.State 					:= MACHPROC_RUN_20;
				g_LateralProcess.Common.Previous.TransferStatus := EXC_STANDBY_0;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_DummyPulses, 'Lat, timeout 1');
			ELSIF 	g_LateralProcess.Common.State > MACHPROC_WAIT_BEFORE_EXIT_82 THEN
				g_LateralProcess.Common.State 					:= MACHPROC_RUN_20;
				g_LateralProcess.Common.Previous.TransferStatus := EXC_STANDBY_0;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_DummyPulses, 'Lat, timeout 2');
			ELSE
				;(* This is a true lateral error, leave it to error handler *)
			END_IF
		END_IF
	END_IF

	IF 	g_LateralProcess.Common.State >= MACHPROC_RUN_20 AND
		g_LateralProcess.Common.State <= MACHPROC_WAIT_BEFORE_EXIT_82 THEN
		IF g_LateralProcess.Common.Product.LengthStart = 0 THEN
			IF (g_LateralProcess.Common.InSensor.Input=0) AND OldSensor THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_LateralProcess.Common.LogBookFlag, g_DummyPulses, 'Lat, lengthstart');
				g_LateralProcess.Common.Product.LengthStart 	:= g_DummyPulses;
			END_IF
		END_IF
	END_IF
	OldSensor := g_LateralProcess.Common.InSensor.Output;




	RunFoldMotor(g_MCfg.Trace2File, ADR(T2FD), g_LateralProcess.Common.Motor, g_LateralProcess.Common.CurTimer, 0);


	(* If E-stop will this output drop. Set variable accordingly to avoid movement when E-stop is released *)
	IF g_Machine.EStopActivated THEN
		g_LateralProcess.Common.FoldUnit1.Output		:= 0;
		g_LateralProcess.Common.FoldUnit2.Output		:= 0;
		g_LateralProcess.KeepLeftBladeOut				:= FALSE;
		g_LateralProcess.Template1_05					:= 0;
		g_LateralProcess.Template1_10					:= 0;
		g_LateralProcess.Template1_20					:= 0;
		g_LateralProcess.Template1_40					:= 0;
	END_IF

	// TEST PWC
	KeepLeftBladeOutDelay( Set := g_LateralProcess.KeepLeftBladeOut, CntAdr := ADR(g_MilliSeconds), Delay := g_LateralProcess.Parameters.DelayBladeBack );
	IF RLowerBlades AND IIBladeRightHome THEN
		RLowerBlades := FALSE;
		g_LateralProcess.RaiseBlades := FALSE;
	END_IF

	// Lateral fold blades
	QYLFoldBladeRight	:= g_LateralProcess.Common.FoldUnit1.Output OR KeepLeftBladeOutDelay.Out;  
	QYLFoldBladeLeft	:= g_LateralProcess.Common.FoldUnit2.Output;

	(* First set of templates *)
	QYWidthFront05	:= g_LateralProcess.Template1_05;
	QYWidthFront10	:= g_LateralProcess.Template1_10;
	QYWidthFront20	:= g_LateralProcess.Template1_20;
	QYWidthFront40	:= g_LateralProcess.Template1_40;
	(* Second set of templates *)
	QYWidthBack05	:= g_LateralProcess.Template2_05;
	QYWidthBack10	:= g_LateralProcess.Template2_10;
	QYWidthBack20	:= g_LateralProcess.Template2_20;
	QYWidthBack40	:= g_LateralProcess.Template2_40;

	(*PWC: Reset Templates for next Garment if old Garment is clear of L-Fold *)	// CWH_DUO
	IF EDGENEG(IBXAFold) AND NOT IBXAFoldHorizontal AND (g_LateralProcess.Common.State = 20) THEN
		g_LateralProcess.Template1_40			:= FALSE;
		g_LateralProcess.Template1_20			:= FALSE;
		g_LateralProcess.Template1_10			:= FALSE;
		g_LateralProcess.Template1_05			:= FALSE;

		g_LateralProcess.Template2_40			:= FALSE;
		g_LateralProcess.Template2_20			:= FALSE;
		g_LateralProcess.Template2_10			:= FALSE;
		g_LateralProcess.Template2_05			:= FALSE;
	END_IF
	//test to close Backtemplate after it went up-> if used comment what is already in state20
//	IF EDGEPOS(QYTemplatesUp[0]) AND (g_LateralProcess.Common.State >= 20) THEN
//		g_LateralProcess.Template2_40			:= FALSE;
//		g_LateralProcess.Template2_20			:= FALSE;
//		g_LateralProcess.Template2_10			:= TRUE;
//		g_LateralProcess.Template2_05			:= FALSE;
//	END_IF;

	//Q_LowerTemplate										:= g_LateralProcess.LiftTemplate;		// Lift templates when garment is coming in to lateral.. 
	QYTemplatesUp[0]	:= g_LateralProcess.LiftTemplate AND NOT g_LateralService;		// Lift templates when garment is coming in to lateral.. 
	QYBypassLateral		:= g_LateralProcess.BypassLateral;		// Trouser can bypass the lateral fold... 
	QYOffsetBlade		:= g_LateralProcess.OffsetBlade;		// Offset the right blade when trouser that needs lateral folding...
	//Q_LowerBlades		:= g_LateralProcess.RaiseBlades;
	QYRaiseBlades		:= ((g_LateralProcess.RaiseBlades AND NOT g_DuoInletProcess.lowerBlades) OR g_LateralService AND NOT g_TestRaiseBlades);	//CWH_DUO
	QMLFold[1]			:= g_LateralProcess.Common.Motor.Run AND g_Core.System.Runtime.isRunning;

	// ----------------------------------------------------------------
	// PMU: Xtreme Heavy option
	// ----------------------------------------------------------------
	
	QYTemplatesUp[1] 	:= ((rLiftRearTemplates AND g_ACfg[g_AutoProgram.SelectedAutoProgram -1].XtremeHeavy) OR g_XtremeHeavy.Templates) OR (rLiftRearTemplates AND g_HCfg.DuoInlet) AND NOT g_LateralService;
	
	IF g_Core.System.Runtime.isRunning THEN //Only make physical movement if machine is running
		QYGuidePlates := g_ACfg[ACfgTopConveyorProgram].XtremeGuideplates OR g_XtremeHeavy.Guideplates;
	END_IF

	QYRaiseRBlade[0] 	:= QYRaiseBlades;
	QYRaiseRBlade[1] 	:= QYRaiseBlades AND g_LateralProcess.XtremeRaiseBlades; // g_ACfg[g_AutoProgram.SelectedAutoProgram -1].XtremeRaiseBlades;
	QYRaiseRBlade[2] 	:= QYRaiseBlades AND g_LateralProcess.XtremeRaiseBlades; // g_ACfg[g_AutoProgram.SelectedAutoProgram -1].XtremeRaiseBlades;

	QYRaiseLBlade[0] 	:= QYRaiseBlades;
	QYRaiseLBlade[1] 	:= QYRaiseBlades AND g_LateralProcess.XtremeRaiseBlades; // g_ACfg[g_AutoProgram.SelectedAutoProgram -1].XtremeRaiseBlades;
	QYRaiseLBlade[2] 	:= QYRaiseBlades AND g_LateralProcess.XtremeRaiseBlades; // g_ACfg[g_AutoProgram.SelectedAutoProgram -1].XtremeRaiseBlades;

	// ----------------------------------------------------------------
	// Duo Inlet option
	// ----------------------------------------------------------------

	// 17-12-2018 PWC: Inset a delay from machine timer for the DuoInlet to raise ( Only when using DuoInlet part)
	IF DuoRequest THEN
		DelayRaiseDuoInlet(IN := rLiftDuoInlet, PT := UINT_TO_TIME(g_MCfg.Duo.RaiseDuoInletDelay));
		rRaiseDuoInlet := DelayRaiseDuoInlet.Q;
	ELSE
		rRaiseDuoInlet := rLiftDuoInlet;// PWC: When Garment comes from Fox Inlet, we don't use the delay.
	END_IF

	QYRaiseDuoInlet := rRaiseDuoInlet OR (g_LateralService AND g_TestRaiseInlet);

	// ----------------------------------------------------------------
END_PROGRAM

