
FUNCTION_BLOCK RcpShowLevel
	VAR_INPUT
		Ident : UDINT;
		VarName : STRING[200];
		VarLevel : USINT;
	END_VAR
	VAR_OUTPUT
		Status : USINT;
		LineNumber : UINT;
		ChangeCount : UINT;
		ChangeVarName : STRING[200];
	END_VAR
	VAR
		InitState : BOOL;
		pStart : UDINT;
		pEnd : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK RcpGetMemInfo
	VAR_INPUT
		Ident : UDINT;
		cmdGetMemInfo : USINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		NumberBytesFree : UDINT;
		MaxBlockSizeFree : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK RcpGetNames
	VAR_INPUT
		Enable : BOOL;
		Ident : UDINT;
		pRcpNameArray : UDINT;
		SizeRcpNameArray : UINT;
		LinesRcpNameArray : UINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		ErrStringInfo : STRING[32];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK RcpCopy
	VAR_INPUT
		Enable : BOOL;
		Ident : UDINT;
		RcpSourceNumber : UINT;
		RcpDestBegin : UINT;
		RcpDestEnd : UINT;
		optCopySelectedPar : USINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		NewRecipeNumber : UINT;
		ErrStringInfo : STRING[32];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK RcpNameList
	VAR_INPUT
		Enable : BOOL;
		Ident : UDINT;
		cmdInit : USINT;
		cmdScrollUp : USINT;
		cmdScrollDown : USINT;
		cmdGotoIndex : UINT;
	END_VAR
	VAR_OUTPUT
		SelectedItem : USINT;
		RcpNumber : UINT;
		ErrStringInfo : STRING[32];
		Status : UINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK RcpPointInit
	VAR_INPUT
		pPointerName : UDINT;
		RcpInitIdent : UDINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		PointerIdent : UDINT;
		ErrStringInfo : STRING[32];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK RcpAdd
	VAR_INPUT
		Enable : BOOL;
		Ident : UDINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		NewRecipeNumber : UINT;
		ErrStringInfo : STRING[32];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION RcpPointRef : UINT
	VAR_INPUT
		RcpInitIdent : UDINT;
		PointerIdent : UDINT;
		Index : UINT;
	END_VAR
END_FUNCTION

FUNCTION_BLOCK RcpInit
	VAR_INPUT
		Enable : BOOL;
		pStructName : UDINT;
		pRcpInfoStruct : UDINT;
		LenRcpInfoStruct : UINT;
		pFileNameArray : UDINT;
		SizeFileNameArray : UINT;
		LinesFileNameArray : UINT;
		SizeMemAlloc : UDINT;
		cfgWorkWithVar : USINT;
		cfgCompressOn : USINT;
		NumbersLang : UINT;
	END_VAR
	VAR_OUTPUT
		Ident : UDINT;
		Status : UINT;
		SizeMemAllocated : UDINT;
		ErrStringInfo : STRING[100];
		ErrStringDetail : STRING[100];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK RcpLoad
	VAR_INPUT
		Enable : BOOL;
		Ident : UDINT;
		pDevice : UDINT;
		pFileName : UDINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		ErrStringInfo : STRING[100];
		ErrStringDetail : STRING[100];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK RcpSave
	VAR_INPUT
		Enable : BOOL;
		Ident : UDINT;
		pDevice : UDINT;
		pFileName : UDINT;
		optHeaderOnly : USINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		ErrStringInfo : STRING[100];
		ErrStringDetail : STRING[100];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK RcpFileListScroll
	VAR_INPUT
		Enable : BOOL;
		Ident : UDINT;
		cmdUp : USINT;
		cmdDown : USINT;
		cmdInit : USINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		SelectedItem : USINT;
		ActFileNumber : UINT;
		ActFileName : STRING[32];
		ErrStringInfo : STRING[32];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK ParScroInit
	VAR_INPUT
		Enable : BOOL;
		Ident : UDINT;
		pFileNameParLanguage : UDINT;
		pParScrollArray : UDINT;
		pParValueArray : UDINT;
		pParNameArray : UDINT;
		pParNameString : UDINT;
		pActParValue : UDINT;
		pDevice : UDINT;
		SizeParScrollArray : UINT;
		SizeParValueArray : UINT;
		SizeParNameArray : UINT;
		SizeActParValue : UINT;
		LinesParScrollArray : UINT;
		LinesParNameArray : UINT;
		AdrTimerVisibility : UDINT;
		SizeTimerVisibility : UINT;
		pVarNameArray : UDINT;
		SizeVarNameArray : UINT;
		LinesVarNameArray : UINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		ErrStringInfo : STRING[32];
		ErrStringDetail : STRING[32];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK ParScroCyclic
	VAR_INPUT
		Enable : BOOL;
		Ident : UDINT;
		cmdInit : USINT;
		cmdUp : USINT;
		cmdDown : USINT;
		cmdLangSwitch : USINT;
		cmdSearchPlace : UINT;
		cmdSearch : UINT;
		SearchVariable : STRING[50];
		cmdEditPar : USINT;
		cmdRcpChange : USINT;
		cmdJumpFirst : USINT;
		ActLanguage : USINT;
		SelectRcpNumber : UINT;
		ShowLevel : USINT;
		cmdGotoIndex : UINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		ActParNumber : UINT;
		SelectedItem : USINT;
		ErrStringInfo : STRING[32];
		ItemCount : UINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK RcpDeInit
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

FUNCTION_BLOCK RcpDirList
	VAR_INPUT
		Enable : BOOL;
		Ident : UDINT;
		pDevice : UDINT;
		pFileExtFilter : UDINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		ErrStringInfo : STRING[32];
	END_VAR
END_FUNCTION_BLOCK
