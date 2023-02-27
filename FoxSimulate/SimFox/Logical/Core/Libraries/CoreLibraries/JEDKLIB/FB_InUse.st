FUNCTION_BLOCK FB_InUse
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Author:			Jensen Denmark
	
		Filename:    	InUse.src
	
		Description: 	Combination of lane coupling
	
		Dependences:	Filter_Coupling	
	
		Interfaces:		In:
							Mode
						  	CouplingClass
						Out:						
							InUse_Type as pointer
						
	
		History:		16-09-2006		V1.00.0		MHA				Created
						24-09-2007		V1.08.0		MHA				.Lanes,	.LanesAll Offset changed from 0 to 1
						16-11-2007		V1.10.0		MHA,AHO,SKR		Renamed parameters
						
																														  *)
	(*----------------------------------------------* cyclic program *----------------------------------------------------*)
	
	
	(* The function executes when a change in CouplingClass or Mode is detected or manually set by the Set command *)
	
	(*--------------------------------------------------------------------------------------------------*)
	(*	Description:																					*)
	(*--------------------------------------------------------------------------------------------------*)
	(*
			Calculates steering lanes based on number of lanes and coupling class, as used in jedk Filter_Coupling, BlowPipe, etc.
			The function is based on offset 0, exept for .Lanes and .SteeringLane.LanesCoupled[]
			
		In:
				InUse_Type_Adr					:		Adress of the InUse_Type 
				InUse.Mode					:		Number of lanes, mode for special lane combination
				InUse.CouplingClass			:		Lane coupling (info)
				InUse.Set					:		Manually executes the function. Note! Not necessary unless written directly to InUse_Type's output variables. 
													Using continously Set command will only take up more system resources
	
		Out:	
				InUse.Lane.Active[]				:		Is steering lane
				InUse.Lanes 				:		Number of active steering lanes, offset 1 !
				InUse.SteeringLane.LanesCoupled[]			:		Number of lanes part of each steering lane, offset 1 !
				InUse.SteeringLane.No[]		:		Lane number for steering lanes.
				InUse.Lane.SteeringLane[]	:		Steering lane number for all lanes, including inactive.	
				InUse.IndexSteering[]		:		Steering Lane Number Index for actual Lane number.
													Note! Only index of steering lane numbers are relavant and so this paramater should only be accessed from those numbers.
				
			-------------------- Example   4 Lane machine, coupled in 2-Lane operation 1*2 , 3*4   --------------------
		In:
							(Init program)			
				InUse.Mode := g_MaxLane;			( = 4 )
				InUse_Function	( InUse_Type_Adr := ADR(InUse) );			
																	
							(Cyclic program)
				InUse.CouplingClass := 	g_CouplingClass;	( = 5 )
				InUse_Function();	
		
		Out:		
				InUse.Lane.Active[0]				=	FALSE				(Inactive lane)
				InUse.Lane.Active[1]				=	TRUE				(Active lane)
				InUse.Lane.Active[2]				=	TRUE				(Active lane)
				InUse.Lane.Active[3]				=	FALSE				(Inactive lane)
				
				InUse.SteeringLane.Count			=	2					(Machine is running in 2 lane operation)		Offset 1
		
				InUse.SteeringLane.LanesCoupled[0]	=	2					(2 lanes are coupled with first steering lane)	Offset 1
				InUse.SteeringLane.LanesCoupled[1]	=	2					(2 lanes are coupled with second steering lane)	Offset 1
	
				InUse.SteeringLane.No[0]		=	1					(Lane 2 is first active steering lane)
				InUse.SteeringLane.No[1]		=	2					(Lane 3 is second active steering lane)
		
				InUse.Lane.SteeringLane[0]	=	1					(Lane 1 is coupled with lane 2)
				InUse.Lane.SteeringLane[1]	=	1					(Lane 2 is coupled with lane 2)
				InUse.Lane.SteeringLane[2]	=	2					(Lane 3 is coupled with lane 3)
				InUse.Lane.SteeringLane[3]	=	2					(Lane 4 is coupled with lane 3)
				
				InUse.Lane.IndexSteering[0]	=   0					   (Not relavant)
				InUse.Lane.IndexSteering[1]	=	0					(This Steering Lane (Machine lane number 2) is Lane Number 1 of this Two lane operation )
				InUse.Lane.IndexSteering[2]	=	1					(This Steering Lane (Machine lane number 3) is Lane Number 2 of this Two lane operation )
				InUse.Lane.IndexSteering[3]	=   0					   (Not relavant)
				 ...													...
	*)
	
	IF InUse_Type_Adr <> oldInUse_Type_Adr OR Coupling_Function.MemAdr <> ADR(Coupling) OR Coupling.CounterAdr[0] <> ADR(Counter) THEN
		InitDone := FALSE;
	END_IF
	oldInUse_Type_Adr := InUse_Type_Adr;
	
	// Initialize 
	IF NOT InitDone THEN
		IF InUse_Type_Adr = 0 THEN
			ErrorCode := 10;
			ErrorString := 'InUse Type_Adr = 0';
			RETURN;
		END_IF
		pInUse_Type ACCESS InUse_Type_Adr;
	
		pInUse_Type.SteeringLane.Count := 1;
		Coupling_Function.MemAdr := ADR(Coupling);
		Coupling.CounterAdr[0] := ADR(Counter);
		Coupling.On := TRUE;
		Coupling_Function(InitDone := FALSE);
		IF Coupling_Function.ErrorCode > 0 THEN
			ErrorCode := 11;
			ErrorString := Coupling_Function.ErrorString;
			RETURN;
		END_IF
	
		InitDone := TRUE;
	END_IF
	
	// Change in lane coupling 
	IF (pInUse_Type.CouplingClass <> OldCouplingClass) OR (pInUse_Type.Mode <> OldMode) THEN
		OldMode := pInUse_Type.Mode;
		OldCouplingClass := pInUse_Type.CouplingClass;
	
		MaxLane := pInUse_Type.Mode;
		IF pInUse_Type.Mode = 31 THEN MaxLane := 3; END_IF
		IF pInUse_Type.Mode = 51 THEN MaxLane := 5; END_IF
	
		IF (MaxLane = 0) OR (MaxLane > 6) THEN
			pInUse_Type.Mode := 1;
			ErrorCode := 20;
			ErrorString := 'InUse Mode = 0 or > 6';
			RETURN;
		ELSE
			ErrorCode := 0;
			ErrorString := '';
		END_IF
	
		pInUse_Type.Set := TRUE;
	END_IF
	
	// Do combination 
	IF pInUse_Type.Set THEN
		pInUse_Type.Set := FALSE;
	
		// Initialize 
		FOR La := 0 TO 5 DO
			pInUse_Type.Lane.Active[La] := FALSE;
			pInUse_Type.SteeringLane.LanesCoupled[La] := 0;
			Coupling.In[La]	 := TRUE;
		END_FOR
		pInUse_Type.SteeringLane.No := pInUse_Type.SteeringLane.LanesCoupled;
		pInUse_Type.Lane.SteeringLane := pInUse_Type.SteeringLane.LanesCoupled;
		pInUse_Type.Lane.IndexSteering := pInUse_Type.SteeringLane.LanesCoupled;
		Coupling.Mode := pInUse_Type.Mode;
		Coupling.Info := pInUse_Type.CouplingClass;
	
		Counter := Counter + 1;
		Coupling_Function();
	
		// Number of steering lanes
		//		- Lanes
		//		- SteeringLane.No
		//		- Lane.IndexSteering
		
		pInUse_Type.SteeringLane.Count := 0;
		FOR La := 0 TO MaxLane - 1 DO
			pInUse_Type.Lane.Active[La] := Coupling.Out[La];
			pInUse_Type.SteeringLane.No[La] := 0;
			IF pInUse_Type.Lane.Active[La] THEN
				pInUse_Type.SteeringLane.No[pInUse_Type.SteeringLane.Count] := La;
				pInUse_Type.Lane.IndexSteering[La] := pInUse_Type.SteeringLane.Count;
				pInUse_Type.SteeringLane.Count := pInUse_Type.SteeringLane.Count + 1;
			END_IF
		END_FOR
	
		// Function error lanecombination, InUse- or Filter_Coupling Function 
		IF pInUse_Type.SteeringLane.Count = 0 THEN
			ErrorCode := 30;
			ErrorString := 'InUse SteeringLane.Count = 0';
			RETURN;
		END_IF
	
		FOR La := 0 TO 5 DO
			Coupling.In[La] := FALSE;
			pInUse_Type.SteeringLane.LanesCoupled[La] := 0;
		END_FOR
		pInUse_Type.Lane.SteeringLane := pInUse_Type.SteeringLane.LanesCoupled;
	
		// Steering lane for inactive lanes, 
		//		- SteeringLane.LanesCoupled
		//		- Lane.SteeringLane
		
		La := 0;
		FOR Cnt := 0 TO pInUse_Type.SteeringLane.Count - 1 DO
			Coupling.In[ pInUse_Type.SteeringLane.No[Cnt] ] := TRUE;
	
			Counter := Counter + 1;
			Coupling_Function();
	
			// Couple steering lane number to inactive lanes 
			REPEAT
				IF Coupling.OutAll[La] THEN
					pInUse_Type.SteeringLane.LanesCoupled[Cnt] := pInUse_Type.SteeringLane.LanesCoupled[Cnt] + 1;
					pInUse_Type.Lane.SteeringLane[La] := pInUse_Type.SteeringLane.No[Cnt];
				END_IF
				La := La + 1;
			UNTIL ( NOT Coupling.OutAll[MIN(La, SIZEOF(Coupling.OutAll) / SIZEOF(Coupling.OutAll[0]) - 1)] ) OR ( La >= MaxLane ) END_REPEAT
	
			Coupling.In[ pInUse_Type.SteeringLane.No[Cnt] ] := FALSE;
		END_FOR
	
	END_IF
END_FUNCTION_BLOCK