(********************************************************************
 * COPYRIGHT -- JEDK
 ********************************************************************
 * Library: Util
 * File: TaskNameVar.st
 * Author: mha
 * Created: September 25, 2012
 ********************************************************************
 * Implementation of library Util
 ********************************************************************) 

// Make String for local variable. "LocalVar" to "Taskname:LocalVar"
// Example:
// TaskNameVar( VarName := 'LiftUpMotor', pVarOutput := g_TaskVariable );
// LiftUpMotor_Function(CntName:='g_MilliSeconds', MemName := g_TaskVariable, Mode := 1 );
//

FUNCTION TaskNameVar

ST_name(0, ADR(pVarOutput), ADR(Grp));
strcat(ADR(pVarOutput), ADR(':'));
strcat(ADR(pVarOutput), ADR(VarName));
TaskNameVar;

END_FUNCTION

