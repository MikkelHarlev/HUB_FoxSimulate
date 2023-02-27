(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Program: JENTRANSSrv
 * File: Functions.st
 * Author: eg
 * Created: April 23, 2012
 *******************************************************************)

FUNCTION GenerateXMLString
	IF pConvertedString > 0 THEN
		// Converting number to ascii
		itoa(No, ADR(tmpString));
		
		ConvertedString ACCESS pConvertedString;
		// Replacing @ with number.
		strcpy(ADR(ConvertedString),ADR(TemplateString));
		strcat(ADR(ConvertedString), ADR('['));
		strcat(ADR(ConvertedString), ADR(tmpString));
		strcat(ADR(ConvertedString), ADR(']'));
		GenerateXMLString := TRUE;
	ELSE
		GenerateXMLString := FALSE;
	END_IF
END_FUNCTION