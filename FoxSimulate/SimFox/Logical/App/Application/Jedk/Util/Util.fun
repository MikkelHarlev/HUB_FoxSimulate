(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Util
 * File: Util.fun
 * Author: mha
 * Created: September 25, 2012
 ********************************************************************
 * Functions and function blocks of library Util
 ********************************************************************)

FUNCTION TaskNameVar : BOOL (*TaskNameVar( VarName := 'Guide', pVarOutput := g_TaskVariable );*)
	VAR_INPUT
		VarName : STRING[20];
		pVarOutput : STRING[30];
	END_VAR
	VAR
		Grp : UDINT;
	END_VAR
END_FUNCTION
