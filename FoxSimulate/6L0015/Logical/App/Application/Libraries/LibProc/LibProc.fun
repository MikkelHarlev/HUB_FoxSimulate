(********************************************************************
 * COPYRIGHT -- IT
 ********************************************************************
 * Library: Process
 * File: Process.fun
 * Author: mariw
 * Created: July 09, 2010
 ********************************************************************
 * Functions and function blocks of library Process
 ********************************************************************)

FUNCTION_BLOCK FunFilter2
	VAR_INPUT
		IN : BOOL;
		FilterPos : UDINT;
		FilterNeg : UDINT;
	END_VAR
	VAR_OUTPUT
		OUT : BOOL;
	END_VAR
	VAR
		IN_Last : BOOL;
		Timer1 : UDINT;
		Timer2 : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FunFilter
	VAR_INPUT
		IN : BOOL;
		Count : UDINT;
	END_VAR
	VAR_OUTPUT
		OUT : BOOL;
	END_VAR
	VAR
		IN_Last : BOOL;
		Timer : UDINT;
	END_VAR
END_FUNCTION_BLOCK
