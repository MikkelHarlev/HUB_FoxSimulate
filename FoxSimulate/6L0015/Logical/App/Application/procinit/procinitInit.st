PROGRAM _INIT
(* init program *)
MAX_NUMBER_OF_MACHINE_PROCESSES := 14;

FOR MachineIndex := 1 TO MAX_NUMBER_OF_MACHINE_PROCESSES DO
	g_MachineManager[MachineIndex].StatusData.Id		:= MachineIndex;
	g_MachineManager[MachineIndex].Name					:= '';
	g_MachineManager[MachineIndex].Run					:= FALSE;
	g_MachineManager[MachineIndex].StatusData.State		:= 0;
	g_MachineManager[MachineIndex].StatusData.ErrorCode	:= 0;
END_FOR


//##########################################################################
// Must be set to max number od stacker groups is then
// adjusted when g_HCfg.NumberOfStackers is read in the cyclic part.
//##########################################################################

NUMBER_OF_STACKERGROUPS := 5;



// Set index numbers for the machine manager..

//g_HangerInletProcess.Common.MachineManagerIndex				:= 1;
//g_ManualInletProcess.Common.MachineManagerIndex				:= 1;
g_HangerOpenerProcess.Common.MachineManagerIndex 				:= 2;
//g_ManualInfeedProcess.Common.MachineManagerIndex			 	:= 2;
g_TopConveyorProcess.Common.MachineManagerIndex					:= 3;
g_LateralProcess.Common.MachineManagerIndex						:= 4;
g_CrossFoldAProcess.Common.MachineManagerIndex					:= 5;
g_CrossFoldBProcess.Common.MachineManagerIndex					:= 6;
// To make a dynamic inedxing number of stacker groups...
FOR i := 1 TO NUMBER_OF_STACKERGROUPS DO
	g_StackerProcess[i].Common.MachineManagerIndex				:= i + 6;	
END_FOR	
g_OutletProcess.Common.MachineManagerIndex						:= g_StackerProcess[NUMBER_OF_STACKERGROUPS].Common.MachineManagerIndex + 1;
g_DeliveryProcess.Common.MachineManagerIndex					:= g_OutletProcess.Common.MachineManagerIndex + 1;
g_DeliveryProcess2.Common.MachineManagerIndex					:= g_DeliveryProcess.Common.MachineManagerIndex + 1;
g_MiniJenwayProcess.Common.MachineManagerIndex					:= g_DeliveryProcess2.Common.MachineManagerIndex + 1;
IF g_HCfg.FeedManual THEN
	g_ManualInletProcess.Common.MachineManagerIndex				:= 1;
	g_HangerInletProcess.Common.MachineManagerIndex				:= g_MiniJenwayProcess.Common.MachineManagerIndex + 1;
ELSE
	g_HangerInletProcess.Common.MachineManagerIndex				:= 1;
	g_ManualInletProcess.Common.MachineManagerIndex				:= g_MiniJenwayProcess.Common.MachineManagerIndex + 1;
END_IF
END_PROGRAM

