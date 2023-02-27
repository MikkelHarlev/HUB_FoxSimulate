
ACTION TrigSelectionAct:

	(*######################################*)
	(* Make a selection according to lenght *)
	(*######################################*)
	Found := FALSE;//g_AutoProgram.SelectedProgram 	:= 0;
	LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, LogBookFlag, g_AutoProgram.ShirtDetected, 'A-P, Shirt value');
	LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, LogBookFlag, g_AutoProgram.MeasuredLenght, 'A-P, Measured lenght');
	// Find actual AutoProgram
	LocalSearchAutoProgram ACCESS(g_Core.Services.AutoProg.Runtime.autoprogPointer + (SIZEOF(LocalSearchAutoProgram) * LIMIT(0, (g_AutoProgram.AutoProgramToSearch - 1), MAX_NUMBER_OF_AUTOPROGRAMS)));
	LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, LogBookFlag, g_AutoProgram.AutoProgramToSearch, 'A-P, Local search');

	FOR Index := 1 TO MAX_AUTO_LIST_5 DO
		// If measured lenght is shorter then selected go into if statement, can be several times, due to same lenght on several Auto programs..	
		// IF no lenght selected it considerd max lenght 09-08-02..
		IF (g_AutoProgram.MeasuredLenght < LocalSearchAutoProgram.LenghtPoints[Index]) OR (LocalSearchAutoProgram.LenghtPoints[Index] = 0) THEN
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, LogBookFlag, g_AutoProgram.MeasuredLenght, 'A-P, Lenght found');
			IF ((g_AutoProgram.ShirtDetected = 1) OR (g_AutoProgram.ShirtDetected = 2)) AND ((LocalSearchAutoProgram.Trouser[Index] = 1) OR (LocalSearchAutoProgram.Trouser[Index] = 0)) THEN		(* It's a shirt... *)
				g_AutoProgram.SelectedProgram 	:= LocalSearchAutoProgram.Categorys[Index];
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, LogBookFlag, g_AutoProgram.SelectedProgram, 'A-P, Shirt found');
				g_AutoProgram.ProgramFound		:= TRUE;
				Found 							:= TRUE;				
				EXIT;
			ELSIF (g_AutoProgram.ShirtDetected = 0) AND (LocalSearchAutoProgram.Trouser[Index] = 2 AND g_AutoProgram.IsFlapTrousers )THEN 	(* It's FlapTrousers *)				
				g_AutoProgram.SelectedProgram 	:= LocalSearchAutoProgram.Categorys[Index];
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, LogBookFlag, g_AutoProgram.SelectedProgram, 'A-P, Flap Trousers found');
				g_AutoProgram.ProgramFound		:= TRUE; 
				Found 							:= TRUE;				
				EXIT;
			ELSIF (g_AutoProgram.ShirtDetected = 0) AND ((LocalSearchAutoProgram.Trouser[Index] = 3) OR (LocalSearchAutoProgram.Trouser[Index] = 0)) AND NOT g_AutoProgram.IsFlapTrousers  THEN 		(* It's trousers... *)				
				g_AutoProgram.SelectedProgram 	:= LocalSearchAutoProgram.Categorys[Index];
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, LogBookFlag, g_AutoProgram.SelectedProgram, 'A-P, Trouser found');
				g_AutoProgram.ProgramFound		:= TRUE;
				Found 							:= TRUE;				
				AutoProgramToSearch				:= g_AutoProgram.AutoProgramToSearch;
				EXIT;
			END_IF				
		END_IF
	END_FOR
	// If no match was made according to lenght just check type and select one..
	IF NOT Found THEN
		FOR Index := 1 TO MAX_AUTO_LIST_5 DO
			IF ((g_AutoProgram.ShirtDetected = 1) OR (g_AutoProgram.ShirtDetected = 2)) AND (LocalSearchAutoProgram.Trouser[Index] = 1) THEN		(* It's a shirt... *)
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, LogBookFlag, g_AutoProgram.SelectedProgram, 'A-P, Force found shirt');
				g_AutoProgram.SelectedProgram 	:= LocalSearchAutoProgram.Categorys[Index];
				Found 							:= TRUE;				
				EXIT;
			ELSIF (g_AutoProgram.ShirtDetected = 0) AND (LocalSearchAutoProgram.Trouser[Index] = 2) THEN		(* It's trousers... *)								
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, LogBookFlag, g_AutoProgram.SelectedProgram, 'A-P, Force found trouser');
				g_AutoProgram.SelectedProgram 	:= LocalSearchAutoProgram.Categorys[Index];
				Found 							:= TRUE;				
				EXIT;
			ELSIF (g_AutoProgram.ShirtDetected = 0) AND (LocalSearchAutoProgram.Trouser[Index] = 3) THEN		(* It's FlapTrousrs... *)								
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, LogBookFlag, g_AutoProgram.SelectedProgram, 'A-P, Force found Flaptrouser');
				g_AutoProgram.SelectedProgram 	:= LocalSearchAutoProgram.Categorys[Index];
				Found 							:= TRUE;				
				EXIT;
			END_IF 
		END_FOR	
			
		// Not found at garment type. Look for lenght only
		IF NOT Found THEN 
			AutoprogramNoMatchType := AutoprogramNoMatchType + 1;
			FOR Index := 1 TO MAX_AUTO_LIST_5 DO
				// First matching length
				IF (g_AutoProgram.MeasuredLenght < LocalSearchAutoProgram.LenghtPoints[Index]) OR (LocalSearchAutoProgram.LenghtPoints[Index] = 0) THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, LogBookFlag, g_AutoProgram.MeasuredLenght, 'A-P Lenght found after search fail');
					g_AutoProgram.SelectedProgram 	:= LocalSearchAutoProgram.Categorys[Index];
					g_AutoProgram.ProgramFound		:= TRUE;
					Found 							:= TRUE;				
					EXIT;
				END_IF
			END_FOR
		END_IF
			
		// Still not found. Choose the number 5 selection
		IF NOT Found THEN
			AutoprogramNoMatch := AutoprogramNoMatch + 1;
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, LogBookFlag, g_AutoProgram.MeasuredLenght, 'A-P Forced selection 5');
			g_AutoProgram.SelectedProgram 	:= LocalSearchAutoProgram.Categorys[5];
			g_AutoProgram.ProgramFound		:= TRUE;
		END_IF
			
		g_AutoProgram.ProgramFound				:= TRUE; 	
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, LogBookFlag, g_AutoProgram.SelectedProgram, 'A-P, Forced program');
	END_IF	
	LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, LogBookFlag, g_AutoProgram.SelectedProgram, 'A-P, Selected progrm');

END_ACTION
