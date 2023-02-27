TYPE
	xml_cbData_type : STRUCT
		cbFunc	: UDINT ;
		cbDataType	: USINT ;
		cbpData	: UDINT ;
	END_STRUCT;
	XMLCBIDENT_typ : STRUCT
		ticket	: UDINT ;
		status	: DINT ;
		parser	: UDINT ;
		internal	: USINT ;
	END_STRUCT;
	xml_sax_para_t : STRUCT
		fcallMaxSize	: UDINT ;
		fMaxNameLen	: UINT ;
		pMaxNum	: UINT ;
		aMaxNum	: UINT ;
	END_STRUCT;
END_TYPE