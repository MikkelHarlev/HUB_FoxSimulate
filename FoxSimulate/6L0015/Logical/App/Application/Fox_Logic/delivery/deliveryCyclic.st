PROGRAM _CYCLIC
(* cyclic program *)

(*-------------------------------------------------------------------------------------

Author:   				Sten Flystedt

FileName:				Delivery.st

Desription:				Delivery

Reference:

Interfaces:				No interfaces.

Watch debugg:			Name OF important watch configurations.

History:
10-08-17				V2.01.6	WM				Buffer Unit connected TO convoyer (new input AND outout)
10-08-09				V1.04.4	PO Nilsson		Added a option check on QKOutlet..
10-05-25				V1.04.3	PO Nilsson		Got code from Tematic TO handle I/O connection TO Jenway..
10-04-28				V1.04.2	PO Nilsson		Removed the RollOff task, shall NOT be a part OF the Fox...
10-03-23				V1.04.1	PO Nilsson		Only set Motor output when no error in manager. 
												Otherwise the motor could run after E-stop was reseted..
												RunTime FOR motor is now configurable..
09-12-03				V1.04.0	PO Nilsson		Toke the latest version from Sten/Tematic AND implemented into the Fox.
												Changed I/O names TO fit it TO the Fox.
												There is also a ugly fix TO resolve conflict that happens some times...
09-09-16				V1.03.1 Sten Flystedt	Delivery belt start also in accumulation mode.
09-05-11				V1.03.0 Sten Flystedt	CrossBelt photocell is no option (always standard),Delivery FUNCTION MOVE TO new position in struct AND added in the code.
09-04-01				V1.02.2 Sten Flystedt	Rearranged data structure TO enable bugfix FOR wrong stack data.
09-03-26				V1.02.1 Sten Flystedt	Fixed possible startupbug IF crossbelt sensor was covered
09-03-12				V1.02 Sten Flystedt		IF Slave was NOT communicating at start up could it happend that CrossLoadPoint.State was still on 0. This is here fixed so it
												goes TO run mode IF this happends.
08-07-01				V1.01 Sten Flystedt		First edition...
---------------------------------------------------------------------------------------*)

	IF NOT g_SystemInitialized OR (g_HCfg.CrossConveyor = 0) THEN
		RETURN;
	END_IF	


	//IF g_Machine.CurrentMasterSlaveFunction = SLAVE_OUTLET_THIS_IS_SLAVE_2 THEN
	//	RETURN;
	//END_IF

	testme := 1;

	(*#####################*)
	(* Get current time... *)
	(*#####################*)
	g_DeliveryProcess.Common.CurTimer 					:= g_Timers._1_ms;			(* Get current time *)
	IF g_DeliveryProcess.Common.LogBookFlag > 0 THEN
		strcpy(ADR(TmpStr),ADR(g_DeliveryProcess.Common.Description));
	END_IF


	g_DeliveryProcess.Common.Motor.RunTime			:= g_MCfg.Delivery.CrossBeltRunTime;	

	testme := 2;

	(*#################################*)
	(* copy status of exchange objects *)
	(*#################################*)
	g_DeliveryProcess.NumberOfLoadPoints := 1; //special setup ->stacker no.2 is inline //g_HCfg.NumberOfStackers + g_SlaveOutlet.NumberOfStackers;
	IF g_DeliveryProcess.NumberOfLoadPoints > g_DeliveryProcess.MaxNumberOfLoadPoints THEN (* SFX here is needed some better calculation *)
		g_DeliveryProcess.NumberOfLoadPoints := g_DeliveryProcess.MaxNumberOfLoadPoints;
	END_IF

	testme := 3;

	IF g_MCfg.Delivery.CrossBeltOffSet < 1 THEN
		g_MCfg.Delivery.CrossBeltOffSet := 1;
	END_IF

	testme := 4;

	(* Update data from local outlet *)
	FOR i:= 1 TO g_HCfg.NumberOfStackers DO
		g_DeliveryProcess.CrossLoadPoint[i].Exchange := g_OutletProcess.StackerUnit[i].Next;
	END_FOR

	testme := 5;

	(* Update data from slave outlet *)
	IF g_SlaveOutlet.NumberOfStackers > 0 AND g_SlaveOutlet.Updated THEN
		IF g_SlaveOutlet.NumberOfStackers <= (g_DeliveryProcess.MaxNumberOfLoadPoints-g_HCfg.NumberOfStackers) THEN
			FOR i:= 1 TO g_SlaveOutlet.NumberOfStackers DO
				g_DeliveryProcess.CrossLoadPoint[g_HCfg.NumberOfStackers+i].Exchange := g_SlaveOutlet.StackerUnit[i].Exchange;
			END_FOR
		END_IF
		g_SlaveOutlet.Updated := FALSE;
	END_IF

	testme := 6;

	//g_DeliveryProcess.CrossBelt.Length := (g_MCfg.Outlet.CrossBeltLength/100)+3;
	g_DeliveryProcess.CrossBelt.Length := (g_MCfg.Outlet.CrossBeltLength/100+(g_MCfg.Outlet.CrossBeltLength/1000));	// CWH Fix to only run ca. 10% ekstra
	// Check that length does not exed the number of elements in the array...
	HookSize:= (SIZEOF(g_DeliveryProcess.CrossBelt.Hook)/SIZEOF(g_DeliveryProcess.CrossBelt.Hook[0]))-1;
	IF g_DeliveryProcess.CrossBelt.Length > HookSize THEN
		g_DeliveryProcess.CrossBelt.Length := HookSize; 
	END_IF

	testme := 7;

 
	(*########################################*)
	(* Connect inputs to the module structure *)
	(*########################################*)

	g_DeliveryProcess.Common.InSensor.Input 				:= IBDeliveryBeltBegin;
	
	// 2.1.6 -> Buffer Unit is ready when first OH is off
	IF (NOT g_MCfg.Jenway.InvertJenwayReady) THEN 
		g_DeliveryProcess.NextMachineReady						:= ISReadyOutlet OR IBBufferUnitReady;
	ELSE
		g_DeliveryProcess.NextMachineReady						:= (NOT ISReadyOutlet) OR IBBufferUnitReady;
	END_IF
	g_DeliveryProcess.DeliveryBelt.EndSensor.Input 				:= 0; // wrapper machine at end of inline part stacker 2//IBDeliveryBeltEnd;
	//IF g_HCfg.DeliveryExternalCommunication = 4 THEN
	//	g_DeliveryProcess.DeliveryBelt.EndSensor.Input			:= g_DeliveryProcess.NextMachineReady;
	//ELSE
	//	g_DeliveryProcess.DeliveryBelt.EndSensor.Input 			:= IBDeliveryBeltEnd;
	//END_IF	

	(*######################*)
	(* Connect timer values *)
	(*######################*)
	g_DeliveryProcess.Common.WatchDogStartupTime			:= 4000;
	g_DeliveryProcess.Common.WatchDogRunTime				:= 10000;
	g_DeliveryProcess.Common.ExitTime						:= 1200;
	g_DeliveryProcess.DeliveryBelt.ExitTime					:= g_MCfg.Delivery.ExitRunTime;
	g_DeliveryProcess.Common.InSensor.OnDelay				:= g_MCfg.SensorFilterTime;
	g_DeliveryProcess.Common.InSensor.OffDelay				:= g_MCfg.SensorFilterTime;
	g_DeliveryProcess.DeliveryBelt.EndSensor.OnDelay		:= g_MCfg.SensorFilterTime;
	g_DeliveryProcess.DeliveryBelt.EndSensor.OffDelay		:= g_MCfg.SensorFilterTime;
	g_DeliveryProcess.DeliveryBelt.Function 				:= g_MCfg.Delivery.Function; (*:= DELIVERY_FUNCTION_TRANSPORT_1; DELIVERY_FUNCTION_ACCUMULATE_0*)

	RunFoldTask(g_MCfg.Trace2File, ADR(T2FD), g_DeliveryProcess.Common,g_MachineManager[g_DeliveryProcess.Common.MachineManagerIndex]);
	RunIOCounter(g_DeliveryProcess.DeliveryBelt.EndSensor, g_DeliveryProcess.Common.CurTimer);

	(*********************************************)
	(*********************************************)
	(*                                           *)
	(* MAIN RUN OF CONVEYORS BELT + CROSS        *)
	(*                                           *)
	(*********************************************)
	(*********************************************)
	testme := 8;

	CASE g_DeliveryProcess.Common.State OF

		(*####################################*)
		(* Start Up Machine, Home Axels etc.. *)
		(*####################################*)

		MACHPROC_STARTUP_1:
	
			testme := 9;


			(* Run for a while to ensure process is clean *)
			g_DeliveryProcess.Common.WatchDogRunTimer 		:= g_DeliveryProcess.Common.CurTimer;							(* start watchdog timer for process *)
			g_DeliveryProcess.Common.Previous.TransferStatus := EXC_STANDBY_0;
			g_DeliveryProcess.Common.State 					:= MACHPROC_RUN_20;
			FOR i:= 1 TO g_DeliveryProcess.NumberOfLoadPoints DO
				g_DeliveryProcess.CrossLoadPoint[i].Exchange.TransferStatus  	:= EXC_STANDBY_0;
				g_DeliveryProcess.CrossLoadPoint[i].State						:= MACHPROC_RUN_20;
			END_FOR
			g_DeliveryProcess.CrossUnloadPoint.Exchange.TransferStatus  		:= EXC_STANDBY_0;
			g_DeliveryProcess.CrossUnloadPoint.State							:= MACHPROC_RUN_20;
			g_DeliveryProcess.DeliveryUnloadPoint.Exchange.TransferStatus  		:= EXC_STANDBY_0;
			g_DeliveryProcess.DeliveryUnloadPoint.State							:= MACHPROC_RUN_20;
			g_DeliveryProcess.DeliveryLoadPoint.Exchange.TransferStatus  		:= EXC_STANDBY_0;
			g_DeliveryProcess.DeliveryLoadPoint.State							:= MACHPROC_RUN_20;
			g_DeliveryProcess.CrossBelt.cmdStart 						:= 1;
			//		g_DeliveryProcess.DeliveryBelt.cmdStart 					:= 1;  //PWC: This is disabled. Dan Munch. We don't want to empty DeliveryConv at machinestart.
			(*###############################################################*)
			(* Machien Stop case, to handle shut down process of the module  *)
			(*###############################################################*)

		MACHPROC_STOP_15:

			testme := 10;
	
			FOR i:= 1 TO g_DeliveryProcess.NumberOfLoadPoints DO
				g_DeliveryProcess.CrossLoadPoint[i].State					:= MACHPROC_INIT_0;
			END_FOR
			g_DeliveryProcess.CrossUnloadPoint.State						:= MACHPROC_INIT_0;
			g_DeliveryProcess.DeliveryUnloadPoint.State						:= MACHPROC_INIT_0;
			g_DeliveryProcess.DeliveryLoadPoint.State						:= MACHPROC_INIT_0;
			g_DeliveryProcess.Common.State 									:= MACHPROC_INIT_0;
			g_DeliveryProcess.CrossBelt.Hook[0].State				:= 0;
			g_DeliveryProcess.CrossBelt.Hook[0].StackIndex			:= 0;
			g_DeliveryProcess.DeliveryBelt.Hook[0].State			:= 0;
			g_DeliveryProcess.DeliveryBelt.Hook[0].StackIndex		:= 0;

			(*#####################*)
			(* Main running state  *)
			(*#####################*)

			MACHPROC_RUN_20,
		MACHPROC_RUN_21:

			testme := 11;
			g_DeliveryProcess.Common.WatchDogRunTimer := g_DeliveryProcess.Common.CurTimer;

			g_DeliveryProcess.CrossBelt.OkToStart 	:= TRUE;
			g_DeliveryProcess.AllInIdle		 		:= TRUE;
			(* Control Cross conveyor *)
			FOR i:= 1 TO g_DeliveryProcess.NumberOfLoadPoints DO
				(* Some how can a slave be missed to be up running and then will it be corrected here *)
				IF g_DeliveryProcess.CrossLoadPoint[i].State = MACHPROC_INIT_0 THEN
					g_DeliveryProcess.CrossLoadPoint[i].State	:= MACHPROC_RUN_20;
				END_IF
				IF g_DeliveryProcess.CrossLoadPoint[i].Exchange.TransferStatus > EXC_WANT_TO_UNLOAD_1 THEN
					g_DeliveryProcess.CrossBelt.OkToStart := FALSE;
				END_IF
				IF g_DeliveryProcess.CrossLoadPoint[i].State <> MACHPROC_RUN_20 THEN
					g_DeliveryProcess.AllInIdle		 		:= FALSE;
				END_IF
			END_FOR
			IF g_DeliveryProcess.CrossUnloadPoint.State <> MACHPROC_RUN_20 THEN
				g_DeliveryProcess.AllInIdle		 		:= FALSE;
			END_IF
			IF g_DeliveryProcess.DeliveryLoadPoint.State <> MACHPROC_RUN_20 THEN
				g_DeliveryProcess.AllInIdle		 		:= FALSE;
			END_IF
			IF g_DeliveryProcess.DeliveryUnloadPoint.State <> MACHPROC_RUN_20 THEN
				g_DeliveryProcess.AllInIdle		 		:= FALSE;
			END_IF
			IF g_DeliveryProcess.AllInIdle THEN
				g_DeliveryProcess.Common.State := MACHPROC_RUN_20;
			ELSE
				g_DeliveryProcess.Common.State := MACHPROC_RUN_21;
			END_IF

			g_DeliveryProcess.CrossBelt.Hook[0].State := 0;
			g_DeliveryProcess.CrossBelt.Hook[0].StackIndex := 0;

			IF g_DeliveryProcess.CrossUnloadPoint.StopMotor THEN
				g_DeliveryProcess.CrossBelt.OkToStart := FALSE;
				g_DeliveryProcess.CrossBelt.RestartDelay := 100;(* Aprox 1 sec *)
			ELSE
				IF g_DeliveryProcess.CrossBelt.RestartDelay > 0 THEN
					g_DeliveryProcess.CrossBelt.OkToStart 		:= FALSE;
					g_DeliveryProcess.CrossBelt.RestartDelay 	:= g_DeliveryProcess.CrossBelt.RestartDelay - 1;
				END_IF
			END_IF
			IF (g_DeliveryProcess.Common.Motor.State = MOTOR_STATE_RUN_2) AND (NOT g_DeliveryProcess.CrossBelt.OkToStart) THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag, 9999, 'Del, Force stop Cross motor');
				g_DeliveryProcess.Common.Motor.cmdStop					:= TRUE;
			ELSIF (g_DeliveryProcess.Common.Motor.State <> MOTOR_STATE_RUN_2) AND g_DeliveryProcess.CrossBelt.OkToStart THEN
				IF g_DeliveryProcess.CrossBelt.IsLoaded OR g_DeliveryProcess.CrossBelt.cmdStart THEN
					g_DeliveryProcess.Common.Motor.cmdForward			:= TRUE;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag, 9999, 'Del Start Cross motor');
				END_IF
			END_IF
			IF (g_DeliveryProcess.Common.Motor.State = MOTOR_STATE_RUN_2) AND g_DeliveryProcess.CrossBelt.cmdStart THEN
				g_DeliveryProcess.Common.Motor.RunTimer := g_DeliveryProcess.Common.CurTimer;
			END_IF
			g_DeliveryProcess.CrossBelt.cmdStart := 0;

			(* Control Delivery conveyor *)  // 03-04-2018 PWC: Added OkToStart so Delivery Belt is stopped, when stakker is indexing.
			IF g_DeliveryProcess.DeliveryLoadPoint.StopMotor OR g_DeliveryProcess.DeliveryUnloadPoint.StopMotor (*OR NOT g_DeliveryProcess.CrossBelt.OkToStart*) THEN
				IF (g_DeliveryProcess.DeliveryBelt.Motor.State = MOTOR_STATE_RUN_2) THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag, 9999, 'Del, Stop delivery motor');
					g_DeliveryProcess.DeliveryBelt.Motor.cmdStop					:= TRUE;
				END_IF
			ELSE (* Possible to start *)
				IF (g_DeliveryProcess.DeliveryBelt.Motor.State <> MOTOR_STATE_RUN_2) 
					AND (((g_DeliveryProcess.DeliveryBelt.StackCounter > 0) 
					AND (g_MCfg.Delivery.Function <> DELIVERY_FUNCTION_ACCUMULATE_0)) OR g_DeliveryProcess.DeliveryBelt.cmdStart) THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag, 9999, 'Del, Start delivery motor');
					g_DeliveryProcess.DeliveryBelt.Motor.cmdForward					:= TRUE;
				ELSIF (g_DeliveryProcess.DeliveryBelt.Motor.State = MOTOR_STATE_RUN_2) THEN
					(* Retrig timer if start command *)
					IF  g_DeliveryProcess.DeliveryBelt.cmdStart THEN
						g_DeliveryProcess.DeliveryBelt.Motor.RunTimer := g_DeliveryProcess.Common.CurTimer;
					END_IF
				END_IF
			END_IF
			(* Clear belt after time out *)
			IF (g_DeliveryProcess.DeliveryBelt.Motor.State = MOTOR_STATE_RUN_2) THEN
				IF ElapsedMsTime(g_DeliveryProcess.Common.CurTimer, g_DeliveryProcess.DeliveryBelt.Motor.RunTimer) >= (g_DeliveryProcess.DeliveryBelt.Motor.RunTime-100) THEN
					FOR i := 0 TO g_DeliveryProcess.DeliveryBelt.StackCounter DO
						g_DeliveryProcess.DeliveryBelt.Hook[i].State 		:= 0;
						g_DeliveryProcess.DeliveryBelt.Hook[i].StackIndex 	:= 0;
					END_FOR
					g_DeliveryProcess.DeliveryBelt.StackCounter := 0;
				END_IF
			END_IF
			g_DeliveryProcess.DeliveryBelt.cmdStart 				:= 0;

			g_DeliveryProcess.CrossUnloadPoint.StartPosition		:= g_MCfg.Outlet.CrossBeltLength/100;
			g_DeliveryProcess.DeliveryLoadPoint.StartPosition		:= 1;
			FOR i:= 1 TO g_HCfg.NumberOfStackers DO
				g_DeliveryProcess.CrossLoadPoint[i].StartPosition 	:= g_MCfg.Outlet.StartPosition[i]/100+g_MCfg.Delivery.CrossBeltOffSet;
				g_DeliveryProcess.CrossLoadPoint[i].StopPosition 	:= g_MCfg.Outlet.StopPosition[i]/100+g_MCfg.Delivery.CrossBeltOffSet;
			END_FOR
			testme := 12;
		
	END_CASE


	(*********************************************)
	(*********************************************)
	(*                                           *)
	(* LOAD OUTLETSTACKER UNITS  TO CROSS        *)
	(*                                           *)
	(*********************************************)
	(*********************************************)
	FOR i:= 1 TO g_DeliveryProcess.NumberOfLoadPoints DO
	
		testme := 13;

		CASE g_DeliveryProcess.CrossLoadPoint[i].State OF

			MACHPROC_RUN_20:
		
				testme := 14;


				IF g_DeliveryProcess.CrossLoadPoint[i].Exchange.TransferStatus = EXC_WANT_TO_UNLOAD_1 THEN					(* Previous task whants to unload *)
					IF DeliveryPositionIsFree(g_DeliveryProcess.CrossBelt,g_DeliveryProcess.CrossLoadPoint[i].StartPosition,g_DeliveryProcess.CrossLoadPoint[i].StopPosition) = 1 THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag, i, 'Del, Data from outlet');
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag, g_DeliveryProcess.CrossLoadPoint[i].StartPosition, 'Del, Startpos');
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag, g_DeliveryProcess.CrossLoadPoint[i].StopPosition, 'Del, Stoppos');
						(* Pre-fill position with dummy data to avoid crashes *)
						FillDeliveryPosition(g_DeliveryProcess.CrossBelt,
						g_DeliveryProcess.CrossLoadPoint[i].StartPosition,
						g_DeliveryProcess.CrossLoadPoint[i].StopPosition,
						g_DeliveryProcess.MaxStackIndex);
						g_DeliveryProcess.CrossLoadPoint[i].StopMotor					:= TRUE;
						g_DeliveryProcess.CrossLoadPoint[i].Exchange.TransferStatus 	:= EXC_READY_TO_RECIEVE_2;
						g_DeliveryProcess.CrossLoadPoint[i].State						:= MACHPROC_WAIT_FOR_JOB_22;
					END_IF
				END_IF

			MACHPROC_WAIT_FOR_JOB_22:

				(* Previous task is ready to unload*)
				IF g_DeliveryProcess.CrossLoadPoint[i].Exchange.TransferStatus = EXC_UNLOADING_3 THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag, i, 'Del, Stack from outlet');
					g_DeliveryProcess.NextStackIndex 										:= g_DeliveryProcess.NextStackIndex + 1;
					IF g_DeliveryProcess.NextStackIndex >= g_DeliveryProcess.MaxStackIndex THEN
						g_DeliveryProcess.NextStackIndex 									:= 1;
					END_IF
					g_DeliveryProcess.StackData[g_DeliveryProcess.NextStackIndex] 			:= g_DeliveryProcess.CrossLoadPoint[i].Exchange.Stack;
					FillDeliveryPosition(	g_DeliveryProcess.CrossBelt,
					g_DeliveryProcess.CrossLoadPoint[i].StartPosition,
					g_DeliveryProcess.CrossLoadPoint[i].StopPosition,
					g_DeliveryProcess.NextStackIndex);
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag, i, 'Del, CrLo stinx');
					g_DeliveryProcess.CrossLoadPoint[i].Exchange.TransferStatus  			:= EXC_RECIVING_4;
					g_DeliveryProcess.CrossLoadPoint[i].State 								:= MACHPROC_WAIT_LOAD_COMPLETE_24;
				END_IF
				testme := 15;


			MACHPROC_WAIT_LOAD_COMPLETE_24:

				IF g_DeliveryProcess.CrossLoadPoint[i].Exchange.TransferStatus = EXC_FINISHED_UNLOADING_5 THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag, i, 'Del, restart');
					g_DeliveryProcess.CrossLoadPoint[i].Exchange.TransferStatus  	:= EXC_STANDBY_0;
					g_DeliveryProcess.CrossLoadPoint[i].StopMotor					:= FALSE;
					g_DeliveryProcess.CrossLoadPoint[i].State 						:= MACHPROC_RUN_20;
				END_IF

				// Ugly fix 09-11-23...
				IF g_DeliveryProcess.CrossLoadPoint[i].Exchange.TransferStatus = EXC_WANT_TO_UNLOAD_1 THEN
					g_DeliveryProcess.CrossLoadPoint[i].State 						:= MACHPROC_RUN_20;
				END_IF	

				testme := 16;

		END_CASE
	END_FOR


	g_DeliveryProcess.CrossUnloadPoint.Exchange := g_DeliveryProcess.DeliveryLoadPoint.Exchange;
	(*********************************************)
	(*********************************************)
	(*                                           *)
	(* UNLOAD CROSS TO DELIVERY                  *)
	(*                                           *)
	(*********************************************)
	(*********************************************)

	CASE g_DeliveryProcess.CrossUnloadPoint.State OF

		MACHPROC_RUN_20:

			IF (NOT g_HCfg.DeliveryExternalCommunication = 4) THEN
				IF g_HCfg.DeliveryConveyor = 0 THEN (* No Delivery conveyor is used *)
					IF g_DeliveryProcess.Common.InSensor.Output THEN
						g_DeliveryProcess.CrossUnloadPoint.StopMotor				:= TRUE;
					ELSE
						g_DeliveryProcess.CrossUnloadPoint.StopMotor				:= FALSE;
					END_IF
				END_IF
				//		SFX 090916 run as normal even if accumulate
				//		ELSIF g_MCfg.Delivery.Function = 0 THEN (* Delivery conveyor for storage *)
				//			;
			ELSIF g_DeliveryProcess.Common.InSensor.Output THEN
				///////////////////////
				IF g_HCfg.DeliveryExternalCommunication = 4 AND (NOT g_DeliveryProcess.NextMachineReady) THEN
					g_DeliveryProcess.CrossUnloadPoint.StopMotor				:= TRUE;
				ELSE

					i := g_DeliveryProcess.CrossUnloadPoint.StartPosition;(* Cross beltlength *)
					g_DeliveryProcess.CrossBelt.StackIndex := 0;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag, 9999, 'Del,CrULo *_*_*_*_*_* START');
					IF g_DeliveryProcess.CrossLoadPoint[g_HCfg.NumberOfStackers].StopPosition > g_DeliveryProcess.CrossLoadPoint[1].StopPosition THEN
						Endpos := g_DeliveryProcess.CrossLoadPoint[g_HCfg.NumberOfStackers].StopPosition;
					ELSE
						Endpos := g_DeliveryProcess.CrossLoadPoint[1].StopPosition;
					END_IF
					EndPossCorr := (Endpos+(Endpos/10));	// CWH Fix to only run ca. 10% ekstra
					//			IF i < Endpos+3 THEN
					IF i < EndPossCorr THEN	// CWH Fix to only run ca. 10% ekstra
						g_DeliveryProcess.Common.AlarmList.Alarm[DELIVERY_FAIL_CODE_BELTLENGTH_5] 		:= TRUE;
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 0, g_DeliveryProcess.Common.LogBookFlag, 9999, 'Del, CrULo CrossLength incorrect');
						//				i := Endpos+3;
						i := EndPossCorr;				
					ELSE
						g_DeliveryProcess.Common.AlarmList.Alarm[DELIVERY_FAIL_CODE_BELTLENGTH_5] 		:= FALSE;
					END_IF
					WHILE (i>0) AND (i >= Endpos) AND (g_DeliveryProcess.CrossBelt.StackIndex = 0) DO
						IF g_DeliveryProcess.CrossBelt.Hook[i].State = HOOK_STATE_STACK_HEADER_1 THEN
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag, 9999, 'Del, CrULo Hook occupied');
							IF g_DeliveryProcess.StackData[g_DeliveryProcess.CrossBelt.Hook[i].StackIndex].Count > 0 THEN
								LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,g_DeliveryProcess.CrossBelt.Hook[i].StackIndex, 'Del, CrULo Hook occupied index');
								LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,g_DeliveryProcess.StackData[g_DeliveryProcess.CrossBelt.Hook[i].StackIndex].Destination, 'Del,CrULo Header found');
								LogEntry(g_MCfg.Trace2File, ADR(T2FD), 4, g_DeliveryProcess.Common.LogBookFlag,i, 'Del, CrULo Header found');
								LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,g_DeliveryProcess.CrossBelt.Hook[i].StackIndex, 'Del, Index');
								g_DeliveryProcess.CrossBelt.StackIndex := g_DeliveryProcess.CrossBelt.Hook[i].StackIndex;
							ELSE
								(* Dummy stack do not load *)
								LogEntry(g_MCfg.Trace2File, ADR(T2FD), 4, g_DeliveryProcess.Common.LogBookFlag,g_DeliveryProcess.CrossBelt.Hook[i].StackIndex, 'Del, CrULo strange data');
							END_IF
							(* Mark this hook as already picked up *)
							g_DeliveryProcess.CrossBelt.Hook[i].State := HOOK_STATE_STACK_USED_3;
						ELSIF g_DeliveryProcess.CrossBelt.Hook[i].State > HOOK_STATE_EMPTY_0 THEN
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_DeliveryProcess.Common.LogBookFlag,i, 'Del, bulk found at');
						END_IF
						i:=i-1;
					END_WHILE;
					IF g_DeliveryProcess.CrossBelt.StackIndex = 0 THEN
						g_DeliveryProcess.CrossBelt.StackIndex := g_DeliveryProcess.CrossBelt.MissedStackIndex;
						IF g_DeliveryProcess.CrossBelt.StackIndex > 0 THEN
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_DeliveryProcess.Common.LogBookFlag,g_DeliveryProcess.CrossBelt.StackIndex, 'Del, Used Missed stack');
						ELSE
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_DeliveryProcess.Common.LogBookFlag,0, 'Del, No header found');
						END_IF
					END_IF
					Lastfoundstack := g_DeliveryProcess.StackData[g_DeliveryProcess.CrossBelt.StackIndex].CustomerId;
					IF g_DeliveryProcess.CrossUnloadPoint.Exchange.Block THEN
						g_DeliveryProcess.CrossUnloadPoint.StopMotor				:= TRUE;
						g_DeliveryProcess.CrossUnloadPoint.State					:= MACHPROC_WAIT_FOR_DELIVERY_21;
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,9999, 'Del,Cross stop motor1');
					ELSIF g_DeliveryProcess.CrossUnloadPoint.Exchange.TransferStatus = EXC_STANDBY_0 THEN
						g_DeliveryProcess.CrossUnloadPoint.Exchange.TransferStatus 	:= EXC_WANT_TO_UNLOAD_1;
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,9999,'Del, CrUnLd, Del is ready');
						g_DeliveryProcess.CrossUnloadPoint.State					:= MACHPROC_DELIVER_PACKAGE_80;
						g_DeliveryProcess.CrossUnloadPoint.StopMotor				:= FALSE;
						g_DeliveryProcess.CrossBelt.cmdStart := 1;
					ELSE
						g_DeliveryProcess.CrossUnloadPoint.StopMotor				:= TRUE;
						g_DeliveryProcess.CrossUnloadPoint.State					:= MACHPROC_WAIT_FOR_DELIVERY_21;
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,9999,'Del, Cross stop motor1');
					END_IF
					g_DeliveryProcess.CrossBelt.MissedStackIndex := 0;
				END_IF
			ELSE
				(* Try to pick up any stack not detected by photocell *)
				inx := g_DeliveryProcess.CrossUnloadPoint.StartPosition;
				IF g_DeliveryProcess.CrossBelt.Hook[inx].State = HOOK_STATE_STACK_HEADER_1 THEN
					IF g_DeliveryProcess.StackData[g_DeliveryProcess.CrossBelt.Hook[inx].StackIndex].Count > 0 THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_DeliveryProcess.Common.LogBookFlag,g_DeliveryProcess.CrossBelt.Hook[inx].StackIndex, 'Del, Undetectedstack');
						g_DeliveryProcess.CrossBelt.MissedStackIndex 	:= g_DeliveryProcess.CrossBelt.Hook[inx].StackIndex;
						Lastmissedstack 								:= g_DeliveryProcess.StackData[g_DeliveryProcess.CrossBelt.Hook[inx].StackIndex].CustomerId;
					END_IF
				END_IF
				g_DeliveryProcess.CrossUnloadPoint.StopMotor					:= FALSE;
			END_IF
			testme := 18;


		MACHPROC_WAIT_FOR_DELIVERY_21:

			IF g_DeliveryProcess.CrossUnloadPoint.Exchange.Block THEN
				g_DeliveryProcess.CrossUnloadPoint.StopMotor				:= TRUE;
			ELSIF g_DeliveryProcess.CrossUnloadPoint.Exchange.TransferStatus = EXC_STANDBY_0 THEN
				g_DeliveryProcess.CrossUnloadPoint.Exchange.TransferStatus 	:= EXC_WANT_TO_UNLOAD_1;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,0,'Del, CrUnLd, Del is ready');
				g_DeliveryProcess.CrossUnloadPoint.State					:= MACHPROC_DELIVER_PACKAGE_80;
				g_DeliveryProcess.CrossBelt.cmdStart 				:= 1;
				g_DeliveryProcess.CrossUnloadPoint.StopMotor				:= FALSE;

			ELSE
				g_DeliveryProcess.CrossUnloadPoint.StopMotor				:= TRUE;
			END_IF

			testme := 19;

		MACHPROC_DELIVER_PACKAGE_80:

			IF g_DeliveryProcess.CrossUnloadPoint.Exchange.Block THEN
				IF NOT g_DeliveryProcess.CrossUnloadPoint.StopMotor THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,0,'Del, Cross stop motor2');
				END_IF
				g_DeliveryProcess.CrossUnloadPoint.StopMotor				:= TRUE;
			ELSIF g_DeliveryProcess.CrossUnloadPoint.Exchange.TransferStatus = EXC_READY_TO_RECIEVE_2 THEN
				IF g_DeliveryProcess.CrossBelt.StackIndex > 0 THEN
					g_DeliveryProcess.CrossUnloadPoint.Exchange.StackIndex		:= g_DeliveryProcess.CrossBelt.StackIndex;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,g_DeliveryProcess.CrossUnloadPoint.Exchange.StackIndex,'Del, CrULo transfer data');
				ELSE
					g_DeliveryProcess.CrossUnloadPoint.Exchange.StackIndex		:= g_DeliveryProcess.MaxStackIndex;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,g_DeliveryProcess.CrossUnloadPoint.Exchange.StackIndex, 'Del, CrULo transfer trash');
				END_IF
				g_DeliveryProcess.CrossUnloadPoint.Exchange.TransferStatus 	:= EXC_UNLOADING_3;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag, 9999,'Del, CrUnLd, Del reciving');
				g_DeliveryProcess.CrossUnloadPoint.State 						:= MACHPROC_PACKAGE_DELIVERED_81;
				g_DeliveryProcess.CrossBelt.cmdStart 							:= 1;
				g_DeliveryProcess.CrossUnloadPoint.StopMotor					:= FALSE;
			ELSE
				IF NOT g_DeliveryProcess.CrossUnloadPoint.StopMotor THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,9999, 'Del, Cross stop motor2');
				END_IF
				g_DeliveryProcess.CrossUnloadPoint.StopMotor					:= TRUE;
			END_IF
			testme := 20;


		MACHPROC_PACKAGE_DELIVERED_81:

			IF g_DeliveryProcess.CrossUnloadPoint.Exchange.Block THEN
				g_DeliveryProcess.CrossUnloadPoint.StopMotor				:= TRUE;
			ELSIF g_DeliveryProcess.DeliveryLoadPoint.Exchange.Block THEN
				g_DeliveryProcess.CrossUnloadPoint.StopMotor				:= TRUE;
			ELSIF g_DeliveryProcess.CrossUnloadPoint.Exchange.TransferStatus = EXC_RECIVING_4 THEN
				g_DeliveryProcess.CrossBelt.cmdStart 					:= 1;
				g_DeliveryProcess.CrossUnloadPoint.StopMotor					:= FALSE;
				IF (g_DeliveryProcess.Common.InSensor.Output = 0) THEN
					g_DeliveryProcess.CrossUnloadPoint.Exchange.TransferStatus 	:= EXC_FINISHED_UNLOADING_5;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag, 9999, 'Del, CrUnLd, Del done');
					g_DeliveryProcess.CrossUnloadPoint.State 					:= MACHPROC_RUN_20;
				END_IF
			ELSE
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,0,'Del, Cross stop motor3');
				g_DeliveryProcess.CrossUnloadPoint.StopMotor					:= TRUE;
			END_IF

			testme := 21;

	END_CASE



	(*********************************************)
	(*********************************************)
	(*                                           *)
	(* LOAD DELIVERY FROM CROSS                  *)
	(*                                           *)
	(*********************************************)
	(*********************************************)
	g_DeliveryProcess.DeliveryLoadPoint.Exchange := g_DeliveryProcess.CrossUnloadPoint.Exchange;
	CASE g_DeliveryProcess.DeliveryLoadPoint.State OF

		MACHPROC_RUN_20:

			g_DeliveryProcess.DeliveryLoadPoint.StopMotor						:= FALSE;	
			IF g_DeliveryProcess.DeliveryUnloadPoint.StopMotor THEN
				g_DeliveryProcess.DeliveryLoadPoint.Exchange.Block 				:= TRUE;
			ELSIF g_DeliveryProcess.DeliveryLoadPoint.Exchange.TransferStatus = EXC_WANT_TO_UNLOAD_1 THEN					(* Previous task whants to unload *)
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag, 9999,'Del, load ready');
				g_DeliveryProcess.DeliveryBelt.cmdStart 						:= 1;
				g_DeliveryProcess.DeliveryLoadPoint.Exchange.TransferStatus 	:= EXC_READY_TO_RECIEVE_2;
				g_DeliveryProcess.DeliveryLoadPoint.State						:= MACHPROC_WAIT_FOR_JOB_22;
				g_DeliveryProcess.DeliveryLoadPoint.Exchange.Block 				:= FALSE;
			ELSE
				g_DeliveryProcess.DeliveryLoadPoint.Exchange.Block 				:= FALSE;
				g_DeliveryProcess.DeliveryLoadPoint.Exchange.TransferStatus 	:= EXC_STANDBY_0;
			END_IF
			testme := 22;

		MACHPROC_WAIT_FOR_JOB_22:

			IF g_DeliveryProcess.DeliveryUnloadPoint.StopMotor THEN					(* Previous task whants to unload *)
				g_DeliveryProcess.DeliveryLoadPoint.Exchange.Block 	:= TRUE;
			ELSIF g_DeliveryProcess.DeliveryLoadPoint.Exchange.TransferStatus = EXC_UNLOADING_3 THEN
				(* Load Position 0 *)
				g_DeliveryProcess.DeliveryBelt.Hook[0].State 			:= HOOK_STATE_STACK_HEADER_1;
				g_DeliveryProcess.DeliveryBelt.Hook[0].StackIndex 		:= g_DeliveryProcess.CrossUnloadPoint.Exchange.StackIndex;
				g_DeliveryProcess.DeliveryLoadPoint.Exchange.TransferStatus  	:= EXC_RECIVING_4;
				g_DeliveryProcess.DeliveryBelt.cmdStart 				:= 1;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,g_DeliveryProcess.DeliveryLoadPoint.Exchange.StackIndex, 'Del, load recieveing');
				g_DeliveryProcess.DeliveryLoadPoint.Exchange.Block 				:= FALSE;
				g_DeliveryProcess.DeliveryLoadPoint.State 						:= MACHPROC_WAIT_LOAD_COMPLETE_24;
			END_IF
			testme := 23;

		MACHPROC_WAIT_LOAD_COMPLETE_24:

			IF g_DeliveryProcess.DeliveryUnloadPoint.StopMotor THEN
				g_DeliveryProcess.DeliveryLoadPoint.Exchange.Block 				:= TRUE;
			ELSIF g_DeliveryProcess.DeliveryLoadPoint.Exchange.TransferStatus = EXC_FINISHED_UNLOADING_5 THEN
				g_DeliveryProcess.DeliveryBelt.cmdStart 						:= 1;
				IF g_DeliveryProcess.DeliveryBelt.StackCounter < g_DeliveryProcess.DeliveryBelt.Length THEN
					g_DeliveryProcess.DeliveryBelt.StackCounter 				:= g_DeliveryProcess.DeliveryBelt.StackCounter + 1;
				END_IF
				i 																:= g_DeliveryProcess.DeliveryBelt.StackCounter;
				WHILE i >= 1 DO
					g_DeliveryProcess.DeliveryBelt.Hook[i].State 				:= g_DeliveryProcess.DeliveryBelt.Hook[i-1].State;
					g_DeliveryProcess.DeliveryBelt.Hook[i].StackIndex 			:= g_DeliveryProcess.DeliveryBelt.Hook[i-1].StackIndex;
					i															:= i - 1;
				END_WHILE;
				g_DeliveryProcess.DeliveryBelt.Hook[0].State 					:= HOOK_STATE_EMPTY_0;
				g_DeliveryProcess.DeliveryBelt.Hook[0].StackIndex 				:= 0;
				g_DeliveryProcess.DeliveryLoadPoint.State 						:= MACHPROC_WAIT_BEFORE_EXIT_82;
				g_DeliveryProcess.DeliveryLoadPoint.Exchange.Block 				:= FALSE;
				IF g_DeliveryProcess.DeliveryBelt.Function = DELIVERY_FUNCTION_ACCUMULATE_0 THEN
					g_DeliveryProcess.DeliveryBelt.ExitTimer					:= g_DeliveryProcess.Common.CurTimer;
				END_IF
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,g_DeliveryProcess.DeliveryLoadPoint.Exchange.StackIndex,'Del, load complete');
			ELSE
				g_DeliveryProcess.DeliveryBelt.cmdStart 						:= 1;
				g_DeliveryProcess.DeliveryLoadPoint.Exchange.Block 				:= FALSE;
				g_DeliveryProcess.DeliveryLoadPoint.Exchange.TransferStatus  	:= EXC_RECIVING_4;
			END_IF

		MACHPROC_WAIT_BEFORE_EXIT_82:

			testme := 24;

			IF g_DeliveryProcess.DeliveryBelt.Function = DELIVERY_FUNCTION_ACCUMULATE_0 THEN
				IF ElapsedMsTime(g_DeliveryProcess.Common.CurTimer, g_DeliveryProcess.DeliveryBelt.ExitTimer) >= (g_DeliveryProcess.DeliveryBelt.ExitTime) THEN
					g_DeliveryProcess.DeliveryLoadPoint.StopMotor					:= TRUE;	// High during one cycle then low again.
				END_IF
				IF ElapsedMsTime(g_DeliveryProcess.Common.CurTimer, g_DeliveryProcess.DeliveryBelt.ExitTimer) >= (g_DeliveryProcess.DeliveryBelt.ExitTime+100) THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,g_DeliveryProcess.DeliveryLoadPoint.Exchange.StackIndex, 'Del, Acc separate ok');
					g_DeliveryProcess.DeliveryLoadPoint.State 						:= MACHPROC_RUN_20;
					g_DeliveryProcess.DeliveryLoadPoint.Exchange.TransferStatus 	:= EXC_STANDBY_0;
				END_IF
			ELSE
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,g_DeliveryProcess.DeliveryLoadPoint.Exchange.StackIndex,'Del,Load exit ok');
				g_DeliveryProcess.DeliveryLoadPoint.State 							:= MACHPROC_RUN_20;
				g_DeliveryProcess.DeliveryLoadPoint.Exchange.TransferStatus 		:= EXC_STANDBY_0;
			END_IF
	END_CASE


	(*********************************************)
	(*********************************************)
	(*                                           *)
	(* UNLOAD DELIVERY TO SENDOUT                *)
	(*                                           *)
	(*********************************************)
	(*********************************************)

	// Important this must be connected some where if Jenway is after a delivery belt...
	// g_DeliveryProcess.DeliveryUnloadPoint.Exchange  := g_RollOffProcess.Previous ;  // What shall this be connected to? POX 10-04-28



	CASE g_DeliveryProcess.DeliveryUnloadPoint.State OF

		MACHPROC_RUN_20:

			testme := 25;
			g_DeliveryProcess.DeliveryIsInProgress									:= FALSE;
			IF g_HCfg.DeliveryExternalCommunication = EXTCOM_NO_JENWAY_0 THEN (* No RollOff or Jenway *)
				g_DeliveryProcess.DeliveryUnloadPoint.StopMotor						:= FALSE;
			ELSIF g_HCfg.DeliveryExternalCommunication = EXTCOM_TEMATIC_HAS_ROLLOFF_1 THEN (* RollOff controlled by Tematic *)
				IF g_DeliveryProcess.DeliveryBelt.EndSensor.Output THEN (* Stack in position to go to RollOff *)
					IF (g_DeliveryProcess.DeliveryUnloadPoint.Exchange.TransferStatus = EXC_STANDBY_0) AND (NOT g_DeliveryProcess.DeliveryUnloadPoint.Exchange.Block) THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,0,'Del, Unl req rolloff');
						g_DeliveryProcess.DeliveryUnloadPoint.Exchange.TransferStatus 		:= EXC_WANT_TO_UNLOAD_1;
						g_DeliveryProcess.DeliveryUnloadPoint.State 						:= MACHPROC_DELIVER_PACKAGE_80;
					ELSE
						IF NOT g_DeliveryProcess.DeliveryUnloadPoint.StopMotor THEN
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,0,'Del, Unl, rolloff not ready');
						END_IF
						g_DeliveryProcess.DeliveryUnloadPoint.StopMotor						:= TRUE;
					END_IF
				ELSE
					g_DeliveryProcess.DeliveryUnloadPoint.StopMotor							:= FALSE;
				END_IF
			ELSIF g_HCfg.DeliveryExternalCommunication = EXTCOM_JENWAY_HAS_ROLLOFF_2 THEN (* RollOff controlled by Jenway *)
				IF g_DeliveryProcess.DeliveryUnloadPoint.Exchange.TransferStatus = EXC_RECIVING_DONE_6 THEN
					g_DeliveryProcess.DeliveryUnloadPoint.Exchange.TransferStatus  := EXC_STANDBY_0;
				END_IF	
				IF g_DeliveryProcess.DeliveryBelt.EndSensor.Output THEN (* Stack in position to go to RollOff *)
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 5, g_DeliveryProcess.Common.LogBookFlag,0, 'Del, Package ready to JenWayRollOff');
					g_DeliveryProcess.DeliveryUnloadPoint.Exchange.TransferStatus			:= EXC_WANT_TO_UNLOAD_1;
					IF g_DeliveryProcess.DeliveryBelt.StackCounter = 0 THEN (* No known data found *)
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_DeliveryProcess.Common.LogBookFlag, 9999, 'Del, Unl, ok to sendout but shitdata');
						g_DeliveryProcess.DeliveryUnloadPoint.Exchange.Stack		:= g_DeliveryProcess.StackData[g_DeliveryProcess.MaxStackIndex];
					ELSE
						g_DeliveryProcess.DeliveryUnloadPoint.Exchange.Stack		:= g_DeliveryProcess.StackData[g_DeliveryProcess.DeliveryBelt.Hook[g_DeliveryProcess.DeliveryBelt.StackCounter].StackIndex];
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,g_DeliveryProcess.DeliveryBelt.Hook[g_DeliveryProcess.DeliveryBelt.StackCounter].StackIndex, 'Del, Unl, ok to sendout data ok');
					END_IF
					g_DeliveryProcess.DeliveryUnloadPoint.State 							:= MACHPROC_DELIVER_JENWAY_70;
				ELSE
					g_DeliveryProcess.DeliveryUnloadPoint.StopMotor							:= FALSE;
				END_IF
			
			ELSIF g_HCfg.DeliveryExternalCommunication = EXTCOM_RELEASE_IO_3 THEN (* Use IO signals to release indeing *)
			
				IF g_DeliveryProcess.DeliveryBelt.EndSensor.Output THEN (* Stack in position to go to RollOff *)
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 5, g_DeliveryProcess.Common.LogBookFlag,0, 'Del, Package ready to next machine');
					IF g_DeliveryProcess.DeliveryBelt.StackCounter = 0 THEN (* No known data found *)
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_DeliveryProcess.Common.LogBookFlag, 9999, 'Del, Unl, ok to sendout but shitdata');
						g_DeliveryProcess.DeliveryUnloadPoint.Exchange.Stack		:= g_DeliveryProcess.StackData[g_DeliveryProcess.MaxStackIndex];
					ELSE
						g_DeliveryProcess.DeliveryUnloadPoint.Exchange.Stack		:= g_DeliveryProcess.StackData[g_DeliveryProcess.DeliveryBelt.Hook[g_DeliveryProcess.DeliveryBelt.StackCounter].StackIndex];
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,g_DeliveryProcess.DeliveryBelt.Hook[g_DeliveryProcess.DeliveryBelt.StackCounter].StackIndex, 'Del, Unl, ok to sendout data ok');
					END_IF
					g_DeliveryProcess.DeliveryUnloadPoint.State 							:= MACHPROC_DELIVER_EXTIO_WAIT_60;
				ELSE
					g_DeliveryProcess.DeliveryUnloadPoint.StopMotor							:= FALSE;
				END_IF
			END_IF


		MACHPROC_DELIVER_EXTIO_WAIT_60:

			testme := 26;
			
			IF g_DeliveryProcess.NextMachineReady THEN
				
				
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 5, g_DeliveryProcess.Common.LogBookFlag,0, 'Del, Ext machine can recieve');
				g_DeliveryProcess.DeliveryIsInProgress								:= TRUE;
				g_DeliveryProcess.DeliveryUnloadPoint.State 						:= MACHPROC_DELIVER_TRANSPORT_61;
				g_DeliveryProcess.DeliveryBelt.cmdStart 							:= TRUE;
				g_DeliveryProcess.DeliveryUnloadPoint.StopMotor						:= FALSE;
				g_JenWayIsBlocked	:= FALSE;
			ELSIF g_DeliveryProcess.DeliveryBelt.EndSensor.Output = 0 THEN 				(* Stack was removed, exit out *)
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 5, g_DeliveryProcess.Common.LogBookFlag,0, 'Del, Stack removed');
				g_DeliveryProcess.DeliveryBelt.ExitTimer							:= g_DeliveryProcess.Common.CurTimer;
				g_DeliveryProcess.DeliveryUnloadPoint.State 						:= MACHPROC_EXIT_JENWAY_72;
				g_JenWayIsBlocked	:= FALSE;
			ELSE
				g_DeliveryProcess.DeliveryUnloadPoint.StopMotor						:= TRUE;
				g_JenWayIsBlocked	:= TRUE;
			END_IF

		MACHPROC_DELIVER_TRANSPORT_61:
	
			testme := 27;

		
			IF g_DeliveryProcess.DeliveryBelt.EndSensor.Output = 0 THEN 			(* Stack has left sensor area *)
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 5, g_DeliveryProcess.Common.LogBookFlag,0, 'Del, Stack left sensor');
				g_DeliveryProcess.DeliveryBelt.ExitTimer							:= g_DeliveryProcess.Common.CurTimer;
				g_DeliveryProcess.DeliveryUnloadPoint.State 						:= MACHPROC_EXIT_JENWAY_72;
			END_IF

		MACHPROC_DELIVER_JENWAY_70:
	
			testme := 28;


			IF g_DeliveryProcess.DeliveryUnloadPoint.Exchange.TransferStatus = EXC_RECIVING_4 THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 5, g_DeliveryProcess.Common.LogBookFlag,0, 'Del, JenWayRollOff can recieve');
				g_DeliveryProcess.DeliveryUnloadPoint.State 						:= MACHPROC_SENDTO_JENWAY_71;
				g_DeliveryProcess.DeliveryBelt.cmdStart 							:= 1;
				g_DeliveryProcess.DeliveryUnloadPoint.StopMotor						:= FALSE;
			ELSIF g_DeliveryProcess.DeliveryBelt.EndSensor.Output = 0 THEN 				(* Stack was removed, exit out *)
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 5, g_DeliveryProcess.Common.LogBookFlag,0, 'Del, Stack removed');
				g_DeliveryProcess.DeliveryBelt.ExitTimer							:= g_DeliveryProcess.Common.CurTimer;
				g_DeliveryProcess.DeliveryUnloadPoint.State 						:= MACHPROC_EXIT_JENWAY_72;
			ELSE
				g_DeliveryProcess.DeliveryUnloadPoint.StopMotor						:= TRUE;
			END_IF

		MACHPROC_SENDTO_JENWAY_71:
			testme := 29;

		
			IF g_DeliveryProcess.DeliveryBelt.EndSensor.Output = 0 THEN 			(* Stack has left sensor area *)
				g_DeliveryProcess.DeliveryUnloadPoint.Exchange.TransferStatus		:= EXC_FINISHED_UNLOADING_5;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 5, g_DeliveryProcess.Common.LogBookFlag,0, 'Del, Stack left sensor');
				g_DeliveryProcess.DeliveryBelt.ExitTimer								:= g_DeliveryProcess.Common.CurTimer;
				g_DeliveryProcess.DeliveryUnloadPoint.State 							:= MACHPROC_EXIT_JENWAY_72;
			END_IF

		MACHPROC_EXIT_JENWAY_72:

			testme := 30;

			IF ElapsedMsTime(g_DeliveryProcess.Common.CurTimer, g_DeliveryProcess.DeliveryBelt.ExitTimer) >= g_DeliveryProcess.DeliveryBelt.ExitTime THEN
				g_DeliveryProcess.DeliveryUnloadPoint.Exchange.TransferStatus			:= EXC_FINISHED_UNLOADING_5;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 5, g_DeliveryProcess.Common.LogBookFlag,g_DeliveryProcess.DeliveryBelt.ExitTime, 'Del, Pack delivered to JenWayRollOff');
				g_DeliveryProcess.DeliveryUnloadPoint.State 							:= MACHPROC_RUN_20;
			END_IF

		MACHPROC_DELIVER_PACKAGE_80:

			testme := 31;

			IF g_DeliveryProcess.DeliveryUnloadPoint.Exchange.Block THEN
				g_DeliveryProcess.DeliveryUnloadPoint.StopMotor						:= TRUE;
			ELSIF (g_DeliveryProcess.DeliveryUnloadPoint.Exchange.TransferStatus = EXC_STANDBY_0) THEN
				(* SFX This extra check was put in to unlock a lock situation at BasseMuese, Ok or what was the real reason *)
				g_DeliveryProcess.DeliveryUnloadPoint.Exchange.TransferStatus 		:= EXC_WANT_TO_UNLOAD_1;
			ELSIF (g_DeliveryProcess.DeliveryUnloadPoint.Exchange.TransferStatus = EXC_READY_TO_RECIEVE_2) THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,0, 'Del, Unl, rolloff is ready');
				IF g_DeliveryProcess.DeliveryBelt.StackCounter = 0 THEN (* No known data found *)
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_DeliveryProcess.Common.LogBookFlag, 9999, 'Del, Unl, ok to sendout but shitdata');
					g_DeliveryProcess.DeliveryUnloadPoint.Exchange.Stack		:= g_DeliveryProcess.StackData[g_DeliveryProcess.MaxStackIndex];
				ELSE
					g_DeliveryProcess.DeliveryUnloadPoint.Exchange.Stack		:= g_DeliveryProcess.StackData[g_DeliveryProcess.DeliveryBelt.Hook[g_DeliveryProcess.DeliveryBelt.StackCounter].StackIndex];
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,g_DeliveryProcess.DeliveryBelt.Hook[g_DeliveryProcess.DeliveryBelt.StackCounter].StackIndex, 'Del, Unl, ok to sendout data ok');
				END_IF
				g_DeliveryProcess.DeliveryBelt.cmdStart 						:= 1;
				g_DeliveryProcess.DeliveryUnloadPoint.StopMotor					:= FALSE;
				g_DeliveryProcess.DeliveryUnloadPoint.Exchange.TransferStatus 	:= EXC_UNLOADING_3;
				g_DeliveryProcess.DeliveryUnloadPoint.State 					:= MACHPROC_PACKAGE_DELIVERED_81;
			ELSE
				g_DeliveryProcess.DeliveryUnloadPoint.StopMotor					:= FALSE;
			END_IF

		MACHPROC_PACKAGE_DELIVERED_81:

			testme := 32;
	
			IF g_DeliveryProcess.DeliveryUnloadPoint.Exchange.Block THEN
				g_DeliveryProcess.DeliveryUnloadPoint.StopMotor					:= TRUE;
			ELSIF g_DeliveryProcess.DeliveryUnloadPoint.Exchange.TransferStatus = EXC_RECIVING_4 THEN
				g_DeliveryProcess.DeliveryBelt.cmdStart 						:= 1;
				g_DeliveryProcess.DeliveryUnloadPoint.StopMotor					:= FALSE;
				IF g_DeliveryProcess.DeliveryBelt.EndSensor.Output = 0 THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag, 9999, 'Del, DelUnl, photo cell free');
					g_DeliveryProcess.DeliveryBelt.ExitTimer					:= g_DeliveryProcess.Common.CurTimer;
					g_DeliveryProcess.DeliveryBelt.ExitRecalcTime				:= 0;
					g_DeliveryProcess.DeliveryUnloadPoint.State 				:= MACHPROC_WAIT_BEFORE_EXIT_82;
				END_IF
			ELSIF g_DeliveryProcess.DeliveryUnloadPoint.Exchange.TransferStatus = EXC_UNLOADING_3 THEN
				g_DeliveryProcess.DeliveryUnloadPoint.StopMotor					:= FALSE;
			ELSIF g_DeliveryProcess.DeliveryUnloadPoint.Exchange.TransferStatus = EXC_STANDBY_0 THEN
				(* RollOff was rest, go back *)
				g_DeliveryProcess.DeliveryUnloadPoint.State 					:= MACHPROC_RUN_20;
			ELSE
				g_DeliveryProcess.DeliveryUnloadPoint.StopMotor					:= TRUE;
			END_IF

		MACHPROC_WAIT_BEFORE_EXIT_82:

			testme := 33;

			IF g_DeliveryProcess.DeliveryUnloadPoint.Exchange.Block THEN
				(* to keep already run time when rolloff block comes. Must be substracted from total exit time when rolloff is free again *)
				IF g_DeliveryProcess.DeliveryBelt.ExitRecalcTime = 0 THEN
					g_DeliveryProcess.DeliveryBelt.ExitRecalcTime := ElapsedMsTime(g_DeliveryProcess.Common.CurTimer, g_DeliveryProcess.DeliveryBelt.ExitTimer);
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag,g_DeliveryProcess.DeliveryBelt.ExitRecalcTime, 'Del, DelUnl, recalc exit time');
				END_IF
				g_DeliveryProcess.DeliveryBelt.ExitTimer						:= g_DeliveryProcess.Common.CurTimer;
				g_DeliveryProcess.DeliveryUnloadPoint.StopMotor					:= TRUE;
			ELSIF ElapsedMsTime(g_DeliveryProcess.Common.CurTimer, g_DeliveryProcess.DeliveryBelt.ExitTimer) >= (g_DeliveryProcess.DeliveryBelt.ExitTime-g_DeliveryProcess.DeliveryBelt.ExitRecalcTime) THEN
				IF g_DeliveryProcess.DeliveryBelt.StackCounter > 0 THEN
					g_DeliveryProcess.DeliveryBelt.Hook[g_DeliveryProcess.DeliveryBelt.StackCounter].State 			:= HOOK_STATE_EMPTY_0;
					g_DeliveryProcess.DeliveryBelt.Hook[g_DeliveryProcess.DeliveryBelt.StackCounter].StackIndex 	:= 0;
					g_DeliveryProcess.DeliveryBelt.StackCounter 													:= g_DeliveryProcess.DeliveryBelt.StackCounter - 1;
				END_IF
				g_DeliveryProcess.DeliveryUnloadPoint.StopMotor							:= FALSE;
				g_DeliveryProcess.DeliveryUnloadPoint.Exchange.TransferStatus 			:= EXC_FINISHED_UNLOADING_5;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_DeliveryProcess.Common.LogBookFlag, 9999, 'Del, DelUnl, complete');
				g_DeliveryProcess.DeliveryUnloadPoint.State 							:= MACHPROC_RUN_20;
			ELSE
				g_DeliveryProcess.DeliveryUnloadPoint.StopMotor							:= FALSE;
				g_DeliveryProcess.DeliveryBelt.cmdStart 								:= 1;
			END_IF

	END_CASE
 
	//#######################################

	IF (g_HCfg.DeliveryExternalCommunication = 4) AND (NOT g_DeliveryProcess.NextMachineReady) THEN
		;
		//	g_HangerInletProcess.EnableFeeding	:= 0;
	ELSE
		IF EDGEPOS(g_DeliveryProcess.NextMachineReady) THEN
			//		g_HangerInletProcess.EnableFeeding					:= 1;  
			;
		END_IF
   			
		IF g_HCfg.DeliveryConveyor = 0 THEN
			g_DeliveryProcess.DeliveryUnloadPoint.StopMotor := FALSE;
			// 		g_DeliveryProcess.CrossUnloadPoint.Exchange.Block := FALSE;
		END_IF		
	END_IF



	RunFoldMotor(g_MCfg.Trace2File, ADR(T2FD), g_DeliveryProcess.DeliveryBelt.Motor, g_DeliveryProcess.Common.CurTimer, g_OutletProcess.Common.LogBookFlag);
	RunDeliveryBelt(g_DeliveryProcess.CrossBelt,g_DeliveryProcess.Common.Motor);

	//PWC: New Button on Main Screen. Run DeliveryConveyor for the time given in ExitTime*4 (*4 to get it about right)
	IF g_HMI_MacConfig.DeleteDataRuntime = 0 THEN
		HMIHideDelivBelt := 1;
	ELSE
		HMIHideDelivBelt := (g_HCfg.CrossConveyor = 0);
	END_IF

	RRunDelivBelt := (EDGEPOS(HMIRunDeliv = 1) AND NOT QMDeliveryConveyor AND NOT QMCrossConveyor);
	IF HMIRunDeliv > 0 THEN
		HMIRunDeliv := 0;
	END_IF

	RStartDelMotor(IN := EDGEPOS(RRunDelivBelt), PT := UINT_TO_TIME(g_DeliveryProcess.DeliveryBelt.ExitTime*4));


	IF NOT RStartDelMotor.Q AND IBDeliveryBeltBegin AND QMCrossConveyor AND NOT IBDeliveryBeltEnd THEN
		RStartDelMotor(IN :=  EDGEPOS(RRunDelivBelt), PT := UINT_TO_TIME(g_DeliveryProcess.DeliveryBelt.ExitTime*3));
	END_IF

	QMDeliveryConveyor			:= (g_DeliveryProcess.DeliveryBelt.Motor.Run OR RStartDelMotor.Q) AND g_MachineManager[g_DeliveryProcess.Common.MachineManagerIndex].Run;		// To not run motor after E-stop has been pressed
	QMCrossConveyor				:= g_DeliveryProcess.Common.Motor.Run AND g_MachineManager[g_DeliveryProcess.Common.MachineManagerIndex].Run;			// To not run motor after E-stop has been pressed

	IF g_HCfg.CrossConveyor > 0 THEN
		QKOutlet			:= g_DeliveryProcess.DeliveryIsInProgress;
	END_IF	

	// CWH Fix to reset Beltlength error
	IF g_Machine.ResetAllAlarm THEN
		g_DeliveryProcess.Common.AlarmList.Alarm[DELIVERY_FAIL_CODE_BELTLENGTH_5] 		:= FALSE;
	END_IF;

	IF RInit THEN
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 1, 1, 64738, 'Outlet Cyclic init');
	END_IF

	RInit := 0;

END_PROGRAM

