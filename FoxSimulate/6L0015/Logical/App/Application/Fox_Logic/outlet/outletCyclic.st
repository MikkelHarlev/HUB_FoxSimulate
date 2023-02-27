PROGRAM _CYCLIC
(* cyclic program *)
(*-------------------------------------------------------------------------------------

Author:   				Sten Flystedt

FileName:				Outlet.scr

Desription:				Outlet


Watch debugg:			Name OF important watch configurations.

History:
18-09-27				V1.08.2	CWH				Modifyed Man outlet so 'ISOutlet[0]' means 1 button TO All (1 Delivery Conv), 'ISOutlet[1..10]' when 1 TO 10x0 
11-07-28				V1.08.1	PO Nilsson		Improved handshake with MLabel, clean up status with Nicolas.
11-07-05				V1.08.0	PO Nilsson		IF wrong options with prining was set, ItemIndex could get out OF arraynsize AND cause Overflow error.
10-12-15				V1.07.9	PO Nilsson		Working printer functionality FOR Padana 40-6020..
10-11-25				V1.07.8	PO Nilsson		Worked on finishing the XML Jenway communication...
10-11-08				V1.07.7	PO Nilsson		Extended handshake with MLabel TO work with a physical printer.. Padana Everest is the first project.	
10-08-09				V1.07.6	PO Nilsson		Option handling OF output QKOutlet... 
												ELSIF in Beltstate = MACHPROC_RUN_20 had a bug, not looking at all statements
10-07-21				V1.07.5	WM				Change FOR test (stop Belt when ph at end OF Belt is covert)
10-06-08				V1.07.4	PO Nilsson		Changed so we could have 10 AND NOT only 8 pieces in a stack...
10-04-28				V1.07.3	PO Nilsson		Jenway communication direct after incline belt on online machine...	
10-04-27				V1.07.2	PO Nilsson		Rermoved member "EmptyBeltCommand" from Outlet, was NOT used...
10-03-31				V1.07.1	PO Nilsson		Added check FOR E-stop on Stacker Roll-off AND Lift Motors, to NOT get restart after E-stop reset...
10-03-30				V1.07.0	PO Nilsson		Error fix FOR extra stacker photocell Online version..
10-03-29				V1.06.9	PO Nilsson		g_OutletProcess.Common.State was never set TO _21 when a new pieces came into stackers..
10-03-25				V1.06.8	PO Nilsson		SaveBeltState must be set before State is Set TO _80..
10-03-24				V1.06.7	PO Nilsson		g_OutletProcess.Parameters[0] are made inte a array TO handle
												different timers on each stacker...
10-03-23				V1.06.6	PO Nilsson		Wrong timers was used FOR Roll offs.
10-03-08				V1.06.5	PO Nilsson		Run roll-off motor when cylinder goes back..
10-02-25				V1.06.4 PO Nilsson		Bug fix time out stacker index, just keept on indexing..
												Bug fix from Midtvask, when in state _50 the global flag was NOT reset correctly.
												So the alarm only pop up ones..	
10-02-22				V1.06.3	PO Nilsson		Index on time out from Hanger inlet...		
10-08-09				V1.06.2	PO Nilsson		No adjust OF lift in state _20 IF Count is 0, conflicting FUNCTION othervise..
10-02-04				V1.06.1	PO Nilsson		Reseted the Previous.Transferstatus at startup.
10-02-04				V1.06.0	PO Nilsson		Removed alarm[5] was wrong gave a alarm every time we made stack change on height with sensor..	
10-01-13				V1.05.9	PO Nilsson		MAX stack height FUNCTION AND some synks from Tematic...
												Input that can block the feed OF more stacks when no cross conveyor...
10-01-11				V1.05.8	PO Nilsson		Bug fix, alarms from Holbaek..
09-12-08				V1.05.7	PO Nilsson		Bug fix, if Coupled OR BeltCoupled had bad values it caused a Range overflow...
09-12-03				V1.05.6	PO Nilsson		Bug fix Overflow in printer part with Multistacker machine...
												Changed the reset OF the Lift NOT down errors...
09-12-02				V1.05.5	PO Nilsson		When stacker goes up empty IF does NOT need TO go below again before ready, smother movement..
												PressTimer was NOT triggered in the correct way...
												LiftRaiseDelay was moved TO a MachineConfig rather THEN Recipe...
09-12-01				V1.05.4	PO Nilsson		Bug fix, Could start stacking before the lift was in _20, was noticed on Holbael machine when wait FOR MiniJenway... 
												Printer data is hadcoded TO StackerUnit 1...
09-11-25				V1.05.3	PO Nilsson		Bug found in Index between StackerGroupLink AND Lift... Alarm LevelSensor added... 
												RollOff Ontime was NOT used but other timer..
09-11-23				V1.05.2	PO Nilsson		Startup delay on lift so they avoid closing OF flaps.
												E-stop OF Belts still unsecure IF it's works..
												Start clearing OF stcakergroupling.transferstatus..
09-11-19				V1.05.1	PO Nilsson		Made a HolBaek Special flag so I can use the same source with Holbaek as the machine with out Minijenway...	
09-11-17				V1.05.0	PO Nilsson		Changed the flow OF the lift so it does NOT go againts the flaps before the garment is there.
												Changed name OF the outputs FOR the lift so it matched the FUNCTION better...
09-11-04				V1.04.3	PO Nilsson		Changed the flow AND copy OF product data TO make the new stack change work better..		
09-11-03				V1.04.2	PO Nilsson		Mini jenway screwed the cross belt FUNCTION in BeltState = _20, this is now NOT compatible with Holbaek...		
09-10-28				V1.04.1	Sten Flystedt	Stackchange is now made IF product has LastItemOnStack-flag set. NO check with stacker.
09-10-15				V1.04.0	PO Nilsson		Start work on Multi Stacker
09-10-14				V1.03.3 PO Nilsson		Changed so Fox makes index on each stack...
09-10-08				V1.03.2 PO Nilsson		Bug fix Printer was NOT PP_STANDBY_10 in singel stack, added some LOG entries..	
09-10-01				V1.03.1 PO Nilsson		Bug fixes on site Holbaek
09-08-13				V1.03.0 Sten Flystedt	Lift now goes up TO doors AND stay with photocell covered.
												No sensor detection the possible FOR dropped garment, using time instead.
												go down with lift properly since photocell don't handle uneven or bulky garments.
												Separate on AND off delay FOR sensor. Hardcoded. Needs TO be configurable.
												This way we also has a pressing FUNCTION automatically. Do we need the built in press FUNCTION at all?
												NOTE! Recommend TO look over timer. Might be non-used AND some should be configurable.
09-04-01				V1.02.2 Sten Flystedt	Corrected stack data mismatch when copy stacks internally.
09-03-25				V1.02.1 Sten Flystedt	Copied Batch Id from Product also into Stack
09-03-12				V1.02 Sten Flystedt		Added some fixes FOR indexing double stackers. And unlock certain conditions in communication TO Delivery. Used At Basse Muese
08-07-01				V1.01 Sten Flystedt		First edition...
---------------------------------------------------------------------------------------*)

	IF NOT g_SystemInitialized OR (g_HCfg.NumberOfStackers = 0) THEN
		RETURN;
	END_IF	

	// Init 
	IF NOT RInitDone THEN
		RInitDone := 1;
		FOR i := 1 TO g_HCfg.NumberOfStackers DO
			LowerTableJam_TP[i].PT := 30;
		END_FOR	
	END_IF

	// Stacker index buttons show.
	iST := (iST + 1) MOD (MAX_NUMBER_OF_STACKERS + 1);
	itoa(g_OutletProcess.StackerUnit[iST].Counter, ADR(g_HMIStackCountStr[iST]));
	g_HMIMakeIndexHide[iST] := BOOL_TO_UINT(iST > g_HCfg.NumberOfStackers);

	// Outlet at machine start
	MachineStartMakeIndex := FALSE;
	IF EDGEPOS(g_Core.System.Runtime.isRunning) AND g_FirstBoot THEN
		MachineStart := 1;
		g_FirstBoot := FALSE;
	END_IF
	IF MachineStart AND LiftIsReady THEN
		MachineStartMakeIndex := TRUE;
		MachineStart := 0;
	END_IF

	// Manual outlet	
	g_MCfg.Outlet.ConveyorRuntime := MAX(500, g_MCfg.Outlet.ConveyorRuntime);
	OutletPressing := FALSE;
	FOR i := 2 TO g_HCfg.NumberOfStackers DO
		OutletButton[i] := (ISOutlet[i] OR g_HMIMakeIndex[i] = 1 OR ISOutlet[0]) AND g_Core.System.Runtime.isRunning AND NOT g_OutletProcess.StackerUnit[1].BeltEndSensor.Output;
		IF OutletButton[i] THEN
			OutletPressing := TRUE;
			OutletButtonHasPressed[i] := TRUE;
		END_IF
		
		// avoid divide by 0
		g_MCfg.Outlet.ButtonPressTime	:= LIMIT (10,g_MCfg.Outlet.ButtonPressTime,10000);
		// Long press empty stacker
		OutletIndex_TON[i](IN := OutletButton[i] AND NOT g_OutletProcess.StackerUnit[1].BeltEndSensor.Output, PT := UDINT_TO_TIME(g_MCfg.Outlet.ButtonPressTime));
		IF OutletIndex_TON[i].Q AND NOT OutletIndex_TONEdge[i] OR (g_HMIMakeIndex[0] = 1) AND NOT HMIMakeIndexEdge[0] OR MachineStartMakeIndex THEN
			g_OutletProcess.StackerUnit[i].cmdIndex := 1;
		END_IF

		// Run incline / delivery conveyor
		OutletConveyor_Delay[i](Set := OutletButton[i] AND NOT OutletButtonEdge[i] OR g_OutletProcess.StackerUnit[i].LiftMotor.Run AND OutletButtonHasPressed[i] AND NOT g_OutletProcess.StackerUnit[1].BeltEndSensor.Output  , Delay := g_MCfg.Outlet.ConveyorRuntime, CntAdr := ADR(g_MilliSeconds));
		
		IF OutletConveyor_Delay[i].Trig THEN
			OutletButtonHasPressed[i] := FALSE;
		END_IF
		
		HMIMakeIndexEdge[i] := g_HMIMakeIndex[i] = 1;
		OutletButtonEdge[i] := OutletButton[i];
		OutletIndex_TONEdge[i] := OutletIndex_TON[i].Q;
	END_FOR
	HMIMakeIndexEdge[0] := g_HMIMakeIndex[0] = 1;
	// Special doe stacker 1
	IF (g_HMIMakeIndex[1] = 1) OR (g_HMIMakeIndex[0] = 1) THEN
		g_OutletProcess.StackerUnit[1].cmdIndex := 1;
	END_IF
	
	IF OutletPressing THEN
		OutletPressingCountDown := OutletPressingCountDown - MIN(OutletPressingCountDown, g_MilliSeconds - OldMilliSeconds);
		itoa(OutletPressingCountDown / (TIME_TO_UDINT(OutletIndex_TON[2].PT) / 10), ADR(g_HMIOutletPressingCountDownStr));
	ELSE
		g_HMIOutletPressingCountDownStr := '';
		OutletPressingCountDown := TIME_TO_UDINT(OutletIndex_TON[2].PT);
	END_IF
		
	// Lift in top position waiting and waiting
	WaitingPhotocellNo := 0;
	LiftIsReady := 1;
	FOR i := 1 TO g_HCfg.NumberOfStackers DO
		IF (g_OutletProcess.StackerUnit[i].LiftState = MACHPROC_GO_UP_30) OR (g_OutletProcess.StackerUnit[i].LiftState = MACHPROC_STARTUP_3) OR RTestWaitingAlarm[i] THEN
			WaitingPhotocellNo := i;
		END_IF
		IF (g_OutletProcess.StackerUnit[i].LiftState <> MACHPROC_RUN_20) THEN
			LiftIsReady := 0;
		END_IF	
	END_FOR
	WaitingPhotocellOK(Set := (WaitingPhotocellNo = 0) OR g_Machine.ResetAllAlarm OR NOT g_Core.System.Runtime.isRunning OR g_Core.System.Interface.alarms.isLowAirPressure); // possible to reset from HMI 
	g_WaitingLiftAlarm := NOT WaitingPhotocellOK.Out;
	RForceLiftSequence := g_WaitingLiftAlarm AND g_Machine.ResetAllAlarm;

	IF g_Machine.ResetAllAlarm OR EDGEPOS(g_Core.System.Runtime.isRunning) THEN
		FOR i := 1 TO g_HCfg.NumberOfStackers DO
			IF g_OutletProcess.StackerUnit[i].isTopSensorAlarm THEN
				g_OutletProcess.StackerUnit[i].cmdIndex := 1;
				g_OutletProcess.StackerUnit[i].isTopSensorAlarm := FALSE;
			END_IF
		END_FOR
		g_OutletProcess.Common.AlarmList.Alarm[7] := FALSE;
	END_IF
	
	IF g_WaitingLiftAlarm AND (WaitingPhotocellNo > 0) THEN
		IF NOT g_OutletProcess.Common.AlarmList.Alarm[8] THEN
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, WaitingPhotocellNo, 'Lift not up alarm');
		END_IF
		g_OutletProcess.Common.AlarmList.Alarm[8] := TRUE;
	ELSE
		g_OutletProcess.Common.AlarmList.Alarm[8] := TestB[0];
	END_IF

	(*#####################*)
	(* Get current time... *)
	(*#####################*)
	g_OutletProcess.Common.CurTimer 					:= g_Timers._1_ms;			(* Get current time *)
	IF g_OutletProcess.Common.LogBookFlag > 0 THEN
		strcpy(ADR(TmpStr),ADR(g_OutletProcess.Common.Description));
	END_IF

	IF NOT (g_Core.Services.Recipe.Runtime.recipePointer > 0) THEN		(* Check that pointer is bigger then Null *)
		RETURN;								(* Do not run task before pointer is assigned... *)
	END_IF

	(*#################################*)
	(* copy status of exchange objects *)
	(*#################################*)
	//	CrossLoadA := 0;
	//	CrossLoadB := 0;
	g_MCfg.Outlet.CrossBeltNr[2] := 0; // stacker no.2 is inline not connected to crossBelt
	FOR i := 1 TO g_HCfg.NumberOfStackers DO
		IF g_MCfg.Outlet.CrossBeltNr[i] = 1 THEN
			//			CrossLoadA := CrossLoadA + 1;
			g_OutletProcess.StackerUnit[i].Next		:= g_DeliveryProcess.CrossLoadPoint[i].Exchange;
		ELSIF g_MCfg.Outlet.CrossBeltNr[i] = 2 THEN
			//		  	CrossLoadB := CrossLoadB + 1;
			g_OutletProcess.StackerUnit[i].Next		:= g_DeliveryProcess2.CrossLoadPoint[i].Exchange;
		END_IF
	END_FOR
	
	MLabelEnabled := (g_HCfg.PrinterCom = 1) AND g_PrinterCom.isEnabled;

	IF g_WaitingMLabel THEN
		g_MLabelColor := 51;
	ELSE
		g_MLabelColor := 0;
	END_IF

	(*########################################*)
	(* Connect inputs to the module structure *)
	(*########################################*)

	RDeliveryBeltEnd[1] := IBDeliveryBeltEnd OR IBDeliveryBeltEndM[1];
	FOR i := 2 TO MAX_NUMBER_OF_STACKERS DO
		RDeliveryBeltEnd[i] := IBDeliveryBeltEndM[i];
	END_FOR

	g_OutletProcess.StackerExtention.OnTime := g_MCfg.Stacker.BeltExtention;

	FOR i := 1 TO g_HCfg.NumberOfStackers DO

		// Lower table
		LowerTableJam_TP[i]( IN := g_ProcessAlarm );

		// Stacker lift is at top
		g_OutletProcess.StackerUnit[i].LevelSensor.Input		:= IBStackLowerTable[i];

		// Input for Max height
		g_OutletProcess.StackerUnit[i].MaxHeightSensor.Input	:= IBStackIndexingTable[i];			

		// Input to black feed of more stacks.
		g_OutletProcess.StackerUnit[1].BeltBlockSensor.Input	:= ISBlockStacker[1] OR RDeliveryBeltEnd[i] OR g_SealerJam;			

	END_FOR
	// special  case inline & crossconv
	g_OutletProcess.StackerUnit[2].BeltEndSensor.Input		:= IBDeliveryBeltEnd;	// Only online machine
	
	IF g_HCfg.CrossConveyor = 0 THEN
		g_OutletProcess.StackerUnit[1].BeltEndSensor.Input		:= IBDeliveryBeltEnd;	// Only online machine
		
		(*#####	JENWAY		######*)
		// moved to xml_jenway task
//		IF EDGEPOS (g_OutletProcess.StackerUnit[1].BeltEndSensor.Output) OR ( EDGEPOS(g_Core.System.Runtime.isRunning) AND g_OutletProcess.StackerUnit[1].BeltEndSensor.Output )THEN	// send request to Jenway
//			//OR (g_OutletProcess.StackerUnit[1].BeltEndSensor.Output AND (g_JenwayCom.outlet[0].step = INTERCOM_IDLE) AND NOT g_Jenway.No[0].Request   ) 
//			g_Jenway.No[0].Request := 1;
//		END_IF;

		IF g_ShiftBufferData OR g_Overflow THEN
			g_ShiftBufferData	:= FALSE;
			g_Overflow	:= FALSE;
			DataShifting;
		END_IF	
		(*###################*)
	END_IF
	// 2.1.6 -> Buffer Unit is ready when first PH is off
	IF ((g_HCfg.DeliveryExternalCommunication = 3) AND (g_HCfg.CrossConveyor >= 1)) THEN
		FOR i := 1 TO g_HCfg.NumberOfStackers DO
			IF g_MCfg.Outlet.CrossBeltNr[i] = 0 THEN
				IF g_OutletProcess.StackerUnit[i].BeltBlockSensor.Output THEN
					g_OutletProcess.StackerUnit[i].BlockDelivery := TRUE;
				ELSE
					g_OutletProcess.StackerUnit[i].BlockDelivery := FALSE;
				END_IF
			ELSIF g_MCfg.Outlet.CrossBeltNr[i] >= 1 THEN
				g_OutletProcess.StackerUnit[i].BlockDelivery := FALSE;
			END_IF	
		END_FOR
//		g_OutletProcess.NextMachineReady := TRUE; // is handled by Delivery Task
		g_OutletProcess.NextMachineReady[1] := TRUE;
		g_OutletProcess.NextMachineReady[2] := ISWrapperRunning; // wrapper machine after stacker 2
		
	ELSIF ((g_HCfg.DeliveryExternalCommunication = 3) AND (g_HCfg.CrossConveyor = 0)) THEN	
		IF (NOT g_MCfg.Jenway.InvertJenwayReady) THEN 
			g_OutletProcess.NextMachineReady[1]						:= ISReadyOutlet OR IBBufferUnitReady;
		ELSE
			g_OutletProcess.NextMachineReady[1]						:= (NOT ISReadyOutlet) OR IBBufferUnitReady;
		END_IF
		FOR i := 1 TO g_HCfg.NumberOfStackers DO
			g_OutletProcess.StackerUnit[i].BlockDelivery := FALSE;
		END_FOR	
	END_IF
	
	(*######################*)
	(* Connect timer values *)
	(*######################*)
	RunFoldTask(g_MCfg.Trace2File, ADR(T2FD), g_OutletProcess.Common,g_MachineManager[g_OutletProcess.Common.MachineManagerIndex]);
	CASE g_OutletProcess.Common.State OF

		(*####################################*)
		(* Start Up Machine, Home Axels etc.. *)
		(*####################################*)

		MACHPROC_STARTUP_1:

			g_OutletProcess.Common.Previous.TransferStatus	:= EXC_STANDBY_0;

			FOR i := 1 TO g_HCfg.NumberOfStackers DO
				g_OutletProcess.StackerUnit[i].LiftState 	:= MACHPROC_STARTUP_1;
				g_OutletProcess.StackerUnit[i].BeltState 	:= MACHPROC_STARTUP_1;
			END_FOR

			FOR i := 1 TO NUMBER_OF_STACKERGROUPS DO
				g_OutletProcess.StackerGroupLink[i].State 					:= MACHPROC_STARTUP_1;
				g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus := EXC_STANDBY_0;			// 09-11-23
			END_FOR

			g_OutletProcess.Common.WatchDogRunTimer 		:= g_OutletProcess.Common.CurTimer;
			g_OutletProcess.Common.State 					:= MACHPROC_RUN_21;

			(*###############################################################*)
			(* Machine Stop case, to handle shut down process of the module  *)
			(*###############################################################*)

		MACHPROC_STOP_15:
			FOR i := 1 TO g_HCfg.NumberOfStackers DO
				g_OutletProcess.StackerUnit[i].LiftMode		:= LIFT_MODE_DOWN_2;
				g_OutletProcess.StackerUnit[i].LiftState 	:= MACHPROC_INIT_0;
				g_OutletProcess.StackerUnit[i].BeltState 	:= MACHPROC_INIT_0;
			END_FOR
			FOR i := 1 TO NUMBER_OF_STACKERGROUPS DO
				g_OutletProcess.StackerGroupLink[i].State 	:= MACHPROC_INIT_0;
			END_FOR

			(*#####################*)
			(* Main running state  *)
			(*#####################*)

			MACHPROC_RUN_20,
		MACHPROC_RUN_21:

			(* If all lift and belt are in idle state then is main process also in idle and can be stopped *)
			IF g_OutletProcess.Common.State = MACHPROC_RUN_21 AND (g_OutletProcess.Common.Previous.TransferStatus < EXC_ERROR_99) THEN
				g_OutletProcess.AllSubIdle := TRUE;
				FOR i := 1 TO g_HCfg.NumberOfStackers DO
					IF g_OutletProcess.StackerUnit[i].LiftState <> MACHPROC_RUN_20 THEN
						g_OutletProcess.AllSubIdle := FALSE;
						i := g_HCfg.NumberOfStackers;
					END_IF
					IF (g_OutletProcess.StackerUnit[i].BeltState <> MACHPROC_RUN_20) AND (g_OutletProcess.StackerUnit[i].BeltState <> MACHPROC_DELIVER_PACKAGE_80) THEN
						g_OutletProcess.AllSubIdle := FALSE;
						i := g_HCfg.NumberOfStackers;
					END_IF
				END_FOR
				FOR i := 1 TO NUMBER_OF_STACKERGROUPS DO
					IF (g_OutletProcess.StackerGroupLink[i].State <> MACHPROC_RUN_20) AND (g_OutletProcess.StackerGroupLink[i].State <> MACHPROC_DELIVER_PACKAGE_80) THEN
						g_OutletProcess.AllSubIdle := FALSE;
						i := NUMBER_OF_STACKERGROUPS;
					END_IF
				END_FOR
				IF g_OutletProcess.AllSubIdle THEN
					g_OutletProcess.Common.State 						:= MACHPROC_RUN_20;
				END_IF
				g_OutletProcess.Common.WatchDogRunTimer 				:= g_OutletProcess.Common.CurTimer;
			ELSIF (g_OutletProcess.Common.Previous.TransferStatus < EXC_ERROR_99) THEN
				g_OutletProcess.Common.Next.TransferStatus := EXC_ERROR_99;
			
			END_IF

	END_CASE

	// Read parameters at boot-up
	IF RInitReadParameters AND (g_Core.Services.Recipe.Runtime.recipePointer > 0) THEN
		FOR i := 1 TO NUMBER_OF_STACKERGROUPS DO
			g_OutletProcess.StackerGroupLink[i].Product.FoldProgram := 2;
			g_OutletProcess.StackerGroupLink[i].ReadParameters := TRUE;
		END_FOR
		FOR i := 1 TO NUMBER_OF_STACKERS DO
			g_OutletProcess.Parameters[i] := g_RCfg[0].Outlet;	
		END_FOR
		RInitReadParameters := FALSE;
	END_IF

	FOR i := 1 TO NUMBER_OF_STACKERGROUPS DO

		g_OutletProcess.StackerGroupLink[i].Previous		:= g_StackerProcess[i].Common.Next;

		FirstStackersInThisGroup 							:= g_StackerGroup[i].FirstStack;	
		LastStackersInThisGroup 							:= g_StackerGroup[i].LastStack;

		IF g_OutletProcess.StackerGroupLink[i].ReadParameters THEN
			g_OutletProcess.StackerGroupLink[i].ReadParameters 	:= FALSE;
			IF g_Core.Services.Recipe.Runtime.recipePointer > 0 THEN			(* Check that pointer is bigger then Null *)
				LocalFoldProgram ACCESS(g_Core.Services.Recipe.Runtime.recipePointer + (SIZEOF(LocalFoldProgram) * LIMIT(0, (g_OutletProcess.StackerGroupLink[i].Product.FoldProgram - 1), MAX_NUMBER_OF_CATEGORIES)));
			ELSE
				RETURN;		(* Can not access LocalFoldProgram before pointer is ok. *)
			END_IF
			g_OutletProcess.Parameters[g_OutletProcess.StackerGroupLink[i].Product.Stack]		:= LocalFoldProgram.Outlet;

			// Mode is not used on the FOX remove?? 09-12-09 POX
			IF g_OutletProcess.Parameters[g_OutletProcess.StackerGroupLink[i].Product.Stack].Mode > OUTLETMODE_DOUBLE_1 THEN
				g_OutletProcess.Parameters[g_OutletProcess.StackerGroupLink[i].Product.Stack].Mode := OUTLETMODE_SINGLE_0;
			END_IF
			//IF g_OutletProcess.Parameters[g_OutletProcess.StackerGroupLink[i].Product.Stack].NumberOfProducts > MAX_STACK_SIZE THEN
			//	g_OutletProcess.Parameters[g_OutletProcess.StackerGroupLink[i].Product.Stack].NumberOfProducts := MAX_STACK_SIZE;
			//END_IF
			// Changed this 2010-06-08 POX
			IF g_OutletProcess.Parameters[g_OutletProcess.StackerGroupLink[i].Product.Stack].NumberOfProducts > STACK_ITEM_MAX_20 THEN
				g_OutletProcess.Parameters[g_OutletProcess.StackerGroupLink[i].Product.Stack].NumberOfProducts := STACK_ITEM_MAX_20;
			END_IF
		
			FOR j := FirstStackersInThisGroup TO LastStackersInThisGroup DO
				g_OutletProcess.StackerUnit[j].LevelSensor.OnDelay		:= LevelSensorFilterOnTime;
				g_OutletProcess.StackerUnit[j].LevelSensor.OffDelay		:= LevelSensorFilterOffTime;
				g_OutletProcess.StackerUnit[j].MaxHeightSensor.OnDelay	:= LevelSensorFilterOnTime;
				g_OutletProcess.StackerUnit[j].MaxHeightSensor.OffDelay	:= LevelSensorFilterOffTime;
				g_OutletProcess.StackerUnit[j].BeltBlockSensor.OnDelay	:= LevelSensorFilterOnTime;
				g_OutletProcess.StackerUnit[j].BeltBlockSensor.OffDelay	:= LevelSensorFilterOffTime;
				g_OutletProcess.StackerUnit[j].BeltEndSensor.OnDelay	:= 50;	
				g_OutletProcess.StackerUnit[j].BeltEndSensor.OffDelay	:= 50;	
				g_OutletProcess.StackerUnit[j].DownSensor.OnDelay		:= 50;	
				g_OutletProcess.StackerUnit[j].DownSensor.OffDelay		:= 50;	
				g_OutletProcess.StackerUnit[j].PressTime				:= g_MCfg.Outlet.PressTime;		// Machine or Recipe timers??
				(* Ensure belt motor runs enough time *)
				g_OutletProcess.StackerUnit[j].Motor.RunTime 		:= 10000;
				g_OutletProcess.StackerUnit[j].LiftMotor.RunTime 	:= 8000;
				// Delay lift after check of stack size..	
				g_OutletProcess.StackerUnit[j].DelayLiftTime			:= 500;
				// Start delay for the LiftMotor to avoid current rush if booth start at same time...
				g_OutletProcess.StackerUnit[j].LiftMotor.StartDelayTime	:= 400;
			END_FOR
		END_IF
	
		CASE g_OutletProcess.StackerGroupLink[i].State OF

			(*####################################*)
			(* Start Up Machine, Home Axels etc.. *)
			(*####################################*)

			MACHPROC_STARTUP_1:
				g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus := EXC_STANDBY_0;		// 10-02-04
				g_OutletProcess.StackerGroupLink[i].State					:= MACHPROC_RUN_20;
		
		
		
				//##########################
				// Stacker group link state  
				//##########################

			MACHPROC_RUN_20:
		
				// JEDK FIX: PMU 29.01.13 Fixes issue #140
				g_OutletProcess.StackerGroupLink[i].ReadParameters := TRUE;

				// Ugly fix to get passed look up here // 09-11-23 POX...
				IF (g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus > EXC_WANT_TO_UNLOAD_1) AND (g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus < EXC_ERROR_99) THEN
					g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus  := EXC_WANT_TO_UNLOAD_1;
				END_IF	

				g_OutletProcess.Common.AlarmList.Alarm[6] := FALSE;
					
				//FOR ai := 1 TO g_HCfg.NumberOfStackers DO	
				//	IF g_OutletProcess.StackerUnit[ai].JamLevelSensor.Output THEN
				//		g_OutletProcess.Common.AlarmList.Alarm[6] := TRUE;
				//	END_IF
				//END_FOR

				// Start the flow of goods
				// Make sure the Lift is in Idle state and not waiting for Belt to finish it task.. 09-12-01
				IF (g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus = EXC_WANT_TO_UNLOAD_1) AND (ManualStop = 0) AND NOT g_Core.System.Interface.alarms.isLowAirPressure AND NOT g_OutletProcess.StackerUnit[i].isTopSensorAlarm AND NOT g_OutletProcess.StackerUnit[i].isCheckTopSensor THEN			(* Previous task whants to unload *)
					g_OutletProcess.StackerGroupLink[i].Product	:= g_OutletProcess.StackerGroupLink[i].Previous.Product;
					ACfgProgram := LIMIT(0, g_OutletProcess.StackerGroupLink[i].Product.AutoProgram - 1, 98);
					IF g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].LiftState = MACHPROC_RUN_20 THEN
						// Make count already here to make the direct stack change work better..
						g_OutletProcess.Common.State																:= MACHPROC_RUN_21;	// 10-03-29, Must be set to _21 here else it will always be ready to Soft stop..
						g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].Counter		:= g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].Counter + 1;
						g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].LiftState	:= MACHPROC_DROP_STARTED_21;
						g_OutletProcess.StackerGroupLink[i].State													:= MACHPROC_WAIT_FOR_TABLE_23;
					END_IF	
				END_IF

			MACHPROC_WAIT_FOR_TABLE_23:

				(* If coupled, then all coupled lift must be ready *)
				IF g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].LiftState = MACHPROC_RUN_20 THEN		
					g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].LiftState	:= MACHPROC_DROP_STARTED_21;
				ELSIF g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].LiftState = MACHPROC_WAIT_TOWEL_DETECT_22 THEN	
					Blocked 																						:= FALSE;
					g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].StackChange		:= FALSE;
					IF NOT Blocked THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, g_OutletProcess.Common.CurTimer, 'OUTL all stack is below');
						g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus 								:= EXC_READY_TO_RECIEVE_2;
						g_OutletProcess.StackerGroupLink[i].State													:= MACHPROC_WAIT_LIFT_IN_POS_27;
					END_IF
				END_IF
				g_OutletProcess.Common.WatchDogRunTimer 															:= g_OutletProcess.Common.CurTimer;
	
			MACHPROC_WAIT_LIFT_IN_POS_27:
	
	
				//10-09-22 POX
				IF g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus = EXC_ERROR_99 THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, g_OutletProcess.Common.CurTimer, 'OUTL Error in stacker go back');
					g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].LiftState := MACHPROC_RUN_20;			// POX 10-10-05..
					g_OutletProcess.StackerGroupLink[i].State		:= MACHPROC_RUN_20;
				END_IF	
	
	
				// 09-08-10
				IF g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus = EXC_WANT_TO_UNLOAD_1 THEN
					g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus := EXC_READY_TO_RECIEVE_2;
				ELSIF g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus = EXC_UNLOADING_3 THEN		// Stacker has opened the flaps
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, g_OutletProcess.Common.CurTimer, 'OUTL stacker has dropped');
					g_OutletProcess.StackerGroupLink[i].State				:= MACHPROC_WAIT_LIFT_RECIEVE_OK_28;
				END_IF
				g_OutletProcess.Common.WatchDogRunTimer 					:= g_OutletProcess.Common.CurTimer;
	
			MACHPROC_WAIT_LIFT_RECIEVE_OK_28:
	
				IF (g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].LiftState	= MACHPROC_DROP_COMPLETE_24) 
					OR ((g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].LiftState = MACHPROC_RUN_20) AND (g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].BeltState = MACHPROC_RUN_20))THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, g_OutletProcess.Common.CurTimer, 'OUTL Lift has recieved');
					g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus 						:= EXC_RECIVING_4;
					g_OutletProcess.StackerGroupLink[i].State											:= MACHPROC_WAIT_STACKER_DROP_29;
				END_IF
				// Removed this watchdog to create an error if garment is dropped before the stacker flaps... POX
				g_OutletProcess.Common.WatchDogRunTimer 												:= g_OutletProcess.Common.CurTimer;
			

	
			MACHPROC_WAIT_STACKER_DROP_29:
		
				//IF g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus = EXC_STANDBY_0 THEN	// Error in Stacker
				IF g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus = EXC_ERROR_99 THEN	// Error in Stacker
					g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].LiftState := MACHPROC_RUN_20;
					g_OutletProcess.StackerGroupLink[i].State	:= MACHPROC_RUN_20;
				END_IF
			

				IF g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus = EXC_FINISHED_UNLOADING_5 THEN (* Stacker has closed the doors *)
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, g_OutletProcess.Common.CurTimer, 'OUTL Stacker done');
				
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, g_OutletProcess.StackerGroupLink[i].Product.Stack, 'OUTL SU Index');
					// 10-03-24.. 40-6009...
				
					g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].StackData[0].Count 				:= g_OutletProcess.StackerUnit[i].StackData[0].Count + 1;
					IF g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].StackData[0].Count >= STACK_ITEM_MAX_20 THEN
						g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].StackData[0].Count := STACK_ITEM_MAX_20;
					END_IF	
					g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].StackData[0].FoldProgram 		:= g_OutletProcess.StackerGroupLink[i].Product.FoldProgram;
					g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].StackData[0].CustomerId 			:= g_OutletProcess.StackerGroupLink[i].Product.Customer;
					g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].StackData[0].ArticleId 			:= g_OutletProcess.StackerGroupLink[i].Product.Article;
					g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].StackData[0].BatchId	 			:= g_OutletProcess.StackerGroupLink[i].Product.BatchId;
					g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].StackData[0].Destination 		:= g_OutletProcess.StackerGroupLink[i].Product.JenWayDestination;
				
					// This is not OK for a Multi stacker machine
					// If multi stacker this creates a Overflow sins counter is added for every stacker...

					IF MLabelEnabled THEN
						// Detailed data for Print and Pack
						// Check how the Count is counted and reseted... So it works for this....
						ItemIndex := g_OutletProcess.StackerUnit[1].StackData[0].Count;	
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, ItemIndex, 'OUTL ItemIndex');
						g_OutletProcess.StackerUnit[1].StackData[0].BatchId							:= StackIndexNumber;
						//g_OutletProcess.StackerUnit[1].StackData[0].ItemData[ItemIndex].Id 			:= UDINT_TO_UINT(g_OutletProcess.StackerGroupLink[1].Product.BatchId);	
						IF (ItemIndex >= 0) AND (ItemIndex <= STACK_ITEM_MAX_20) THEN
							g_OutletProcess.StackerUnit[1].StackData[0].ItemData[ItemIndex].CustomerId 	:= g_OutletProcess.StackerGroupLink[1].Product.Customer;
							g_OutletProcess.StackerUnit[1].StackData[0].ItemData[ItemIndex].ArticleId 	:= g_OutletProcess.StackerGroupLink[1].Product.Article;
							g_OutletProcess.StackerUnit[1].StackData[0].ItemData[ItemIndex].HangerId 	:= g_OutletProcess.StackerGroupLink[1].Product.HangerId;
							g_OutletProcess.StackerUnit[1].StackData[0].ItemData[ItemIndex].GarmentId 	:= g_OutletProcess.StackerGroupLink[1].Product.GarmentId;
							g_OutletProcess.StackerUnit[1].StackData[0].ItemData[ItemIndex].FoldProgram := g_OutletProcess.StackerGroupLink[1].Product.FoldProgram;
						ELSE
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 0, 1, ItemIndex, 'OUTL wrong ItemIndex');
						END_IF	
					END_IF	
					
					g_OutletProcess.StackerGroupLink[i].ReadParameters 																:= TRUE;
					g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus														:= EXC_RECIVING_DONE_6;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, g_OutletProcess.Common.CurTimer, 'OUTL goods ok');
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, g_OutletProcess.StackerGroupLink[i].Product.Stack, 'Stack value');
					g_OutletProcess.StackerUnit[g_OutletProcess.StackerGroupLink[i].Product.Stack].LiftState						:= MACHPROC_LIFT_EVALUATE_STACK_25;
					g_OutletProcess.StackerGroupLink[i].State 																		:= MACHPROC_WAIT_BEFORE_EXIT_82;
					g_OutletProcess.Common.ExitTimer 																				:= g_OutletProcess.Common.CurTimer;							(* start watchdog timer for process *)
				END_IF

				// Multi stacker how??
				//IF g_StackerProcess[1].Common.State = MACHPROC_ERROR_99 THEN
				//	g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus 													:= EXC_STANDBY_0;
				//	g_OutletProcess.StackerGroupLink[i].State																		:= MACHPROC_RUN_20; 		
				//END_IF		
		
		
				g_OutletProcess.Common.WatchDogRunTimer 																			:= g_OutletProcess.Common.CurTimer;

			MACHPROC_WAIT_BEFORE_EXIT_82:

				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, g_OutletProcess.Common.CurTimer, 'Wait before exit');
				g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus 														:= EXC_STANDBY_0;
				g_OutletProcess.StackerGroupLink[i].State																			:= MACHPROC_RUN_20;

		END_CASE
	END_FOR


	(* Must run counters always. Rest is only run if not coupled *)
	FOR i := 1 TO g_HCfg.NumberOfStackers DO
		RunIOCounter(g_OutletProcess.StackerUnit[i].LevelSensor, g_OutletProcess.Common.CurTimer);
		RunIOCounter(g_OutletProcess.StackerUnit[i].MaxHeightSensor, g_OutletProcess.Common.CurTimer);
		RunIOCounter(g_OutletProcess.StackerUnit[i].DownSensor, g_OutletProcess.Common.CurTimer);
		RunIOCounter(g_OutletProcess.StackerUnit[i].BeltBlockSensor, g_OutletProcess.Common.CurTimer);
		RunIOCounter(g_OutletProcess.StackerUnit[i].BeltEndSensor, g_OutletProcess.Common.CurTimer);
		
		IF NOT g_OutletProcess.StackerUnit[i].LevelSensor.Output THEN
			g_OutletProcess.StackerUnit[i].isCheckTopSensor := FALSE;
		END_IF
		g_OutletProcess.StackerUnit[i].TON_TopSensorAlarm(IN := g_OutletProcess.StackerUnit[i].isCheckTopSensor, PT := T#4s );
		IF g_OutletProcess.StackerUnit[i].TON_TopSensorAlarm.Q AND NOT g_OutletProcess.StackerUnit[i].isTopSensorAlarm THEN
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 4, g_OutletProcess.Common.LogBookFlag, i, 'Top sensor jam alarm');
			g_HMITopSensorAlarmStNo := i;
			g_OutletProcess.StackerUnit[i].isTopSensorAlarm := TRUE;
			g_OutletProcess.Common.AlarmList.Alarm[7] := TRUE;
			g_OutletProcess.StackerUnit[i].LiftState := 0;
		END_IF
		
		CASE g_OutletProcess.StackerUnit[i].LiftState OF

			MACHPROC_INIT_0:
		
				WasIndexed[i] := FALSE;
				StartupDelayTime := 1000;	// Delay restart for short push of stop/start. Banging fix.
				IF MachineStop_TOF.Q THEN
					g_OutletProcess.StackerUnit[i].StartupDelayTimer := g_OutletProcess.Common.CurTimer;
				END_IF
				
				IF g_Core.System.Runtime.isRunning AND NOT g_Core.System.Interface.alarms.isLowAirPressure AND NOT g_OutletProcess.StackerUnit[i].isTopSensorAlarm AND ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].StartupDelayTimer) >= StartupDelayTime THEN
					g_OutletProcess.StackerUnit[i].LiftState := MACHPROC_STARTUP_1;
				END_IF


			MACHPROC_STARTUP_1:

				(* reduce number of indexes needed to be done *)
				IF g_OutletProcess.StackerUnit[i].cmdIndex > 3 THEN
					(* Illegal value *)
					g_OutletProcess.StackerUnit[i].cmdIndex 				:= 0;
				ELSIF g_OutletProcess.StackerUnit[i].cmdIndex > 0 AND g_OutletProcess.StackerUnit[i].DoubleWaiting = FALSE THEN
					g_OutletProcess.StackerUnit[i].cmdIndex 				:= g_OutletProcess.StackerUnit[i].cmdIndex - 1;
				END_IF

				// Clear the alarm
				g_OutletProcess.Common.AlarmList.Alarm[6]			:= FALSE;
				g_OutletProcess.StackerUnit[i].StartupDelayTimer 	:= g_OutletProcess.Common.CurTimer;
				IF WasIndexed[i] THEN			// To do not have startup delay if coming from a Stack change..
					StartupDelayTime 	:= 0;
					WasIndexed[i]		:= FALSE;
				ELSE
					StartupDelayTime := 1000;
				END_IF	
				g_OutletProcess.StackerUnit[i].LiftState			:= MACHPROC_STARTUP_2;


			MACHPROC_STARTUP_2:
				// Wait for flaps to close
				IF ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].StartupDelayTimer) >= StartupDelayTime THEN
					g_OutletProcess.StackerUnit[i].StartupDelayTimer 	:= g_OutletProcess.Common.CurTimer;
					// Lift is not up send it up
					IF g_OutletProcess.StackerUnit[i].LevelSensor.Output = 0 THEN
						g_OutletProcess.StackerUnit[i].LiftMode			:= LIFT_MODE_UP_1;
						g_OutletProcess.StackerUnit[i].LiftState		:= MACHPROC_STARTUP_3;
						// Lift is already up
					ELSE		
						g_OutletProcess.StackerUnit[i].LiftMode			:= LIFT_MODE_DOWN_2;
						g_OutletProcess.StackerUnit[i].LiftState		:= MACHPROC_STARTUP_4;
					END_IF
				END_IF

		

			MACHPROC_STARTUP_3:

				// Go up until sensor is covered 
				g_OutletProcess.StackerUnit[i].StartupDelayTimer 	:= g_OutletProcess.Common.CurTimer;
				IF g_OutletProcess.StackerUnit[i].LevelSensor.Output = 1 THEN
					IF g_OutletProcess.StackerUnit[i].Counter = 0 THEN		// If stacker lift is empty it can stay up, make jumpy movement othervise..
						g_OutletProcess.StackerUnit[i].LiftMode				:= LIFT_MODE_STOP_3;
						g_OutletProcess.StackerUnit[i].LiftState			:= MACHPROC_RUN_20;				
					ELSE
						g_OutletProcess.StackerUnit[i].WatchDogStartup 		:= g_OutletProcess.Common.CurTimer;
						g_OutletProcess.StackerUnit[i].LiftMode				:= LIFT_MODE_DOWN_2;
						g_OutletProcess.StackerUnit[i].LiftState			:= MACHPROC_STARTUP_4;
					END_IF	
				END_IF
				IF NOT g_Core.System.Runtime.isRunning THEN
					g_OutletProcess.StackerUnit[i].LiftState			:= MACHPROC_INIT_0;
				END_IF



			MACHPROC_STARTUP_4:
		
				// Stop just under sensor 
				IF g_OutletProcess.StackerUnit[i].LevelSensor.Output = 0 THEN
					g_OutletProcess.StackerUnit[i].LiftMode					:= LIFT_MODE_STOP_3;
					g_OutletProcess.StackerUnit[i].LiftState				:= MACHPROC_RUN_20;
				END_IF

				IF ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].WatchDogStartup) >= 3000 THEN
					g_OutletProcess.StackerUnit[i].LiftMode					:= LIFT_MODE_STOP_3;
					g_OutletProcess.StackerUnit[i].LiftState				:= MACHPROC_RUN_20;
				END_IF
				
				



				(*#####################*)
				(* Main running state  *)
				(*#####################*)

			MACHPROC_RUN_20:

				IF g_Core.System.Interface.alarms.isLowAirPressure THEN
					g_OutletProcess.StackerUnit[i].LiftState := MACHPROC_INIT_0;
				ELSE
					(* Wait for Outlet state to give order via new state *)
					(* Can also via external command index table *)
					IF g_OutletProcess.StackerUnit[i].cmdIndex > 0 THEN
						IF g_OutletProcess.StackerUnit[i].StackData[0].Count = 0 THEN
							g_OutletProcess.StackerUnit[i].StackData[0] := GarbageStackData;
						END_IF
						g_OutletProcess.StackerUnit[i].LiftState		:= MACHPROC_DO_INDEX_26;
						g_OutletProcess.StackerUnit[i].cmdIndex			:= 0;			// POX ???
						g_OutletProcess.Common.State					:= MACHPROC_RUN_21;	// MHA Moderna avoid mixing garment
					END_IF
			
					// Is now always stoppped to not go all the way up...
					//IF g_OutletProcess.StackerUnit[i].LevelSensor.Output = 1 THEN
					IF (g_OutletProcess.StackerUnit[i].LevelSensor.Output = 1) AND (g_OutletProcess.StackerUnit[i].Counter > 0) THEN
						g_OutletProcess.StackerUnit[i].LiftMode			:= LIFT_MODE_DOWN_2;
					ELSE
						g_OutletProcess.StackerUnit[i].LiftMode			:= LIFT_MODE_STOP_3;
					END_IF
				END_IF
				
		



			MACHPROC_DROP_STARTED_21:
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 4, g_OutletProcess.Common.LogBookFlag, i, 'Lift go to top');
				g_OutletProcess.StackerUnit[i].LiftMode						:= LIFT_MODE_UP_1;
				g_OutletProcess.StackerUnit[i].LevelSensor.OldEdgeCounter 	:= g_OutletProcess.StackerUnit[i].LevelSensor.EdgeCounter;
				g_OutletProcess.StackerUnit[i].LiftState					:= MACHPROC_GO_UP_30;


			MACHPROC_GO_UP_30:
		
				// Trigger press timer	
				IF g_OutletProcess.StackerUnit[i].LevelSensor.EdgeCounter > g_OutletProcess.StackerUnit[i].LevelSensor.OldEdgeCounter THEN	
					g_OutletProcess.StackerUnit[i].PressTimer := g_OutletProcess.Common.CurTimer;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Trigger press timer'); 		
				END_IF	
				g_OutletProcess.StackerUnit[i].LevelSensor.OldEdgeCounter := g_OutletProcess.StackerUnit[i].LevelSensor.EdgeCounter;			


				// Lift is on top and press time has elapsed..
				IF (g_OutletProcess.StackerUnit[i].LevelSensor.Output = 1) AND ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].PressTimer) >= g_OutletProcess.StackerUnit[i].PressTime THEN
					g_OutletProcess.StackerUnit[i].LiftMode			:= LIFT_MODE_STOP_3;
					g_OutletProcess.StackerUnit[i].SinkTimer 		:= g_OutletProcess.Common.CurTimer;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Lift is on Top/Recieve'); 		
					g_OutletProcess.StackerUnit[i].LiftState		:= MACHPROC_WAIT_TOWEL_DETECT_22;
				END_IF
			


			MACHPROC_WAIT_TOWEL_DETECT_22:

				//Here it should stay until Flaps has opened, and not timer..
				IF ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].SinkTimer) >= g_MCfg.Stacker.DropTime THEN
					g_OutletProcess.StackerUnit[i].LiftMode				:= LIFT_MODE_DOWN_2;
					g_OutletProcess.StackerUnit[i].LiftState			:= MACHPROC_GO_BELOW_SENSOR_23;
					g_OutletProcess.StackerUnit[i].SinkTimer 			:= g_OutletProcess.Common.CurTimer;
				END_IF


			MACHPROC_GO_BELOW_SENSOR_23:
	
				g_OutletProcess.StackerUnit[i].LiftMode				:= LIFT_MODE_DOWN_2;
				IF g_OutletProcess.StackerUnit[i].LevelSensor.Output = 0 THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Lift now below sensor');
					g_OutletProcess.StackerUnit[i].LiftMode				:= LIFT_MODE_STOP_3;
					//g_OutletProcess.StackerUnit[i].STGJamTimer		:= g_OutletProcess.Common.CurTimer;
					g_OutletProcess.StackerUnit[i].LiftState			:= MACHPROC_DROP_COMPLETE_24;
				END_IF


				(* Check that sensor is not blocked, if not do an indexing anyway *)
				IF ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].SinkTimer) >= 2000 THEN	
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Lift Stack change on top sensor');
					g_OutletProcess.StackerUnit[i].LiftState := MACHPROC_WAIT_ALLDOWN_36;
					g_OutletProcess.StackerUnit[i].LiftMode := LIFT_MODE_DOWN_2;
					g_OutletProcess.StackerUnit[i].isCheckTopSensor := TRUE;
					g_OutletProcess.StackerUnit[i].SinkTimer := g_OutletProcess.Common.CurTimer;
				END_IF


			MACHPROC_DROP_COMPLETE_24:
				//if ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].STGJamTimer) >= 4000 then //If detection failed
				//g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus 	:= EXC_STANDBY_0;
				//g_OutletProcess.StackerGroupLink[i].State						:= MACHPROC_RUN_20;
				//g_OutletProcess.StackerUnit[i].LiftState						:= MACHPROC_RUN_20;
				;(* Do nothing, just wait for outlet task to set new state *)

			MACHPROC_LIFT_EVALUATE_STACK_25:
				// Copy data, How to make it more compact...
				// We must copy data from STG here aswell can have been updated by XB after we made the first copy at start outlet.. POX..
				CASE i OF 
					1:	IF g_OutletProcess.StackerGroupLink[1].Product.Stack = 1 THEN
							g_OutletProcess.StackerUnit[1].LastItemOnStack 	:= g_StackerProcess[1].Common.Product.LastItemOnStack;
						END_IF	
					2:	IF g_OutletProcess.StackerGroupLink[1].Product.Stack = 2 THEN
							g_OutletProcess.StackerUnit[2].LastItemOnStack 	:= g_StackerProcess[1].Common.Product.LastItemOnStack;
						END_IF	
					3: 	IF g_OutletProcess.StackerGroupLink[2].Product.Stack = 3 THEN
							g_OutletProcess.StackerUnit[3].LastItemOnStack 	:= g_StackerProcess[2].Common.Product.LastItemOnStack;
						END_IF	
					4: 	IF g_OutletProcess.StackerGroupLink[2].Product.Stack = 4 THEN
							g_OutletProcess.StackerUnit[4].LastItemOnStack 	:= g_StackerProcess[2].Common.Product.LastItemOnStack;
						END_IF	
					5: 	IF g_OutletProcess.StackerGroupLink[3].Product.Stack = 5 THEN
							g_OutletProcess.StackerUnit[5].LastItemOnStack 	:= g_StackerProcess[3].Common.Product.LastItemOnStack;
						END_IF	
					6: 	IF g_OutletProcess.StackerGroupLink[3].Product.Stack = 6 THEN
							g_OutletProcess.StackerUnit[6].LastItemOnStack 	:= g_StackerProcess[3].Common.Product.LastItemOnStack;
						END_IF	
				END_CASE	

				// Max number reached or Stack changes command...
				IF ((g_OutletProcess.StackerUnit[i].Counter >= g_OutletProcess.Parameters[i].NumberOfProducts) AND (NOT g_HangerInletProcess.CustomerStackChange)) OR 
					(g_OutletProcess.StackerUnit[i].LastItemOnStack > 0) OR
					(g_OutletProcess.StackerUnit[i].MaxHeightSensor.Output AND g_HCfg.StackMaxHeightSensor) OR
					(g_OutletProcess.StackerUnit[i].cmdIndex > 0) OR 
					(g_OutletProcess.StackerGroupLink[i].Product.NoRead XOR g_OutletProcess.StackerUnit[i].NoRead) THEN
				
					IF g_OutletProcess.StackerUnit[i].cmdIndex > 0 THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Stack change cmdIndex');
						g_OutletProcess.StackerUnit[i].cmdIndex 		:= FALSE;			// Should it be here??? POX
					ELSIF g_OutletProcess.StackerUnit[i].LastItemOnStack > 0 THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Stack change LastItem');
						g_OutletProcess.StackerUnit[i].LastItemOnStack	:= 0;										
					ELSIF (g_OutletProcess.StackerUnit[i].MaxHeightSensor.Output AND g_HCfg.StackMaxHeightSensor) THEN	
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Stack change Max sensor');
					ELSE	
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Stack change Count');	
					END_IF	
					g_OutletProcess.StackerUnit[i].LiftState		:= MACHPROC_DO_INDEX_26;
				ELSE
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Lift stack is not full');
					g_OutletProcess.StackerUnit[i].DelayLiftTimer		:= g_OutletProcess.Common.CurTimer;
					g_OutletProcess.StackerUnit[i].LiftState			:= MACHPROC_DELAY_LIFTUP_40;
				END_IF
				g_OutletProcess.StackerUnit[i].NoRead := g_OutletProcess.StackerGroupLink[i].Product.NoRead;


			MACHPROC_DELAY_LIFTUP_40:
		
				IF ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].DelayLiftTimer) >= g_OutletProcess.StackerUnit[i].DelayLiftTime THEN
					g_OutletProcess.StackerUnit[i].LiftState			:= MACHPROC_RUN_20;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, g_OutletProcess.Common.CurTimer, 'OUTL Delay lift up 2');
				END_IF


			MACHPROC_DO_INDEX_26:

				//			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Lift do index');
				//			g_OutletProcess.StackerUnit[i].LiftMode				:= LIFT_MODE_DOWN_2;
				//			g_OutletProcess.StackerUnit[i].SinkTimer 			:= g_OutletProcess.Common.CurTimer;
				//			g_OutletProcess.StackerUnit[i].LiftState			:= MACHPROC_WAIT_ALLDOWN_36;
			
				//POX 2012-04-16
				IF g_OutletProcess.StackerUnit[i].BeltState = MACHPROC_RUN_20 THEN 				// Belt must be ready with previous stack before going down.
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Lift do index');
					g_OutletProcess.StackerUnit[i].LiftState		:= MACHPROC_WAIT_ALLDOWN_36;
					g_OutletProcess.StackerUnit[i].LiftMode			:= LIFT_MODE_DOWN_2;
					g_OutletProcess.StackerUnit[i].SinkTimer		:= g_OutletProcess.Common.CurTimer;
				END_IF
	
			MACHPROC_WAIT_ALLDOWN_36:

				IF	g_OutletProcess.StackerUnit[i].DoIndex THEN
					g_OutletProcess.StackerUnit[i].SinkPressDelay := g_MCfg.Stacker.IndexingDelay;
				ELSE
					g_OutletProcess.StackerUnit[i].SinkPressDelay := 0;
				END_IF
				// Sink delay
				IF ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].SinkTimer) >= (g_MCfg.Stacker.IndexingDelay + g_OutletProcess.StackerUnit[i].SinkPressDelay) THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Lift all down');
					g_OutletProcess.StackerUnit[i].LiftMode				:= LIFT_MODE_IDLE_0;
					g_OutletProcess.StackerUnit[i].LiftState			:= MACHPROC_WAIT_BELT_READY_38;
				END_IF
												
				// Wait for belt to be in state 20 and not forced to be emptied..
			MACHPROC_WAIT_BELT_READY_38:
		
				IF (g_OutletProcess.StackerUnit[i].BeltState = MACHPROC_RUN_20) THEN							
					g_OutletProcess.StackerUnit[i].LiftState := MACHPROC_WAIT_INDEX_37;
				END_IF	

	
				// Lift is down, Belt state takes over the controll..
			MACHPROC_WAIT_INDEX_37:
				WasIndexed[i]							:= TRUE;		// Used to make the Startup delay correct in _1
				g_OutletProcess.StackerUnit[i].DoIndex 	:= FALSE;

		END_CASE

	END_FOR



	FOR i := 1 TO g_HCfg.NumberOfStackers DO
		(* Control the indexing belts *)
		ThisStackerGroup 							:= (g_HCfg.NumberOfStackers+1)/2;	
 

		CASE g_OutletProcess.StackerUnit[i].BeltState OF

			MACHPROC_STARTUP_1:

				g_OutletProcess.StackerUnit[i].RollOff						:= FALSE;
				g_OutletProcess.StackerUnit[i].Motor.cmdStop				:= TRUE;
				g_OutletProcess.StackerUnit[i].LiftMotor.cmdStop			:= TRUE;
				g_OutletProcess.JenwayIsIndexing							:= FALSE;
				(* Normal is TransferStatus set by next process. But if this is a slave with XML com can this be locking up since Outlet task is remanent. So for safety is this value cleared also here *)
				g_OutletProcess.StackerUnit[i].Next.TransferStatus 			:= EXC_STANDBY_0;
				(* check last state of belt to continue where stopped last time *)
				IF g_OutletProcess.StackerUnit[i].SaveBeltState > 0 THEN
					g_OutletProcess.StackerUnit[i].BeltState				:= MACHPROC_DELIVER_PACKAGE_80;(*g_OutletProcess.StackerUnit[i].SaveBeltState;*)
				ELSE
					g_OutletProcess.StackerUnit[i].BeltState				:= MACHPROC_RUN_20;
				END_IF
			

				(*#####################*)
				(* Main running state  *)
				(*#####################*)

			MACHPROC_RUN_20:

				IF g_Core.System.Interface.alarms.isLowAirPressure THEN
					; // Wait air ok.
				ELSIF g_HCfg.DeliveryExternalCommunication = 0 THEN		// The normal case when nothing is connected after the stacker belt...

					IF (g_HCfg.DeliveryConveyor = 0) AND (g_HCfg.DeliveryConveyorFotoSensorEnd = 1) AND (g_OutletProcess.StackerUnit[i].BeltBlockSensor.Output) THEN
						g_OutletProcess.StackerUnit[i].BlockDelivery := TRUE;
					ELSIF (g_HCfg.DeliveryConveyor >= 1) AND (g_HCfg.DeliveryConveyorFotoSensorEnd = 1) AND (g_OutletProcess.StackerUnit[i].BeltBlockSensor.Output) AND (g_MCfg.Outlet.CrossBeltNr[i] = 0) THEN
						g_OutletProcess.StackerUnit[i].BlockDelivery := TRUE;					
					ELSE
						g_OutletProcess.StackerUnit[i].BlockDelivery := FALSE;
					END_IF
				 
					IF (NOT g_OutletProcess.StackerUnit[i].BlockDelivery) THEN											

						IF (g_OutletProcess.StackerUnit[i].LiftState = MACHPROC_WAIT_INDEX_37) THEN
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Outlet, Lift is done');
							(* Wait for Table to request to index *)
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Belt indexing');
							g_OutletProcess.StackerUnit[i].BeltIsIndexing		:= TRUE;
							g_OutletProcess.StackerUnit[i].BeltState			:= MACHPROC_INDEX_RUN_24;
							g_OutletProcess.StackerUnit[i].Motor.cmdForward		:= TRUE;
							//09-09-01...
							IF g_OutletProcess.StackerUnit[i].LiftState = MACHPROC_WAIT_INDEX_37 THEN
								g_OutletProcess.StackerUnit[i].LiftMotor.cmdForward	:= TRUE;
							END_IF	
						END_IF
					END_IF		
						
				ELSIF g_HCfg.DeliveryExternalCommunication = 2 OR g_Core.Services.System.Runtime.file.Connection[3].isEnabled THEN		// A real jenway with XML communication is connected directly after an Online machine...
					IF (g_OutletProcess.StackerUnit[i].LiftState = MACHPROC_WAIT_INDEX_37) AND g_Core.System.Runtime.isRunning THEN
						// A stack is present at end of inlcine belt...
						IF g_OutletProcess.StackerUnit[1].BeltEndSensor.Output THEN	
									g_Jenway.No[0].Request := 1; // send request to jenway
									IF g_OutletProcess.NextMachineReady[i] THEN									// Jenway ready
											g_Jenway.No[0].Go :=	1;																// transfer to Jenway
											//Buffer data shift here?
											DeliveringToJenway	:= TRUE;	
											// buffer stack data							
											DataBuffer; 				// call action		
											// Belt indexing
											g_OutletProcess.StackerUnit[i].BeltIsIndexing		:= TRUE;
											g_OutletProcess.StackerUnit[i].BeltState			:= MACHPROC_INDEX_RUN_24;
											g_OutletProcess.StackerUnit[i].Motor.cmdForward		:= TRUE;
											IF g_OutletProcess.StackerUnit[i].LiftState = MACHPROC_WAIT_INDEX_37 THEN
												g_OutletProcess.StackerUnit[i].LiftMotor.cmdForward	:= TRUE;
											END_IF	
	//										g_OutletProcess.StackerUnit[i].Motor.cmdForward		:= TRUE;
	//										g_OutletProcess.StackerUnit[i].BeltState			:= MACHPROC_INDEX_DELIVER_JENWAY_29;		// to run outlet belt for one stack size
									END_IF
						ELSE 				// no stack  present at end of inlcine belt
									// buffer stack data							
									DataBuffer; 				// call action					
									// Belt indexing
									DeliveringToJenway	:= FALSE;	
									g_OutletProcess.StackerUnit[i].BeltIsIndexing		:= TRUE;
									g_OutletProcess.StackerUnit[i].BeltState			:= MACHPROC_INDEX_RUN_24;
									g_OutletProcess.StackerUnit[i].Motor.cmdForward		:= TRUE;
									IF g_OutletProcess.StackerUnit[i].LiftState = MACHPROC_WAIT_INDEX_37 THEN
										g_OutletProcess.StackerUnit[i].LiftMotor.cmdForward	:= TRUE;
									END_IF	
				
						END_IF
					END_IF	
			
				ELSIF (g_HCfg.DeliveryExternalCommunication = 3 OR g_HCfg.DeliveryExternalCommunication = 4) THEN  	// A real Jenway with I/O communication is connected directly after an Online machine..
					IF PrinterSimulation THEN
						IF NOT PrinterSimulationTrigger THEN
							// Set dummy Stackdata
							PrinterSimulationTrigger := TRUE;
							g_OutletProcess.StackerUnit[1].StackData[1].BatchId := g_OutletProcess.StackerUnit[1].StackData[1].BatchId + 1;
							g_OutletProcess.StackerUnit[1].StackData[1].Count := 1;
							g_OutletProcess.StackerUnit[1].StackData[1].ItemData[1].CustomerId		:= 90;
							g_OutletProcess.StackerUnit[1].StackData[1].ItemData[1].ArticleId		:= 91;	
							g_OutletProcess.StackerUnit[1].StackData[1].ItemData[1].FoldProgram		:= 3;
							Dummy := UDINT_TO_DINT(g_OutletProcess.StackerUnit[1].StackData[1].BatchId + 10);
							itoa(Dummy, ADR(g_OutletProcess.StackerUnit[1].StackData[1].ItemData[1].HangerId));					
							Dummy := Dummy + 10;
							itoa(Dummy, ADR(g_OutletProcess.StackerUnit[1].StackData[1].ItemData[1].GarmentId));					
						END_IF	
					END_IF	
					IF (g_OutletProcess.StackerUnit[i].LiftState = MACHPROC_WAIT_INDEX_37) AND g_Core.System.Runtime.isRunning THEN
						// A stack is present at end of inlcine belt...
						RBlockSensor := g_OutletProcess.StackerUnit[i].BeltBlockSensor.Output;
						IF RBlockSensor THEN //g_OutletProcess.StackerUnit[1].BeltEndSensor.Output THEN	
							IF (g_OutletProcess.NextMachineReady[i]) AND (NOT g_OutletProcess.StackerUnit[i].BlockDelivery) THEN
								LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag,0,'Out, Unl req I/O rolloff');
								// Printer Com
								g_WaitingMLabel	:= 0;	
								IF (MLabelEnabled) AND (g_OutletProcess.StackerUnit[1].StackData[0].Count > 0) OR (g_PrinterCom.FolderStatus = PP_WANT_TO_UNLOAD_30) THEN // Empty stack, skip Mlabel
									g_WaitingMLabel	:= g_PrinterCom.MLabelStatus = 0;	
									IF (g_PrinterCom.MLabelStatus = PP_STANDBY_10) AND (g_PrinterCom.FolderStatus <> PP_WANT_TO_UNLOAD_30) AND (i = 1) THEN
										g_OutletProcess.StackerUnit[1].StackData[1]		:= g_OutletProcess.StackerUnit[1].StackData[0];
										g_OutletProcess.StackerUnit[1].StackData[0]		:= ZeroStackData;
										g_PrinterCom.FolderStatus 					:= PP_WANT_TO_UNLOAD_30;	// Folder wants to unload.
										LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_OutletProcess.Common.LogBookFlag, i, 'Want to unload');
									END_IF
									IF ((g_PrinterCom.MLabelStatus = PP_READY_TO_RECIVE_15) OR (g_PrinterCom.MLabelStatus = PP_NO_PRINT_21)) AND (i = 1) THEN
										LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_OutletProcess.Common.LogBookFlag, i, 'Ready to unload');
										g_PrinterCom.FolderStatus 					:= PP_STACK_ON_WAY_31;	// Folder wants to unload.
										g_OutletProcess.JenwayIsIndexing					:= TRUE;
										g_OutletProcess.StackerUnit[i].BeltIsIndexing		:= TRUE;
										g_OutletProcess.StackerUnit[i].BeltState			:= MACHPROC_INDEX_RUN_24;
										g_OutletProcess.StackerUnit[i].Motor.cmdForward		:= TRUE;
										IF g_OutletProcess.StackerUnit[i].LiftState = MACHPROC_WAIT_INDEX_37 THEN
											g_OutletProcess.StackerUnit[i].LiftMotor.cmdForward	:= TRUE;
										END_IF	
									END_IF	
								ELSE
									rEmptyStack := TRUE; // Empty stack, skip Mlabel
									g_OutletProcess.JenwayIsIndexing					:= TRUE;
									g_OutletProcess.StackerUnit[i].BeltIsIndexing		:= TRUE;
									g_OutletProcess.StackerUnit[i].BeltState			:= MACHPROC_INDEX_RUN_24;
									g_OutletProcess.StackerUnit[i].Motor.cmdForward		:= TRUE;
									IF g_OutletProcess.StackerUnit[i].LiftState = MACHPROC_WAIT_INDEX_37 THEN
										g_OutletProcess.StackerUnit[i].LiftMotor.cmdForward	:= TRUE;
									
									END_IF	
								END_IF
							END_IF		
							// No stack at end of incline belt go ahead and make index with out handshake with jenway		
						ELSE
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag,0,'Out, Unl req I/O rolloff no stack');
							// Printer Com
							IF (MLabelEnabled) AND (g_OutletProcess.StackerUnit[1].StackData[0].Count > 0) OR (g_PrinterCom.FolderStatus = PP_WANT_TO_UNLOAD_30) THEN // Empty stack, skip Mlabel
								IF (g_PrinterCom.MLabelStatus = PP_STANDBY_10) AND (g_PrinterCom.FolderStatus <> PP_WANT_TO_UNLOAD_30) AND (i = 1) THEN
									g_OutletProcess.StackerUnit[1].StackData[1]		:= g_OutletProcess.StackerUnit[1].StackData[0];
									g_OutletProcess.StackerUnit[1].StackData[0]		:= ZeroStackData;
									g_PrinterCom.FolderStatus 					:= PP_WANT_TO_UNLOAD_30;	// Folder wants to unload.
									LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_OutletProcess.Common.LogBookFlag, i, 'Want to unload');
								END_IF
								IF ((g_PrinterCom.MLabelStatus = PP_READY_TO_RECIVE_15) OR (g_PrinterCom.MLabelStatus = PP_NO_PRINT_21)) AND (i = 1) THEN
									LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_OutletProcess.Common.LogBookFlag, i, 'Ready to unload');
									g_PrinterCom.FolderStatus 					:= PP_STACK_ON_WAY_31;	// Folder wants to unload.
									g_OutletProcess.JenwayIsIndexing					:= TRUE;
									g_OutletProcess.StackerUnit[i].BeltIsIndexing		:= TRUE;
									g_OutletProcess.StackerUnit[i].BeltState			:= MACHPROC_INDEX_RUN_24;
									g_OutletProcess.StackerUnit[i].Motor.cmdForward		:= TRUE;
									IF g_OutletProcess.StackerUnit[i].LiftState = MACHPROC_WAIT_INDEX_37 THEN
										g_OutletProcess.StackerUnit[i].LiftMotor.cmdForward	:= TRUE;
									END_IF	
								END_IF	
							ELSE
								rEmptyStack := TRUE; // Empty stack, skip Mlabel
								g_OutletProcess.JenwayIsIndexing					:= TRUE;
								g_OutletProcess.StackerUnit[i].BeltIsIndexing		:= TRUE;
								g_OutletProcess.StackerUnit[i].BeltState			:= MACHPROC_INDEX_RUN_24;
								g_OutletProcess.StackerUnit[i].Motor.cmdForward		:= TRUE;
								IF g_OutletProcess.StackerUnit[i].LiftState = MACHPROC_WAIT_INDEX_37 THEN
									g_OutletProcess.StackerUnit[i].LiftMotor.cmdForward	:= TRUE;
								END_IF	
								IF (g_MCfg.Stacker.BeltExtention > 0) THEN //AND (g_OutletProcess.StackerUnit[i].BeltIsIndexing) THEN
									g_OutletProcess.StackerExtentionRun := TRUE;
								END_IF																							
							END_IF		
						END_IF	
					END_IF
				END_IF	


			MACHPROC_INDEX_WAIT_JENWAY_23:
		
		
