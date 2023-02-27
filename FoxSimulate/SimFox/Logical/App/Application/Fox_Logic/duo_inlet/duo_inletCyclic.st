(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: duo_inlet
 * File: duo_inletCyclic.st
 * Author: munchp
 * Created: April 06, 2017
 ********************************************************************
 * Implementation of program duo_inlet
 ********************************************************************)

PROGRAM _CYCLIC

IF NOT g_HCfg.DuoInlet THEN
	RETURN;
END_IF
	
	(*#####################*)
	(* Get current time... *)
	(*#####################*)
	g_DuoInletProcess.Common.CurTimer 					:= g_Timers._1_ms;
	IF g_DuoInletProcess.Common.LogBookFlag > 0 THEN
		strcpy(ADR(TmpStr),ADR(g_DuoInletProcess.Common.Description));
	END_IF

	IF NOT (g_Core.Services.Recipe.Runtime.recipePointer > 0) THEN		(* Check that pointer is bigger then Null *)
		RETURN;								(* Do not run task before pointer is assigned... *)
	END_IF
	IF EDGEPOS(g_Core.Services.Recipe.Runtime.recipePointer > 0) AND (g_DuoInletProcess.Common.Product.FoldProgram = 0) THEN
		g_DuoInletProcess.Common.Product.FoldProgram		:= 75;
	END_IF
 		

	(*#################################*)
	(* copy status of exchange objects *)
	(*#################################*)
	g_DuoInletProcess.Common.Previous					:= g_TopConveyorProcess.Common.Next;
	g_DuoInletProcess.Common.Next						:= g_LateralProcess.Common.Previous;
	
	(*########################################*)
	(* Connect inputs to the module structure *)
	(*########################################*)
	g_DuoWheelCounter;
	g_DuoInletProcess.IBLF 		:= IBLF;
	g_DuoInletProcess.IBInlet 	:= IBInlet;
	
	FOR x := 2 TO 4 DO g_DuoInletProcess.IBAutoL[x] := IBAutoL[x]; g_DuoInletProcess.IBAutoW[x] := IBAutoW[x]; END_FOR;
	
	this.filter.IBLF		(In:=g_DuoInletProcess.IBLF,	 		Filter := 10, 			FMode:=3, TMode:=0, CntAdr:=ADR(g_DuoWheelCounter));
	this.filter.IBInlet		(In:=g_DuoInletProcess.IBInlet, 		Filter := filterValue, 	FMode:=3, TMode:=0, CntAdr:=ADR(g_MilliSeconds));
	this.filter.IBAutoL[2]	(In:=g_DuoInletProcess.IBAutoL[2], 		Filter := filterValue, 	FMode:=3, TMode:=0, CntAdr:=ADR(g_MilliSeconds));
	this.filter.IBAutoL[3]	(In:=g_DuoInletProcess.IBAutoL[3], 		Filter := filterValue, 	FMode:=3, TMode:=0, CntAdr:=ADR(g_MilliSeconds));
	this.filter.IBAutoL[4]	(In:=g_DuoInletProcess.IBAutoL[4], 		Filter := filterValue, 	FMode:=3, TMode:=0, CntAdr:=ADR(g_MilliSeconds));
	this.filter.IBAutoW[2]	(In:=g_DuoInletProcess.IBAutoW[2], 		Filter := filterValue, 	FMode:=3, TMode:=0, CntAdr:=ADR(g_MilliSeconds));
	this.filter.IBAutoW[3]	(In:=g_DuoInletProcess.IBAutoW[3], 		Filter := filterValue, 	FMode:=3, TMode:=0, CntAdr:=ADR(g_MilliSeconds));
	this.filter.IBAutoW[4]	(In:=g_DuoInletProcess.IBAutoW[4], 		Filter := filterValue, 	FMode:=3, TMode:=0, CntAdr:=ADR(g_MilliSeconds));
	
	(*######################*)
	(* Connect timer values *)
	(*######################*)
	g_DuoInletProcess.Common.WatchDogStartupTime			:= 2000;
	g_DuoInletProcess.Common.WatchDogRunTime				:= 30000;		// Increased from 3000 to 4000 2010-07-07 POX.. 

	(*#################*)
	(* Read parameters *)
	(*#################*)
	
	IF g_DuoInletProcess.Common.Product.FoldProgram <> oldFoldProgram THEN
		oldFoldProgram := g_DuoInletProcess.Common.Product.FoldProgram;
		g_DuoInletProcess.Common.ReadParameters := TRUE;
	END_IF;

	IF g_DuoInletProcess.Common.ReadParameters THEN
		g_DuoInletProcess.Common.ReadParameters 			:= FALSE;
		IF g_Core.Services.Recipe.Runtime.recipePointer > 0 THEN			(* Check that pointer is bigger then Null *)
			LocalFoldProgram ACCESS(g_Core.Services.Recipe.Runtime.recipePointer + (SIZEOF(LocalFoldProgram) * LIMIT(0, (g_DuoInletProcess.Common.Product.FoldProgram - 1), MAX_NUMBER_OF_CATEGORIES)));
		ELSE
			RETURN;		(* Can not access LocalFoldProgram before pointer is ok. *)
		END_IF
		
		g_DuoInletProcess.Parameters						:= LocalFoldProgram.DuoInlet;
		
	END_IF;
	
	RunFoldTask(g_MCfg.Trace2File, ADR(T2FD), g_DuoInletProcess.Common, g_MachineManager[g_DuoInletProcess.Common.MachineManagerIndex]);

	
	// -------------------------------------------------------------------
	// Block Topconveyor coms and get Lateral Fold to communicate with duo
	// -------------------------------------------------------------------
	
	this.TOF_GarmentOnTop.IN := EDGEPOS(IBInfeedBeltEndMP);
	
//	IF (g_DuoInletProcess.Common.State > 21 AND g_DuoInletProcess.Common.State < 26) AND (g_TopConveyorProcess.Common.Next.TransferStatus = EXC_STANDBY_0) 
//		AND NOT this.TOF_GarmentOnTop.Q AND NOT (IBHorizontal (*AND (g_FlipInlet < DUO_FLIP_INLET_02)*)) AND (g_LateralProcess.Common.State = 20) THEN 
//		g_DuoInletProcess.requestDelivery := TRUE;
////		g_FlipInlet := 0; //PWC: We reset this every time Duo is allowed to run, so Fox Inlet can run the next two pieces. This can be changed by DUO_FLIP_INLET_02
//	END_IF
		
//CWH
	IF (g_DuoInletProcess.Common.State > 21 AND g_DuoInletProcess.Common.State < 26) (*AND (g_TopConveyorProcess.Common.Next.TransferStatus = EXC_STANDBY_0) *)
		AND (NOT this.TOF_GarmentOnTop.Q AND NOT IBHorizontal OR (g_FlipInlet > DUO_FLIP_INLET_02)) AND (g_LateralProcess.Common.State = 20) THEN 
		g_DuoInletProcess.requestDelivery := TRUE;
		g_FlipInlet := 0; //PWC: We reset this every time Duo is allowed to run, so Fox Inlet can run the next two pieces. This can be changed by DUO_FLIP_INLET_02
	END_IF
	
	// -------------------------------------------------------------------
	// Vacuum & Powersave
	// -------------------------------------------------------------------
	this.powersave.TOF_Inlet(IN := g_DuoInletProcess.IBInlet, PT:= UINT_TO_TIME(this.powersave.timeBeforePowersave * 1000));
	g_DuoInletProcess.QMVacuumDuo := (*this.powersave.TOF_Inlet.Q AND*) g_Core.System.Runtime.isRunning;
	
	IF g_DuoInletProcess.QMVacuumDuo THEN
		count := count + 1;
	END_IF;
	
	IF count >= 180000 THEN // 30 min at 10 ms
		g_DuoInletProcess.QCleanVentDuo := TRUE;
	ELSE
		g_DuoInletProcess.QCleanVentDuo := FALSE;
	END_IF;
	
	IF count >= 180300 THEN
		count := 0;
	END_IF;	

	// -------------------------------------------------------------------
	// Sorting / Customer Change
	// -------------------------------------------------------------------
	IF EDGEPOS(ISDuoCustChange) THEN
 		RCustomerChange := 1;
		RStackChangeIndex := RStackChangeIndex + 1;
	END_IF
	
	IF EDGEPOS(ISSort) AND g_DuoInletProcess.Common.Next.TransferStatus <= EXC_RECIVING_4 AND (g_DuoInletProcess.Common.State > 20 AND g_DuoInletProcess.Common.State < 25)  THEN
		IF g_DuoInletProcess.SortOutDuoEnd THEN
			rSorting := 2;	// 2 sortout after the last stakker.
		ELSE
			rSorting := 3;	// 3 sortout after XB
		END_IF
	END_IF;
			
	// -------------------------------------------------------------------
	// Length meassure
	// -------------------------------------------------------------------
	
	IF EDGEPOS(IBLF) THEN
		this.length.startPoint := g_DuoWheelCounter;
	END_IF;
	
	IF EDGENEG(IBLF) THEN
		this.length.endPoint := g_DuoWheelCounter;
		this.length.lengthPulses := (this.length.endPoint - this.length.startPoint);
		this.length.length_mm := UDINT_TO_UINT(((this.length.lengthPulses) * WHEEL_INC_TO_DISTANCE_MM) / 134);
		g_DuoInletProcess.Common.Product.Length := this.length.length_mm;
		this.length.done_meas := TRUE;
		HMILengthCM	:= this.length.length_mm/10;
	END_IF;
	
	
	(* Additional case statement not covered by RunFoldTask(g_MCfg.Trace2File, ADR(T2FD), ) function. *)
	CASE g_DuoInletProcess.Common.State OF

		(*####################################*)
		(* Start Up Machine, Home Axels etc.. *)
		(*####################################*)
		
		// -------------------------------------------------
		MACHPROC_STARTUP_1:
		// -------------------------------------------------

			g_DuoInletProcess.Common.Previous.TransferStatus 		:= EXC_STANDBY_0;
			IF g_DuoInletProcess.Common.SaveState = MACHPROC_DELIVER_PACKAGE_80 THEN
				
				g_DuoInletProcess.Common.State 						:= MACHPROC_DELIVER_PACKAGE_80;
				g_DuoInletProcess.Common.Previous.TransferStatus 	:= EXC_RECIVING_4;
			ELSE
				g_DuoInletProcess.Common.State 						:= MACHPROC_RUN_20;
				g_DuoInletProcess.Common.Previous.TransferStatus 	:= EXC_STANDBY_0;
			END_IF
			(*SFX savestate start is not working 090202*)
			g_DuoInletProcess.Common.State 							:= MACHPROC_RUN_20;
			g_DuoInletProcess.Common.Previous.TransferStatus 		:= EXC_STANDBY_0;


		// -------------------------------------------------
		MACHPROC_MANUAL_8:
		// -------------------------------------------------
			;


		(*###############################################################*)
		(* Machine Stop case, to handle shut down process of the module  *)
		(*###############################################################*)

		// -------------------------------------------------
		MACHPROC_STOP_15:
		// -------------------------------------------------
			(* Reset output and handle the shutdown procedure *)
			(* Extra stop cases may be needed.. *)
			
			g_DuoInletProcess.Common.State 				:= MACHPROC_INIT_0;
			g_DuoInletProcess.Common.FoldUnit1.State	:= FOLDIO_STATE_IDLE_0;
			g_DuoInletProcess.Common.FoldUnit2.State	:= FOLDIO_STATE_IDLE_0;
			g_DuoInletProcess.Common.Motor.cmdStop		:= TRUE;
			IF g_MachineManager[g_DuoInletProcess.Common.Id].ForcedStop THEN
				g_DuoInletProcess.Common.SaveState := 0;
			END_IF


		(*#####################*)
		(* Main running state  *)
		(*#####################*)
		
		// -------------------------------------------------
		MACHPROC_RUN_20:
		// -------------------------------------------------	
			g_DuoInletProcess.requestDelivery := FALSE;
			g_DuoInletProcess.QMInletDuo := FALSE;
			IF g_DuoInletProcess.Parameters.DelayStartInlet > 0 AND NOT g_DuoInletProcess.ManualFeed THEN
				this.startInlet := this.filter.IBInlet.Out OR this.filter.IBAutoL[2].Out OR this.filter.IBAutoL[3].Out OR this.filter.IBAutoL[4].Out;
			ELSE
				this.startInlet := ISInlet;
			END_IF;
			this.TON_DelayStartInlet.IN := this.startInlet;
			this.blockInlet := g_LateralProcess.Common.State <> 20;
			
			// Get data to structure
			IF this.startInlet AND NOT this.blockInlet THEN
				g_DuoInletProcess.Common.Product.ProductType		:= TOWELS_TYPE_3;
//				g_DuoInletProcess.Common.Product.SortOut := rSorting;
				g_DuoInletProcess.Common.Product.DuoStackChangeIndex := RStackChangeIndex;
//				g_DuoInletProcess.Common.Product.PreStackChange := RCustomerChange;
							; // Do nothing
				IF g_DuoInletProcess.AutoLengthON THEN	// AutoPrg select
					// Get stacker settings
					IF this.filter.IBAutoL[4].Out THEN // Four photocells covered
	//					g_DuoInletProcess.Common.Product.Stack := LIMIT(1, LocalFoldProgram.DuoInlet.StackerSelection[3], 2);
	//					rStackSelect		:= 3;
						g_DuoInletProcess.Common.Product.FoldProgram	:= g_MCfg.Duo.AutoPrgSelect[3];
					ELSIF this.filter.IBAutoL[3].Out THEN // Three photocells covered
	//					g_DuoInletProcess.Common.Product.Stack := LIMIT(1, LocalFoldProgram.DuoInlet.StackerSelection[2], 2);
	//					rStackSelect		:= 2;
						g_DuoInletProcess.Common.Product.FoldProgram	:= g_MCfg.Duo.AutoPrgSelect[2];
					ELSIF this.filter.IBAutoL[2].Out THEN // Two photocells covered
	//					g_DuoInletProcess.Common.Product.Stack := LIMIT(1, LocalFoldProgram.DuoInlet.StackerSelection[1], 2);
	//					rStackSelect		:= 1;
						g_DuoInletProcess.Common.Product.FoldProgram	:= g_MCfg.Duo.AutoPrgSelect[1];
					ELSE // One photocell covered
	//					g_DuoInletProcess.Common.Product.Stack := LIMIT(1, LocalFoldProgram.DuoInlet.StackerSelection[0], 2);
	//					rStackSelect		:= 0;
					END_IF;
				ELSE	// Rcp select if not i AutoPrg mode
					IF this.filter.IBAutoL[4].Out THEN // Four photocells covered
	//					g_DuoInletProcess.Common.Product.Stack := LIMIT(1, LocalFoldProgram.DuoInlet.StackerSelection[3], 2);
	//					rStackSelect		:= 3;
						g_DuoInletProcess.Common.Product.FoldProgram	:= g_MCfg.Duo.RcpSelect[3];
					ELSIF this.filter.IBAutoL[3].Out THEN // Three photocells covered
	//					g_DuoInletProcess.Common.Product.Stack := LIMIT(1, LocalFoldProgram.DuoInlet.StackerSelection[2], 2);
	//					rStackSelect		:= 2;
						g_DuoInletProcess.Common.Product.FoldProgram	:= g_MCfg.Duo.RcpSelect[2];
					ELSIF this.filter.IBAutoL[2].Out THEN // Two photocells covered
	//					g_DuoInletProcess.Common.Product.Stack := LIMIT(1, LocalFoldProgram.DuoInlet.StackerSelection[1], 2);
	//					rStackSelect		:= 1;
						g_DuoInletProcess.Common.Product.FoldProgram	:= g_MCfg.Duo.RcpSelect[1];
					ELSE // One photocell covered
	//					g_DuoInletProcess.Common.Product.Stack := LIMIT(1, LocalFoldProgram.DuoInlet.StackerSelection[0], 2);
	//					rStackSelect		:= 0;
					END_IF;
				END_IF
				
				// Start the inlet after a delay
				IF this.TON_DelayStartInlet.Q THEN
					time_stamps[0] := g_DuoInletProcess.Common.CurTimer;
					g_DuoInletProcess.Common.WatchDogRunTimer := g_DuoInletProcess.Common.CurTimer;
					g_DuoInletProcess.Common.State := MACHPROC_START_INLET_21;
				END_IF;
			END_IF;
			
		// -------------------------------------------------
		MACHPROC_START_INLET_21:
		// -------------------------------------------------
					
			g_AutoProgram.OperatorAutoProgram	:= 75;
		
			// Check the width photocells after a delay
			this.TON_DelayCheckPh.IN := TRUE;
			IF this.TON_DelayCheckPh.Q THEN
				g_DuoInletProcess.Common.State := MACHPROC_CHECK_PH_22;
				this.TON_DelayCheckPh.IN := FALSE;
			END_IF;
			
		// -------------------------------------------------
		MACHPROC_CHECK_PH_22:
		// -------------------------------------------------
		
			// Get Template settings  PWC: Now It's Set FoldProgram 75,76 or 77| New: We don't use this section, but use the vertical ph instead.
//			IF RSelectProgram = 1 THEN	

//			ELSIF this.filter.IBAutoW[4].Out THEN
//				g_DuoInletProcess.Common.Product.Duo_WidthFirst := LocalFoldProgram.DuoInlet.WidthFirst[2];
//				g_DuoInletProcess.Common.Product.Duo_WidthLast 	:= LocalFoldProgram.DuoInlet.WidthLast[2];
//				g_DuoInletProcess.Common.Product.FoldProgram	:= g_MCfg.Duo.AutoPrgSelect[3];
//			ELSIF this.filter.IBAutoW[3].Out THEN
//				g_DuoInletProcess.Common.Product.Duo_WidthFirst := LocalFoldProgram.DuoInlet.WidthFirst[1];
//				g_DuoInletProcess.Common.Product.Duo_WidthLast 	:= LocalFoldProgram.DuoInlet.WidthLast[1];
//				g_DuoInletProcess.Common.Product.FoldProgram	:= g_MCfg.Duo.AutoPrgSelect[2];
//			ELSIF this.filter.IBAutoW[2].Out THEN
//				g_DuoInletProcess.Common.Product.Duo_WidthFirst := LocalFoldProgram.DuoInlet.WidthFirst[0];
//				g_DuoInletProcess.Common.Product.Duo_WidthLast 	:= LocalFoldProgram.DuoInlet.WidthLast[0];
//				g_DuoInletProcess.Common.Product.FoldProgram	:= g_MCfg.Duo.AutoPrgSelect[1];
//			END_IF;

//			IF g_DuoInletProcess.Common.Product.FoldProgram = oldFoldProgram THEN
//				g_DuoInletProcess.Common.Product.Stack := LIMIT(1, LocalFoldProgram.DuoInlet.StackerSelection[rStackSelect], 2);
				IF g_DuoInletProcess.requestDelivery THEN
					g_DuoInletProcess.Common.Next.TransferStatus := EXC_WANT_TO_UNLOAD_1;
					g_DuoInletProcess.Common.State := MACHPROC_UNLOAD_23;
				END_IF;
//			END_IF
		// -------------------------------------------------	
		MACHPROC_UNLOAD_23:
		// -------------------------------------------------	
			IF g_DuoInletProcess.Common.Next.TransferStatus = EXC_READY_TO_RECIEVE_2 THEN
				g_DuoInletProcess.Common.Next.TransferStatus := EXC_UNLOADING_3;
				g_DuoInletProcess.Common.State := MACHPROC_UNLOAD_24;
			ELSE
				g_DuoInletProcess.QMInletDuo := FALSE;
			END_IF;
		
		// -------------------------------------------------	
		MACHPROC_UNLOAD_24:
		// -------------------------------------------------
			IF g_DuoInletProcess.Common.Next.TransferStatus = EXC_RECIVING_4 THEN
				this.TON_DelayCheckIBLF.IN := TRUE;
				g_DuoInletProcess.Common.Product.SortOut := rSorting;
				g_DuoInletProcess.QMInletDuo := TRUE;
				InletTimeOut(IN := TRUE, PT := T#1000ms) ;
			END_IF;
			
			IF (IBLF) THEN
				this.linenSeen := TRUE;
			END_IF;
			
			IF NOT IBLF AND this.TON_DelayCheckIBLF.Q AND this.length.done_meas AND this.linenSeen THEN
				this.TON_DelayCheckIBLF.IN := FALSE;
				g_DuoInletProcess.QMInletDuo := FALSE;
				this.length.done_meas := FALSE;
				this.linenSeen := FALSE;
				g_DuoInletProcess.Common.Next.Product := g_DuoInletProcess.Common.Product; // Handover duo product to lateral fold
				IF g_DuoInletProcess.Common.Next.TransferStatus = EXC_RECIVING_4 THEN
					g_DuoInletProcess.Common.Product.SortOut := rSorting 	:= 0;
//					g_DuoInletProcess.Common.Product.PreStackChange			:= FALSE;
					
					g_DuoInletProcess.Common.Next.TransferStatus := EXC_FINISHED_UNLOADING_5;
					g_DuoInletProcess.Common.State := MACHPROC_WAIT_FOR_LFOLD_25;
					InletTimeOut(IN := FALSE, PT := T#10ms);	
				END_IF;
			// Abort! There was no Linen in time.
			ELSIF InletTimeOut.Q AND NOT this.linenSeen THEN
				g_DuoInletProcess.Common.Next.TransferStatus	:= 7; //Send Abort TransfoerStatus "Abort" to LateralN Fold task
				this.TON_DelayCheckIBLF.IN := FALSE;
				this.length.done_meas := FALSE;
				this.linenSeen := FALSE;
				InletTimeOut(IN := FALSE, PT := T#10ms);
				g_DuoInletProcess.Common.WatchDogRunTimer 		:= g_DuoInletProcess.Common.CurTimer;
				g_DuoInletProcess.Common.State := MACHPROC_WAIT_FOR_LFOLD_25;//MACHPROC_RUN_20;
			END_IF;	
		
		// -------------------------------------------------
		MACHPROC_WAIT_FOR_LFOLD_25:
		// -------------------------------------------------
			IF g_DuoInletProcess.Common.Next.TransferStatus = EXC_STANDBY_0 THEN
				g_DuoInletProcess.requestDelivery := FALSE; // Reset flag for coms
				time_stamps[1] := g_DuoInletProcess.Common.CurTimer;
				time_stamps[2] := time_stamps[1] - time_stamps[0];
				g_DuoInletProcess.Common.WatchDogRunTimer 		:= g_DuoInletProcess.Common.CurTimer;
				g_DuoInletProcess.Common.Product.FoldProgram 	:= oldFoldProgram;
				g_DuoInletProcess.Common.State := MACHPROC_RUN_20;
			END_IF;
		
		// -------------------------------------------------	
		MACHPROC_ERROR_99:
		// -------------------------------------------------
			g_DuoInletProcess.requestDelivery := FALSE;
			g_DuoInletProcess.QMInletDuo 				:= FALSE;
			g_DuoInletProcess.Common.Motor.cmdStop		:= TRUE;
			g_DuoInletProcess.Common.FoldUnit1.Output	:= 0;
			g_DuoInletProcess.Common.FoldUnit2.Output	:= 0;
			
	END_CASE
	
	RetSortOut := g_DuoInletProcess.SortOutDuoEnd;
	RetAutoLength := g_DuoInletProcess.AutoLengthON;
	RetManFeed := g_DuoInletProcess.ManualFeed;	

	(* If E-stop will this output drop. Set variable accordingly to avoid movement when E-stop is released *)
	IF g_Machine.EStopActivated THEN
		g_DuoInletProcess.QMInletDuo 	:= FALSE;
		g_DuoInletProcess.QCleanVentDuo := FALSE;
		g_DuoInletProcess.QMVacuumDuo 	:= FALSE;
	END_IF
	

		
	// ---------------------------------------------------------------
	// Function mappings
	// ---------------------------------------------------------------
	this.TOF_GarmentOnInlet.IN := EDGENEG(this.linenSeen);
	
	IF g_DuoInletProcess.Parameters.DelayStartInlet > 0 THEN
		this.TON_DelayStartInlet.PT := UINT_TO_TIME(g_DuoInletProcess.Parameters.DelayStartInlet);
	ELSE
		this.TON_DelayStartInlet.PT := T#100ms;
	END_IF;
	this.TON_DelayCheckPh.PT		:= T#100ms;
	this.TON_DelayCheckIBLF.PT		:= T#300ms;
	this.TOF_GarmentOnTop.PT		:= T#2500ms;
	this.TOF_GarmentOnInlet.PT		:= UINT_TO_TIME(testTime);
		
	this.TON_DelayStartInlet();
	this.TON_DelayCheckPh();
	this.TON_DelayCheckIBLF();
	this.TOF_GarmentOnTop();
	this.TOF_GarmentOnInlet();
	
	g_DuoInletProcess.lowerBlades := this.linenSeen;
	
	// ---------------------------------------------------------------
	// Output mappings
	// ---------------------------------------------------------------	
		
	QMInletDuo 		:= g_DuoInletProcess.QMInletDuo;
	QMLFold[2]		:= g_DuoInletProcess.QMInletDuo OR QMLFold[1] OR g_DuoInletMotorPreStart;
	QYInletDuoBrake	:= NOT QMLFold[2];
	QMVacuumDuo 	:= g_DuoInletProcess.QMVacuumDuo;
	QCleanVentDuo 	:= g_DuoInletProcess.QCleanVentDuo;
	QKRaiseDuoInlet := g_DuoInletProcess.cmdRaiseTable;
	QKLowerDuoInlet := g_DuoInletProcess.cmdLowerTable;
	
	g_DuoInletProcess.useInverter := TRUE;	
	IF g_DuoInletProcess.useInverter THEN
	
		StartInverter := g_Core.System.Runtime.isRunning OR g_DuoInletProcess.Common.State = MACHPROC_MANUAL_8;
		FOR i := 0 TO 1 DO	
		CASE g_Inverter.Drive[i].GetState OF
			0,3 : 	(* Drive not Ready *)
					g_Inverter.Drive[i].SetControl := 14;
			2   : 	(* Drive Ready *)
					IF StartInverter THEN
						g_Inverter.Drive[i].SetControl := 15;
					END_IF;
			4	:	(* Drive Running *)
					IF NOT StartInverter THEN
						g_Inverter.Drive[i].SetControl := 14;
					END_IF;
		END_CASE
		END_FOR
		// Inverter speed
		g_Inverter.Drive[0].SetSpeed := SEL(QMLFold[1],0, g_DuoInletProcess.inverterSpeed);
//		g_Inverter.Drive[1].SetSpeed := SEL(QMInletDuo,0, LFoldSpeed);
		
	END_IF;

	
		
END_PROGRAM
