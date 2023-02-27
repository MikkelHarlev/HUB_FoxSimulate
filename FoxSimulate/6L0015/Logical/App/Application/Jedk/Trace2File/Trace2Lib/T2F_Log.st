
(* TODO: Add your comment here *)
FUNCTION T2F_Log
	IF DA = 0 THEN
		RETURN;
	END_IF
	Data ACCESS DA; 
	IF Data.init = FALSE THEN
		RETURN;
	END_IF

	UsedFifo := (T2F_Array_Size + Data.FiFo_In - Data.FiFo_Out) MOD T2F_Array_Size;
	IF (UsedFifo >= T2F_Array_Size - 1) OR Data.HasOverrun AND (UsedFifo >= T2F_Array_Size - 2) THEN
		// Overrun 
		Data.OverrunCount := Data.OverrunCount + 1;
		Data.OverrunCount1 := Data.OverrunCount1 + 1;
		Data.HasOverrun := TRUE;
	ELSE
		Data.DTStructureGetTime_0(enable := TRUE, pDTStructure := ADR(Data.DTStructureCurrent));
		IF Data.HasOverrun THEN
			Data.FiFo[(Data.FiFo_In + 1) MOD T2F_Array_Size] := Data.FiFo[Data.FiFo_In];
			Data.FiFo[Data.FiFo_In].TimeStamp := Data.DTStructureCurrent;
			itoa(Data.OverrunCount1, ADR(Tmp));
			Data.FiFo[Data.FiFo_In].Text := CONCAT('Trace2File Overrun ', Tmp);
			Data.FiFo[Data.FiFo_In].Text := CONCAT(Data.FiFo[Data.FiFo_In].Text, ' Times;');
			Data.FiFo_In := (Data.FiFo_In + 1) MOD T2F_Array_Size;
			Data.OverrunCount1 := 0;
			Data.HasOverrun := FALSE;
		END_IF

		// Log
		Data.FiFo[Data.FiFo_In].TimeStamp := Data.DTStructureCurrent;
		Data.FiFo_In := (Data.FiFo_In + 1) MOD T2F_Array_Size;
		Data.FiFo[Data.FiFo_In].TimeStamp := Data.DTStructureCurrent;
		Data.FiFo[Data.FiFo_In].Text := '';
		Data.FiFo[Data.FiFo_In].Function := '';
	END_IF

	T2F_Log := TRUE;

END_FUNCTION
