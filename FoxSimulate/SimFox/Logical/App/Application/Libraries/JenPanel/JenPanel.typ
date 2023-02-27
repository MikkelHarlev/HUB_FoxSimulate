TYPE
	HmiVC_Type : STRUCT
		ContrastNew	: USINT ;
		ContrastOld	: USINT ;
		BrightnessOld	: USINT ;
		BrightnessNew	: USINT ;
		Status	: UDINT ;
		Handle	: UDINT ;
	END_STRUCT;
	PageUserLabelData_type : STRUCT
		TextIndex	: UINT ;
		Activate	: USINT ;
	END_STRUCT;
	NavigateKeyData_type : STRUCT
		FunctionKeyText	: STRING[11] ;
		PassWordLevel	: UINT ;
		PageId	: UINT ;
		IconId	: UINT ;
		FunctionKeyStatus	: UINT ;
		TextSnippetIndex	: UINT ;
		TextGroupIndex	: USINT ;
	END_STRUCT;
	PageHandler_Type : STRUCT
		CurrentKey	: UINT ;
		CurrentPage	: UINT ;
		NewPage	: UINT ;
		PassWordLevel	: UINT ;
		PictureHeaderName	: STRING[30] ;
		PictureHeaderUser	: PageUserLabelData_type ;
		FunctionKeyData	: ARRAY[0..11] OF NavigateKeyData_type ;
		KeyPressed	: UINT ;
		MenuIndex	: UINT ;
		Flag	: UINT ;
		LastMessageTimer	: UINT ;
		HighestMenuIndex	: UINT ;
		Activated	: USINT ;
		RunJenPanel	: USINT ;
		ExitTimeOut	: UINT ;
		TouchKeyDelay	: UINT ;
		TouchKeyDelayTimer	: UINT ;
		CurrentLanguage	: UINT ;
		NumberOfFunctionKeys	: UINT ;
		PassWordTimeOut	: UINT ;
		PassWordTimeOutTimer	: UDINT ;
		RootKeyTimeOut	: UINT ;
		RootKeyTimeOutTimer	: UINT ;
		HeaderTextIndex	: UINT ;
		HeaderTextGroupIndex	: USINT ;
		VcHandle	: UDINT ;
	END_STRUCT;
END_TYPE