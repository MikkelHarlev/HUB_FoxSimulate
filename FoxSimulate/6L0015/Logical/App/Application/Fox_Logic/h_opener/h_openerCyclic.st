PROGRAM _CYCLIC
(* cyclic program *)

(*-------------------------------------------------------------------------------------

Author:   				PO Nilsson

FileName:				H_opener.scr

Desription:				Hanger opener and reset, and empty hanger returner..

Information:			If it's a Combi hanger the hanger reset/trouser opener should be connected to the g_HangerOpenerProcess.HangerResetLower output...
						Hammer should be the hammer...


History:
10-10-14				V1.05.6	PO Nilsson		Bug fix for long overalls from turn around covering the Photocell in plate.. 
10-08-10				V1.05.5	PO Nilsson		New error case, garment can be dropped when entering inlet and the create a timeout in Top conveyor.
												Then the deloading unit can't travel down, so a alarm is created in the Hanger opener..
10-04-28				V1.05.4	PO Nilsson		Bug fix, if we got reading error in Inlet task, we should not go back in state _30.
10-03-25				V1.05.3	PO Nilsson		Fixed pajamas opener..	
10-03-23				V1.05.2	PO Nilsson		Added timer for Pajamas opener..
10-03-18				V1.05.1	PO Nilsson		Pajamas opener for Lobster...
10-03-18				V1.05.0	PO Nilsson		Fox 600...
10-03-08				V1.04.3	PO Nilsson		Changed name in the inputs for the lift..
10-03-05				V1.04.2	PO Nilsson		Moved the HangerInDU alarm to check when ClampBlock is released to get better timing..
10-03-03				V1.04.1	PO Nilsson		Changed filter on HangerInDo photocell...
												Removed log in _99 was continous 	
10-02-17				V1.04.0	PO Nilsson		Added new input to check that hanger is in Du when on top position...
10-02-08				V1.03.7	PO Nilsson		Upper Horn is set to true when error..
10-02-04				V1.03.6	PO Nilsson		Now the start of hanger reset is triggerd when the lift goes up, and then we just use the 
												GarmentOnHanger photocell when lift is up to trigger alarm...
10-02-03				V1.03.5 PO Nilsson		Changed name on X_InletHorizontalDetection to IBHorizontal to make IO Description to work..
10-01-28				V1.03.4	PO Nilsson		We moved the hanger in plate photocell to a better place, but it could miss empty hangers.
												So I added a flag to remeber flank when goes into plate...
10-01-27				V1.03.3	PO Nilsson		Moved error reset of outputs from _98 to _99 did not work in _98 why...
10_01_25				V1.03.2	PO Nilsson		Speed up of hand over with Turn around, a good thing...
10-01-24				V1.03.1	PO Nilsson		Added watchdogs in startup 2,3 this is not handled by library function..
												If hanger opener is in waiting _25 and we get a E-stop we need to sync hanger block again...
												Cleard some E-stop problems...
10-01-12				V1.03.0	PO Nilsson		"Data" member was removed from g_AutoProgramData structure
09-12-08				V1.02.9	PO Nilsson		Cleaned up comments and removed remarked source..
09-12-02				V1.02.8	PO Nilsson		HardCoded the Next hanger time, if changed it was dangerous...
9-11-22				V1.02.7 PO Nilsson		Bug fix for the Hanger out error..
09-11-16				V1.02.6	PO Nilsson		Name change on some outputs, small fixes according to Ben.
												Pyjamas button and function...
09-11-13				V1.02.5	PO Nilsson		Stop TopConveyor when we have the Hanger out error in Hanger opener...
09-11-13				V1.02.4	PO Nilsson		Bug fix for the Combi hanger HangerResetLower output was reset at same time as Hammer..
09-11-02				V1.02.3 PO Nilsson		Combi hanger opening logic...
09-10-27				V1.02.2	PO Nilsson		Removed machine manager index from init part of Hanger opener..
09-10-01				V1.02.1 PO Nilsson		Bug fixes on site Holbaek
09-09-08				V1.02.0	PO Nilsson		Removed [0..1] records in AutoProgram type
09-08-31				V1.01 	PO Nilsson		To avoid E-stop problems, remove hanger out of garment before stop...
09-08-13				V1.00.	1 SFX			Removed watchdog timer set in start up. This caused lock-up. 
09-03-09				V0.00 	PO Nilsson		First edition...
---------------------------------------------------------------------------------------*)

IF g_Core.System.Runtime.isInitDone AND (NOT g_HCfg.FeedManual) THEN
	(*Call Init*)
	IF NOT INIT_OPENER THEN
		HangerOpenerInit;
		INIT_OPENER := TRUE; 
	END_IF;

	(*Call Cycle*)
	HangerOpener;
	
END_IF;

END_PROGRAM

