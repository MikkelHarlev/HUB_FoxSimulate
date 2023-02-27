FUNCTION_BLOCK FB_Tag_Read_Write
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Author:			Jensen Denmark
	
		Function:    	Tag_Read_Write
	
		Description: 	Handle Reading and Writing of RFID Tags.
	
		Dependences:	Serial_Com function in JEDK V0.35 or later.
	
		Interfaces:  	
	
		History:		28-09-2009	V1.00	CRT		Error correction in read/write partial data
																														  *)
	(*----------------------------------------------* cyclic program *----------------------------------------------------*)

	IF pSerial <> oldpSerial OR pConfig <> oldpConfig OR pData <> oldpData THEN
		InitDone := FALSE;
	END_IF
	oldpSerial := pSerial;
	oldpConfig := pConfig;
	oldpData := pData;
	
	(* Buffer *)
	IF NOT InitDone THEN
		IF (pSerial > 0) AND (pConfig > 0) AND (pData > 0) THEN
			InitDone := 1;
			Serial ACCESS pSerial;
			Config ACCESS pConfig;
			Tag    ACCESS pData;
		ELSE
			ErrorNumber := 99;
			ErrorString := 'Pointer Error';
			RETURN;
		END_IF;
	END_IF;
	
	(* Handling off Requests *)
	CASE State OF
	
		00:	(* Wait for Command *)
			CASE Command OF
				1: 	(* Read Tag *)
					
					IF (EnableMetaData) THEN
						State    := 50;
						SubState := 10;
					ELSE
						State    := 10;	
					END_IF
				2:	(* Write Tag *)
					
					IF (EnableMetaData) THEN
						State 	 := 50;
						SubState := 20;
					ELSE
						State    := 20;
					END_IF
				3:	(* Reset Tag *)
					State := 30;
				4:	(* Abort Telegram *)
                    State := 40;
				5: (* Read UniqueID *)
					State := 50;
            END_CASE;
			Serial.Rx := 0;
	
		10:	(* Send Read Request to Tag *)
			// Clear local tag data, to prevent wrong read
			memset(ADR(Tag.LinenData) + Config.DataStart,0, Config.DataLength);
			// Read Tag
			ErrorNumber := 0;
			ErrorString := '';
			Serial.Tx_Data[00] := 082; 
			IF (Config.DataStart + Config.DataLength) > Config.MemorySize THEN
				ErrorNumber := 70;
				State := 99;
			ELSE
				Length :=itoa(Config.DataStart, ADR(Serial.Tx_Data[1]));
				IF Length > 4 THEN
					ErrorNumber := 71;
					State := 99;
				ELSE
					Serial.Tx_Data[01] := 048;
					Serial.Tx_Data[02] := 048;
					Serial.Tx_Data[03] := 048;
					Serial.Tx_Data[04] := 048;
					itoa(Config.DataStart, ADR(Serial.Tx_Data[5-Length]));
				END_IF;
				Length :=itoa(Config.DataLength, ADR(Serial.Tx_Data[5]));
				IF Length > 4 THEN
					ErrorNumber := 72;
					State := 99;
				ELSE
					Serial.Tx_Data[05] := 048;
					Serial.Tx_Data[06] := 048;
					Serial.Tx_Data[07] := 048;
					Serial.Tx_Data[08] := 048;
					itoa(Config.DataLength, ADR(Serial.Tx_Data[9-Length]));
					TxSize := 09;
					Serial.Rx_Data[0] := 0;
					Serial.Rx_Data[1] := 0;
					State := 11;
				END_IF;
			END_IF;
	
		11:	(* Wait for responce *)
			IF (Serial.Rx > 0) THEN
				IF (Serial.Rx_Data[0] = 6) AND (Serial.Rx_Data[1] = 48) THEN
					State := 12;
				ELSE
					ErrorNumber := Serial.Rx_Data[1] - 48;
					State := 99;
				END_IF;
				Serial.Rx := 0;
			END_IF;
	
		12:	(* Request Data from Tag *)
			Serial.Tx_Data[0] := 002;
			Serial.Tx := 1;
			State := 13;
	
		13:	(* Check Data from Tag *)
			IF (Serial.Rx > 0) THEN
				RxChecksum  := 0;
				FOR Cnt := 0 TO Serial.Rx - 1 DO
					RxChecksum := RxChecksum XOR Serial.Rx_Data[Cnt];
				END_FOR;
				IF RxChecksum = 0 THEN
					memcpy(ADR(Tag.LinenData) + Config.DataStart, ADR(Serial.Rx_Data), Config.DataLength);
					ExecutionTime := 10 * Timeout.ET;
					Command := 0;
					State   := 0;
				ELSE
					ErrorNumber := 080;
					State := 99;
				END_IF;
				Serial.Rx := 0;
			END_IF;
	
		20:	(* Send Write Request to Tag *)
			ErrorNumber := 0;
			ErrorString := '';
			Serial.Tx_Data[00] := 087;
			IF (Config.DataStart + Config.DataLength) > Config.MemorySize THEN
				ErrorNumber := 70;
				State := 99;
			ELSE
				Length :=itoa(Config.DataStart, ADR(Serial.Tx_Data[1]));
				IF Length > 4 THEN
					ErrorNumber := 71;
					State := 99;
				ELSE
					Serial.Tx_Data[01] := 048;
					Serial.Tx_Data[02] := 048;
					Serial.Tx_Data[03] := 048;
					Serial.Tx_Data[04] := 048;
					itoa(Config.DataStart, ADR(Serial.Tx_Data[5-Length]));
				END_IF;
				Length :=itoa(Config.DataLength, ADR(Serial.Tx_Data[5]));
				IF Length > 4 THEN
					ErrorNumber := 72;
					State := 99;
				ELSE
					Serial.Tx_Data[05] := 048;
					Serial.Tx_Data[06] := 048;
					Serial.Tx_Data[07] := 048;
					Serial.Tx_Data[08] := 048;
					itoa(Config.DataLength, ADR(Serial.Tx_Data[9-Length]));
					TxSize := 09;
					Serial.Rx_Data[0] := 0;
					Serial.Rx_Data[1] := 0;
					State := 21;
				END_IF;
			END_IF;
	
		21:	(* Wait for responce *)
			IF (Serial.Rx > 0) THEN
				IF (Serial.Rx_Data[0] = 6) AND (Serial.Rx_Data[1] = 48) THEN
					State := 22;
				ELSE
					ErrorNumber := Serial.Rx_Data[1] - 48;
					State := 99;
				END_IF;
				Serial.Rx := 0;
			END_IF;
	
		22:	(* Send Data to Tag *)
			Serial.Tx_Data[0] := 2;
			memcpy(ADR(Serial.Tx_Data[1]), ADR(Tag.LinenData) + Config.DataStart, Config.DataLength);
			TxSize := UINT_TO_USINT(Config.DataLength + 1);
			Serial.Rx_Data[0] := 0;
			Serial.Rx_Data[1] := 0;
			State := 23;
	
		23:	(* Wait for responce *)
			IF (Serial.Rx > 0) THEN
				IF (Serial.Rx_Data[0] = 6) AND (Serial.Rx_Data[1] = 48) THEN
					ExecutionTime := 10 * Timeout.ET;
					Command := 0;
					State := 0;
				ELSE
					ErrorNumber := Serial.Rx_Data[1] - 48;
					State := 99;
				END_IF;
				Serial.Rx := 0;
			END_IF;
	
		30:	(* Send Reset Command to Tag *)
			ErrorNumber := 0;
			ErrorString := '';
			Serial.Tx_Data[00] := 081;
			Serial.Tx_Data[01] := 081;
			Serial.Tx := 2;
			Serial.Rx_Data[0] := 0;
			Serial.Rx_Data[1] := 0;
			State := 31;
	
		31:	(* Wait for responce *)
			IF (Serial.Rx > 0) THEN
				IF (Serial.Rx_Data[0] = 81) AND (Serial.Rx_Data[1] = 81) THEN
					ExecutionTime := 10 * Timeout.ET;
					Command := 0;
					State := 0;
				ELSE
					ErrorNumber := 90;
					State := 99;
				END_IF;
				Serial.Rx := 0;
			END_IF;
	
		40:	(* Abort Telegram *)
			ErrorNumber := 0;
			ErrorString := '';
			Serial.Tx_Data[00] := 038;
			Serial.Tx_Data[01] := 038;
			Serial.Tx_Data[02] := 038;
			Serial.Tx_Data[03] := 038;
			Serial.Tx_Data[04] := 038;
			Serial.Tx_Data[05] := 038;
			Serial.Tx_Data[06] := 038;
			Serial.Tx_Data[07] := 038;
			Serial.Tx_Data[08] := 038;
			Serial.Tx_Data[09] := 038;
			Serial.Tx_Data[10] := 038;
			Serial.Tx_Data[11] := 038;
			Serial.Tx := 12;
			Serial.Rx_Data[0] := 0;
			Serial.Rx_Data[1] := 0;
			State := 41;
	
		41:	(* Wait for responce *)
			IF (Serial.Rx > 0) THEN
				IF (Serial.Rx_Data[0] = 21) AND (Serial.Rx_Data[1] = 55) THEN
					ExecutionTime := 10 * Timeout.ET;
					Command := 0;
					State := 0;
				ELSE
					ErrorNumber := 91;
					State := 99;
				END_IF;
				Serial.Rx := 0;
            END_IF;
			
		// Read Unique ID From tag!
		50:	(* Send Read Request to Tag *)
			ErrorNumber := 0;
			ErrorString := '';
			Serial.Tx_Data[00] := 085;
			TxSize := 01;
			Serial.Rx_Data[0] := 0;
			Serial.Rx_Data[1] := 0;
			State := 51;
			memset(ADR(Tag.MetaData),0,SIZEOF(Tag.MetaData));
			
		51:	(* Wait for responce *)
			IF (Serial.Rx > 0) THEN
				// Check checksum
				RxChecksum  := 0;
				FOR Cnt := 0 TO Serial.Rx - 1 DO
					RxChecksum := RxChecksum XOR Serial.Rx_Data[Cnt];
				END_FOR;
				// Checksum ok.
				IF RxChecksum = 0 THEN
					IF (Serial.Rx_Data[0] = 48) THEN
						// Set metadata
						Tag.MetaData.TagType := Serial.Rx_Data[1];
						memcpy(ADR(Tag.MetaData.UniqueID[0]),ADR(Serial.Rx_Data[2]),8);
						State := SubState;
					ELSE
						ErrorNumber := 123;
						State 		:= 99;
					END_IF;
				ELSE
					ErrorNumber := 080;
					State 		:= 99;
				END_IF

				Serial.Rx := 0;
				ExecutionTime := 10 * Timeout.ET;
				IF (SubState = 0) THEN
					Command := 0;
				ELSE
					SubState := 0;
				END_IF
				
			END_IF;
		// Unique ID End.
			
	
		99:	(* Error Handling *)
			CASE ErrorNumber OF
				001:	ErrorString := 'No Tag Present';
				002:	ErrorString := 'Read Error';
				004:	ErrorString := 'Write Error';
				006:	ErrorString := 'Interface Error';
				007:	ErrorString := 'Telegram Format Error';
				008:	ErrorString := 'Transmit Data Checksum Error';
				068:	ErrorString := 'CT Error !!!';
				069:	ErrorString := 'CRC Error !!!';
				060:	ErrorString := 'Timeout In Transmission';
				070:	ErrorString := 'Data Start and Data Length > Tag Data Size';
				071:	ErrorString := 'Data Start Illegal';
				072:	ErrorString := 'Data Length Illegal';
				080:	ErrorString := 'Receive Data Checksum Error';
				090:	ErrorString := 'Reset Not Done';
				091:	ErrorString := 'Abort Telegram Not Done';
				123:	ErrorString := 'No Data Carrier Was Recognized';
			ELSE
				ErrorString := 'Unknown Error';
			END_CASE;
			Command := 0;
			State   := 0;
	
	END_CASE;
	
	(* Transmit Telegram *)
	IF TxSize > 0 THEN
		TxChecksum := 0;
		FOR Cnt := 0 TO TxSize - 1 DO
			TxChecksum := TxChecksum XOR Serial.Tx_Data[Cnt];
		END_FOR;
		Serial.Tx_Data[TxSize] := TxChecksum;
		Serial.Tx := TxSize + 1;
		TxSize := 0;
	END_IF;
	
	(* TimeOut *)
	Timeout(IN := USINT_TO_BOOL(Command), PT := 200);
	IF Timeout.Q THEN
		ErrorNumber := 60;
		State := 99;
	END_IF;
END_FUNCTION_BLOCK