//				IF g_OutletProcess.JenwayExchange[i].TransferStatus = EXC_RECIVING_4 THEN
				IF NOT g_Jenway.No[0].Request THEN 
					g_Jenway.No[0].Request := 1; // send request to jenway					
				END_IF
				
				IF g_OutletProcess.NextMachineReady[i]  OR (g_JenwayCom.outlet[0].runtime.isReady) OR (NOT g_OutletProcess.StackerUnit[1].BeltEndSensor.Output) THEN	
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 5, g_OutletProcess.Common.LogBookFlag,0, 'Outlet, JenWay can recieve');
					// buffer data shift
					//					DataShifting;
					DeliveringToJenway	:= TRUE;
					g_OutletProcess.StackerUnit[i].BeltIsIndexing		:= TRUE;
					PositionStamp	:= StateTimeCount;
					g_OutletProcess.StackerUnit[i].BeltState			:= MACHPROC_INDEX_RUN_24;
					g_OutletProcess.StackerUnit[i].Motor.cmdForward		:= TRUE;
					IF g_OutletProcess.StackerUnit[i].LiftState = MACHPROC_WAIT_INDEX_37 THEN
						g_OutletProcess.StackerUnit[i].LiftMotor.cmdForward	:= TRUE;
					END_IF	
				END_IF


			MACHPROC_INDEX_RUN_24:
	
				StateTimeCount	:= StateTimeCount + 1;		// how long motor has run
				// Run lift motor until stack has left lift...
				IF g_OutletProcess.StackerUnit[1].BeltEndSensorEdge  AND (i = 2) AND (g_HCfg.DeliveryExternalCommunication <> 0) AND NOT DeliveringToJenway THEN  // only for stacker 2
					g_OutletProcess.StackerUnit[i].Motor.cmdStop		:= TRUE;
					g_OutletProcess.StackerUnit[i].LiftMotor.cmdStop	:= TRUE;
					g_OutletProcess.StackerUnit[i].BeltState	:= MACHPROC_INDEX_WAIT_JENWAY_23;	 // previos stack reached beltend lift and outlet should stop and wait until that stack delivered to jenway or removed
					g_OutletProcess.StackerUnit[1].BeltEndSensorEdge	:= FALSE;
				ELSIF (ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].Motor.RunTimer) >=  g_MCfg.Stacker.LiftRaiseDelay )  THEN
					PositionStamp	:= 0;
					IF (g_OutletProcess.Parameters[i].Mode = OUTLETMODE_SINGLE_0) OR g_OutletProcess.StackerUnit[i].StackChange THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Belt single');
						g_OutletProcess.StackerUnit[i].LiftState 		:= MACHPROC_STARTUP_1; 			// Allow lift to go up again for next 
						//g_OutletProcess.StackerUnit[i].StackData[1]		:= g_OutletProcess.StackerUnit[i].StackData[0];
						//g_OutletProcess.StackerUnit[i].StackData[0]		:= ZeroStackData;
						g_OutletProcess.StackerUnit[i].LiftMotor.cmdStop := REnableOrgJECHStop;
						g_OutletProcess.StackerUnit[i].Counter			:= 0;
						StackIndexNumber 								:= StackIndexNumber + 1; 
						PrinterTimeOutTimer								:= g_OutletProcess.Common.CurTimer;
						//g_PrinterCom.FolderStatus 						:= PP_STANDBY_10;	
						//					StackIndexNumber 								:= StackIndexNumber + 1;		// Increase the stack counter for every new stack...	
						StateTimeCount		:= 0;
						g_OutletProcess.StackerUnit[i].LiftMotor.cmdStop := TRUE;
						g_OutletProcess.StackerUnit[i].BeltState		:= MACHPROC_INDEX_TO_ROLLOFF_27;

					ELSE (* Double Stacks *)
						IF g_OutletProcess.StackerUnit[i].DoubleWaiting THEN
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Belt double wait');
							g_OutletProcess.StackerUnit[i].LiftState 		:= MACHPROC_STARTUP_1; 		// Allow lift to go up again for next 
							g_OutletProcess.StackerUnit[i].StackData[1].Count	:= g_OutletProcess.StackerUnit[i].StackData[1].Count + g_OutletProcess.StackerUnit[i].StackData[0].Count;
							g_OutletProcess.StackerUnit[i].StackData[0]			:= ZeroStackData;
							g_OutletProcess.StackerUnit[i].Counter				:= 0;
							g_OutletProcess.StackerUnit[i].LiftMotor.cmdStop 	:= TRUE;
							g_OutletProcess.StackerUnit[i].DoubleWaiting		:= FALSE;
							StackIndexNumber 									:= StackIndexNumber + 1;
							PrinterTimeOutTimer									:= g_OutletProcess.Common.CurTimer;
							//g_PrinterCom.FolderStatus 							:= PP_STANDBY_10;	
							//						StackIndexNumber 									:= StackIndexNumber + 1;		// Increase the stack counter for every new stack...	
							g_OutletProcess.StackerUnit[i].LiftMotor.cmdStop := TRUE;
							g_OutletProcess.StackerUnit[i].BeltState			:= MACHPROC_INDEX_TO_ROLLOFF_27;
						ELSE
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Belt double index');
							g_OutletProcess.StackerUnit[i].LiftState 		:= MACHPROC_STARTUP_1; 		// Allow lift to go up again for next 
							g_OutletProcess.StackerUnit[i].StackData[1]		:= g_OutletProcess.StackerUnit[i].StackData[0];
							g_OutletProcess.StackerUnit[i].StackData[0]		:= ZeroStackData;
							g_OutletProcess.StackerUnit[i].Counter			:= 0;
							g_OutletProcess.StackerUnit[i].Motor.cmdStop	:= TRUE;
							g_OutletProcess.StackerUnit[i].LiftMotor.cmdStop := TRUE;
							g_OutletProcess.StackerUnit[i].DoubleWaiting	:= TRUE;
							g_OutletProcess.StackerUnit[i].BeltIsIndexing	:= FALSE;
							g_OutletProcess.StackerUnit[i].BeltState		:= MACHPROC_RUN_20;
						END_IF
					END_IF					
				END_IF




			MACHPROC_INDEX_NO_LIFT_25:
				IF (g_OutletProcess.Parameters[i].Mode = OUTLETMODE_SINGLE_0) OR g_OutletProcess.StackerUnit[i].StackChange OR g_OutletProcess.StackerUnit[i].DoubleWaiting THEN
					g_OutletProcess.StackerUnit[i].SaveBeltState		:= MACHPROC_DELIVER_PACKAGE_80;
					g_OutletProcess.StackerUnit[i].BeltState			:= MACHPROC_DELIVER_PACKAGE_80;
					g_OutletProcess.StackerUnit[i].DoubleWaiting		:= FALSE;
					(* A little cross copy to keep extra stack data in stack[2] *)
					g_OutletProcess.StackerUnit[i].StackData[1]			:= g_OutletProcess.StackerUnit[i].StackData[2];
					g_OutletProcess.StackerUnit[i].StackData[2]			:= g_OutletProcess.StackerUnit[i].StackData[0];
					g_OutletProcess.StackerUnit[i].StackData[0]			:= ZeroStackData;
					g_OutletProcess.StackerUnit[i].Counter				:= 0;
				ELSE (* Double Stacks *)
					g_OutletProcess.StackerUnit[i].Motor.cmdForward		:= TRUE;
					g_OutletProcess.StackerUnit[i].LiftMotor.cmdForward	:= TRUE;
					g_OutletProcess.StackerUnit[i].BeltState			:= MACHPROC_DOUBLE_MOVE_26;
				END_IF

			MACHPROC_DOUBLE_MOVE_26:
				// ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].Motor.RunTimer) >= g_OutletProcess.Parameters.LiftRaiseDelay THEN
				IF ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].Motor.RunTimer) >= g_MCfg.Stacker.LiftRaiseDelay THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Belt double index');
					g_OutletProcess.StackerUnit[i].LiftState 			:= MACHPROC_STARTUP_1; (* Restart lift sequense *)
					g_OutletProcess.StackerUnit[i].Counter				:= 0;
					g_OutletProcess.StackerUnit[i].Motor.cmdStop		:= TRUE;
					g_OutletProcess.StackerUnit[i].LiftMotor.cmdStop 	:= TRUE;
					g_OutletProcess.StackerUnit[i].DoubleWaiting		:= TRUE;
					g_OutletProcess.StackerUnit[i].BeltIsIndexing		:= FALSE;
					g_OutletProcess.StackerUnit[i].BeltState			:= MACHPROC_RUN_20;
				END_IF

			MACHPROC_INDEX_TO_ROLLOFF_27:			(*  TEST  *)
				IF g_OutletProcess.DoubleIndex AND (g_HCfg.CrossConveyor = 0) THEN //longer indexing if customer changes and special case (Stackchange on Metric-command and reset)
					g_OutletProcess.BeltIndexing := (g_ACfg[ACfgProgram].FullIndexingTime[i] * 2);
					g_HangerInletProcess.CustomerStackChange	:= FALSE;
				ELSE
					g_OutletProcess.BeltIndexing := g_ACfg[ACfgProgram].FullIndexingTime[i];
				END_IF

				//				IF ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].Motor.RunTimer) >= g_OutletProcess.BeltIndexing THEN //(g_OutletProcess.Parameters[i].FullIndexingTime) THEN 
				// added a condition to choose between transport or accumulate on outlet conveyor
				IF	 ( ( (g_MCfg.Delivery.Function = DELIVERY_FUNCTION_TRANSPORT_1) AND (g_HCfg.CrossConveyor =0)) AND (  g_OutletProcess.StackerUnit[1].BeltEndSensorEdge OR ( (ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].Motor.RunTimer) >=  g_OutletProcess.StackerUnit[i].Motor.RunTime)) ) 
							OR ( ( (g_MCfg.Delivery.Function = DELIVERY_FUNCTION_ACCUMULATE_0 OR g_HCfg.DeliveryExternalCommunication =0) AND g_HCfg.CrossConveyor =0) 
							AND (  g_OutletProcess.StackerUnit[1].BeltEndSensorEdge OR (ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].Motor.RunTimer) >=  g_OutletProcess.BeltIndexing) ) )  
					OR ( (g_HCfg.CrossConveyor = 1) AND( (ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].Motor.RunTimer) >=  g_OutletProcess.BeltIndexing) ) ) ) THEN
					//LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Belt rolloff end');
					g_OutletProcess.StackerUnit[1].BeltEndSensorEdge	:= FALSE;
					DeliveringToJenway		:= FALSE;
					g_OutletProcess.StackerUnit[i].Motor.cmdStop		:= TRUE;
					g_OutletProcess.StackerUnit[i].LiftMotor.cmdStop	:= TRUE;
					g_OutletProcess.JenwayIsIndexing					:= FALSE;
					IF (g_HCfg.CrossConveyor >= 1) AND (g_MCfg.Outlet.CrossBeltNr[i] > 0) THEN
						g_OutletProcess.StackerUnit[i].SaveBeltState	:= MACHPROC_DELIVER_PACKAGE_80;
						g_OutletProcess.StackerUnit[i].BeltState		:= MACHPROC_DELIVER_PACKAGE_80;
					ELSE
					
					
						IF (MLabelEnabled) AND (i = 1) AND NOT rEmptyStack THEN // Empty stack, skip Mlabel THEN
							//#############
							// MLable printing is done here, stack leaves machine and Belt is stopped here to start work on next stack..
							// And we have stack data in the "	g_OutletProcess.StackerUnit[1].StackData[1]	"...
							// All off this is hardcoded to StackerUnit 1, Is not needed for a Multistacker machine
							//#############

							// Printer simulation for Desktop use only ..
							IF PrinterSimulation THEN
								PrinterTimeOutTimer := g_OutletProcess.Common.CurTimer;
							END_IF	
					
							// Time out if no reply from MLabel or incorrect answer
							IF ElapsedMsTime(g_OutletProcess.Common.CurTimer, PrinterTimeOutTimer) >= 8000 THEN		// This timer is influensed by the one above aswell wath out...
								LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_OutletProcess.Common.LogBookFlag, PrinterState, 'Printer Time Out');
								g_PrinterCom.MLabelStatus 					:= PP_STANDBY_10;
								TimeOutCounter 								:= TimeOutCounter + 1;
								PrinterState 								:= PP_STATE_START_0;
								g_OutletProcess.StackerUnit[i].BeltState	:= MACHPROC_DO_EXIT_83;	
							END_IF

							// Sub state for communication with MLabel...
							CASE PrinterState OF
	  						
								// Start communicate with MLable
								PP_STATE_START_0:						
									PrinterTimeOutTimer := g_OutletProcess.Common.CurTimer;
									//IF (g_PrinterCom.MLabelStatus = PP_STANDBY_10) THEN				// MLabel is ready to recieve.
									IF (g_PrinterCom.MLabelStatus = PP_STATE_WAIT_POSITION_16) THEN							// MLabel is ready to recieve. V1.08.1
										LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_OutletProcess.Common.LogBookFlag, i, 'In position');
										g_PrinterCom.FolderStatus 					:= PP_STACK_IN_POSITION_32;	// Folder has stack in position
										PrinterTimeOutTimer 						:= g_OutletProcess.Common.CurTimer;
										g_PrinterCom.MLabelStatus 					:= -1;
										PrinterState 								:= PP_STATE_WAIT_PRINT_10;
									ELSIF g_PrinterCom.MLabelStatus = PP_NO_PRINT_21 THEN						// MLabel say no print used stack without label, our no physical printer	
										PrinterState 								:= PP_STATE_NOPRINT_30;	
									ELSIF g_PrinterCom.MLabelStatus = PP_PRINT_FAILED_2 THEN					// MLabel failed to print, wait for correction	
										IF g_PrinterCom.MLabelStatus <> OldMLabelState THEN
											LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_OutletProcess.Common.LogBookFlag, i, 'Print failed - 5');
										END_IF	
									ELSE
										LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_OutletProcess.Common.LogBookFlag, g_PrinterCom.MLabelStatus, 'Print Unknowned answer - 5');
										PrinterState								:= PP_STATE_START_0;
										PrinterSimulationTrigger 					:= FALSE;
										g_OutletProcess.StackerUnit[i].BeltState	:= MACHPROC_DO_EXIT_83;	
									END_IF
						
									// Wait for MLabel to print the label
								PP_STATE_WAIT_PRINT_10:
									PrinterTimeOutTimer := g_OutletProcess.Common.CurTimer;
									// MLabel sets PP_STANDBY_10 when printing is done
									IF g_PrinterCom.MLabelStatus = PP_STANDBY_10 THEN	
										LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_OutletProcess.Common.LogBookFlag, i, 'Printing finished');
										g_PrinterCom.FolderStatus 					:= PP_STANDBY_10;						
										g_LogStacker.LogType						:= UDINT_TO_UINT(g_OutletProcess.StackerUnit[1].StackData[1].BatchId);
										g_LogStacker.Item1							:= g_OutletProcess.StackerUnit[1].StackData[1].ItemData[1].HangerId;
										g_LogStacker.Item2							:= g_OutletProcess.StackerUnit[1].StackData[1].ItemData[2].HangerId;
										g_LogStacker.Item3							:= g_OutletProcess.StackerUnit[1].StackData[1].ItemData[3].HangerId;
										g_LogStacker.Item4							:= g_OutletProcess.StackerUnit[1].StackData[1].ItemData[4].HangerId;
										g_LogStacker.Item5							:= g_OutletProcess.StackerUnit[1].StackData[1].ItemData[5].HangerId;
										g_LogStacker.Item6							:= g_OutletProcess.StackerUnit[1].StackData[1].ItemData[6].HangerId;
										g_LogStacker.DoLog 							:= TRUE;
										PrinterTimeOutTimer 						:= g_OutletProcess.Common.CurTimer;
										PrinterState								:= PP_STATE_START_0;
										PrinterSimulationTrigger 					:= FALSE;
										g_PrinterCom.FolderStatus 					:= PP_STANDBY_10;	// Folder is idle
										g_WaitingMLabel	:= FALSE;	
										g_OutletProcess.StackerUnit[i].BeltState	:= MACHPROC_DO_EXIT_83;	
									ELSIF (g_PrinterCom.MLabelStatus = PP_READY_TO_RECIVE_15) THEN		// Wait for MLabel to responde
										;
									ELSIF (g_PrinterCom.MLabelStatus = PP_STATE_WAIT_POSITION_16) THEN	// Wait for MLabel to responde V1.08.1
										;
									ELSIF (g_PrinterCom.MLabelStatus = 65535) THEN						// Wait for MLabel to responde V1.08.1
										;
									ELSIF g_PrinterCom.MLabelStatus = PP_PRINT_FAILED_2 THEN			// MLabel failed to print, wait for correction	
										IF g_PrinterCom.MLabelStatus <> OldMLabelState THEN
											LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_OutletProcess.Common.LogBookFlag, g_PrinterCom.MLabelStatus, 'Print failed - 10');
										END_IF	
									ELSE
										LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_OutletProcess.Common.LogBookFlag, g_PrinterCom.MLabelStatus, 'Print Unknowned answer - 10');
										PrinterState								:= PP_STATE_START_0;
										g_PrinterCom.FolderStatus 					:= PP_STANDBY_10;	// Folder is idle
										g_WaitingMLabel	:= FALSE;	
										PrinterSimulationTrigger 					:= FALSE;
										g_OutletProcess.StackerUnit[i].BeltState	:= MACHPROC_DO_EXIT_83;	
									END_IF	
				
									// No printing 	
								PP_STATE_NOPRINT_30:
									g_PrinterCom.FolderStatus 	:= PP_STANDBY_10;						
									g_LogStacker.LogType		:= UDINT_TO_UINT(g_OutletProcess.StackerUnit[1].StackData[1].BatchId);
									g_LogStacker.Item1			:= g_OutletProcess.StackerUnit[1].StackData[1].ItemData[1].HangerId;
									g_LogStacker.Item2			:= g_OutletProcess.StackerUnit[1].StackData[1].ItemData[2].HangerId;
									g_LogStacker.Item3			:= g_OutletProcess.StackerUnit[1].StackData[1].ItemData[3].HangerId;
									g_LogStacker.Item4			:= g_OutletProcess.StackerUnit[1].StackData[1].ItemData[4].HangerId;
									g_LogStacker.Item5			:= g_OutletProcess.StackerUnit[1].StackData[1].ItemData[5].HangerId;
									g_LogStacker.Item6			:= g_OutletProcess.StackerUnit[1].StackData[1].ItemData[6].HangerId;
									g_LogStacker.DoLog 			:= TRUE;
									LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_OutletProcess.Common.LogBookFlag, i, 'No Print');
									g_OutletProcess.StackerUnit[1].StackData[1].BatchId := 0;
									PrinterState 										:= PP_STATE_START_0;
									PrinterSimulationTrigger 							:= FALSE;
									g_PrinterCom.FolderStatus 					:= PP_STANDBY_10;	// Folder is idle
									g_WaitingMLabel	:= FALSE;	
									g_OutletProcess.StackerUnit[i].BeltState			:= MACHPROC_DO_EXIT_83;		
							END_CASE
							// Make trigger for logmessages..
							OldMLabelState := g_PrinterCom.MLabelStatus;
							// Printer is bypassed due to operator decision when communication is lost..
							IF NOT g_PrinterCom.isEnabled THEN 	
								LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_OutletProcess.Common.LogBookFlag, i, 'Print bypassed');
								g_OutletProcess.StackerUnit[i].BeltState	:= MACHPROC_DO_EXIT_83;
							END_IF	
							// No printing option 
						ELSE
							rEmptyStack := FALSE; // Reset rEmptystack
							g_OutletProcess.StackerUnit[i].BeltState	:= MACHPROC_DO_EXIT_83;
						END_IF
					END_IF
   							
				END_IF
			
				// Stack has left incline belt finish hand shake with Jenway XML		
