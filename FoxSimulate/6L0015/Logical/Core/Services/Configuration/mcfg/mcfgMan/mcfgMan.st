(********************************************************************
 * COPYRIGHT -- JENSEN Denmark A/S
 ********************************************************************
 * Program: mcfgMan
 * File: mcfgMan.st
 * Author: eg
 * Created: July 31, 2013
 ********************************************************************
 * Implementation of program mcfgMan
 ********************************************************************)

PROGRAM _INIT
	MachineFileManage.FileExistColour := 1;
	MachineFileManage.FileNotExistColour := 53;
	MachineFileManage.RefreshRate := 200;
END_PROGRAM


PROGRAM _CYCLIC
// Reresh the file status and file date 
	CASE MachineFileManage.stepFileInfo OF
	
		0:// Set start values before searching 
			MachineFileManage.FileCounter := 0;
			memset(ADR(MachineFileManage.ReadData),0,SIZEOF(MachineFileManage.ReadData));
			MachineFileManage.ChkFileDate[0] := '';
			MachineFileManage.ChkFileDate[1] := '';
	   		MachineFileManage.ChkFileExists[0] := 0;
	  		MachineFileManage.ChkFileExists[1] := 0;
	        MachineFileManage.stepFileInfo := 1;
	        DRead.enable := 1;
	        DRead.pDevice := ADR(NAME_CFG_DEVICE);
	        DRead.pPath := 0;
	        DRead.option := FILE_FILE;
	        DRead.pData := ADR(MachineFileManage.ReadData);
	        DRead.data_len := SIZEOF(MachineFileManage.ReadData);
	        DRead();
	
		1:	// Search for existing files in directory 
	        DRead.enable := 1;
	        DRead.pDevice := ADR(NAME_CFG_DEVICE);
	        DRead.pPath := 0;
	        DRead.option := FILE_FILE;
	        DRead.pData := ADR(MachineFileManage.ReadData);
	        DRead.data_len := SIZEOF(MachineFileManage.ReadData);
	        DRead.entry := MachineFileManage.FileCounter;
	        DRead();
	        MachineFileManage.wStatus := DRead.status;
	
	        // Verify status 
	        IF (MachineFileManage.wStatus = 0) THEN
				MachineFileManage.FileNameLength := strlen(ADR(MachineFileManage.ReadData.Filename));
				FOR i := 0 TO MachineFileManage.FileNameLength -1 DO
					IF (MachineFileManage.ReadData.Filename[i] >= 65) AND (MachineFileManage.ReadData.Filename[i] <= 90) THEN // A-Z 
						MachineFileManage.ReadData.Filename[i] := MachineFileManage.ReadData.Filename[i] + 32;				// a-z 
					END_IF
				END_FOR
				ascDT(MachineFileManage.ReadData.Date, ADR(MachineFileManage.DateStr), SIZEOF(MachineFileManage.DateStr));
	        	IF strcmp(ADR(MachineFileManage.ReadData.Filename),ADR('mcfg0.csv')) = 0 THEN
	        		MachineFileManage.ChkFileExists[0] := 1;
	        		strcpy(ADR(MachineFileManage.ChkFileDate[0]),ADR(MachineFileManage.DateStr));
	        	ELSIF strcmp(ADR(MachineFileManage.ReadData.Filename),ADR('mcfg1.csv')) = 0 THEN
	        		MachineFileManage.ChkFileExists[1] := 1;
	        		strcpy(ADR(MachineFileManage.ChkFileDate[1]),ADR(MachineFileManage.DateStr));
	        	END_IF
	            MachineFileManage.FileCounter := MachineFileManage.FileCounter + 1;
	        ELSE
	           IF (MachineFileManage.wStatus <> 65535) THEN
	               MachineFileManage.stepFileInfo := 3;
	               IF (MachineFileManage.wStatus = 20799) THEN
	                   MachineFileManage.wError := FileIoGetSysError();
	               END_IF
	           END_IF
		    END_IF
	
		3:	// Prepare search result 
			FOR i := 0 TO 1 DO
		   		strcpy(ADR(MachineFileManage.File[i].Date),ADR(MachineFileManage.ChkFileDate[i]));
	   			MachineFileManage.File[i].Exists := MachineFileManage.ChkFileExists[i];
	   			MachineFileManage.File[i].Visible := 1-MachineFileManage.File[i].Exists;// Exists => visible, Notexists=>invisible 
				IF MachineFileManage.File[i].Exists = 1 THEN
					MachineFileManage.File[i].Colour := MachineFileManage.FileExistColour;
				ELSE
					MachineFileManage.File[i].Colour := MachineFileManage.FileNotExistColour;
				END_IF
				MachineFileManage.File[i].Selected := 1;
	        END_FOR
	        MachineFileManage.stepFileInfo := 4;
	
	      	IF strcmp(ADR(g_Core.Services.System.Runtime.file.LastMachineFile),ADR('mcfg1.csv')) = 0 THEN
		   		strcpy(ADR(MachineFileManage.SelectedFile),ADR('mcfg1'));
		   		strcpy(ADR(MachineFileManage.SelectedDate),ADR(MachineFileManage.File[1].Date));
				MachineFileManage.File[0].Selected := 1; // Invisible 
				MachineFileManage.File[1].Selected := 0; // Visible 
			ELSE
		   		strcpy(ADR(MachineFileManage.SelectedFile),ADR('mcfg0'));
		   		strcpy(ADR(MachineFileManage.SelectedDate),ADR(MachineFileManage.File[0].Date));
				MachineFileManage.File[0].Selected := 0; // Visible 
				MachineFileManage.File[1].Selected := 1; // Invisible 
			END_IF
	
			// Make extra Read to clear extra error that comes due to bug? in library? 
	        DRead.enable := 1;
	        DRead.pDevice := ADR(NAME_CFG_DEVICE);
	        DRead.pPath := 0;
	        DRead.option := FILE_FILE;
	        DRead.pData := ADR(MachineFileManage.ReadData);
	        DRead.data_len := SIZEOF(MachineFileManage.ReadData);
	        DRead.entry := 0;
	        DRead();
	        MachineFileManage.wStatus := DRead.status;
	
		4: // Wait a little before next search 
			MachineFileManage.RefreshCount := MachineFileManage.RefreshCount + 1;
			IF MachineFileManage.RefreshCount > MachineFileManage.RefreshRate THEN
				MachineFileManage.RefreshCount := 0;
	            MachineFileManage.stepFileInfo := 0;
			END_IF
	
	END_CASE
END_PROGRAM
