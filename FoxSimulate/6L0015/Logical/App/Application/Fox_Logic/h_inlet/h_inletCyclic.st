PROGRAM _CYCLIC
(* cyclic program *)

(*-------------------------------------------------------------------------------------

Author:   				Walid Mari 

FileName:				H_inlet.scr

Desription:				Hanger inlet to machine..

Watch debugg:			Name of important watch configurations.

History:
---------------------------------------------------------------------------------------*)

IF g_Core.System.Runtime.isInitDone AND (NOT g_HCfg.FeedManual) THEN
	(*Call Init*)
	IF NOT INIT_H_INLET THEN
		HangerInletInit;
		INIT_H_INLET := TRUE; 
	END_IF;

	(*Call Cycle*)
	HangerInlet;
	
END_IF;

	
END_PROGRAM

