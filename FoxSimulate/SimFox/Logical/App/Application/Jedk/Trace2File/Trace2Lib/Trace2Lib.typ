
TYPE
	Trace2File_Type : 	STRUCT 
		Text : STRING[T2F_StringLenght];
		Function : STRING[T2F_FunctionStringLenght];
		TimeStamp : DTStructure;
	END_STRUCT;
	Trace2File_Data_Type : 	STRUCT 
		FiFo : ARRAY[0..T2F_Array_Size]OF Trace2File_Type;
		FiFo_Out : UDINT := 1;
		FiFo_In : UDINT := 1;
		DTStructureGetTime_0 : DTStructureGetTime;
		DTStructureCurrent : DTStructure;
		enable : BOOL := FALSE;
		init : BOOL := FALSE;
		OverrunCount : UINT;
		OverrunCount1 : UINT;
		HasOverrun : BOOL;
	END_STRUCT;
END_TYPE
