TYPE
	(*ComModule_Type : STRUCT
		Id	:INT;	
		ComPort	:UDINT;	
		WriteState	:UINT;	
		ReadState	:UINT;	
		ReadFlag	:UINT;	
		FrameState	:UINT;	
		ReadMsg	:ARRAY[0..80] OF USINT;	
		ReadInMsg	:ARRAY[0..80] OF USINT;	
		RecStringCounter	:UINT;	
		IncompleteMsgCounter	:UINT;	
		IllegalCharCounter	:UINT;	
		ReadMsgCounter	:UINT;	
		LeftOverCharCounter	:UINT;	
		WriteMsg	:ARRAY[0..80] OF USINT;	
		Mode	:SINT;	
		DiagFlag	:UINT;	
	END_STRUCT;*)
			ComPort_Type : STRUCT
		Id	:INT;	
		State	:UINT;	
		ReadState	:UINT;	
		Ident	:UDINT;	
		Device	:UDINT;	
		Param	:UDINT;	
		Count	:UDINT;	
		CycelCounter	:UDINT;	
		RcvPoll	:USINT;	
		ReadStr	:ARRAY[0..125] OF USINT;	
		(*ReadIndex	:UDINT;	*)
		ReadId	:HangerID_Type;	
		(*ComModuleIndex	:ARRAY[0..64] OF SINT;*)	
		(*ScanIndex	:ARRAY[0..64] OF SINT;	*)
		ComUnitIndex	:ARRAY[0..254] OF SINT;	
		(*ScannerPtr	:UDINT;	
		ComModulePtr	:UDINT;	*)
		ComUnitPtr	:UDINT;	
		(*CheckSumErrCounter	:INT;	*)
		(*IdleRecieveCounter	:INT;	*)
		(*IllegalCharCounter	:INT;	*)
		(*SendErrCounter	:INT;	*)
		ComModuleMaxIncompleteCounter	:UINT;	
		(*FirstScanId	:DINT;	
		LastScanId	:DINT;	
		FirstTextId	:DINT;	
		LastTextId	:DINT;*)	
		CurrentId	:DINT;	
		NumberOfComUnits	:UINT;	
		WaitCycle	:DINT;	
		RecCounter	:DINT;	
		DiagLastInMsg	:ARRAY[0..80] OF USINT;	
		DiagLastOutMsg	:ARRAY[0..80] OF USINT;	
	END_STRUCT;
			ComUnit_Type : STRUCT
		Id	:INT;	
		FunctionType	:UINT;	
		RcvPoll	:USINT;	
		Ident	:UDINT;	
		DiagFlag	:UINT;	
		FrameState	:UINT;	
		Delimiter1	:UINT;	
		Delimiter2	:UINT;	
		TagId	:STRING[IDLength];	
		NumberOfBuffers	:UINT;	
		RecCounter	:UINT;	
		Mode	:SINT;	
		ScanPortPointer	:UDINT;	
	END_STRUCT;
			(*Scanner_Type : STRUCT
		Id	:INT;	
		Mode	:USINT;	
		ComPort	:UDINT;	
		FrameState	:UINT;	
		ReadId	:STRING[IDLength];	
	END_STRUCT;*)
			ScanPort_Type : STRUCT
		State	:UINT;	
		ComPort	:ComPort_Type;	
		(*Scanner	:ARRAY[0..19] OF Scanner_Type;	
		ComModule	:ARRAY[0..9] OF ComModule_Type;	*)
		ComUnit	:ARRAY[0..COMBUS_MAX_COMUNITS] OF ComUnit_Type;	
		InitState	:UDINT;	
		RunState	:UDINT;	
		BusType	:UINT;	
	END_STRUCT;
END_TYPE
