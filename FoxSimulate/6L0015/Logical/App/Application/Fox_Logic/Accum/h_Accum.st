(********************************************************************
 * COPYRIGHT -- IT
 ********************************************************************
 * Program: Accum
 * File: h_Accum.st
 * Author: mariw
 * Created: June 06, 2011
 ********************************************************************
 * Implementation of program Accum
 ********************************************************************) 
ACTION h_AccumInit :
	OldMetric.Step := 0;
END_ACTION



(*Add a new action to your IEC program or library*)
ACTION h_Accum: 



(* Machine is running, make real process??? *)
IF g_HangerInletProcess.Common.State >= MACHPROC_RUN_20 THEN
	
	// Input	
	AccumStop.Input			:= IIPrestopIn OR g_sim.IIPrestopIn;
			

	// Timers
	AccumStop.OnDelay		:= g_MCfg.Accum.FullSensorOnTime;		//50
	AccumStop.OffDelay		:= g_MCfg.Accum.FullSensorOffTime;		//200	
	AccumStop.PulseOnTime	:= g_MCfg.Accum.FullSensorOnPulse;		//200
	AccumStop.PulseOffTime	:= g_MCfg.Accum.FullSensorOffPulse;		//200
	
	// Output	
	QYPreStop				:= AccumStop.Pulse;
	
	// Send the Full signal back to Metricon...
	g_ExternalCom.InletActive 	:= TRUE;					//0 = No hanger wanted, 1 = Hangers wanted. Start SXA...
	g_ExternalCom.InletFull		:= AccumStop.Input; 		//0=Inlet free, 1= Full no more hangers...
	

//	IF g_MCfg.Deloading.InvertOutletFree THEN				//0 = Needs signal to run, 1 = needs signal to stop...
//		IF (NOT ISHangerOutletFree) THEN
//			Q_MachinIsRunning_CNC			:= TRUE;				
//		ELSE
//			Q_MachinIsRunning_CNC			:= FALSE;						
//		END_IF
//	ELSIF (NOT g_MCfg.Deloading.InvertOutletFree) THEN
//		IF ISHangerOutletFree THEN
//			Q_MachinIsRunning_CNC			:= TRUE;					// Used for Nurnberg to indicate
//		ELSE
//			Q_MachinIsRunning_CNC			:= FALSE;					// Used for Nurnberg to indicate		
//		END_IF
//	END_IF	
		
	(*Time Delay due to missing Hanger Feed  *)
	NoExternalHangerFeed;		
ELSE		
	// Clear outputs	
	QYPreStop			:= FALSE;
	
	// Send the Full signal back to Metricon...
	g_ExternalCom.InletActive 	:= 0;		//0 = No hanger wanted, 1 = Hangers wanted. Start SXA...
	g_ExternalCom.InletFull		:= 1; 		//0=Inlet free, 1= Full no more hangers...
		
	g_ExternalCom.ExternalFeed.TimeCountActive:= FALSE;
END_IF

FullReg(AccumStop);

