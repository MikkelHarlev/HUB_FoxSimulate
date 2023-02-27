(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: XtremeHeavy
 * File: XtremeHeavyCyclic.st
 * Author: munchp
 * Created: September 28, 2015
 ********************************************************************
 * Implementation of program XtremeHeavy
 ********************************************************************)

PROGRAM _CYCLIC

// ---------------------------------------
// Init
// ---------------------------------------

	IF NOT g_HCfg.XtremeHeavy THEN
		g_XtremeHeavy.hideHMI := 1;
		RETURN;
	ELSE
		g_XtremeHeavy.hideHMI := 0;
	END_IF;
	HMIHideXtremeHeavy			:= 1; //PWC: Stuff on screen that is not used yet or just not used
	
// ---------------------------------------
// HMI Test
// ---------------------------------------
	
	rToggleTime := 1500;
	
	Toggle(Set := NOT Toggle.Out, Delay := rToggleTime, Comp := 0, CntAdr := ADR(g_MilliSeconds));
	IF Toggle.Trig THEN
		rToggle := NOT rToggle;
	END_IF;
	
	g_XtremeHeavy.Guideplates 		:= USINT_TO_BOOL(SEL(XtremeTest.Guideplates AND rToggle, 0, 1));
	g_XtremeHeavy.Templates			:= USINT_TO_BOOL(SEL(g_TestRaiseBlades AND rToggle, 0, 1)); 
	g_XtremeHeavy.Gap				:= USINT_TO_BOOL(SEL(XtremeTest.Gap AND rToggle, 0, 1)); 
	g_XtremeHeavy.RaiseStackerBelt	:= USINT_TO_BOOL(SEL(XtremeTest.RaiseStackerBelt AND rToggle, 0, 1)); 
	g_XtremeHeavy.SlackStackerBelt	:= USINT_TO_BOOL(SEL(XtremeTest.SlackStackerBelt AND rToggle, 0, 1)); 

END_PROGRAM
