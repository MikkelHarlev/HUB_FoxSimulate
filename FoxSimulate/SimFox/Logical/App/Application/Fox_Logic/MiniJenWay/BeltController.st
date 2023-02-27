(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: MiniJenWay
 * File: BeltController.st
 * Author: jspernil
 * Created: June 02, 2009
 ********************************************************************
 * Implementation of program MiniJenWay
 ********************************************************************) 

(*TODO: Add your comment here*)

FUNCTION BeltController


BeltData.FilterPhotocell.Input 			:= BeltData.Input.Photocell;
BeltData.FilterPhotocell.OnDelay		:= 1; 
BeltData.FilterPhotocell.OffDelay 		:= 5;

BeltData.OffdelayPhotocell.Input		:= BeltData.Input.Photocell;
BeltData.OffdelayPhotocell.OnDelay		:= 1;




//BeltData.Timers.MaxRunTime				:= 4000;	
//BeltDate.Timers.WaitAfterRXTimer			:= 2000;

FullReg(BeltData.FilterPhotocell);
FullReg(BeltData.OffdelayPhotocell);


CASE BeltData.State OF
	
	(* Wait for command *)
	BELT_STATE_IDLE_0:
	
		(* Previous belt wants to unload *)
		IF NOT BeltData.OffdelayPhotocell.Output AND BeltData.Input.PrevToUnload THEN
			BeltData.Timers.MaxRunTimer := BeltData.CurTimer;
			BeltData.State 				:= BELT_STATE_RECIVING_5;
		END_IF			
		
		(* Unload to next belt *)
		IF BeltData.FilterPhotocell.Output AND BeltData.Input.NextIsReady THEN
			BeltData.Timers.MaxRunTimer 	:= BeltData.CurTimer;
			BeltData.Output.WantToUnload	:= TRUE;
			BeltData.State 					:= BELT_STATE_UNLOADING_10;
		ELSE
			BeltData.Output.WantToUnload	:= FALSE;
		END_IF
	
		(* Run start up state first to detect any items... *)	
		IF NOT BeltData.InitDone THEN
  			BeltData.State := BELT_STATE_STARTUP_20;
		END_IF		
		
		(* Tell prev we are ready to recive *)
		BeltData.Output.IsReady := NOT BeltData.OffdelayPhotocell.Output AND BeltData.InitDone;
		
	
	
	BELT_STATE_RECIVING_5:
	
		BeltData.Output.Motor 	:= TRUE;
		//BeltData.Output.IsReady := FALSE;
		
		// Item is at front
		IF BeltData.FilterPhotocell.Output THEN
  			BeltData.Output.Motor 	:= FALSE;
			BeltData.State 			:= BELT_STATE_IDLE_0;
		END_IF		
		
		// Time out
		IF ElapsedMsTime(BeltData.CurTimer, BeltData.Timers.MaxRunTimer) >= BeltData.Timers.MaxRunTime THEN	
			BeltData.Output.Motor 	:= FALSE;
			BeltData.State 			:= BELT_STATE_IDLE_0;
		END_IF
	
	
	BELT_STATE_UNLOADING_10:
	
		BeltData.Output.Motor 	:= TRUE;
		BeltData.Output.IsReady	:= FALSE;
	
		// Item is at front on next belt
		//IF NOT BeltData.Input.NextIsReady THEN
		IF NOT BeltData.FilterPhotocell.Output THEN	
  			BeltData.Output.Motor 				:= FALSE;
			BeltData.Output.WantToUnload		:= FALSE;
			BeltData.Timers.WaitAfterRXTimer 	:= BeltData.CurTimer; 
			BeltData.State 						:= BELT_STATE_IDLE_0;
		END_IF		
	
		// Time out
		IF ElapsedMsTime(BeltData.CurTimer, BeltData.Timers.MaxRunTimer) >= BeltData.Timers.MaxRunTime THEN	
		//IF ElapsedMsTime(BeltData.CurTimer, BeltData.Timers.MaxRunTimer) >= 500 THEN	
			BeltData.Output.Motor 				:= FALSE;
			BeltData.Timers.WaitAfterRXTimer 	:= BeltData.CurTimer; 
			BeltData.State 						:= BELT_STATE_IDLE_0;
		END_IF
	
		// If belt is unloading we can load from Previous...
	//	BeltData.Output.IsReady := TRUE;

	BELT_STATE_WAIT_AFTER_RX_12:
		
		IF ElapsedMsTime(BeltData.CurTimer, BeltData.Timers.WaitAfterRXTimer) >= 2000 THEN	
			BeltData.State 			:= BELT_STATE_IDLE_0;
		END_IF
	
	


	
	BELT_STATE_STARTUP_20:
	
		// Run motor until Photocell or Timeout...
		BeltData.Output.Motor := NOT BeltData.FilterPhotocell.Output;
	
		IF (ElapsedMsTime(BeltData.CurTimer, BeltData.Timers.MaxRunTimer) >= BeltData.Timers.MaxRunTime) OR NOT BeltData.Output.Motor THEN	
			BeltData.Output.Motor 	:= FALSE;
			BeltData.InitDone		:= TRUE;
			BeltData.State 			:= BELT_STATE_IDLE_0;
		END_IF

	
END_CASE	



BeltController := BeltData.State;		(* Return state value *)


END_FUNCTION
