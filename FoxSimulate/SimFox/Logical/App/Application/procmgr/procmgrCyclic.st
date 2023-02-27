PROGRAM _CYCLIC
(*-------------------------------------------------------------------------------------

Author:   				Sten Flystedt.

FileName:				Task(file)name.scr

Desription:				Machine process manager...

Reference:

Interfaces:				No interfaces.

Watch debugg:			Name OF important watch configurations.

History:
10-03-18				V1.52.1	PO Nilsson			Bug fix from last version, timer was NOT connected...
10-03-12				V1.52.0	PO Nilsson			Increased timeout FOR softstop IF we have a cross conveyor...
10-02-18				V1.51.9	PO Nilsson			Added block on Forced stop in CASE _20 so simulation would work..	
10-01-25				V1.51.8	PO Nilsson			Jam time was counted cyclic AND NOT BY seconds..
09-12-11				V1.51.7	PO Nilsson			Time out on Soft StopAttempt, if Softstop failed...
09-12-03				V1.51.6	PO Nilsson			Added the g_ResetStackerNotDown TO reset old stacker lifters...
													Removed the Green button as reset possibility...
09-12-02				V1.51.5	PO Nilsson			Greeen button TO reset alarm aswell.
09-12-01				V1.51.4	PO Nilsson			Lowerd the time OF machine running time out, to get more Jenway blocked time..
09-11-11				V1.51.3	PO Nilsson			Added empty hanger block time counter...
09-09-15				V1.51.2	PO Nilsson			Start work on MultiStacker...	
09-09-21				V1.51.1	PO Nilsson			When stop attempt block inlet OF hangers, so machine can stop...	
09-08-13				V1.51.0	SF					No lamp FOR jenway block
													Stop machine even IF some task is in state 0(not used)
													Show Jenway blocked message as stopReason
													Count statistics FOR blocked jenway
09-05-13				V1.50	PO Nilsson			Adapted TO the FOX...
09-04-07				V1.22.1 SF					Service mode will now block start up OF machine with message.
09-03-09				V1.22 SF					Status icon on top bar+LogBookflag using LogEntry(g_MCfg.Trace2File, ADR(T2FD),) FUNCTION
09-01-22				V1.21 PO Nilsson			Added alarms from the BootUpFlag...

08-02-19				V1.20 Per-Olov Nilsson		Cleaned up FOR the new Exchange type.

07-10-01				V1.10 Per-Olov Nilsson		Updated FOR Trolley washer...

---------------------------------------------------------------------------------------*)

	IF (g_OptionsAndConfigInit = FALSE) OR (g_Core.Services.Recipe.Runtime.recipePointer = 0) THEN		(* Check that pointer is bigger then Null *)
		RETURN;
	END_IF	
	g_SystemInitialized := TRUE;
	
	// Set power save if no linen in hanger inlet if AF
	g_Core.System.Runtime.isPowerSave := (g_ManualInletProcess.Values.InletIsIdle OR g_HangerInletProcess.InletIsIdle) AND ISControlPlc AND (g_Core.Services.Alarmhandler.Runtime.Event[0].Status = 0);
		
	// Reset was made from alarm bar
	IF g_Core.Services.Alarmhandler.Runtime.Event[0].Acknowledged THEN
		g_Machine.ResetAllAlarm := TRUE;
	END_IF	

	(*#######################*)
	(* Get timer for process *)
	(*#######################*)
	CurTimer := g_Timers._1_ms;
	IF cmdLogBookFlag >= 0 THEN
		g_TopConveyorProcess.Common.LogBookFlag := cmdLogBookFlag;
		g_LateralProcess.Common.LogBookFlag := cmdLogBookFlag;
		g_CrossFoldAProcess.Common.LogBookFlag := cmdLogBookFlag;
		g_CrossFoldBProcess.Common.LogBookFlag := cmdLogBookFlag;
		g_StackerProcess[1].Common.LogBookFlag := cmdLogBookFlag;		
		g_StackerProcess[2].Common.LogBookFlag := cmdLogBookFlag;		
		g_StackerProcess[3].Common.LogBookFlag := cmdLogBookFlag;		
		g_StackerProcess[4].Common.LogBookFlag := cmdLogBookFlag;		
		g_StackerProcess[5].Common.LogBookFlag := cmdLogBookFlag;
			
		g_OutletProcess.Common.LogBookFlag := cmdLogBookFlag;
		g_DeliveryProcess.Common.LogBookFlag := cmdLogBookFlag;
		g_DeliveryProcess.Common.LogBookFlag := cmdLogBookFlag;
		//	g_RollOffProcess.Common.LogBookFlag := cmdLogBookFlag;
		cmdLogBookFlag := -1;
	END_IF

	// Check that pointer is bigger then Null 
	IF NOT (g_Core.Services.Recipe.Runtime.recipePointer > 0) THEN		
		RETURN;		
	END_IF

	StopReasonTextId := 0;

	(*################*)
	(* Connect inputs *)
	(*################*)
	g_Machine.StartButton := ISStartMachine OR g_VirtualStartKey;
	g_Machine.StopButton := g_SoftStopButton = 0;
	g_VirtualStopKey; (* Keep for the future *)

	ForceStopButton.Input := NOT g_Machine.StopButton;
	g_Machine.DoorsClosed := TRUE;

	(*########################################*)
	(* E-stop and Motor protection connection *)
	(*########################################*)
	// Activate Simulated operation (For Test panel i.e.)
	// g_Core.System.Runtime.isSimulation := g_Core.System.Runtime.isSimulation := 1;  

	IF g_Core.System.Runtime.isSimulation THEN
		g_Machine.EStopActivated := FALSE;
		g_Machine.MotorProtectionTripped := FALSE;
	ELSE
		g_Machine.EStopActivated := NOT ISEmergencyOk;
		g_Machine.MotorProtectionTripped := NOT ISThermoOk;
	END_IF

	LowAirPressure_TON(IN := NOT g_Machine.AirPressureIsOK AND NOT RFuseFault AND ISGuardOk AND ISEmergencyOk, PT := T#1s);
	IF g_HCfg.BRSafety THEN
		ISGuardOk := NOT g_Core.System.Interface.alarms.isGuardFault;
	ELSE
		g_Core.System.Interface.alarms.isGuardFault := NOT ISGuardOk;
	END_IF
	
	//	g_Core.System.Interface.alarms.isFuseFault24V :=  

	(*#######################*)
	(* Simulation start/stop *)
	(*#######################*)
	IF g_Core.System.Runtime.isSimulation THEN
		g_Machine.SimulStartButton := SimulStart;
		g_Machine.SimulStopButton := SimulStop;
		HMIButtonsVisible := 0;
	ELSE
		g_Machine.SimulStartButton := FALSE;
		g_Machine.SimulStopButton := FALSE;
		HMIButtonsVisible := 1;
	END_IF

	(*##################*)
	(* Motor Protection *)
	(*##################*)
	IF g_Machine.MotorProtectionTripped THEN (* Motor Protection *)
		IF MachineManagerStatus < MACHPROC_TRIG_ERROR_98 THEN
			MachineManagerStatus := MACHPROC_TRIG_ERROR_98;
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 4, g_MainLogBookFlag,9902, 'Motor Protect');
		END_IF
		StopReasonTextId := 2;	(* Motor protection *)
		g_MainAlarms.Alarm[1] := TRUE;
	ELSE
		g_MainAlarms.Alarm[1] := FALSE;
	END_IF

	//#######################
	// Air pressure control 
	//#######################

	// Do Softstop by g_Core;

	(*###################*)
	(* Main E-stop check *)
	(*###################*)
	g_MainAlarms.Alarm[0] := FALSE;
	IF NOT g_Core.System.Runtime.isRunning THEN
		IF MachineManagerStatus < MACHPROC_TRIG_ERROR_98 THEN
			MachineManagerStatus := MACHPROC_TRIG_ERROR_98;
		END_IF
		IF g_Machine.EStopActivated THEN
			StopReasonTextId := 1;	(* E-Stop *)
			//g_MainAlarms.Alarm[0] := TRUE;
		END_IF
	ELSE
		g_MainAlarms.Alarm[0] := FALSE;
	END_IF

	(*###############################*)
	(* Check Manual Feed Configuration  *)
	(* WM : See Task FeedTyp  					*)
	(*###############################*)
	// Do not allow the machine to run if the configured inlet dose not mach the machine components or option was changed during the operation 
	IF g_MainAlarms.Alarm[10]  // Option was changed 
		OR g_MainAlarms.Alarm[11] OR g_MainAlarms.Alarm[12] THEN // Configuration dose not mach Components 
		IF MachineManagerStatus < MACHPROC_TRIG_ERROR_98 THEN
			MachineManagerStatus := MACHPROC_TRIG_ERROR_98;
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 4, g_MainLogBookFlag,9902, 'Wrong Configuration of manual Feeding ');
		END_IF
		StopReasonTextId := 1;	(* E-Stop *)
	END_IF

	(* Set timers used *)
	ForceStopButton.OnDelay := 3000;
	ForceStopButton.OffDelay := 1;

	(* Run Input logic *)
	RunIOCounter(ForceStopButton,CurTimer);

	(*###########*)
	(* Main case *)
	(*###########*)
	CASE MachineManagerStatus OF
		(* Init *)
		MACHPROC_INIT_0:	
			g_HangerInletProcess.StopFeedingOnCustomerChange := FALSE;
			g_HangerInletProcess.CustomerStackChange := FALSE;
  		
			(* Clear Run flag *)
			FOR MachProcesIndex := 1 TO NUMBER_OF_MACHINE_PROCESSES DO
				g_MachineManager[MachProcesIndex].Run := FALSE;
				g_MachineManager[MachProcesIndex].ForcedStop := FALSE;
			END_FOR

			IF g_ProcessService THEN
				IF StopReasonTextId = 0 THEN
					StopReasonTextId := 11;
				END_IF
			END_IF

			(* Operator pressed start button *)
			IF EDGEPOS(g_Machine.StartButton) OR SimulStart THEN
				IF g_ProcessService THEN
					;(* No start is allowed *)
				ELSIF g_Machine.DoorsClosed THEN
					StopReasonTextId := 0;
					MachineManagerStatus := MACHPROC_STARTUP_1;
				ELSE
					StopReasonTextId := 10;
				END_IF
			END_IF

		MACHPROC_STARTUP_1:
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 4, g_MainLogBookFlag,9902, 'StartUp');
			g_Machine.StopAttempt := FALSE;
			g_HangerInletProcess.EnableFeeding := 1;					// Enable inlet of hangers 09-09-21..
			g_ManualInletProcess.Values.StopFeedingStatus := 1;					// Enable inlet of hangers 09-09-21..
		
			RelayDelay := 200;(* Stupid compensation for M/S relay that deactivates FeedingStopsensor while in Init mode *)
			(* Start feeding to get last pieces if there is any *)
			FOR MachProcesIndex := 1 TO NUMBER_OF_MACHINE_PROCESSES DO
				g_MachineManager[MachProcesIndex].Run := TRUE;
				g_MachineManager[MachProcesIndex].ControlFlag := MACHMGR_IDLE;

			END_FOR
			MachineManagerStatus :=	MACHPROC_RUN_20;

		MACHPROC_STOP_15: (* Stopping *)
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 4, g_MainLogBookFlag,StopReasonTextId, 'Operator Stop');
			FOR MachProcesIndex := 1 TO NUMBER_OF_MACHINE_PROCESSES DO
				g_MachineManager[MachProcesIndex].Run := FALSE;
			END_FOR

			StopReasonTextId := 12;(* Soft Stop *)

			MachineManagerStatus := MACHPROC_INIT_0;


		MACHPROC_FORCED_STOP_16:
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 4, g_MainLogBookFlag,9902, 'Forced stop');
			FOR MachProcesIndex := 1 TO NUMBER_OF_MACHINE_PROCESSES DO
				g_MachineManager[MachProcesIndex].Run := FALSE;
				g_MachineManager[MachProcesIndex].ForcedStop := TRUE;
			END_FOR

			StopReasonTextId := 99; (* Soft Stop *)
			// PMU Hack
			g_SoftStopDone := TRUE;
			MachineManagerStatus := MACHPROC_INIT_0;

			(* Running *)
		MACHPROC_RUN_20:
			(* Normal Stop / Soft stop *)
			IF EDGENEG(g_Machine.StopButton) OR EDGENEG(SimulStop) THEN (* operator tries to stop machine *)
				g_Machine.StopAttempt := TRUE;
				StopAttemptResetTimer := CurTimer;
				g_HangerInletProcess.EnableFeeding := 0;					// Block inlet of hangers to stop machine 09-09-21..
				g_ManualInletProcess.Values.StopFeedingStatus := 0;					// Block inlet of hangers to stop machine 09-09-21..
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 4, g_MainLogBookFlag,9902, 'Try to stop machine');
			END_IF
			(* Force Stop *)
			IF (ForceStopButton.Output) AND NOT SimulStart THEN		//10-02-18 POX
				g_HangerInletProcess.CustomerStackChange := FALSE;			
				MachineManagerStatus := MACHPROC_FORCED_STOP_16;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 4, g_MainLogBookFlag,9902, 'Forced stopping of machine');
			END_IF
		
			// Check that all process are idle to make Soft stop
			IF g_Machine.StopAttempt THEN
				IF g_HangerInletProcess.StopFeedingOnCustomerChange THEN
					MachineManagerDoIndex := TRUE;
					IF g_HangerInletProcess.CustomerStackChange THEN				
						StopReasonTextId := 101;
					ELSE
						StopReasonTextId := 102;
					END_IF
				ELSE				 
					StopReasonTextId := 12;(* Soft Stop *)
					g_OutletProcess.StackerUnit[2].BeltState := 20;
					g_OutletProcess.StackerUnit[2].LiftState := 20;
					g_OutletProcess.StackerGroupLink[2].State := 20;
					IF g_Machine.AllProcessesIdle THEN
						MachineManagerStatus := MACHPROC_STOP_15;
					END_IF
				END_IF
			END_IF		
		
			// Set higer time out if we have a cross conveyor
			IF g_HCfg.CrossConveyor = 1 THEN
				SoftStopTimeOut := 30000;
			ELSE
				SoftStopTimeOut := 17000;
			END_IF	
			// Clear StopAttempt after a time if any process is in error state or Soft stop failed.
			IF ElapsedMsTime(CurTimer, StopAttemptResetTimer) >= SoftStopTimeOut THEN
				g_Machine.StopAttempt := FALSE;
				IF StopReasonTextId = 12 THEN			// Soft Stop 
					StopReasonTextId := 5;				// Machine in operation
				END_IF			
			END_IF	
		
			IF (g_HCfg.HangerReading = 8) AND (g_ManualInletProcess.Values.ForcedNoCom = 0) THEN
				IF (g_ExternalCom.HangerState = EXTERN_HANGER_WAIT_2) THEN
					StopReasonTextId := 21;
				END_IF			
			END_IF
		
			// Empty hanger is blocked
			IF (StopReasonTextId = 0) AND g_EmptyHangerBlock THEN
				StopReasonTextId := 21;		
			END_IF

			IF (StopReasonTextId = 0) AND g_Core.System.Runtime.isRunning THEN (* There is no other message *)
				StopReasonTextId := 5;		(* POX  *)
			END_IF

			//JEDK
			IF g_Core.System.Runtime.isRunning AND NOT g_Machine.StopAttempt AND (StopReasonTextId <> 19) THEN
				IF g_DuoInletProcess.BlockNormalInlet THEN
					StopReasonTextId := 30;				// Duo inlet only
				ELSE	
					StopReasonTextId := 5;				// Machine in operation
				END_IF
			END_IF
			IF QKStartOk AND NOT StopReasonTextId = 12 THEN
				StopReasonTextId := 0;				// 'Machine ready to start' shows only after shutting down text
			END_IF  

			(* Statistic count of time *)
			IF g_Timers._1_sec <> g_Machine.OldSecond THEN
				g_Machine.OldSecond := g_Timers._1_sec;
			
				// What should we use here??
				IF QMLFold[1] THEN
					g_Machine.IsRunning := TRUE;
					g_Machine.IsRunningTimer := CurTimer;
				ELSIF g_Machine.IsRunning THEN
					IF ElapsedMsTime(CurTimer, g_Machine.IsRunningTimer) >= 2000 THEN
						g_Machine.IsRunning := FALSE;
					END_IF
				END_IF
				IF g_Machine.IsRunning THEN
					//IF (g_Machine.Program > 0) AND (g_Machine.Program < 100)THEN
					IF (g_LateralProcess.Common.Product.FoldProgram > 0) AND (g_LateralProcess.Common.Product.FoldProgram < 100) THEN
						g_Statistic[g_LateralProcess.Common.Product.FoldProgram].RunTime := g_Statistic[g_LateralProcess.Common.Product.FoldProgram].RunTime + 1;
					END_IF
					g_Statistic[0].RunTime := g_Statistic[0].RunTime + 1;
				ELSE
					// Empty hanger return is blocking the folder...
					g_EmptyHangerBlock;
					g_NoHangersAtInlet;
					//					IF g_EmptyHangerBlock THEN
					//						g_Statistic[0].EmptyHangerWaitTime := g_Statistic[0].EmptyHangerWaitTime + 1;
					//					END_IF
					//					// No hangers at Inlet wait for goods...
					//					IF g_NoHangersAtInlet THEN
					//						g_Statistic[0].NoHangersInletTime := g_Statistic[0].NoHangersInletTime + 1;
					//					END_IF
					// Machine has a Jam wait for reset..
					// This is done later in this task out side manager case.
				END_IF
				//			IF (g_Machine.Program > 0) AND (g_Machine.Program < 100)THEN
				//				g_Statistic[g_Machine.Program].OnTime := g_Statistic[g_Machine.Program].OnTime + 1;
				//			END_IF
				IF (g_LateralProcess.Common.Product.FoldProgram > 0) AND (g_LateralProcess.Common.Product.FoldProgram < 100) THEN
					g_Statistic[g_LateralProcess.Common.Product.FoldProgram].OnTime := g_Statistic[g_LateralProcess.Common.Product.FoldProgram].OnTime + 1;
				END_IF			
				g_Statistic[0].OnTime := g_Statistic[0].OnTime + 1;
			
				(*Calculate the stop state if machine by key or by button *)
				IF g_HangerInletProcess.EnableFeeding <> 1 THEN
					g_Statistic[0].Stopping := g_Statistic[0].Stopping+1; 		
				END_IF			
			END_IF
	
			(* Error trig *)
		MACHPROC_TRIG_ERROR_98:
			MachineManagerStatus := MACHPROC_ERROR_99;
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 4, g_MainLogBookFlag,StopReasonTextId, 'Manager Error');
			g_Machine.ErrorInProcess := TRUE;
			FOR MachProcesIndex := 1 TO NUMBER_OF_MACHINE_PROCESSES DO
				g_MachineManager[MachProcesIndex].Run := FALSE;
				(*g_MachineManager[MachProcesIndex].ControlFlag := MACHMGR_ERROR_IN_MACHINE;*)		
			END_FOR

			(* Error *)
		MACHPROC_ERROR_99:
			IF SimulStart OR EDGEPOS(g_Machine.StartButton) THEN (* Reset for start *)
				SimulStart := FALSE;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 4, g_MainLogBookFlag,StopReasonTextId, 'Manager Reset');
				MachineManagerStatus := MACHPROC_STARTUP_1;
		
			ELSIF ForceStopButton.Output THEN
				MachineManagerStatus :=	MACHPROC_FORCED_STOP_16;
			END_IF
	END_CASE

	(*################################*)
	(* Do Index on Customer Change... *)
	(*################################*)
	IF MachineManagerDoIndex THEN
		IF g_Machine.AllProcessesIdle AND g_HangerInletProcess.CustomerStackChange THEN
			IF (g_HCfg.IndexingConveyorsWithPushOff = 0) THEN
				g_OutletProcess.DoubleIndex := TRUE;	  				
			END_IF
			g_HangerInletProcess.CustomerChangeLMP := TRUE;
			FOR i := 1 TO g_HCfg.NumberOfStackers DO
				g_OutletProcess.StackerUnit[i].cmdIndex := 1;
			END_FOR	
		END_IF
	END_IF

	(*#########################################################################*)
	(* General control of processes regardless of what state the machine is in *)
	(*#########################################################################*)
	g_Machine.AllProcessesIdle := TRUE;
	g_ProcessAlarm := FALSE;
	g_ProcessService := FALSE;
	FOR MachProcesIndex := 1 TO NUMBER_OF_MACHINE_PROCESSES DO

		IF g_Core.System.Runtime.isSimulation THEN
			g_MachineManager[MachProcesIndex].Simulate := g_Core.System.Runtime.isSimulation;
		END_IF

		IF (g_MachineManager[MachProcesIndex].StatusData.State > MACHPROC_INIT_0) AND (g_MachineManager[MachProcesIndex].StatusData.State <> MACHPROC_RUN_20) AND (g_MachineManager[MachProcesIndex].StatusData.State <> MACHPROC_ERROR_99) THEN
			g_Machine.AllProcessesIdle := FALSE;
		END_IF

		IF (g_MachineManager[MachProcesIndex].StatusData.State = MACHPROC_ERROR_99) OR g_HangerInletProcess.Common.AlarmList.Alarm[8] THEN
			g_ProcessAlarm := TRUE;
			// Count jam time for the statistics
			IF g_ProcessAlarm THEN
				IF g_Timers._1_sec <> OldSecondsJam THEN
					OldSecondsJam := g_Timers._1_sec;
					g_Statistic[0].JamTime := g_Statistic[0].JamTime + 1;
				END_IF	
			END_IF		
		END_IF

		IF g_MachineManager[MachProcesIndex].StatusData.State = MACHPROC_MANUAL_8 THEN
			g_ProcessService := TRUE;
		END_IF
		(* Saftey door is opened *)
		IF NOT g_Machine.DoorsClosed THEN
			g_MachineManager[MachProcesIndex].ControlFlag := MACHMGR_DOOR_IS_OPEN;
		ELSIF (MachineManagerStatus >= MACHPROC_RUN_20) AND (MachineManagerStatus <= MACHPROC_TRIG_ERROR_98) THEN
			g_MachineManager[MachProcesIndex].ControlFlag := MACHMGR_IDLE;
		END_IF

		(* Reset any alarm *)
		IF g_Machine.ResetAllAlarm THEN
			g_ResetStackerNotDown := TRUE;
			g_MachineManager[MachProcesIndex].ResetAlarm := TRUE;
		END_IF
	END_FOR	
				
	(*########################################################################*)
	(* Status Icon, Show main status as iconm on top bar                       *)
	(*########################################################################*)
	IF g_StatusIcon.Key = 1 THEN
		//StatusSetMenu := SetMenuDirect(g_HMIHandler, PAGE_MACHINE_SERVICE);
		g_StatusIcon.Key := 0;
	END_IF

	CASE g_MachineManagerStatus OF
		0,1: (* Idle, starting up *)
			g_StatusIcon.Icon := 1;
		20:(* Run *)
			IF g_ProcessAlarm THEN
				g_StatusIcon.Icon := 3;
			ELSE
				g_StatusIcon.Icon := 2;
			END_IF
		15,16:(* Stopping *)
			g_StatusIcon.Icon := 1;
		98,99: (* Error *)
			g_StatusIcon.Icon := 3;
		ELSE (* Not used *)
			g_StatusIcon.Icon := 3;
	END_CASE

	(* If a process has cleared it's alarm *)
	IF g_ProcessAlarmCleared THEN
		IF StopReasonTextId >= 30 THEN
			StopReasonTextId := 0;
		END_IF
		g_ProcessAlarmCleared := FALSE;
	END_IF

	(*################################################################*)
	(* Set the Machine status for the XML communication with Metricon *)
	(*################################################################*)
	CASE g_MachineManagerStatus OF
		20:(* Run *)
			g_Core.Services.Communication.ConnectionHandler.FoldXML.Runtime.connection[0].data.ClientInfo.MachineStatus := MACHINE_STATE_AUTOMATIC;
	
		ELSE (* Not used *)
			g_Core.Services.Communication.ConnectionHandler.FoldXML.Runtime.connection[0].data.ClientInfo.MachineStatus := MACHINE_STATE_STANDBY;
	END_CASE

	(*##################*)
	(* Run Outputs      *)
	(*##################*)
	g_MachineManagerStatus := MachineManagerStatus;
	ManagerStatusTextId := MachineManagerStatus;

	// Inverter Thermofault #7
	IF g_Inverter.Drive[1].GetState = 23 THEN
		g_MainAlarms.Alarm[7] := TRUE;
		StopReasonTextId := 13;
	ELSE
		g_MainAlarms.Alarm[7] := FALSE;
	END_IF

	//---------------------------------------------------------
	// possible fuse fault
	//---------------------------------------------------------
	IF g_HCfg.BRSafety THEN
		g_Core.System.Interface.alarms.isGuardFault := NOT g_Core.System.Interface.alarms.isSafetyPlcError AND g_Core.System.Interface.alarms.isSafetyActive[2] OR g_Core.System.Interface.alarms.isSafetyActive[3] OR g_Core.System.Interface.alarms.isSafetyActive[4] OR g_Core.System.Interface.alarms.isSafetyActive[5] OR g_Core.System.Interface.alarms.isSafetyActive[6];
	ELSE	
		ISGuardOk := NOT(g_Core.System.Interface.alarms.isSafety1Active OR g_Core.System.Interface.alarms.isSafety2Active OR g_Core.System.Interface.alarms.isSafety3Active OR g_Core.System.Interface.alarms.isSafety4Active OR g_Core.System.Interface.alarms.isSafety5Active OR g_Core.System.Interface.alarms.isSafety6Active);
	END_IF
	ISEmergencyOk := NOT g_Core.System.Interface.alarms.isEStopActive;
	
	IF NOT ISGuardOk OR NOT ISEmergencyOk THEN
		g_GuardHasOpened := TRUE;	
	END_IF
	
	g_Machine.SafetyOk := NOT (g_Core.System.Interface.alarms.isExtEStopActive OR g_Core.System.Interface.alarms.isEStopActive OR g_Core.System.Interface.alarms.isSafety1Active OR g_Core.System.Interface.alarms.isSafety2Active OR g_Core.System.Interface.alarms.isSafety3Active OR g_Core.System.Interface.alarms.isSafety4Active OR g_Core.System.Interface.alarms.isSafety5Active OR g_Core.System.Interface.alarms.isSafety6Active OR g_Core.System.Interface.alarms.isSafetyPlcError);
	
	// Reset low air	
	IF g_ModuleFuseFault[0] THEN
		g_MainAlarms.Alarm[16] := 0;
	END_IF

	// Fuse Fault
	g_StopMachine := 0;
	RFuseFault := FALSE;
	RFuseFaultSide := FALSE;
	FuseFault24V := FALSE;

	FOR i := 1 TO MAX_NUMBER_OF_STACKERS DO
		IF NOT ISFuseOk[i] THEN
			RFuseFault := 1;
			g_StopMachine := 1;
		END_IF
	END_FOR

	RFuseFault := RFuseFault AND ISEmergencyOk AND ISGuardOk AND NOT g_ModuleFuseFault[0];


	IF NOT IFuseOkSideConv THEN
		RFuseFaultSide := 1;	
		g_StopMachine := 1;
	END_IF	

	RFuseFaultSide := RFuseFaultSide AND ISEmergencyOk AND ISGuardOk AND NOT g_ModuleFuseFault[0];

	// Fuse alarm
	g_MainAlarms.Alarm[3] := 0;
	IF RFuseFault AND NOT FuseFault24V THEN
		g_MainAlarms.Alarm[3] := 1;
		g_MainAlarms.Alarm[1] := 0;
		g_MainAlarms.Alarm[0] := 0;
		StopReasonTextId := 6;
	END_IF


	g_MainAlarms.Alarm[18] := 0;
	IF RFuseFaultSide AND NOT FuseFault24V THEN
		g_MainAlarms.Alarm[18] := 1;
		g_MainAlarms.Alarm[1] := 0;
		g_MainAlarms.Alarm[0] := 0;
		StopReasonTextId := 15;
	END_IF

	//24V Power Supply Fuse Fault
	g_MainAlarms.Alarm[9] := 0;
	IF g_ModuleFuseFault[0] AND ISEmergencyOk AND ISGuardOk THEN
		g_MainAlarms.Alarm[9] := 1;
		g_MainAlarms.Alarm[1] := 0;
		g_MainAlarms.Alarm[0] := 0;
		StopReasonTextId := 8;
	END_IF

	// Guard open
	g_MainAlarms.Alarm[5] := 0;
	IF NOT ISGuardOk AND ISEmergencyOk AND ISThermoOk 
		OR g_Core.System.Interface.alarms.isSafety1Active OR g_Core.System.Interface.alarms.isSafety2Active OR g_Core.System.Interface.alarms.isSafety3Active OR g_Core.System.Interface.alarms.isSafety4Active OR g_Core.System.Interface.alarms.isSafety5Active OR g_Core.System.Interface.alarms.isSafety6Active THEN
		//g_MainAlarms.Alarm[5] := 1;
		g_MainAlarms.Alarm[16] := 0;
		g_MainAlarms.Alarm[1] := 0;
		g_MainAlarms.Alarm[3] := 0;
		StopReasonTextId := 10;
	END_IF

	// Safety plc error
	g_MainAlarms.Alarm[6] := 0;
	IF g_Core.System.Interface.alarms.isSafetyPlcError THEN
		//g_MainAlarms.Alarm[6] := 1;
		g_MainAlarms.Alarm[5] := 0;
		g_MainAlarms.Alarm[16] := 0;
		g_MainAlarms.Alarm[1] := 0;
		g_MainAlarms.Alarm[3] := 0;
	END_IF

	// Inverter Thermofault #7
	IF g_Inverter.Drive[0].GetState = 23 THEN
		g_StopMachine := 1;
		g_MainAlarms.Alarm[7] := TRUE;
		StopReasonTextId := 13;
	ELSE
		g_MainAlarms.Alarm[7] := FALSE;
	END_IF

	// Inverter Error #8
	//---------------------------------------------------------

	IF EDGEPOS(StopReasonTextId = 0) THEN
		g_SoftStopDone := 1;
	END_IF

	// Reset 'reset'-signal
	g_Machine.ResetAllAlarm := FALSE;

	IF RInit THEN
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 1, 1, 64738, 'procmgr Cyclic init');
	END_IF
	
	IF TestDisableAllMainAlarms OR g_Core.System.Runtime.isSimulation THEN
		FOR i := 0 TO SIZEOF(g_MainAlarms.Alarm) / SIZEOF(g_MainAlarms.Alarm[0]) - 1 DO 
			g_MainAlarms.Alarm[i] := FALSE;
		END_FOR
	END_IF
	
	g_Core.System.Configuration.isRemoteEnabled := (g_HCfg.HangerReading > 0) AND (g_HangerInletProcess.ForcedNoCom < 2);

	RInit := 0;

	//--------------------------------------------------------	
	// Flashing
	rFlashing := g_Core.Services.Alarmhandler.Runtime.blinkPulse;
		
	// Ready to start (State: stopped in our machines), Flashing green
	// Machine is Running, Green, State: Starting, Execute.
	rQHStatusGreen := g_Core.System.Interface.infos.isInOperation;
	
	rQHStatusGreenFlash := g_Core.System.Interface.infos.isReadyToStart;

	// PowerSave, Yellow, State: Suspending, Suspended.
	rQHStatusYellow := g_Core.System.Interface.infos.isInOperationPowerSave;
	
	// Halted/ Manual control, Flashing Yellow (Holding, Hold, eller Mode: Manual/Maintenance)		
	rQHStatusYellowFlash := g_Core.Services.IO.Interface.isHaltPlc; //g_Core.System.Runtime.isPLCHalted;
	
	// Error, Flashing Red
	// If all is ok but we need to reset (State: stopped in our machines), then Red,
	rQHStatusRedFlash := g_JamAlarm;
	rQHStatusRed := (g_Core.Services.Alarmhandler.Runtime.Event[0].Status > 0) AND NOT ISControlPlc;
	
	// Mapping and priority
	QHStatusRed := ((rQHStatusRed AND NOT rQHStatusRedFlash) OR (rQHStatusRedFlash AND rFlashing)) AND NOT rQHStatusYellowFlash;
	QHStatusYellow := (rQHStatusYellow AND NOT rQHStatusYellowFlash AND NOT rQHStatusRed AND NOT rQHStatusRedFlash) OR (rQHStatusYellowFlash AND rFlashing);
	QHStatusGreen := ((rQHStatusGreen AND NOT rQHStatusGreenFlash) OR (rQHStatusGreenFlash AND rFlashing)) AND NOT rQHStatusRedFlash;
	QHStatusBlue := (rQHStatusBlue AND NOT rQHStatusBlueFlash) OR (rQHStatusBlueFlash AND rFlashing);	
END_PROGRAM