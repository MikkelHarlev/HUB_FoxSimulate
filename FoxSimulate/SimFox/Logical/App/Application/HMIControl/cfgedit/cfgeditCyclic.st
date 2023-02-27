PROGRAM _CYCLIC
(*--------------------------------------------------------------------------
    Author:        Marcial Tschanz
    Filename:      foldprg2.src

    Description:   Control OF the foldprograms in the product picture

    References:

    Interfaces:    g_HMI

    Watch Debug:

    History:
	10-7-20			V2.03.6		WM 					Added InletRunTimeTC1Start with MIN AND MAX in Visu  	
	10-06-22		V2.03.5		PO Nilsson			Added check on g_MCfg.CheckCollapsedTime so it's not zero then set to 220...
	10-05-05		V2.03.4		PO Nilsson			So we can configure Serial communication...
	10-04-28		V2.03.3		PO Nilsson			Removed timer FOR RollOff that shall NOT be part OF the project..
	10-04-26		V2.03.2		PO Nilsson			Added timer FOR H_inlet first stop timer FOR long garments...		
	10-04-12		V2.03.1		PO Nilsson			Removed Overall flasp timers	
	10-03-29		V2.03.0		PO Nilsson			Pajamas opener timers..	
	10-03-23		V2.02.9		PO Nilsson			Added Only Full signals FOR Metricon exchange mode...	
	10-03-10		V2.02.8		PO Nilsson			Increased the LocalMachineConfig.DataExchangeMode TO go TO 2 instead OF 1...
	10-02-22		V2.02.7		PO Nilsson			Overall alignemnt FUNCTION...	
	10-02-17		V2.02.6		PO Nilsson			Removed Photocell.Overtime, Statics per Stacker OR Section
	10-02-03		V2.02.5		PO NIlsson			Removed the TopConveyor config page 604..	
													Removed NOT used variables (Distance)..
	10-01-26		V2.02.4		PO Nilsson			Removed Wait timer hanger inlet..
	09-12-14		V2.02.3		PO Nilsson			Removed timers FOR Press that was NOT used..	
													Added Flaps timers...
	09-09-15		V2.02.2		PO Nilsson			Rearranged stacker Start AND Stop positions FOR Multiple stacks..
	09-09-09		V2.02.1		PO Nilsson			Removed Slope timer adjust, moved TO Recipe...
	2009-08-25		V2.02		PO Nilsson			Removed NOT used parts..
	2009-08-19		V2.01		PO Nilsson			Bug fix, now we are loading the g_MCfg every time we enter cfg page.
	2009-05-27		V2.00		PO Nilsson			FOR Butterfly Fox	
    2009-05-11      V1.00.2 	Marcial Tschanz    	Improved HMI
    2009-03-18      V1.00.1 	Marcial Tschanz    	First version
----------------------------------------------------------------------------*)
	IF (g_OptionsAndConfigInit = FALSE) THEN		(* Check that pointer is bigger then Null *)
		RETURN;									(* Do not run task before pointer is assigned... *)
	END_IF

	(* Load the actual CFG-File *)
	IF g_HCfg.FeedManual THEN	//g_HMI_MacConfig
		IF (g_LoadCFG = TRUE) OR (g_HMI_MacConfig.ManualKeys.RT = 0) 
			OR (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = 5) OR (CfgPageOpened AND ((g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID >= PAGE_CONFIG_PAGE1) AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <= PAGE_CONFIG_PAGE13))) THEN
			g_LoadCFG 			:= FALSE;
			CfgPageOpened 		:= FALSE;
			LocalMachineConfig	:= g_MCfg;
			g_LoadCFGDone		:= TRUE;
		END_IF
		// If outside cfg page set variable..
		IF ((NOT ((g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID >= PAGE_CONFIG_PAGE1) AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <= PAGE_CONFIG_PAGE13))) 
			AND (NOT g_HMI_MacConfig.ManualKeys.RT = 0)) THEN
			CfgPageOpened 		:= TRUE;
		END_IF
	ELSE
		IF (g_LoadCFG = TRUE) OR (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = 5) OR (CfgPageOpened AND ((g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID >= PAGE_CONFIG_PAGE1) AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <= PAGE_CONFIG_PAGE13))) THEN
			g_LoadCFG 			:= FALSE;
			CfgPageOpened 		:= FALSE;
			LocalMachineConfig	:= g_MCfg;
			g_LoadCFGDone		:= TRUE;
		END_IF
		// If outside cfg page set variable..
		IF (NOT ((g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID >= PAGE_CONFIG_PAGE1) AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <= PAGE_CONFIG_PAGE13))) THEN
			CfgPageOpened 		:= FALSE;
		END_IF	
	END_IF

	(*#########################*)
	(* CONFIG PAGES handling  *)
	(*#########################*)
	IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID >= PAGE_CONFIG_PAGE1) AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <= PAGE_CONFIG_PAGE13) THEN
	
		IF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 1) THEN
			NewPage := g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID - 1;
			IF NewPage < PAGE_CONFIG_PAGE1 THEN
				NewPage := PAGE_CONFIG_PAGE13;
			END_IF
			IF (NewPage = PAGE_CONFIG_PAGE13) AND g_HCfg.FeedManual THEN
				NewPage := NewPage - 1;
			END_IF
			IF (NewPage = PAGE_CONFIG_PAGE10) THEN
				NewPage := NewPage - 1;
			END_IF
			IF (NewPage = PAGE_CONFIG_PAGE9) THEN
				NewPage := NewPage - 1;
			END_IF
			IF (NewPage = PAGE_CONFIG_PAGE8) THEN
				NewPage := NewPage - 1;
			END_IF
			StatusSetMenu := CallPageControllerLink(NewPage,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
		ELSIF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 2) THEN
			NewPage := g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID + 1;
			IF (NewPage = PAGE_CONFIG_PAGE8) THEN
				NewPage := NewPage + 1;
			END_IF
			IF (NewPage = PAGE_CONFIG_PAGE9) AND g_HCfg.DeliveryExternalCommunication < SENDOUT_JENWAY_EXCHANGE_1 THEN
				NewPage := NewPage + 1;
			END_IF
			IF (NewPage = PAGE_CONFIG_PAGE10) THEN
				NewPage := NewPage + 1;
			END_IF
			IF (NewPage = PAGE_CONFIG_PAGE13) AND g_HCfg.FeedManual  THEN
				NewPage := NewPage + 1;
			END_IF
			IF NewPage > PAGE_CONFIG_PAGE13 THEN
				NewPage := PAGE_CONFIG_PAGE1;
			END_IF
			StatusSetMenu := CallPageControllerLink(NewPage,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
		ELSIF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 3) THEN
			SaveMcfg 						:= TRUE;
		END_IF
	END_IF


	// To make backwards compability..
	IF g_MCfg.Inlet.Hanger.CheckCollapsedTime = 0 THEN
		LocalMachineConfig.Inlet.Hanger.CheckCollapsedTime 	:= 220;
		ParameterChanged 						:= TRUE;
	END_IF	


	(*###############*)
	(* Manual Inlet *)
	(*###############*)

	IF (((g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID >= PAGE_CONFIG_PAGE1) AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <= PAGE_CONFIG_PAGE13) 
		OR (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_MAIN_1 AND g_HMI_MacConfig.ManualKeys.RT = 0 )) AND (g_MCfgInitDone)) THEN

		IF HMI.MF_GeneralCmd > 0 THEN
			HMI.MF_GeneralCmd									:= 0;
			ParameterChanged 									:= TRUE;
			// Here we pass parameter to HMI
			LocalMachineConfig.MF.AutoStartnletBeltDelayTime	:= HMI.MF_AutoStartnletBeltDelayTime;
			LocalMachineConfig.MF.CheckShirtDelay				:= HMI.MF_CheckShirtDelay;
			LocalMachineConfig.MF.CheckShirtOnTime				:= HMI.MF_CheckShirtOnTime;
			LocalMachineConfig.MF.DelayVacuum					:= HMI.MF_DelayVacuum;
			LocalMachineConfig.MF.ReachGarmentDetectPHTimeOut	:= HMI.MF_ReachGarmentDetectPHTimeOut;
			LocalMachineConfig.MF.ReachInfeedBeltEndPHTimeOut	:= HMI.MF_ReachInfeedBeltEndPHTimeOut;
			LocalMachineConfig.MF.StartnletBeltDelayTime		:= HMI.MF_StartnletBeltDelayTime;
			LocalMachineConfig.MF.ButtonSenistivityTime			:= HMI.MF_ButtonSensivityTime;

			LocalMachineConfig.MF.InfeedBeltAirBlastDelay		:= HMI.MF_InfeedBeltAirBlastDelay;
			LocalMachineConfig.MF.InfeedBeltAirBlastOnTime		:= HMI.MF_InfeedBeltAirBlastOnTime;
		END_IF
	
		// Here we pass Parameter to App	// LocalMachineConfig
		HMI.MF_AutoStartnletBeltDelayTime						:= 	LocalMachineConfig.MF.AutoStartnletBeltDelayTime ;
		HMI.MF_CheckShirtDelay									:= 	LocalMachineConfig.MF.CheckShirtDelay	 ;
		HMI.MF_CheckShirtOnTime									:= 	LocalMachineConfig.MF.CheckShirtOnTime ;
		HMI.MF_DelayVacuum										:= 	LocalMachineConfig.MF.DelayVacuum	;
		HMI.MF_ReachGarmentDetectPHTimeOut						:= 	LocalMachineConfig.MF.ReachGarmentDetectPHTimeOut;
		HMI.MF_ReachInfeedBeltEndPHTimeOut						:= 	LocalMachineConfig.MF.ReachInfeedBeltEndPHTimeOut ;
		HMI.MF_StartnletBeltDelayTime							:= 	LocalMachineConfig.MF.StartnletBeltDelayTime;
		HMI.MF_ButtonSensivityTime								:=  LocalMachineConfig.MF.ButtonSenistivityTime;
		HMI.MF_InfeedBeltAirBlastDelay							:=	LocalMachineConfig.MF.InfeedBeltAirBlastDelay	;
		HMI.MF_InfeedBeltAirBlastOnTime							:=	LocalMachineConfig.MF.InfeedBeltAirBlastOnTime	;
	
		IF HMI.MF_KeyConfigCmd > 0 THEN
			HMI.MF_KeyConfigCmd									:= 0;
			ParameterChanged 									:= TRUE;

			IF HMI.MF_KeyConfigIndex  < MAX_MF_KEYCOUNT THEN
				HMI.MF_KeyConfigIndex							:= HMI.MF_KeyConfigIndex+1; 
			ELSE
				HMI.MF_KeyConfigIndex:= 1; 
			END_IF;
		
			LocalMachineConfig.MF.KeySelected 					:= HMI.MF_KeyConfigIndex ; 
			LocalMachineConfig.MF.AutoStartInletBelt			:= HMI.MF_AutoStartInletBelt;
		
			FOR i:=1 TO MAX_MF_KEYCOUNT DO
				LocalMachineConfig.MF.KeyConfig[i].KeyProgIndex 	:= HMI.MF_Keys[i].KeyProgIndex;
				LocalMachineConfig.MF.KeyConfig[i].KeyStackIndex 	:= HMI.MF_Keys[i].KeyStackIndex;
			END_FOR;
			LocalMachineConfig.MF.KeyProgIndex 				:= HMI.MF_KeyAuto.KeyProgIndex;
			LocalMachineConfig.MF.KeyStackIndex 			:= HMI.MF_KeyAuto.KeyStackIndex;
		END_IF		
	
		HMI.MF_AutoStartInletBelt								:= 	LocalMachineConfig.MF.AutoStartInletBelt;
		FOR i:=1 TO MAX_MF_KEYCOUNT DO
			HMI.MF_Keys[i].KeyProgIndex 						:= LocalMachineConfig.MF.KeyConfig[i].KeyProgIndex ;
			HMI.MF_Keys[i].KeyStackIndex						:= LocalMachineConfig.MF.KeyConfig[i].KeyStackIndex ;			
		END_FOR;
		
		HMI.MF_KeyAuto.KeyProgIndex								:= LocalMachineConfig.MF.KeyProgIndex 	;
		HMI.MF_KeyAuto.KeyStackIndex							:= LocalMachineConfig.MF.KeyStackIndex 	;
		HMI.MF_KeyConfigIndex 									:= LocalMachineConfig.MF.KeySelected ; 
	END_IF		


	IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID >= PAGE_CONFIG_PAGE1) AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <= PAGE_CONFIG_PAGE13) THEN
	
		(*#####################*)
		(* PAGE 1: General     *)
		(*#####################*)


		(* Shirt detection mode *)
		(* ------------------------------------ *)
		IF HMI.OnePhotocellShirtDetectCmd > 0 THEN
			HMI.OnePhotocellShirtDetectCmd 						:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Inlet.OnePhotocellShirtDetect 			:= LIMIT(0, HMI.OnePhotocellShirtDetect, 1);
		END_IF
		HMI.OnePhotocellShirtDetect := LIMIT(0, LocalMachineConfig.Inlet.OnePhotocellShirtDetect, 1);

	
		(* Stacker Belt: Speed Factor - Use direct value *)
		(* --------------------------------------------- *)
		IF HMI.GeneralSpeedFactorCmd > 0 THEN
			HMI.GeneralSpeedFactorCmd  							:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Stacker.BeltSpeedFactor 			:= HMI.GeneralSpeedFactor;
		END_IF
		HMI.GeneralSpeedFactor := LocalMachineConfig.Stacker.BeltSpeedFactor;




		(* Photocells: Filtertime - Use direct value *)
		(* ----------------------------------------- *)
		IF HMI.GeneralSensorFilterTimeCmd > 0 THEN
			HMI.GeneralSensorFilterTimeCmd  					:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.SensorFilterTime 				:= HMI.GeneralSensorFilterTime;
		END_IF
		HMI.GeneralSensorFilterTime := LocalMachineConfig.SensorFilterTime;


		(* Motor: Switchtime - Use direct value *)
		(* ------------------------------------ *)
		IF HMI.GeneralMotorSwitchTimeCmd > 0 THEN
			HMI.GeneralMotorSwitchTimeCmd 						:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.MotorSwitchTime 					:= HMI.GeneralMotorSwitchTime;
		END_IF
		HMI.GeneralMotorSwitchTime := LocalMachineConfig.MotorSwitchTime;



		// Fullsensor Ondelay
		//-------------------
		IF HMI.FullSensorOnTimeCmd > 0 THEN
			HMI.FullSensorOnTimeCmd  						:= 0;
			ParameterChanged 								:= TRUE;
			LocalMachineConfig.Accum.FullSensorOnTime				:= HMI.FullSensorOnTime;
		END_IF
		HMI.FullSensorOnTime := LocalMachineConfig.Accum.FullSensorOnTime;


		// Fullsensor Offdelay
		//-------------------
		IF HMI.FullSensorOffTimeCmd > 0 THEN
			HMI.FullSensorOffTimeCmd  						:= 0;
			ParameterChanged 								:= TRUE;
			LocalMachineConfig.Accum.FullSensorOffTime			:= HMI.FullSensorOffTime;
		END_IF
		HMI.FullSensorOffTime := LocalMachineConfig.Accum.FullSensorOffTime;


		// Fullsensor On Pulse
		//-------------------
		IF HMI.FullSensorOnPulseCmd > 0 THEN
			HMI.FullSensorOnPulseCmd  						:= 0;
			ParameterChanged 								:= TRUE;
			LocalMachineConfig.Accum.FullSensorOnPulse			:= HMI.FullSensorOnPulse;
		END_IF
		HMI.FullSensorOnPulse := LocalMachineConfig.Accum.FullSensorOnPulse;


		// Fullsensor Off Pulse
		//-------------------
		IF HMI.FullSensorOffPulseCmd > 0 THEN
			HMI.FullSensorOffPulseCmd  						:= 0;
			ParameterChanged 								:= TRUE;
			LocalMachineConfig.Accum.FullSensorOffPulse			:= HMI.FullSensorOffPulse;
		END_IF
		HMI.FullSensorOffPulse := LocalMachineConfig.Accum.FullSensorOffPulse;




		(* Conveyor Run Time - Use direct value *)
		(* ------------------------------------ *)
		IF HMI.GeneralConveyorRunTimeCmd > 0 THEN
			HMI.GeneralConveyorRunTimeCmd  						:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.ConveyorRunTime 					:= HMI.GeneralConveyorRunTime * 1000;
		END_IF
		IF g_MCfg.ConveyorRunTime <> 0 THEN
			HMI.GeneralConveyorRunTime := LocalMachineConfig.ConveyorRunTime / 1000;
		ELSE
			HMI.GeneralConveyorRunTime := 0;
		END_IF

		(* Width Increment Offset - Use direct value *)
		(* ----------------------------------------- *)
		IF HMI.GeneralWidthIncrementOffsetCmd > 0 THEN
			HMI.GeneralWidthIncrementOffsetCmd  				:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.LFold.WidthIncrementOffset 			:= HMI.GeneralWidthIncrementOffset;
		END_IF
		HMI.GeneralWidthIncrementOffset := LocalMachineConfig.LFold.WidthIncrementOffset;

		// Flap Trousers 
		// -------------------------------------------------------- 
		IF HMI.FlapTrousersCmd > 0 THEN	
			HMI.FlapTrousersCmd	:= 0;
			//LocalMachineConfig.FlapTrousersClosePlateOnTime := HMI.FlapTrousersClosePlateTimeOn;
		END_IF

		//HMI.FlapTrousersClosePlateTimeOn 	:= 	LocalMachineConfig.FlapTrousersClosePlateOnTime ;

		(* Statistic with Stacker or Section - Use direct value *)
		(* ---------------------------------------------------- *)
		//	IF HMI.GeneralStatisticStackOrSecCmd > 0 THEN
		//		HMI.GeneralStatisticStackOrSecCmd 					:= 0;
		//		ParameterChanged 									:= TRUE;
		//		LocalMachineConfig.StatisticStackOrSection			:= LocalMachineConfig.StatisticStackOrSection + 1;
		//	END_IF
		//	IF LocalMachineConfig.StatisticStackOrSection > 1 THEN
		//		LocalMachineConfig.StatisticStackOrSection := 0;
		//	END_IF
		//


		(*##############*)
		(* Hanger Accum *)
		(*##############*)

		IF HMI.AccumProxFarNearTimeoutCmd > 0 THEN
			HMI.AccumProxFarNearTimeoutCmd 						:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Accum.ProxFarNearTimeout			:= HMI.AccumProxFarNearTimeout;		
		END_IF
		HMI.AccumProxFarNearTimeout								:= LocalMachineConfig.Accum.ProxFarNearTimeout;

		IF HMI.AccumSTFRestartTimeDelayCmd > 0 THEN
			HMI.AccumSTFRestartTimeDelayCmd 						:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Accum.STFRestartTimeDelay			:= HMI.AccumSTFRestartTimeDelay;		
		END_IF
		HMI.AccumSTFRestartTimeDelay							:= LocalMachineConfig.Accum.STFRestartTimeDelay;

		(*##############*)
		(* Hanger inlet *)
		(*##############*)

		// Delay stop direct after hanger feed, for short garments
		IF HMI.DelayStopHangerTimeCmd > 0 THEN
			HMI.DelayStopHangerTimeCmd 							:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Inlet.Hanger.DelayStopHangerConveyor			:= HMI.DelayStopHangerConveyor;
		
		END_IF
		HMI.DelayStopHangerConveyor								:= LocalMachineConfig.Inlet.Hanger.DelayStopHangerConveyor;

		// Delay stop direct after hanger feed, for long garments
		IF HMI.DelayStopHangerTimeLongCmd > 0 THEN
			HMI.DelayStopHangerTimeLongCmd 							:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Inlet.Hanger.DelayStopHangerConveyorLong		:= HMI.DelayStopHangerConveyorLong;
		END_IF
		HMI.DelayStopHangerConveyorLong							:= LocalMachineConfig.Inlet.Hanger.DelayStopHangerConveyorLong;

		// Show long garments timer or not
		IF g_HCfg.OverallAlignment THEN	
			HMI.DelayStopHangerLongRunTime := 0;
		ELSE
			HMI.DelayStopHangerLongRunTime := 1;
		END_IF	

		(* Hanger passed time out *)
		IF HMI.HangerPassedTimeCmd > 0 THEN
			HMI.HangerPassedTimeCmd 							:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Inlet.Hanger.PassedTime					:= HMI.HangerPassedTime;
		END_IF
		HMI.HangerPassedTime									:= LocalMachineConfig.Inlet.Hanger.PassedTime;

		(* Check shirt delay *)
		IF HMI.CheckShirtDelayCmd > 0 THEN
			HMI.CheckShirtDelayCmd 								:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Inlet.CheckShirtDelay					:= HMI.CheckShirtDelay;
		END_IF
		HMI.CheckShirtDelay										:= LocalMachineConfig.Inlet.CheckShirtDelay;

		(* Check shirt ontime *)
		IF HMI.CheckShirtOnTimeCmd > 0 THEN
			HMI.CheckShirtOnTimeCmd 							:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Inlet.CheckShirtOnTime					:= HMI.CheckShirtOnTime;
		END_IF
		HMI.CheckShirtOnTime									:= LocalMachineConfig.Inlet.CheckShirtOnTime;

		(* Hanger hold point *)
		IF HMI.HangerHoldPointCmd > 0 THEN
			HMI.HangerHoldPointCmd 								:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Inlet.Hanger.HoldPoint					:= HMI.HangerHoldPoint;
		END_IF
		HMI.HangerHoldPoint										:= LocalMachineConfig.Inlet.Hanger.HoldPoint;

		// No reads before alarm
		IF HMI.NoReadAlarmCmd > 0 THEN
			HMI.NoReadAlarmCmd									:= FALSE;
			ParameterChanged 									:= TRUE;
			IF HMI.NoReadAlarm > 20 THEN
				HMI.NoReadAlarm := 20;
			END_IF	
			LocalMachineConfig.Inlet.NoReadAlarm						:= HMI.NoReadAlarm;
		END_IF
		HMI.NoReadAlarm										:= LocalMachineConfig.Inlet.NoReadAlarm;

		// Auto program on unknown hangers
		IF HMI.AutoProgramUfoCmd > 0 THEN
			HMI.AutoProgramUfoCmd								:= FALSE;
			ParameterChanged 									:= TRUE;
			IF HMI.AutoProgramUfo > MAX_NUMBER_OF_CATEGORIES THEN
				HMI.AutoProgramUfo := MAX_NUMBER_OF_CATEGORIES;
			END_IF			 
			LocalMachineConfig.Metricon.AutoProgramUfo					:= HMI.AutoProgramUfo;
		END_IF
		HMI.AutoProgramUfo										:= LocalMachineConfig.Metricon.AutoProgramUfo;

		// Press reset delay 
		IF HMI.PressResetTimeCmd > 0 THEN
			HMI.PressResetTimeCmd 								:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Deloading.PressResetTime					:= HMI.PressResetTime;
		END_IF
		HMI.PressResetTime										:= LocalMachineConfig.Deloading.PressResetTime;

		// Overall center startdelay
		IF HMI.OverallCenterDelayCmd > 0 THEN
			HMI.OverallCenterDelayCmd							:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Inlet.OverallCenterDelay				:= HMI.OverallCenterDelay;
		END_IF
		HMI.OverallCenterDelay									:= LocalMachineConfig.Inlet.OverallCenterDelay;

		// Overall center ontime
		IF HMI.OverallCenterOntimeCmd > 0 THEN
			HMI.OverallCenterOntimeCmd							:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Inlet.OverallCenterOnTime				:= HMI.OverallCenterOnTime;
		END_IF
		HMI.OverallCenterOnTime									:= LocalMachineConfig.Inlet.OverallCenterOnTime;

		// Runtime Vacuum inlet conveyor
		IF HMI.InletRunTimeTC1StartCmd > 0 THEN
			HMI.InletRunTimeTC1StartCmd						:= 0;
			ParameterChanged 								:= TRUE;
			LocalMachineConfig.Inlet.RunTimeTC1Start			:= HMI.InletRunTimeTC1Start;
		END_IF
		HMI.InletRunTimeTC1Start							:= LocalMachineConfig.Inlet.RunTimeTC1Start;

		// Show overall function with option flas
		IF g_HCfg.OverallAlignment THEN
			HMI.OverallRunTime := 0;		
		ELSE
			HMI.OverallRunTime := 1;		
		END_IF	
		
		// Show Flap Trousers function with option flas
		IF g_HCfg.FlapTrousers THEN
			HMI.FlapTrousersRunTime := 0;		
		ELSE
			HMI.FlapTrousersRunTime := 1;		
		END_IF	

		(*###############*)
		(* Hanger opener *)
		(*###############*)

		(* Start lift time *)
		IF HMI.StartLiftTimeCmd > 0 THEN
			HMI.StartLiftTimeCmd 								:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Deloading.StartLiftTime					:= HMI.StartLiftTime;
		END_IF
		HMI.StartLiftTime										:= LocalMachineConfig.Deloading.StartLiftTime;

		(* Hanger in plate time *)
		IF HMI.HangerInPlateTimeCmd > 0 THEN
			HMI.HangerInPlateTimeCmd 							:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Deloading.HangerInPlateTime				:= HMI.HangerInPlateTime;
		END_IF
		HMI.HangerInPlateTime									:= LocalMachineConfig.Deloading.HangerInPlateTime;

		(* Hanger reset time *)
		IF HMI.HangerResetTimeCmd > 0 THEN
			HMI.HangerResetTimeCmd 								:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Deloading.HangerResetTime					:= HMI.HangerResetTime;
		END_IF
		HMI.HangerResetTime										:= LocalMachineConfig.Deloading.HangerResetTime;

		(* Hanger slide out time *)
		IF HMI.HangerSlideOutTimeCmd > 0 THEN
			HMI.HangerSlideOutTimeCmd							:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Deloading.HangerSlideOutTime				:= HMI.HangerSlideOutTime;
		END_IF
		HMI.HangerSlideOutTime									:= LocalMachineConfig.Deloading.HangerSlideOutTime;

		(* Hanger reset delay *)
		IF HMI.HangerResetDelayCmd > 0 THEN
			HMI.HangerResetDelayCmd								:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Deloading.HangerResetDelay					:= HMI.HangerResetDelay;
		END_IF
		HMI.HangerResetDelay									:= LocalMachineConfig.Deloading.HangerResetDelay;

		(* Hanger reset delay *)
		IF HMI.KGHangerClampDelayCmd > 0 THEN
			HMI.KGHangerClampDelayCmd								:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Deloading.KG.HangerClampDelay				:= HMI.KGHangerClampDelay;
		END_IF
		HMI.KGHangerClampDelay									:= LocalMachineConfig.Deloading.KG.HangerClampDelay;

		// Pyjamas Motor run time 
		IF HMI.PajamasMotorPosCmd > 0 THEN
			HMI.PajamasMotorPosCmd							:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Deloading.PajamasStopPos				:= HMI.PajamasStopPos;
		END_IF
		HMI.PajamasStopPos									:= LocalMachineConfig.Deloading.PajamasStopPos;
		
		// Pyjamas 2nd Poition in case 2 steps opening is used  
		IF HMI.PajamasMotorPos2Cmd > 0 THEN
			HMI.PajamasMotorPos2Cmd							:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Deloading.PajamasStopPos2				:= HMI.PajamasStopPos2;
		END_IF
		HMI.PajamasStopPos2									:= LocalMachineConfig.Deloading.PajamasStopPos2;
		
		// Pyjamas Delay restart
		IF HMI.PajamasRestartDelayCmd > 0 THEN
			HMI.PajamasRestartDelayCmd							:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Deloading.PajamasRestartDelay				:= HMI.PajamasRestartDelay;
		END_IF
		HMI.PajamasRestartDelay									:= LocalMachineConfig.Deloading.PajamasRestartDelay;
	
		(*##############*)
		(* Top conveyor *)
		(*##############*)

		(* Top conveyor belt on time *)
		IF HMI.InfeedBeltOnTimeCmd > 0 THEN
			HMI.InfeedBeltOnTimeCmd 							:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.TC.InfeedBeltOnTime					:= HMI.InfeedBeltOnTime;
		END_IF
		HMI.InfeedBeltOnTime									:= LocalMachineConfig.TC.InfeedBeltOnTime;	

		(*###########################*)
		(* PAGE 2: Inlet And Lateral *)
		(*###########################*)

		// Distance Turn around photocell - LA-FoldPoint 
		IF HMI.DistanceXA_FoldPointCmd > 0 THEN
			HMI.DistanceXA_FoldPointCmd  						:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.LFold.DistanceIBLA_FoldPoint			:= HMI.DistanceIBLA_FoldPoint;
		END_IF
		HMI.DistanceIBLA_FoldPoint := LocalMachineConfig.LFold.DistanceIBLA_FoldPoint;

		// Distance XB-FoldPoint - Use direct value 
		IF HMI.DistanceXB_FoldPointCmd > 0 THEN
			HMI.DistanceXB_FoldPointCmd  						:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.XFold.DistanceXB_FoldPoint 			:= HMI.DistanceXB_FoldPoint;
		END_IF
		HMI.DistanceXB_FoldPoint := LocalMachineConfig.XFold.DistanceXB_FoldPoint;

		// Distance FoldPoint-XBExit - Use direct value 
		IF HMI.DistanceXBFoldPoint_XBExitCmd > 0 THEN
			HMI.DistanceXBFoldPoint_XBExitCmd  					:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.XFold.DistanceXBFoldPoint_XBExit 		:= HMI.DistanceXBFoldPoint_XBExit;
		END_IF
		HMI.DistanceXBFoldPoint_XBExit := LocalMachineConfig.XFold.DistanceXBFoldPoint_XBExit;

		// CrossB Extra rewerse time 
		IF HMI.CrossBExtraRewerseTimeCmd > 0 THEN
			HMI.CrossBExtraRewerseTimeCmd  				:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.XFold.CrossBExtraRewerseTime			:= HMI.CrossBExtraRewerseTime;
		END_IF
		HMI.CrossBExtraRewerseTime := LocalMachineConfig.XFold.CrossBExtraRewerseTime;

		(*############################*)
		(* PAGE 3: Stacker and Outlet *)
		(*############################*)

		// Arrow bottons
		IF (HMI.Stacker.OperatorCmd = 1) AND (HMI.Stacker.SelectedStacker < g_HCfg.NumberOfStackers) THEN	
			HMI.Stacker.OperatorCmd := 0;
			HMI.Stacker.SelectedStacker := HMI.Stacker.SelectedStacker + 1; 
		ELSIF (HMI.Stacker.OperatorCmd = 2) AND (HMI.Stacker.SelectedStacker > 1) THEN
			HMI.Stacker.OperatorCmd := 0;
			HMI.Stacker.SelectedStacker := HMI.Stacker.SelectedStacker - 1; 
			// Make check if operator set values direct...
		ELSIF (HMI.Stacker.OperatorCmd = 3) THEN
			HMI.Stacker.OperatorCmd := 0;
			IF (HMI.Stacker.SelectedStacker > g_HCfg.NumberOfStackers) OR (HMI.Stacker.SelectedStacker < 1) THEN
				HMI.Stacker.SelectedStacker := 1; 
			END_IF	
		ELSIF (HMI.Stacker.OperatorCmd = 0) AND (HMI.Stacker.SelectedStacker = 0) THEN	
			HMI.Stacker.SelectedStacker := 1;
		END_IF	

		// Stacker Delivery Destination 
		IF g_HCfg.CrossConveyor >= 1 THEN
			HMI.CrossBeltNrRuntime := 0;
		ELSE
			HMI.CrossBeltNrRuntime := 1;
		END_IF
	
		IF HMI.Stacker.CrossBeltNrCmd > 0 THEN	
			HMI.Stacker.CrossBeltNrCmd		 										:= 0;
			ParameterChanged 														:= TRUE;
			LocalMachineConfig.Outlet.CrossBeltNr[HMI.Stacker.SelectedStacker] 	:= HMI.Stacker.CrossBeltNr;
			IF LocalMachineConfig.Outlet.CrossBeltNr[HMI.Stacker.SelectedStacker] > 2 THEN
				LocalMachineConfig.Outlet.CrossBeltNr[HMI.Stacker.SelectedStacker] := 2;
			END_IF		
		END_IF
		HMI.Stacker.CrossBeltNr := LocalMachineConfig.Outlet.CrossBeltNr[HMI.Stacker.SelectedStacker];

		// Stacker Start Position - Use direct value 
		IF HMI.Stacker.StartPositionCmd > 0 THEN	
			HMI.Stacker.StartPositionCmd	 										:= 0;
			ParameterChanged 														:= TRUE;
			LocalMachineConfig.Stacker.StartPosition[HMI.Stacker.SelectedStacker] 	:= HMI.Stacker.StartPosition;
		END_IF
		HMI.Stacker.StartPosition := LocalMachineConfig.Stacker.StartPosition[HMI.Stacker.SelectedStacker];

		// Stacker Stop Position - Use direct value 
		IF HMI.Stacker.StopPositionCmd > 0 THEN
			HMI.Stacker.StopPositionCmd  										:= 0;
			ParameterChanged 													:= TRUE;
			LocalMachineConfig.Stacker.StopPosition[HMI.Stacker.SelectedStacker]	:= HMI.Stacker.StopPosition;
		END_IF
		HMI.Stacker.StopPosition := LocalMachineConfig.Stacker.StopPosition[HMI.Stacker.SelectedStacker];

		// Outlet Start Position - Use direct value 
		IF HMI.Stacker.OutletStartPositionCmd > 0 THEN	
			HMI.Stacker.OutletStartPositionCmd									:= 0;
			ParameterChanged 													:= TRUE;
			LocalMachineConfig.Outlet.StartPosition[HMI.Stacker.SelectedStacker]	:= HMI.Stacker.OutletStartPosition;
		END_IF
		HMI.Stacker.OutletStartPosition := LocalMachineConfig.Outlet.StartPosition[HMI.Stacker.SelectedStacker];

		// Outlet Stop Position - Use direct value
		IF HMI.Stacker.OutletStopPositionCmd > 0 THEN	
			HMI.Stacker.OutletStopPositionCmd										:= 0;
			ParameterChanged 														:= TRUE;
			LocalMachineConfig.Outlet.StopPosition[HMI.Stacker.SelectedStacker]	:= HMI.Stacker.OutletStopPosition;
		END_IF
		HMI.Stacker.OutletStopPosition := LocalMachineConfig.Outlet.StopPosition[HMI.Stacker.SelectedStacker];

		// Flaps delay open
		IF HMI.Stacker.FlapsDelayOpenCmd > 0 THEN	
			HMI.Stacker.FlapsDelayOpenCmd						:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Stacker.FlapsDelayOpen					:= HMI.Stacker.FlapsDelayOpen;
		END_IF
		HMI.Stacker.FlapsDelayOpen	 := LocalMachineConfig.Stacker.FlapsDelayOpen;

		// Flaps delay close
		IF HMI.Stacker.FlapsTimeOpenCmd > 0 THEN	
			HMI.Stacker.FlapsTimeOpenCmd						:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Stacker.FlapsTimeOpen					:= HMI.Stacker.FlapsTimeOpen;
		END_IF
		HMI.Stacker.FlapsTimeOpen	 := LocalMachineConfig.Stacker.FlapsTimeOpen;

		// Flaps restart delay
		IF HMI.Stacker.FlapsRestartDelayCmd > 0 THEN	
			HMI.Stacker.FlapsRestartDelayCmd					:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Stacker.FlapsRestartDelay				:= HMI.Stacker.FlapsRestartDelay;
		END_IF
		HMI.Stacker.FlapsRestartDelay	 := LocalMachineConfig.Stacker.FlapsRestartDelay;

		(*##############################*)
		(* PAGE 4: Stacker and Outlet 2 *)
		(*##############################*)

		(* Stacker: Transport Offset Time - Use direct value *)
		IF HMI.StackerTransportOffSetTimeCmd > 0 THEN
			HMI.StackerTransportOffSetTimeCmd  						:= 0;
			ParameterChanged 										:= TRUE;
			LocalMachineConfig.Stacker.TransportOffSetTime			:= HMI.StackerTransportOffSetLength;
		END_IF
		HMI.StackerTransportOffSetLength := LocalMachineConfig.Stacker.TransportOffSetTime;

		(* Stacker: Indexing Delay - Use direct value *)
		IF HMI.StackerIndexingDelayCmd > 0 THEN
			HMI.StackerIndexingDelayCmd  							:= 0;
			ParameterChanged 										:= TRUE;
			LocalMachineConfig.Stacker.IndexingDelay 				:= HMI.StackerIndexingDelay;
		END_IF
		HMI.StackerIndexingDelay := LocalMachineConfig.Stacker.IndexingDelay;

		(* Stacker: Max. Sink Delay - Use direct value *)
		IF HMI.StackerMaxSinkDelayCmd > 0 THEN
			HMI.StackerMaxSinkDelayCmd  							:= 0;
			ParameterChanged 										:= TRUE;
			LocalMachineConfig.Stacker.MaxSinkDelay					:= HMI.StackerMaxSinkDelay;
		END_IF
		HMI.StackerMaxSinkDelay := LocalMachineConfig.Stacker.MaxSinkDelay;

		// Stacker: Lift raise delay
		IF HMI.LiftRaiseDelayCmd > 0 THEN
			HMI.LiftRaiseDelayCmd  									:= 0;
			ParameterChanged 										:= TRUE;
			LocalMachineConfig.Stacker.LiftRaiseDelay				:= HMI.LiftRaiseDelay;
		END_IF
		HMI.LiftRaiseDelay := LocalMachineConfig.Stacker.LiftRaiseDelay;

		(* Outlet: Stack Change Mode - Use direct value *)
		IF HMI.OutletStackChangeModeCmd > 0 THEN
			HMI.OutletStackChangeModeCmd 							:= 0;
			ParameterChanged 										:= TRUE;
			LocalMachineConfig.Outlet.StackChangeMode				:= LocalMachineConfig.Outlet.StackChangeMode + 1;
		END_IF
		IF LocalMachineConfig.Outlet.StackChangeMode > 6 THEN
			LocalMachineConfig.Outlet.StackChangeMode := 0;
		END_IF

		(* Outlet: RollOff Return Time - Use direct value *)
		IF HMI.OutletRollOffReturnTimeCmd > 0 THEN
			HMI.OutletRollOffReturnTimeCmd  						:= 0;
			ParameterChanged 										:= TRUE;
			LocalMachineConfig.Outlet.RollOffReturnTime 				:= HMI.OutletRollOffReturnTime;
		END_IF
		HMI.OutletRollOffReturnTime := LocalMachineConfig.Outlet.RollOffReturnTime;

		(* Outlet: Cross-Belt length - Use direct value *)
		IF HMI.OutletCrossBeltLengthCmd > 0 THEN
			HMI.OutletCrossBeltLengthCmd  							:= 0;
			ParameterChanged 										:= TRUE;
			LocalMachineConfig.Outlet.CrossBeltLength 				:= HMI.OutletCrossBeltLength;
		END_IF
		HMI.OutletCrossBeltLength := LocalMachineConfig.Outlet.CrossBeltLength;

		(*##############################*)
		(* PAGE 5: Delivery             *)
		(*##############################*)

		(* Delivery Crossbelt Offset - Use direct value *)
		//IF HMI.DeliveryCrossBeltOffSetCmd > 0 THEN
		//		HMI.DeliveryCrossBeltOffSetCmd  						:= 0;
		//		ParameterChanged 										:= TRUE;
		//		LocalMachineConfig.Delivery.CrossBeltOffSet 				:= HMI.DeliveryCrossBeltOffSet;
		//	END_IF
		//	HMI.DeliveryCrossBeltOffSet := LocalMachineConfig.Delivery.CrossBeltOffSet;
		//

		(* Delivery Exit Run Time - Use direct value *)
		IF HMI.DeliveryExitRunTimeCmd > 0 THEN
			HMI.DeliveryExitRunTimeCmd  							:= 0;
			ParameterChanged 										:= TRUE;
				LocalMachineConfig.Delivery.ExitRunTime 					:= HMI.DeliveryExitRunTime;
		END_IF
		HMI.DeliveryExitRunTime := 	LocalMachineConfig.Delivery.ExitRunTime;

		(* Delivery function *)
		IF HMI.DeliveryFunctionCmd > 0 THEN
			HMI.DeliveryFunctionCmd  							:= 0;
			ParameterChanged 									:= TRUE;
			LocalMachineConfig.Delivery.Function 				:= LocalMachineConfig.Delivery.Function + 1;
		END_IF
		IF LocalMachineConfig.Delivery.Function > DELIVERY_FUNCTION_TRANSPORT_1 THEN
			LocalMachineConfig.Delivery.Function := DELIVERY_FUNCTION_ACCUMULATE_0;
		END_IF
		HMI.DeliveryFunction := LocalMachineConfig.Delivery.Function;

		(*##############################*)
		(* PAGE 9: SendOut/Jenway      *)
		(*##############################*)
		// SFX 150113 Use M2M parameters instead

		(*##############################*)
		(* PAGE 10: Compound             *)
		(*##############################*)
		// SFX 150113 Use M2M parameters instead

		(*##############################*)
		(* PAGE 8: Loading Conveyor     *)
		(*##############################*)

		(*#####################################################*)
		(* Load the changed variables to g_FoldProgram         *)
		(*#####################################################*)
		//IF ParameterChanged THEN
		//		(* Update Master variable 'config' without saving *)
		//		g_MCfg				:= LocalMachineConfig;
		//		ParameterChanged 			:= FALSE;
		//		g_UpdateMachineConfigFlag 	:= TRUE;
		//	END_IF
		//
		//	IF g_SaveMachineConfigFlag = TRUE THEN
		//		g_MCfg				:=	LocalMachineConfig;
		//	END_IF
		//

		(*########################*)
		(* Metricon communication *)
		(*########################*)
		// Full signals  
		IF HMI.FullSignalsCmd > 0 THEN
			HMI.FullSignalsCmd  									:= 0;
			ParameterChanged 										:= TRUE;
			LocalMachineConfig.Metricon.UseExternalStatus					:= LocalMachineConfig.Metricon.UseExternalStatus + 1;
			IF LocalMachineConfig.Metricon.UseExternalStatus > 1 THEN
				LocalMachineConfig.Metricon.UseExternalStatus := 0;
			END_IF			
		END_IF

		// Data exchange mode 
		//
		// 0 = Full data
		// 1 = Auto program only
		// 2 = Auto program and stack change
		// 3 = Only Full signals	
		// ------------------ 
		// DATA_EX_FULL_0;
		// DATA_EX_AUTO_1;
		// DATA_EX_AUTO_STACKCHANGE_2;
		// DATA_EX_ONLY_FULL_IO_3;
		// DATA_EX_ONLY_STACKCHANGE_4;

		IF HMI.DataExchangeModeCmd > 0 THEN
			HMI.DataExchangeModeCmd									:= 0;
			ParameterChanged 										:= TRUE;
			LocalMachineConfig.Metricon.DataExchangeMode						:= LocalMachineConfig.Metricon.DataExchangeMode + 1;
			IF LocalMachineConfig.Metricon.ComMode = 4 THEN
				IF LocalMachineConfig.Metricon.DataExchangeMode > DATA_EX_ONLY_STACKCHANGE_4 THEN
					LocalMachineConfig.Metricon.DataExchangeMode := 1;
				ELSIF LocalMachineConfig.Metricon.DataExchangeMode = DATA_EX_ONLY_FULL_3 THEN
					LocalMachineConfig.Metricon.DataExchangeMode := DATA_EX_ONLY_STACKCHANGE_4;
				END_IF
			ELSE
				IF LocalMachineConfig.Metricon.DataExchangeMode > DATA_EX_ONLY_FULL_IO_3 THEN
					LocalMachineConfig.Metricon.DataExchangeMode := 0;
				END_IF
			END_IF			
		END_IF
	
		// Communication way. XML, Serial, BCD, PVI
		// 0 = No com
		// 1 = XML.
		// 2 = PVI
		// 3 = Serial
		// 4 = BCD	
		IF HMI.ComModeCmd > 0 THEN
			HMI.ComModeCmd		  									:= 0;
			ParameterChanged 										:= TRUE;
			LocalMachineConfig.Metricon.ComMode := LocalMachineConfig.Metricon.ComMode + 1;
			// No PVI possible
			IF LocalMachineConfig.Metricon.ComMode = 2 THEN
				LocalMachineConfig.Metricon.ComMode := 3;
			END_IF			
			IF LocalMachineConfig.Metricon.ComMode > 4 THEN
				LocalMachineConfig.Metricon.ComMode := 0;
			END_IF
		END_IF
		IF (LocalMachineConfig.Metricon.ComMode <> 4) AND (LocalMachineConfig.Metricon.DataExchangeMode = DATA_EX_ONLY_STACKCHANGE_4) THEN
			HMI.DataExchangeModeCmd := 1;
		ELSIF  ((LocalMachineConfig.Metricon.ComMode = 4) AND ((LocalMachineConfig.Metricon.DataExchangeMode = DATA_EX_FULL_0) OR 
			(LocalMachineConfig.Metricon.DataExchangeMode = DATA_EX_ONLY_FULL_IO_3))) THEN
			LocalMachineConfig.Metricon.DataExchangeMode := 1;
			ParameterChanged 					:= TRUE;	
		END_IF
	END_IF

	IF g_LoadCFGDone THEN
		IF ParameterChanged THEN
			(* Update Master variable 'config' without saving *)
			g_MCfg				:= LocalMachineConfig;
			ParameterChanged 			:= FALSE;
			//		g_UpdateMachineConfigFlag 	:= TRUE;
			//		IF NOT (g_Core.Services.Machine.Interface.ptrConfig > 0) THEN		
			//			;
			//		ELSE
			//			//MachineConfig ACCESS(g_Core.Services.Machine.Interface.ptrConfig );
			//			//MachineConfig := LocalMachineConfig;
			//		END_IF	
		END_IF

		IF SaveMcfg THEN
			SaveMcfg 										:= FALSE;
			g_Core.Services.Machine.Interface.isCmdSave 	:= TRUE;						// Command mcfg to do the actual saving
		END_IF
	END_IF

END_PROGRAM

