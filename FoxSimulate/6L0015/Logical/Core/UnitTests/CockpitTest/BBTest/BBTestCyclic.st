PROGRAM _CYCLIC


CASE step OF 
		5: (* Sets the start CustArt *)		
				StautsText := '1 Lane, Sheets, Recipe 81';
				g_Core.Services.CAR.Interface.No[0].CustomerNumber := 10;
				g_Core.Services.CAR.Interface.No[0].ArticleNumber := 1;
				StepDone := 1;
				
				IF StepDone THEN
					IF Manual THEN
						step := ManualStep;
					ELSIF NOT Manual THEN
						step := 7;
						StepDone:= 0;
					END_IF
				END_IF
			
			7: (* Wait 2 seconds *)
					StautsText := 'Wait for 2 seconds';
					i := i +1;
			
					IF i = 100 THEN
	 					StepDone := 1;
						i := 0;
					END_IF 					
				
						
				IF StepDone THEN
					IF Manual THEN
						step := ManualStep;
					ELSIF NOT Manual THEN
						step := 10;
						StepDone:= 0;
					END_IF
				END_IF

		10: (* Set ISEmergency to 1 *)
				StautsText := 'Set ISEmergency to 1';
				g_Core.System.Runtime.isSimulation := 1; 
				
				IF Manual THEN
					step := ManualStep;
				ELSIF NOT Manual THEN
					step := 20;
				END_IF
				
		20: (* Set ISControlPLC to 1 *)
				StautsText :='Set ISControlPlc to 1';
				g_Core.System.Runtime.isRunning :=1;
				
				IF Manual THEN
					step := ManualStep;
				ELSIF NOT Manual THEN
					step := 25;
				END_IF	
				
		25:	(* Wait 5 seconds *)
					StautsText := 'Wait for 5 seconds';
					i := i +1;
			
					IF i = 250 THEN
	 					StepDone := 1;
						i := 0;
					END_IF 					
				
						
				IF StepDone THEN
					IF Manual THEN
						step := ManualStep;
					ELSIF NOT Manual THEN
						step := 30;
						StepDone:= 0;
					END_IF
				END_IF
				
		30: (* Set ISEmergency to 0 and wait 5 seconds then set it to 1 *)
				StautsText := 'Set ISemergency to 0 and wait 5 seconds then set it to 1';
				g_Core.System.Runtime.isSimulation := 1;
				i := i +1;
				
				IF g_Core.System.Runtime.isSimulation = 1 THEN
					g_Core.System.Runtime.isSimulation := 0;
					IF i = 250 THEN
	 					g_Core.System.Runtime.isSimulation := 1;
						StepDone := 1;
						i := 0;
					END_IF 					
				END_IF
						
				IF StepDone THEN
					IF Manual THEN
						step := ManualStep;
					ELSIF NOT Manual THEN
						step := 35;
						StepDone:= 0;
						i := 0;
					END_IF
				END_IF
		
		35:	(* Wait 5 seconds *)
					StautsText := 'Wait 5 Seconds';
					i := i +1;
			
					IF i = 250 THEN
	 					StepDone := 1;
						i := 0;
					END_IF 					
				
						
				IF StepDone THEN
					IF Manual THEN
						step := ManualStep;
					ELSIF NOT Manual THEN
						step := 40;
						StepDone:= 0;
					END_IF
				END_IF
		
					
				
		40: (* Set ISControlPLC to 0 and wait 5 seconds then set it to 1 *)
				StautsText := 'Set ISControlPlc to 0 and wait 5 sec. then set it to 1';
				i := i +1;
				g_Core.System.Runtime.isRunning := 0;
				
				IF g_Core.System.Runtime.isRunning = 0 THEN
					IF i = 250 THEN
	 					g_Core.System.Runtime.isRunning := 1;
						StepDone := 1;
						i := 0;
					END_IF 					
				END_IF
				
				IF StepDone THEN
					IF Manual THEN
						step := ManualStep;
					ELSIF NOT Manual THEN
						step := 45;
						StepDone := 0;
						ProdCount := 0;
					END_IF
				END_IF
				
		45: (* Wait 5 seconds *)
				StautsText := 'Wait 5 seconds';
				i := i +1;
				
					IF i = 250 THEN
	 					StepDone := 1;
						i := 0;
					END_IF 					
						
				IF StepDone THEN
					IF Manual THEN
						step := ManualStep;
					ELSIF NOT Manual THEN
						step := 50;
						StepDone:= 0;
					END_IF
				END_IF
				
				
		50: (* Add 10 Pieces to each Lane *)
				StautsText := 'Add 10 Pieces to each Lane'; 
			i := i +1;
			IF i = 25  AND NOT StepDone THEN
				ProdCount := ProdCount +1;
				FOR La := 0 TO 5 DO
					LogData_0(Type:=PRODUCTION_PRODUCTION, Lane:=La +1);
				END_FOR
				i := 0;
			END_IF	
				IF ProdCount = 10 THEN
					StepDone := 1;
					i := 0;
				END_IF				
				
				IF StepDone THEN
					IF Manual THEN
						step := ManualStep;
					ELSIF NOT Manual THEN
						step := 60;
						StepDone := 0;
						ProdCount := 0;
					END_IF
				END_IF
				
		60: (* Add 5 pieces to each Lane and then Make a PRODUCTION_REWASH *)
					StautsText := 'Add 5 Pieces to each Lane and then make a PRODUCTION_REWASH';
			
			i := i +1;	
			IF i = 25  AND NOT StepDone THEN
				ProdCount := ProdCount +1;
				FOR La := 0 TO 5 DO
					LogData_0(Type:= 65, Lane := La + 1, Info1 := 1, Info2 := 5);
					LogData_0(Type:=PRODUCTION_REWASH, Lane:=La +1);
					LogData_0(Type:=PRODUCTION_PRODUCTION, Lane:=La +1);
				END_FOR	
				i := 0;
			END_IF	
			
			IF ProdCount =  5 THEN
				StepDone := 1;
			i := 0;
			END_IF				
				
			IF StepDone THEN				
				IF Manual THEN
					step := ManualStep;
				ELSIF NOT Manual THEN
					StepDone := 0;
					step := 70;
					ProdCount := 0;
				END_IF
			END_IF
		70: (* Add 5 Pieces to each Lane and then Make a PRODUCTION_REPAIR *)
				StautsText := 'Add 5 Pieces to each Lane and then make a PRODUCTION_REPAIR';
			i := i +1;
			IF i = 25  AND NOT StepDone THEN
				ProdCount := ProdCount +1;
				FOR La := 0 TO 5 DO
					LogData_0(Type:=PRODUCTION_REPAIR, Lane:=La +1);
					LogData_0(Type:=PRODUCTION_PRODUCTION, Lane:=La +1);
				END_FOR
				i := 0;
			END_IF	
							
				IF ProdCount = 5  THEN
					StepDone := 1;
					i := 0;
				END_IF				
				
				IF StepDone THEN				
					IF Manual THEN
						step := ManualStep;
					ELSIF NOT Manual THEN
						step := 75;
						ProdCount := 0;
					END_IF
				END_IF
				
		75:   (* Wait 5 seconds *)
				StautsText := 'Wait 5 seconds';
				i := i +1;
				
					IF i = 250 THEN
	 					StepDone := 1;
						i := 0;
					END_IF 					
						
				IF StepDone THEN
					IF Manual THEN
						step := ManualStep;
					ELSIF NOT Manual THEN
						step := 80;
						StepDone:= 0;
					END_IF
				END_IF
				
		80: (* Change CustArt *)
				StautsText := '1 Lane, Duvets, Recipe 82';
				g_Core.Services.CAR.Interface.No[0].CustomerNumber := 10;
				g_Core.Services.CAR.Interface.No[0].ArticleNumber := 2;
				StepDone := 1;
				
				IF StepDone THEN
					IF Manual THEN
						step := ManualStep;
					ELSIF NOT Manual THEN
						step := 82;
						StepDone:= 0;
					END_IF
				END_IF
				
		82:	(* Add 5 Pieces to each Lane *)
				StautsText := 'Add 5 Pieces to each Lane'; 
			i := i +1;
			IF i = 25  AND NOT StepDone THEN	
				ProdCount := ProdCount +1;
				FOR La := 0 TO 5 DO
					LogData_0(Type:= 65, Lane := La + 1, Info1 := 0, Info2 := 5);
					LogData_0(Type:=PRODUCTION_PRODUCTION, Lane:=La +1);
				END_FOR
				i := 0;	
		END_IF
				IF ProdCount = 5 THEN
					StepDone := 1;
					i := 0;
				END_IF				
				
				IF StepDone THEN
					IF Manual THEN
						step := ManualStep;
					ELSIF NOT Manual THEN
						step := 85;
						StepDone := 0;
						ProdCount := 0;
					END_IF
				END_IF
		
			
		85:   (* Wait 5 seconds *)
				StautsText := 'Wait 5 seconds';
				i := i +1;
				
					IF i = 250 THEN
	 					StepDone := 1;
						i := 0;
					END_IF 					
						
				IF StepDone THEN
					IF Manual THEN
						step := ManualStep;
					ELSIF NOT Manual THEN
						step := 90;
						StepDone:= 0;
					END_IF
				END_IF

			90: (* Change CustArt  2*)
				StautsText := '1 Lane, Table, Recipe 83';
				g_Core.Services.CAR.Interface.No[0].CustomerNumber := 10;
				g_Core.Services.CAR.Interface.No[0].ArticleNumber := 3;
				StepDone := 1;
				
				IF StepDone THEN
					IF Manual THEN
						step := ManualStep;
					ELSIF NOT Manual THEN
						step := 92;
						StepDone:= 0;
					END_IF
				END_IF
				
			92: (* Add 5 Pieces to each Lane *)
				StautsText := 'Add 5 Pieces to each Lane'; 
				
			i := i +1;
			//IF i = 25  AND NOT StepDone THEN
			ProdCount := ProdCount +1;
			FOR La := 0 TO 5 DO
					LogData_0(Type:=PRODUCTION_PRODUCTION, Lane:=La +1);
			END_FOR
			i := 0;			
			//END_IF
				IF ProdCount = 5 THEN
					StepDone := 1;
					i := 0;
				END_IF				
				
				IF StepDone THEN
					IF Manual THEN
						step := ManualStep;
						// small hack
						StepDone := 0;
					ELSIF NOT Manual THEN
						step := 100;
						StepDone := 0;
						ProdCount := 0;
					END_IF
				END_IF
				
			100: (* The End *)
				StautsText := 'The End....';
				g_Core.System.Runtime.isRunning := 0;
				step := 5;

END_CASE

END_PROGRAM
