(********************************************************************
 * COPYRIGHT -- IXP Data
 ********************************************************************
 * Program: Simulation
 * File: SimulationCyclic.st
 * Author: mazin.khalafalla
 * Created: May 27, 2019
 ********************************************************************
 * Implementation of program Simulation
 ********************************************************************)

PROGRAM _CYCLIC

IF NOT g_SystemInitialized THEN
    RETURN;
END_IF
Sim.CurrentTimer	:= g_Timers._1_ms;
	IF EDGENEG(g_Core.System.Runtime.isRunning) THEN
		g_sim.Test	:= 0;
	END_IF	
IF g_sim.Test THEN
g_Core.Services.Alarmhandler.Interface.AlarmGroup[CORE_INFOS].Alarm[19]	:= TRUE;		
//	ISEmergencyOk			:= TRUE;
//	ISThermoOk				:= TRUE;
//	ISGuardOk				:= TRUE;
//	ISAirOk					:= TRUE;
//	ISFuseOk[1]				:= TRUE;
//	IFuseOkSideConv			:= TRUE;
//	IBStackLowerTable[1]	:= TRUE;
	
//	Config.TurnerDistancePh	:= 200;
// IO
	IBRightTrouseDetection	:= g_sim.IBRightTrouseDetection;
	g_Core.System.Interface.alarms.isAcoposError	:= FALSE;	
	// Stop Simulation if machine stop
	IF (Sim.State > 0) AND NOT g_Core.System.Runtime.isRunning THEN
		Sim.State := 0;
		g_sim.Test := 0;
	END_IF	

	CASE Sim.State OF
	0 :	// Start
		IF g_Core.System.Runtime.isRunning THEN
			g_sim.IIPrestopIn := TRUE;
			IF (g_HangerOpenerProcess.Common.State >= 20) AND NOT g_ProcessAlarm AND (g_HangerInletProcess.EnableFeeding =1 ) THEN
				Sim.State	:= 10;
				Sim.Counter	:= Sim.CurrentTimer;
			ELSIF g_HCfg.FeedManual  AND NOT g_ProcessAlarm THEN
				Sim.State	:= 15;
				Sim.Counter	:= Sim.CurrentTimer;
			END_IF
		END_IF
	
	10:
		g_sim.IIPrestopIn		:= FALSE;
		g_sim.IISeperationIn	:= TRUE;
		IF (ElapsedMsTime (Sim.CurrentTimer,Sim.Counter) > g_HangerInletProcess.PresenceStepfeeder.OnDelay +400) THEN //+400
		g_sim.IISupervisionSeperation	:= TRUE;

			Sim.State	:=20;

		Sim.Counter	:= Sim.CurrentTimer;
		END_IF;
	
	15:
		g_sim.IBGarmentOnInletMP		:= TRUE;
		Sim.State	:=20;
	
	20: 
		//IF QYSeparation THEN
			g_sim.IISupervisionSeperation	:= FALSE;
			g_sim.IISeperationIn			:= FALSE;
		//END_IF
		IF (ElapsedMsTime (Sim.CurrentTimer,Sim.Counter) > 1500) AND NOT g_ProcessAlarm THEN //1500
			g_sim.IBGarmentDetection		:= TRUE;
			g_sim.IBRightTrouseDetection	:= TRUE;
			g_sim.IBGarmentOnInletMP		:= FALSE;
			Sim.Counter	:= Sim.CurrentTimer;
			Sim.State	:= 30;
		END_IF
	30:	
		IF (ElapsedMsTime (Sim.CurrentTimer,Sim.Counter) > 400) AND NOT g_ProcessAlarm THEN
			g_sim.IBGarmentDetection		:= FALSE;
			g_sim.IBRightTrouseDetection	:= FALSE;
			g_sim.IBHangerDeloadReady		:= TRUE;
			g_sim.IBHangerMove				:= TRUE;
			g_sim.IBInfeedBeltEndMP		:= TRUE;
			Sim.Counter						:= Sim.CurrentTimer;
			Sim.State						:= 40;
		END_IF
	40:
		g_sim.IBHangerMove		:= FALSE;
		IF (ElapsedMsTime (Sim.CurrentTimer,Sim.Counter) > 800) THEN
			g_sim.IBHangerDeloadReady	:= FALSE;
			g_sim.IBHangerMove			:= TRUE;
			g_sim.IBInfeedBeltEndMP		:= FALSE;
			Sim.Counter					:= Sim.CurrentTimer;
			IF g_HCfg.FeedManual THEN
				Sim.State					:= 100;
				Sim.Counter					:= Sim.CurrentTimer;
			ELSE	
				Sim.State					:= 50;
				Sim.Counter					:= Sim.CurrentTimer;
			END_IF
		END_IF
	50:
		g_sim.IBHangerMove		:= FALSE;
		IF (ElapsedMsTime (Sim.CurrentTimer,Sim.Counter) > 400) THEN
			g_sim.IIDeloadingDown	:= FALSE;
			Sim.Counter				:= Sim.CurrentTimer;
			Sim.State				:= 60;
		END_IF
		
	60:
		IF (ElapsedMsTime (Sim.CurrentTimer,Sim.Counter) > 500) THEN
			g_sim.IIDeloadingUp	:= TRUE;
			Sim.Counter			:= Sim.CurrentTimer;
			Sim.State			:= 70;
		END_IF
		
	70:
		IF (ElapsedMsTime (Sim.CurrentTimer,Sim.Counter) > 200) THEN
			g_sim.IBJamDeloading	:= TRUE;
			Sim.Counter				:= Sim.CurrentTimer;
			Sim.State				:= 80;
		END_IF
	80:
		IF (ElapsedMsTime (Sim.CurrentTimer,Sim.Counter) > 1000) THEN
			g_sim.IBJamDeloading	:= FALSE;
			g_sim.IIJamDeloadingOut	:= TRUE;
			Sim.Counter				:= Sim.CurrentTimer;
			Sim.State				:= 90;
		END_IF
		
	90:
		IF (ElapsedMsTime (Sim.CurrentTimer,Sim.Counter) > 200) THEN
			g_sim.IIJamDeloadingOut	:= FALSE;
			g_sim.IIDeloadingUp		:= FALSE;
			g_sim.IIDeloadingDown	:= TRUE;
			Sim.Counter				:= Sim.CurrentTimer;
			Sim.State				:= 100;
		END_IF
		
	100:
		IF (ElapsedMsTime (Sim.CurrentTimer,Sim.Counter) > 200) THEN
			g_sim.IBHorizontal		:= TRUE;
			g_sim.IIBladeRightHome	:= TRUE;
			Sim.Counter				:= Sim.CurrentTimer;
			Sim.State				:= 110;
