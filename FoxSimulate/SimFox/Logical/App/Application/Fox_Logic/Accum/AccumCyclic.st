
(*-------------------------------------------------------------------------------------

Author:   				PO Nilsson.

Desription:				Accum stop or extra stepfeeder infront of the machine.

History:
10-04-01				V1.01.1	PO Nilsosn				InletFull direct to input and not filtered output.
														InletActive alwasy true when machine running..
09-08-27				V1.01.0 PO Nilsson				Machine configuration for timers.		
09-06-22				V1.00.0 PO Nilsson				First edition.

---------------------------------------------------------------------------------------*)
PROGRAM _CYCLIC



IF g_Core.System.Runtime.isInitDone AND NOT g_HCfg.FeedManual THEN
	(*Call Init*)
	IF NOT INIT_ACCUM THEN
		h_AccumInit;
		INIT_ACCUM := TRUE; 
	END_IF;

	(*Call Cycle*)
	h_Accum;
	
END_IF;




END_PROGRAM
