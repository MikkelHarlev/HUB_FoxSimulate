FUNCTION saxSetCBIdent : USINT
	VAR_INPUT
		handle	:UDINT;
		cbptr	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION saxGetEndElementHandler : UDINT
END_FUNCTION
FUNCTION saxSetSingleRespCB : USINT
	VAR_INPUT
		handle	:UDINT;
		cbFunc	:UDINT;
		originType	:USINT;
		originData	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION saxReset : INT
	VAR_INPUT
		handle	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION saxResponseNeed : USINT
	VAR_INPUT
		handle	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION saxAddResultCBFunc : USINT
	VAR_INPUT
		funcPtr	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION saxGetStartElementHandler : UDINT
END_FUNCTION
FUNCTION saxGetCharHandler : UDINT
END_FUNCTION
FUNCTION saxClose : INT
	VAR_INPUT
		handle	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION saxFinished : USINT
	VAR_INPUT
		handle	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION saxOpen : UDINT
	VAR_INPUT
		fcallMaxSize	:UDINT;
		fMaxNameLen	:UINT;
		pMaxNum	:UINT;
		aMaxNum	:UINT;
	END_VAR
END_FUNCTION
FUNCTION saxAddCBFunc : USINT
	VAR_INPUT
		funcPtr	:UDINT;
		fname	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION saxAddUndefCBFunc : USINT
	VAR_INPUT
		funcPtr	:UDINT;
	END_VAR
END_FUNCTION