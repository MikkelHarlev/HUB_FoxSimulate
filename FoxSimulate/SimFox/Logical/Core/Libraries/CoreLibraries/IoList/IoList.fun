FUNCTION_BLOCK IoDescLoad
VAR_INPUT
		Enable	:BOOL;	
		Ident	:UDINT;	
		pDevice	:UDINT;	
		pFileName	:UDINT;	
		pDescString	:UDINT;	
		SizeDescString	:UDINT;	
	END_VAR
	VAR_OUTPUT
		Status	:UINT;	
		ErrStringInfo	:STRING[64];	
	END_VAR
END_FUNCTION_BLOCK
FUNCTION_BLOCK IoListScroll
VAR
		UpdateOutput	:USINT;	
	END_VAR
	VAR_INPUT
		Enable	:BOOL;	
		Ident	:UDINT;	
		IoType	:USINT;	
		cmdInit	:USINT;	
		cmdUp	:USINT;	
		cmdDown	:USINT;	
		cmdScrollLevelUp	:USINT;	
		cmdScrollLevelDown	:USINT;	
		cmdSetOutput	:USINT;	
		cmdForceEnable	:USINT;	
		cmdForceDisable	:USINT;	
		cmdForceSetValue	:USINT;	
		cmdForceDisableAll	:USINT;	
		NumbSelectLanguage	:USINT;	
	END_VAR
	VAR_OUTPUT
		Status	:UINT;	
		ErrStringInfo	:STRING[32];	
		ActIoNumber	:UINT;	
		NumberOfIoTotal	:UINT;	
		SelectedItem	:UINT;	
		ActIoForcedOn	:USINT;	
		AnyIoForcedOn	:USINT;	
	END_VAR
END_FUNCTION_BLOCK
FUNCTION_BLOCK IoListInit
VAR_INPUT
		Enable	:BOOL;	
		pStateDi	:UDINT;	
		pStateDo	:UDINT;	
		pStateAi	:UDINT;	
		pStateAo	:UDINT;	
		pVisWindow	:UDINT;	
		pVisVarDigitalSet	:UDINT;	
		pVisVarAnalogSet	:UDINT;	
		pVisVarDigitalForce	:UDINT;	
		pVisVarAnalogForce	:UDINT;	
		pVisStructIoInfo	:UDINT;	
		SizeMemAlloc	:UDINT;	
		SizeVisWindow	:UINT;	
		SizeVisStructIoInfo	:UINT;	
		SizeVisVarDigitalSet	:USINT;	
		SizeVisVarAnalogSet	:USINT;	
		SizeVisVarDigitalForce	:USINT;	
		SizeVisVarAnalogForce	:USINT;	
		LinesVisWindow	:USINT;	
		LenStateDi	:UINT;	
		LenStateDo	:UINT;	
		LenStateAi	:UINT;	
		LenStateAo	:UINT;	
		UseArio	:USINT;	
		IgnoreNonExistIo	:USINT;	
		pDatObjName	:UDINT;	
	END_VAR
	VAR_OUTPUT
		Ident	:UDINT;	
		Status	:UINT;	
		SizeMemAllocated	:UDINT;	
		ErrStringInfo	:STRING[32];	
		ErrStringDetail	:STRING[32];	
	END_VAR
END_FUNCTION_BLOCK
FUNCTION_BLOCK IoGetMemInfo
VAR_INPUT
		Ident	:UDINT;	
		cmdGetMemInfo	:USINT;	
	END_VAR
	VAR_OUTPUT
		Status	:UINT;	
		NumberBytesFree	:UDINT;	
		MaxBlockSizeFree	:UDINT;	
	END_VAR
END_FUNCTION_BLOCK
