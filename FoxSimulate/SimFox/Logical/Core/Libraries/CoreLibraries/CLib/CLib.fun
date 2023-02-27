
FUNCTION_BLOCK FlattenVar
	VAR_INPUT
		Command : USINT;
		Settings : JFESettings_Type;
		pDirectory : UDINT;
		pFile : UDINT;
		pDeviceCreator : UDINT;
		pDevice : UDINT;
		VarName : STRING[80];
		memAllocSize : UDINT;
	END_VAR
	VAR_OUTPUT
		Status : USINT;
	END_VAR
	VAR
		Ident : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION ConvIntToAscii : UINT
	VAR_INPUT
		Conv_Type : UINT;
		AdrValueString : UDINT;
		StringLength : UINT;
		AdrVar : UDINT;
	END_VAR
END_FUNCTION

FUNCTION_BLOCK USBDisk
	VAR_INPUT
		PullInterval : UINT;
		USBDevice : STRING[32];
		FileDeviceName : UDINT;
		Run : BOOL;
	END_VAR
	VAR_OUTPUT
		StatusString : STRING[80];
		Status : UINT;
		ProductID : UDINT;
		VendorID : UDINT;
	END_VAR
	VAR
		Ident : UDINT;
	END_VAR
END_FUNCTION_BLOCK
