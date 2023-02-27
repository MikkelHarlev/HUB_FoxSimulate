(********************************************************************
 * COPYRIGHT -- IT
 ********************************************************************
 * Program: stacker
 * File: ACTIONS.st
 * Author: mariw
 * Created: October 11, 2010
 ********************************************************************
 * Implementation of program stacker
 ********************************************************************) 

(*Add a new action to your IEC program or library*)
ACTION JamBugFix: 


	FOR StackerGroupBugFix := 1 TO NUMBER_OF_STACKERGROUPS DO
		IF NOT g_StackerProcess[StackerGroupBugFix].Common.AlarmList.Alarm[2] AND 
			g_StackerProcess[StackerGroupBugFix].Common.AlarmList.Ack[2] THEN				
			g_StackerProcess[StackerGroupBugFix].Common.State := MACHPROC_INIT_0;
			g_StackerProcess[StackerGroupBugFix].Common.OldState := MACHPROC_INIT_0;
			g_OutletProcess.Common.State := 0; 
			g_OutletProcess.Common.OldState := 0; 
			g_OutletProcess.Common.Next.TransferStatus := 0; 
			g_OutletProcess.Common.Previous.TransferStatus := 0; 
		
		END_IF;
	END_FOR

END_ACTION
