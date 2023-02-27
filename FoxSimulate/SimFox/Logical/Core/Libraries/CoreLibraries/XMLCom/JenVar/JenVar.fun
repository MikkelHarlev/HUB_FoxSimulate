FUNCTION_BLOCK CreateVariableAddressList
	VAR_INPUT
		enable	:BOOL;
		createOffset	:BOOL;
		Ident	:UDINT;
	END_VAR
	VAR_OUTPUT
		Adr_VariableAddressList	:UDINT;
		status	:UINT;
	END_VAR
END_FUNCTION_BLOCK
FUNCTION_BLOCK GetVariableData
	VAR_INPUT
		enable	:BOOL;
		pVarName	:UDINT;
	END_VAR
	VAR_OUTPUT
		pVarStruct	:UDINT;
		CountVariables	:UDINT;
		Ident	:UDINT;
		status	:UINT;
	END_VAR
END_FUNCTION_BLOCK
FUNCTION_BLOCK CreateVariableNameList
	VAR_INPUT
		enable	:BOOL;
		Ident	:UDINT;
	END_VAR
	VAR_OUTPUT
		AdrVariableNameList	:UDINT;
		status	:UINT;
	END_VAR
END_FUNCTION_BLOCK
FUNCTION_BLOCK DestroyVariableData
	VAR_INPUT
		enable	:BOOL;
		Ident	:UDINT;
	END_VAR
	VAR_OUTPUT
		status	:UINT;
	END_VAR
END_FUNCTION_BLOCK
FUNCTION_BLOCK GetVariableData_Mem
	VAR_INPUT
		enable	:BOOL;
		pVarName	:UDINT;
		oldIdent	:UDINT;
	END_VAR
	VAR_OUTPUT
		pVarStruct	:UDINT;
		countVariables	:UDINT;
		ident	:UDINT;
		status	:UINT;
	END_VAR
END_FUNCTION_BLOCK