//				IF g_HCfg.DeliveryExternalCommunication = 2 THEN		// A real jenway with XML communication is connected directly after an Online machine...
//					g_OutletProcess.JenwayExchange.TransferStatus := EXC_FINISHED_UNLOADING_5;
//					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 5, g_OutletProcess.Common.LogBookFlag,0, 'Outlet, JenWay has the stack');
//				END_IF	
				

			MACHPROC_INDEX_DELIVER_JENWAY_29:	(*Outlet belt to run only for stack size when transferring to Jenway*)

				IF NOT g_OutletProcess.StackerUnit[1].BeltEndSensor.Output OR ( ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].Motor.RunTimer) >= 1500) THEN		// stack delivered to Jenway  --> need to add a filter here
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 5, g_OutletProcess.Common.LogBookFlag,0, 'Outlet delivered to Jenway');
					g_OutletProcess.StackerUnit[i].Motor.cmdStop		:= TRUE;
					g_OutletProcess.StackerUnit[i].BeltState	:= MACHPROC_DO_EXIT_83;
				END_IF;			
			

			MACHPROC_DELIVER_PACKAGE_80:

				(* Wait for next task to prepare to take over product. *)
				g_OutletProcess.StackerUnit[i].SaveBeltState			:= MACHPROC_DELIVER_PACKAGE_80;
				IF g_OutletProcess.StackerUnit[i].Next.TransferStatus = EXC_STANDBY_0 THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Belt cross can recive');
					//g_OutletProcess.StackerUnit[i].Next.Stack 			:= g_OutletProcess.StackerUnit[i].StackData[1];
					g_OutletProcess.StackerUnit[i].Next.TransferStatus 	:= EXC_WANT_TO_UNLOAD_1;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Belt deliver package');
					//g_OutletProcess.StackerUnit[i].BeltState			:= MACHPROC_PACKAGE_DELIVERING_91;
				ELSIF g_OutletProcess.StackerUnit[i].Next.TransferStatus = EXC_READY_TO_RECIEVE_2 THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 2, g_OutletProcess.Common.LogBookFlag, i, 'Belt fix to release lockup at basse muese');
					g_OutletProcess.StackerUnit[i].Next.Stack 			:= g_OutletProcess.StackerUnit[i].StackData[1];
					g_OutletProcess.StackerUnit[i].BeltState			:= MACHPROC_PACKAGE_DELIVERING_91;
				END_IF

			MACHPROC_PACKAGE_DELIVERING_91:

				IF g_OutletProcess.StackerUnit[i].Next.TransferStatus = EXC_READY_TO_RECIEVE_2 THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Belt start');
					g_OutletProcess.StackerUnit[i].Next.TransferStatus 		:= EXC_UNLOADING_3;
					g_OutletProcess.StackerUnit[i].Motor.cmdForward			:= TRUE;				
					g_OutletProcess.StackerUnit[i].BeltState				:= MACHPROC_DELAY_START_ROLL_OFF_92;
					//			ELSIF g_OutletProcess.StackerUnit[i].Next.TransferStatus < EXC_READY_TO_RECIEVE_2 AND g_OutletProcess.StackerUnit[i].LiftState = MACHPROC_WAIT_BELT_READY_38 THEN
					//				IF g_MCfg.Outlet.CrossBeltNr[i] = 1 THEN
					//					IF g_DeliveryProcess.Common.State = MACHPROC_RUN_20 THEN
					//						g_OutletProcess.StackerUnit[i].BeltState				:= MACHPROC_RUN_20;
					//					END_IF
					//				ELSIF g_MCfg.Outlet.CrossBeltNr[i] = 2 THEN
					//					IF g_DeliveryProcess2.Common.State = MACHPROC_RUN_20 THEN
					//						g_OutletProcess.StackerUnit[i].BeltState				:= MACHPROC_RUN_20;
					//					END_IF
					//				END_IF
				END_IF

			MACHPROC_DELAY_START_ROLL_OFF_92:
				IF ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].Motor.RunTimer) >= g_OutletProcess.Parameters[i].DelayRollOffOut THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Belt rolloff start');
					g_OutletProcess.StackerUnit[i].StackData[1]				:= ZeroStackData;
					g_OutletProcess.StackerUnit[i].RollOff					:= TRUE;
					g_OutletProcess.StackerUnit[i].BeltState				:= MACHPROC_PACKAGE_DELIVERED_81;
				END_IF

			MACHPROC_PACKAGE_DELIVERED_81:

				IF ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].Motor.RunTimer) < g_ACfg[ACfgProgram].FullIndexingTime[i] THEN		// Was not right timer POX 09-11-25
					;(* Do nothing *)
				ELSIF (g_OutletProcess.StackerUnit[i].Motor.State = MOTOR_STATE_RUN_2)  THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Belt rolloff done');
					//g_OutletProcess.StackerUnit[i].RollOff					:= FALSE;
					g_OutletProcess.StackerUnit[i].Motor.cmdStop			:= TRUE;
				ELSIF g_OutletProcess.StackerUnit[i].Next.TransferStatus = EXC_RECIVING_4 THEN
					g_OutletProcess.StackerUnit[i].RollOff					:= FALSE;
					//g_OutletProcess.StackerUnit[i].Motor.cmdStop			:= TRUE;
					//				g_OutletProcess.StackerUnit[i].Motor.cmdForward			:= TRUE;// needs to run also when cylinder goes back
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag, i, 'Belt crossbelt done');
					g_OutletProcess.StackerUnit[i].ExitTimer				:= g_OutletProcess.Common.CurTimer;
					g_OutletProcess.StackerUnit[i].BeltState				:= MACHPROC_WAIT_BEFORE_EXIT_82;
				END_IF

			MACHPROC_WAIT_BEFORE_EXIT_82:

				IF ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].ExitTimer) >= g_MCfg.Outlet.RollOffReturnTime THEN
					g_OutletProcess.StackerUnit[i].Motor.cmdStop			:= TRUE;
					g_OutletProcess.StackerUnit[i].BeltState				:= MACHPROC_DO_EXIT_83;
				END_IF

			MACHPROC_DO_EXIT_83:
			
				// If input to block feed on more stacks are not activated continue...
				//IF NOT g_OutletProcess.StackerUnit[i].BeltBlockSensor.Output THEN
				g_OutletProcess.StackerUnit[i].Next.TransferStatus 		:= EXC_FINISHED_UNLOADING_5;
				g_OutletProcess.StackerUnit[i].BeltState				:= MACHPROC_RUN_20;
				g_OutletProcess.StackerUnit[i].SaveBeltState			:= 0;
				g_OutletProcess.StackerUnit[i].BeltIsIndexing			:= FALSE;
			//END_IF
	


		END_CASE
		IF EDGEPOS( g_OutletProcess.StackerExtentionRun) THEN
			g_OutletProcess.StackerExtention.State := FOLDIO_STATE_START_1;
			g_OutletProcess.StackerExtentionRun := FALSE;
		END_IF		
	 
		RunFoldMotor(g_MCfg.Trace2File, ADR(T2FD), g_OutletProcess.StackerUnit[i].Motor, g_OutletProcess.Common.CurTimer, g_OutletProcess.Common.LogBookFlag);
		RunFoldMotor(g_MCfg.Trace2File, ADR(T2FD), g_OutletProcess.StackerUnit[i].LiftMotor, g_OutletProcess.Common.CurTimer, g_OutletProcess.Common.LogBookFlag);
	
		ActivateFoldIO(g_OutletProcess.StackerExtention, g_OutletProcess.Common.CurTimer);

		LiftOutputDelay[i](In := g_OutletProcess.StackerUnit[i].Up);
	
