(* statistics setup *)

ACTION setup: 
	IF NOT GotTexts THEN
		IF VA_Saccess(1, g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler) = 0 THEN
			i := 0;
			FOR x := 0 TO 900 DO
				IF	(x >= 0 AND x <= 19) OR (x >= 20 AND x <= 37) OR (x >= 101 AND x <= 110) OR (x >= 201 AND x <= 210) OR (x >= 301 AND x <= 310) OR (x >= 401 AND x <= 410) OR (x >= 510 AND x <= 510) OR (x >= 601 AND x <= 610)  OR (x >= 801 AND x <= 810) THEN
					TextLength := SIZEOF(ArrMonthList[x]) -1;
					VA_wcGetTextByTextGroup(1, g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler, 9, x, ADR(ArrMonthListUniCode), ADR(TextLength));
					pChar ACCESS ADR(ArrTexts[i]);
					FOR y := 0 TO UINT_TO_USINT(TextLength) DO (*Strip unicode =) wee*)
						pChar ACCESS ADR(pChar);
						pChar := UINT_TO_USINT(ArrMonthListUniCode[y]);
						pChar ACCESS ADR(pChar) + 1;
					END_FOR
					IF i < 12 THEN
						ArrMonthList[x] := ArrTexts[x];
					END_IF
					i := i + 1;
				END_IF
			END_FOR
			VA_Srelease(1,g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler);
			GotTexts := TRUE;
			ConfigSum := 0;
			NumberOfProductionUnits := GetData(ServerNo := 1, Type:= NUMBER_OF_LANES, Lane:= 1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
			// SAFETY CHECK 
			IF NumberOfProductionUnits = 0 THEN // Something is not right! ALARM TRIGGER HERE
				NumberOfProductionUnits := 1;
			END_IF
			FOR i := 0 TO SIZEOF(g_Core.Services.System.Runtime.file.StatSetup)/SIZEOF(g_Core.Services.System.Runtime.file.StatSetup[0])-1 DO
				ConfigSum := ConfigSum + g_Core.Services.System.Runtime.file.StatSetup[i];
			END_FOR
			IF ConfigSum = 0 THEN (*AutoSetup*)
				Setup[0] := TRUE; (*showtime*)
				Setup[1] := TRUE; (*totalcount*)
				Setup[2] := g_Core.Services.Statistics.Interface.configuration.isRewash; (*rewash*)
				Setup[3] := g_Core.Services.Statistics.Interface.configuration.isRepair; (*repair*)
				Setup[4] := g_Core.Services.Statistics.Interface.configuration.isDrop; (*drop*)
				Setup[5] := g_Core.Services.Statistics.Interface.configuration.isQuality; (*Quality*)
				Setup[6] := g_Core.Services.Statistics.Interface.configuration.isOversize; (*oversize*)
				Setup[7] := g_Core.Services.Statistics.Interface.configuration.isPreproduction; (*preproduction*)
				Setup[8] := g_Core.Services.Statistics.Interface.configuration.isTooClose; (*preproduction*)
				Setup[9] := g_Core.Services.Statistics.Interface.configuration.isOption1; (*preproduction*)
				Setup[10] := g_Core.Services.Statistics.Interface.configuration.isOption2; (*preproduction*)
				Setup[11] := g_Core.Services.Statistics.Interface.configuration.isOption3; (*preproduction*)
				x := 0;
				FOR i:= 0 TO 11 DO (*Clear all*)
					g_Core.Services.System.Runtime.file.StatSetup[i] := 0;
				END_FOR

				FOR i:= 0 TO 1 DO (*Setup options*)
					IF Setup[i] THEN
						g_Core.Services.System.Runtime.file.StatSetup[x] := i+1;
						x := x + 1;
					END_IF
				END_FOR

				FOR i := 0 TO UDINT_TO_USINT(NumberOfProductionUnits) - 1 DO (*Setup counters*)
					g_Core.Services.System.Runtime.file.StatSetup[x] := 9 + i;
					x := x + 1;
				END_FOR
				FOR i:= 2 TO 7 DO (*Setup options*)
					IF Setup[i] THEN
						IF x < 11 THEN
							g_Core.Services.System.Runtime.file.StatSetup[x] := i+1;
							x := x + 1;
						ELSE
							OVERFLOW := TRUE; (*Warning overflow of options / counters*)
							EXIT;
						END_IF
					END_IF
				END_FOR
				g_Core.Services.System.Interface.isCmdSave := TRUE;
			END_IF
			DynamicSetup := g_Core.Services.System.Runtime.file.StatSetup;
		END_IF
	END_IF
END_ACTION
