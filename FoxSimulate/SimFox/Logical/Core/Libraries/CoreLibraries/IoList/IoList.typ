TYPE
	IoInfo_Type : STRUCT
		Description	:ARRAY[0..6] OF STRING[20];	
		Value	:ARRAY[0..6] OF STRING[4];	
		ElementActLevel	:UINT;	
		NumbElementsActLevel	:UINT;	
		ActIoAdr	:UDINT;	
		PathScrollLevel	:STRING[120];	
		ActIoName	:STRING[64];	
		SelectedLevel	:USINT;	
	END_STRUCT;
END_TYPE
