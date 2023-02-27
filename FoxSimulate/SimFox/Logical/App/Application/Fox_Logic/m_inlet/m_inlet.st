(********************************************************************
 * COPYRIGHT -- IT
 ********************************************************************
 * Program: m_inlet
 * File: m_inlet.st
 * Author: mariw
 * Created: May 26, 2011
 ********************************************************************
 * Implementation OF program m_inlet
 ********************************************************************) 
ACTION ManualInletInit :
	
	StackDestinationTest := 1;			// Used for testing multistacker, set a fixed Stack destination from Inlet...
	(* Common settings for the task *)
	g_ManualInletProcess.Values.StopFeedingStatus 			:= 1;		// Always start feeding at startup...
	g_ManualInletProcess.Values.AutoSelectColor 			:= 46;		// Yellow
	(* Individual settings for the task *)
	g_ManualInletProcess.Common.Description 		:= 'Manual Inlet';
	InitFoldTask(g_ManualInletProcess.Common, g_MachineManager[g_ManualInletProcess.Common.MachineManagerIndex]);
	g_AutoProgram.SelectedAutoProgram 				:= 1;
	g_AutoProgram.OperatorAutoProgram				:= g_AutoProgram.SelectedAutoProgram;
END_ACTION


ACTION ManualInlet: 
	(*------------------------------------------------------------------------------------------------*)
	(*------------------------------ CALL PROCESS 			------------------------------------------*)	
	(*------------------------------------------------------------------------------------------------*)
	(*#####################*)
	(* Get current time... *)
	(*#####################*)
	g_ManualInletProcess.Common.CurTimer 						:= g_Timers._1_ms;						(* Get current time *)
	IF g_ManualInletProcess.Common.LogBookFlag > 0 THEN
		strcpy(ADR(TmpStr),ADR(g_ManualInletProcess.Common.Description));
	END_IF
	(*##################*)
	(* Stop feeding HMI *)
	(*##################*)
	g_HangerInletProcess.StopFeedingCmd := 0;
	IF g_ManualInletProcess.Common.State <> 20 THEN										
		g_HangerInletProcess.StopFeedingCmd := 1; 
	ELSIF (g_ManualInletProcess.Common.State = 20) AND NOT g_Machine.StopAttempt THEN	
		g_HangerInletProcess.StopFeedingCmd := 0; 
	END_IF	
	(*#################################*)
	(* copy status of exchange objects *)
	(*#################################*)
	g_ManualInletProcess.Common.Next			:= g_TopConveyorProcess.Common.Previous;




	(*------------------------------------------------------------------------------------------------*)
	(*------------------------------ GET INPUTS SIGNALS		------------------------------------------*)
	(*------------------------------------------------------------------------------------------------*)

	// Detect shirt or trouser at inlet, one or both photocells needed for detection
	g_ManualInletProcess.Inputs.ShirtDetect.Input					:= IBTrouseDetection OR IBLeftTrouseDetection OR IBRightTrouseDetection ;		// WM Detect shirt or trouser at inlet
	g_ManualInletProcess.Inputs.GarmentDetectionUp.Input			:= IBGarmentDetection;		// Detect and measure garment at inlet
	g_ManualInletProcess.Inputs.GarmentOnInlet.Input				:= IBGarmentOnInletMP ;
	g_ManualInletProcess.Inputs.ReachedInfeedBeltEnd.Input			:= IBInfeedBeltEndMP ;
	g_ManualInletProcess.Inputs.InletConvoyerJam.Input				:= IBInletConvoyerJamMP ;
	
	g_ManualInletProcess.Inputs.StartButtons[1].Input 				:= ISStartMP[1];
	g_ManualInletProcess.Inputs.StartButtons[2].Input 				:= ISStartMP[2];
	g_ManualInletProcess.Inputs.StartButtons[3].Input 				:= ISStartMP[3];
	g_ManualInletProcess.Inputs.StartButtons[4].Input 				:= ISStartMP[4];
	g_ManualInletProcess.Inputs.StartButtons[5].Input 				:= ISStartMP[5];
	g_ManualInletProcess.Inputs.StartButtons[6].Input 				:= ISStartMP[6];
	g_ManualInletProcess.Inputs.StartButtons[7].Input 				:= ISStartMP[7];
	g_ManualInletProcess.Inputs.StartButtons[8].Input 				:= ISStartMP[8];
	g_ManualInletProcess.Inputs.StartButtons[9].Input 				:= ISStartMP[9];
	g_ManualInletProcess.Inputs.StartButtons[10].Input 				:= ISStartMP[10];
	
	//Show number of buttons in use for manual start 	//cbv
	
	FOR i:= 1 TO 10 DO
		IF i <= g_HCfg.NumberOfButtonsMF THEN
			g_HMI_MacConfig.ManualFeed.RTButton[i] := 0;
		ELSE
			g_HMI_MacConfig.ManualFeed.RTButton[i] := 1;
		END_IF
	END_FOR


	(*------------------------------------------------------------------------------------------------*)
	(*------------------------------ INPUTS PARAMATER 		------------------------------------------*)
	(*------------------------------------------------------------------------------------------------*)

	g_ManualInletProcess.Common.WatchDogStartupTime						:= 4000;
	g_ManualInletProcess.Common.WatchDogRunTime							:= 2800; 		// changed from 2800 to 2800 ms 
	g_ManualInletProcess.Common.ExitTime								:= 100;
	
	// Inputs Parameter 
	g_ManualInletProcess.Inputs.ShirtDetect.OnDelay						:= g_MCfg.SensorFilterTime;
	g_ManualInletProcess.Inputs.ShirtDetect.OffDelay					:= g_MCfg.SensorFilterTime;
	g_ManualInletProcess.Inputs.ReachedInfeedBeltEnd.OffDelay			:= g_MCfg.SensorFilterTime;
	g_ManualInletProcess.Inputs.ReachedInfeedBeltEnd.OnDelay			:= g_MCfg.SensorFilterTime;
	g_ManualInletProcess.Inputs.InletConvoyerJam.OffDelay				:= g_MCfg.SensorFilterTime;
	//g_ManualInletProcess.GarmentDetect.OnDelay			:= 50;		
	g_ManualInletProcess.Inputs.GarmentDetectionUp.OnDelay				:= 0;			// Filter is set to Zero sins we missed empty hangers some time
	g_ManualInletProcess.Inputs.GarmentDetectionUp.OffDelay				:= 100;
	g_ManualInletProcess.Inputs.GarmentOnInlet.OnDelay					:= 100;			// Filter is set to Zero sins we missed empty hangers some time
	g_ManualInletProcess.Inputs.GarmentOnInlet.OffDelay					:= 0;
	g_ManualInletProcess.Inputs.InletConvoyerJam.OnDelay				:= 500; 		// We wait 500 ms to regist a jam
//	g_ManualInletProcess.Inputs.SecurityCover.OnDelay					:= g_MCfg.MF_SecurityCoverOnDelay;
//	g_ManualInletProcess.Inputs.SecurityCover.OffDelay					:= g_MCfg.MF_SecurityCoverOffDelay;
	
	FOR i:=1 TO MAX_MF_KEYCOUNT DO
		g_ManualInletProcess.Inputs.StartButtons[i].OnDelay 			:= MAX (10,g_MCfg.MF.ButtonSenistivityTime ); 
		g_ManualInletProcess.Inputs.StartButtons[i].OffDelay			:= MAX (10,g_MCfg.MF.ButtonSenistivityTime ); 
	END_FOR
	
	// Outputs -Parameter
	g_ManualInletProcess.Outputs.SleeveBlastLeft.StartDelayTime			:= g_ACfg[g_ManualInletProcess.Common.Product.FoldProgram].ArmBlowDelay[1];		
	g_ManualInletProcess.Outputs.SleeveBlastLeft.OnTime					:= g_ACfg[g_ManualInletProcess.Common.Product.FoldProgram].ArmBlowOnTime[1];
	g_ManualInletProcess.Outputs.SleeveBlastRight.StartDelayTime 		:= g_ACfg[g_ManualInletProcess.Common.Product.FoldProgram].ArmBlowDelay[0];
	g_ManualInletProcess.Outputs.SleeveBlastRight.OnTime				:= g_ACfg[g_ManualInletProcess.Common.Product.FoldProgram].ArmBlowOnTime[0];
	g_ManualInletProcess.Outputs.InfeedBeltAirBlast.StartDelayTime		:= g_MCfg.MF.InfeedBeltAirBlastDelay;			
	g_ManualInletProcess.Outputs.InfeedBeltAirBlast.OnTime				:= g_MCfg.MF.InfeedBeltAirBlastOnTime; 
	g_ManualInletProcess.Outputs.InFeedBeltMotor.StartDelayTime			:= 0;		
	g_ManualInletProcess.Outputs.InFeedBeltMotor.OnTime					:= 30000; // max Run Time 
	g_ManualInletProcess.Outputs.InletBeltMotor.StartDelayTime			:= 0;		
	g_ManualInletProcess.Outputs.InletBeltMotor.OnTime					:= 30000; // max Run Time 
	g_ManualInletProcess.Outputs.InletConveyorMotor.StartDelayTime		:= 0;		
	g_ManualInletProcess.Outputs.InletConveyorMotor.OnTime				:= 3000; // max Run Time 
	g_ManualInletProcess.Outputs.InletBeltTC1Start.StartDelayTime		:= 0;		
	g_ManualInletProcess.Outputs.InletBeltTC1Start.OnTime				:= 30000; // max Run Time 
	g_ManualInletProcess.Outputs.CheckForShirt.StartDelayTime			:= g_MCfg.MF.CheckShirtDelay;
	g_ManualInletProcess.Outputs.CheckForShirt.OnTime					:= g_MCfg.MF.CheckShirtOnTime;
	g_ManualInletProcess.Outputs.Vacuum.StartDelayTime					:= g_MCfg.MF.DelayVacuum;
	g_ManualInletProcess.Outputs.Vacuum.OnTime							:= 10; // Just to trigger a raising edge..
	IF g_MCfg.MF.ReleaseInfeedBeltJamTime = 0 THEN
		g_ManualInletProcess.Outputs.ReleaseInfeedBeltJam.OnTime		:= 400;
	ELSE	
		g_ManualInletProcess.Outputs.ReleaseInfeedBeltJam.OnTime		:= g_MCfg.MF.ReleaseInfeedBeltJamTime ;
	END_IF
	
	// Timers -Parameters
	g_ManualInletProcess.Timers.ReachGarmentDetectionPH.TTime			:= g_MCfg.MF.ReachGarmentDetectPHTimeOut;
	g_ManualInletProcess.Timers.ReachInfeedBeltEndPH.TTime				:= g_MCfg.MF.ReachInfeedBeltEndPHTimeOut;
	g_ManualInletProcess.Timers.AutoStartnletBeltDelay.TTime				:= g_MCfg.MF.AutoStartnletBeltDelayTime;
	g_ManualInletProcess.Timers.JamWaitInletConv.TTime					:= g_ManualInletProcess.Outputs.InfeedBeltAirBlast.OnTime;
	
	g_ManualInletProcess.Timers.FanCleaning.TTime						:= g_MCfg.Inlet.Vaccum.FanCleaningTime;

	g_ManualInletProcess.Values.AutoStartInletBelt						:= g_MCfg.MF.AutoStartInletBelt;
	g_ManualInletProcess.Values.GarmentsBeforeCleaning					:= g_MCfg.Inlet.Vaccum.FanCleaningPieces;			
	g_ManualInletProcess.Values.IdleTime								:= 30000;							// Inlet has been idle, Index stack at Holbaek
	g_ManualInletProcess.Values.JamAtInletConvoyerLimit					:= 2; 
	HangerNoReadMax														:= g_MCfg.Inlet.NoReadAlarm;
	g_HangerInletProcess.AutoSelectColor								:= g_ManualInletProcess.Values.AutoSelectColor;

	(*------------------------------------------------------------------------------------------------*)
	(*------------------------------ CALL INPUTS 			------------------------------------------*)
	(*------------------------------------------------------------------------------------------------*)
	RunIOCounter(g_ManualInletProcess.Inputs.ShirtDetect				, g_ManualInletProcess.Common.CurTimer);
	RunIOCounter(g_ManualInletProcess.Inputs.GarmentDetectionUp			, g_ManualInletProcess.Common.CurTimer);
	RunIOCounter(g_ManualInletProcess.Inputs.GarmentOnInlet				, g_ManualInletProcess.Common.CurTimer);
	RunIOCounter(g_ManualInletProcess.Inputs.ReachedInfeedBeltEnd		, g_ManualInletProcess.Common.CurTimer);
	RunIOCounter(g_ManualInletProcess.Inputs.InletConvoyerJam			, g_ManualInletProcess.Common.CurTimer);
//	RunIOCounter(g_ManualInletProcess.Inputs.SecurityCover				, g_ManualInletProcess.Common.CurTimer);
	
	FOR i:=1 TO MAX_MF_KEYCOUNT DO
		RunIOCounter(g_ManualInletProcess.Inputs.StartButtons[i]		, g_ManualInletProcess.Common.CurTimer);
	END_FOR;



	(*------------------------------------------------------------------------------------------------*)
	(*------------------------------ LOGIC IMPLEMENTATION 	------------------------------------------*)
	(*------------------------------------------------------------------------------------------------*)

	(*WM Get Selected Feeding Button on Inlet *)
	IF (g_ManualInletProcess.Inputs.GarmentOnInlet.Output OR g_ManualInletProcess.Inputs.GarmentDetectionUp.Output) AND EDGEPOS(ISCustomerChange) THEN	// added GarmentDetectionUp to have larger window to detect stack change 
		PreStackChange := ManPreStackChange := TRUE;// NOT ManPreStackChange;
		// 		OldStackChangeIndex := StackChangeIndex;
		//		StackChangeIndex := StackChangeIndex + 1;
		//		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'M_Inlet Customer Changed');
	END_IF
	
	IF EDGEPOS(g_ManualInletProcess.Inputs.GarmentOnInlet.Output) THEN
		g_ManualInletProcess.Values.SelectedStacker 	:= 0;
		g_ManualInletProcess.Timers.AutoStartnletBeltDelay.Timer := g_ManualInletProcess.Common.CurTimer; 		// To control the delay of AutoInletBeltStart in state_20 MKH
	END_IF
		
	
	g_ManualInletProcess.Values.StartInletButton := FALSE; 
	FOR i:= 1 TO MAX_MF_KEYCOUNT DO
		IF (((g_ManualInletProcess.Common.State = 20) OR (g_ManualInletProcess.Common.State = 42)) AND (NOT BlockStartBTN) AND (g_ManualInletProcess.Inputs.GarmentOnInlet.Output)) THEN
			IF g_ManualInletProcess.Inputs.StartButtons[i].Output AND ( i <= g_HCfg.NumberOfButtonsMF ) THEN 		// JEDK FIX -- PMU 30.11.12 Issue #126: Start buttons starting the inlet on different edges
				//PreStackChange := FALSE;
				g_ManualInletProcess.Values.StartInletButton := TRUE; 
				IF (g_HCfg.HangerReading = 0) OR (g_HangerInletProcess.ForcedNoCom >= 1) AND (i <= g_HCfg.NumberOfButtonsMF) THEN
					g_ManualInletProcess.Values.SelectedProg 		:= g_MCfg.MF.KeyConfig[i].KeyProgIndex; 
				ELSIF (g_HCfg.HangerReading = 8) OR (g_HangerInletProcess.ForcedNoCom = 0) THEN
					IF (g_ManualInletProcess.Common.State = 42) AND (g_ExternalCom.Recipe = 0) THEN
						g_ManualInletProcess.Common.Product.FoldProgram := g_MCfg.MF.KeyConfig[i].KeyProgIndex;
						g_AutoProgram.SelectedAutoProgram				:= g_MCfg.MF.KeyConfig[i].KeyProgIndex;
					END_IF
				END_IF
				BlockStartBTN := TRUE;
			ELSIF g_ManualInletProcess.Inputs.StartButtons[i].Output AND (i > g_HCfg.NumberOfButtonsMF) THEN
				g_ManualInletProcess.Values.SelectedProg		:= g_MCfg.MF.KeyConfig[1].KeyProgIndex;// On this machine, always select autoprg. from Key_1
				g_ManualInletProcess.Values.SelectedStacker 	:= g_MCfg.MF.KeyConfig[i].KeyStackIndex;
				BlockStartBTN := TRUE;
				g_ManualInletProcess.Values.StartInletButton := TRUE;
			END_IF;
		END_IF
	END_FOR;
	IF g_ManualInletProcess.Values.AutoStartInletBelt THEN
		// Assume last Prog if Auto Feed Prog is Null
		IF g_MCfg.MF.KeyProgIndex = 0 THEN
			g_MCfg.MF.KeyProgIndex := g_ManualInletProcess.Values.SelectedProg;
		END_IF;
		g_ManualInletProcess.Values.SelectedProg 		:= g_MCfg.MF.KeyProgIndex   ; 
		g_ManualInletProcess.Values.SelectedStacker 	:= g_MCfg.MF.KeyStackIndex  ; 	
	END_IF
	


	(*Default if no Prog Set for manual keys*)
	IF g_ManualInletProcess.Values.SelectedProg <1 THEN
		g_ManualInletProcess.Values.SelectedProg:= 1; 
	END_IF;
	(*Change Auto Prog No*)
	(* Prevent overwritting Autoprogram if Metricon connection is enabled *) //MKH
	IF (g_HangerInletProcess.ForcedNoCom <> 0) OR (g_HCfg.HangerReading = 0 )THEN
		g_AutoProgram.SelectedAutoProgram			:= g_ManualInletProcess.Values.SelectedProg;
		g_AutoProgram.OperatorAutoProgram			:= g_AutoProgram.SelectedAutoProgram;
	END_IF
	
	(*#######################*)
	(* Force No com handling *)
	(*#######################*)
	
	IF g_HangerInletProcess.ForcedNoCom = 0 THEN							// No force com
		g_HangerInletProcess.HangerReading			:= g_HCfg.HangerReading;
		g_ManualInletProcess.Values.HangerReading 	:= g_HCfg.HangerReading;
	ELSIF g_HangerInletProcess.ForcedNoCom >= 1 THEN						// Forced No com
		g_HangerInletProcess.HangerReading			:= 0;
		g_ManualInletProcess.Values.HangerReading	:= 0;			
	END_IF
	
	//	(*Test : Ignore Timeout*)
	g_ManualInletProcess.Common.WatchDogRunTimer 			:= g_ManualInletProcess.Common.CurTimer;			// start watchdog timer for process 
	
	IF (g_ManualInletProcess.Common.State > 22) AND (g_ManualInletProcess.Common.State < 26) THEN
		IF g_ManualInletProcess.Common.Next.TransferStatus = EXC_STANDBY_0 THEN
			g_ManualInletProcess.Common.Next.TransferStatus 	:= EXC_WANT_TO_UNLOAD_1;
		END_IF
	END_IF

	(*------------------------------------------------------------------------------------------------*)
	(*------------------------------ PROCESS  STEPS 		------------------------------------------*)
	(*------------------------------------------------------------------------------------------------*)
	RunFoldTask(g_MCfg.Trace2File, ADR(T2FD), g_ManualInletProcess.Common, g_MachineManager[g_ManualInletProcess.Common.MachineManagerIndex]);

	CASE g_ManualInletProcess.Common.State OF

		(*####################################*)
		(* Start Up Machine, Home Axels etc.. *)
		(*####################################*)

		MACHPROC_STARTUP_1:

			(* Do something  *)
			g_ManualInletProcess.Common.Previous.TransferStatus 	:= EXC_STANDBY_0;
			g_ManualInletProcess.Common.Next.TransferStatus			:= EXC_STANDBY_0;
			//	g_ManualInletProcess.Common.WatchDogRunTimer 			:= g_ManualInletProcess.Common.CurTimer;			// start watchdog timer for process 
			// Default Garment Length
			g_ManualInletProcess.Values.GarmentLenght  					:= 0;
			// Pass To next Step 		
			g_ManualInletProcess.Common.State 						:= MACHPROC_STARTUP_2;	

		MACHPROC_STARTUP_2:
			(*Do nothing*)
			g_ManualInletProcess.Common.State 						:= MACHPROC_RUN_20;	
			//			g_ManualInletProcess.Common.WatchDogRunTimer 			:= g_ManualInletProcess.Common.CurTimer;			// start watchdog timer for process 

		
			(*###############################################################*)
			(* Machine Stop case, to handle shut down process of the module  *)
			(*###############################################################*)

		MACHPROC_STOP_15:
			;
			(* Reset output and handle the shutdown procedure *)
			(* Extra stop cases may be needed.. *)
			g_ManualInletProcess.Common.State 						:= MACHPROC_INIT_0;
			g_ManualInletProcess.Common.FoldUnit1.State				:= 0;
			g_ManualInletProcess.Common.FoldUnit2.State				:= 0;
			g_ManualInletProcess.Common.Motor.cmdStop				:= TRUE;
			g_ManualInletProcess.Outputs.SleeveBlastRight.State		:= FOLDIO_STATE_IDLE_0;
			g_ManualInletProcess.Outputs.SleeveBlastLeft.State		:= FOLDIO_STATE_IDLE_0;
			g_ManualInletProcess.Timers.DelayStart.Timer 			:= 0;						// Reset this timer when machine is stopped... 
			g_ManualInletProcess.Outputs.InletConveyorMotor.State	:= FOLDIO_STATE_IDLE_0;
			g_ManualInletProcess.Values.GarmentLenght  				:= 0;
			g_ManualInletProcess.Outputs.InfeedBeltAirBlast.State	:= FOLDIO_STATE_IDLE_0;	
			

			(*#####################*)
			(* Main running state  *)
			(*#####################*)


		MACHPROC_RUN_20:
			
			BlockStartBTN := FALSE;
			g_ManualInletProcess.Values.GarmentLenght := 0;
			
			g_ManualInletProcess.Outputs.InletConveyorMotor.State := FOLDIO_STATE_IDLE_0;
			g_ManualInletProcess.Outputs.InletBeltMotor.State := FOLDIO_STATE_IDLE_0;
			g_ManualInletProcess.Outputs.InFeedBeltMotor.State := FOLDIO_STATE_IDLE_0;

			(* Garment in place and Top Convoyer is ready *)
			(* We also check the lenght of the previous garment to se if we should start or not... *)
			IF g_ManualInletProcess.Inputs.GarmentOnInlet.Output AND (g_ManualInletProcess.Values.GarmentLenght < 20) 
				AND g_ManualInletProcess.Values.StopFeedingStatus = 1 AND NOT g_Core.System.Interface.alarms.isLowAirPressure THEN		// Stop feeding not activated...

				LinenID := LinenID + 1;
				IF LinenID = 0 THEN
					LinenID := LinenID + 1;
				END_IF
				g_ManualInletProcess.Common.Product.ID := LinenID;
				g_ManualInletProcess.Common.Product.NoRead := FALSE;

				IF g_ManualInletProcess.Timers.DelayStart.Timer = 0 THEN
					g_ManualInletProcess.Timers.DelayStart.Timer 				:= g_ManualInletProcess.Common.CurTimer;
				END_IF			
				// No hanger reading or Diseabled or Just full signals communication...
				IF (g_ManualInletProcess.Values.HangerReading = 0) OR (g_ManualInletProcess.Values.ForcedNoCom = 1) OR (g_MCfg.Metricon.DataExchangeMode = DATA_EX_ONLY_FULL_IO_3) THEN			
					g_ManualInletProcess.Common.Product.FoldProgram 	:= g_AutoProgram.SelectedAutoProgram;		
					g_ManualInletProcess.Common.Product.BatchId	 		:= g_BatchId;
					g_ManualInletProcess.Common.Product.Article	 		:= g_ArticleNumber := g_ArticleNumber + 1 ;
					g_ManualInletProcess.Common.Product.Stack			:= g_ManualInletProcess.Values.SelectedStacker;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'M_Inlet Feed hanger');
					// Set yellow color for hanger manual selection..
					g_ManualInletProcess.Values.AutoSelectColor				:= 46;		// Yellow...	
					g_HangerInletProcess.AutoSelectColor					:= 46;	
					g_ManualInletProcess.Timers.RestartInletConvDelay.Timer	:= g_ManualInletProcess.Common.CurTimer;
					//					g_ManualInletProcess.Timers.AutoStartnletBeltDelay.Timer := g_ManualInletProcess.Common.CurTimer;
					
					IF NOT g_ManualInletProcess.Inputs.ReachedInfeedBeltEnd.Output THEN
						//						IF (EDGENEG (g_ManualInletProcess.Values.StartInletButton) OR g_ManualInletProcess.Values.AutoStartInletBelt ) THEN 
						IF (EDGENEG (g_ManualInletProcess.Values.StartInletButton) OR (g_ManualInletProcess.Values.AutoStartInletBelt AND 
							ElapsedMsTime(g_ManualInletProcess.Common.CurTimer, g_ManualInletProcess.Timers.AutoStartnletBeltDelay.Timer ) >= g_ManualInletProcess.Timers.AutoStartnletBeltDelay.TTime) ) 
							AND NOT g_DuoInletProcess.BlockNormalInlet THEN // to give more time to operator to change stacker when AutoInletBelt is used // + DUO only block
							IF (NOT g_ManualInletProcess.Inputs.GarmentDetectionUp.Output) THEN
								(*-- Moved to State 24 --*)
								//IF PreStackChange THEN
								//									g_ManualInletProcess.Common.Product.PreStackChange	:= TRUE;
								//									StackChangeIndex := StackChangeIndex + 1;
								//									g_ManualInletProcess.Common.Product.StackChangeIndex := StackChangeIndex;
								//									IF ManPreStackChange THEN
								//		 								LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'M_Inlet Customer Changed');
								//										ManPreStackChange								:= FALSE;
								//									END_IF
								//		 							PreStackChange 										:= FALSE;
								//								ELSE
								//									g_ManualInletProcess.Common.Product.PreStackChange	:= FALSE;
								//								END_IF																	
								// We start the Inlet convoyer immedietely to give inlet time to get target velocity							
								g_ManualInletProcess.Outputs.InletConveyorMotor.State 	:= FOLDIO_STATE_START_1;							
								g_ManualInletProcess.Common.State 						:= MACHPROC_START_INLET_DELAY_22;
								g_ManualInletProcess.Common.Product.ProductType			:= TROUSER_TYPE_0;											// Default every garment is a Trouser 
								// Open window for Shirt/Trouser detection
								IF (NOT g_ManualInletProcess.Values.AutoStartInletBelt) THEN 
									g_ManualInletProcess.Outputs.CheckForShirt.State 		:= FOLDIO_STATE_START_1;
								END_IF
							
							ELSE 
								g_ManualInletProcess.Common.ErrorCode 	:= 7; 							
								g_ManualInletProcess.Common.State 		:= MACHPROC_TRIG_ERROR_98;
							
							END_IF
							
						END_IF;
					ELSE
						IF EDGENEG (g_ManualInletProcess.Values.StartInletButton) AND (g_ManualInletProcess.Common.Next.TransferStatus = EXC_STANDBY_0) THEN
							g_ManualInletProcess.Common.ErrorCode := 8; 							
							g_ManualInletProcess.Common.State 		:= MACHPROC_TRIG_ERROR_98;
						END_IF						
					END_IF;
				ELSIF (g_ManualInletProcess.Values.HangerReading = 8) AND (g_ManualInletProcess.Values.ForcedNoCom = 0) THEN		// Hanger reading with data exchange 	
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'H_Inlet Wait hanger data');
					g_ManualInletProcess.Common.State 					:= MACHPROC_WAIT_READ_40;
				END_IF	
			END_IF
			
		MACHPROC_WAIT_READ_40:
		
			// Trigger a request to Metricon for hanger data...
			IF g_ExternalCom.ConnectionType = CONNECTION_TYPE_BCD_4 THEN
				BCD_Conntection					:= 0;
				g_HangerInletProcess.Common.Product.NoRead	:= FALSE;
			END_IF		 
			g_ExternalCom.HangerState 			:= EXTERN_HANGER_REQUEST_1;
			g_LogInletHanger.HType				:= LOG_TYPE_HANGER_REGUEST_1;
			g_LogInletHanger.Article 			:= 0;
			g_LogInletHanger.Customer			:= 0;
			g_LogInletHanger.Destination		:= 0;
			g_LogInletHanger.HangerIdStr		:= '';
			g_LogInletHanger.Program			:= 0;
			g_LogInletHanger.StackChange		:= 0;	
			g_LogInletHanger.DoLog				:= TRUE;							// Write data to logrecord...
			HangerNoRead 						:= HangerNoRead + 1;				// Always increase this counter is cleared if OK read...
			g_ManualInletProcess.Common.State	:= MACHPROC_WAIT_DATA_41;

			ReadErrorTimer := g_ManualInletProcess.Common.CurTimer;

		MACHPROC_WAIT_DATA_41:
		
		
			(* Hand shake with Metricon... *)
			IF (g_ExternalCom.HangerState = EXTERN_HANGER_WAIT_2) AND (g_ManualInletProcess.Values.ForcedNoCom <> 2) THEN
				; (* External search in progress *)
			ELSIF g_ExternalCom.HangerState = EXTERN_HANGER_FOUND_6 THEN
				// Set green color for hanger OK
				//			g_ManualInletProcess.Values.AutoSelectColor			:= 10;		// Green...

				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'H_Inlet Data OK');
				//			IF (g_ExternalCom.Recipe < 1) OR (g_ExternalCom.Recipe > 99) THEN
				//   				g_ManualInletProcess.Common.Product.FoldProgram := 1;	
				//				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'H_I, Bad fold program');
				//			ELSE
				//				g_ManualInletProcess.Common.Product.FoldProgram := g_ExternalCom.Recipe;	
				//			END_IF	
				IF g_MCfg.Metricon.DataExchangeMode = DATA_EX_ONLY_STACKCHANGE_4 THEN
					g_ManualInletProcess.Common.Product.FoldProgram := g_AutoProgram.SelectedAutoProgram;
				ELSE
					IF (g_ExternalCom.Recipe < 1) OR (g_ExternalCom.Recipe > 99) THEN
						g_ManualInletProcess.Common.Product.FoldProgram := 1;	
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'H_Inlet, Bad fold program');
					ELSE
						g_ManualInletProcess.Common.Product.FoldProgram := g_ExternalCom.Recipe;
					END_IF	
				END_IF
				// Full data exchange		
				IF (g_MCfg.Metricon.ComMode <> 4) AND g_MCfg.Metricon.DataExchangeMode = DATA_EX_FULL_0 THEN
					g_ManualInletProcess.Common.Product.BatchId	 	:= UDINT_TO_UINT(g_ExternalCom.CustomerId);
					g_ManualInletProcess.Common.Product.Customer	:= UDINT_TO_UINT(g_ExternalCom.CustomerId);
					g_ManualInletProcess.Common.Product.Article	 	:= g_ExternalCom.ArticleId;
					g_ManualInletProcess.Common.Product.Stack		:= g_ExternalCom.Destination;		// To wich stacker 
					// Change Auto program on Main screen...
					g_AutoProgram.SelectedAutoProgram 				:= g_ExternalCom.Recipe;	 
					// Auto program and No stack destination	
				ELSIF (g_MCfg.Metricon.ComMode <> 4) AND g_MCfg.Metricon.DataExchangeMode = DATA_EX_AUTO_1 THEN
					g_ManualInletProcess.Common.Product.BatchId	 	:= UDINT_TO_UINT(g_ExternalCom.CustomerId);
					g_ManualInletProcess.Common.Product.Customer	:= UDINT_TO_UINT(g_ExternalCom.CustomerId);
					g_ManualInletProcess.Common.Product.Article	 	:= g_ExternalCom.ArticleId;
					g_ManualInletProcess.Common.Product.Stack		:= 0;		// To wich stacker 
					// Change Auto program on Main screen...
					g_AutoProgram.SelectedAutoProgram 				:= g_ExternalCom.Recipe;
				ELSIF g_MCfg.Metricon.ComMode = 4 THEN //AND (g_MCfg.Metricon.DataExchangeMode = DATA_EX_AUTO_1 OR g_MCfg.Metricon.DataExchangeMode = DATA_EX_AUTO_STACKCHANGE_2) THEN
					IF (g_ExternalCom.Recipe < 1) OR (g_ExternalCom.Recipe > 99) THEN
						g_HangerInletProcess.ExternalRecipe		:= 1;
					ELSE
						g_HangerInletProcess.ExternalRecipe		:= g_ExternalCom.Recipe;
					END_IF
					g_HangerInletProcess.Common.Product.Stack	:= 0;		// To wich stacker	 
				END_IF
					
				// Make strings of HangerId data...
				DataMakeStr(g_ExternalCom.HangerId, ADR(g_ManualInletProcess.Common.Product.HangerId));
				DataMakeStr(g_ExternalCom.GarmentId, ADR(g_ManualInletProcess.Common.Product.GarmentId));
		
				HangerNoRead := 0;		// Clear counter every time we get a OK reading	
			
				// Set green color for hanger OK
				g_HangerInletProcess.AutoSelectColor			:= 10;		// Green...						
				g_ManualInletProcess.Values.AutoSelectColor		:= 10;
			
				// Make a stack change if AutoProgram change / and stack change on Fold program... 10-01-28..
				IF g_MCfg.Outlet.StackChangeMode = OUTLET_STACK_CHANGE_FOLDPROG_1 THEN
					IF g_AutoProgram.SelectedAutoProgram <> OldAutoProgram THEN
						StackChangeIndex := StackChangeIndex + 1;
						g_ManualInletProcess.Common.Product.StackChangeIndex := StackChangeIndex;
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'H_Inlet Stack change A-P Changed');
					END_IF
				END_IF
				//OldAutoProgram := g_AutoProgram.SelectedAutoProgram;			
						
				// Stack change...
				//			IF (g_MCfg.Metricon.DataExchangeMode = DATA_EX_FULL_0) OR (g_MCfg.Metricon.DataExchangeMode = DATA_EX_AUTO_STACKCHANGE_2) THEN
				//				IF ((g_ExternalCom.StackChange = 0) AND (g_MCfg.Outlet.ZeroValueStackChange = 0)) OR ((g_ExternalCom.StackChange < 0) AND (g_MCfg.Outlet.ZeroValueStackChange = 1)) THEN
				//					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'H_Inlet No Stack change');
				//					;	// No stack change do nothing
				//				//ELSIF (g_ExternalCom.StackChange > 0) THEN
				//				ELSIF (g_ExternalCom.StackChange > 0) OR ((g_MCfg.Outlet.ZeroValueStackChange = 1) AND (g_ExternalCom.StackChange >= 0))  THEN					
				//					// To give a Stack index number to the garments, if the stack change garment is lost in the folder...			
				//					StackChangeIndex := StackChangeIndex + 1;
				//					// Take care on high stack numbers...
				//					g_ManualInletProcess.Common.Product.StackChangeIndex := StackChangeIndex;
				//					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'H_Inlet Stack change triggerd');
				//				END_IF
				//			END_IF
				/////
				IF ((g_MCfg.Metricon.DataExchangeMode = DATA_EX_FULL_0) OR (g_MCfg.Metricon.DataExchangeMode = DATA_EX_ONLY_STACKCHANGE_4)
					OR (g_MCfg.Metricon.DataExchangeMode = DATA_EX_AUTO_STACKCHANGE_2)) AND (g_MCfg.Outlet.StackChangeMode <> OUTLET_STACK_CHANGE_RESET_4) THEN
					IF ((g_ExternalCom.StackChange = 0) AND (g_MCfg.Outlet.ZeroValueStackChange = 0)) OR ((g_ExternalCom.StackChange < 0) AND (g_MCfg.Outlet.ZeroValueStackChange = 1)) THEN
						IF g_MCfg.Outlet.StackChangeMode = OUTLET_STACK_CHANGE_MET_FPROG_5 THEN
							IF g_AutoProgram.SelectedAutoProgram <> OldAutoProgram THEN
								StackChangeIndex := StackChangeIndex + 1;
								g_HangerInletProcess.Common.Product.StackChangeIndex := StackChangeIndex;
								LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_DummyPulses, 'H_Inlet Stack change A-P Changed');
							END_IF
						ELSE						
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'H_Inlet No Stack change');
							;	// No stack change do nothing
						END_IF
						//ELSIF (g_ExternalCom.StackChange > 0) THEN
					ELSIF (g_ExternalCom.StackChange > 0) OR ((g_MCfg.Outlet.ZeroValueStackChange = 1) AND (g_ExternalCom.StackChange >= 0)) THEN
						// To give a Stack index number to the garments, if the stack change garment is lost in the folder...			
						StackChangeIndex := StackChangeIndex + 1;
						// Take care on high stack numbers...
						g_ManualInletProcess.Common.Product.StackChangeIndex := StackChangeIndex;
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_DummyPulses, 'H_Inlet Stack change triggerd');
					END_IF

				END_IF			
				/////		
				OldAutoProgram := g_AutoProgram.SelectedAutoProgram;			
				// Counter on Inlet service page							
				g_ManualInletProcess.NoReadCount				:= 0;		// Reset counter...	
				g_ManualInletProcess.DiagCounters.HangerReadOK	:= g_ManualInletProcess.DiagCounters.HangerReadOK + 1;
			
			
				// Log data	
				g_LogInletHanger.HType					:= LOG_TYPE_HANGER_FOUND_6;
				g_LogInletHanger.Article 				:= g_ExternalCom.ArticleId;
				g_LogInletHanger.Customer				:= g_ExternalCom.CustomerId;
				g_LogInletHanger.Destination			:= g_ExternalCom.Destination;
				DataMakeStr(g_ExternalCom.HangerId, ADR(g_LogInletHanger.HangerIdStr));
				g_LogInletHanger.Program				:= g_ExternalCom.Recipe;
				g_LogInletHanger.StackChange			:= g_ExternalCom.StackChange;	
				g_LogInletHanger.DoLog					:= TRUE;							// Write data to logrecord...
					
			
				IF g_ExternalCom.ArticleId > 0 THEN
					g_ArticleNumber := g_ExternalCom.ArticleId;
				END_IF
				IF g_ExternalCom.CustomerId > 0 THEN
					g_CustomerNumber := g_ExternalCom.CustomerId;
				END_IF			
				
				g_ManualInletProcess.Common.State 				:= MACHPROC_DELAY_START_42;	
		
		
			ELSIF (g_ExternalCom.HangerState = EXTERN_HANGER_FAIL_9) OR (g_ManualInletProcess.Values.ForcedNoCom = 2) THEN	
			
				IF (HangerNoRead < HangerNoReadMax) THEN 
					HangerNoRead := HangerNoRead + 1;
					//				IF g_ExternalCom.MetricHangerReadStatus = HANGER_READ_STATE_NO_READ THEN
					//					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'H_I, No read');
					//					g_ManualInletProcess.NoReadCount 			:= g_ManualInletProcess.NoReadCount + 1;
					//					g_ManualInletProcess.DiagCounters.NoRead	:= g_ManualInletProcess.DiagCounters.NoRead + 1;
					//				ELSIF g_ExternalCom.MetricHangerReadStatus = HANGER_READ_STATE_NO_DATA THEN
					//					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'H_I, No Data');
					//					g_ManualInletProcess.DiagCounters.NoData	:= g_ManualInletProcess.DiagCounters.NoData + 1;
					//				END_IF
					IF g_ExternalCom.MetricHangerReadStatus = HANGER_READ_STATE_NO_READ THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'H_I, No read');
						g_ManualInletProcess.NoReadCount 			:= g_ManualInletProcess.NoReadCount + 1;
						g_ManualInletProcess.DiagCounters.NoRead	:= g_ManualInletProcess.DiagCounters.NoRead + 1;
					ELSIF g_ExternalCom.MetricHangerReadStatus = HANGER_READ_STATE_NO_DATA OR (g_ExternalCom.ConnectionType = CONNECTION_TYPE_BCD_4) THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'H_I, No Data');
						g_ManualInletProcess.DiagCounters.NoData	:= g_ManualInletProcess.DiagCounters.NoData + 1;
					END_IF	
				
					// Set red color for hanger NOT OK
					g_ManualInletProcess.Values.AutoSelectColor			:= 51;	// Red...
					g_HangerInletProcess.AutoSelectColor				:= 51;
					g_ManualInletProcess.Common.Product.NoRead			:= TRUE;
					IF g_ExternalCom.ConnectionType = CONNECTION_TYPE_BCD_4 THEN
						//g_HangerInletProcess.Common.Product.FoldProgram 	:= g_MCfg.Metricon.AutoProgramUfo;					
						//g_ExternalCom.Recipe								:= g_HangerInletProcess.Common.Product.FoldProgram;
						//g_AutoProgram.OperatorAutoProgram					:= OldAutoProgram;
						g_ManualInletProcess.Common.Product.FoldProgram 	:= g_AutoProgram.SelectedAutoProgram; //OldAutoProgram;								
						g_ManualInletProcess.Common.Product.Stack			:= 0;
						StackChangeIndex 									:= StackChangeIndex + 1;
						g_ManualInletProcess.Common.Product.StackChangeIndex := StackChangeIndex;				// Trigger stack change on ufo hangers
						//					g_LogInletHanger.HType								:= LOG_TYPE_NODATA_FORCED_66;
						//					g_LogInletHanger.Article 							:= g_ExternalCom.ArticleId;
						//					g_LogInletHanger.Customer							:= g_ExternalCom.CustomerId;
						//					g_LogInletHanger.Destination						:= g_ExternalCom.Destination;
						//					DataMakeStr(g_ExternalCom.HangerId, ADR(g_LogInletHanger.HangerIdStr));
						//					g_LogInletHanger.Program							:= g_ExternalCom.Ethernet.GarmentData.Program;
						//					g_LogInletHanger.StackChange						:= 1;	
						//					g_LogInletHanger.DoLog								:= TRUE;	
						g_ManualInletProcess.Common.State 					:= MACHPROC_DELAY_START_42;			
					ELSE										
						// We got default data from Metricon
						g_ManualInletProcess.Common.Product.FoldProgram 	:= g_MCfg.Metricon.AutoProgramUfo;					
						g_ExternalCom.Recipe								:= g_ManualInletProcess.Common.Product.FoldProgram;
						g_ManualInletProcess.Common.Product.Stack			:= g_HCfg.NumberOfStackers;		// To wich stacker 09-11-24
						StackChangeIndex 									:= StackChangeIndex + 1;
						g_ManualInletProcess.Common.Product.StackChangeIndex := StackChangeIndex;				// Trigger stack change on ufo hangers
						g_LogInletHanger.HType								:= LOG_TYPE_NODATA_FORCED_66;
						g_LogInletHanger.Article 							:= g_ExternalCom.ArticleId;
						g_LogInletHanger.Customer							:= g_ExternalCom.CustomerId;
						g_LogInletHanger.Destination						:= g_ExternalCom.Destination;
						DataMakeStr(g_ExternalCom.HangerId, ADR(g_LogInletHanger.HangerIdStr));
						g_LogInletHanger.Program							:= g_Core.Services.Communication.ConnectionHandler.FoldXML.Runtime.connection[0].data.GarmentData.Program;
						g_LogInletHanger.StackChange						:= 1;	
						g_LogInletHanger.DoLog								:= TRUE;							// Write data to logrecord...	
						g_ManualInletProcess.Common.State 					:= MACHPROC_DELAY_START_42;
					END_IF
				ELSIF HangerNoRead >= HangerNoReadMax THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_DummyPulses, 'H_Inlet, Hanger max read error');
					g_ManualInletProcess.Common.ErrorCode 				:= 13;			// Hanger read error... 
					g_ManualInletProcess.Common.State 					:= MACHPROC_TRIG_ERROR_98;

				END_IF				
			END_IF
		

		
			g_ManualInletProcess.Common.WatchDogRunTimer := g_ManualInletProcess.Common.CurTimer;

		MACHPROC_DELAY_START_42:
		
			// Start after receiving data...			
			g_ManualInletProcess.Timers.RestartInletConvDelay.Timer		:= g_ManualInletProcess.Common.CurTimer;
			g_ManualInletProcess.Timers.AutoStartnletBeltDelay.Timer	:= g_ManualInletProcess.Common.CurTimer;
					
			IF NOT g_ManualInletProcess.Inputs.ReachedInfeedBeltEnd.Output THEN

				IF (EDGENEG (g_ManualInletProcess.Values.StartInletButton) OR g_ManualInletProcess.Values.AutoStartInletBelt) THEN
					IF (NOT g_ManualInletProcess.Inputs.GarmentDetectionUp.Output) THEN
						g_AutoProgram.OperatorAutoProgram 						:= g_AutoProgram.SelectedAutoProgram;
						g_ManualInletProcess.ManualInletStarted					:= TRUE;
						// We start the Inlet convoyer immedietely to give inlet time to get target velocity							
						g_ManualInletProcess.Outputs.InletConveyorMotor.State 	:= FOLDIO_STATE_START_1;							
						g_ManualInletProcess.Common.State 						:= MACHPROC_START_INLET_DELAY_22;
						g_ManualInletProcess.Common.Product.ProductType			:= TROUSER_TYPE_0;											// Default every garment is a Trouser 
						// Open window for Shirt/Trouser detection 
						IF (NOT g_ManualInletProcess.Values.AutoStartInletBelt) THEN 
							g_ManualInletProcess.Outputs.CheckForShirt.State 		:= FOLDIO_STATE_START_1;
						END_IF
						//								IF (g_HCfg.HangerReading = 8) AND NOT (g_ExternalCom.HangerState = EXTERN_HANGER_FAIL_9) THEN
						g_ExternalCom.HangerState := EXTERN_HANGER_AWAY_3;// Always send "Hanger Away" at this point.
						//								END_IF							
							
					ELSE 
						g_ExternalCom.HangerState := EXTERN_HANGER_AWAY_3; //22-03-2018 PWC: Also send "Hanger Away" when we have a Jam, to avoid "Double Hanger" in Metricon.
						g_ManualInletProcess.Common.ErrorCode 	:= 7; 							
						g_ManualInletProcess.Common.State 		:= MACHPROC_TRIG_ERROR_98;							
					END_IF
				END_IF	
			END_IF

			// Restart again 
		MACHPROC_START_INLET_DELAY_22:
							
			IF ElapsedMsTime(g_ManualInletProcess.Common.CurTimer, g_ManualInletProcess.Timers.RestartInletConvDelay.Timer) >= g_ManualInletProcess.Timers.RestartInletConvDelay.TTime THEN				
				// Wait also if Garment is taken automatically 
				IF (g_ManualInletProcess.Values.AutoStartInletBelt AND 
					ElapsedMsTime(g_ManualInletProcess.Common.CurTimer, g_ManualInletProcess.Timers.AutoStartnletBeltDelay.Timer ) >= g_ManualInletProcess.Timers.AutoStartnletBeltDelay.TTime) OR 
					NOT g_ManualInletProcess.Values.AutoStartInletBelt	THEN
						
					g_ManualInletProcess.ManualInletStarted					:= FALSE;				
												
					IF (g_ManualInletProcess.Common.Next.TransferStatus = EXC_RECIVING_DONE_6) OR (g_ManualInletProcess.Common.Next.TransferStatus = EXC_STANDBY_0) THEN			(* Garment has left the inlet belt.. *)
						g_ManualInletProcess.Common.Next.TransferStatus 	:= EXC_STANDBY_0;
						IF g_ManualInletProcess.Values.AutoStartInletBelt THEN 
							g_ManualInletProcess.Outputs.CheckForShirt.State 		:= FOLDIO_STATE_START_1;
						END_IF						
						g_ManualInletProcess.Outputs.InletBeltMotor.State 	:= FOLDIO_STATE_START_1;
						g_ManualInletProcess.Timers.InletConveyor.Timer		:= g_ManualInletProcess.Common.CurTimer;
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'M_Inlet, wait start');
						g_ManualInletProcess.Outputs.Vacuum.State			:= FOLDIO_STATE_START_1;
							
						g_ManualInletProcess.Timers.ReachGarmentDetectionPH.Timer 	:= g_ManualInletProcess.Common.CurTimer;
						g_ManualInletProcess.Common.State 					:= MACHPROC_START_SLEAVEBLAST_24;
					END_IF
				END_IF
			END_IF
			(*Alarm if a garment stuck in the infeed Belt*)
			IF g_ManualInletProcess.Inputs.InletConvoyerJam.Output THEN
				g_ManualInletProcess.Common.ErrorCode 	:= 8; // Jam at infeed belt
				g_ManualInletProcess.Common.State 		:= MACHPROC_TRIG_ERROR_98;
			END_IF;

			(*Wait untill Garment covered the Upper PH = X_GarmentDetection*)
		MACHPROC_START_SLEAVEBLAST_24:

			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'M_Inlet, wait Garment detection PH ');
			// Handle TimeOut Error if Garment did not reached the Upper PH within time 
			IF ElapsedMsTime(g_ManualInletProcess.Common.CurTimer, g_ManualInletProcess.Timers.ReachGarmentDetectionPH.Timer ) >= g_ManualInletProcess.Timers.ReachGarmentDetectionPH.TTime THEN
				// Error : Garment was not detected by PH Garment_Detection 
				g_ManualInletProcess.Common.ErrorCode 	:= 5; 
				g_ManualInletProcess.Common.State 		:= MACHPROC_TRIG_ERROR_98;
			ELSE			
				// Garment passes the photocell
				IF g_ManualInletProcess.Inputs.GarmentDetectionUp.Output THEN
					(*----Moved from state 20 so AutoStartnletBeltDelay.Time can have effect on stack change triggered manually by operator--MKH 28.3.19--*)
					IF PreStackChange THEN
						g_ManualInletProcess.Common.Product.PreStackChange	:= TRUE;
						StackChangeIndex := StackChangeIndex + 1;
						g_ManualInletProcess.Common.Product.StackChangeIndex := StackChangeIndex;
						IF ManPreStackChange THEN
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'M_Inlet Customer Changed');
							ManPreStackChange								:= FALSE;
						END_IF
						PreStackChange 										:= FALSE;
					ELSE
						g_ManualInletProcess.Common.Product.PreStackChange	:= FALSE;
					END_IF	
					(*--------*)			
					g_ManualInletProcess.Outputs.InletBeltMotor.State 			:= FOLDIO_STATE_START_1;
					g_ManualInletProcess.Outputs.InFeedBeltMotor.State 			:= FOLDIO_STATE_START_1;

					g_ManualInletProcess.Outputs.SleeveBlastRight.State			:= FOLDIO_STATE_START_1;
					g_ManualInletProcess.Outputs.SleeveBlastLeft.State			:= FOLDIO_STATE_START_1;
			
					g_ManualInletProcess.Outputs.InfeedBeltAirBlast.State		:= FOLDIO_STATE_IDLE_0;	
					
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'H-Inlet lead garment');
					
					//	Next Step depends on the availability of InfeedBeltMiddle_PH
					// Continue with detection of garment at the end of infeed belt  
					g_ManualInletProcess.Timers.ReachInfeedBeltEndPH.Timer 	:= g_ManualInletProcess.Common.CurTimer;
					g_ManualInletProcess.Common.State 						:= MACHPROC_WAIT_INFEEDBELT_END_26;				
					// Start the AirBlast
					g_ManualInletProcess.Outputs.InfeedBeltAirBlast.State	:= FOLDIO_STATE_START_1;						
					g_ManualInletProcess.Timers.ReachInfeedBeltEndPH.Timer 	:= g_ManualInletProcess.Common.CurTimer;
					g_ManualInletProcess.Values.JamAtInletConvoyerCounter 	:= 0; 				
				END_IF
			END_IF

			(*Here we axpect the garment to be dtected at the end of infeed belt *) 
		MACHPROC_WAIT_INFEEDBELT_END_26:

			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'M_Inlet ');
			// Handle TimeOut Error if Garment did not reached the end of Infeed Belt  
			IF ElapsedMsTime(g_ManualInletProcess.Common.CurTimer, g_ManualInletProcess.Timers.ReachInfeedBeltEndPH.Timer ) >= g_ManualInletProcess.Timers.ReachInfeedBeltEndPH.TTime THEN
				// Error : Garment was not detected by PH end of Infeed Belt 
				g_ManualInletProcess.Common.ErrorCode 	:= 6; 
				g_ManualInletProcess.Common.State 		:= MACHPROC_TRIG_ERROR_98;
			ELSE			
				// Handling of Jam Photocell in case the garment turns around the inlet convoyer
				IF g_ManualInletProcess.Inputs.InletConvoyerJam.Output THEN
					// Error : Jam at End of Inlet Convoyer
					g_ManualInletProcess.Common.ErrorCode 	:= 8; 
					g_ManualInletProcess.Common.State 		:= MACHPROC_TRIG_ERROR_98;
				END_IF;

				IF g_ManualInletProcess.Inputs.ReachedInfeedBeltEnd.Output THEN					
					g_ManualInletProcess.Outputs.InletConveyorMotor.State 		:= FOLDIO_STATE_IDLE_0;								
					g_ManualInletProcess.Outputs.InletBeltMotor.State 			:= FOLDIO_STATE_IDLE_0;
					//IF(NOT g_ManualInletProcess.Common.Next.TransferStatus = EXC_READY_TO_RECIEVE_2) THEN						
					g_ManualInletProcess.Outputs.InFeedBeltMotor.State 			:= FOLDIO_STATE_IDLE_0;
					//END_IF
					//test
					g_ManualInletProcess.Common.Next.Product			:= g_ManualInletProcess.Common.Product;
				
					//					(*We stop the AirBlast here since the garment passed successfully *)
					//					g_ManualInletProcess.Outputs.InfeedBeltAirBlast.State := FOLDIO_STATE_IDLE_0;
						
					(*We are ready to pass the garment to Top Convoyer*)		
					IF g_ManualInletProcess.Common.Next.TransferStatus = EXC_STANDBY_0 THEN
						g_ManualInletProcess.Common.Next.TransferStatus 	:= EXC_WANT_TO_UNLOAD_1;
					END_IF
					(*We have to stop if we were wating for new item*)	
					IF (g_ManualInletProcess.Common.Next.TransferStatus = EXC_READY_TO_RECIEVE_2) THEN 
						g_ManualInletProcess.Common.State 					:= MACHPROC_WAIT_STOP_30;
					ELSE
						g_ManualInletProcess.Outputs.InletBeltTC1Start.State	:= FOLDIO_STATE_IDLE_0;
						g_ManualInletProcess.Common.State 						:= MACHPROC_WAIT_RESTART_28;
						g_ManualInletProcess.Timers.ReachInfeedBeltEndPH.Timer 	:= g_ManualInletProcess.Common.CurTimer;
					END_IF
				END_IF		
			END_IF	
			
			// Wait for Top Convoyer to get ready..
		MACHPROC_WAIT_RESTART_28:

			// Make handshake with Hanger opener..
			IF g_ManualInletProcess.Common.Next.TransferStatus = EXC_STANDBY_0 THEN
				g_ManualInletProcess.Common.Next.TransferStatus 		:= EXC_WANT_TO_UNLOAD_1;
				g_ManualInletProcess.Timers.ReachInfeedBeltEndPH.Timer 	:= g_ManualInletProcess.Common.CurTimer;
			ELSIF g_ManualInletProcess.Common.Next.TransferStatus = EXC_READY_TO_RECIEVE_2 THEN
				IF ElapsedMsTime(g_ManualInletProcess.Common.CurTimer, g_ManualInletProcess.Timers.ReachInfeedBeltEndPH.Timer ) >= 280 THEN
					g_ManualInletProcess.Common.Next.TransferStatus 	:= EXC_UNLOADING_3;
					g_ManualInletProcess.Timers.InletConveyor.Timer		:= g_ManualInletProcess.Common.CurTimer;
					// Activate the Inlet belt 
					g_ManualInletProcess.Common.State 					:= MACHPROC_WAIT_STOP_30;
				END_IF
			END_IF


		MACHPROC_WAIT_STOP_30:

			// Reset the Trouser alignment output 
			g_ManualInletProcess.Values.TrouserAlignment	:= FALSE;
		
			// Hanger has dropped down onto the opener plate. 
			IF g_ManualInletProcess.Common.Next.TransferStatus = EXC_READY_TO_RECIEVE_2 THEN
				g_ManualInletProcess.Common.Next.TransferStatus 	:= EXC_UNLOADING_3;	
				//test
				g_ManualInletProcess.Common.Next.Product			:= g_ManualInletProcess.Common.Product;
			ELSIF g_ManualInletProcess.Common.Next.TransferStatus = EXC_RECIVING_4 THEN
				g_ManualInletProcess.Common.Product.EmpHangLength 	:= g_ManualInletProcess.Values.GarmentLenght;
				g_ManualInletProcess.Common.Next.Product			:= g_ManualInletProcess.Common.Product;
				g_ManualInletProcess.Outputs.VacuumFlap				:= FALSE;
				g_ManualInletProcess.Common.Next.TransferStatus 	:= EXC_FINISHED_UNLOADING_5;				//Hanger opener clamps hanger and starts opening...
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'H_Inlet hanger dropped');
				g_ManualInletProcess.Common.ExitTimer				:= g_ManualInletProcess.Common.CurTimer;
				IF g_ManualInletProcess.Values.GarmentLenght > g_MCfg.Inlet.Hanger.EmptyHangerLength THEN	
					IF (g_ManualInletProcess.Common.Product.ProductType = SHIRT_TYPE_1) OR (g_ManualInletProcess.Common.Product.ProductType = PYJAMAS_TYPE_2) THEN
						ShirtDetectedHMI := 1;	// Shirt icon
					ELSE
						ShirtDetectedHMI := 3;	// Trouser icon 
					END_IF	
				ELSE
					// WM 2.2.17 value changed from 3 to 66 to make place for new garments
					ShirtDetectedHMI := 66;		// Empty hanger detected at Hanger inlet...
				END_IF	
				g_ManualInletProcess.Common.State 					:= MACHPROC_AT_TOPCONVOYER_32;
			END_IF


			// Top Convoyer has got the Garment, go back and start feeding next garment
		MACHPROC_AT_TOPCONVOYER_32:

			IF ElapsedMsTime(g_ManualInletProcess.Common.CurTimer, g_ManualInletProcess.Common.ExitTimer) >= g_ManualInletProcess.Common.ExitTime THEN
				g_ManualInletProcess.Outputs.InletBeltMotor.State			:= FOLDIO_STATE_IDLE_0;
				(*We stop the AirBlast here since the garment passed successfully *)
				g_ManualInletProcess.Outputs.InfeedBeltAirBlast.State := FOLDIO_STATE_IDLE_0;			
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'M_Inlet Exit');
				//BlockStartBTN := FALSE;

				g_ManualInletProcess.Common.State 					:= 33; //MACHPROC_RUN_20;

			END_IF

		33:
			IF NOT g_ManualInletProcess.Inputs.ReachedInfeedBeltEnd.Output THEN
				g_ManualInletProcess.Values.SelectedStacker			:= 0; //PWC 03-10-2017: Reset Manual stacker select.
				g_ManualInletProcess.Common.State 					:= MACHPROC_RUN_20;
			END_IF
				
		MACHPROC_ERROR_99:

	
			g_ManualInletProcess.Common.Next.TransferStatus					:= EXC_ERROR_99;		// POX Obs..
			g_ManualInletProcess.Outputs.SleeveBlastRight.State				:= FOLDIO_STATE_IDLE_0;
			g_ManualInletProcess.Outputs.SleeveBlastLeft.State				:= FOLDIO_STATE_IDLE_0;
			g_ManualInletProcess.Outputs.InFeedBeltMotor.State				:= FOLDIO_STATE_IDLE_0;
			g_ManualInletProcess.Outputs.InfeedBeltAirBlast.State			:= FOLDIO_STATE_IDLE_0;			
			g_ManualInletProcess.Outputs.InletBeltTC1Start.State			:= FOLDIO_STATE_IDLE_0;
			g_ManualInletProcess.Outputs.InletConveyorMotor.State			:= FOLDIO_STATE_IDLE_0;
			g_ManualInletProcess.Outputs.InletBeltMotor.State				:= FOLDIO_STATE_IDLE_0;
			g_ManualInletProcess.Values.TrouserAlignment					:= FALSE;
			g_ManualInletProcess.Outputs.VacuumFlap							:= FALSE;
			IF (HangerNoRead >= HangerNoReadMax) AND (HangerNoRead > 0) THEN
				HangerNoRead												:= HangerNoRead -1;
			END_IF
			BlockStartBTN													:= FALSE;

	END_CASE



	(*------------------------------------------------------------------------------------------------*)
	(*------------------------------ CALL OUTPUTS 			------------------------------------------*)
	(*------------------------------------------------------------------------------------------------*)
	ActivateFoldIO(g_ManualInletProcess.Outputs.SleeveBlastRight			, g_ManualInletProcess.Common.CurTimer);
	ActivateFoldIO(g_ManualInletProcess.Outputs.SleeveBlastLeft				, g_ManualInletProcess.Common.CurTimer);
	ActivateFoldIO(g_ManualInletProcess.Outputs.InFeedBeltMotor				, g_ManualInletProcess.Common.CurTimer);
	ActivateFoldIO(g_ManualInletProcess.Outputs.InletConveyorMotor		, g_ManualInletProcess.Common.CurTimer);
	ActivateFoldIO(g_ManualInletProcess.Outputs.InletBeltMotor					, g_ManualInletProcess.Common.CurTimer);
	ActivateFoldIO(g_ManualInletProcess.Outputs.InfeedBeltAirBlast			, g_ManualInletProcess.Common.CurTimer);	
	ActivateFoldIO(g_ManualInletProcess.Outputs.CheckForShirt				, g_ManualInletProcess.Common.CurTimer);
	ActivateFoldIO(g_ManualInletProcess.Outputs.InletBeltTC1Start			, g_ManualInletProcess.Common.CurTimer);
	ActivateFoldIO(g_ManualInletProcess.Outputs.Vacuum							, g_ManualInletProcess.Common.CurTimer);
	ActivateFoldIO(g_ManualInletProcess.Outputs.ReleaseInfeedBeltJam	, g_ManualInletProcess.Common.CurTimer);



	(*########*)
	(* E-Stop *)
	(*########*)

	IF g_Machine.EStopActivated THEN
		g_ManualInletProcess.Outputs.InletConveyorMotor.State := FOLDIO_STATE_IDLE_0;
	END_IF 	

	(*############*)
	(* Reset Comm *)
	(*############*)
	
	IF ResetNoRead THEN
		HangerNoRead				:= 0;
		g_ExternalCom.HangerState	:= 0;
		ResetNoRead		:= FALSE;
	END_IF
	
	(*##################################*)
	(* Check if it's a Shirt or Trouser *)
	(*##################################*)

	// If ForceTrouser is set to FORCE_TO_TROUSER_1 then nothing happens but all garment are trouser by default..
	IF g_ACfg[g_ManualInletProcess.Common.Product.FoldProgram].ForceTrouser = 0 THEN						// Use photocell to detect shirts...
		IF g_ManualInletProcess.Outputs.CheckForShirt.Output THEN
			IF g_ManualInletProcess.Inputs.ShirtDetect.Output  THEN
				IF g_ManualInletProcess.Common.Product.ProductType 	= TROUSER_TYPE_0 THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'Shirt found');
				END_IF
				g_ManualInletProcess.Common.Product.ProductType 	:= SHIRT_TYPE_1;
			END_IF
		END_IF	
	ELSIF g_ACfg[g_ManualInletProcess.Common.Product.FoldProgram].ForceTrouser = FORCE_TO_SHIRT_2 THEN		// Force to shirt
		IF g_ManualInletProcess.Outputs.CheckForShirt.Output THEN
			IF g_ManualInletProcess.Common.Product.ProductType <> SHIRT_TYPE_1 THEN											// To get only one log
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'Shirt forced');
			END_IF
			g_ManualInletProcess.Common.Product.ProductType 	:= SHIRT_TYPE_1;
		END_IF	
	ELSIF g_ACfg[g_ManualInletProcess.Common.Product.FoldProgram].ForceTrouser = FORCE_TO_PYJAMAS_3 THEN	// Force to pyjamas
		IF g_ManualInletProcess.Outputs.CheckForShirt.Output THEN
			IF g_ManualInletProcess.Inputs.ShirtDetect.Output  THEN		// Pajamas must work in a mix with trousers...
				IF g_ManualInletProcess.Common.Product.ProductType <> PYJAMAS_TYPE_2 THEN										// To get only one log
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'Pyjamas forced');
				END_IF
				g_ManualInletProcess.Common.Product.ProductType 	:= PYJAMAS_TYPE_2;
			END_IF	
		END_IF	
	END_IF

	// It is a trouser, detection is closed and nothing was detected...
	IF EDGENEG(g_ManualInletProcess.Outputs.CheckForShirt.Output) AND (g_ManualInletProcess.Common.Product.ProductType = TROUSER_TYPE_0) THEN
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_ManualInletProcess.Common.LogBookFlag, g_DummyPulses, 'Trouser found');
		// Trouser aligment function
		IF g_ACfg[g_ManualInletProcess.Common.Product.FoldProgram].TrouserAlignment THEN
			g_ManualInletProcess.Values.TrouserAlignment := TRUE;
		END_IF	
		IF g_MCfg.Inlet.RunInfeedAll = 0 THEN								// 0 = Stop on trousers..
			g_ManualInletProcess.Outputs.InFeedBeltMotor.State := FOLDIO_STATE_IDLE_0;	// Stop the Infeed belt if it's a par of trousers.
		END_IF
	END_IF	 



	(*############################*)
	(* Measure lenght of garement *)
	(*############################*)

	(* Make pulses when the hanger conveyor is running *)
	IF g_ManualInletProcess.Outputs.InletConveyorMotor.Output THEN
		g_ManualInletProcess.Values.PulsCounter := g_ManualInletProcess.Values.PulsCounter + 1;
	END_IF		
	IF g_ManualInletProcess.Values.PulsCounter >= 60000 THEN
		g_ManualInletProcess.Values.PulsCounter := 0;
	END_IF	


	// Leading Edge 
	IF g_ManualInletProcess.Values.GarmentLenght = 0 THEN
		IF g_ManualInletProcess.Inputs.GarmentDetectionUp.EdgeCounter > g_ManualInletProcess.Inputs.GarmentDetectionUp.OldEdgeCounter THEN
			g_ManualInletProcess.Values.LeadingPoint := g_ManualInletProcess.Values.PulsCounter;	
		END_IF
		g_ManualInletProcess.Inputs.GarmentDetectionUp.OldEdgeCounter := g_ManualInletProcess.Inputs.GarmentDetectionUp.EdgeCounter;

		// Trailing Edge 
		IF g_ManualInletProcess.Values.LeadingPoint > 0 THEN
			IF (g_ManualInletProcess.Inputs.GarmentDetectionUp.TrailCounter > g_ManualInletProcess.Inputs.GarmentDetectionUp.OldTrailCounter) OR
				(((g_ManualInletProcess.Common.State = MACHPROC_WAIT_STOP_30) OR (g_ManualInletProcess.Common.State = MACHPROC_WAIT_RESTART_28) ) > Old_EdgeState) THEN	
				g_ManualInletProcess.Values.GarmentLenght :=  ElapsedMsTime(g_ManualInletProcess.Values.PulsCounter, g_ManualInletProcess.Values.LeadingPoint);
			END_IF
		END_IF		 
		g_ManualInletProcess.Inputs.GarmentDetectionUp.OldTrailCounter := g_ManualInletProcess.Inputs.GarmentDetectionUp.TrailCounter;
	END_IF
	Old_EdgeState := ((g_ManualInletProcess.Common.State = MACHPROC_WAIT_STOP_30) OR (g_ManualInletProcess.Common.State = MACHPROC_WAIT_RESTART_28));


	//#########################################################
	// Hanger Inlet is idle to be used in the machine process..
	//#########################################################


	IF g_ManualInletProcess.Common.State =  MACHPROC_RUN_20 THEN
		IF (ElapsedMsTime(g_ManualInletProcess.Common.CurTimer, g_ManualInletProcess.Values.IdleTimer) >= g_ManualInletProcess.Values.IdleTime) THEN
			g_ManualInletProcess.Values.InletIsIdle := TRUE;
		END_IF
	ELSE
		g_ManualInletProcess.Values.InletIsIdle := FALSE;
		g_ManualInletProcess.Values.IdleTimer := g_ManualInletProcess.Common.CurTimer; 	
	END_IF


	//###################################
	// Run Vaccum motor if needed.
	//###################################

	IF g_ManualInletProcess.Common.State >= MACHPROC_RUN_20 THEN
		IF g_MCfg.Inlet.Vaccum.AlwaysUse THEN 
			g_ManualInletProcess.Outputs.VacuumMotor := TRUE;
		ELSE
			g_ManualInletProcess.Outputs.VacuumMotor := FALSE;
		END_IF
	ELSE	
		g_ManualInletProcess.Outputs.VacuumMotor := FALSE;
	END_IF	



	//##############################################
	// Number of garments before cleaning of Fan..
	//##############################################

	IF g_ManualInletProcess.Outputs.VacuumMotor THEN
		IF EDGEPOS(g_ManualInletProcess.Inputs.GarmentDetectionUp.Output) THEN
			NumberOfGarmentsCleaning := NumberOfGarmentsCleaning + 1;
			// Check when to activate the output for cleaning the fan..
			IF NumberOfGarmentsCleaning > g_ManualInletProcess.Values.GarmentsBeforeCleaning THEN
				NumberOfGarmentsCleaning					:= 0;
				g_ManualInletProcess.Timers.FanCleaning.Timer 	:= g_ManualInletProcess.Common.CurTimer;
				g_ManualInletProcess.Outputs.VacuumCleaning 	:= TRUE;
			END_IF	
		END_IF
	END_IF	


	// Reset cleaning output after a time	
	IF g_ManualInletProcess.Outputs.VacuumCleaning THEN	
		IF (ElapsedMsTime(g_ManualInletProcess.Common.CurTimer, g_ManualInletProcess.Timers.FanCleaning.Timer) >= g_ManualInletProcess.Timers.FanCleaning.TTime) THEN
			g_ManualInletProcess.Outputs.VacuumCleaning := FALSE;
		END_IF
	END_IF

	//###############################################
	// Set vacuum flap after foldio timer has runned
	//###############################################

	IF g_ManualInletProcess.Outputs.Vacuum.Output THEN
		g_ManualInletProcess.Outputs.VacuumFlap	:= TRUE;
	END_IF


	// Change State back if Alarm reseted
	IF g_TopConveyorProcess.Common.ErrorCode = 2 AND g_ManualInletProcess.Common.State= MACHPROC_WAIT_STOP_30  THEN
		g_ManualInletProcess.Common.State := 99; 
	END_IF;


	//###############################################
	// Manual tranport of jamed garment 
	//###############################################

	IF g_ManualInletProcess.Common.State = 99 AND (g_ManualInletProcess.Common.ErrorCode = 6 OR g_ManualInletProcess.Common.ErrorCode = 8 OR g_ManualInletProcess.Common.ErrorCode = 12) THEN
		
		// View the Visu Button 
		g_HMI_MacConfig.ReleaseInfeedJam.RT := 0; 	
		// Run The Belts for  time when the Button is pressed  		
		IF g_HMI_MacConfig.ReleaseInfeedJam.BTN = 1 THEN
			g_ManualInletProcess.Outputs.ReleaseInfeedBeltJam.State := FOLDIO_STATE_START_1 ; 
		END_IF;
	ELSE
		g_ManualInletProcess.Outputs.ReleaseInfeedBeltJam.State := FOLDIO_STATE_IDLE_0 ; 
	END_IF;
	
	//###################################
	//Show Icon if StackChange requested
	//###################################

	//IF (StackChangeIndex <> g_CrossFoldBProcess.StackChangeControl.OldStackChangeIndex)
	//PWC 02-07-2018: For bette overview in code below	//CWH_DUO
	StckIdx			:= g_ManualInletProcess.Common.Product.StackChangeIndex;
	OldStckIdx		:= g_CrossFoldBProcess.StackChangeControl.OldStackChangeIndex;
	DuoStckIdx		:= g_DuoInletProcess.Common.Product.DuoStackChangeIndex;
	OldDuoStckIdx	:= g_CrossFoldBProcess.StackChangeControl.DuoOldStackChangeIndex;
	
	IF ((StckIdx <> OldStckIdx) AND (OldStckIdx > 0)) OR ((DuoStckIdx <> OldDuoStckIdx) AND (DuoStckIdx > 0)) AND (g_HCfg.FeedManual = 1) THEN
		g_HangerInletProcess.IndexingIconRuntime := 0;	
	ELSE
		g_HangerInletProcess.IndexingIconRuntime := 1;
	END_IF

	//	//###############################################
	//	// Shut down Inlet by Security Cover 
	//	//###############################################
	//
	//	IF EDGENEG(g_ManualInletProcess.Inputs.SecurityCover.Output )THEN
	//		SecurityCover := TRUE;
	//  	END_IF
	//	IF SecurityCover THEN
	//		g_ManualInletProcess.Common.ErrorCode		:= 12;
	// 		g_ManualInletProcess.Common.State 			:= MACHPROC_TRIG_ERROR_98;
	//		g_ManualInletProcess.Outputs.VacuumMotor	:= FALSE;
	//		IF (g_ManualInletProcess.Inputs.SecurityCover.Output) THEN
	//  			SecurityCover := FALSE;
	//   		END_IF					
	//  	END_IF
	//
	
	(*------------------------------------------------------------------------------------------------*)
	(*------------------------------ SET OUTPUT SIGNALS 	------------------------------------------*)
	(*------------------------------------------------------------------------------------------------*)
	//	QYCHAirShortArmLeft := g_ManualInletProcess.Outputs.SleeveBlastLeft.Output;
	QYAirLeftSleeve := g_ManualInletProcess.Outputs.SleeveBlastLeft.Output;
	//	QYCHAirShortArmRight := g_ManualInletProcess.Outputs.SleeveBlastRight.Output;
	QYAirRightSleeve := g_ManualInletProcess.Outputs.SleeveBlastRight.Output;

	//done in Top Convoyer 
	//QMInfeedBelt			:= g_ManualInletProcess.Outputs.InFeedBeltMotor;

	QYVacuumFlap			:= g_ManualInletProcess.Outputs.VacuumFlap;
	QMVacuum				:= g_ManualInletProcess.Outputs.VacuumMotor;
	QYVacuumCleaning		:= g_ManualInletProcess.Outputs.VacuumCleaning;

	//done in Top Convoyer 
	// QMInletConvoyerMP 	:= g_ManualInletProcess.Outputs.InletConveyorMotor.Output;
	
	QMVacuumInletConveyor	:= g_ManualInletProcess.Outputs.InletBeltMotor.Output OR g_ManualInletProcess.Outputs.ReleaseInfeedBeltJam.Output ;
	QYMPInfeedAirBlast		:= g_ManualInletProcess.Outputs.InfeedBeltAirBlast.Output ;
	
	// Test 
	g_test_steper.M_Inlet.curStep := g_ManualInletProcess.Common.State;

END_ACTION

ACTION Sim :

//	// test 
//	IF g_Sim.BTN = 1 THEN
//		g_Sim.RT := 0; 
//		ISEmergencyOk:= TRUE;
//		ISStartMachine;
//		ISAirOk:= TRUE;
//		X_StopMachine_BTN:= TRUE;
//		ISThermoOk:= TRUE;
//		X_ManualFeedSecurity_SWT:= 1; 
//	ELSE
//		g_Sim.RT := 1; 	
//	END_IF;
	
END_ACTION