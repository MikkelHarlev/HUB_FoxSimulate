(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Package: Remote
 * File: Remote.typ
 * Author: eg
 * Created: February 14, 2013
 ********************************************************************
 * Data types of package Remote
 ********************************************************************)

TYPE
	XML_Remote_Type : 	STRUCT 
		CustomerNumber1 : DINT;
		ArticleNumber1 : DINT;
		RecipeNumber1 : INT;
		CustomerNumber2 : DINT;
		ArticleNumber2 : DINT;
		RecipeNumber2 : INT;
		Alarm : STRING[161];
		Info : STRING[161];
		AlarmID : DINT;
		OperatorID1 : DINT;
		OperatorID2 : DINT;
		ButtonAction : INT; (*We need only one button due to the resistive touch technology.*)
		ButtonText1 : STRING[41];
		ButtonText2 : STRING[41];
		ButtonText3 : STRING[41];
		ButtonText4 : STRING[41];
		ButtonText5 : STRING[41];
		OperatorStat1 : DINT;
		OperatorStat2 : DINT;
		RunMode : DINT; (*Bit array for Enabled, CAR/R, 1/2 Lanes, Operators and Stat handling.*)
		Language : INT;
		UpdateID1 : UDINT;
		UpdateID2 : UDINT;
	END_STRUCT;
END_TYPE
