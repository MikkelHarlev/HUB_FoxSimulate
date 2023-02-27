PROGRAM _CYCLIC
(*--------------------------------------------------------------------------------------------------------------------
	Author:			Jensen Denmark

	Filename:    	settingstrig.src

	Description: 	Trigger usable RCfg settings for stackers, type and uniform.
	
	History:		31-10-2018		V1.00		CWH
					
															
------------------------------------------------ cyclic PROGRAM ----------------------------------------------------*)
	IF NOT g_Core.System.Runtime.isInitDone THEN
		RETURN;
	END_IF  

	// Control, is it the first time running this task
	IF g_HCfg.SettingsTrig = 112 THEN
	
		// Activate the setups
		IF EDGEPOS(g_Core.System.Runtime.isRunning) THEN // Activate at first start
			//******************************************************************************
		
			// Stacker setup		
			IF g_HCfg.CrossConveyor >0 THEN
				FOR i := 1 TO g_HCfg.NumberOfStackers DO
					g_MCfg.Outlet.CrossBeltNr[i] := 1;
				END_FOR
		
				CASE g_HCfg.NumberOfStackers OF			
					0:
						CASE g_HCfg.BlockDirection OF	//To set unload positions to the crosconveyor						
							0:	// Away from operator
								g_MCfg.Outlet.StartPosition[1]	:= 0;
								g_MCfg.Outlet.StartPosition[2]	:= 0;
								g_MCfg.Outlet.StartPosition[3]	:= 0;
								g_MCfg.Outlet.StartPosition[4]	:= 0;
								g_MCfg.Outlet.StartPosition[5]	:= 0;
								g_MCfg.Outlet.StartPosition[6]	:= 0;
								g_MCfg.Outlet.StartPosition[7]	:= 0;
								g_MCfg.Outlet.StartPosition[8]	:= 0;
								g_MCfg.Outlet.StartPosition[9]	:= 0;
								g_MCfg.Outlet.StartPosition[10]	:= 0;
				
								g_MCfg.Outlet.StopPosition[1]	:= 0;
								g_MCfg.Outlet.StopPosition[2]	:= 0;
								g_MCfg.Outlet.StopPosition[3]	:= 0;
								g_MCfg.Outlet.StopPosition[4]	:= 0;
								g_MCfg.Outlet.StopPosition[5]	:= 0;
								g_MCfg.Outlet.StopPosition[6]	:= 0;
								g_MCfg.Outlet.StopPosition[7]	:= 0;
								g_MCfg.Outlet.StopPosition[8]	:= 0;
								g_MCfg.Outlet.StopPosition[9]	:= 0;
								g_MCfg.Outlet.StopPosition[10]	:= 0;
					
							1:	// To operator
								g_MCfg.Outlet.StartPosition[10]	:= 0;
								g_MCfg.Outlet.StartPosition[9]	:= 0;
								g_MCfg.Outlet.StartPosition[8]	:= 0;
								g_MCfg.Outlet.StartPosition[7]	:= 0;
								g_MCfg.Outlet.StartPosition[6]	:= 0;
								g_MCfg.Outlet.StartPosition[5]	:= 0;
								g_MCfg.Outlet.StartPosition[4]	:= 0;
								g_MCfg.Outlet.StartPosition[3]	:= 0;
								g_MCfg.Outlet.StartPosition[2]	:= 0;
								g_MCfg.Outlet.StartPosition[1]	:= 0;
				
								g_MCfg.Outlet.StopPosition[10]	:= 0;
								g_MCfg.Outlet.StopPosition[9]	:= 0;
								g_MCfg.Outlet.StopPosition[8]	:= 0;
								g_MCfg.Outlet.StopPosition[7]	:= 0;
								g_MCfg.Outlet.StopPosition[6]	:= 0;
								g_MCfg.Outlet.StopPosition[5]	:= 0;
								g_MCfg.Outlet.StopPosition[4]	:= 0;
								g_MCfg.Outlet.StopPosition[3]	:= 0;
								g_MCfg.Outlet.StopPosition[2]	:= 0;
								g_MCfg.Outlet.StopPosition[1]	:= 0;
						END_CASE
			
					1:
						CASE g_HCfg.BlockDirection OF							
							0:	// Away from operator
								g_MCfg.Outlet.StartPosition[1]	:= 100;
								g_MCfg.Outlet.StartPosition[2]	:= 0;
								g_MCfg.Outlet.StartPosition[3]	:= 0;
								g_MCfg.Outlet.StartPosition[4]	:= 0;
								g_MCfg.Outlet.StartPosition[5]	:= 0;
								g_MCfg.Outlet.StartPosition[6]	:= 0;
								g_MCfg.Outlet.StartPosition[7]	:= 0;
								g_MCfg.Outlet.StartPosition[8]	:= 0;
								g_MCfg.Outlet.StartPosition[9]	:= 0;
								g_MCfg.Outlet.StartPosition[10]	:= 0;
				
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+500);
								g_MCfg.Outlet.StopPosition[2]	:= 0;
								g_MCfg.Outlet.StopPosition[3]	:= 0;
								g_MCfg.Outlet.StopPosition[4]	:= 0;
								g_MCfg.Outlet.StopPosition[5]	:= 0;
								g_MCfg.Outlet.StopPosition[6]	:= 0;
								g_MCfg.Outlet.StopPosition[7]	:= 0;
								g_MCfg.Outlet.StopPosition[8]	:= 0;
								g_MCfg.Outlet.StopPosition[9]	:= 0;
								g_MCfg.Outlet.StopPosition[10]	:= 0;
					
							1:	// To operator
								g_MCfg.Outlet.StartPosition[10]	:= 0;
								g_MCfg.Outlet.StartPosition[9]	:= 0;
								g_MCfg.Outlet.StartPosition[8]	:= 0;
								g_MCfg.Outlet.StartPosition[7]	:= 0;
								g_MCfg.Outlet.StartPosition[6]	:= 0;
								g_MCfg.Outlet.StartPosition[5]	:= 0;
								g_MCfg.Outlet.StartPosition[4]	:= 0;
								g_MCfg.Outlet.StartPosition[3]	:= 0;
								g_MCfg.Outlet.StartPosition[2]	:= 0;
								g_MCfg.Outlet.StartPosition[1]	:= 100;
				
								g_MCfg.Outlet.StopPosition[10]	:= 0;
								g_MCfg.Outlet.StopPosition[9]	:= 0;
								g_MCfg.Outlet.StopPosition[8]	:= 0;
								g_MCfg.Outlet.StopPosition[7]	:= 0;
								g_MCfg.Outlet.StopPosition[6]	:= 0;
								g_MCfg.Outlet.StopPosition[5]	:= 0;
								g_MCfg.Outlet.StopPosition[4]	:= 0;
								g_MCfg.Outlet.StopPosition[3]	:= 0;
								g_MCfg.Outlet.StopPosition[2]	:= 0;
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+500);
		
						END_CASE
			
					2:
						CASE g_HCfg.BlockDirection OF							
							0:	// Away from operator
								g_MCfg.Outlet.StartPosition[1]	:= 100;
								g_MCfg.Outlet.StartPosition[2]	:= (g_MCfg.Outlet.StartPosition[1]+500);
								g_MCfg.Outlet.StartPosition[3]	:= 0;
								g_MCfg.Outlet.StartPosition[4]	:= 0;
								g_MCfg.Outlet.StartPosition[5]	:= 0;
								g_MCfg.Outlet.StartPosition[6]	:= 0;
								g_MCfg.Outlet.StartPosition[7]	:= 0;
								g_MCfg.Outlet.StartPosition[8]	:= 0;
								g_MCfg.Outlet.StartPosition[9]	:= 0;
								g_MCfg.Outlet.StartPosition[10]	:= 0;
				
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+500);
								g_MCfg.Outlet.StopPosition[2]	:= (g_MCfg.Outlet.StartPosition[2]+500);
								g_MCfg.Outlet.StopPosition[3]	:= 0;
								g_MCfg.Outlet.StopPosition[4]	:= 0;
								g_MCfg.Outlet.StopPosition[5]	:= 0;
								g_MCfg.Outlet.StopPosition[6]	:= 0;
								g_MCfg.Outlet.StopPosition[7]	:= 0;
								g_MCfg.Outlet.StopPosition[8]	:= 0;
								g_MCfg.Outlet.StopPosition[9]	:= 0;
								g_MCfg.Outlet.StopPosition[10]	:= 0;
					
							1:	// To operator
								g_MCfg.Outlet.StartPosition[10]	:= 0;
								g_MCfg.Outlet.StartPosition[9]	:= 0;
								g_MCfg.Outlet.StartPosition[8]	:= 0;
								g_MCfg.Outlet.StartPosition[7]	:= 0;
								g_MCfg.Outlet.StartPosition[6]	:= 0;
								g_MCfg.Outlet.StartPosition[5]	:= 0;
								g_MCfg.Outlet.StartPosition[4]	:= 0;
								g_MCfg.Outlet.StartPosition[3]	:= 0;
								g_MCfg.Outlet.StartPosition[2]	:= 100;
								g_MCfg.Outlet.StartPosition[1]	:= (g_MCfg.Outlet.StartPosition[2]+500);
				
								g_MCfg.Outlet.StopPosition[10]	:= 0;
								g_MCfg.Outlet.StopPosition[9]	:= 0;
								g_MCfg.Outlet.StopPosition[8]	:= 0;
								g_MCfg.Outlet.StopPosition[7]	:= 0;
								g_MCfg.Outlet.StopPosition[6]	:= 0;
								g_MCfg.Outlet.StopPosition[5]	:= 0;
								g_MCfg.Outlet.StopPosition[4]	:= 0;
								g_MCfg.Outlet.StopPosition[3]	:= 0;
								g_MCfg.Outlet.StopPosition[2]	:= (g_MCfg.Outlet.StartPosition[2]+500);
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+500);
						END_CASE
			
					3:
						CASE g_HCfg.BlockDirection OF								
							0:	// Away from operator
								g_MCfg.Outlet.StartPosition[1]	:= 100;
								g_MCfg.Outlet.StartPosition[2]	:= (g_MCfg.Outlet.StartPosition[1]+500);
								g_MCfg.Outlet.StartPosition[3]	:= (g_MCfg.Outlet.StartPosition[2]+950);
								g_MCfg.Outlet.StartPosition[4]	:= 0;
								g_MCfg.Outlet.StartPosition[5]	:= 0;
								g_MCfg.Outlet.StartPosition[6]	:= 0;
								g_MCfg.Outlet.StartPosition[7]	:= 0;
								g_MCfg.Outlet.StartPosition[8]	:= 0;
								g_MCfg.Outlet.StartPosition[9]	:= 0;
								g_MCfg.Outlet.StartPosition[10]	:= 0;
				
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+500);
								g_MCfg.Outlet.StopPosition[2]	:= (g_MCfg.Outlet.StartPosition[2]+500);
								g_MCfg.Outlet.StopPosition[3]	:= (g_MCfg.Outlet.StartPosition[3]+500);
								g_MCfg.Outlet.StopPosition[4]	:= 0;
								g_MCfg.Outlet.StopPosition[5]	:= 0;
								g_MCfg.Outlet.StopPosition[6]	:= 0;
								g_MCfg.Outlet.StopPosition[7]	:= 0;
								g_MCfg.Outlet.StopPosition[8]	:= 0;
								g_MCfg.Outlet.StopPosition[9]	:= 0;
								g_MCfg.Outlet.StopPosition[10]	:= 0;
					
							1:	// To operator
								g_MCfg.Outlet.StartPosition[10]	:= 0;
								g_MCfg.Outlet.StartPosition[9]	:= 0;
								g_MCfg.Outlet.StartPosition[8]	:= 0;
								g_MCfg.Outlet.StartPosition[7]	:= 0;
								g_MCfg.Outlet.StartPosition[6]	:= 0;
								g_MCfg.Outlet.StartPosition[5]	:= 0;
								g_MCfg.Outlet.StartPosition[4]	:= 0;
								g_MCfg.Outlet.StartPosition[3]	:= 100;
								g_MCfg.Outlet.StartPosition[2]	:= (g_MCfg.Outlet.StartPosition[3]+950);
								g_MCfg.Outlet.StartPosition[1]	:= (g_MCfg.Outlet.StartPosition[2]+500);
				
								g_MCfg.Outlet.StopPosition[10]	:= 0;
								g_MCfg.Outlet.StopPosition[9]	:= 0;
								g_MCfg.Outlet.StopPosition[8]	:= 0;
								g_MCfg.Outlet.StopPosition[7]	:= 0;
								g_MCfg.Outlet.StopPosition[6]	:= 0;
								g_MCfg.Outlet.StopPosition[5]	:= 0;
								g_MCfg.Outlet.StopPosition[4]	:= 0;
								g_MCfg.Outlet.StopPosition[3]	:= (g_MCfg.Outlet.StartPosition[3]+600);
								g_MCfg.Outlet.StopPosition[2]	:= (g_MCfg.Outlet.StartPosition[2]+500);
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+500);
						END_CASE
			
					4:
						CASE g_HCfg.BlockDirection OF							
							0:	// Away from operator
								g_MCfg.Outlet.StartPosition[1]	:= 100;
								g_MCfg.Outlet.StartPosition[2]	:= (g_MCfg.Outlet.StartPosition[1]+500);
								g_MCfg.Outlet.StartPosition[3]	:= (g_MCfg.Outlet.StartPosition[2]+700);
								g_MCfg.Outlet.StartPosition[4]	:= (g_MCfg.Outlet.StartPosition[3]+500);
								g_MCfg.Outlet.StartPosition[5]	:= 0;
								g_MCfg.Outlet.StartPosition[6]	:= 0;
								g_MCfg.Outlet.StartPosition[7]	:= 0;
								g_MCfg.Outlet.StartPosition[8]	:= 0;
								g_MCfg.Outlet.StartPosition[9]	:= 0;
								g_MCfg.Outlet.StartPosition[10]	:= 0;
				
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+600);
								g_MCfg.Outlet.StopPosition[2]	:= (g_MCfg.Outlet.StartPosition[2]+600);
								g_MCfg.Outlet.StopPosition[3]	:= (g_MCfg.Outlet.StartPosition[3]+600);
								g_MCfg.Outlet.StopPosition[4]	:= (g_MCfg.Outlet.StartPosition[4]+600);
								g_MCfg.Outlet.StopPosition[5]	:= 0;
								g_MCfg.Outlet.StopPosition[6]	:= 0;
								g_MCfg.Outlet.StopPosition[7]	:= 0;
								g_MCfg.Outlet.StopPosition[8]	:= 0;
								g_MCfg.Outlet.StopPosition[9]	:= 0;
								g_MCfg.Outlet.StopPosition[10]	:= 0;
					
							1:	// To operator
								g_MCfg.Outlet.StartPosition[10]	:= 0;
								g_MCfg.Outlet.StartPosition[9]	:= 0;
								g_MCfg.Outlet.StartPosition[8]	:= 0;
								g_MCfg.Outlet.StartPosition[7]	:= 0;
								g_MCfg.Outlet.StartPosition[6]	:= 0;
								g_MCfg.Outlet.StartPosition[5]	:= 0;
								g_MCfg.Outlet.StartPosition[4]	:= 100;
								g_MCfg.Outlet.StartPosition[3]	:= (g_MCfg.Outlet.StartPosition[4]+500);
								g_MCfg.Outlet.StartPosition[2]	:= (g_MCfg.Outlet.StartPosition[3]+700);
								g_MCfg.Outlet.StartPosition[1]	:= (g_MCfg.Outlet.StartPosition[2]+500);
				
								g_MCfg.Outlet.StopPosition[10]	:= 0;
								g_MCfg.Outlet.StopPosition[9]	:= 0;
								g_MCfg.Outlet.StopPosition[8]	:= 0;
								g_MCfg.Outlet.StopPosition[7]	:= 0;
								g_MCfg.Outlet.StopPosition[6]	:= 0;
								g_MCfg.Outlet.StopPosition[5]	:= 0;
								g_MCfg.Outlet.StopPosition[4]	:= (g_MCfg.Outlet.StartPosition[4]+500);
								g_MCfg.Outlet.StopPosition[3]	:= (g_MCfg.Outlet.StartPosition[3]+600);
								g_MCfg.Outlet.StopPosition[2]	:= (g_MCfg.Outlet.StartPosition[2]+600);
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+500);
						END_CASE
			
					5:
						CASE g_HCfg.BlockDirection OF		
							0:	// Away from operator
								g_MCfg.Outlet.StartPosition[1]	:= 100;
								g_MCfg.Outlet.StartPosition[2]	:= (g_MCfg.Outlet.StartPosition[1]+500);
								g_MCfg.Outlet.StartPosition[3]	:= (g_MCfg.Outlet.StartPosition[2]+700);
								g_MCfg.Outlet.StartPosition[4]	:= (g_MCfg.Outlet.StartPosition[3]+500);
								g_MCfg.Outlet.StartPosition[5]	:= (g_MCfg.Outlet.StartPosition[4]+950);
								g_MCfg.Outlet.StartPosition[6]	:= 0;
								g_MCfg.Outlet.StartPosition[7]	:= 0;
								g_MCfg.Outlet.StartPosition[8]	:= 0;
								g_MCfg.Outlet.StartPosition[9]	:= 0;
								g_MCfg.Outlet.StartPosition[10]	:= 0;
				
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+600);
								g_MCfg.Outlet.StopPosition[2]	:= (g_MCfg.Outlet.StartPosition[2]+600);
								g_MCfg.Outlet.StopPosition[3]	:= (g_MCfg.Outlet.StartPosition[3]+600);
								g_MCfg.Outlet.StopPosition[4]	:= (g_MCfg.Outlet.StartPosition[4]+600);
								g_MCfg.Outlet.StopPosition[5]	:= (g_MCfg.Outlet.StartPosition[5]+600);
								g_MCfg.Outlet.StopPosition[6]	:= (g_MCfg.Outlet.StartPosition[6]+600);
								g_MCfg.Outlet.StopPosition[7]	:= 0;
								g_MCfg.Outlet.StopPosition[8]	:= 0;
								g_MCfg.Outlet.StopPosition[9]	:= 0;
								g_MCfg.Outlet.StopPosition[10]	:= 0;
					
							1:	// To operator
								g_MCfg.Outlet.StartPosition[10]	:= 0;
								g_MCfg.Outlet.StartPosition[9]	:= 0;
								g_MCfg.Outlet.StartPosition[8]	:= 0;
								g_MCfg.Outlet.StartPosition[7]	:= 0;
								g_MCfg.Outlet.StartPosition[6]	:= 0;
								g_MCfg.Outlet.StartPosition[5]	:= 100;
								g_MCfg.Outlet.StartPosition[4]	:= (g_MCfg.Outlet.StartPosition[5]+950);
								g_MCfg.Outlet.StartPosition[3]	:= (g_MCfg.Outlet.StartPosition[4]+500);
								g_MCfg.Outlet.StartPosition[2]	:= (g_MCfg.Outlet.StartPosition[3]+700);
								g_MCfg.Outlet.StartPosition[1]	:= (g_MCfg.Outlet.StartPosition[2]+500);
				
								g_MCfg.Outlet.StopPosition[10]	:= 0;
								g_MCfg.Outlet.StopPosition[9]	:= 0;
								g_MCfg.Outlet.StopPosition[8]	:= 0;
								g_MCfg.Outlet.StopPosition[7]	:= 0;
								g_MCfg.Outlet.StopPosition[6]	:= 0;
								g_MCfg.Outlet.StopPosition[5]	:= (g_MCfg.Outlet.StartPosition[5]+600);
								g_MCfg.Outlet.StopPosition[4]	:= (g_MCfg.Outlet.StartPosition[4]+600);
								g_MCfg.Outlet.StopPosition[3]	:= (g_MCfg.Outlet.StartPosition[3]+600);
								g_MCfg.Outlet.StopPosition[2]	:= (g_MCfg.Outlet.StartPosition[2]+600);
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+600);
						END_CASE
			
					6:
						CASE g_HCfg.BlockDirection OF		
							0:	// Away from operator
								g_MCfg.Outlet.StartPosition[1]	:= 100;
								g_MCfg.Outlet.StartPosition[2]	:= (g_MCfg.Outlet.StartPosition[1]+500);
								g_MCfg.Outlet.StartPosition[3]	:= (g_MCfg.Outlet.StartPosition[2]+700);
								g_MCfg.Outlet.StartPosition[4]	:= (g_MCfg.Outlet.StartPosition[3]+500);
								g_MCfg.Outlet.StartPosition[5]	:= (g_MCfg.Outlet.StartPosition[4]+700);
								g_MCfg.Outlet.StartPosition[6]	:= (g_MCfg.Outlet.StartPosition[5]+500);
								g_MCfg.Outlet.StartPosition[7]	:= 0;
								g_MCfg.Outlet.StartPosition[8]	:= 0;
								g_MCfg.Outlet.StartPosition[9]	:= 0;
								g_MCfg.Outlet.StartPosition[10]	:= 0;
				
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+600);
								g_MCfg.Outlet.StopPosition[2]	:= (g_MCfg.Outlet.StartPosition[2]+600);
								g_MCfg.Outlet.StopPosition[3]	:= (g_MCfg.Outlet.StartPosition[3]+600);
								g_MCfg.Outlet.StopPosition[4]	:= (g_MCfg.Outlet.StartPosition[4]+600);
								g_MCfg.Outlet.StopPosition[5]	:= (g_MCfg.Outlet.StartPosition[5]+600);
								g_MCfg.Outlet.StopPosition[6]	:= (g_MCfg.Outlet.StartPosition[6]+600);
								g_MCfg.Outlet.StopPosition[7]	:= 0;
								g_MCfg.Outlet.StopPosition[8]	:= 0;
								g_MCfg.Outlet.StopPosition[9]	:= 0;
								g_MCfg.Outlet.StopPosition[10]	:= 0;
					
							1:	// To operator
								g_MCfg.Outlet.StartPosition[10]	:= 0;
								g_MCfg.Outlet.StartPosition[9]	:= 0;
								g_MCfg.Outlet.StartPosition[8]	:= 0;
								g_MCfg.Outlet.StartPosition[7]	:= 0;
								g_MCfg.Outlet.StartPosition[6]	:= 100;
								g_MCfg.Outlet.StartPosition[5]	:= (g_MCfg.Outlet.StartPosition[6]+500);
								g_MCfg.Outlet.StartPosition[4]	:= (g_MCfg.Outlet.StartPosition[5]+700);
								g_MCfg.Outlet.StartPosition[3]	:= (g_MCfg.Outlet.StartPosition[4]+500);
								g_MCfg.Outlet.StartPosition[2]	:= (g_MCfg.Outlet.StartPosition[3]+700);
								g_MCfg.Outlet.StartPosition[1]	:= (g_MCfg.Outlet.StartPosition[2]+500);
				
								g_MCfg.Outlet.StopPosition[10]	:= 0;
								g_MCfg.Outlet.StopPosition[9]	:= 0;
								g_MCfg.Outlet.StopPosition[8]	:= 0;
								g_MCfg.Outlet.StopPosition[7]	:= 0;
								g_MCfg.Outlet.StopPosition[6]	:= (g_MCfg.Outlet.StartPosition[6]+600);
								g_MCfg.Outlet.StopPosition[5]	:= (g_MCfg.Outlet.StartPosition[5]+600);
								g_MCfg.Outlet.StopPosition[4]	:= (g_MCfg.Outlet.StartPosition[4]+600);
								g_MCfg.Outlet.StopPosition[3]	:= (g_MCfg.Outlet.StartPosition[3]+600);
								g_MCfg.Outlet.StopPosition[2]	:= (g_MCfg.Outlet.StartPosition[2]+600);
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+600);
						END_CASE
			
					7:
						CASE g_HCfg.BlockDirection OF									
							0:	// Away from operator
								g_MCfg.Outlet.StartPosition[1]	:= 100;
								g_MCfg.Outlet.StartPosition[2]	:= (g_MCfg.Outlet.StartPosition[1]+500);
								g_MCfg.Outlet.StartPosition[3]	:= (g_MCfg.Outlet.StartPosition[2]+700);
								g_MCfg.Outlet.StartPosition[4]	:= (g_MCfg.Outlet.StartPosition[3]+500);
								g_MCfg.Outlet.StartPosition[5]	:= (g_MCfg.Outlet.StartPosition[4]+700);
								g_MCfg.Outlet.StartPosition[6]	:= (g_MCfg.Outlet.StartPosition[5]+500);
								g_MCfg.Outlet.StartPosition[7]	:= (g_MCfg.Outlet.StartPosition[6]+950);
								g_MCfg.Outlet.StartPosition[8]	:= 0;
								g_MCfg.Outlet.StartPosition[9]	:= 0;
								g_MCfg.Outlet.StartPosition[10]	:= 0;
				
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+600);
								g_MCfg.Outlet.StopPosition[2]	:= (g_MCfg.Outlet.StartPosition[2]+600);
								g_MCfg.Outlet.StopPosition[3]	:= (g_MCfg.Outlet.StartPosition[3]+600);
								g_MCfg.Outlet.StopPosition[4]	:= (g_MCfg.Outlet.StartPosition[4]+600);
								g_MCfg.Outlet.StopPosition[5]	:= (g_MCfg.Outlet.StartPosition[5]+600);
								g_MCfg.Outlet.StopPosition[6]	:= (g_MCfg.Outlet.StartPosition[6]+600);
								g_MCfg.Outlet.StopPosition[7]	:= (g_MCfg.Outlet.StartPosition[7]+600);
								g_MCfg.Outlet.StopPosition[8]	:= 0;
								g_MCfg.Outlet.StopPosition[9]	:= 0;
								g_MCfg.Outlet.StopPosition[10]	:= 0;
					
							1:	// To operator
								g_MCfg.Outlet.StartPosition[10]	:= 0;
								g_MCfg.Outlet.StartPosition[9]	:= 0;
								g_MCfg.Outlet.StartPosition[8]	:= 0;
								g_MCfg.Outlet.StartPosition[7]	:= 100;
								g_MCfg.Outlet.StartPosition[6]	:= (g_MCfg.Outlet.StartPosition[7]+950);
								g_MCfg.Outlet.StartPosition[5]	:= (g_MCfg.Outlet.StartPosition[6]+500);
								g_MCfg.Outlet.StartPosition[4]	:= (g_MCfg.Outlet.StartPosition[5]+700);
								g_MCfg.Outlet.StartPosition[3]	:= (g_MCfg.Outlet.StartPosition[4]+500);
								g_MCfg.Outlet.StartPosition[2]	:= (g_MCfg.Outlet.StartPosition[3]+700);
								g_MCfg.Outlet.StartPosition[1]	:= (g_MCfg.Outlet.StartPosition[2]+500);
				
								g_MCfg.Outlet.StopPosition[10]	:= 0;
								g_MCfg.Outlet.StopPosition[9]	:= 0;
								g_MCfg.Outlet.StopPosition[8]	:= 0;
								g_MCfg.Outlet.StopPosition[7]	:= (g_MCfg.Outlet.StartPosition[7]+600);
								g_MCfg.Outlet.StopPosition[6]	:= (g_MCfg.Outlet.StartPosition[6]+600);
								g_MCfg.Outlet.StopPosition[5]	:= (g_MCfg.Outlet.StartPosition[5]+600);
								g_MCfg.Outlet.StopPosition[4]	:= (g_MCfg.Outlet.StartPosition[4]+600);
								g_MCfg.Outlet.StopPosition[3]	:= (g_MCfg.Outlet.StartPosition[3]+600);
								g_MCfg.Outlet.StopPosition[2]	:= (g_MCfg.Outlet.StartPosition[2]+600);
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+600);
						END_CASE
			
					8:
						CASE g_HCfg.BlockDirection OF		
							0:	// Away from operator
								g_MCfg.Outlet.StartPosition[1]	:= 100;
								g_MCfg.Outlet.StartPosition[2]	:= (g_MCfg.Outlet.StartPosition[1]+500);
								g_MCfg.Outlet.StartPosition[3]	:= (g_MCfg.Outlet.StartPosition[2]+700);
								g_MCfg.Outlet.StartPosition[4]	:= (g_MCfg.Outlet.StartPosition[3]+500);
								g_MCfg.Outlet.StartPosition[5]	:= (g_MCfg.Outlet.StartPosition[4]+700);
								g_MCfg.Outlet.StartPosition[6]	:= (g_MCfg.Outlet.StartPosition[5]+500);
								g_MCfg.Outlet.StartPosition[7]	:= (g_MCfg.Outlet.StartPosition[6]+700);
								g_MCfg.Outlet.StartPosition[8]	:= (g_MCfg.Outlet.StartPosition[7]+500);
								g_MCfg.Outlet.StartPosition[9]	:= 0;
								g_MCfg.Outlet.StartPosition[10]	:= 0;
				
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+600);
								g_MCfg.Outlet.StopPosition[2]	:= (g_MCfg.Outlet.StartPosition[2]+600);
								g_MCfg.Outlet.StopPosition[3]	:= (g_MCfg.Outlet.StartPosition[3]+600);
								g_MCfg.Outlet.StopPosition[4]	:= (g_MCfg.Outlet.StartPosition[4]+600);
								g_MCfg.Outlet.StopPosition[5]	:= (g_MCfg.Outlet.StartPosition[5]+600);
								g_MCfg.Outlet.StopPosition[6]	:= (g_MCfg.Outlet.StartPosition[6]+600);
								g_MCfg.Outlet.StopPosition[7]	:= (g_MCfg.Outlet.StartPosition[7]+600);
								g_MCfg.Outlet.StopPosition[8]	:= (g_MCfg.Outlet.StartPosition[8]+600);
								g_MCfg.Outlet.StopPosition[9]	:= 0;
								g_MCfg.Outlet.StopPosition[10]	:= 0;
					
							1:	// To operator
								g_MCfg.Outlet.StartPosition[10]	:= 0;
								g_MCfg.Outlet.StartPosition[9]	:= 0;
								g_MCfg.Outlet.StartPosition[8]	:= 100;
								g_MCfg.Outlet.StartPosition[7]	:= (g_MCfg.Outlet.StartPosition[8]+500);
								g_MCfg.Outlet.StartPosition[6]	:= (g_MCfg.Outlet.StartPosition[7]+700);
								g_MCfg.Outlet.StartPosition[5]	:= (g_MCfg.Outlet.StartPosition[6]+500);
								g_MCfg.Outlet.StartPosition[4]	:= (g_MCfg.Outlet.StartPosition[5]+700);
								g_MCfg.Outlet.StartPosition[3]	:= (g_MCfg.Outlet.StartPosition[4]+500);
								g_MCfg.Outlet.StartPosition[2]	:= (g_MCfg.Outlet.StartPosition[3]+700);
								g_MCfg.Outlet.StartPosition[1]	:= (g_MCfg.Outlet.StartPosition[2]+500);
				
								g_MCfg.Outlet.StopPosition[10]	:= 0;
								g_MCfg.Outlet.StopPosition[9]	:= 0;
								g_MCfg.Outlet.StopPosition[8]	:= (g_MCfg.Outlet.StartPosition[8]+600);
								g_MCfg.Outlet.StopPosition[7]	:= (g_MCfg.Outlet.StartPosition[7]+600);
								g_MCfg.Outlet.StopPosition[6]	:= (g_MCfg.Outlet.StartPosition[6]+600);
								g_MCfg.Outlet.StopPosition[5]	:= (g_MCfg.Outlet.StartPosition[5]+600);
								g_MCfg.Outlet.StopPosition[4]	:= (g_MCfg.Outlet.StartPosition[4]+600);
								g_MCfg.Outlet.StopPosition[3]	:= (g_MCfg.Outlet.StartPosition[3]+600);
								g_MCfg.Outlet.StopPosition[2]	:= (g_MCfg.Outlet.StartPosition[2]+600);
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+600);
						END_CASE	
			
					9:
						CASE g_HCfg.BlockDirection OF		
							0:	// Away from operator
								g_MCfg.Outlet.StartPosition[1]	:= 100;
								g_MCfg.Outlet.StartPosition[2]	:= (g_MCfg.Outlet.StartPosition[1]+500);
								g_MCfg.Outlet.StartPosition[3]	:= (g_MCfg.Outlet.StartPosition[2]+700);
								g_MCfg.Outlet.StartPosition[4]	:= (g_MCfg.Outlet.StartPosition[3]+500);
								g_MCfg.Outlet.StartPosition[5]	:= (g_MCfg.Outlet.StartPosition[4]+700);
								g_MCfg.Outlet.StartPosition[6]	:= (g_MCfg.Outlet.StartPosition[5]+500);
								g_MCfg.Outlet.StartPosition[7]	:= (g_MCfg.Outlet.StartPosition[6]+700);
								g_MCfg.Outlet.StartPosition[8]	:= (g_MCfg.Outlet.StartPosition[7]+500);
								g_MCfg.Outlet.StartPosition[9]	:= (g_MCfg.Outlet.StartPosition[8]+950);
								g_MCfg.Outlet.StartPosition[10]	:= 0;
				
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+600);
								g_MCfg.Outlet.StopPosition[2]	:= (g_MCfg.Outlet.StartPosition[2]+600);
								g_MCfg.Outlet.StopPosition[3]	:= (g_MCfg.Outlet.StartPosition[3]+600);
								g_MCfg.Outlet.StopPosition[4]	:= (g_MCfg.Outlet.StartPosition[4]+600);
								g_MCfg.Outlet.StopPosition[5]	:= (g_MCfg.Outlet.StartPosition[5]+600);
								g_MCfg.Outlet.StopPosition[6]	:= (g_MCfg.Outlet.StartPosition[6]+600);
								g_MCfg.Outlet.StopPosition[7]	:= (g_MCfg.Outlet.StartPosition[7]+600);
								g_MCfg.Outlet.StopPosition[8]	:= (g_MCfg.Outlet.StartPosition[8]+600);
								g_MCfg.Outlet.StopPosition[9]	:= (g_MCfg.Outlet.StartPosition[9]+600);
								g_MCfg.Outlet.StopPosition[10]	:= 0;
					
							1:	// To operator
								g_MCfg.Outlet.StartPosition[10]	:= 0;
								g_MCfg.Outlet.StartPosition[9]	:= 100;
								g_MCfg.Outlet.StartPosition[8]	:= (g_MCfg.Outlet.StartPosition[9]+950);
								g_MCfg.Outlet.StartPosition[7]	:= (g_MCfg.Outlet.StartPosition[8]+500);
								g_MCfg.Outlet.StartPosition[6]	:= (g_MCfg.Outlet.StartPosition[7]+700);
								g_MCfg.Outlet.StartPosition[5]	:= (g_MCfg.Outlet.StartPosition[6]+500);
								g_MCfg.Outlet.StartPosition[4]	:= (g_MCfg.Outlet.StartPosition[5]+700);
								g_MCfg.Outlet.StartPosition[3]	:= (g_MCfg.Outlet.StartPosition[4]+500);
								g_MCfg.Outlet.StartPosition[2]	:= (g_MCfg.Outlet.StartPosition[3]+700);
								g_MCfg.Outlet.StartPosition[1]	:= (g_MCfg.Outlet.StartPosition[2]+500);
				
								g_MCfg.Outlet.StopPosition[10]	:= 0;
								g_MCfg.Outlet.StopPosition[9]	:= (g_MCfg.Outlet.StartPosition[9]+600);
								g_MCfg.Outlet.StopPosition[8]	:= (g_MCfg.Outlet.StartPosition[8]+600);
								g_MCfg.Outlet.StopPosition[7]	:= (g_MCfg.Outlet.StartPosition[7]+600);
								g_MCfg.Outlet.StopPosition[6]	:= (g_MCfg.Outlet.StartPosition[6]+600);
								g_MCfg.Outlet.StopPosition[5]	:= (g_MCfg.Outlet.StartPosition[5]+600);
								g_MCfg.Outlet.StopPosition[4]	:= (g_MCfg.Outlet.StartPosition[4]+600);
								g_MCfg.Outlet.StopPosition[3]	:= (g_MCfg.Outlet.StartPosition[3]+600);
								g_MCfg.Outlet.StopPosition[2]	:= (g_MCfg.Outlet.StartPosition[2]+600);
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+600);
						END_CASE	
			
					10:
						CASE g_HCfg.BlockDirection OF							
							0:	// Away from operator
								g_MCfg.Outlet.StartPosition[1]	:= 100;
								g_MCfg.Outlet.StartPosition[2]	:= (g_MCfg.Outlet.StartPosition[1]+500);
								g_MCfg.Outlet.StartPosition[3]	:= (g_MCfg.Outlet.StartPosition[2]+700);
								g_MCfg.Outlet.StartPosition[4]	:= (g_MCfg.Outlet.StartPosition[3]+500);
								g_MCfg.Outlet.StartPosition[5]	:= (g_MCfg.Outlet.StartPosition[4]+700);
								g_MCfg.Outlet.StartPosition[6]	:= (g_MCfg.Outlet.StartPosition[5]+500);
								g_MCfg.Outlet.StartPosition[7]	:= (g_MCfg.Outlet.StartPosition[6]+700);
								g_MCfg.Outlet.StartPosition[8]	:= (g_MCfg.Outlet.StartPosition[7]+500);
								g_MCfg.Outlet.StartPosition[9]	:= (g_MCfg.Outlet.StartPosition[8]+700);
								g_MCfg.Outlet.StartPosition[10]	:= (g_MCfg.Outlet.StartPosition[9]+500);
				
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+600);
								g_MCfg.Outlet.StopPosition[2]	:= (g_MCfg.Outlet.StartPosition[2]+600);
								g_MCfg.Outlet.StopPosition[3]	:= (g_MCfg.Outlet.StartPosition[3]+600);
								g_MCfg.Outlet.StopPosition[4]	:= (g_MCfg.Outlet.StartPosition[4]+600);
								g_MCfg.Outlet.StopPosition[5]	:= (g_MCfg.Outlet.StartPosition[5]+600);
								g_MCfg.Outlet.StopPosition[6]	:= (g_MCfg.Outlet.StartPosition[6]+600);
								g_MCfg.Outlet.StopPosition[7]	:= (g_MCfg.Outlet.StartPosition[7]+600);
								g_MCfg.Outlet.StopPosition[8]	:= (g_MCfg.Outlet.StartPosition[8]+600);
								g_MCfg.Outlet.StopPosition[9]	:= (g_MCfg.Outlet.StartPosition[9]+600);
								g_MCfg.Outlet.StopPosition[10]	:= (g_MCfg.Outlet.StartPosition[10]+600);
					
							1:	// To operator
								g_MCfg.Outlet.StartPosition[10]	:= 100;
								g_MCfg.Outlet.StartPosition[9]	:= (g_MCfg.Outlet.StartPosition[10]+500);
								g_MCfg.Outlet.StartPosition[8]	:= (g_MCfg.Outlet.StartPosition[9]+700);
								g_MCfg.Outlet.StartPosition[7]	:= (g_MCfg.Outlet.StartPosition[8]+500);
								g_MCfg.Outlet.StartPosition[6]	:= (g_MCfg.Outlet.StartPosition[7]+700);
								g_MCfg.Outlet.StartPosition[5]	:= (g_MCfg.Outlet.StartPosition[6]+500);
								g_MCfg.Outlet.StartPosition[4]	:= (g_MCfg.Outlet.StartPosition[5]+700);
								g_MCfg.Outlet.StartPosition[3]	:= (g_MCfg.Outlet.StartPosition[4]+500);
								g_MCfg.Outlet.StartPosition[2]	:= (g_MCfg.Outlet.StartPosition[3]+700);
								g_MCfg.Outlet.StartPosition[1]	:= (g_MCfg.Outlet.StartPosition[2]+500);
				
								g_MCfg.Outlet.StopPosition[10]	:= (g_MCfg.Outlet.StartPosition[10]+600);
								g_MCfg.Outlet.StopPosition[9]	:= (g_MCfg.Outlet.StartPosition[9]+600);
								g_MCfg.Outlet.StopPosition[8]	:= (g_MCfg.Outlet.StartPosition[8]+600);
								g_MCfg.Outlet.StopPosition[7]	:= (g_MCfg.Outlet.StartPosition[7]+600);
								g_MCfg.Outlet.StopPosition[6]	:= (g_MCfg.Outlet.StartPosition[6]+600);
								g_MCfg.Outlet.StopPosition[5]	:= (g_MCfg.Outlet.StartPosition[5]+600);
								g_MCfg.Outlet.StopPosition[4]	:= (g_MCfg.Outlet.StartPosition[4]+600);
								g_MCfg.Outlet.StopPosition[3]	:= (g_MCfg.Outlet.StartPosition[3]+600);
								g_MCfg.Outlet.StopPosition[2]	:= (g_MCfg.Outlet.StartPosition[2]+600);
								g_MCfg.Outlet.StopPosition[1]	:= (g_MCfg.Outlet.StartPosition[1]+600);
						END_CASE	
				END_CASE
			END_IF
	
			// Heavy Garment Setup
			IF g_HCfg.HeavyGarment THEN

			END_IF
			// Delete rcp if not in machine
			IF NOT g_HCfg.HeavyGarment THEN
				g_ACfg[2].Name	:= '';
				g_ACfg[3].Name	:= '';
			END_IF
		
			// Micro Setup
			IF g_HCfg.Micro THEN
			
			END_IF
			// Delete rcp if not in machine
			IF NOT g_HCfg.Micro THEN
				g_ACfg[4].Name	:= '';
			END_IF
		
			// Bib Setup
			IF g_HCfg.BibOverall THEN
			
			END_IF
			// Delete rcp if not in machine
			IF NOT g_HCfg.BibOverall THEN
				g_ACfg[5].Name	:= '';
			END_IF
		
			// Duo Setup
			IF g_HCfg.DuoInlet THEN
			
			END_IF
			// Delete rcp if not in machine
			IF NOT g_HCfg.DuoInlet THEN
				g_ACfg[75].Name	:= '';
				g_ACfg[76].Name	:= '';
				g_ACfg[77].Name	:= '';
			END_IF

			// XtremeHeavy Setup
			IF g_HCfg.XtremeHeavy THEN // Bathrope
				g_RCfg[72].XtremeHeavy.FXtremeGap			:= 1;	// Bathrope kat 72 rcp	// CWH: Hedder måske LocalFoldProgram.XtremeHeavy.FXtremeGap
				g_RCfg[72].XtremeHeavy.FSlackStackerBelt	:= 1;	// Bathrope kat 72 rcp
				g_RCfg[72].XtremeHeavy.FRaiseTiltConv		:= 1;	// Bathrope kat 72 rcp
			
				g_ACfg[6].XtremeHeavy		:= 1;
				g_ACfg[6].XtremeRaiseBlades	:= 1;
			END_IF
			// Delete rcp if not in machine
			IF NOT g_HCfg.XtremeHeavy THEN
				g_ACfg[6].Name				:= '';	// g_ACfg[7].Name,Bathrope
			END_IF
		
			// Fox MF Setup
			IF g_HCfg.FeedManual THEN
				FOR i := 1 TO 99 DO
					g_ACfg[i].ArmBlowDelay[0]	:= 740;	// ELSE 580
					g_ACfg[i].ArmBlowDelay[1]	:= 700;	// ELSE 325
				END_FOR
			END_IF
		
			//******************************************************************************
		
			// Save
			g_HCfg.SettingsTrig		:= 0;
			g_Core.Services.Recipe.Interface.isCmdSave := 1;	// Save changes to RCfg Timer lists
			g_Core.Services.Machine.Interface.isCmdSave := 1;	// Save changes to MCfg Timer lists
			g_Core.Services.Hardware.Interface.isCmdSave := 1;	// Save changes to HCfg Timer lists
			g_Core.Services.AutoProg.Interface.isCmdSave := 1;	// Save changes to AutoProgram	
			g_Core.Services.System.Interface.isCmdSave := 1;	// Save changes to SystemFile
			rLoadStart := TRUE;
		
		END_IF
	ELSE
		IF rLoadStart THEN
			TON_LoadDelay.IN := TRUE;
			IF TON_LoadDelay.Q THEN
				g_Core.Services.Machine.Interface.isCmdLoad	:= TRUE;
				rLoadStart:= FALSE;
			END_IF
		ELSE
			// Stop this task, if it's not the first time running this task
			IF ST_ident(ADR('settingstr'), 0, ADR(ident)) = 0 THEN
				ST_tmp_suspend(ident);
			END_IF
		END_IF;
		TON_LoadDelay.PT	:= T#5000ms;
		TON_LoadDelay();
	END_IF
END_PROGRAM