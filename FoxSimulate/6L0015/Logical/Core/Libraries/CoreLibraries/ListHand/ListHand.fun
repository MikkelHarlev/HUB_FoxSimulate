
FUNCTION_BLOCK ListEdit
	VAR_INPUT
		Enable : BOOL;
		Ident : UDINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		ErrStringInfo : STRING[32];
		ErrStringDetail : STRING[32];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK ListLock
	VAR_INPUT
		Enable : BOOL;
		Ident : UDINT;
		LockNumber : UINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		ErrStringInfo : STRING[32];
		ErrStringDetail : STRING[32];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK ListSearch
	VAR_INPUT
		Enable : BOOL;
		Ident : UDINT;
		OptionSearch : USINT;
		pListInfoStruct : UDINT;
		pStringArray : UDINT;
		pEntryStruct : UDINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		ErrStringInfo : STRING[32];
		ErrStringDetail : STRING[32];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK ListDelete
	VAR_INPUT
		Enable : BOOL;
		Ident : UDINT;
		optDeleteAll : USINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		ErrStringInfo : STRING[32];
		ErrStringDetail : STRING[32];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK ListAdd
	VAR_INPUT
		Enable : BOOL;
		Ident : UDINT;
		cmdAdd : USINT;
		optDoSort : USINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		ErrStringInfo : STRING[32];
		ErrStringDetail : STRING[32];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK ListScroll
	VAR_INPUT
		Enable : BOOL;
		Ident : UDINT;
		cmdScroll : USINT;
		pListInfoStruct : UDINT;
		pStringArray : UDINT;
		pEntryStruct : UDINT;
		ArrayElementTotal : USINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		ErrStringInfo : STRING[32];
		ErrStringDetail : STRING[32];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK ListSort
	VAR_INPUT
		Enable : BOOL;
		Ident : UDINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		ErrStringInfo : STRING[32];
		ErrStringDetail : STRING[32];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK ListSave
	VAR_INPUT
		Enable : BOOL;
		Ident : UDINT;
		pDestName : UDINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		ErrStringInfo : STRING[32];
		ErrStringDetail : STRING[32];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK ListLoad
	VAR_INPUT
		Enable : BOOL;
		Ident : UDINT;
		pSourceName : UDINT;
		pListInfoStruct : UDINT;
		pStringArray : UDINT;
		pEntryStruct : UDINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		ErrStringInfo : STRING[32];
		ErrStringDetail : STRING[32];
		ErrCorrupt : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK ListInit
	VAR_INPUT
		Enable : BOOL;
		pStringArray : UDINT;
		pEntryStruct : UDINT;
		pStringPath : UDINT;
		pDevice : UDINT;
		pListInfoStruct : UDINT;
		SizeMemAlloc : UDINT;
		SizeListInfoStruct : UINT;
		SizeStringArray : UINT;
		SizeEntryStruct : UINT;
		SizeStringPath : UINT;
		ArrayElementTotal : USINT;
		ListType : USINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		Ident : UDINT;
		ErrStringInfo : STRING[32];
		ErrStringDetail : STRING[32];
	END_VAR
END_FUNCTION_BLOCK
