(*-------------------------------------------------------------------------------------

Author:   				PO Nilsson	

FileName:				MiniJenwayCyclic.st

Desription:				Mini Jenway after folder

Reference:

Interfaces:				No interfaces.

Watch debugg:			Name of important watch configurations.

History:
10-04-27				V1.01.6	PO Nilsson		Increased the timer to Recheck empty command, from 5 to 15 seconds...
10-02-04				V1.01.5	PO Nilsson		Removed some unused code (Alarm[3])
09-11-19				V1.01.4	PO Nilsson		Found bug when converted to AS 3.0.80, wrong data type was copied into "g_MiniJenwayProcess.Common.Previous"
09-11-18				V1.01.3	PO Nilsson		Removed ISIndexA with the g_HMIMakeIndex.. 	
09-10-27				V1.01.2	PO Nilsson		Removed machine manager index from init part of xb
09-10-01				V1.01.1 PO Nilsson		Bug fixes on site Holbaek
09-08-13				V1.01 	SFX				Now goes back to state 20 at stop attempts to enable stopping the machine.
												Count block time for statistics moved to process manager.
												Created a process alarm in alarm list when Jenway is blocked.
												Can not state 25 be removed and we use only 20?
09-06-03				V1.00 PO Nilsson		First edition...
---------------------------------------------------------------------------------------*)


PROGRAM _CYCLIC

IF NOT g_SystemInitialized THEN
	RETURN;
END_IF	