//		g_OutletProcess.StackerUnit[i].BeltEndSensorEdge := g_OutletProcess.StackerUnit[i].BeltEndSensor.Output;
		
	END_FOR

	IF EDGEPOS(g_OutletProcess.StackerUnit[1].BeltEndSensor.Output ) THEN
		g_OutletProcess.StackerUnit[1].BeltEndSensorEdge := TRUE;
	END_IF	
	
	// Prevent stackers from "banging" 
	MachineStop_TOF(IN := EDGENEG(g_Core.System.Runtime.isRunning) OR EDGEPOS(g_Core.System.Interface.alarms.isLowAirPressure), PT := T#3s);
	IF EDGEPOS(g_Core.System.Runtime.isRunning AND NOT MachineStop_TOF.Q) OR EDGENEG(g_Core.System.Interface.alarms.isLowAirPressure OR MachineStop_TOF.Q) THEN
		RestartPressDown.Set := TRUE;
	END_IF
	RestartPressDown(Delay := 550, CntAdr := ADR(g_MilliSeconds));

	FOR i := 1 TO g_HCfg.NumberOfStackers DO
		// JEDK FIX: To avoid stacker banging
		//		IF g_OutletProcess.Common.State = MACHPROC_INIT_0 THEN 
		IF RestartPressDown.Out THEN
			g_OutletProcess.StackerUnit[i].Up			:= FALSE;
			g_OutletProcess.StackerUnit[i].ReleaseBreak := TRUE;
		ELSE

			// Lift in top and jam occurs			
			IF LowerTableJam_TP[i].Q AND g_OutletProcess.StackerUnit[i].LiftMode <> LIFT_MODE_DOWN_2 AND g_OutletProcess.StackerUnit[i].LevelSensor.Output THEN
				LiftMode[i] := g_OutletProcess.StackerUnit[i].LiftMode;
				RLowerTableJam[i] := 0;
			END_IF
		
			// Lower table
			IF LowerTableJam_TP[i].Q AND RLowerTableJam[i] THEN
				g_OutletProcess.StackerUnit[i].LiftMode := LIFT_MODE_DOWN_2;
			END_IF
		
			// Reset position after jam
			IF RLowerTableJam[i] AND NOT LowerTableJam_TP[i].IN THEN
				g_OutletProcess.StackerUnit[i].LiftMode := LiftMode[i];
				RLowerTableJam[i] := 0;
			END_IF			

			CASE g_OutletProcess.StackerUnit[i].LiftMode OF
				LIFT_MODE_IDLE_0:
					g_OutletProcess.StackerUnit[i].Up			:= FALSE;
					g_OutletProcess.StackerUnit[i].ReleaseBreak := FALSE;
				LIFT_MODE_UP_1:
					g_OutletProcess.StackerUnit[i].Up			:= TRUE;
					g_OutletProcess.StackerUnit[i].ReleaseBreak := TRUE;
				LIFT_MODE_DOWN_2:
					g_OutletProcess.StackerUnit[i].Up			:= FALSE;
					g_OutletProcess.StackerUnit[i].ReleaseBreak := TRUE;
				LIFT_MODE_STOP_3:
					g_OutletProcess.StackerUnit[i].Up			:= TRUE;
					g_OutletProcess.StackerUnit[i].ReleaseBreak := FALSE;
				LIFT_MODE_BRAKE_LOCK_9:
					// Up is controled by external box 
					g_OutletProcess.StackerUnit[i].ReleaseBreak := TRUE;
			END_CASE
		END_IF	
	END_FOR

	// Check if Service page is active, then we can activate stacker test cycle from service task.
	IF g_HMIHandler.CurrentPage = PAGE_SERVICE_OUTLET THEN
		ServiceActive	:= TRUE;
	ELSE
		ServiceActive	:= FALSE;
	END_IF

	FOR i := 1 TO g_HCfg.NumberOfStackers DO
		IF g_OutletProcess.StackerUnit[i].LiftMotor.Run THEN
			LiftMotorHasRun[i] := TRUE;
		END_IF
		IF g_HMIMakeIndex[0] = 0 THEN
			LiftMotorHasRun[i] := FALSE;
		END_IF
			
		QMRollOff[i]		:= (g_OutletProcess.StackerUnit[i].Motor.Run OR OutletConveyor_Delay[i].Out OR OutletButton[i] OR (g_HMIMakeIndex[0] = 1) AND LiftMotorHasRun[i]) AND g_Core.System.Runtime.isRunning;
		QMLiftOutlet[i]		:= g_OutletProcess.StackerUnit[i].LiftMotor.Run AND g_Core.System.Runtime.isRunning;		
		QYLiftDown[i] 		:= LiftOutputDelay[i].Out AND NOT RestartPressDown.Out AND NOT MachineStop_TOF.Q AND (g_Core.System.Runtime.isRunning OR ServiceActive);
		QYLiftDownStop[i] 	:= g_OutletProcess.StackerUnit[i].ReleaseBreak AND NOT MachineStop_TOF.Q AND (g_Core.System.Runtime.isRunning OR ServiceActive OR RestartPressDown.Out);
		QYRollOffOut[i] 	:= g_OutletProcess.StackerUnit[i].RollOff AND g_Core.System.Runtime.isRunning;
	END_FOR

	IF g_HCfg.CrossConveyor = 0 THEN
		QKOutlet := g_OutletProcess.JenwayIsIndexing;
	END_IF

	IF RInit THEN
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 1, 1, 64738, 'Outlet Cyclic init');
	END_IF

	RInit := 0;

	(**********Jenway blocked*************)
	Ton_JenBlocked(IN := IBDeliveryBeltEnd AND (NOT g_OutletProcess.NextMachineReady[2] OR g_JenWayIsBlocked) AND g_Core.System.Runtime.isRunning ,PT := UDINT_TO_TIME (g_MCfg.Jenway.BlockTimer*1000));	// show text on main page
	IF Ton_JenBlocked.Q AND g_Core.System.Runtime.isRunning THEN
		g_Core.Services.Alarmhandler.Interface.AlarmGroup[CORE_INFOS].Alarm[17] := TRUE;		
		g_Core.Services.Alarmhandler.Interface.AlarmGroup[CORE_INFOS].Priority[17] := 200;	// Jenway Blocked
	ELSE
		g_Core.Services.Alarmhandler.Interface.AlarmGroup[CORE_INFOS].Alarm[17] := FALSE;
	END_IF
	
	Ton_JenBlocked2(IN := ((g_TopConveyorProcess.Common.State = 85) AND g_Core.Services.Alarmhandler.Interface.AlarmGroup[CORE_INFOS].Alarm[17] AND g_Core.System.Runtime.isRunning) ,PT := T#5s);	// show text on main page
	g_MainAlarms.Alarm[13] := Ton_JenBlocked2.Q AND g_Core.System.Runtime.isRunning;	// Machine is full and Jenway is blocked
	
	OldMilliSeconds := g_MilliSeconds;
END_PROGRAM