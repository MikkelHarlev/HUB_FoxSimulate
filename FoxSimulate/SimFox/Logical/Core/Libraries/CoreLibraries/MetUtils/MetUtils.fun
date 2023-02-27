
FUNCTION metvsprintf : INT
	VAR_INPUT
		buf : REFERENCE TO SINT;
		fmt : REFERENCE TO SINT;
		args : UDINT;
	END_VAR
END_FUNCTION

FUNCTION simple_strtoul : UDINT
	VAR_INPUT
		cp : REFERENCE TO SINT;
		endp : UDINT;
		base : UINT;
	END_VAR
END_FUNCTION

FUNCTION strnlen : DINT
	VAR_INPUT
		s : REFERENCE TO SINT;
		count : UDINT;
	END_VAR
END_FUNCTION

FUNCTION metsprintf : INT
	VAR_INPUT
		buf : REFERENCE TO SINT;
		fmt : REFERENCE TO SINT;
		va____ : UDINT;
	END_VAR
END_FUNCTION

FUNCTION strtrimend : DINT
	VAR_INPUT
		instr : REFERENCE TO SINT;
	END_VAR
END_FUNCTION

FUNCTION logprintf : DINT
	VAR_INPUT
		errornr : UINT;
		errorinfo : UDINT;
		fmt : REFERENCE TO SINT;
		__VA_ARGS__ : UDINT;
	END_VAR
END_FUNCTION

FUNCTION logassert : DINT
	VAR_INPUT
		line : UDINT;
		file : REFERENCE TO SINT;
		check : REFERENCE TO SINT;
	END_VAR
END_FUNCTION

FUNCTION CheckDelayedOutput : DINT
	VAR_INPUT
		Output : DelayedOutput_Type;
		curtimer : UINT;
	END_VAR
END_FUNCTION

FUNCTION SetDelayedOutput : DINT
	VAR_INPUT
		Output : DelayedOutput_Type;
		starttimer : UINT;
		delay : UINT;
	END_VAR
END_FUNCTION

FUNCTION CheckSensor : BOOL
	VAR_INPUT
		sensor : PresenceSensor_Type;
		curtimer : UINT;
	END_VAR
END_FUNCTION

FUNCTION gettimestamp : UDINT
END_FUNCTION

FUNCTION elapsedtime : UINT
	VAR_INPUT
		curtime : UINT;
		starttime : UINT;
	END_VAR
END_FUNCTION

FUNCTION getcurtimer : UINT
END_FUNCTION

FUNCTION getcurlongtimer : UDINT
END_FUNCTION

FUNCTION elapsedlongtime : UDINT
	VAR_INPUT
		curtime : UDINT;
		starttime : UDINT;
	END_VAR
END_FUNCTION