//			ConvH.SetSpeed	:= 1;
//			ConvH.CountSetSpeed	:= g_WheelCounter + 50;
		END_IF
	
	110:
		g_SpeedCountOfWheel			:= g_SpeedCountOfWheel +1;
		g_WheelCounter				:= g_WheelCounter +1;
		IF (ElapsedMsTime (Sim.CurrentTimer,Sim.Counter) > 400) THEN
			g_sim.IBHorizontal		:= FALSE;
			g_sim.IBXAFold			:= TRUE;
			Sim.Counter				:= Sim.CurrentTimer;
			Sim.State				:= 120;
		END_IF
		
	120:
		IF (ElapsedMsTime (Sim.CurrentTimer,Sim.Counter) > 1200) THEN //1500
			g_sim.IBXAFold			:= FALSE;
			g_sim.IBXBFold			:= TRUE;
			Sim.Counter				:= Sim.CurrentTimer;
			Sim.State				:= 130;
		END_IF
	
	130:
		IF (ElapsedMsTime (Sim.CurrentTimer,Sim.Counter) > 1100) THEN
			g_sim.IBXBFold			:= FALSE;
			g_sim.IBStacker[1]		:= TRUE;
			Sim.Counter				:= Sim.CurrentTimer;
			Sim.State				:= 140;
		END_IF
	
	140:
		IF (ElapsedMsTime (Sim.CurrentTimer,Sim.Counter) > 300) THEN
			g_sim.IBStacker[1]		:= FALSE;
			Sim.Counter				:= Sim.CurrentTimer;
			Sim.State				:= 150;
		END_IF
		
	150:
		IF (ElapsedMsTime (Sim.CurrentTimer,Sim.Counter) > 10) THEN
			Sim.Counter				:= Sim.CurrentTimer;
			Sim.State				:= 0;
		END_IF
		
	END_CASE;

ELSE

	g_sim.IIPrestopIn 				:= FALSE;
	g_sim.IISeperationIn 			:= FALSE;
	g_sim.IISupervisionSeperation	:= FALSE;
	g_sim.IBGarmentDetection 		:= FALSE;
	g_sim.IBGarmentOnInletMP		:= FALSE;
	g_sim.IBInfeedBeltEndMP			:= FALSE;
	g_sim.IBHangerDeloadReady	 	:= FALSE;
	g_sim.IBHangerMove 				:= FALSE;
	g_sim.IIDeloadingUp 			:= FALSE;
	g_sim.IIDeloadingDown 			:= FALSE;
	g_sim.IBRightTrouseDetection 	:= FALSE;
	g_sim.IBJamDeloading 			:= FALSE;
	g_sim.IIJamDeloadingOut 		:= FALSE;
	g_sim.IBHorizontal 				:= FALSE;
	g_sim.IBXAFold 					:= FALSE;
	g_sim.IIBladeRightHome 			:= FALSE;
	g_sim.IBXBFold 					:= FALSE;
	g_sim.IBStacker[1]				:= FALSE;
	
		Sim.State						:= 0;
		g_Core.Services.Alarmhandler.Interface.AlarmGroup[CORE_INFOS].Alarm[19]	:= FALSE;
END_IF

END_PROGRAM
