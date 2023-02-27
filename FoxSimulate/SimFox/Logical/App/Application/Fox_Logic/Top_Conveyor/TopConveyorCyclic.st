PROGRAM _CYCLIC
(* cyclic program *)

(*-------------------------------------------------------------------------------------

Author:   				Sten Flystedt

FileName:				TopConveyor.st

Desription:				Top conveyor, also called Turn around conveyor

Reference:
ll
Interfaces:				No interfaces.

Watch debugg:			Name OF important watch configurations.

History:
18-09-28				V1.14.9	CWH				Added ELIS MES...
10-05-31				V1.14.8	PO Nilsson		Increased the Watchdog timeout from 3000 TO 3500...
10-05-07				V1.14.7	PO Nilsson		Used Product .Size field TO detect it is a Overall...
10-05-06				V1.14.6	PO Nilsson		We can now adjust Discount after a stop AND go in Turn around...
10-04-29				V1.14.5	PO Nilsson		Bug fix, when error 4 was reseted Hanger opener was started changed code in _1...
10-04-22				V1.14.4	PO Nilsson		Added FUNCTION TO start Inlet / Overall funcion...
10-04-16				V1.14.3	PO Nilsson		Infeed belt stop can be controlled FOR all garment types...
10-04-13				V1.14.2	PO Nilsson		Infeed belt can also be stoped on trosers BY selection in Auto program..
10-03-29				V1.14.1	PO Nilsson		Removed "JogMotor"..
10-03-18				V1.14.0	PO Nilsson		Fox 600...
10-03-18				V1.13.5	PO Nilsson		Removed update ot watchdog in Wait FOR rearedge _90
10-02-08				V1.13.4	PO Nilsson		Check photocells at startup TO see that now garments are still there...
10-02-03				V1.13.3	PO Nilsson		Changed name on X_InletHorizontalDetection TO IBHorizontal TO get IO Descriptions TO work
												AND on Q_M_TopConveyorForward TO Q_TopConveyor_MTR AND Q_M_InfeedBeltForward TO Q_InfeedBelt_MTR.
												Removed Vertical LEFT AND RIGHT sensor... Changed name on X_InletVerticalMid TO IBVertical[1]..
10-01-27				V1.13.2	PO Nilsson		Cleaned up, removed the only vertical... g_SpeedCountOfWheel changed TO UINT..
												Changed around quit much TO get the discount TO work good...
10-01-12				V1.13.1	PO Nilsson		"Data" member was removed from g_AutoProgramData structure...
09-01-11				V1.13.0	PO Nilsson		Bug fixes from Holbaek. Just clean up no real bug found.
09-12-10				V1.12.9	PO Nilsson		Secured the Code around HoldPoint AND stop OF motor...
09-12-08				V1.12.8	PO Nilsson		Removed the variable g_GarmentOnInlet...
09-12-02				V1.12.7	PO Nilsson		Shorten the Holdpoint...
09-11-30				V1.12.6 PO Nilsson		Bug fix, toke the wrong input IF old style photocells..
09-11-30				V1.12.5	PO Nilsson		Bug fix FOR the Lead AND Rear EDGE detection...
09-11-22				V1.12.4	PO Nilsson		Bug fix FOR the Hanger out error..
09-11-18				V1.12.3	PO Nilsson		Added FUNCTION TO handle the extra run OF Infeed belt when hanger goes in TO machine...
09-11-16				V1.12.2 PO Nilsson		Force Pyjamas was also added here TO get the Infeed belt stop correct..		
09-11-13				V1.12.1 PO Nilsson		Stop TopConveyor when we have the Hanger out error i Hanger Opener..	
09-11-03				V1.12.0	PO Nilsson		Found bad bug with Discount, was always set AND was triggered when motor was running..
												The motor was always stop at holdpoint due TO changes in the code that caused other parts TO NOT work correct..
09-11-02				V1.11.4 PO Nilsson		New photocell FUNCTION with only vertical photocells...
09-10-27				V1.11.3 PO Nilsson		Removed machine manager index from init part OF Top conveyor.
09-10-20				V1.11.2 PO Nilsson 		Changed discount FOR puls counting..
09-10-01				V1.11.1 PO Nilsson		Bug fixes on site Holbaek
09-09-08				V1.11.0	PO Nilsson		Removed [0..1] records in AutoProgram type
09-03-10				V1.10 	PO Nilsson		Adapted from Tematic TO Fox..
08-07-01				V1.01 	Sten Flystedt	First edition...
---------------------------------------------------------------------------------------*)
	
	IF EDGEPOS(g_Core.System.Runtime.isRunning) THEN
		StopTask := 0;
	END_IF

	(*#####################*)
	(* Get current time... *)
	(*#####################*)
	g_TopConveyorProcess.Common.CurTimer := g_Timers._1_ms;						(* Get current time *)
	IF g_TopConveyorProcess.Common.LogBookFlag > 0 THEN
		strcpy(ADR(TmpStr),ADR(g_TopConveyorProcess.Common.Description));
	END_IF

	// Run TC to correct belts after jam
	IF EDGEPOS(g_Core.System.Runtime.isRunning) AND g_GuardHasOpened THEN
		g_GuardHasOpened := FALSE;
		RunTurnAround_TOF.IN := NOT IBHorizontal;
	END_IF
	RunTurnAround_TOF(PT := T#3s);
	RunTurnAround_TOF.IN := FALSE;
	g_CorrectBeltsTurnAround := RunTurnAround_TOF.Q;

	// Turnaround photocells still covered after correct belts
	IF EDGENEG(g_CorrectBeltsTurnAround) AND (IBVertical[1] OR IBVertical[2]) THEN
		g_TopConveyorProcess.Common.ErrorCode := 9;
		g_TopConveyorProcess.Common.State := MACHPROC_TRIG_ERROR_98;
	END_IF	

	// Photocell modes at Turnaround photocells for Rear edge measurment
	CASE g_TopConveyorProcess.Common.Product.ProductType OF

		TROUSER_TYPE_0:	// Trousers
			IF g_ACfg[ACfgProgram].PhTrousers.TwoVerticalRear THEN
				RTurnVertical := IBVertical[1] AND IBVertical[2];
			ELSE
				RTurnVertical := IBVertical[1] OR IBVertical[2];
			END_IF			
			BTurn[0].In := RTurnVertical OR (IBHorizontal OR g_sim.IBHorizontal) AND g_ACfg[ACfgProgram].PhTrousers.UseHorizontalRear;
			BTurn[1].In := (IBXAFold OR g_sim.IBXAFold) OR IBXAFoldHorizontal AND g_ACfg[ACfgProgram].PhTrousers.UseHorizontalLead;
	
		SHIRT_TYPE_1: // Shirts
			IF g_ACfg[ACfgProgram].PhShirt.TwoVerticalRear THEN
				RTurnVertical := IBVertical[1] AND IBVertical[2];
			ELSE
				RTurnVertical := IBVertical[1] OR IBVertical[2];
			END_IF			
			BTurn[0].In := RTurnVertical OR (IBHorizontal OR g_sim.IBHorizontal) AND g_ACfg[ACfgProgram].PhShirt.UseHorizontalRear;
			BTurn[1].In := (IBXAFold OR g_sim.IBXAFold) OR IBXAFoldHorizontal AND g_ACfg[ACfgProgram].PhShirt.UseHorizontalLead;

		ELSE // Flap trousers or other types
			IF g_ACfg[ACfgProgram].PhFlapTrousers.TwoVerticalRear THEN
				RTurnVertical := IBVertical[1] AND IBVertical[2];
			ELSE
				RTurnVertical := IBVertical[1] OR IBVertical[2];
			END_IF			
			BTurn[0].In := RTurnVertical OR (IBHorizontal OR g_sim.IBHorizontal) AND g_ACfg[ACfgProgram].PhFlapTrousers.UseHorizontalRear;
			BTurn[1].In := (IBXAFold OR g_sim.IBXAFold) OR IBXAFoldHorizontal AND g_ACfg[ACfgProgram].PhFlapTrousers.UseHorizontalLead;
	END_CASE

	BTurn[0]();
	BTurn[1]();

	IF BTurnVertical.Out THEN
		Ph1NegCountStampWhl := g_WheelCounter;
	END_IF

	// For check test
	IF EDGEPOS(BTurn[0].Out) THEN
		TCLinen.Check_Ph1PosCountStampWhl := g_WheelCounter;
	END_IF
	IF EDGENEG(BTurn[0].Out) THEN
		TCLinen.Check_Ph1NegCountStampWhl := g_WheelCounter;
	END_IF
	IF EDGEPOS(BTurn[1].Out) THEN
		TCLinen.Check_Ph2PosCountStampWhl := g_WheelCounter;
	END_IF

	IF EDGEPOS(BTurn[0].Out) THEN
		Ph[0] := g_WheelCounter;
	END_IF
	IF EDGEPOS(BTurn[1].Out) THEN
		Ph[1] := g_WheelCounter;
		Dist := Ph[1] - Ph[0];
	END_IF

	IF EDGEPOS(BTurn[0].Out) THEN
		PhEdge[0] := g_WheelCounter;
	END_IF
	IF EDGENEG(BTurn[0].Out) THEN
		PhEdge[1] := g_WheelCounter;
		LengtPh1Edge := PhEdge[1] - PhEdge[0];
	END_IF

	(*#################################*)
	(* copy status of exchange objects *)
	(*#################################*)
	IF g_HCfg.FeedManual THEN
		g_TopConveyorProcess.Common.Previous := g_ManualInletProcess.Common.Next;
		g_TopConveyorProcess.Common.Next := g_LateralProcess.Common.Previous;
	ELSE
		g_TopConveyorProcess.Common.Previous := g_HangerOpenerProcess.Common.Next;
		g_TopConveyorProcess.Common.Next := g_LateralProcess.Common.Previous;
	END_IF

	(*########################################*)
	(* Connect inputs to the module structure *)
	(*########################################*)
	g_TopConveyorProcess.Common.InSensor.Input := IBVertical[1];
	g_TopConveyorProcess.Common.InSensor2.Input := IBVertical[2];
	g_TopConveyorProcess.Common.InSensor3.Input := IBVertical[3];
	g_TopConveyorProcess.HorizontalSensor.Input := IBHorizontal;					// Horizontal in sensor

	(*######################*)
	(* Connect timer values *)
	(*######################*)
	g_TopConveyorProcess.Common.WatchDogRunTime := 6500;		
	// Timer is icreesed at manual feed since distance to first ph is longer as in AutoFeed
	IF g_HCfg.FeedManual THEN
		g_TopConveyorProcess.Common.WatchDogRunTime := 4500;		
	END_IF

	g_TopConveyorProcess.Common.WatchDogStartupTime := 4000;
	g_TopConveyorProcess.Common.InSensor.OnDelay := 5;
	g_TopConveyorProcess.Common.InSensor.OffDelay := 5;
	g_TopConveyorProcess.Common.InSensor2.OnDelay := 5;
	g_TopConveyorProcess.Common.InSensor2.OffDelay := 5;
	g_TopConveyorProcess.Common.InSensor3.OnDelay := 5;
	g_TopConveyorProcess.Common.InSensor3.OffDelay := 5;
	g_TopConveyorProcess.HorizontalSensor.OnDelay := 5;
	g_TopConveyorProcess.HorizontalSensor.OffDelay := 5;
	g_TopConveyorProcess.Common.ExitTime := 10;										// Fixed distance from photocell 
	g_TopConveyorProcess.InFeedBeltOnTime := g_MCfg.TC.InfeedBeltOnTime;
	//g_TopConveyorProcess.ExpectedPhCount := 50; Value set in declare.

	RunIOCounter(g_TopConveyorProcess.HorizontalSensor,g_TopConveyorProcess.Common.CurTimer);

	RunFoldTask(g_MCfg.Trace2File, ADR(T2FD), g_TopConveyorProcess.Common,g_MachineManager[g_TopConveyorProcess.Common.MachineManagerIndex]);


	// If the hanger does not come out of the Hanger opener we need to stop asap..	
	IF EDGEPOS((g_TopConveyorProcess.Common.Previous.TransferStatus = EXC_ERROR_99) AND (g_TopConveyorProcess.Common.State < MACHPROC_TRIG_ERROR_98) AND NOT g_HCfg.FeedManual) OR (g_HangerOpenerProcess.Common.ErrorCode=5) THEN
		g_TopConveyorProcess.Common.Motor.cmdStop := TRUE;
		IF g_TopConveyorProcess.Common.State >= MACHPROC_RUN_20 AND g_TopConveyorProcess.Common.State < MACHPROC_HOLP_POINT_85 THEN
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_TopConveyorProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'TC, Trig error from Hanger Opener');
			g_TopConveyorProcess.Common.ErrorCode := 0;
			g_ToLatFold_StopJam := TRUE;
			g_TopConveyorProcess.Common.State := MACHPROC_TRIG_ERROR_98;
		END_IF
	END_IF	
	
	IF g_TopConveyorProcess.Common.Previous.TransferStatus = 0 THEN
		g_CountStamp[1] := 0;
	END_IF

	IF (g_TopConveyorProcess.Common.Previous.TransferStatus = EXC_WANT_TO_UNLOAD_1) AND (g_CountStamp[1] = 0) THEN
		g_CountStamp[0] := g_MilliSeconds;
		g_CountStamp[1] := 1;
	END_IF
	IF (g_TopConveyorProcess.Common.Previous.TransferStatus = 3) AND (g_CountStamp[3] = 0) THEN
		g_CountStamp[3] := g_MilliSeconds - g_CountStamp[0];
	END_IF
	IF (g_TopConveyorProcess.Common.Previous.TransferStatus = 5) AND (g_CountStamp[5] = 0) THEN
		g_CountStamp[5] := g_MilliSeconds - g_CountStamp[0];
	END_IF

	CASE g_TopConveyorProcess.Common.State OF
		(*####################################*)
		(* Start Up Machine, Home Axels etc.. *)
		(*####################################*)	
		MACHPROC_INIT_0:

			// To stop it if E-stop is pressed...	
			g_TopConveyorProcess.InfeedBeltMotor := FALSE;
			g_TopConveyorProcess.StopInFeedBelt.State := FOLDIO_STATE_IDLE_0;
			g_TopConveyorProcess.InFeedBeltOnTimer := g_TopConveyorProcess.Common.CurTimer;

		MACHPROC_STARTUP_1:

			// If a garment is present in the Turn around conveyor
			g_TopConveyorProcess.Common.AlarmList.Alarm[11] := FALSE;
			IF NOT g_CorrectBeltsTurnAround THEN
				IF g_TopConveyorProcess.Common.InSensor.Output OR g_TopConveyorProcess.HorizontalSensor.Output THEN
					g_TopConveyorProcess.Common.ErrorCode := 4;
					g_TopConveyorProcess.Common.State := MACHPROC_TRIG_ERROR_98;
//				ELSIF BTurn[1].Out THEN
//					// Wait for XA before is ready after startup
//					g_TopConveyorProcess.Common.AlarmList.Alarm[11] := ElapsedMsTime(g_TopConveyorProcess.Common.CurTimer, g_TopConveyorProcess.InFeedBeltOnTimer) > 2000;
				ELSE
					g_TopConveyorProcess.Common.ReadParameters := TRUE;		(* Set it already here sins data is copied in case MACHPROC_RUN_20 *)

					g_TopConveyorProcess.Common.Previous.TransferStatus := EXC_STANDBY_0;
					g_TopConveyorProcess.Common.State := MACHPROC_RUN_20;
					g_TopConveyorProcess.Common.WatchDogRunTimer := g_TopConveyorProcess.Common.CurTimer;					(* start watchdog timer for process *)
					g_TopConveyorProcess.InfeedBeltMotor := FALSE;
					g_TopConveyorProcess.StopInFeedBelt.State := FOLDIO_STATE_IDLE_0;
				END_IF	
			END_IF	

			(*###############################################################*)
			(* Machine Stop case, to handle shut down process of the module  *)
			(*###############################################################*)
		MACHPROC_STOP_15:
			;
			(* Reset output and handle the shutdown procedure *)
			(* Extra stop cases may be needed.. *)

			g_TopConveyorProcess.Common.State := MACHPROC_INIT_0;
			g_TopConveyorProcess.Common.FoldUnit1.State := 0;
			g_TopConveyorProcess.Common.FoldUnit2.State := 0;
			g_TopConveyorProcess.Common.Motor.cmdStop := TRUE;
			g_TopConveyorProcess.InfeedBeltMotor := FALSE;
			g_TopConveyorProcess.StopInFeedBelt.State := FOLDIO_STATE_IDLE_0;

			(*#####################*)
			(* Main running state  *)
			(*#####################*)
		MACHPROC_RUN_20:
			(* Ensure correct fold program is loaded into task *)
			(*g_TopConveyorProcess.Parameters := LocalFoldProgram.Inlet;*)

			g_StartXAConveyor := 0;	
			IF g_WheelCounter > StopTopConveyor AND NOT g_HCfg.FeedManual THEN
				g_TopConveyorProcess.Common.Motor.cmdStop := TRUE;
			END_IF
			IF g_TopConveyorProcess.Common.Previous.TransferStatus = EXC_WANT_TO_UNLOAD_1 THEN					(* Ready to feed garment *)
				IF BTurn[0].Out THEN
					g_TopConveyorProcess.Common.ErrorCode := 10;
					g_TopConveyorProcess.Common.State := MACHPROC_TRIG_ERROR_98;
				ELSE
					g_TopConveyorProcess.Common.Previous.TransferStatus := EXC_READY_TO_RECIEVE_2;
					IF g_HCfg.FeedManual THEN
						g_TopConveyorProcess.Common.Motor.cmdForward := TRUE;
					END_IF			
				END_IF
			ELSIF (g_TopConveyorProcess.Common.Previous.TransferStatus = EXC_UNLOADING_3) THEN
				g_TopConveyorProcess.Common.State := MACHPROC_DELIVER_PACKAGE_80;
			ELSIF (g_TopConveyorProcess.Common.Previous.TransferStatus = 99) THEN  //PWC 26-04-2017:Stop motor if not Garment detection PH in time
				IF g_HCfg.FeedManual THEN
					g_TopConveyorProcess.Common.Motor.cmdStop := TRUE;
				END_IF
			END_IF

		MACHPROC_DELIVER_PACKAGE_80:

			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_TopConveyorProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Inl, Start from top');
			g_TopConveyorProcess.Common.Product := g_TopConveyorProcess.Common.Previous.Product;
			ACfgProgram := LIMIT(0, g_TopConveyorProcess.Common.Product.FoldProgram - 1, 98);

			// Copy Timer 
			g_TopConveyorProcess.BlowPointTime := g_ACfg[ACfgProgram].TrouserBlowPoint;
			g_TopConveyorProcess.TrouserBlast.StartDelayTime := g_ACfg[ACfgProgram].DelayTrouserBlast;
			g_TopConveyorProcess.TrouserBlast.OnTime := g_ACfg[ACfgProgram].OnTimeTrouserBlast;
			g_TopConveyorProcess.StopInFeedBelt.StartDelayTime := g_ACfg[ACfgProgram].InFeedBeltStopDelay;
			g_TopConveyorProcess.StopInFeedBelt.OnTime := g_ACfg[ACfgProgram].InFeedBeltStopTime;
	
			g_TopConveyorProcess.Common.Product.Length := 0;
			g_TopConveyorProcess.Common.Motor.cmdForward := TRUE;								(* Start motor.. *)
			g_TopConveyorProcess.StopInFeedBelt.State := FOLDIO_STATE_START_1;		// start inletBelt (it will start after a delay)
//			InfeedBeltStop.Set := TRUE;
//			g_TopConveyorProcess.InfeedBeltMotor := TRUE;								(* Start infeed belt *)
			g_TopConveyorProcess.Common.WatchDogRunTimer := g_TopConveyorProcess.Common.CurTimer;		(* start watchdog timer for process *)
			g_TopConveyorProcess.InFeedBeltOnTimer := g_TopConveyorProcess.Common.CurTimer;
			g_TopConveyorProcess.ExpectedPhCounter := g_SpeedCountOfWheel;

			// Start Inlet (Overall function)...
			IF g_HCfg.OverallAlignment THEN
				IF g_TopConveyorProcess.Common.Product.Size > 2400 THEN
					g_HangerInletProcess.InletBeltTC1Start.State := FOLDIO_STATE_START_1;
				ELSE	
					g_HangerInletProcess.InletBeltTC1Start.State := FOLDIO_STATE_IDLE_0;
				END_IF	
			END_IF		

			// What type of garments to stop make stretch stop on 
			CASE g_ACfg[ACfgProgram].InFeedStopOnTrousers OF
		
				0:	// Stop on Shirst and pyjamas
					IF ((g_TopConveyorProcess.Common.Product.ProductType = SHIRT_TYPE_1) OR (g_TopConveyorProcess.Common.Product.ProductType = PYJAMAS_TYPE_2)) THEN 
//						IF g_TopConveyorProcess.StopInFeedBelt.State = FOLDIO_STATE_IDLE_0 THEN		// Only log once..
//							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_TopConveyorProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Inl, Inter. stop infeed Shirts');
//						END_IF	
						//						g_TopConveyorProcess.StopInFeedBelt.State := FOLDIO_STATE_START_1;
						g_TopConveyorProcess.StopInFeedBelt.StartDelayTime := g_ACfg[ACfgProgram].InFeedBeltStopDelay;
					ELSE
						g_TopConveyorProcess.StopInFeedBelt.StartDelayTime := 0;
					END_IF
		
		
				1:	// Stop on Trouser
					IF (g_TopConveyorProcess.Common.Product.ProductType = TROUSER_TYPE_0) THEN 
//						IF g_TopConveyorProcess.StopInFeedBelt.State = FOLDIO_STATE_IDLE_0 THEN		// Only log once..
//							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_TopConveyorProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Inl, Inter. stop infeed Trousers');
//						END_IF	
//						g_TopConveyorProcess.StopInFeedBelt.State := FOLDIO_STATE_START_1;
						g_TopConveyorProcess.StopInFeedBelt.StartDelayTime := g_ACfg[ACfgProgram].InFeedBeltStopDelay;
					ELSE
						g_TopConveyorProcess.StopInFeedBelt.StartDelayTime := 0;	
					END_IF
		
		
				2:	// Stop on Shirts, Pyjamas and Trouser..
					g_TopConveyorProcess.StopInFeedBelt.StartDelayTime := g_ACfg[ACfgProgram].InFeedBeltStopDelay;
//					IF g_TopConveyorProcess.StopInFeedBelt.State = FOLDIO_STATE_IDLE_0 THEN		// Only log once..
//						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_TopConveyorProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Inl, Inter. stop infeed all types');
//					END_IF	
//					g_TopConveyorProcess.StopInFeedBelt.State := FOLDIO_STATE_START_1;						
			END_CASE	
	
			(* Set flank counters *)
			g_TopConveyorProcess.Common.InSensor.OldEdgeCounter := g_TopConveyorProcess.Common.InSensor.EdgeCounter;
			g_TopConveyorProcess.Common.InSensor2.OldEdgeCounter := g_TopConveyorProcess.Common.InSensor.EdgeCounter;
			g_TopConveyorProcess.Common.InSensor3.OldEdgeCounter := g_TopConveyorProcess.Common.InSensor.EdgeCounter;
			g_TopConveyorProcess.HorizontalSensor.OldEdgeCounter := g_TopConveyorProcess.HorizontalSensor.EdgeCounter;
			EdgeFoundCounter := 0;	
	
			// 09-08-11
			IF g_TopConveyorProcess.BlowPointTime = 0 THEN
				IF (g_TopConveyorProcess.Common.Previous.TransferStatus < EXC_RECIVING_4) AND NOT g_ACfg[ACfgProgram].DeloaderHeavyGarment THEN
					g_TopConveyorProcess.Common.Previous.TransferStatus := EXC_RECIVING_4;
				END_IF	
				g_TopConveyorProcess.Common.State := MACHPROC_WAIT_LEADEDGE_81;
			ELSE
				g_TopConveyorProcess.BlowPointTimer := g_TopConveyorProcess.Common.CurTimer;
				g_TopConveyorProcess.Common.State := MACHPROC_STOP_AIRBLAST_30;
			END_IF
	
		MACHPROC_STOP_AIRBLAST_30:
			// To make an Air blast for trouser with the wristlets folded once	
			IF ElapsedMsTime(g_TopConveyorProcess.Common.CurTimer, g_TopConveyorProcess.BlowPointTimer) >= g_TopConveyorProcess.BlowPointTime THEN
				g_TopConveyorProcess.Common.Motor.cmdStop	 := TRUE;								(* Stop motor.. *)
				g_TopConveyorProcess.StopInFeedBelt.State := FOLDIO_STATE_IDLE_0;
//				g_TopConveyorProcess.InfeedBeltMotor := FALSE;								(* Stop infeed belt *)	
				g_TopConveyorProcess.TrouserBlast.State := FOLDIO_STATE_START_1;
				g_TopConveyorProcess.Common.WatchDogRunTimer := g_TopConveyorProcess.Common.CurTimer;							(* start watchdog timer for process *)
				g_TopConveyorProcess.Common.State := MACHPROC_DO_AIRBLAST_35;
			END_IF

		MACHPROC_DO_AIRBLAST_35:
			// Make the air blast for trouser with folded wristlets..
			IF g_TopConveyorProcess.TrouserBlast.State = FOLDIO_STATE_IDLE_0 THEN
				g_TopConveyorProcess.Common.Motor.cmdForward := TRUE;								(* Start motor.. *)
				g_TopConveyorProcess.StopInFeedBelt.State := FOLDIO_STATE_START_1;
//				g_TopConveyorProcess.InfeedBeltMotor := TRUE;								(* Start infeed belt *)
				g_TopConveyorProcess.Common.WatchDogRunTimer := g_TopConveyorProcess.Common.CurTimer;		(* start watchdog timer for process *)
				g_TopConveyorProcess.InFeedBeltOnTimer := g_TopConveyorProcess.Common.CurTimer;
				g_TopConveyorProcess.ExpectedPhCounter := g_SpeedCountOfWheel;
				g_TopConveyorProcess.Common.State := MACHPROC_WAIT_LEADEDGE_81;
		
				//MKH Brolli like changes--Speed up
				IF (g_TopConveyorProcess.Common.Previous.TransferStatus < EXC_RECIVING_4) AND NOT g_ACfg[ACfgProgram].DeloaderHeavyGarment THEN
					g_TopConveyorProcess.Common.Previous.TransferStatus := EXC_RECIVING_4;
				END_IF	
			END_IF			

		MACHPROC_WAIT_LEADEDGE_81:
			// Reset every time a new garment goes into top conveyor..
			// Start measuring the garment...
			
			IF BTurn[0].Out AND ElapsedMsTime(g_SpeedCountOfWheel, g_TopConveyorProcess.ExpectedPhCounter) >= g_TopConveyorProcess.ExpectedPhCount THEN					// If two photocells covered at Leading edge..
				LatestTCLinen := TCLinen;
				TCLinen := EmptyTCLinen;
				TCLinen.Ph1PosCountStampWhl := g_WheelCounter;
				g_TopConveyorProcess.StartPoint := g_SpeedCountOfWheel;
				g_SpeedCountOfWheel := 0;
				g_TopConveyorProcess.Common.Product.Length := 0;
				g_TopConveyorProcess.InfeedBeltMotor := FALSE;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_TopConveyorProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'TC Lead edge detected');

				IF (g_TopConveyorProcess.Common.Previous.TransferStatus < EXC_RECIVING_4) AND g_ACfg[ACfgProgram].DeloaderHeavyGarment THEN
					g_TopConveyorProcess.Common.Previous.TransferStatus := EXC_RECIVING_4;
				END_IF	

				g_TopConveyorProcess.Common.State := MACHPROC_HOLP_POINT_85;
			END_IF

			// Stop Infeed belt after a time...
			IF ElapsedMsTime(g_TopConveyorProcess.Common.CurTimer, g_TopConveyorProcess.InFeedBeltOnTimer) >= g_ACfg[ACfgProgram].InFeedBeltStopTime THEN //g_ACfg[ACfgProgram].InFeedBeltStopTime g_TopConveyorProcess.InFeedBeltOnTime
				IF g_HCfg.FeedManual THEN
					IF NOT g_ManualInletProcess.Inputs.ReachedInfeedBeltEnd.Output THEN
						g_TopConveyorProcess.InfeedBeltMotor := FALSE;
						g_TopConveyorProcess.StopInFeedBelt.State := FOLDIO_STATE_IDLE_0;
					END_IF					
				ELSE
					g_TopConveyorProcess.InfeedBeltMotor := FALSE;
					g_TopConveyorProcess.StopInFeedBelt.State := FOLDIO_STATE_IDLE_0;
				END_IF
			END_IF

			(* Finish the handshake with the hanger opener *)
			IF g_TopConveyorProcess.Common.Previous.TransferStatus = EXC_FINISHED_UNLOADING_5 THEN
				g_TopConveyorProcess.Common.Previous.TransferStatus := EXC_RECIVING_DONE_6;
			END_IF		

		MACHPROC_HOLP_POINT_85:
			g_TopConveyorProcess.Common.WatchDogRunTimer := g_TopConveyorProcess.Common.CurTimer;							(* start watchdog timer for process *)

			(* Finish the handshake with the hanger opener *)
			IF g_TopConveyorProcess.Common.Previous.TransferStatus = EXC_FINISHED_UNLOADING_5 THEN
				g_TopConveyorProcess.Common.Previous.TransferStatus := EXC_RECIVING_DONE_6;
			END_IF

			//############################################################################################################
			// Stop motor if Lateral is not ready, Second inparameter should be zero sins counter is reset at leading..
			//############################################################################################################
			IF EDGEPOS(ElapsedMsTime(g_SpeedCountOfWheel, 0) >= parHoldPosition) THEN			
				IF g_TopConveyorProcess.Common.Motor.State = MOTOR_STATE_RUN_2 THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 9, g_TopConveyorProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Inl, Stop at Hold Point');
				END_IF
				g_TopConveyorProcess.Common.Motor.cmdHold := TRUE;
			END_IF
			TOF_blockFromDuo(IN:= g_DuoInletProcess.requestDelivery, PT:= T#1500ms);
			(* Handshake with the Lateral fold belt *)
			IF (NOT g_DuoInletProcess.requestDelivery OR NOT TOF_blockFromDuo.Q) AND NOT TestHold THEN
				//CWH(*
				// When both inlet are inuse, ensure that Duo_Inlet is allowed to run every 2-3 times
				IF g_FlipInlet <= DUO_FLIP_INLET_02 THEN
					g_FlipInlet := g_FlipInlet + 1;
				END_IF 
				//CWH		*)
				IF  (g_TopConveyorProcess.Common.Next.TransferStatus = EXC_STANDBY_0) AND (ForcedHoldTest = 0) AND NOT g_DuoInletProcess.requestDelivery (*AND NOT g_DuoInletProcess.IBInlet*) THEN 
					g_TopConveyorProcess.Common.Next.TransferStatus := EXC_WANT_TO_UNLOAD_1;
				ELSIF g_TopConveyorProcess.Common.Next.TransferStatus = EXC_READY_TO_RECIEVE_2 THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_TopConveyorProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Inl, hold point');
					g_TopConveyorProcess.Common.Motor.cmdHold := FALSE;
					g_TopConveyorProcess.Common.Motor.cmdForward := TRUE;		// Has priority over Stop and Hold...
					g_TopConveyorProcess.Common.Next.TransferStatus := EXC_UNLOADING_3;
				ELSIF g_TopConveyorProcess.Common.Next.TransferStatus = EXC_RECIVING_4 THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 9, g_TopConveyorProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Inl, Continue');
					g_TopConveyorProcess.Common.Motor.cmdHold := FALSE;
					g_TopConveyorProcess.Common.Motor.cmdForward := TRUE;		// Has priority over Stop and Hold...
					HoldStartCount := g_SpeedCountOfWheel;
					Ph2CountStampWhl := 0;
					Ph2CountStampMs := 0;
					Ph2NegCountStampMs := 0;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 1, g_TopConveyorProcess.Common.LogBookFlag, UDINT_TO_UINT(g_WheelCounter), 'TC, Goto MACHPROC_WAIT_REAREDGE_90');
		
					LongPiece := FALSE;
					g_TopConveyorProcess.Common.State := MACHPROC_WAIT_REAREDGE_90;
				END_IF
			END_IF
	
		MACHPROC_WAIT_REAREDGE_90:
			HoldDifference := HoldStartCount - HoldStopCount;
	
			// Let it run a little before we check for trailing edge..
			IF g_SpeedCountOfWheel > RunBeforeRearEdge THEN	

				IF (g_WheelCounter > TCLinen.Ph1PosCountStampWhl + g_MCfg.TC.TurnerDistancePh - StartXAOffset) AND NOT LongPiece THEN
					MeasureProduct := g_TopConveyorProcess.Common.Product;
					GoMeasure := TRUE;
					LongPiece := TRUE;
				END_IF

				// Trail edge was found...	
				IF NOT BTurn[0].Out THEN
					TCLinen.Ph1NegCountStampWhl := g_WheelCounter;
					g_TopConveyorProcess.StopPoint := g_SpeedCountOfWheel;
					g_TopConveyorProcess.Common.Product.LengthWheel := g_SpeedCountOfWheel;
					g_TopConveyorProcess.Common.Product.Length := (g_SpeedCountOfWheel * WHEEL_INC_TO_DISTANCE_MM) / 100;
					g_TopConveyorProcess.Common.Product.LengthNoDisc := g_TopConveyorProcess.Common.Product.Length;
					g_ToLatFold.RearPoint := g_WheelCounter;
					g_TopConveyorProcess.Common.ExitTimer := g_SpeedCountOfWheel;
					IF (TCLinen.Ph1NegCountStampWhl - TCLinen.Ph1PosCountStampWhl) < 60 THEN
						FailCount := FailCount + 1;
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 1, g_TopConveyorProcess.Common.LogBookFlag, UDINT_TO_UINT(g_WheelCounter), 'TC, Trail-Fail');
					END_IF				
			
					IF NOT LongPiece THEN
						MeasureProduct := g_TopConveyorProcess.Common.Product;
						GoMeasure := TRUE;
					END_IF
					LongPiece := FALSE;
					g_TopConveyorProcess.Common.State := 92;
				END_IF
			END_IF

		92:			
			(* Finish the handshake with the hanger opener *)
			IF g_TopConveyorProcess.Common.Previous.TransferStatus >= EXC_FINISHED_UNLOADING_5 OR g_TopConveyorProcess.Common.Previous.TransferStatus = EXC_STANDBY_0 THEN
				g_TopConveyorProcess.Common.Previous.TransferStatus := EXC_STANDBY_0;
				StopTopConveyor := g_WheelCounter + g_MCfg.TC.TurnerDistancePh + 50;
				g_TopConveyorProcess.Common.State := MACHPROC_RUN_20;
			END_IF
			
		MACHPROC_TRIG_ERROR_98:		
			g_TopConveyorProcess.Common.Previous.TransferStatus := EXC_ERROR_99;
			g_StartXAConveyor := 0;	
			g_TopConveyorProcess.Common.Motor.cmdStop := TRUE;

		MACHPROC_ERROR_99:		
			g_TopConveyorProcess.Common.Motor.cmdStop := TRUE;
			g_HangerInletProcess.InletBeltTC1Start.State := FOLDIO_STATE_IDLE_0;
			g_TopConveyorProcess.Common.Previous.TransferStatus := EXC_STANDBY_0;
			g_TopConveyorProcess.InfeedBeltMotor := FALSE;
			g_TopConveyorProcess.StopInFeedBelt.State := FOLDIO_STATE_IDLE_0;
	END_CASE

	CASE MeasureState OF		
		// ------------------------------------------------------------------------------------------------------------------------------------------------------------
		0:	// Waiting for garment
			// ------------------------------------------------------------------------------------------------------------------------------------------------------------
			IF GoMeasure THEN
				GoMeasure := FALSE;
				MeasureState := 30;
			END_IF

			// ------------------------------------------------------------------------------------------------------------------------------------------------------------
		30:	// Measure
			// ------------------------------------------------------------------------------------------------------------------------------------------------------------

			IF EDGEPOS(g_WheelCounter > TCLinen.Ph1PosCountStampWhl + g_MCfg.TC.TurnerDistancePh - StartXAOffset) THEN
				AutoProgramNumberIBXA := MeasureProduct.FoldProgram;
				g_StartXAConveyor := TRUE;	
			END_IF

			// Lead B
			IF g_WheelCounter > TCLinen.Ph1PosCountStampWhl + g_MCfg.TC.TurnerDistancePh - ExpectedOffSet THEN
				IF BTurn[1].Out AND (TCLinen.Ph2PosCountStampWhl = 0) THEN
					TCLinen.Ph2PosCountStampWhl := g_WheelCounter;
					g_TopConveyorProcess.Common.Product.LeadEdgeXA := g_DummyPulses;
					MeasureProduct.LeadEdgeXA := g_DummyPulses;
				END_IF
			END_IF

			// Garment measured
			IF (TCLinen.Ph2PosCountStampWhl > 0) AND (TCLinen.Ph1NegCountStampWhl > 0) THEN
				TCLinen.LengthWhl := UDINT_TO_UINT(g_MCfg.TC.TurnerDistancePh - (TCLinen.Ph2PosCountStampWhl - TCLinen.Ph1NegCountStampWhl));
				TCLinen.Length_mm := (TCLinen.LengthWhl * WHEEL_INC_TO_DISTANCE_MM) / 100;

				TCLinen.LengthWhl1Ph := UDINT_TO_UINT(TCLinen.Ph1NegCountStampWhl - TCLinen.Ph1PosCountStampWhl);
				TCLinen.Length1Ph_mm := (TCLinen.LengthWhl1Ph * WHEEL_INC_TO_DISTANCE_MM) / 100;

				g_ToLatFold.PosBPoint := g_WheelCounter;
				IF TCLinen.Ph2PosCountStampWhl > TCLinen.Ph1NegCountStampWhl THEN
					g_ToLatFold.Diff := TCLinen.Ph2PosCountStampWhl - TCLinen.Ph1NegCountStampWhl + DistOrgNewPh;
				ELSE
					g_ToLatFold.Diff := DistOrgNewPh;
				END_IF
			END_IF				

			// Garment measured
			IF TCLinen.Length_mm > 0 THEN

				g_StartXAConveyor := 0;	
				TCLinen.LengthOrgTC_mm := MeasureProduct.Length;
				TCLinen.ProductID := MeasureProduct.ID;
		
				// The extra time garment hase moved after original photocell
				// g_MCfg.TurnerDistOrgNewWhl

				IF TCLinen.Ph2PosCountStampWhl > TCLinen.Ph1NegCountStampWhl THEN
					TCLinen.ExtraRunTime := (TCLinen.Ph2PosCountStampWhl - TCLinen.Ph1NegCountStampWhl);
				ELSE
					TCLinen.ExtraRunTime := 0;
				END_IF					
				MeasureProduct.TCExtraRunTime := UDINT_TO_UINT(TCLinen.ExtraRunTime);

				// Squeeze in extended measure
				MeasureProduct.Length := TCLinen.Length_mm;
				g_HMILengthCM := MeasureProduct.Length / 10;
				// check oversize max length 2.5m MKH
				IF MeasureProduct.Length > 2500 THEN
					g_TopConveyorProcess.Common.ErrorCode := 7;
					g_TopConveyorProcess.Common.State := MACHPROC_TRIG_ERROR_98;
					g_LateralProcess.Common.Motor.cmdStop := TRUE;
					g_CrossFoldAProcess.Common.Motor.cmdStop:= TRUE;
				ELSE		
		
					g_TopConveyorProcess.Common.Next.Product := MeasureProduct;
					g_TopConveyorProcess.Common.Next.TransferStatus := EXC_FINISHED_UNLOADING_5;	(* Lateral get foldpoint *)
					g_TopConveyorProcess.Common.ExitTimer := g_SpeedCountOfWheel;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 9, g_TopConveyorProcess.Common.LogBookFlag, MeasureProduct.Length, 'Inlet, Shirt Lenght');
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_TopConveyorProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Inlet, Rear edge Shirt');

					MeasureState := MACHPROC_WAIT_BEFORE_EXIT_82;
				END_IF
			END_IF
	
			IF g_TopConveyorProcess.Common.State >= MACHPROC_TRIG_ERROR_98 THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_TopConveyorProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'TC: Measure aborted error');
				MeasureState := 0;
			END_IF
	
			IF g_LateralProcess.Common.State = MACHPROC_ERROR_99 THEN
				g_StartXAConveyor := FALSE;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_TopConveyorProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'TC: Measure aborted error 2');
				MeasureState := 0;
			END_IF		
	
			// Timeout 
			IF NOT g_sim.Test AND (g_WheelCounter > TCLinen.Ph1PosCountStampWhl + g_MCfg.TC.TurnerDistancePh + 100) THEN
				g_StartXAConveyor := FALSE;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_TopConveyorProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'TC: Measure Timeout 2');
				g_TopConveyorProcess.Common.ErrorCode := 8;
				g_TopConveyorProcess.Common.State := MACHPROC_TRIG_ERROR_98;
				g_ToLatFold_StopJam := TRUE;
				MeasureState := 0;
			END_IF

	
		MACHPROC_WAIT_BEFORE_EXIT_82:
			IF g_TopConveyorProcess.Common.State >= MACHPROC_TRIG_ERROR_98 THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_TopConveyorProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'TC: Measure aborted error 2');
				MeasureState := 0;
			ELSIF ElapsedMsTime(g_SpeedCountOfWheel, g_TopConveyorProcess.Common.ExitTimer) > g_TopConveyorProcess.Common.ExitTime OR NOT g_TopConveyorProcess.Common.Motor.Run THEN
				g_TopConveyorProcess.Common.WatchDogRunTimer := g_TopConveyorProcess.Common.CurTimer;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_TopConveyorProcess.Common.LogBookFlag, g_SpeedCountOfWheel, 'Inlet Exit is done');

				IF g_TopConveyorProcess.Common.State = MACHPROC_RUN_20 THEN
					g_TopConveyorProcess.Common.Motor.cmdStop := TRUE;
				END_IF

				MeasureState := 0;
			END_IF
		
	END_CASE
	ActivateFoldIO(g_TopConveyorProcess.StopInFeedBelt, g_TopConveyorProcess.Common.CurTimer);
	ActivateFoldIO(g_TopConveyorProcess.TrouserBlast, g_TopConveyorProcess.Common.CurTimer);

	IF EDGEPOS(BTurn[0].Out) AND RContinouslyTCLinenTest AND NOT TrigTCLinenTest THEN
		TrigTCLinenTest := 1;
	END_IF

	IF EDGEPOS(TrigTCLinenTest) THEN
		TCLinenTest := EmptyTCLinen;
	END_IF

	// MACHPROC_WAIT_REAREDGE_2_91:
	IF TrigTCLinenTest THEN

		// Lead A
		IF BTurn[0].Out AND (TCLinenTest.Ph1PosCountStampWhl = 0) THEN
			TCLinenTest.Ph1PosCountStampWhl := g_WheelCounter;
			TCLinenTest.ProductID := g_TopConveyorProcess.Common.Product.ID;
		END_IF
			
		// Rear
		IF NOT BTurn[0].Out AND (TCLinenTest.Ph1NegCountStampWhl = 0) AND (TCLinenTest.Ph1PosCountStampWhl > 0) AND (g_WheelCounter > TCLinenTest.Ph1PosCountStampWhl + 30) THEN	
			TCLinenTest.Ph1NegCountStampWhl := g_WheelCounter;
		END_IF

		// Lead B
		IF (TCLinenTest.Ph1PosCountStampWhl > 0) AND (g_WheelCounter > TCLinenTest.Ph1PosCountStampWhl + g_MCfg.TC.TurnerDistancePh - ExpectedOffSet) THEN
			IF BTurn[1].Out AND (TCLinenTest.Ph2PosCountStampWhl = 0) THEN
				TCLinenTest.Ph2PosCountStampWhl := g_WheelCounter;
			END_IF
		END_IF
	
		IF (TCLinenTest.Ph2PosCountStampWhl > 0) AND (TCLinenTest.Ph1NegCountStampWhl > 0) THEN
			TCLinenTest.LengthWhl := UDINT_TO_UINT(g_MCfg.TC.TurnerDistancePh - (TCLinenTest.Ph2PosCountStampWhl - TCLinenTest.Ph1NegCountStampWhl));

			TCLinenTest.LengthWhl1Ph := UDINT_TO_UINT(TCLinenTest.Ph1NegCountStampWhl - TCLinenTest.Ph1PosCountStampWhl);

			RToLatFold.PosBPoint := g_WheelCounter;
			IF TCLinenTest.Ph2PosCountStampWhl > TCLinenTest.Ph1NegCountStampWhl THEN
				RToLatFold.Diff := TCLinenTest.Ph2PosCountStampWhl - TCLinenTest.Ph1NegCountStampWhl + DistOrgNewPh;
			ELSE
				RToLatFold.Diff := DistOrgNewPh;
			END_IF
			TrigTCLinenTest := 0;
		
			IF TCLinenTest.ProductID = g_TopConveyorProcess.Common.Next.Product.ID THEN
				IndexVs := (IndexVs + 1) MOD 10;
				DiffExtVsOrg[IndexVs] := TCLinenTest.LengthWhl - g_TopConveyorProcess.Common.Next.Product.LengthWheel;
			END_IF
		END_IF	
	END_IF

	(*###########################################*)
	(* Garment length from MM to CM for mainpage *)
	(*###########################################*)
	g_TopConveyorProcess.LengthInCM := TCLinen.Length_mm / 10;

	IF (g_TopConveyorProcess.Common.Previous.TransferStatus = 2) AND (g_CountStamp[1] = 0) THEN
		g_CountStamp[2] := g_MilliSeconds - g_CountStamp[0];
	END_IF
	IF (g_TopConveyorProcess.Common.Previous.TransferStatus = 4) AND (g_CountStamp[4] = 0) THEN
		g_CountStamp[4] := g_MilliSeconds - g_CountStamp[0];
	END_IF
	IF (g_TopConveyorProcess.Common.Previous.TransferStatus = 6) AND (g_CountStamp[6] = 0) THEN
		g_CountStamp[6] := g_MilliSeconds - g_CountStamp[0];
	END_IF

	(*#########*)
	(* Outputs *)
	(*#########*)
	// Delay Infeed start
	InfeedDelay(IN := g_HangerInletProcess.InFeedBeltRun.Output);

	// Elis MES outputs
	IF g_HCfg.ElisMes THEN
		Q1KRcpBit1 := Q1KRcpBit2 := Q1KRcpBit4 := Q1KRcpBit8 := Q2KRcpBit1 := Q2KRcpBit2 := Q2KRcpBit4 := Q2KRcpBit8 := FALSE;
		SelectedAutoProgram := g_AutoProgram.SelectedAutoProgram;
		IF SelectedAutoProgram >= 80 THEN
			Q1KRcpBit1 := TRUE;
			SelectedAutoProgram := SelectedAutoProgram - 80;
		END_IF

		IF SelectedAutoProgram >= 40 THEN	
			Q1KRcpBit2 := TRUE;
			SelectedAutoProgram := SelectedAutoProgram - 40;
		END_IF

		IF SelectedAutoProgram >= 20 THEN	
			Q1KRcpBit4 := TRUE;
			SelectedAutoProgram := SelectedAutoProgram - 20;
		END_IF

		IF SelectedAutoProgram >= 10 THEN	
			Q1KRcpBit8 := TRUE;
			SelectedAutoProgram := SelectedAutoProgram - 10;
		END_IF

		IF SelectedAutoProgram >= 8 THEN	
			Q2KRcpBit1 := TRUE;
			SelectedAutoProgram := SelectedAutoProgram - 8;
		END_IF

		IF SelectedAutoProgram >= 4 THEN	
			Q2KRcpBit2 := TRUE;
			SelectedAutoProgram := SelectedAutoProgram - 4;
		END_IF

		IF SelectedAutoProgram >= 2 THEN	
			Q2KRcpBit4 := TRUE;
			SelectedAutoProgram := SelectedAutoProgram - 2;
		END_IF

		IF SelectedAutoProgram = 1 THEN	
			Q2KRcpBit8 := TRUE;
			SelectedAutoProgram := 0;
		END_IF

		// Running?
		QKControlPlc := g_Core.System.Runtime.isRunning;

		// Garment on Feeder
		Q1KFeed := IBGarmentDetection;

		// Stacker activated
		Q1KStack := NOT g_StackerProcess[1].FlapsClose AND g_Core.System.Runtime.isRunning; 
	END_IF
	// End of Elis MES 

	InfeedBeltStop(Delay := g_MCfg.TC.DelayStartInfeed, CntAdr := ADR(g_MilliSeconds));
	// -------------------------------------------------------------

//	QMInlet := ((g_TopConveyorProcess.InfeedBeltMotor AND NOT InfeedBeltStop.Out AND NOT g_TopConveyorProcess.StopInFeedBelt.Output) OR (g_ManualInletProcess.Outputs.InFeedBeltMotor.Output AND NOT g_TopConveyorProcess.StopInFeedBelt.Output) OR InfeedDelay.Q OR g_ManualInletProcess.Outputs.ReleaseInfeedBeltJam.Output) AND NOT InletBrake_TOF.Q;
	QMInlet := ( g_TopConveyorProcess.StopInFeedBelt.Output OR g_HangerInletProcess.InFeedBeltRun.Output );
	InletBrake_TOF(IN := EDGENEG(InfeedDelay.Q));
	// QKBrakeInlet := InletBrake_TOF.Q AND NOT DisableInletBrake;
	QKBrakeInlet := NOT QMInlet AND g_Core.System.Runtime.isRunning;
	IF NOT g_MachineManager[3].Service THEN
		QMTopConveyor := (g_TopConveyorProcess.Common.Motor.Run OR g_ManualInletProcess.Outputs.ReleaseInfeedBeltJam.Output (*OR g_CorrectBeltsTurnAround*));
	END_IF
	TopConveyorBrake_TOF(IN := EDGENEG(QMTopConveyor));
	// QKBrakeTopConveyor := TopConveyorBrake_TOF.Q AND NOT DisableTopConveyorBrake;
	QKBrakeTopConveyor := NOT QMTopConveyor AND g_Core.System.Runtime.isRunning;

	// For manual feeding 
	QMInletConvoyerMP := g_ManualInletProcess.Outputs.InletConveyorMotor.Output OR QMInlet OR g_ManualInletProcess.Outputs.ReleaseInfeedBeltJam.Output;
	QYAirTrouser := g_TopConveyorProcess.TrouserBlast.Output;
	// Test 
	g_test_steper.M_TConv.curStep := g_TopConveyorProcess.Common.State;

	RTopConveyorProcess := g_TopConveyorProcess;
END_PROGRAM