(********************************************************************
 * COPYRIGHT -- JENSEN Denmark A/S
 ********************************************************************
 * Program: TimerVisibilityTest
 * File: TimerVisibilityTest.st
 * Author: eg
 * Created: July 31, 2013
 ********************************************************************
 * Implementation of program TimerVisibilityTest
 ********************************************************************)

PROGRAM _INIT

	strParItem 		:= 'g_RCfg.RcpText';
	strI;
	tmpString;
	noOfTestRuns 	:= 0;
	y				:= 1;
	z				:= 5;
END_PROGRAM


PROGRAM _CYCLIC

	IF (noOfTestRuns > 0 AND noOfTestRuns > i AND NOT g_Core.Services.Recipe.Interface.isCmdUpdatePar)  THEN
		IF (i MOD 2) > 0 THEN
			newParLevel := 1;
		ELSE
			newParLevel := 2;
		END_IF
		TestParList := TRUE;
		i := i + 1;
	END_IF

	
	IF (TestParList) THEN
		TestParList := FALSE;
		FOR x := y TO z DO
			itoa(x, ADR(strI));
			tmpString := strParItem;
			strcat(ADR(tmpString), ADR(strI));
			RcpShowLevel_0(Ident := g_Core.Services.Recipe.Runtime.ParIdent, StrVarName := tmpString, Level := newParLevel);
		END_FOR
		g_Core.Services.Recipe.Interface.isCmdUpdatePar := TRUE;
		triggerCounter := triggerCounter + 1;
	END_IF

END_PROGRAM
