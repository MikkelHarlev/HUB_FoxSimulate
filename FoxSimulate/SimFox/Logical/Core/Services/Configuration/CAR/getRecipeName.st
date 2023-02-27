(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: rcfg
 * File: getRecipeName.st
 * Author: eg
 * Created: April 16, 2014
 ********************************************************************
 * Implementation of program rcfg
 ********************************************************************) 

(* oh. *)
ACTION getRecipeName: 
	strcpy(ADR(nameStr),g_Core.System.Configuration.adrRCfgVarName);
	strcat(ADR(nameStr),ADR('['));
	itoa(g_Core.Services.CAR.Runtime.No[i].RecipeNumber -1, ADR(tempStr));
	strcat(ADR(nameStr),ADR(tempStr));
	strcat(ADR(nameStr),ADR('].'));
	strcat(ADR(nameStr),g_Core.System.Configuration.adrRCfgNameVarName);
	GetAdr(ADR(adrRecipeName), ADR(nameStr));
	IF (adrRecipeName > 0) THEN
		strcpy(ADR(recipeName), adrRecipeName);
	END_IF
END_ACTION
