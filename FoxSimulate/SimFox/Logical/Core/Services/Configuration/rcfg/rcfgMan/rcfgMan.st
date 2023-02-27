(********************************************************************
 * COPYRIGHT -- JENSEN Denmark A/S
 ********************************************************************
 * Program: rcfgMan
 * File: rcfgMan.st
 * Author: eg
 * Created: July 31, 2013
 ********************************************************************
 * Implementation of program rcfgMan
 ********************************************************************)

PROGRAM _INIT
	RecipeFileManage.RefreshRate := 200;
END_PROGRAM

PROGRAM _CYCLIC
// Refresh the file status and file date 
	CASE RecipeFileManage.stepFileInfo OF
	
		0:// Set start values before searching 
			RecipeFileManage.FileCounter := 0;
			memset(ADR(RecipeFileManage.ReadData),0,SIZEOF(RecipeFileManage.ReadData));
			RecipeFileManage.ChkFileDate[0] := '';
			RecipeFileManage.ChkFileDate[1] := '';
			RecipeFileManage.ChkFileDate[2] := '';
	   		RecipeFileManage.ChkFileExists[0] := 0;
	  		RecipeFileManage.ChkFileExists[1] := 0;
	  		RecipeFileManage.ChkFileExists[2] := 0;
	        RecipeFileManage.stepFileInfo := 1;
	        DRead.enable := 1;
	        DRead.pDevice := ADR(NAME_CFG_DEVICE);
	        DRead.pPath := 0;
	        DRead.option := FILE_FILE;
	        DRead.pData := ADR(RecipeFileManage.ReadData);
	        DRead.data_len := SIZEOF(RecipeFileManage.ReadData);
	        DRead();
	
		1:	// Search for existing files in directory 
	        DRead.enable := 1;
	        DRead.pDevice := ADR(NAME_CFG_DEVICE);
	        DRead.pPath := 0;
	        DRead.option := FILE_FILE;
	        DRead.pData := ADR(RecipeFileManage.ReadData);
	        DRead.data_len := SIZEOF(RecipeFileManage.ReadData);
	        DRead.entry := RecipeFileManage.FileCounter;
	        DRead();
	        RecipeFileManage.wStatus := DRead.status;
	
	        // Verify status 
	        IF (RecipeFileManage.wStatus = 0) THEN
				ascDT(RecipeFileManage.ReadData.Date, ADR(RecipeFileManage.DateStr), SIZEOF(RecipeFileManage.DateStr));
				RecipeFileManage.FileNameLength := strlen(ADR(RecipeFileManage.ReadData.Filename));
				FOR i := 0 TO RecipeFileManage.FileNameLength -1 DO
					IF (RecipeFileManage.ReadData.Filename[i] >= 65) AND (RecipeFileManage.ReadData.Filename[i] <= 90) THEN // A-Z 
						RecipeFileManage.ReadData.Filename[i] := RecipeFileManage.ReadData.Filename[i] + 32;				// a-z 
					END_IF
				END_FOR
	        	IF strcmp(ADR(RecipeFileManage.ReadData.Filename),ADR('0.csv')) = 0 THEN
	        		RecipeFileManage.ChkFileExists[0] := 1;
	        		strcpy(ADR(RecipeFileManage.ChkFileDate[0]),ADR(RecipeFileManage.DateStr));
	        	ELSIF strcmp(ADR(RecipeFileManage.ReadData.Filename),ADR('1.csv')) = 0 THEN
	        		RecipeFileManage.ChkFileExists[1] := 1;
	        		strcpy(ADR(RecipeFileManage.ChkFileDate[1]),ADR(RecipeFileManage.DateStr));
	        	ELSIF strcmp(ADR(RecipeFileManage.ReadData.Filename),ADR('2.csv')) = 0 THEN
	        		RecipeFileManage.ChkFileExists[2] := 1;
	        		strcpy(ADR(RecipeFileManage.ChkFileDate[2]),ADR(RecipeFileManage.DateStr));
	        	END_IF
	            RecipeFileManage.FileCounter := RecipeFileManage.FileCounter + 1;
	        ELSE
	           IF (RecipeFileManage.wStatus <> 65535) THEN
	               RecipeFileManage.stepFileInfo := 3;
	               IF (RecipeFileManage.wStatus = 20799) THEN
	                   RecipeFileManage.wError := FileIoGetSysError();
	               END_IF
	           END_IF
		    END_IF
	
		3:	// Prepare search result 
			FOR i := 0 TO 2 DO
		   		strcpy(ADR(RecipeFileManage.File[i].Date),ADR(RecipeFileManage.ChkFileDate[i]));
	   			RecipeFileManage.File[i].Exists := RecipeFileManage.ChkFileExists[i];
	   			RecipeFileManage.File[i].Visible := 1-RecipeFileManage.File[i].Exists;// Exists => visible, Notexists=>invisible 
				IF RecipeFileManage.File[i].Exists = 1 THEN
					RecipeFileManage.File[i].Colour := RecipeFileManage.FileExistColour;
				ELSE
					RecipeFileManage.File[i].Colour := RecipeFileManage.FileNotExistColour;
				END_IF
				RecipeFileManage.File[i].Selected := 1;
	        END_FOR
	        RecipeFileManage.stepFileInfo := 4;
	
	      	IF strcmp(ADR(g_Core.Services.System.Runtime.file.LastLoadedRecipe),ADR('1.csv')) = 0 THEN
		   		strcpy(ADR(RecipeFileManage.SelectedFile),ADR('Recipe1'));
		   		strcpy(ADR(RecipeFileManage.SelectedDate),ADR(RecipeFileManage.File[1].Date));
				RecipeFileManage.File[0].Selected := 1; // Invisible 
				RecipeFileManage.File[1].Selected := 0; // Visible 
				RecipeFileManage.File[2].Selected := 1; // Invisible 
	      	ELSIF strcmp(ADR(g_Core.Services.System.Runtime.file.LastMachineFile),ADR('2.csv')) = 0 THEN
		   		strcpy(ADR(RecipeFileManage.SelectedFile),ADR('Recipe2'));
		   		strcpy(ADR(RecipeFileManage.SelectedDate),ADR(RecipeFileManage.File[2].Date));
				RecipeFileManage.File[0].Selected := 1; // Invisible 
				RecipeFileManage.File[1].Selected := 1; // Invisible 
				RecipeFileManage.File[2].Selected := 0; // Visible 
			ELSE
		   		strcpy(ADR(RecipeFileManage.SelectedFile),ADR('Recepie0'));
		   		strcpy(ADR(RecipeFileManage.SelectedDate),ADR(RecipeFileManage.File[0].Date));
				RecipeFileManage.File[0].Selected := 0; // Visible 
				RecipeFileManage.File[1].Selected := 1; // Invisible 
				RecipeFileManage.File[2].Selected := 1; // Invisible 
			END_IF
	
			// Make extra Read to clear extra error that comes due to bug? in library? 
	        DRead.enable := 1;
	        DRead.pDevice := ADR(NAME_CFG_DEVICE);
	        DRead.pPath := 0;
	        DRead.option := FILE_FILE;
	        DRead.pData := ADR(RecipeFileManage.ReadData);
	        DRead.data_len := SIZEOF(RecipeFileManage.ReadData);
	        DRead.entry := 0;
	        DRead();
	        RecipeFileManage.wStatus  := DRead.status;
	
		4: // Wait a little before next search 
			RecipeFileManage.RefreshCount := RecipeFileManage.RefreshCount + 1;
			IF RecipeFileManage.RefreshCount > RecipeFileManage.RefreshRate THEN
				RecipeFileManage.RefreshCount := 0;
	            RecipeFileManage.stepFileInfo := 0;
			END_IF
	
	END_CASE

END_PROGRAM
