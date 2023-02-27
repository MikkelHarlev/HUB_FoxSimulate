FUNCTION_BLOCK FB_MapLaneCombination
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Author:			Jensen Denmark
	
		Filename:    	MapLaneCombination.src
	
		Description: 	Maps different lane coupling combinations. From one MaxLane to another
							X-Lanes 	-> 1, 2, X-Lanes
	
		Dependences:	JEDK V 0.38+
							InUse 
	
		Interfaces:		In 	
							MapLaneFunction_Type_Adr		UDINT		Adress of MapLaneFunction_Type, with In-/Output variables
							MapLaneFunction.MasterLaneMode	USINT		Machine Lane Mode		

							MapLaneFunction_Type.In :
							  	.In.MasterCouplingClass		USINT		Machines recipe coupling class
							  	.In.MasterLaneNo			USINT		Machines Lane number
							  	.In.CurrentMode				USINT		Mode, witch the machine's lane combinations is to be mapped to.
							  	
						Out 
							ErrorCode						USINT		Functions Error code							
							ErrorString						STRING		Description of Error code
							MapLaneFunction_Type.Out :						
								.Out.La						USINT		Mapped Lane number
								.Out.Info					USINT		Mapped coupling class
						
	
		History:		16-09-2006		V1.00		MHA
						11-07-2018		V1.01		BKY		MasterLaneMode is now an input to the function and has been removed from .In datatype.
															Enables number of lanes to be updated in cyclic similar to SetReset function.
																									  				      *)
	(*----------------------------------------------* cyclic program *----------------------------------------------------*)

	IF Map_Type_Adr <> oldMap_Type_Adr THEN
		InitDone := FALSE;
	END_IF
	oldMap_Type_Adr := Map_Type_Adr;
	
	// MasterLaneMode change..? 
	IF MasterLaneMode <> MasterLaneModeOld THEN
		// Reinitialize init
		InitDone := FALSE;
	END_IF
	MasterLaneModeOld := MasterLaneMode;

	// Initialize
	IF NOT InitDone THEN
	
		// Input Type
		IF Map_Type_Adr = 0 THEN
			ErrorCode := 10;
			ErrorString := 'Null Pointer Map_Type_Adr';
			RETURN;
		END_IF
		pMap_Type ACCESS Map_Type_Adr;
	
		// Max Lane
		MasterMaxLane := MasterLaneMode;
		IF MasterMaxLane = 31 THEN MasterMaxLane := 3; END_IF;
		IF MasterMaxLane = 51 THEN MasterMaxLane := 5; END_IF;
		IF MasterMaxLane = 0 OR MasterMaxLane > 6 THEN
			ErrorCode := 20;
			ErrorString := 'Mode = 0 or > 6';
			RETURN;
		END_IF
	
		// Initialize InUse
		MasterInUse.Mode := MasterLaneMode;
		MasterInUse_Function ( InUse_Type_Adr := ADR(MasterInUse) );
		IF MasterInUse_Function.ErrorCode > 0 THEN
			ErrorCode	:= 30;
			ErrorString := MasterInUse_Function.ErrorString;
			RETURN;
		END_IF
	
		InitDone := TRUE;
	END_IF
	
	// Same lanemodes
	IF pMap_Type.In.CurrentMode = MasterLaneMode THEN
		pMap_Type.Out.La := pMap_Type.In.MasterLaneNo;
		pMap_Type.Out.Info := pMap_Type.In.MasterCouplingClass;
	
	// One lane at x-lane master mode
	ELSIF pMap_Type.In.CurrentMode = 1 THEN
		pMap_Type.Out.La := 0;
		pMap_Type.Out.Info := 0;
	
	// Two lane at master lanes > 2
	ELSE
		MasterInUse.Mode := MasterLaneMode;
		MasterInUse.CouplingClass := pMap_Type.In.MasterCouplingClass;
		MasterInUse_Function();
	
		pMap_Type.Out.La := 0;
		pMap_Type.Out.Info := 0;
		IF MasterInUse.SteeringLane.Count = 1 THEN
			pMap_Type.Out.Info := 1;
		ELSIF pMap_Type.In.MasterLaneNo >= (MasterMaxLane / 2) THEN
			pMap_Type.Out.La := 1;
		END_IF
	END_IF
	
END_FUNCTION_BLOCK