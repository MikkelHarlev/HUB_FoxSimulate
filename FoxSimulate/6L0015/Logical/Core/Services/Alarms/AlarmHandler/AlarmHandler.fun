(********************************************************************
 * COPYRIGHT -- JENSEN Denmark A/S
 ********************************************************************
 * Program: AlarmHandler
 * File: AlarmHandler.fun
 * Author: eg
 * Created: August 02, 2013
 ********************************************************************
 * Functions and function blocks of program AlarmHandler
 ********************************************************************)

FUNCTION stringToWString : BOOL (*TODO: Add your comment here*)
	VAR_INPUT
		pDest : UDINT;
		pSrc : UDINT;
		dLen : UINT;
	END_VAR
	VAR
		varWchar : REFERENCE TO UINT;
		varChar : REFERENCE TO USINT;
		i : UINT;
	END_VAR
END_FUNCTION
