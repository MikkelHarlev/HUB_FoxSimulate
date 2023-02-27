FUNCTION xml_MakeStream : UDINT
	VAR_INPUT
		ident	:UDINT;
		len	:REFERENCE TO UDINT;
		data	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION xml_MakeCmdStream : UDINT
	VAR_INPUT
		ident	:UDINT;
		len	:REFERENCE TO UDINT;
		data	:UDINT;
		str	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION xml_DeleteStream : BOOL
	VAR_INPUT
		ident	:UDINT;
		xmlstr	:UDINT;
		len	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION xml_LoadMIdent : UDINT
	VAR_INPUT
		ident	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION xml_DumpMIdent : UDINT
	VAR_INPUT
		ident	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION xml_MEnd : BOOL
	VAR_INPUT
		ident	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION xml_StructClose : BOOL
	VAR_INPUT
		ident	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION xml_AddStruct : BOOL
	VAR_INPUT
		ident	:UDINT;
		reprtype	:INT;
		numelem	:INT;
	END_VAR
END_FUNCTION
FUNCTION xml_CloseArray : BOOL
	VAR_INPUT
		ident	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION xml_AddArray : BOOL
	VAR_INPUT
		ident	:UDINT;
		reptype	:INT;
		namestr	:UDINT;
		numelem	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION xml_AddValue : BOOL
	VAR_INPUT
		ident	:UDINT;
		valtype	:INT;
		reptype	:INT;
		nameStr	:UDINT;
		len	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION xml_MCreate : UDINT
	VAR_INPUT
		name	:UDINT;
		type	:INT;
		arch	:INT;
		len	:UDINT;
		isNoPtr	:INT;
	END_VAR
END_FUNCTION
