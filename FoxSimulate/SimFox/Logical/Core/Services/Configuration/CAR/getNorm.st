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
ACTION getRecipeNorm: 
	strcpy(ADR(nameStr),g_Core.System.Configuration.adrRCfgVarName);
	strcat(ADR(nameStr),ADR('['));
	itoa(g_Core.Services.CAR.Runtime.No[i].RecipeNumber -1, ADR(tempStr));
	strcat(ADR(nameStr),ADR(tempStr));
	strcat(ADR(nameStr),ADR('].'));
	strcat(ADR(nameStr),g_Core.System.Configuration.adrRCfgNormVarName);
	GetAdr(ADR(adrRecipeNorm), ADR(nameStr));
	IF (adrRecipeNorm > 0) THEN
		pNorm ACCESS adrRecipeNorm;
		Norm := pNorm;
	END_IF
END_ACTION
