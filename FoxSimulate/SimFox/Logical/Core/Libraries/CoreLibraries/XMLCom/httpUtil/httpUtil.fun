FUNCTION httpGenHeader : UDINT
	VAR_INPUT
		buffer	:UDINT;
		content	:UDINT;
		clen	:UDINT;
		prio	:SINT;
	END_VAR
END_FUNCTION
FUNCTION httpParseHeader : USINT
	VAR_INPUT
		string	:UDINT;
		len	:UDINT;
		head	:HTTP_Header_typ;
	END_VAR
END_FUNCTION
FUNCTION httpHeaderGen : UDINT
	VAR_INPUT
		buff	:UDINT;
		clen	:UDINT;
		prio	:SINT;
	END_VAR
END_FUNCTION
FUNCTION httpSetIpHeader : UDINT
	VAR_INPUT
		ipaddr	:UDINT;
	END_VAR
END_FUNCTION
FUNCTION httpStripHeader : UDINT
	VAR_INPUT
		string	:UDINT;
		len	:REFERENCE TO UINT;
	END_VAR
END_FUNCTION
