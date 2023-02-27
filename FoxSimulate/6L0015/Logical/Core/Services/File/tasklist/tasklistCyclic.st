PROGRAM _CYCLIC
	// List and information of all tasks handling
	IF NOT g_Core.System.Runtime.isInitDone	OR g_Core.Services.IO.Interface.isHaltPlc THEN
	    RETURN;
	END_IF  
	
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = 113 THEN 
		IF SoftModuleInfo.ListType <> SoftModuleInfo.ListTypeOld THEN
			SoftModuleInfo.ListTypeOld := SoftModuleInfo.ListType;
			SoftModuleInfo.State := 0;
		END_IF
	
		CASE SoftModuleInfo.State OF
			0:	// Init
				SoftModuleInfo.No := TEmpty;
				SoftModuleInfo.NoOfModules := 0;
				SoftModuleInfo.ListPrevIndex := 0;
				SoftModuleInfo.ListIndex := 0;
				SoftModuleInfo.Stat.Selected := 0;
				memset(ADR(NameArray),0,SIZEOF(NameArray));
				memset(ADR(VersionArray),0,SIZEOF(VersionArray));
				memset(ADR(SizeArray),0,SIZEOF(SizeArray));
				memset(ADR(DateArray),0,SIZEOF(DateArray));
				NameArray[0] := 'Updating...';
				SoftModuleInfo.State := 1;
	
			1:	// Set type 
				SoftModuleInfo.State := 2;
				SoftModuleInfo.ListType := 17;
	
			2:	// List modules
			    SoftModuleInfo.ListPrevIndex := SoftModuleInfo.ListIndex;
			    MO_list(SoftModuleInfo.ListPrevIndex, ADR(SoftModuleInfo.ListIndex), ADR(MO_list_0));           (* get module info *)
	
				// Only specific type
				IF MO_list_0.type = SoftModuleInfo.ListType THEN
					strcpy(ADR(SoftModuleInfo.No[SoftModuleInfo.NoOfModules].Name) , ADR(MO_list_0.name));
					SoftModuleInfo.No[SoftModuleInfo.NoOfModules].Group := MO_list_0.grp;
					SoftModuleInfo.No[SoftModuleInfo.NoOfModules].State := MO_list_0.state;
					SoftModuleInfo.No[SoftModuleInfo.NoOfModules].MemType := MO_list_0.memtype;
					SoftModuleInfo.NoOfModules := SoftModuleInfo.NoOfModules +1;
				END_IF
				
				// New index or finish
				IF SoftModuleInfo.ListIndex <> RListIndexOld THEN
					RListIndexOld := SoftModuleInfo.ListIndex;
					RListIndexOldTime := RCycleCounter +10;
				END_IF
				// Function finish
				IF RCycleCounter > RListIndexOldTime THEN
					ModuleIndex := 0;
					SoftModuleInfo.State := 3;
				END_IF
	
			3:	// Read module info
				MO_info_0(enable := 1, pName := ADR(SoftModuleInfo.No[ModuleIndex].Name), grp := 0);	
	
				// Wait for update
				IF MO_info_0.status = 0 THEN
					SoftModuleInfo.No[ModuleIndex].DateTime := MO_info_0.date;	// Last change date and time
					SoftModuleInfo.No[ModuleIndex].Size := MO_info_0.size;	// Size of program task (binary file)
					strcpy(ADR(SoftModuleInfo.No[ModuleIndex].Version) , ADR(MO_info_0.version));
	
					// Newest Date
					IF ModuleIndex = 0 THEN
						TmpModule := SoftModuleInfo.No[ModuleIndex];
		 			ELSE		 
						DTCompare := DiffDT(DTStructure_TO_DT(ADR (TmpModule.DateTime)),DTStructure_TO_DT(ADR (SoftModuleInfo.No[ModuleIndex].DateTime)));
						IF (DTCompare = 4294967295) THEN   
							TmpModule := SoftModuleInfo.No[ModuleIndex];
						END_IF
					END_IF 
					// HMI information
					NameArray[ModuleIndex] := SoftModuleInfo.No[ModuleIndex].Name;
					VersionArray[ModuleIndex] := SoftModuleInfo.No[ModuleIndex].Version;
	
					itoa(SoftModuleInfo.No[ModuleIndex].Size, ADR(RTmp));
					SizeArray[ModuleIndex] := RTmp;
					
					DateArray[ModuleIndex] := '';
					itoa(SoftModuleInfo.No[ModuleIndex].DateTime.day, ADR(RTmp));
					IF strlen(ADR(RTmp)) = 1 THEN
						strcat(ADR(DateArray[ModuleIndex]),ADR('0'));
					END_IF
					strcat(ADR(DateArray[ModuleIndex]),ADR(RTmp));
					strcat(ADR(DateArray[ModuleIndex]),ADR('.'));
					itoa(SoftModuleInfo.No[ModuleIndex].DateTime.month, ADR(RTmp));
					IF strlen(ADR(RTmp)) = 1 THEN
						strcat(ADR(DateArray[ModuleIndex]),ADR('0'));
					END_IF
					strcat(ADR(DateArray[ModuleIndex]),ADR(RTmp));
					strcat(ADR(DateArray[ModuleIndex]),ADR('.'));
					itoa(SoftModuleInfo.No[ModuleIndex].DateTime.year, ADR(RTmp));
					IF strlen(ADR(RTmp)) = 1 THEN
						strcat(ADR(DateArray[ModuleIndex]),ADR('0'));
					END_IF
					strcat(ADR(DateArray[ModuleIndex]),ADR(RTmp));
					strcat(ADR(DateArray[ModuleIndex]),ADR(' '));
					itoa(SoftModuleInfo.No[ModuleIndex].DateTime.hour, ADR(RTmp));
					IF strlen(ADR(RTmp)) = 1 THEN
						strcat(ADR(DateArray[ModuleIndex]),ADR('0'));
					END_IF
					strcat(ADR(DateArray[ModuleIndex]),ADR(RTmp));
					strcat(ADR(DateArray[ModuleIndex]),ADR(':'));
					itoa(SoftModuleInfo.No[ModuleIndex].DateTime.minute, ADR(RTmp));
					IF strlen(ADR(RTmp)) = 1 THEN
						strcat(ADR(DateArray[ModuleIndex]),ADR('0'));
					END_IF
					strcat(ADR(DateArray[ModuleIndex]),ADR(RTmp));
					strcat(ADR(DateArray[ModuleIndex]),ADR(':'));
					itoa(SoftModuleInfo.No[ModuleIndex].DateTime.second, ADR(RTmp));
					IF strlen(ADR(RTmp)) = 1 THEN
						strcat(ADR(DateArray[ModuleIndex]),ADR('0'));
					END_IF
					strcat(ADR(DateArray[ModuleIndex]),ADR(RTmp));
	
					// Next module
					ModuleIndex := ModuleIndex + 1;
	
					IF ModuleIndex >= SoftModuleInfo.NoOfModules THEN
						SoftModuleInfo.State := 4;
					END_IF
	
				// Module not found
				ELSIF MO_info_0.status = 3019 THEN
					SoftModuleInfo.No[ModuleIndex].Name := 'NOT FOUND..!!';
					ModuleIndex := ModuleIndex + 1;
	
				// No module found at all
				ELSE 
					SoftModuleInfo.State := 99;
				END_IF
	
			4:	// Update Newest module
				SoftModuleInfo.NewestModule := TmpModule;	
				SoftModuleInfo.NewestDateTimeUDINT := DT_TO_UDINT(DTStructure_TO_DT(ADR (SoftModuleInfo.NewestModule.DateTime)));			
				SoftModuleInfo.State := 5;
	
			5:	// Wait step
				;
			99: // Error step
				;
		END_CASE
	
		// List commands
		IF 	SoftModuleInfo.Cmd.Up THEN
			IF RCycleCounter > RScrollTime THEN
				RScrollTime := RCycleCounter +25;
				IF SoftModuleInfo.Stat.Selected > 0 THEN SoftModuleInfo.Stat.Selected := SoftModuleInfo.Stat.Selected -1; END_IF;
			END_IF
		ELSIF SoftModuleInfo.Cmd.Dw THEN
			IF RCycleCounter > RScrollTime THEN
				RScrollTime := RCycleCounter +25;
				IF SoftModuleInfo.Stat.Selected +1 < SoftModuleInfo.NoOfModules THEN SoftModuleInfo.Stat.Selected := SoftModuleInfo.Stat.Selected +1; END_IF;
			END_IF
		END_IF
		RCycleCounter := RCycleCounter +1;
	ELSE
		SoftModuleInfo.State := 0;
	END_IF
END_PROGRAM