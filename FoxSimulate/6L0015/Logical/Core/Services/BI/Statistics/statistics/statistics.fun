
FUNCTION_BLOCK flowTimeCounter (*TODO: Add your comment here*)
	VAR_INPUT
		reset : BOOL;
		set : BOOL;
		adrMillicounter : UDINT;
	END_VAR
	VAR_OUTPUT
		timer : UDINT;
	END_VAR
	VAR
		oldtime : UDINT;
		initDone : BOOL;
		pMilliCounter : REFERENCE TO UDINT;
		oldset : BOOL;
	END_VAR
END_FUNCTION_BLOCK
