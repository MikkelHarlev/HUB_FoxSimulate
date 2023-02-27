
TYPE
	SoftModule_typ : 	STRUCT 
		NoOfModules : USINT;
		NewestModule : SoftModuleNo_typ;
		NewestDateTimeUDINT : UDINT;
		State : USINT;
		ListType : USINT := 17;
		ListTypeOld : USINT;
		ListIndex : UINT;
		ListPrevIndex : UINT;
		Cmd : SoftModuleCmd_typ;
		Stat : SoftModuleStat_typ;
		No : ARRAY[0..244] OF SoftModuleNo_typ;
	END_STRUCT;
	SoftModuleStat_typ : 	STRUCT 
		Selected : USINT;
	END_STRUCT;
	SoftModuleCmd_typ : 	STRUCT 
		Up : BOOL;
		Dw : BOOL;
	END_STRUCT;
	SoftModuleNo_typ : 	STRUCT 
		Name : STRING[20];
		State : USINT;
		Group : USINT;
		MemType : UDINT;
		DateTime : RTCtime_typ;
		Size : UDINT;
		Version : STRING[10];
	END_STRUCT;
END_TYPE
