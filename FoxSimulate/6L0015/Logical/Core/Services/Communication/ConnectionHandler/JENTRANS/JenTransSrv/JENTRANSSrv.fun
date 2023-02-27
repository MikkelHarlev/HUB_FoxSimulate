(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Program: JENTRANSSrv
 * File: JENTRANSSrv.fun
 * Author: eg
 * Created: April 23, 2012
 ********************************************************************
 * Functions and function blocks of program JENTRANSSrv
 ********************************************************************)

FUNCTION GenerateXMLString : BOOL (*convert 0-9 int to ascii*)
	VAR_INPUT
		No : USINT;
		TemplateString : STRING[100];
		pConvertedString : UDINT;
	END_VAR
	VAR
		tmpString : STRING[2];
		ConvertedString : REFERENCE TO STRING[100];
	END_VAR
END_FUNCTION
