(********************************************************************
 * COPYRIGHT -- IT
 ********************************************************************
 * Program: m_inlet
 * File: m_inletCyclic.st
 * Author: mariw
 * Created: May 26, 2011
 ********************************************************************
 * Implementation of program m_inlet
 ********************************************************************)

PROGRAM _CYCLIC

	IF g_MCfgInitDone AND g_Core.System.Runtime.isInitDone AND g_HCfg.FeedManual THEN
	
		(*Call Init*)
		IF NOT INIT_M_INLET THEN
			ManualInletInit;
			INIT_M_INLET := TRUE; 
		END_IF;

		(*Call Cycle*)
		ManualInlet;

		(*For Testing*)
		//Sim;
	END_IF;

	// HW- Check deactivated !
	X_ManualFeedSecurity_SWT:= TRUE;
END_PROGRAM

