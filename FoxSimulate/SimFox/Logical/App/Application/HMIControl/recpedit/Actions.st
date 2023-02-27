(********************************************************************
 * COPYRIGHT -- IT
 ********************************************************************
 * Program: recpedit
 * File: Actions.st
 * Author: mariw
 * Created: August 23, 2010
 ********************************************************************
 * Implementation of program recpedit
 ********************************************************************) 

(*Set a parameter value to all other recipes when a certain button in Visu beside it is pressed*)
ACTION SetToAllRecipes: 

	FOR n:=0 TO 99 DO
		//outlet
		IF SetToAllRcp.OutletDelayRollOffOut THEN
			callRecp; CopyToProgram.Outlet.DelayRollOffOut:=LocalFoldProgram.Outlet.DelayRollOffOut;			
		ELSIF SetToAllRcp.OutletFullIndexingTime THEN
			;
(*			callRecp; CopyToProgram.Outlet.FullIndexingTime:=LocalFoldProgram.Outlet.FullIndexingTime;				*)
		ELSIF SetToAllRcp.OutletNumberOfProducts THEN
			callRecp; CopyToProgram.Outlet.NumberOfProducts:=LocalFoldProgram.Outlet.NumberOfProducts;				
		ELSIF SetToAllRcp.StackerCoupling THEN
			callRecp; CopyToProgram.Stacker.StackerSelection:=LocalFoldProgram.Stacker.StackerSelection;				
		ELSIF SetToAllRcp.StackerEdge THEN
			callRecp; CopyToProgram.Stacker.StopLeadingOrRearEdge:=LocalFoldProgram.Stacker.StopLeadingOrRearEdge;				
		ELSIF SetToAllRcp.StackerJenWayDest THEN
			callRecp; CopyToProgram.Stacker.JenWayDestination:=LocalFoldProgram.Stacker.JenWayDestination;				
		ELSIF SetToAllRcp.StackerStopPosition THEN
			callRecp; CopyToProgram.Stacker.StopPosition:=LocalFoldProgram.Stacker.StopPosition;				
		//lateral
		ELSIF SetToAllRcp.LateralBladeBackTime THEN
			callRecp; CopyToProgram.Lateral.BladeBackTime:=LocalFoldProgram.Lateral.BladeBackTime;				
		ELSIF SetToAllRcp.LateralLeftBladeOnTime THEN
			callRecp; CopyToProgram.Lateral.OnTimeLeftBlade:=LocalFoldProgram.Lateral.OnTimeLeftBlade;				
		ELSIF SetToAllRcp.LateralLeftBladeStartDelay THEN
			callRecp; CopyToProgram.Lateral.StartDelayLeftBlade:=LocalFoldProgram.Lateral.StartDelayLeftBlade;				
		ELSIF SetToAllRcp.LateralRightBladeOnTime THEN
			callRecp; CopyToProgram.Lateral.OnTimeRightBlade:=LocalFoldProgram.Lateral.OnTimeRightBlade;				
		ELSIF SetToAllRcp.LateralRightBladeStartDelay THEN
			callRecp; CopyToProgram.Lateral.StartDelayRightBlade:=LocalFoldProgram.Lateral.StartDelayRightBlade;				
		ELSIF SetToAllRcp.LateralWidthFirst THEN
			callRecp; CopyToProgram.Lateral.WidthFirst:=LocalFoldProgram.Lateral.WidthFirst;				
		ELSIF SetToAllRcp.LateralWidthLast THEN
			callRecp; CopyToProgram.Lateral.WidthLast:=LocalFoldProgram.Lateral.WidthLast;				
		END_IF

	END_FOR;
		
END_ACTION

ACTION callRecp :
	
		CopyToProgram ACCESS(g_Core.Services.Recipe.Runtime.recipePointer + (SIZEOF(LocalFoldProgram) * LIMIT(0, (n-1), MAX_NUMBER_OF_CATEGORIES)));	
	
END_ACTION
