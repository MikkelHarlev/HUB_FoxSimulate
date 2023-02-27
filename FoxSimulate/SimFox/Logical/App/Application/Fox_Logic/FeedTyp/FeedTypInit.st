(********************************************************************
 * COPYRIGHT -- IT
 ********************************************************************
 * Program: FeedTyp
 * File: FeedTypInit.st
 * Author: mariw
 * Created: June 14, 2011
 ********************************************************************
 * Implementation of program FeedTyp
 ********************************************************************)

PROGRAM _INIT
// Reset Alarm of Oiption "Feed manual Changed" 
	g_MainAlarms.Alarm[10] := FALSE; 	
	g_HMI_MacConfig.ManualKeys.RT :=1;
	PageFeedType := LookupPageID(603,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);

	(*Hide Sim Data*)
	g_Sim.RT := 1; 
END_PROGRAM
