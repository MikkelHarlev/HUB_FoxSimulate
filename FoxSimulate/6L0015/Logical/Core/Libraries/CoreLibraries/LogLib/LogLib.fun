FUNCTION_BLOCK LogSetLineRead
	VAR_INPUT
		enable	:BOOL;
		ident	:UDINT;
	END_VAR
	VAR_OUTPUT
		status	:UINT;
	END_VAR
END_FUNCTION_BLOCK
FUNCTION_BLOCK LogRead
	VAR_INPUT
		enable	:BOOL;
		startFirstEntry	:BOOL;
		ident	:UDINT;
		adrReadData	:UDINT;
		sizeofReadData	:UDINT;
	END_VAR
	VAR_OUTPUT
		entries_read	:UDINT;
		status	:UINT;
	END_VAR
END_FUNCTION_BLOCK
FUNCTION_BLOCK LogStore
	VAR_INPUT
		enable	:BOOL;
		ident	:UDINT;
	END_VAR
	VAR_OUTPUT
		status	:UINT;
	END_VAR
END_FUNCTION_BLOCK
FUNCTION_BLOCK LogWrite
	VAR_INPUT
		enable	:BOOL;
		ident	:UDINT;
		AdrWriteData	:UDINT;
	END_VAR
	VAR_OUTPUT
		status	:UINT;
	END_VAR
END_FUNCTION_BLOCK
FUNCTION_BLOCK LogInit
	VAR_INPUT
		enable	:BOOL;
		EntrysLogfile	:UINT;
		sizeLogbuffer	:UDINT;
		pNameDevice	:UDINT;
		pNameFile	:UDINT;
		AdrLogbuffer	:UDINT;
		pNameWriteData	:UDINT;
		pIndexName	:UDINT;
	END_VAR
	VAR_OUTPUT
		ident	:UDINT;
		Ident_JenXML	:UDINT;
		AdrNameArray	:UDINT;
		CountVariables	:UDINT;
		ErrStringInfo	:STRING[32];
		ErrStringDetail	:STRING[32];
		status	:UINT;
	END_VAR
END_FUNCTION_BLOCK
