(*-------------------------------------------------------------------------------------

Author:   				PO Nilsson

FileName:				MetriconIOCyclic.st

Desription:				I/O connection to Metricon..




History:

10-01-24				V0.01.0		PO Nilsson		Removed the function it is no placed in the HangerInlet part...		
09-11-19				V0.00.0 	PO Nilsson		First edition...
---------------------------------------------------------------------------------------*)

PROGRAM _CYCLIC


// Using Direct IO 
IF g_MCfg.Metricon.UseExternalStatus = CONNECTION_TYPE_NONE_0 THEN
	;
END_IF



END_PROGRAM
