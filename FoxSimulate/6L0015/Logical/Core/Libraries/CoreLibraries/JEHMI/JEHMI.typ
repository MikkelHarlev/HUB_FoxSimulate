
TYPE
	HMIRuntime_Type : 	STRUCT 
		autoReload : UINT;
	END_STRUCT;
	HMIInit_Type : 	STRUCT 
		VisObject : UDINT;
		LoadPatch : BOOL;
		PatchDataObject : UDINT;
		DataObject : UDINT;
		LockTimeOut : UINT;
		CalibrateTime : UINT;
		ExitTime : UINT;
		SystemPageID : UINT;
		CalibratePageID : UINT;
		InvalidPanelPageID : UINT;
		WrongPasswordPageID : UINT;
		pTaskInterface : UDINT;
		pPasswordArr : UDINT;
		NotificatorTimer : UINT;
		Enabled : BOOL;
		AnimationSpeed : USINT;
		hwID : UDINT;
	END_STRUCT;
	HMIPageHandler_Type : 	STRUCT 
		Request : UINT;
		Active : UINT;
	END_STRUCT;
	HMIPageControllerKey_Type : 	STRUCT 
		PageControllerLink : UINT;
		TextID : UINT;
		IconID : UINT;
		Enabled : UINT;
		Locked : UINT;
	END_STRUCT;
	HMIInput_Type : 	STRUCT 
		KeyPressed : USINT;
		Key : ARRAY[0..15] OF HMIPageControllerKey_Type;
	END_STRUCT;
	HMIPasswordHandler_Type : 	STRUCT 
		Level : USINT;
		HideLogin : UINT;
		HideInvalidPassword : UINT;
		Entered : USINT;
		Password : STRING[4];
	END_STRUCT;
	hmiTouch_type : 	STRUCT 
		status : UDINT;
		x : UDINT;
		y : UDINT;
	END_STRUCT;
	HMITaskInterface_Type : 	STRUCT 
		KeyPressed : USINT;
		PageControllerID : UINT;
		pVCHandler : UDINT;
		pPanelHandler : UDINT;
		Icons : BOOL;
		SystemInitDone : BOOL;
		PasswordLevel : USINT;
		InitPassword : BOOL;
		isInitDone : BOOL;
		isDisableScreenCalibration : BOOL;
		touch : hmiTouch_type;
	END_STRUCT;
	HMIPageController_Type : 	STRUCT 
		Page : UINT;
		ID : UINT;
		Button : ARRAY[0..15] OF HMIPageControllerKey_Type;
		Next : UDINT;
		NoHistory : BOOL;
	END_STRUCT;
	HMIPageControllerHandler_Type : 	STRUCT 
		RequestedPageController : UINT;
		ParentPageController : ARRAY[0..31] OF UINT;
		pPageController : UDINT;
		Level : USINT;
		DisplayType : USINT;
		ChangeDisplayType : USINT;
		GoBack : BOOL;
		NoHistory : BOOL;
	END_STRUCT;
	HMIInternal_Type : 	STRUCT 
		NotifyTimer : UINT;
		ValidDevice : BOOL;
		PageControllerHandler : HMIPageControllerHandler_Type;
		InputLock : BOOL;
		InputState : USINT;
		InputTimer : UINT;
		InputKey : USINT;
		RequestPage : UINT;
		PasswordLevel : USINT;
		LockTimeOut : UDINT;
		ActivePageControllerID : UINT;
		ActivePageControllerPage : UINT;
		NewPasswordLevel : USINT;
		PasswordList : ARRAY[0..2] OF UDINT;
		LoginTries : USINT;
		LogTimer : UDINT;
		PasswordInit : BOOL;
		TouchTimer : UDINT;
		TouchStatus : USINT;
		PWRequestedPageHandler : ARRAY[0..1] OF UINT;
		InputKeyLast : UINT;
		CheckLastInput : BOOL;
		dataObjectDate1 : DATE_AND_TIME;
		dataObjectDate2 : DATE_AND_TIME;
		calibrationImage : UINT;
		calibrationProgress : REAL;
		calibrationCounter : UINT;
		dataObjectCheckCounter : UINT;
	END_STRUCT;
	HMINotificator_Type : 	STRUCT 
		Hide : UINT;
		Item : UINT;
	END_STRUCT;
END_TYPE
