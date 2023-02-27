(**********************************************************************************
Remember TO add File device 
  Name	'trace2file'
***********************************************************************************)

PROGRAM _INIT
	CRLF[0] := 13; 
	CRLF[1] := 10; 
	CRLF[2] := 0; 
	// Header
	Header := 'Time;Task;Type;Info 3;Info 3 Value;Info 4;Info 4 Value;Info 5;Log Text';
	strcat(ADR(Header),ADR(CRLF)); // CR LF
	rewriteFifoArraySize := SIZEOF(rewriteFifo) / SIZEOF(rewriteFifo[0]);
	BufferLimit := SIZEOF(BufferString) - SIZEOF(T2FD.FiFo[0])*2;
	IF errorString = '' THEN
		errorString := 'Boot';
	END_IF
	T2FD.init := TRUE;
	T2F_MaxFileSizeUse := T2F_MaxFileSize;
	T2F_NumberOfFilesUse := MAX(2, T2F_NumberOfFiles);
	OldMilliSeconds := g_MilliSeconds;

	Count;
	
END_PROGRAM

PROGRAM _CYCLIC

	parNoLogsSkibIdle := T2F_Array_Size / 10;
	UsedFifo := (T2F_Array_Size + T2FD.FiFo_In - T2FD.FiFo_Out) MOD T2F_Array_Size;
	UsedFifoMax := MAX(UsedFifo, UsedFifoMax);
	T2FD.enable := TRUE; //test to log only H-inlet//g_MCfg.Trace2File;
	
	//x----------------------------------------------------------------------------------
	// Handle the ring-fifo buffer.
	//x----------------------------------------------------------------------------------
	REPEAT
		doRepeat := FALSE;
		
		StateTime := StateTime + (g_MilliSeconds - OldMilliSeconds);
		IF T2F_State <> OldT2F_State THEN
			OldT2F_State := T2F_State;
			StateTime := 0;
		END_IF
		CASE T2F_State OF
		
			// Log enabled?
			T2F_WaitEnable:
				IF T2FD.enable THEN
					T2F_State := T2F_Init;
				END_IF
	
				// Initialize if empty Ring-Fifo
			T2F_Init:
				IF T2FD.FiFo_In = 0 AND T2FD.FiFo_Out = 0 THEN
					T2FD.FiFo_In := 1;
					T2FD.FiFo_Out := 0;
				END_IF
				strDevice := 'trace2file';
				strFileName := 'trace';
				BufferLimit := SIZEOF(BufferString) - SIZEOF(T2FD.FiFo[0])*2;
				doRepeat := TRUE;
				T2F_State := T2F_WaitData;
				
				// Idle with file closed. Waiting for data.
			T2F_WaitData:
				IF NOT T2FD.enable THEN
					T2F_State := T2F_WaitEnable;
				ELSIF UsedFifo > 0 AND StateTime > parIdleTimeWriting OR UsedFifo >= parNoLogsSkibIdle THEN
					strcat(strcpy(ADR(strFile),ADR(strFileName)),ADR('01.csv'));
					FOpen(enable := TRUE, pDevice := ADR(strDevice), pFile := ADR(strFile), mode := FILE_RW);
					doRepeat := TRUE;
					T2F_State := T2F_WaitOpenFile;
				END_IF

				// Open file for writing.
			T2F_WaitOpenFile:
				wStatus := FOpen.status;
				IF wStatus = 65535 THEN
					FOpen();
					wStatus := FOpen.status;
				END_IF
				CASE wStatus OF
					0: // OK
						dwIdent := FOpen.ident;
						strcat(strcpy(ADR(strFile),ADR(strFileName)),ADR('01.csv'));
						FInfo(enable := TRUE, pDevice := ADR(strDevice), pName := ADR(strFile), pInfo := ADR(fileInfo));
						doRepeat := TRUE;
						T2F_State := T2F_WaitInfo;

					20708: // fiERR_FILE_NOT_FOUND 
						cmdInitFirstFile := TRUE;
						T2F_State := T2F_WaitingNewFile;

					65535: ;// BUSY
					ELSE
						cmdPrintErrorString := TRUE;
						T2F_State := T2F_Error;
				END_CASE 

				// File info.
			T2F_WaitInfo:
				wStatus := FInfo.status;
				IF wStatus = 65535 THEN
					FInfo();
					wStatus := FInfo.status;
				END_IF
				CASE wStatus OF
					0: // OK
						fileoffset1 := fileInfo.size;
						doRepeat := TRUE;
						T2F_State := T2F_MoreData;
					65535: ;// BUSY
					ELSE
						cmdPrintErrorString := TRUE;
						T2F_State := T2F_Error;
				END_CASE 

				// Incoming data, file still open.
			T2F_MoreData:
				IF StateTime > parIdleTimeWriting OR NOT T2FD.enable THEN
					T2F_State := T2F_CloseFile;
				ELSIF StateTime > parIdleTimeWriting / 3 AND UsedFifo > 0 OR UsedFifo >= parNoLogsSkibIdle THEN
					cmdT2F_WriteBuffer := TRUE;
					T2F_State := T2F_WaitingWritingBuffer;
				END_IF
	
			T2F_CloseFile:
				IF NOT isMakingNewFile AND NOT isWritingFile THEN
					FClose(enable := TRUE, ident := dwIdent);
					T2F_State := T2F_WaitCloseFile;
				END_IF
				
				// Closing log file
			T2F_WaitCloseFile:
				wStatus := FClose.status;
				IF wStatus <> 0 THEN
					FClose();
					wStatus := FClose.status;
				END_IF
				CASE wStatus OF
					0: // OK
						T2F_State := T2F_WaitData;
						doRepeat := TRUE;
					65535: ;// BUSY
					ELSE
						cmdPrintErrorString := TRUE;
						T2F_State := T2F_Error;
				END_CASE 
				
				// Making of new file after full file size in progress.
			T2F_WaitingNewFile:
				IF NOT isMakingNewFile AND NOT cmdMakeNewFile AND NOT cmdInitFirstFile THEN
					BufferStringStartAdr := ADR(BufferString);
					BufferStringEndAdr := strcpy(BufferStringStartAdr, ADR(Header));
					BufferStringLen := BufferStringEndAdr - BufferStringStartAdr;
					cmdT2F_RewriteBuffer := TRUE;
					T2F_State := T2F_WaitingWritingBuffer;
					// Write to file / prepare filebuffer while deleting/renaming extra files.
				ELSIF UsedFifo > T2F_Array_Size / 2 AND UsedFifo >= parNoLogsSkibIdle AND fileoffset1 < T2F_MaxFileSizeUse * 3 AND NOT isWritingFile THEN
					IF isBlockTraceFile1 THEN
						isDataInBuffer := TRUE;
						BufferStringStartAdr := ADR(BufferString);
						BufferStringEndAdr := strcpy(BufferStringStartAdr, ADR(Header));
						BufferStringLen := BufferStringEndAdr - BufferStringStartAdr;
						cmdT2F_RewriteBuffer := TRUE;
						T2F_State := T2F_WaitingDataInBuffer;
					ELSE
						cmdT2F_WriteBuffer := TRUE;
						T2F_State := T2F_WaitingWritingBufferNF;
					END_IF
				END_IF
				
				// Writing to log file while extra existing files is handled.
			T2F_WaitingWritingBufferNF:
				IF NOT cmdT2F_WriteBuffer AND NOT isWritingFile THEN
					doRepeat := TRUE;
					T2F_State := T2F_WaitingNewFile;
				END_IF
	
				// Waiting buffered data to be written in new file
			T2F_WaitingDataInBuffer:
				IF isDataInBuffer OR isWritingFile THEN 
					;
				ELSIF UsedFifo >= parNoLogsSkibIdle THEN
					cmdT2F_WriteBuffer := TRUE;
					T2F_State := T2F_WaitingWritingBuffer;
				END_IF
					
				// Writing logs to file.
			T2F_WaitingWritingBuffer:
				IF isWritingFile OR cmdT2F_RewriteBuffer OR cmdT2F_WriteBuffer THEN
					; // Waiting writing done
				ELSIF fileoffset1 > T2F_MaxFileSizeUse OR cmdUserMakeNewFile THEN
					cmdUserMakeNewFile := FALSE;
					cmdMakeNewFile := TRUE;
					T2F_State := T2F_WaitingNewFile;
				ELSE
					doRepeat := TRUE;
					T2F_State := T2F_MoreData;
				END_IF
	
				// Error trigged.
			T2F_Error:
				dwIdentErrClose := dwIdent;
				FCloseError(enable := TRUE, ident := dwIdentErrClose);
				IF T2F_MakeNewFileState < T2F_Error THEN
					T2F_MakeNewFileState := T2F_Error;
				END_IF
				IF T2F_WriteState < T2F_Error THEN
					T2F_WriteState := T2F_Error;
				END_IF
				isFileChecked := FALSE;
				T2F_State := T2F_ErrorWait;
	
				// Error. Wait reinitialize.
			T2F_ErrorWait:
				CASE FCloseError.status OF
					ERR_OK, fiERR_FILE_NOT_OPENED:
						isFileChecked := TRUE;
					ELSE
						FCloseError(enable := TRUE, ident := dwIdentErrClose);
				END_CASE
				IF StateTime > 1000 AND isFileChecked THEN 
					T2F_State := T2F_Init;
				END_IF
		END_CASE
		
		//x----------------------------------------------------------------------------------
		// Rename and make new log file.
		//x----------------------------------------------------------------------------------
		StateTimeMakeNew := StateTimeMakeNew + (g_MilliSeconds - OldMilliSeconds);
		IF T2F_MakeNewFileState <> OldT2F_MakeNewFileState THEN
			OldT2F_MakeNewFileState := T2F_MakeNewFileState;
			StateTimeMakeNew := 0;
		END_IF
		CASE T2F_MakeNewFileState OF 
			
			// Wait for cmd make new file 
			T2F_WaitEnable:	
				isMakingNewFile := FALSE;
				IF cmdRequestOpenFile THEN
					cmdRequestOpenFile := FALSE;
					fileoffset1 := 0;
					strcat(strcpy(ADR(strFile),ADR(strFileName)),ADR('01.csv'));
					FOpen(enable := TRUE, pDevice := ADR(strDevice), pFile := ADR(strFile), mode := FILE_RW);
					T2F_MakeNewFileState := T2F_WaitOpenFile;
				ELSIF cmdInitFirstFile THEN
					cmdInitFirstFile := FALSE;
					isMakingNewFile := TRUE;
					strcat(strcpy(ADR(strFileCreate),ADR(strFileName)),ADR('01.csv'));
					FCreate(enable := TRUE, pDevice := ADR(strDevice), pFile := ADR(strFileCreate));
					T2F_MakeNewFileState := T2F_WaitCreateFile;
				ELSIF cmdMakeNewFile THEN
					cmdMakeNewFile := FALSE;
					isMakingNewFile := TRUE;
					filenumber := T2F_NumberOfFilesUse;
					tmpStrAdr := strcpy(ADR(filenumberstring),ADR('00'));
					tmpStrAdr := memset(tmpStrAdr-itoa(filenumber,ADR(numberStr)),0,1) - 1;
					tmpStrAdr := strcat(tmpStrAdr,ADR(numberStr));
					strcat(strcat(strcpy(ADR(strFileDelete),ADR(strFileName)),ADR(filenumberstring)),ADR('.csv'));
					FDelete(enable := TRUE, pDevice := ADR(strDevice), pName := ADR(strFileDelete));
					T2F_MakeNewFileState := T2F_WaitDeleteFile;
				END_IF
			
				// Wait Delete
			T2F_WaitDeleteFile:	
				wStatus := FDelete.status;
				IF wStatus <> 0 THEN
					FDelete();
					wStatus := FDelete.status;
				END_IF
				CASE wStatus OF
					0: // OK
						T2F_MakeNewFileState := T2F_RenameFile;
					20708: // fiERR_FILE_NOT_FOUND 
						T2F_MakeNewFileState := T2F_RenameFile;
					20712: // fiERR_FILE 
						//errorString := 'fiERR_FILE ';
						T2F_MakeNewFileState := T2F_RenameFile;
					65535: ;// BUSY
					ELSE
						cmdPrintErrorString := TRUE;
						T2F_MakeNewFileState := T2F_Error;
				END_CASE 
	
				// Renaming files.
			T2F_RenameFile:	
				IF filenumber > 1 THEN
					tmpStrAdr := strcpy(ADR(filenumberstring),ADR('00'));
					tmpStrAdr := memset(tmpStrAdr-itoa(filenumber,ADR(numberStr)),0,1) - 1;
					tmpStrAdr := strcat(tmpStrAdr,ADR(numberStr));
					strcat(strcat(strcpy(ADR(strFileNewName), ADR(strFileName)),ADR(filenumberstring)),ADR('.csv'));
					filenumber := filenumber - 1;
					tmpStrAdr := strcpy(ADR(filenumberstring),ADR('00'));
					tmpStrAdr := memset(tmpStrAdr-itoa(filenumber,ADR(numberStr)),0,1) - 1;
					tmpStrAdr := strcat(tmpStrAdr,ADR(numberStr));
					strcat(strcat(strcpy(ADR(strFileRename), ADR(strFileName)),ADR(filenumberstring)),ADR('.csv'));
					IF filenumber > 1 THEN
						FRename(enable := TRUE, pDevice := ADR(strDevice), pName := ADR(strFileRename), pNewName := ADR(strFileNewName));
						T2F_MakeNewFileState := T2F_WaitRenameFile;
					ELSE
						FRename(enable := FALSE, pDevice := ADR(strDevice), pName := ADR(strFileRename), pNewName := ADR(strFileNewName));
						isBlockTraceFile1 := TRUE;
						IF isWritingFile THEN
							T2F_MakeNewFileState := T2F_WaitWritingIdle;
						ELSE
							FClose(enable := TRUE, ident := dwIdent);
							T2F_MakeNewFileState := T2F_WaitCloseFile;
						END_IF				
					END_IF
				ELSE 
					isBlockTraceFile1 := TRUE;
					T2F_MakeNewFileState := T2F_WaitWritingIdle;
				END_IF
			
				// Wait Delete in progress.
			T2F_WaitRenameFile:
				wStatus := FRename.status;
				IF wStatus <> 0 THEN
					FRename(enable := NOT DisableRename);
					wStatus := FRename.status;
				END_IF
				CASE wStatus OF
					0: // OK
						RenameErrorCount := 0;
						IF filenumber > 1 THEN
							T2F_MakeNewFileState := T2F_RenameFile;
						ELSE
							strcat(strcpy(ADR(strFileCreate),ADR(strFileName)),ADR('01.csv'));
							FCreate(enable := TRUE, pDevice := ADR(strDevice), pFile := ADR(strFileCreate));
							T2F_MakeNewFileState := T2F_WaitCreateFile;
						END_IF
						
					20700,20708: // fiERR_INVALID_PATH, fiERR_FILE_NOT_FOUND  
						T2F_MakeNewFileState := T2F_RenameFile;
						
					65534:
						IF StateTimeMakeNew > 500 THEN
							DisableRename := FALSE;
						END_IF
					65535: ;// BUSY
					ELSE
						cmdPrintErrorString := TRUE;
						T2F_MakeNewFileState := T2F_Error;
				END_CASE 
	
				// Wait for log file idle
			T2F_WaitWritingIdle:	
				IF NOT isWritingFile THEN
					FClose(enable := TRUE, ident := dwIdent);
					T2F_MakeNewFileState := T2F_WaitCloseFile;
				END_IF				
				
				// Close the log file.
			T2F_WaitCloseFile:
				wStatus := FClose.status;
				IF wStatus <> 0 THEN
					FClose();
					wStatus := FClose.status;
				END_IF
				CASE wStatus OF
					0: // OK
						FRename(enable := TRUE);
						T2F_MakeNewFileState := T2F_WaitRenameFile;
						
					20721: // fiERR_FILE_NOT_OPENED 
						FRename(enable := TRUE);
						T2F_MakeNewFileState := T2F_WaitRenameFile;
						
					65535: ;// BUSY
					ELSE
						cmdPrintErrorString := TRUE;
						T2F_MakeNewFileState := T2F_Error;
				END_CASE 
	
				// Create new log file.
			T2F_WaitCreateFile:
				wStatus := FCreate.status;
				IF wStatus <> 0 THEN
					FCreate();
					wStatus := FCreate.status;
				END_IF
				CASE wStatus OF
					0: // OK
						dwIdent := FCreate.ident;
						fileoffset1 := 0;
						FileCreatedTotal := FileCreatedTotal + 1;
						isMakingNewFile := FALSE;
						isBlockTraceFile1 := FALSE;
						T2F_MakeNewFileState := T2F_WaitEnable;
						
					65535: ;// BUSY
					ELSE
						cmdPrintErrorString := TRUE;;
						T2F_MakeNewFileState := T2F_Error;
				END_CASE 
			
				// Open file for writing.
			T2F_WaitOpenFile:
				wStatus := FOpen.status;
				IF wStatus <> 0 THEN
					FOpen();
					wStatus := FOpen.status;
				END_IF
				CASE wStatus OF
					0: // OK
						dwIdent := FOpen.ident;
						strcat(strcpy(ADR(strFile),ADR(strFileName)),ADR('01.csv'));
						FInfo(enable := TRUE, pDevice := ADR(strDevice), pName := ADR(strFile), pInfo := ADR(fileInfo));
						T2F_MakeNewFileState := T2F_WaitInfo;
	
					20708: // fiERR_FILE_NOT_FOUND 
						cmdInitFirstFile := TRUE;
						T2F_MakeNewFileState := T2F_WaitEnable;
	
					65535: ;// BUSY
					ELSE
						cmdPrintErrorString := TRUE;
						T2F_State := T2F_Error;
				END_CASE 
	
				// File info.
			T2F_WaitInfo:
				wStatus := FInfo.status;
				IF wStatus <> 0 THEN
					FInfo();
					wStatus := FInfo.status;
				END_IF
				CASE wStatus OF
					0: // OK
						fileoffset1 := fileInfo.size;
						T2F_MakeNewFileState := T2F_WaitEnable;
					65535: ;// BUSY
					ELSE
						cmdPrintErrorString := TRUE;
						T2F_MakeNewFileState := T2F_Error;
				END_CASE 
	
				// Error has occured
			T2F_Error:
				IF T2F_State < T2F_Error THEN
					T2F_State := T2F_Error;
				END_IF
				T2F_MakeNewFileState := T2F_ErrorWait;
	
				// Wait for filesystem ok.
			T2F_ErrorWait:
				IF T2F_State < T2F_Error THEN
					T2F_MakeNewFileState := T2F_WaitEnable;
				END_IF
	
		END_CASE
	
		//x----------------------------------------------------------------------------------
		// Making csv data and write to file.
		//x----------------------------------------------------------------------------------
		StateTimeWrite := StateTimeWrite + (g_MilliSeconds - OldMilliSeconds);
		IF T2F_WriteState <> OldT2F_WriteState THEN
			OldT2F_WriteState := T2F_WriteState;
			StateTimeWrite := 0;
		END_IF
		CASE T2F_WriteState OF
	
			0:
				T2F_WriteState := T2F_Waiting;
				
				// Wait make csv
			T2F_Waiting:
				// Write stored buffer to new file. Rewrite last lines to new file from previous log.
				IF cmdT2F_RewriteBuffer THEN
					BufferStringStartAdr := ADR(BufferString);
					IF BufferStringEndAdr = 0 THEN
						BufferStringEndAdr := strcpy(BufferStringStartAdr,ADR(''));
					END_IF
					BufferStringLen := BufferStringEndAdr - BufferStringStartAdr;
					FifoOutAtRewriting := T2FD.FiFo_Out;
					Fifo_In := rewriteIndex;
					IF rewriteFifoFull THEN
						Fifo_Out := (rewriteIndex + 1) MOD rewriteFifoArraySize;
					ELSE
						Fifo_Out := rewriteIndexOut;
					END_IF
					rewriteFifoFull := FALSE;
					rewriteFifoLoopCount := 0;
					WHILE (Fifo_In <> Fifo_Out AND BufferStringLen < BufferLimit) DO
						rewriteFifoLoopCount := rewriteFifoLoopCount + 1;
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR('00'));
						BufferStringEndAdr := memset(BufferStringEndAdr-itoa(rewriteFifo[Fifo_Out].TimeStamp.hour,ADR(hourStr)),0,1) - 1;
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(hourStr));
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(':00'));
						BufferStringEndAdr := memset(BufferStringEndAdr-itoa(rewriteFifo[Fifo_Out].TimeStamp.minute,ADR(minuteStr)),0,1) - 1;
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(minuteStr));
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(':00'));
						BufferStringEndAdr := memset(BufferStringEndAdr-itoa(rewriteFifo[Fifo_Out].TimeStamp.second,ADR(secondsStr)),0,1) - 1;
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(secondsStr));
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(':000'));
						BufferStringEndAdr := memset(BufferStringEndAdr-itoa(rewriteFifo[Fifo_Out].TimeStamp.millisec,ADR(millisecondsStr)),0,1) - 1;
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(millisecondsStr));
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(';'));
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(rewriteFifo[Fifo_Out].Function));
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(';'));
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(rewriteFifo[Fifo_Out].Text));
						IF rewriteFifoLoopCount = 1 AND DebugEnable THEN
							BufferStringEndAdr := strcat(BufferStringEndAdr,ADR('Rewrite Start'));
						END_IF
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(CRLF)); // CR LF
						BufferStringLen := BufferStringEndAdr - BufferStringStartAdr;
						Fifo_Out := (Fifo_Out + 1) MOD rewriteFifoArraySize;
					END_WHILE
					IF Fifo_In = Fifo_Out THEN
						cmdT2F_RewriteBuffer := FALSE;
					END_IF
					rewriteIndexOut := Fifo_Out;
					isRewriting := TRUE;
					cmdT2F_WriteBuffer := TRUE;
				END_IF			
	
				// Make the csv-buffer.
				IF cmdT2F_WriteBuffer THEN
					BufferStringStartAdr := ADR(BufferString);
					IF NOT isRewriting THEN
						BufferStringEndAdr := strcpy(BufferStringStartAdr,ADR(''));
					END_IF
					BufferStringLen := BufferStringEndAdr - BufferStringStartAdr;
					Fifo_In := T2FD.FiFo_In;
					IF FifoOutAtRewriting > 0 THEN
						Fifo_Out := FifoOutAtRewriting;
					ELSE
						Fifo_Out := T2FD.FiFo_Out;
					END_IF
					FifoOutAtRewriting := 0;
					StartBufferCount := TIME_TO_UDINT(clock_ms());
					IF NOT isRewriting THEN
						rewriteIndexOut := rewriteIndex;
					END_IF
					BufWriteStart := TRUE;
					WHILE (Fifo_In <> Fifo_Out AND BufferStringLen < BufferLimit) DO
						IF NOT isRewriting THEN
							rewriteFifo[rewriteIndex] := T2FD.FiFo[Fifo_Out];
							rewriteIndex := (rewriteIndex + 1) MOD rewriteFifoArraySize;
							IF rewriteIndexOut = rewriteIndex THEN
								rewriteFifoFull := TRUE;
							END_IF
						END_IF
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR('00'));
						BufferStringEndAdr := memset(BufferStringEndAdr-itoa(T2FD.FiFo[Fifo_Out].TimeStamp.hour,ADR(hourStr)),0,1) - 1;
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(hourStr));
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(':00'));
						BufferStringEndAdr := memset(BufferStringEndAdr-itoa(T2FD.FiFo[Fifo_Out].TimeStamp.minute,ADR(minuteStr)),0,1) - 1;
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(minuteStr));
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(':00'));
						BufferStringEndAdr := memset(BufferStringEndAdr-itoa(T2FD.FiFo[Fifo_Out].TimeStamp.second,ADR(secondsStr)),0,1) - 1;
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(secondsStr));
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(':000'));
						BufferStringEndAdr := memset(BufferStringEndAdr-itoa(T2FD.FiFo[Fifo_Out].TimeStamp.millisec,ADR(millisecondsStr)),0,1) - 1;
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(millisecondsStr));
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(';'));
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(T2FD.FiFo[Fifo_Out].Function));
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(';'));
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(T2FD.FiFo[Fifo_Out].Text));
						IF BufWriteStart AND DebugEnable THEN
							BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(' Buf-Start'));
						END_IF
						BufWriteStart := FALSE;
						BufferStringEndAdr := strcat(BufferStringEndAdr,ADR(CRLF)); // CR LF
						Fifo_Out := (Fifo_Out + 1) MOD T2F_Array_Size;
						BufferStringLen := BufferStringEndAdr - BufferStringStartAdr;
						LogInfoLineCount := LogInfoLineCount + 1;
					END_WHILE;

					BufferUsedLengthMax := MAX(BufferStringLen, BufferUsedLengthMax);
					IF Fifo_In = Fifo_Out THEN
						cmdT2F_WriteBuffer := FALSE;
					END_IF
					isRewriting := FALSE;
					IF isDataInBuffer THEN
						// Wait with data in buffer while new file is created.
						T2F_WriteState := T2F_WaitNewFile;
					ELSE
						isWritingFile := TRUE;
						FWrite(enable := TRUE, ident := dwIdent, offset := fileoffset1, pSrc := BufferStringStartAdr, len := BufferStringLen);
						fileoffset1 := fileoffset1 + BufferStringLen;
						T2F_WriteState := T2F_WaitWriteBuffer;
					END_IF
					UsedMilliseconds := TIME_TO_UDINT(clock_ms()) - StartBufferCount;
					UsedMillisecondsMax := MAX(UsedMilliseconds, UsedMillisecondsMax);
				END_IF
			
				// Buffer waiting with data for new file creation.
			T2F_WaitNewFile:
				IF NOT isBlockTraceFile1 THEN
					isDataInBuffer := FALSE;
					isWritingFile := TRUE;
					FWrite(enable := TRUE, ident := dwIdent, offset := fileoffset1, pSrc := BufferStringStartAdr, len := BufferStringLen);
					fileoffset1 := fileoffset1 + BufferStringLen;
					T2F_WriteState := T2F_WaitWriteBuffer;
				END_IF
				
				// Buffer writing in progress
			T2F_WaitWriteBuffer:
				wStatus := FWrite.status;
				IF wStatus <> 0 THEN
					FWrite();
					wStatus := FWrite.status;
				END_IF
				CASE wStatus OF
					0: // OK
						isWritingFile := cmdT2F_WriteBuffer;
						T2FD.FiFo_Out := Fifo_Out;
						doRepeat := TRUE;
						T2F_WriteState := T2F_Waiting;

					20721: // fiERR_FILE_NOT_OPENED 
						cmdRequestOpenFile := TRUE;
						T2F_WriteState := T2F_WaitOpenFile;
						
					65535: ;// BUSY
					ELSE
						cmdPrintErrorString := TRUE;
						T2F_WriteState := T2F_Error;
				END_CASE 
				
			T2F_WaitOpenFile:
				IF cmdRequestOpenFile THEN
					isWritingFile := FALSE;
					cmdRequestOpenFile := FALSE;
					T2F_WriteState := T2F_WaitEnable;
				ELSIF T2F_MakeNewFileState = T2F_WaitEnable THEN
					T2F_WriteState := T2F_WaitWriteBuffer;
				END_IF
				
			
			T2F_Error:
				IF T2F_State < T2F_Error THEN
					T2F_State := T2F_Error;
				END_IF
				T2F_WriteState := T2F_ErrorWait;
				
				// Wait for filesystem ok.
			T2F_ErrorWait:
				IF T2F_State < T2F_Error THEN
					T2F_WriteState := T2F_WaitEnable;
				END_IF
			
		END_CASE 
	
		// Error information.
		IF cmdPrintErrorString THEN
			cmdPrintErrorString := FALSE;
			errorCode := wStatus;
			errorcount := errorcount + 1;
			CASE wStatus OF
				9999: errorString := 'ERR_NOTIMPLEMENTED';
				20700: errorString := 'fiERR_INVALID_PATH';
				20702: errorString := 'fiERR_NO_MORE_ENTRIES';
				20703: errorString := 'fiERR_NOT_SUPPORTED';
				20704: errorString := 'fiERR_INVALID_TYP';
				20705: errorString := 'fiERR_EXIST';
				20706: errorString := 'fiERR_ACCESS';
				20708: errorString := 'fiERR_FILE_NOT_FOUND ';
				20709: errorString := 'fiERR_FILE_DEVICE';
				20710: errorString := 'fiERR_SPACE ';
				20711: errorString := 'fiERR_SEEK';
				20712: errorString := 'fiERR_FILE';
				20715: errorString := 'fiERR_COM_FILE_CLOSE';
				20717: errorString := 'fiERR_COM_FILE_WRITE';
				20718: errorString := 'fiERR_COM_FILE_IOCTL';
				20719: errorString := 'fiERR_DATA ';
				20721: errorString := 'fiERR_FILE_NOT_OPENED';
				20723: errorString := 'fiERR_DIR_NOT_EXIST';
				20729: errorString := 'fiERR_PARAMETER';
				20798: errorString := 'fiERR_DEVICE_MANAGER';
				20799: errorString := 'FileIoGetSysError';
				65534: errorString := 'ERR_FUB_ENABLE_FALSE';
				ELSE errorString := 'Else';
			END_CASE 
		END_IF
	UNTIL (NOT doRepeat) END_REPEAT
	
	OldMilliSeconds := g_MilliSeconds;
END_PROGRAM

PROGRAM _EXIT
	FClose(enable := dwIdent > 0, ident := dwIdent);
	FCloseError(enable := dwIdentErrClose > 0, ident := dwIdentErrClose);
	errorCode := FClose.status;
END_PROGRAM