(*#####################*)
(* Get current time... *)
(*#####################*)
g_MiniJenwayProcess.Common.CurTimer 						:= g_Timers._1_ms;						(* Get current time *)
IF g_MiniJenwayProcess.Common.LogBookFlag > 0 THEN
	strcpy(ADR(TmpStr),ADR(g_MiniJenwayProcess.Common.Description));
END_IF



(*#################################*)
(* copy status of exchange objects *)
(*#################################*)

// At Holbaek we connect directly to the outlet to the MiniJenway...
// Must be copied on the transferstatus level sins unmatching types
g_MiniJenwayProcess.Common.Previous.TransferStatus		:= g_OutletProcess.StackerUnit[1].Next.TransferStatus;		// Per stacker unit 


(*########################################*)
(* Connect inputs to the module structure *)
(*########################################*)

Belt1.Input.Photocell		:= X_MiniPhotocell1;
Belt2.Input.Photocell		:= X_MiniPhotocell2;
IBBeltFullSignal;

(*######################*)
(* Connect timer values *)
(*######################*)

g_MiniJenwayProcess.Common.WatchDogStartupTime			:= 4000;
g_MiniJenwayProcess.Common.WatchDogRunTime				:= 2000;
g_MiniJenwayProcess.Common.InSensor.OnDelay				:= 2;
g_MiniJenwayProcess.Common.InSensor.OffDelay			:= 2;

(* Belt timers *)
Belt1.OffdelayPhotocell.OffDelay    	:= g_MCfg. MJ_PhotocellOffdelay;
Belt2.OffdelayPhotocell.OffDelay    	:= g_MCfg. MJ_PhotocellOffdelay;

Belt1.Timers.MaxRunTime 				:= g_MCfg.MJ_MaxRunTimeB1;			//2500
Belt2.Timers.MaxRunTime 				:= g_MCfg.MJ_MaxRunTimeB2;			//1300	

(* Handle Input signals *)

RunFoldTask(g_MCfg.Trace2File, ADR(T2FD), g_MiniJenwayProcess.Common, g_MachineManager[g_MiniJenwayProcess.Common.MachineManagerIndex]);

CASE g_MiniJenwayProcess.Common.State OF

	(*####################################*)
	(* Start Up Machine, Home Axels etc.. *)
	(*####################################*)

	MACHPROC_STARTUP_1:

		
		g_MiniJenwayProcess.Common.Previous.TransferStatus 	:= EXC_STANDBY_0;
		g_MiniJenwayProcess.Common.WatchDogRunTimer 		:= g_MiniJenwayProcess.Common.CurTimer;					(* start watchdog timer for process *)
		g_MiniJenwayProcess.Common.State 					:= MACHPROC_RUN_20;

		g_MiniJenWayIsBlocked 								:= FALSE;
		Belt1.InitDone 										:= FALSE;
		Belt2.InitDone 										:= FALSE;
		QKEnableBufferBelt 									:= FALSE;
	
	(*###############################################################*)
	(* Machien Stop case, to handle shut down process of the module  *)
	(*###############################################################*)

	MACHPROC_STOP_15:
		;
		(* Reset output and handle the shutdown procedure *)
		(* Extra stop cases may be needed.. *)
		g_MiniJenwayProcess.Common.State 					:= MACHPROC_INIT_0;
		g_MiniJenwayProcess.Common.FoldUnit1.State			:= 0;
		g_MiniJenwayProcess.Common.FoldUnit2.State			:= 0;
		g_MiniJenwayProcess.Common.Motor.cmdStop			:= TRUE;

		QKEnableBufferBelt 									:= FALSE;


	(*#####################*)
	(* Main running state  *)
	(*#####################*)

	MACHPROC_RUN_20:


		IF g_HCfg.SpecialMiniJenWay > 0 THEN
			IF g_MachineManager[g_MiniJenwayProcess.Common.MachineManagerIndex].Run AND (NOT g_Machine.StopAttempt) THEN 
				g_MiniJenwayProcess.Common.State 			:= MACHPROC_MACHINE_IS_RUNNING_25;
				g_MiniJenWayIsBlocked 						:= FALSE;
			END_IF
		END_IF	
				
		QKEnableBufferBelt 								:= FALSE;


	MACHPROC_MACHINE_IS_RUNNING_25:
	
		g_MiniJenwayProcess.Common.WatchDogRunTimer 	:= g_MiniJenwayProcess.Common.CurTimer;					(* start watchdog timer for process *)
	
		QKEnableBufferBelt 								:= NOT X_StopBeltInput;
	
		(* Make handshake with Previous task... *)
		IF g_MiniJenwayProcess.Common.Previous.TransferStatus = EXC_WANT_TO_UNLOAD_1 THEN		(* Prev wants to unload *)
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_MiniJenwayProcess.Common.LogBookFlag, g_DummyPulses, 'MJW, Prev wants to unload');
			IF (Belt1.Output.IsReady AND IBDeliveryBeltEnd) OR NOT IBDeliveryBeltEnd THEN
				g_MiniJenwayProcess.Common.Previous.TransferStatus 	:= EXC_READY_TO_RECIEVE_2;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_MiniJenwayProcess.Common.LogBookFlag, g_DummyPulses, 'MJW, X := 2');
				g_MiniJenWayIsBlocked 	:= FALSE;
			ELSE
				g_MiniJenWayIsBlocked 	:= TRUE;
			END_IF
		ELSIF g_MiniJenwayProcess.Common.Previous.TransferStatus = EXC_UNLOADING_3 THEN	
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_MiniJenwayProcess.Common.LogBookFlag, g_DummyPulses, 'MJW, X := 4');
			g_MiniJenwayProcess.Common.Previous.TransferStatus 	:= EXC_RECIVING_4;
		ELSIF g_MiniJenwayProcess.Common.Previous.TransferStatus = EXC_FINISHED_UNLOADING_5 THEN		
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_MiniJenwayProcess.Common.LogBookFlag, g_DummyPulses, 'MJW, X := 0');
			//g_MiniJenwayProcess.Common.Previous.TransferStatus 	:= EXC_RECIVING_DONE_6;	
			g_MiniJenwayProcess.Common.Previous.TransferStatus 	:= EXC_STANDBY_0;			(* Vilket skall det vara här??? *)
			Belt1.Input.PrevToUnload 							:=	FALSE;
		END_IF		
		
		
		// Start belt in curve 1 when Photocell is covered and delivery belt is running...
		IF IBDeliveryBeltEnd AND g_OutletProcess.StackerUnit[1].Motor.Run THEN
			Belt1.Input.PrevToUnload := TRUE;
		END_IF
		
		
		
		//########################################################################################
		// Start to empty delivery belt if machine has standstill and stack present at photocell..
		//########################################################################################
		
		
		//IF IBDeliveryBeltEnd AND g_HangerInletProcess.InletIsIdle AND Belt1.Output.IsReady AND NOT ReCheckFlag THEN
		IF IBDeliveryBeltEnd AND g_HangerInletProcess.InletIsIdle AND Belt1.Output.IsReady AND NOT ReCheckFlag AND NOT g_OutletProcess.StackerUnit[1].Motor.Run THEN	// POX 10-04-27...
			g_HMIMakeIndex	:= TRUE;
			ReCheckFlag 	:= TRUE;
			ReCheckTimer 	:= g_MiniJenwayProcess.Common.CurTimer;
		END_IF
		
		IF (ElapsedMsTime(g_MiniJenwayProcess.Common.CurTimer, ReCheckTimer) >= 15000) THEN
			ReCheckFlag 	:= FALSE;
		END_IF	
		
		
		
		(*################################*)
		(* First Curved belt after folder *)
		(*################################*)
		
		Belt1.Input.NextIsReady		:= Belt2.Output.IsReady AND NOT X_StopBeltInput;


		(*#################################*)
		(* Second curved belt after folder *)
		(*#################################*)

		Belt2.Input.PrevToUnload := Belt1.Output.WantToUnload;
		Belt2.Input.NextIsReady  := IBBeltFullSignal AND NOT X_StopBeltInput;		(* Signal is inverted POX *)
	
		
		(*################################################*)
		(* Go back to Idle case if nothing is happening?? *)
		(*################################################*)
		
		IF g_Machine.StopAttempt THEN 
		//IF NOT g_MachineManager[g_MiniJenwayProcess.Common.MachineManagerIndex].Run THEN
			g_MiniJenwayProcess.Common.State 		:= MACHPROC_RUN_20;
		END_IF
		

	MACHPROC_ERROR_99:
		;


END_CASE

(*###############################*)
(* Run Belt controller functions *)
(*###############################*)


Belt1.CurTimer := g_Timers._1_ms;		(* Get current time to function... *)
Belt2.CurTimer := g_Timers._1_ms;

// Run function call for Belt controllers
BeltController(Belt1);
BeltController(Belt2);




(*#################*)
(* Connect Outputs *)
(*#################*)



QMCurve[1]	:= Belt1.Output.Motor;
QMCurve[2]	:= Belt2.Output.Motor;



END_PROGRAM