(* Stop Hanger-System if PreStop or Outlet is full or Machine isn't running *)
BlockSystem.Input				:= X_PreStopFull_PH;

// Timers
BlockSystem.OnDelay				:= g_MCfg.Accum.FullSensorOnTime;		//50
BlockSystem.OffDelay			:= g_MCfg.Accum.FullSensorOffTime;		//200
RunIOCounter(BlockSystem, g_HangerOpenerProcess.Common.CurTimer);

(********************************************************************* 
	This Implementation manages the Feeding of items 
	comming from an old metricon system which was modified for Fox.
*********************************************************************)
IF g_HCfg.FeedFromOldMetricon >= 1 THEN
	OldMetricon;
END_IF
	
END_ACTION


ACTION OldMetricon: 
	// Read Inputs
	IF NOT OldMetric.sim  THEN
		OldMetric.Prox_Near := X_OM_ProxNear_PH;
		OldMetric.Prox_Far := X_OM_ProxFar_PH;
	END_IF

	// Time out to wait for Hanger	
	OldMetric.JamTimeOut := g_MCfg.Accum.ProxFarNearTimeout;
	OldMetric.FSTimeOut := g_MCfg.Accum.STFRestartTimeDelay;
	OldMetric.PreStoperTime := g_MCfg.Accum.PreStoperDelay;
	
	// detect state change 
	OldMetric.ProxFarToOn := 0;
	IF OldMetric.Prox_Far AND NOT OldMetric.ProxFarLastState THEN
		OldMetric.ProxFarToOn := TRUE;
	END_IF
	IF OldMetric.Prox_Near AND NOT OldMetric.ProxNearLastState THEN
		OldMetric.ProxNearToOn := TRUE;
	END_IF
	
	// Force step 20 at new start 
	IF g_HangerInletProcess.EnableFeeding AND NOT OldMetric.StateOld THEN
		OldMetric.Step:= 20; // Wait for FullSensor ro be OFF
	END_IF
	

	CASE OldMetric.Step OF
	
		0 : // init
		;
		20 : // Wait for FullSensor ro be OFF
			IF NOT IIPrestopIn THEN
				OldMetric.Step:= 30; // Set Vorstopp			
			END_IF
		30 : // Set Vorstopp
			OldMetric.Prox_PreStopper:= TRUE; 	
			OldMetric.Step:= 40; // Set Vorstopp
			OldMetric.ProxNearToOn:= TRUE;
			OldMetric.FSTimer:=0;			
		40 : 
		
		// Run App
			// The close Prox to mashine detected a Hanger	
			IF OldMetric.ProxNearToOn  THEN		
				OldMetric.Timer:= 0;	
				OldMetric.startTimer:= FALSE;		
				OldMetric.Prox_PreStopper:= TRUE;	
		
				//Hanger passed throw the far Prox
				IF OldMetric.ProxFarToOn THEN
					// close the stopper
					OldMetric.Prox_PreStopper:= FALSE; 
					OldMetric.ProxNearToOn:= 0;
					OldMetric.ProxFarToOn :=0;
					// start Timer
					OldMetric.startTimer:= TRUE;				
				END_IF
			END_IF

			// start Timer
			IF OldMetric.startTimer THEN
				IF OldMetric.Timer > OldMetric.JamTimeOut THEN
					// Alarm
					g_HangerInletProcess.Common.AlarmList.Alarm[8]:= TRUE; 
					OldMetric.startTimer:=0;
					OldMetric.Step:=99;  // step for Alarm 
				ELSE
					OldMetric.Timer:= OldMetric.Timer+1;					
				END_IF
			END_IF
			IF OldMetric.Prox_Far AND OldMetric.Prox_PreStopper THEN
				OldMetric.Prox_PreStopper:= FALSE;
			END_IF
	
		// Wait for long FullSensor = OFF to stop running
			IF IIPrestopIn THEN
				OldMetric.FSTimer:= OldMetric.FSTimer+1; 
			ELSE
				OldMetric.FSTimer:=0;
			END_IF
		
			IF OldMetric.FSTimer > OldMetric.FSTimeOut THEN
				OldMetric.Step:=50;  //Set Vorstopp to OFF 
			END_IF
					
		50 : //Set Vorstopp to OFF
			OldMetric.Prox_PreStopper:= FALSE; 
			OldMetric.Step:=20;  //Set Vorstopp to OFF 
		99 : //Alarm 
			IF g_Machine.ResetAllAlarm THEN
				g_HangerInletProcess.Common.AlarmList.Alarm[8]:= FALSE; 
				g_HangerInletProcess.Common.AlarmList.Ack[8]:=0;			
				OldMetric.Step:= 20; //// Wait for FullSensor ro be OFF
			END_IF
	

	END_CASE;

	// save last states
	OldMetric.ProxFarLastState := OldMetric.Prox_Far;
	OldMetric.ProxNearLastState := OldMetric.Prox_Near;		
	g_HangerInletProcess.Common.AlarmList.AckOld[8]:= g_HangerInletProcess.Common.AlarmList.Ack[8];
	OldMetric.StateOld:= g_HangerInletProcess.EnableFeeding;
	
	// Set Timer for stopper 	
	IF EDGENEG(OldMetric.Prox_PreStopper) THEN
		// timer 0 
		OldMetric.PreStoperTimer:=0;		
	END_IF

	OldMetric.PreStoperTimer:=OldMetric.PreStoperTimer+1;
	IF g_HangerInletProcess.Common.State >= MACHPROC_RUN_20 THEN
	IF OldMetric.PreStoperTimer >=OldMetric.PreStoperTime  THEN
		// Set Outputs
		IF NOT OldMetric.sim  THEN
			//Q_OM_PreStopper_VLV:= OldMetric.Prox_PreStopper;
//			IF g_HCfg.FeedFromOldMetricon = 1 THEN		
//				Q_OM_PreStopper_VLV:= OldMetric.Prox_PreStopper;
//			ELSIF g_HCfg.FeedFromOldMetricon = 2 THEN
//				IF OldMetric.startTimer = FALSE THEN
//					Q_OM_PreStopper_VLV := OldMetric.PreStoperPuls;
//				ELSE
//					Q_OM_PreStopper_VLV 	:= OldMetric.Prox_PreStopper;
//				END_IF
//			END_IF
		END_IF
	END_IF
	
	IF ((NOT OldMetric.startTimer) AND OldMetric.Prox_PreStopper AND (OldMetric.Step < 99)) THEN
		IF OldMetric.PreStoperPuls THEN
 			IF OldMetric.PreStoperPulsTimer >= (g_MCfg.Accum.FullSensorOnPulse) THEN
  				OldMetric.PreStoperPulsTimer	:= 0;
				OldMetric.PreStoperPuls			:= FALSE;
			ELSE		 	
				OldMetric.PreStoperPulsTimer	:= OldMetric.PreStoperPulsTimer + 1;
			END_IF
		ELSE
 			IF OldMetric.PreStoperPulsTimer >= (g_MCfg.Accum.FullSensorOffPulse) THEN
  				OldMetric.PreStoperPulsTimer	:= 0;
				OldMetric.PreStoperPuls			:= TRUE;
			ELSE		 	
				OldMetric.PreStoperPulsTimer	:= OldMetric.PreStoperPulsTimer + 1;
			END_IF
		END_IF		
//	END_IF
	ELSE	//	IF EDGENEG(OldMetric.Prox_PreStopper) OR EDGEPOS(OldMetric.startTimer) OR (NOT OldMetric.Step = 99) THEN
 		OldMetric.PreStoperPulsTimer	:= 0;
		OldMetric.PreStoperPuls			:= FALSE;
	END_IF
	END_IF
		


 		
END_ACTION

ACTION NoExternalHangerFeed :

g_ExternalCom.ExternalFeed.WaitForHangerAtPresenceTimeOut := MAX (g_MCfg.Accum.HangerAtPresenceProxTimeOut , 50);
(*Run Timer*)
IF g_ExternalCom.ExternalFeed.TimeCountActive AND NOT  g_ProcessAlarm AND g_HangerInletProcess.EnableFeeding THEN
	g_ExternalCom.ExternalFeed.WaitForHangerAtPresenceTimer := g_ExternalCom.ExternalFeed.WaitForHangerAtPresenceTimer+1;
ELSE
	g_ExternalCom.ExternalFeed.WaitForHangerAtPresenceTimer:= 0; 
END_IF
(*Activate Timer*)
IF NOT IISeperationIn AND AccumStop.Pulse THEN
	g_ExternalCom.ExternalFeed.TimeCountActive := TRUE; 
END_IF
(*Reset the active timer if no impuls for longer than 4 sec *)
IF NOT AccumStop.Pulse THEN
	g_ExternalCom.ExternalFeed.PreStoperTimer := g_ExternalCom.ExternalFeed.PreStoperTimer+1;
	IF g_ExternalCom.ExternalFeed.PreStoperTimer > 400  THEN // for sec 
 		g_ExternalCom.ExternalFeed.TimeCountActive:= FALSE;
	END_IF
ELSE
	g_ExternalCom.ExternalFeed.PreStoperTimer := 0; 
END_IF

(*Deactivate Timer*)
IF IISeperationIn OR g_HangerInletProcess.Common.State<>20 THEN
	g_ExternalCom.ExternalFeed.TimeCountActive:= FALSE;
END_IF



(*Reset WaitTimer*)
IF IISeperationIn THEN
	g_ExternalCom.ExternalFeed.WaitForHangerAtPresenceTimer:= 0; 
END_IF


(*Calc Lost Time*)
IF g_ExternalCom.ExternalFeed.WaitForHangerAtPresenceTimer = g_ExternalCom.ExternalFeed.WaitForHangerAtPresenceTimeOut  THEN
	g_ExternalCom.ExternalFeed.NoExternalFeedTime := g_ExternalCom.ExternalFeed.NoExternalFeedTime + g_ExternalCom.ExternalFeed.WaitForHangerAtPresenceTimeOut ; 
END_IF

IF g_ExternalCom.ExternalFeed.WaitForHangerAtPresenceTimer > g_ExternalCom.ExternalFeed.WaitForHangerAtPresenceTimeOut  THEN
	g_ExternalCom.ExternalFeed.NoExternalFeedTime := g_ExternalCom.ExternalFeed.NoExternalFeedTime+1;
END_IF

g_Statistic[0].NoExternalHangerFeed := UDINT_TO_UINT(g_ExternalCom.ExternalFeed.NoExternalFeedTime/ 100);


END_ACTION


