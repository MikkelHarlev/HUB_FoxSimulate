PROGRAM _CYCLIC
(* cyclic program *)

(*-------------------------------------------------------------------------------------

Author:   				Sten Flystedt.

FileName:				Task(file)name.scr

Desription:				Set init valus TO the processes...

Reference:

Interfaces:				No interfaces.

Watch debugg:			Name OF important watch configurations.

History:
10-01-27				V1.04.5	PO Nilsson			Removed the datatype FOR g_SpeedCountOfWheel AND made simpel UINT... Cleaned up...
10-01-24				V1.04.4	PO Nilsson			Calculate on / off time FOR the measuring wheel AND show on hmi...
09-11-12				V1.04.3	PO Nilsson			NUMBER_OF_STACKERGROUPS is now calculated AND NOT fixed..
09-11-04				V1.04.2	PO Nilsson 			Adjusted after working puls counting...
09-11-03				V1.04.1 PO Nilsson			Removed prototype code AND changed constants some FOR 40-6002..
09-10-27				V1.04.0 PO Nilsson			Multi stacker, calculate index number FOR stacker groups...
09-10-20				V1.03.2 PO Nilsson			Wheel counter changed TO only positiv flanks...

09-09-23				V1.03.1 PO Nilsson			Cleaned up variable names, no FUNCTION change..	

09-04-06				V1.03 PO Nilsson			Adapted TO the FOX

08-02-19				V1.02 Per-Olov Nilsson		New exchange type TO match Manager V1.20.

07-11-12				V1.01 Per-Olov Nilsson		Addapted TO Trolley washer...

00-00-00				V1.00 Sten Flystedt			First edition...

---------------------------------------------------------------------------------------*)
//#########################################################
// Machine manager index 
// Must be set cyclic to work during download of tasks... 
//#########################################################
	NUMBER_OF_MACHINE_PROCESSES := 9 + REAL_TO_UINT((g_HCfg.NumberOfStackers + 1) / 2);;


	//#####################################
	// Calculate number of stacker groups..
	//#####################################

	NUMBER_OF_STACKERGROUPS	:= g_HCfg.NumberOfStackers; // one stacker per group //REAL_TO_UINT((g_HCfg.NumberOfStackers + 1) / 2);			
	NUMBER_OF_STACKERS := g_HCfg.NumberOfStackers; // CBV Required for Cockpit	


	//###################################################################################################
	// This is double also found in the Init part of this task, to make sure a it work when download...
	//###################################################################################################

	//g_HangerInletProcess.Common.MachineManagerIndex				:= 1;
	g_HangerOpenerProcess.Common.MachineManagerIndex 				:= 2;

	//g_ManualInletProcess.Common.MachineManagerIndex				:= 1;
	//g_ManualInfeedProcess.Common.MachineManagerIndex			 	:= 2;

	g_TopConveyorProcess.Common.MachineManagerIndex					:= 3;
	g_LateralProcess.Common.MachineManagerIndex						:= 4;
	g_CrossFoldAProcess.Common.MachineManagerIndex					:= 5;
	g_CrossFoldBProcess.Common.MachineManagerIndex					:= 6;
	// To make a dynamic inedxing number of stacker groups...
	FOR i := 1 TO NUMBER_OF_STACKERGROUPS DO
		g_StackerProcess[i].Common.MachineManagerIndex				:= i + 6;	
	END_FOR	
	g_OutletProcess.Common.MachineManagerIndex						:= g_StackerProcess[NUMBER_OF_STACKERGROUPS].Common.MachineManagerIndex + 1;
	g_DeliveryProcess.Common.MachineManagerIndex					:= g_OutletProcess.Common.MachineManagerIndex + 1;
	g_DeliveryProcess2.Common.MachineManagerIndex					:= g_DeliveryProcess.Common.MachineManagerIndex + 1;
	g_MiniJenwayProcess.Common.MachineManagerIndex					:= g_DeliveryProcess2.Common.MachineManagerIndex + 1;
	IF g_HCfg.FeedManual THEN
		g_ManualInletProcess.Common.MachineManagerIndex				:= 1;
		g_HangerInletProcess.Common.MachineManagerIndex				:= g_MiniJenwayProcess.Common.MachineManagerIndex + 1;
	ELSE
		g_HangerInletProcess.Common.MachineManagerIndex				:= 1;
		g_ManualInletProcess.Common.MachineManagerIndex				:= g_MiniJenwayProcess.Common.MachineManagerIndex + 1;
	END_IF

	//g_RollOffProcess.Common.MachineManagerIndex					:= g_DeliveryProcess.Common.MachineManagerIndex + 1;
	//g_MiniJenwayProcess.Common.MachineManagerIndex				:= g_RollOffProcess.Common.MachineManagerIndex + 1;


	//#######################################################
	// Puls counter input and Counter, used in Top conveyor 
	//#######################################################

	IF ResetCheckCounters THEN
		ResetCheckCounters := FALSE;
		CheckWheelTotalCounter := 0;
	END_IF
	
	
	IF IWhC <> OldWheel THEN
		g_SpeedCountOfWheel := g_SpeedCountOfWheel + 1;
		CheckWheelTotalCounter := CheckWheelTotalCounter + 1;
	END_IF	
	OldWheel := IWhC;

