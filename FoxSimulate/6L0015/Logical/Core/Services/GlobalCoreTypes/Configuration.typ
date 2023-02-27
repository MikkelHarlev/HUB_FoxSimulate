
TYPE
	TimerDescription_Type : 	STRUCT 
		Enable : BOOL;
		Hide : USINT;
		ActTimer : DINT;
		No : ARRAY[0..6]OF DINT;
		Cnt : USINT;
	END_STRUCT;
END_TYPE

(*Insert your comment here.*)

TYPE
	permCAR_Type : 	STRUCT 
		CustomerNumber : UDINT;
		ArticleNumber : UDINT;
		RecipeNumber : USINT;
		Operator : UDINT;
	END_STRUCT;
	OperatorLoginControl_Type : 	STRUCT 
		InfoText : STRING[80];
		Action : UINT;
		Next : UINT;
		Prev : UINT;
		Index : UINT;
	END_STRUCT;
	OperatorLogin_Type : 	STRUCT 
		Type : UINT;
		Disabled : UINT;
		MType : UINT;
		LastName : STRING[20];
		FirstName : STRING[20];
		StationNo : UINT;
		OperatorNo : UINT;
		Action : USINT;
	END_STRUCT;
	OperatorGraph_Type : 	STRUCT 
		Disabled : UINT;
		Performance : REAL;
	END_STRUCT;
	CustomerEdit_Type : 	STRUCT 
		Enter : UINT;
		EnterColor : UINT;
	END_STRUCT;
	pancfg_type : 	STRUCT 
		ActualDateTime : DTStructure;
		Default : PanelCfg_Type;
		ButSaveDefault : USINT;
		SetDateTime : USINT;
		UserBrightness : USINT;
		UserContrast : USINT;
		UserLanguage : USINT;
		ChangeLanguage : USINT;
		CleaningTimeElapse : UINT;
		StatusCleanBackButton : UINT;
	END_STRUCT;
	MachineDataType : 	STRUCT 
		MachineType : USINT;
		TotalPowerOnHours : USINT;
		TotalOperationHours : USINT;
		TotalCounter : USINT;
		ProgramVersion : USINT;
		MachineNumber : USINT;
	END_STRUCT;
	ConfigFileStatus : 	STRUCT 
		Name : STRING[21];
		Date : STRING[21];
		Exists : UINT;
		Colour : UINT;
		Selected : UINT;
		Visible : UINT;
	END_STRUCT;
	CuArt_Type : 	STRUCT 
		Name : STRING[32];
		Number : UINT;
		ArtNumber : UINT;
		RcpNumber : UINT;
	END_STRUCT;
	FileErrorLayer_Type : 	STRUCT 
		State : UINT;
		Show : BOOL;
		Delay : UINT;
		InfoText : STRING[40];
		DetailText : STRING[40];
		OldInfoText : STRING[40];
		OldDetailText : STRING[40];
		ShowLayer : UINT;
		Acknowledge : BOOL;
		ReCheckError : BOOL;
	END_STRUCT;
	FileInfo_Type : 	STRUCT 
		LoadMachineConfigFlag : BOOL;
		MachineAlarmUserTrigger : ARRAY[0..9]OF USINT;
		ShowLevel : UINT;
		UpdateMachineConfigFlag : BOOL;
		BootUpFlag : UINT;
		BootUpFlagMask : UINT;
		AllFilesLoaded : BOOL;
		SystemInitDone : BOOL;
		LogInitDone : BOOL;
		EnableCustomerArticle : USINT;
		SaveRecepieFlag : BOOL;
		SaveMachineConfigFlag : BOOL;
		ExternalcmdKey : USINT;
		RcpText : USINT;
	END_STRUCT;
	FileManagerFile_Type : 	STRUCT 
		Exists : UINT;
		Date : STRING[41];
		Visible : UINT;
		Colour : UINT;
		Selected : UINT;
	END_STRUCT;
	FileManager_Type : 	STRUCT 
		wError : UINT;
		wStatus : UINT;
		stepFileInfo : UINT;
		RefreshCount : UINT;
		RefreshRate : UINT;
		ReadData : fiDIR_READ_DATA;
		DateStr : STRING[41];
		ChkFileDate : ARRAY[0..4]OF STRING[41];
		ChkFileExists : ARRAY[0..4]OF UINT;
		File : ARRAY[0..4]OF FileManagerFile_Type;
		FileNotExistColour : UINT;
		FileExistColour : UINT;
		FileNameLength : UINT;
		FileCounter : UINT;
		SelectedFile : STRING[41];
		SelectedDate : STRING[41];
	END_STRUCT;
	OperatorData_Type : 	STRUCT 
		Id : UINT;
		Name : STRING[41];
		OldId : UINT;
		CycleCount : UINT;
		Minutes : UINT;
		LastFeedCounter : UDINT;
		Counter : UINT;
		Article : UINT;
		ArticleName : STRING[41];
		Customer : UINT;
		CustomerName : STRING[41];
		Reciept : UINT;
		Change : BOOL;
	END_STRUCT;
	OperatorId_Type : 	STRUCT 
		No : UINT;
		Name : STRING[32];
	END_STRUCT;
	Operator_Type : 	STRUCT 
		OpName : STRING[32];
		OpNumber : UINT;
	END_STRUCT;
	Pancfg : 	STRUCT 
		Language : USINT;
		MachineNumber : STRING[32];
		MachineType : STRING[32];
	END_STRUCT;
	PanelCfg_Type : 	STRUCT 
		Brightness : USINT;
		Contrast : USINT;
		Language : USINT;
	END_STRUCT;
	SysMain_Type : 	STRUCT 
		TotalCounter : UDINT;
		OperatingHours : UDINT;
		PowerOns : UDINT;
		PowerOnHours : UDINT;
	END_STRUCT;
	SystemFile_Type : 	STRUCT 
		Language : USINT;
		Password : ARRAY[0..2]OF UDINT;
		LastLoadedRecipe : STRING[32];
		LastMachineFile : STRING[32];
		LastLoadedAutoProg : STRING[32];
		IPAddressPLC : STRING[15];
		IPDefaultGatewayPLC : STRING[15];
		Connection : ARRAY[0..19]OF SystemFile_Connection_Type;
		Port : UINT;
		StatSetup : ARRAY[0..11]OF USINT;
		IconsEnabled : BOOL;
		TimezoneID : INT;
		DaylightSaving : BOOL;
	END_STRUCT;
	SystemStatistics_Type : 	STRUCT 
		ResetDateAndTime : DTStructure;
		MachineID : STRING[32];
		Destination : USINT;
		Filter : USINT;
		Max : USINT;
	END_STRUCT;
	System_Type : 	STRUCT 
		File : SystemFile_Type;
		Valid : USINT;
		FileSave : USINT;
		FileStartSave : USINT;
		FileSaved : USINT;
	END_STRUCT;
END_TYPE
