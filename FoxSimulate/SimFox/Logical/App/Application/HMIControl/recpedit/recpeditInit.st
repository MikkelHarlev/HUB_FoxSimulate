PROGRAM _INIT
(* init program *)
(*######################*)
(* Options hardcoded    *)
(*######################*)
(*g_HCfg.Vacuum;*)								(* Vacuum *)



	g_HCfg.CrossFoldingKnife;					(* Knife *)
	g_HCfg.CrossFoldingGapAdjust;				(* Adjustable Wide CrossA *)
	g_HCfg.NumberOfStackers;						(* Number of Stackers *)
	g_HCfg.IndexingConveyorsWithPushOff;			(* RollOff with Motor *)
	g_HCfg.CrossConveyor;						(* CrossConveyor unidirektional *)
	g_HCfg.CrossConveyorFotoSensorEnd;			(* Fotocell at end of CrossConveyor *)
	g_HCfg.DeliveryConveyor;						(* DeliveryConveyor *)
	g_HCfg.DeliveryConveyorFotoSensorEnd;		(* Fotocell at end of DeliveryConveyor *)

	StateOnEntryDone := FALSE;
	ElementsInArray := MAX_NUMBER_OF_CATEGORIES;
	SyncRecipe 			:= TRUE;




	g_OperatorCommand.NewFoldProgram 	:= g_Machine.Program;
	FoldProgramList.MaxFoldPrograms 	:= MAX_NUMBER_OF_CATEGORIES;
	//MAX_NUMBER_OF_FOLDPROGRAMS 			:= MAX_NUMBER_OF_CATEGORIES;



	FOR i := 0 TO FoldProgramList.MaxFoldPrograms-1 DO
		itoa(i+1, ADR(FoldProgramList.IdString[i]));
	END_FOR


END_PROGRAM

