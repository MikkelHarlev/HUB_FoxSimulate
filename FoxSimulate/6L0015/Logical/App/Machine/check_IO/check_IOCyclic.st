(********************************************************************
 * COPYRIGHT -- JENSEN DK
 ********************************************************************
 * PROGRAM: check_IO
 * File: check_IOCyclic.st
 * Author: PMU 
 * Created: April 30, 2014
 ********************************************************************
 * Implementation OF PROGRAM check_IO
 ********************************************************************)

PROGRAM _CYCLIC
// --------------------------------------------------------------------------------------------------------------------------------------------------
// Variables to search for
// --------------------------------------------------------------------------------------------------------------------------------------------------
                       
	// --------------------------------------------------------------------------------------------------------------------------------------------------
	// Check IOs
	// --------------------------------------------------------------------------------------------------------------------------------------------------	

	IF CheckIODone THEN 
		g_Exists.Vacuum := CheckIO[0].boolReturn;
		g_Exists.FlapsLegsDetectionPlate := CheckIO[1].boolReturn;
		g_Exists.FlapsLegsAdjustment := CheckIO[2].boolReturn;
		g_Exists.AirTrouses := CheckIO[3].boolReturn;
		g_Exists.StackerAir := CheckIO[4].boolReturn;
		RETURN; 
	END_IF // Only check once

	CheckIO[0].IO_Name := '::QMVacuum';	
	CheckIO[1].IO_Name := '::QYFlapsLegsDetectionPlate';	
	CheckIO[2].IO_Name := '::QYFlapsLegsAdjustment';	
	CheckIO[3].IO_Name := '::QYAirTrouses';	
	CheckIO[4].IO_Name := '::QYStackerAir[1]';
	
	CASE step OF 
		// --------------------------------------
		0: 	// Init AsIOListDP
			// --------------------------------------
			AsIOListDP_0.pLastDatapoint := 0;
			index := 0;
			step := 10;

			// --------------------------------------
		10:	// Start the Function to list all the IOs
			// --------------------------------------
			AsIOListDP_0.enable := TRUE;
			IF index < 999 THEN
				IF AsIOListDP_0.status = ERR_OK THEN
					AsIOListDP_0.pLastDatapoint := AsIOListDP_0.pDatapoint;
					AsIOPVInfo_0.enable := TRUE;
					AsIOPVInfo_0.pDatapoint := AsIOListDP_0.pDatapoint;
					IF AsIOPVInfo_0.pDatapoint <> 0 THEN
						memcpy(ADR(tmpChar), AsIOPVInfo_0.pDatapoint + 1, 1);
						IF tmpChar = 73 THEN
							AsIOPVInfo_0.index := 1;
						ELSE
							AsIOPVInfo_0.index := 0;
						END_IF;
					END_IF;
					AsIOListDP_0.enable := FALSE;
					step := 20;
				END_IF;
			ELSE
				step := 50;
			END_IF;
				
			// --------------------------------------
		20:	// Wait for the AsIOPVInfor to finish
			// --------------------------------------
			IF AsIOPVInfo_0.status = ERR_OK THEN
				IF AsIOPVInfo_0.pPvName <> 0 THEN
					strcpy(ADR(io[index].dp_name), AsIOPVInfo_0.pDatapoint);
					strcpy(ADR(io[index].pv_name), AsIOPVInfo_0.pPvName);
					index := index + 1;
				END_IF;
				AsIOPVInfo_0.enable := FALSE;
				step := 10;
			ELSIF AsIOPVInfo_0.status = asioERR_NOSUCH_DP THEN
				AsIOPVInfo_0.enable := FALSE;
				totalDPs := index;
				index := 0;
				step := 30;
				x := 0;
			ELSIF AsIOPVInfo_0.status <> ERR_FUB_BUSY THEN
				step := 50;
			END_IF;
					
			// --------------------------------------	
		30:	// Search the list against the IOs
			// --------------------------------------
			FOR x := 0 TO SIZEOF(CheckIO)/SIZEOF(CheckIO[0]) - 1 DO
				FOR i := 0 TO totalDPs DO			
					IF io[i].pv_name = CheckIO[x].IO_Name THEN
						CheckIO[x].boolReturn := TRUE;
						CheckIO[x].IO_Index := i;
						EXIT;
					ELSE
						CheckIO[x].boolReturn := FALSE;
					END_IF;
				END_FOR
				IF x = (SIZEOF(CheckIO)/SIZEOF(CheckIO[0]) - 1) THEN
					step := 40;					
				END_IF;
			END_FOR
		
			// --------------------------------------
		40:	// Done
			// --------------------------------------
			CheckIODone := TRUE;
				
			// --------------------------------------
		50:	// Error
			// --------------------------------------
			AsIOPVInfo_0.status;
	END_CASE
						
	AsIOListDP_0();
	AsIOPVInfo_0();
		
END_PROGRAM
