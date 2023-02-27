TYPE
	JenVarStruct_typ : STRUCT
		pName	: UDINT ;
		Dimension	: UINT ;
		Type	: UDINT ;
		Len	: UDINT ;
		VarAddress	: UDINT ;
		Adr_Parent	: UDINT ;
		Adr_NextSister	: UDINT ;
		Adr_PrevSister	: UDINT ;
		Adr_Child	: UDINT ;
	END_STRUCT;
	JenVarAdrList_typ : STRUCT
		DataTyp	: UDINT ;
		Address	: UDINT ;
		Len	: UDINT ;
	END_STRUCT;
	JenVarNameList_typ : STRUCT
		Adr	: UDINT ;
		Size	: UDINT ;
	END_STRUCT;
END_TYPE