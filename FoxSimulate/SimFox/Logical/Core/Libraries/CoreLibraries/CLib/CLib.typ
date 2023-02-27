TYPE
	JFESettings_Type : STRUCT
		ColumnNameLevel	: USINT ;
		SecureWrite	: BOOL ;
		HeaderIdent	: UDINT ;
		SplitChar	: UDINT ;
		CreateFile	: BOOL ;
	END_STRUCT;
	Element_Type : STRUCT
		FullName	: STRING[64] ;
		Name	: STRING[32] ;
		Address	: UDINT ;
		Length	: UDINT ;
		Type	: USINT ;
	END_STRUCT;
	Entry_Type : STRUCT
		Name	: STRING[32] ;
		Elements	: UINT ;
		Element	: ARRAY[0..63] OF Element_Type ;
	END_STRUCT;
	FileHandler_Type : STRUCT
		wStatus	: UINT ;
		wError	: UINT ;
		fCommand	: USINT ;
		dwIdent	: UDINT ;
		FOpen	: UDINT ;
		FCreate	: UDINT ;
		FWrite	: UDINT ;
		FRead	: UDINT ;
		FClose	: UDINT ;
		FDelete	: UDINT ;
		DCreate	: UDINT ;
		DClose	: UDINT ;
		FCopy	: UDINT ;
		FileStatus	: USINT ;
		arrDirs	: ARRAY[0..9] OF STRING[80] ;
		NumDirs	: USINT ;
		NumCurDir	: USINT ;
		DirStatus	: BOOL ;
		FullFileName	: STRING[80] ;
		SplitChar	: UDINT ;
		Offset	: UDINT ;
		Buffer	: ARRAY[0..3999] OF USINT ;
		BufferLen	: UDINT ;
		DevLink	: UDINT ;
		MemPartIdent	: UDINT ;
		ReadMemIdent	: UDINT ;
		BufferMemIdent	: UDINT ;
	END_STRUCT;
	FlatVar_Type : STRUCT
		Data_Len	: UDINT ;
		Data_Type	: UDINT ;
		Data_Dimensions	: UINT ;
		Length	: UDINT ;
		StatusString	: STRING[80] ;
		State	: USINT ;
		Entries	: Entry_Type ;
		FileHandler	: FileHandler_Type ;
		FileHeaderLines	: UDINT ;
		FileDataLines	: UDINT ;
		HeaderIdent	: UDINT ;
	END_STRUCT;
END_TYPE