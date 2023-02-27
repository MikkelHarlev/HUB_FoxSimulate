
FUNCTION UpdateButton : BOOL
	VAR_INPUT
		pPanelHandler : UDINT;
		PageControllerID : UINT;
		ButtonNo : UINT;
		ButtonID : UINT;
		PasswordLevel : UINT;
		PageControllerLink : UINT;
	END_VAR
END_FUNCTION

FUNCTION Notify : BOOL
	VAR_INPUT
		pPanelHandler : UDINT;
		BitmapNo : UINT;
		Timer : UINT;
	END_VAR
END_FUNCTION

FUNCTION_BLOCK HMIHandler
	VAR_INPUT
		MemPool : UDINT;
		Init : HMIInit_Type;
		Key : HMIInput_Type;
		Page : HMIPageHandler_Type;
		Password : HMIPasswordHandler_Type;
		InitDone : BOOL;
	END_VAR
	VAR_OUTPUT
		StatusString : STRING[80];
		Status : UINT;
		Ident : UDINT;
	END_VAR
	VAR
		Runtime : HMIRuntime_Type;
		Notificator : HMINotificator_Type;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION CallPageControllerLink : BOOL
	VAR_INPUT
		PageControllerID : UINT;
		pPanelHandler : UDINT;
	END_VAR
END_FUNCTION

FUNCTION LookupPageID : UINT
	VAR_INPUT
		PageID : UINT;
		pPanelHandler : UDINT;
	END_VAR
END_FUNCTION

FUNCTION_BLOCK Animate
	VAR_INPUT
		Type : USINT;
		FirstImage : UINT;
		LastImage : UINT;
		Acceleration : REAL;
		SetTimeout : UINT;
		Enable : BOOL;
		pPanelHandler : UDINT; (*Ident for HMIHandler*)
	END_VAR
	VAR
		Direction : BOOL;
		NotifyIndex : UINT;
		Timer : UINT;
		Timeout : UINT;
		InitDone : BOOL;
	END_VAR
END_FUNCTION_BLOCK
