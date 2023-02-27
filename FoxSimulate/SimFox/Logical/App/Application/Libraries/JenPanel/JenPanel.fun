FUNCTION GetPanelHandle : DINT
	VAR_INPUT
		PageHandler	:PageHandler_Type;
		PanelName	:STRING[31];
	END_VAR
END_FUNCTION
FUNCTION LogOutMenuHandler : DINT
	VAR_INPUT
		PageHandler	:PageHandler_Type;
	END_VAR
END_FUNCTION
FUNCTION GetMenuTexts : DINT
	VAR_INPUT
		PageHandler	:PageHandler_Type;
		PanelName	:STRING[20];
		MenuHeaderTextGroup	:UINT;
		FunctionKeyTextGroup	:UINT;
	END_VAR
END_FUNCTION
FUNCTION RunPageHandler : DINT
	VAR_INPUT
		PageHandler	:PageHandler_Type;
	END_VAR
END_FUNCTION
FUNCTION InitPageHandler : DINT
	VAR_INPUT
		PageHandler	:PageHandler_Type;
		MenuFileName	:STRING[80];
	END_VAR
END_FUNCTION
FUNCTION SetMenuDirect : DINT
	VAR_INPUT
		PageHandler	:PageHandler_Type;
		MenuId	:UINT;
	END_VAR
END_FUNCTION
