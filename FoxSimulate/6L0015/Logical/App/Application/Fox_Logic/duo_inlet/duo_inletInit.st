(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: duo_inlet
 * File: duo_inletInit.st
 * Author: munchp
 * Created: April 06, 2017
 ********************************************************************
 * Implementation of program duo_inlet
 ********************************************************************)

PROGRAM _INIT
	
	(* Individual settings for the task *)
	g_DuoInletProcess.Common.Description 									:= 'Duo Inlet';
	InitFoldTask(g_DuoInletProcess.Common,g_MachineManager[g_DuoInletProcess.Common.MachineManagerIndex]);
	filterValue := 10;

	// Fox Duo ------------------------------
	ISDuoCustChange;
	ISInlet;
	ISSort;
	IBInlet;
	IBLF;
	IWhDuo;
	IBAutoL[2];
	IBAutoL[3];
	IBAutoL[4];
	IBAutoW[2];
	IBAutoW[3];
	IBAutoW[4];
	QCleanVentDuo;
	QMVacuumDuo;
	QMInletDuo;
	RSelectProgram;
	rStackSelect;
	g_FlipInlet;
	DUO_FLIP_INLET_02;

	// Init
	IF oldFoldProgram = 0 THEN
 		oldFoldProgram := 1;
	ELSE	
		g_DuoInletProcess.Common.Product.FoldProgram := oldFoldProgram;
	END_IF
	g_DuoInletProcess.Common.ReadParameters := TRUE;
	
	g_DuoInletProcess.SortOutDuoEnd := RetSortOut;
	g_DuoInletProcess.AutoLengthON := RetAutoLength;
	g_DuoInletProcess.ManualFeed := RetManFeed;	
	
	//Inverter Speeds
	g_DuoInletProcess.inverterSpeed := 1380;
	LFoldSpeed := 1100;
	
	// Powersave after 30 sec
	this.powersave.timeBeforePowersave := 30;
END_PROGRAM

