
TYPE
	OPCData_Type : 	STRUCT 
		MachineNumber : STRING[6];
		MachineID : UINT;
		Started : BOOL;
		EmergencyStop : BOOL;
		ErrorNumber : USINT;
		CustomerNumber : UINT;
		ArtricleNumber : UINT;
		RecipeNumber : USINT;
		ResetCounters : BOOL;
		Counter : ARRAY[0..15] OF UDINT;
	END_STRUCT;
END_TYPE
