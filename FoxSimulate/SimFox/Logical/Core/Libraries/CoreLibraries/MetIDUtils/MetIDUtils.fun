
FUNCTION DataMakeStr : BOOL
	VAR_INPUT
		a : HangerIDUtil_Type;
		HangerStr : REFERENCE TO SINT;
	END_VAR
END_FUNCTION

FUNCTION DataSetNull : INT
	VAR_INPUT
		a : HangerIDUtil_Type;
	END_VAR
END_FUNCTION

FUNCTION DataIsNull : BOOL
	VAR_INPUT
		a : HangerIDUtil_Type;
	END_VAR
END_FUNCTION

FUNCTION DataEqual : BOOL
	VAR_INPUT
		a : HangerIDUtil_Type;
		b : HangerIDUtil_Type;
	END_VAR
END_FUNCTION

FUNCTION DataMakeIdOfStr : BOOL
	VAR_INPUT
		binID : REFERENCE TO HangerIDUtil_Type;
		idstring : UDINT;
	END_VAR
END_FUNCTION
