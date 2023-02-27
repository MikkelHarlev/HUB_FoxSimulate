(********************************************************************
 * COPYRIGHT -- IT
 ********************************************************************
 * Program: FeedTyp
 * File: FeedTypCyclic.st
 * Author: mariw
 * Created: June 14, 2011
 ********************************************************************
 * Implementation of program FeedTyp
 ********************************************************************)

PROGRAM _CYCLIC
  

	IF g_HCfg.FeedManual THEN
		g_HMI_MacConfig.FeedTyp.RT:= 1; // View Manual and Hide Hanger   
		g_HMI_MacConfig.FeedTyp.COL:= 88; // Manual Feed Background Color
		g_HMI_MacConfig.FeedTyp.TXT:= 1; // View Hanger and Hide Manual
	ELSE
		g_HMI_MacConfig.FeedTyp.RT:= 0; // View Hanger and Hide Manual  
		g_HMI_MacConfig.FeedTyp.COL:= 52; // Standard Color
		g_HMI_MacConfig.FeedTyp.TXT:= 0; // View Hanger and Hide Manual		
	END_IF;

	IF (g_HCfg.HangerReading = 8) AND (g_MCfg.Metricon.ComMode <> 4) THEN
 		g_HMI_MacConfig.HangerFeed.RTCom 	:= 0;
	ELSE
		g_HMI_MacConfig.HangerFeed.RTCom	:= 1;
	END_IF
	IF g_HCfg.PrinterCom = 1 THEN
		g_HMI_MacConfig.HangerFeed.RTPrint	:= 0;
	ELSE
		g_HMI_MacConfig.HangerFeed.RTPrint	:= 1;
	END_IF
 
	g_HMI_MacConfig.HangerFeed.RT:= USINT_TO_BOOL (g_HMI_MacConfig.FeedTyp.RT); // Hide by Default 
	g_HMI_MacConfig.ManualFeed.RT:= NOT (USINT_TO_BOOL(g_HMI_MacConfig.FeedTyp.RT)); // View by Default 


	// Hide Visu Buttons
	g_HMI_MacConfig.ReleaseInfeedJam.RT := 1; 
		
	(*------------------- Security Handling -------------------------------------*)
	
	IF g_HCfg.FeedManual THEN

		(*------------------- Configuration of Keys -------------------------------------*)
		(*Visu : View and Hide Layer*)
		g_HMI_MacConfig.ManualKeys.RT :=1; // Hide as default
		// View Layer if Button pressed

		IF g_HMI_MacConfig.ManualKeys.BTN = 1 AND g_LoadCFGDone THEN
			g_HMI_MacConfig.ManualKeys.RT:=0;
			ViewKeyConfigWindowTimer.IN := TRUE; 
		END_IF;
		
		
		// Hide Layer if closed Button pressed
		ViewKeyConfigWindowTimer.PT := UDINT_TO_TIME( 60000 ); // ! Min 
		ViewKeyConfigWindowTimer;		IF EDGENEG(USINT_TO_BOOL( g_HMI_MacConfig.ManualKeys.BTN)) OR ViewKeyConfigWindowTimer.Q  THEN 
			g_HMI_MacConfig.ManualKeys.RT:=1;
			ViewKeyConfigWindowTimer.IN:= FALSE; 
			g_HMI_MacConfig.ManualKeys.BTN :=0;
			// Save chages to File since no Save button is available on Main Screen
			g_ExternalFileManage.saveMcfg := TRUE;
		END_IF;

		
		// Visu - Correct Label of Param page 
		//IF g_HMIHandler.HeaderTextIndex = 603 THEN 
		IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageFeedType THEN
			//g_HMIHandler.HeaderTextIndex	:= 633 ; 
			;// SFX to be fixed
		END_IF	
	ELSE
		g_HMI_MacConfig.ManualKeys.RT :=1; // Hide as default		
	END_IF;

			
	IF ((g_ManualInletProcess.Common.State >= 40) AND (g_ManualInletProcess.Common.State <= 42) AND (NOT g_ManualInletProcess.ManualInletStarted)) THEN	
		g_HMI_MacConfig.DeleteDataRuntime := 0;			
		IF (g_HMI_MacConfig.ManualKeys.Reset = 1) THEN
  			g_HMI_MacConfig.ManualKeys.Reset	:= 0;
			IF (NOT g_ManualInletProcess.Inputs.GarmentOnInlet.Output) THEN
				g_ManualInletProcess.Common.State	:= MACHPROC_RUN_20;
				ResetNoRead							:= TRUE;
				g_HMI_MacConfig.DeleteDataRuntime	:= 1;
			END_IF
		END_IF
	ELSE
		g_HMI_MacConfig.DeleteDataRuntime := 1;
	END_IF


	(*Quick Bug fix in Visu menues -> will be removed at new plattform *)
	// Turn back to main page from machine overwiew when back button is pressed  
//	IF g_HMIHandler.CurrentPage = 2 AND g_HMIHandler.KeyPressed= 6 THEN
//		g_HMIHandler.KeyPressed := 1; 
//	END_IF;
//	IF g_HMIHandler.CurrentPage = 2 THEN
//		g_HMIHandler.Activated := 0; 
//	END_IF

//i := i+1;
//IF i > 3500 THEN
//	SYSreset(1, 1);
//END_IF	


//	// Test Function - Delete Later 
//	IF EDGEPOS (g_ManualInletProcess.Values.StartInletButton) THEN
//		FOR i:=0 TO 20 DO
//			g_test_steper.M_Inlet.Steps[i] := 0; 
//			g_test_steper.M_TConv.Steps[i] := 0; 
//		END_FOR;
//	END_IF;
//
//	IF g_test_steper.M_Inlet.curStep <> g_test_steper.M_Inlet.lastStep THEN
//		g_test_steper.M_Inlet.index := g_test_steper.M_Inlet.index+1; 
//		g_test_steper.M_Inlet.Steps[g_test_steper.M_Inlet.index ] := g_test_steper.M_Inlet.curStep ;
//		IF g_test_steper.M_Inlet.index >= 19 THEN
//			g_test_steper.M_Inlet.index:= 0; 
//		END_IF;
//	END_IF;
//	g_test_steper.M_Inlet.lastStep := g_test_steper.M_Inlet.curStep; 
//
//	IF g_test_steper.M_TConv.curStep <> g_test_steper.M_TConv.lastStep THEN
//		g_test_steper.M_TConv.index := g_test_steper.M_TConv.index+1; 
//		g_test_steper.M_TConv.Steps[g_test_steper.M_TConv.index ] := g_test_steper.M_TConv.curStep ;
//		IF g_test_steper.M_TConv.index >= 19 THEN
//			g_test_steper.M_TConv.index:= 0; 
//		END_IF;
//	END_IF;
//	g_test_steper.M_TConv.lastStep := g_test_steper.M_TConv.curStep; 


END_PROGRAM

