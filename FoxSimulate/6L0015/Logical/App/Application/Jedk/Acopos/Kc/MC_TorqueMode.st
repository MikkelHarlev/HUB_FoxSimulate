FUNCTION_BLOCK MC_TorqueMode
	(*--------------------------------------------------------------------------------------------------------------------*)
	(* Implementation of MC_TorqueMode
		
		20-10-08 Kc.
	(*--------------------------------------------------------------------------------------------------------------------*)
	
	(* Set Nominal Torque *)
	NomTorque := 100;
	
	(* Jmp To Reset Torque *)
	IF Reset THEN
		Reset := FALSE;
		fbkStep := 200;
	END_IF
	
	(* Jmp To Stop Sequense *)
	IF EDGEPOS (Stop) AND NOT (fbkStep = 20) THEN
		fbkStep := 30;
	END_IF
	
	(* Reset Functionblock Step *)
	IF StopFbk THEN
		StopFbk := FALSE;
		NewSpeed := FALSE;
		fbkStep := 0;
	END_IF
	
	(* Delay Recall Funktion AX_ABS *)
	IF TDReCallABS >= 1 THEN
		MoveAbsolute.Execute := FALSE;
		TDReCallABS := TDReCallABS - 1;
	END_IF
	
	(*--------------------------------------------------------------------------------------------------------------------*)
	(* Functionblock step *)
	(*--------------------------------------------------------------------------------------------------------------------*)
	
	CASE fbkStep OF
		0:	(* Waiting For Execution Of Functionblock *)
			Clear := FALSE;
			Done := FALSE;
			MoveAbsolute.Execute := FALSE;
			SetTorquePos.Execute := FALSE;
			SetTorqueNeg.Execute := FALSE;
			(* Start Fb *)
			IF EDGEPOS (Execute) THEN
				(* Start Move (MoveAbsolute) *)
				MoveAbsolute.Axis 			:= Axis;
				MoveAbsolute.Position 		:= Position;
				MoveAbsolute.Velocity 		:= Velocity;
				MoveAbsolute.Acceleration 	:= Acceleration;
				MoveAbsolute.Deceleration 	:= Deceleration;
				MoveAbsolute.Direction 		:= mcSHORTEST_WAY;
				MoveAbsolute.Execute 		:= TRUE;
				TDReCallABS := 20;
				fbkStep := 10;
			END_IF
	
		10:	(* Wait For In Speed (Or Lagerror If In Speed Not Possible) *)
			MoveAbsolute.Execute := FALSE;
			Direction := ActualVelocity > 0;
			IF ActualVelocity > (Velocity - 10) OR ActualVelocity < ((Velocity - 10) *-1) THEN
				(* Set The Limited Torque For Positive And Negative Direction *)
				SetTorquePos.Axis 				:= Axis;
				SetTorquePos.ParID				:= 344;			(* CTRL Torque limiter: LIM_T1_POS override [%] - PARID 344 *)
				SetTorquePos.DataType			:= ncPAR_TYP_USINT;
				SetTorquePos.DataAddress 		:= ADR(Torque);
				SetTorquePos.Execute			:= TRUE;
				SetTorqueNeg.Axis 				:= Axis;
				SetTorqueNeg.ParID				:= 346;			(* CTRL Torque limiter: LIM_T1_NEG override [%] - PARID 346 *)
				SetTorqueNeg.DataType			:= ncPAR_TYP_USINT;
				SetTorqueNeg.DataAddress 		:= ADR(Torque);
				SetTorqueNeg.Execute			:= TRUE;
				fbkStep := 20;
			(* Check For Lag Limit *)
			ELSIF (LagError > LagLimit) OR (LagError < (LagLimit *-1)) THEN
				fbkStep := 30;
			(* Check For Done *)
			ELSIF MoveAbsolute.Done THEN
				Clear := TRUE;
				fbkStep := 40;
			END_IF
	
		20:	(* Wait For Limeted Torque Set *)
			IF (SetTorquePos.Done = TRUE AND SetTorqueNeg.Done = TRUE) THEN
				SetTorquePos.Execute := FALSE;
				SetTorqueNeg.Execute := FALSE;
				fbkStep := 30;
			END_IF
	
		30:	(* Check For Lag Limit -> Return To Stop Position *)
			IF ((LagError > LagLimit) OR (LagError < (LagLimit *-1)) OR Stop) AND (TDReCallABS = 0) THEN
				Stop := FALSE;
				MoveAbsolute.Position 		:= (ActualPosition - LagError);

					IF Direction THEN
						MoveAbsolute.Position 	:= (ActualPosition - Release);
					ELSE
						MoveAbsolute.Position 	:= (ActualPosition + Release);
					END_IF


				MoveAbsolute.Execute 		:= TRUE;
				fbkStep := 40;
			(* Check For Done *)
			ELSIF MoveAbsolute.Done AND NOT Stop THEN
				Clear := TRUE;
				fbkStep := 40;
			(* Set New Torque *)
			ELSIF NewValue THEN
				NewValue := FALSE;
				fbkStep := 10;
			ELSIF NewSpeed THEN	
				NewSpeed := FALSE;
				(* Start Move (MoveAbsolute) *)
				MoveAbsolute.Axis 			:= Axis;
				MoveAbsolute.Position 		:= Position;
				MoveAbsolute.Velocity 		:= Velocity;
				MoveAbsolute.Acceleration 	:= Acceleration;
				MoveAbsolute.Deceleration 	:= Deceleration;
				MoveAbsolute.Direction 		:= mcSHORTEST_WAY;
				MoveAbsolute.Execute 		:= TRUE;
				TDReCallABS := 20;
			END_IF
	
		40:	(* Wait For Done -> Set Torque Back To 100 % *)
			IF (MoveAbsolute.Done = TRUE) OR (MoveAbsolute.CommandAborted = TRUE) OR Clear THEN
				MoveAbsolute.Execute := FALSE;
				(* Set The Limited Torque To 100% For Positive And Negative Direction *)
				SetTorquePos.Axis 				:= Axis;
				SetTorquePos.ParID				:= 344;					(* CTRL Torque limiter: LIM_T1_POS override [%] - PARID 344 *)
				SetTorquePos.DataType			:= ncPAR_TYP_USINT;
				SetTorquePos.DataAddress 		:= ADR(NomTorque);
				SetTorquePos.Execute			:= TRUE;
				SetTorqueNeg.Axis 				:= Axis;
				SetTorqueNeg.ParID				:= 346;					(* CTRL Torque limiter: LIM_T1_NEG override [%] - PARID 346 *)
				SetTorqueNeg.DataType			:= ncPAR_TYP_USINT;
				SetTorqueNeg.DataAddress 		:= ADR(NomTorque);
				SetTorqueNeg.Execute			:= TRUE;
				fbkStep := 50;
			END_IF
	
		50:	(* Wait For Nominel Torque Done -> Start Release *)
			IF (SetTorquePos.Done = TRUE AND SetTorqueNeg.Done = TRUE) THEN
				SetTorquePos.Execute := FALSE;
				SetTorqueNeg.Execute := FALSE;
//				(* Check Direktion *)
//				IF NOT Clear THEN
//					IF Direction THEN
//						MoveAbsolute.Position 	:= (ActualPosition - Release);
//					ELSE
//						MoveAbsolute.Position 	:= (ActualPosition + Release);
//					END_IF
//					MoveAbsolute.Execute 		:= TRUE;
//					TDReCallABS := 20;
//				END_IF	
				fbkStep := 60;
			END_IF
	
		60:	(* Wait For Release Done *)
//			IF (MoveAbsolute.Done = TRUE) OR Clear THEN
//				MoveAbsolute.Execute := FALSE;
				Clear 	:= FALSE;
				Done 	:= TRUE;
				fbkStep	:= 100;
//			END_IF
	
		(*----------------------------------------------------------------------------------------------------------------*)
		(* Done *)
		(*----------------------------------------------------------------------------------------------------------------*)
	
		100: (* Keeping "Done" TRUE if "Execute" is TRUE - According To PLCOpen Interface *)
			IF (Execute = TRUE) THEN
				Done := TRUE;
			ELSE
				Done := FALSE;
				fbkStep := 0;
			END_IF
	
		(*----------------------------------------------------------------------------------------------------------------*)
		(* Reset *)
		(*----------------------------------------------------------------------------------------------------------------*)
	
		200: (* Set The Limited Torque To 100% For Positive And Negative Direction *)
			Done := FALSE;
			MoveAbsolute.Execute 		:= FALSE;
	
			SetTorquePos.Axis 				:= Axis;
			SetTorquePos.ParID				:= 344;					(* CTRL Torque limiter: LIM_T1_POS override [%] - PARID 344 *)
			SetTorquePos.DataType			:= ncPAR_TYP_USINT;
			SetTorquePos.DataAddress 		:= ADR(NomTorque);
			SetTorquePos.Execute			:= TRUE;
			SetTorqueNeg.Axis 				:= Axis;
			SetTorqueNeg.ParID				:= 346;					(* CTRL Torque limiter: LIM_T1_NEG override [%] - PARID 344 *)
			SetTorqueNeg.DataType			:= ncPAR_TYP_USINT;
			SetTorqueNeg.DataAddress 		:= ADR(NomTorque);
			SetTorqueNeg.Execute			:= TRUE;
			fbkStep 						:= 201;
	
		201: (* Wait For Nominel Torque Set *)
			IF (SetTorquePos.Done = TRUE AND SetTorqueNeg.Done = TRUE) THEN
				SetTorquePos.Execute		:= FALSE;
				SetTorqueNeg.Execute		:= FALSE;
				Done := TRUE;
				fbkStep := 100;
			END_IF
	END_CASE
	
	(*--------------------------------------------------------------------------------------------------------------------*)
	(* Error Handling *)
	(*--------------------------------------------------------------------------------------------------------------------*)
	
	IF (Execute = TRUE) THEN
		IF (SetTorquePos.ErrorID <> 0) THEN
			Status := SetTorquePos.ErrorID;
			Error  := SetTorquePos.Error;
			SetTorquePos.Execute := FALSE;
		ELSIF (SetTorqueNeg.ErrorID <> 0) THEN
			Status := SetTorqueNeg.ErrorID;
			Error  := SetTorqueNeg.Error;
			SetTorqueNeg.Execute := FALSE;
		ELSIF (MoveAbsolute.ErrorID <> 0) THEN
			Status := MoveAbsolute.ErrorID;
			Error  := MoveAbsolute.Error;
			MoveAbsolute.Execute := FALSE;
		END_IF
	ELSE
		Status := 0;
		Error  := 0;
	END_IF
	
	IF (Error = TRUE) THEN
		fbkStep := 0;
	END_IF
		
	(*--------------------------------------------------------------------------------------------------------------------*)
	(* Functionblock Calls *)
	(*--------------------------------------------------------------------------------------------------------------------*)
	
		MoveAbsolute();
		SetTorquePos();
		SetTorqueNeg();
	
	(*--------------------------------------------------------------------------------------------------------------------*)
	(* End *)
	(*--------------------------------------------------------------------------------------------------------------------*)
	
END_FUNCTION_BLOCK