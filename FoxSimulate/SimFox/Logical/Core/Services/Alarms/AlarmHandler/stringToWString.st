(********************************************************************
 * COPYRIGHT -- JENSEN Denmark A/S
 ********************************************************************
 * Program: AlarmHandler
 * File: stringToWString.st
 * Author: eg
 * Created: August 02, 2013
 ********************************************************************
 * Implementation of program AlarmHandler
 ********************************************************************) 

 (* TODO: Add your comment here *)
FUNCTION stringToWString
    varWchar ACCESS pDest;
	varChar ACCESS pSrc;
	FOR i := 0 TO (dLen/2)-1 DO
        // optimized function
        varWchar := varChar;
        varWchar ACCESS ADR(varWchar)+SIZEOF(varWchar);
		varChar ACCESS ADR(varChar)+SIZEOF(varChar);
		IF (varChar = 0) THEN
			EXIT;
		END_IF
    END_FOR
	// Why can't we have a void function?
	stringToWString := TRUE;
END_FUNCTION