//	g_SpeedCountOfWheel := g_SpeedCountOfWheel + (g_MilliSeconds - OldMilliseconds);
//	OldMilliseconds := g_MilliSeconds;
	
	IF g_SpeedCountOfWheel >= 60000 THEN
		g_SpeedCountOfWheel := 1;
	END_IF

	// Wheel counter for Duo inlet
	IF IWhDuo XOR RCounterWheelDuo THEN
		g_DuoWheelCounter := g_DuoWheelCounter + 1;
	END_IF;
	RCounterWheelDuo := IWhDuo;

	//IF g_Core.Services.Time.Runtime.MilliSeconds > OldMS THEN
	//	OldMS := g_Core.Services.Time.Runtime.MilliSeconds;
	//	g_Timers._1_ms := g_Timers._1_ms + 1;
	//	IF g_Timers._1_ms > 60000 THEN
	// 		g_Timers._1_ms := 0;
	//	END_IF
	//END_IF
	g_Timers._1_ms := UDINT_TO_UINT(g_Core.Services.Time.Runtime.MilliSeconds MOD 60000);
	
	IF g_Core.Services.Time.Runtime.MilliSeconds > (OldSeconds + 999) THEN
		OldSeconds := g_Core.Services.Time.Runtime.MilliSeconds;
		g_Timers._1_sec := g_Timers._1_sec + 1;
		IF g_Timers._1_sec > 60000 THEN
			g_Timers._1_sec := 0;
		END_IF
	END_IF

	g_DummyPulses := UDINT_TO_UINT(LREAL_TO_UDINT(UDINT_TO_DINT(g_Core.Services.Time.Runtime.MilliSeconds) / DummyFactor) MOD 60000);

	//###############################
	// Stacker groups speed factor
	//###############################

	MM_TO_MS_FACTOR				:= g_MCfg.Stacker.BeltSpeedFactor;



	//#####################################
	// Counter wheel to distance constant
	//#####################################

	//WHEEL_INC_TO_DISTANCE_MM 	:= 414;							// 414 mm/100 pulses Tematic
	//WHEEL_INC_TO_DISTANCE_MM 	:= 513;							// 40-6002 with 19 teeht wheel, this is now right 195mm per 19*2 pulses		

	//WHEEL_INC_TO_DISTANCE_MM 	:= 545;							// Nurnberg 10-01-24... We do not miss pulses but need to adjust anyway...
	// This is now really good...				

	// 5ms = 5.13mm  


	//############################
	// Counter wheel test area... 
	//############################


	Cycle := Cycle + 1;
	//IF (g_Timers._1_ms - CycleResetPoint) > 0 THEN
	//	Cycle := g_Timers._1_ms - CycleResetPoint;
	//ELSE
	//

	IF Test = 1 THEN
		StartPointWheel := g_SpeedCountOfWheel;
		StartPointDum	:= g_DummyPulses;
		Test := 2;
		Cycle := 0;
	ELSIF Test = 2 THEN
		IF Cycle >= 1000 THEN
			StopPointWheel 	:= g_SpeedCountOfWheel;
			StopPointDum	:= g_DummyPulses;
			WheelResult 	:= StopPointWheel - StartPointWheel;
			DummyResult 	:= StopPointDum - StartPointDum;
			Test := 3;
		END_IF
	END_IF



	//#########################################
	// Test measure on off time for sensor...
	// This shows on the Service page for TopConveyor / Inlet... 
	//#########################################


	Counter := Counter + 1;

	IF IWhC > Old_TestPulse THEN
		OnCounter 	:= Counter;	
		LastOff		:= Counter - OffCounter;	
		IF LastOff < 2 THEN
			OffError := OffError + 1;
		END_IF	
	ELSIF IWhC < Old_TestPulse THEN
		LastOn		:= Counter - OnCounter;
		OffCounter 	:= Counter; 
		IF LastOn < 2 THEN
			OnError := OnError + 1;
		END_IF
	END_IF

	Old_TestPulse := IWhC;




	(*##############################################*)
	(* Hanger passed for the HangerInlet is to fast *)
	(*##############################################*)

	g_HangerInletProcess.HangerPassedStf.Input := IISupervisionSeperation OR g_sim.IISupervisionSeperation;
	RunIOCounter(g_HangerInletProcess.HangerPassedStf, g_Timers._1_ms);

END_PROGRAM

