FUNCTION_BLOCK FB_CT290
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Author:			Jensen Denmark
	
		Function:    	CT290
	
		Description: 	Handle Telegrams between B&R and the CT-290.
	
		Dependences:	
	
		Interfaces:  	
	
		History:		12-12-2005		V1.00		CRT
																														  *)
	(*----------------------------------------------* cyclic program *----------------------------------------------------*)
	(*
	
	
	
	*)
	(*--------------------------------------------------------------------------------------------------------------------*)
	
	
	IF NOT Init THEN
		Init := 1;
		CT290  ACCESS CT290DataAdr;
		Serial ACCESS SerialDataAdr;
		Status := 0;
		StatusString := 'Not Enabled';
		State := 15;
	END_IF;
	
	IF Serial.Rx > 0 THEN
		LastByte := Serial.Rx_Data[5] * 256 + Serial.Rx_Data[4] + 5;
		CheckSum := 0;
		FOR CheckSumCnt := 2 TO LastByte DO
			CheckSum := CheckSum + Serial.Rx_Data[CheckSumCnt];
		END_FOR;
		IF NOT ( Serial.Rx_Data[LastByte + 1] = UINT_TO_USINT( CheckSum MOD 256 )) OR
	       NOT ( Serial.Rx_Data[LastByte + 2] = UINT_TO_USINT( CheckSum / 256   )) THEN
			Serial.Rx := 0;
		END_IF;
	END_IF;
	
	CASE State OF
	
		0:
			IF Serial.Tx = 0 THEN
				IF CT290.Enable AND NOT REnable THEN
					State := 1;
				END_IF;
				IF NOT CT290.Enable AND REnable THEN
					State := 3;
				END_IF;
				IF CT290.Enable AND ( Status > 9 )  THEN
					Next := Next + 1;
					IF Next > 3 THEN
						Next := 0;
					END_IF;
					State := 9;
				END_IF;
				REnable := CT290.Enable;
			END_IF;
	
		1:	(* Init CT290 *)
			Serial.Tx_Data[03] := 000;					(* Type 				*)
			Serial.Tx_Data[04] := 001;					(* Length LSB 			*)
			Serial.Tx_Data[05] := 000;					(* Length MSB 			*)
			Serial.Tx_Data[06] := CT290.CT290Node;		(* Node  				*)
			Serial.Tx := 1;								(* Send Telegram 		*)
			State := 2;
	
		2:	(* Init Feedback *)
			IF Serial.Rx > 0 THEN
				IF ( Serial.Rx_Data[3] = 0 ) AND ( Serial.Rx_Data[6] = 1 ) THEN
					Status := 10;
					StatusString := 'Connection to CT290: Ok';
					Cnt := 0;
					State := 7;
				ELSE
					Status := 1;
					StatusString := 'Connection to CT290: No or Bad Answer';
					State  := 15;
				END_IF;
			END_IF;
	
		3:	(* Close CT290 *)
			Serial.Tx_Data[03] := 001;					(* Type 				*)
			Serial.Tx_Data[04] := 000;					(* Length LSB 			*)
			Serial.Tx_Data[05] := 000;					(* Length MSB 			*)
			Serial.Tx := 1;								(* Send Telegram 		*)
			State := 4;
	
		4:	(* Close CT290 Feedback *)
			IF Serial.Rx > 0 THEN
				IF ( Serial.Rx_Data[3] = 1 ) AND ( Serial.Rx_Data[5] = 0 ) THEN
					REnable := 0;
					Status  := 0;
					StatusString := 'Connection to CT290: Closed';
					State   := 15;
				ELSE
					Status := 2;
					StatusString := 'Connection to CT290: Could Not be Closed';
					State := 15;
				END_IF;
			END_IF;
	
		5:	(* Arcnet Active *)
			Serial.Tx_Data[03] := 005;					(* Type 				*)
			Serial.Tx_Data[04] := 000;					(* Length LSB 			*)
			Serial.Tx_Data[05] := 000;					(* Length MSB 			*)
			Serial.Tx := 1;							(* Send Telegram 		*)
			State := 6;
	
		6:	(* Active Feedback *)
			IF Serial.Rx > 0 THEN
				IF ( Serial.Rx_Data[3] = 5 ) AND ( Serial.Rx_Data[6] = CT290.CT290Node ) THEN
					Status := 11;
					StatusString := 'Arcnet Status: Ok';
					State  := 0;
				ELSE
					Status := 03;
					StatusString := 'Arcnet Status: Not Running';
					State  := 15;
				END_IF;
			END_IF;
	
		7:	(* Requests *)
			CASE Cnt OF
				0..3:	(* Outputs *)
					CT290.Get[Cnt].Output.Status := 0;
					CT290.Get[Cnt].Output.StatusString := 'NotUsed';
					IF CT290.Get[Cnt].Enable THEN
						Serial.Tx_Data[03] := 021;
						Serial.Tx_Data[04] := 005;
						Serial.Tx_Data[05] := 000;
						Serial.Tx_Data[06] := CT290.Get[Cnt].ConnectionNode;
						IF CT290.Get[Cnt].Output.First < 193 THEN
							Serial.Tx_Data[07] := CT290.Get[Cnt].Output.First;
							Serial.Tx_Data[08] := CT290.Get[Cnt].Output.First + 63;
						ELSE
							Serial.Tx_Data[07] := CT290.Get[Cnt].Output.First;
							Serial.Tx_Data[08] := 255;
						END_IF;
						Serial.Tx_Data[09] := Cnt * 64;
						Serial.Tx_Data[10] := 1;
						Serial.Tx := 1;
						No := Cnt;
						State := 8;
					END_IF;
	
				4..7:	(* Registers *)
					CT290.Get[Cnt-4].Register.Status := 0;
					CT290.Get[Cnt-4].Register.StatusString := 'NotUsed';
					IF CT290.Get[Cnt-4].Enable THEN
						Serial.Tx_Data[03] := 024;
						Serial.Tx_Data[04] := 005;
						Serial.Tx_Data[05] := 000;
						Serial.Tx_Data[06] := CT290.Get[Cnt-4].ConnectionNode;
						IF CT290.Get[Cnt-4].Register.First < 224 THEN
							Serial.Tx_Data[07] := CT290.Get[Cnt-4].Register.First;
							Serial.Tx_Data[08] := CT290.Get[Cnt-4].Register.First + 31;
						ELSE
							Serial.Tx_Data[07] := CT290.Get[Cnt-4].Register.First;
							Serial.Tx_Data[08] := 255;
						END_IF;
						Serial.Tx_Data[09] := ( Cnt - 4 ) * 64;
						Serial.Tx_Data[10] := 1;
						Serial.Tx := 1;
						No := Cnt - 4;
						State := 8;
					END_IF;
	
				8..11:	(* Actual Timers *)
					CT290.Get[Cnt-8].ActualTimer.Status := 0;
					CT290.Get[Cnt-8].ActualTimer.StatusString := 'NotUsed';
					IF CT290.Get[Cnt-8].Enable THEN
						Serial.Tx_Data[03] := 022;
						Serial.Tx_Data[04] := 005;
						Serial.Tx_Data[05] := 000;
						Serial.Tx_Data[06] := CT290.Get[Cnt-8].ConnectionNode;
						IF CT290.Get[Cnt-8].ActualTimer.First < 224 THEN
							Serial.Tx_Data[07] := CT290.Get[Cnt-8].ActualTimer.First;
							Serial.Tx_Data[08] := CT290.Get[Cnt-8].ActualTimer.First + 31;
						ELSE
							Serial.Tx_Data[07] := CT290.Get[Cnt-8].ActualTimer.First;
							Serial.Tx_Data[08] := 255;
						END_IF;
						Serial.Tx_Data[09] := ( Cnt - 8 ) * 32;
						Serial.Tx_Data[10] := 1;
						Serial.Tx := 1;
						No := Cnt - 8;
						State := 8;
					END_IF;
	
				12..15:	(* Categories *)
					CT290.Get[Cnt-12].Category.Status := 0;
					CT290.Get[Cnt-12].Category.StatusString := 'NotUsed';
					IF CT290.Get[Cnt-12].Enable > 0 THEN
						Serial.Tx_Data[03] := 026;
						Serial.Tx_Data[04] := 002;
						Serial.Tx_Data[05] := 000;
						Serial.Tx_Data[06] := CT290.Get[Cnt-12].ConnectionNode;
						Serial.Tx_Data[07] := 001;
						Serial.Tx := 1;
						No := Cnt - 12;
						State := 8;
					END_IF;
	
			END_CASE;
			Cnt := Cnt + 1;
			IF Cnt > 15 THEN
				Cnt := 0;
				State := 0;
			END_IF;
	
		8:	(* Active Feedback *)
			IF Serial.Rx > 0 THEN
				CASE Serial.Rx_Data[3] OF
					21: (* OutPuts *)
						IF Serial.Rx_Data[6] = 1 THEN
							CT290.Get[No].Output.Status := 1;
							CT290.Get[No].Output.StatusString := 'Ok';
						ELSE
							CT290.Get[No].Output.Status := 2;
							CT290.Get[No].Output.StatusString := 'Error';
						END_IF;
					22: (* ActualTimers *)
						IF Serial.Rx_Data[6] = 1 THEN
							CT290.Get[No].ActualTimer.Status := 1;
							CT290.Get[No].ActualTimer.StatusString := 'Ok';
						ELSE
							CT290.Get[No].ActualTimer.Status := 2;
							CT290.Get[No].ActualTimer.StatusString := 'Error';
						END_IF;
					24: (* Registers *)
						IF Serial.Rx_Data[6] = 1 THEN
							CT290.Get[No].Register.Status := 1;
							CT290.Get[No].Register.StatusString := 'Ok';
						ELSE
							CT290.Get[No].Register.Status := 2;
							CT290.Get[No].Register.StatusString := 'Error';
						END_IF;
					26: (* Category *)
						IF Serial.Rx_Data[6] = 1 THEN
							CT290.Get[No].Category.Status := 1;
							CT290.Get[No].Category.StatusString := 'Ok';
						ELSE
							CT290.Get[No].Category.Status := 2;
							CT290.Get[No].Category.StatusString := 'Error';
						END_IF;
				END_CASE;
				State := 7;
			END_IF;
	
		9:	(* Get Data *)
			IF CT290.Get[Next].Enable THEN
				Serial.Tx_Data[03] := 045;
				Serial.Tx_Data[04] := 012;
				Serial.Tx_Data[05] := 000;
				Serial.Tx_Data[06] := 001;
				Serial.Tx_Data[07] := Next * 64;
				Serial.Tx_Data[08] := Next * 64 + 63;
				Serial.Tx_Data[09] := 003;
				Serial.Tx_Data[10] := Next * 64;
				Serial.Tx_Data[11] := Next * 64 + 31;
				Serial.Tx_Data[12] := 004;
				Serial.Tx_Data[13] := Next * 32;
				Serial.Tx_Data[14] := Next * 32 + 31;
				Serial.Tx_Data[15] := 006;
				Serial.Tx_Data[16] := CT290.Get[Next].ConnectionNode;
				Serial.Tx_Data[17] := 000;
				Serial.Tx := 1;
				State := 10;
			ELSE
				State := 11;
			END_IF;
	
		10:	(* Active Feedback *)
			IF Serial.Rx > 0 THEN
				IF Serial.Rx_Data[3] = Serial.Tx_Data[3] THEN
					FOR Cnt := 0 TO 63 DO
						CT290.Get[Next].Output.No[Cnt] := USINT_TO_BOOL( Serial.Rx_Data[Cnt+18] );
						IF Cnt < 32 THEN
							CT290.Get[Next].Register.No[Cnt] := USINT_TO_BOOL( Serial.Rx_Data[Cnt+82] );
							CT290.Get[Next].ActualTimer.No[Cnt] := ( Serial.Rx_Data[Cnt*2+115] * 256 ) + Serial.Rx_Data[Cnt*2+114];
						END_IF;
						CT290.Get[Next].Category.No := Serial.Rx_Data[178];
					END_FOR;
				END_IF;
				State := 11;
			END_IF;
	
		11:	(* Set Data *)
			State := 13;
			CASE Next OF
				0:	(* Set Outputs *)
					IF CT290.Set.Enable THEN
						Serial.Tx_Data[03] := 61;
						Serial.Tx_Data[05] := 0;
						IF CT290.Set.Output.First < 193 THEN
							Serial.Tx_Data[04] := 66;
							Serial.Tx_Data[06] := CT290.Set.Output.First;
							Serial.Tx_Data[07] := CT290.Set.Output.First + 63;
							memcpy( ADR( Serial.Tx_Data[8] ), ADR( CT290.Set.Output.No[0] ), 64 );
						ELSE
							Serial.Tx_Data[04] := 255 - CT290.Set.Output.First;
							Serial.Tx_Data[06] := CT290.Set.Output.First;
							Serial.Tx_Data[07] := 255;
							memcpy( ADR( Serial.Tx_Data[8] ), ADR( CT290.Set.Output.No[0] ), 255 - CT290.Set.Output.First );
						END_IF;
						Serial.Tx := 1;
						State := 12;
					ELSE
						CT290.Set.Output.Status := 0;
						CT290.Set.Output.StatusString := 'Not Enabled';
					END_IF;
	
				1:	(* Set Registers *)
					IF CT290.Set.Enable THEN
						Serial.Tx_Data[03] := 64;
						Serial.Tx_Data[05] := 0;
						IF CT290.Set.Register.First < 224 THEN
							Serial.Tx_Data[04] := 34;
							Serial.Tx_Data[06] := CT290.Set.Register.First;
							Serial.Tx_Data[07] := CT290.Set.Register.First + 31;
							memcpy( ADR( Serial.Tx_Data[8] ), ADR( CT290.Set.Register.No[0] ), 32 );
						ELSE
							Serial.Tx_Data[04] := 255 - CT290.Set.Register.First + 2;
							Serial.Tx_Data[06] := CT290.Set.Register.First;
							Serial.Tx_Data[07] := 255;
							memcpy( ADR( Serial.Tx_Data[8] ), ADR( CT290.Set.Register.No[0] ), 255 - CT290.Set.Register.First );
						END_IF;
						Serial.Tx := 1;
						State := 12;
					ELSE
						CT290.Set.Register.Status := 0;
						CT290.Set.Register.StatusString := 'Not Enabled';
					END_IF;
	
				2:	(* Set Actual Timers *)
					IF CT290.Set.Enable THEN
						Serial.Tx_Data[03] := 62;
						Serial.Tx_Data[05] := 0;
						IF CT290.Set.ActualTimer.First < 224 THEN
							Serial.Tx_Data[04] := 66;
							Serial.Tx_Data[06] := CT290.Set.ActualTimer.First;
							Serial.Tx_Data[07] := CT290.Set.ActualTimer.First + 31;
							memcpy( ADR( Serial.Tx_Data[8] ), ADR( CT290.Set.ActualTimer.No[0] ), 64 );
						ELSE
							Serial.Tx_Data[04] := 2 + 2 * ( 255 - CT290.Set.ActualTimer.First + 1 );
							Serial.Tx_Data[06] := CT290.Set.ActualTimer.First;
							Serial.Tx_Data[07] := 255;
							memcpy( ADR( Serial.Tx_Data[8] ), ADR( CT290.Set.ActualTimer.No[0] ), 2 * ( 255 - CT290.Set.ActualTimer.First ));
						END_IF;
						Serial.Tx := 1;
						State := 12;
					ELSE
						CT290.Set.ActualTimer.Status := 0;
						CT290.Set.ActualTimer.StatusString := 'Not Enabled';
					END_IF;
	
				3:	(* Set Category *)
					IF CT290.Set.Enable THEN
						Serial.Tx_Data[03] := 65;
						Serial.Tx_Data[04] := 1;
						Serial.Tx_Data[05] := 0;
						Serial.Tx_Data[06] := CT290.Set.Category.No;
						IF ( Serial.Tx_Data[6] = 0 ) OR ( Serial.Tx_Data[6] > 99 )THEN
							Serial.Tx_Data[6] := 99;
						END_IF;
						Serial.Tx := 1;
						State := 12;
					ELSE
						CT290.Set.Category.Status := 0;
						CT290.Set.Category.StatusString := 'Not Enabled';
					END_IF;
			END_CASE;
	
		12:	(* Active Feedback *)
			IF Serial.Rx > 0 THEN
				CASE Next OF
					0:
						IF ( Serial.Rx_Data[3] = Serial.Tx_Data[3] ) AND ( Serial.Rx_Data[4] = 0 ) AND ( Serial.Rx_Data[5] = 0 ) THEN
							CT290.Set.Output.Status := 1;
							CT290.Set.Output.StatusString := 'Ok';
						ELSE
							CT290.Set.Output.Status := 2;
							CT290.Set.Output.StatusString := 'Error';
						END_IF;
					1:
						IF ( Serial.Rx_Data[3] = Serial.Tx_Data[3] ) AND ( Serial.Rx_Data[4] = 0 ) AND ( Serial.Rx_Data[5] = 0 ) THEN
							CT290.Set.Register.Status := 1;
							CT290.Set.Register.StatusString := 'Ok';
						ELSE
							CT290.Set.Register.Status := 2;
							CT290.Set.Register.StatusString := 'Error';
						END_IF;
					2:
						IF ( Serial.Rx_Data[3] = Serial.Tx_Data[3] ) AND ( Serial.Rx_Data[4] = 0 ) AND ( Serial.Rx_Data[5] = 0 ) THEN
							CT290.Set.ActualTimer.Status := 1;
							CT290.Set.ActualTimer.StatusString := 'Ok';
						ELSE
							CT290.Set.ActualTimer.Status := 2;
							CT290.Set.ActualTimer.StatusString := 'Error';
						END_IF;
					3:
						IF ( Serial.Rx_Data[3] = Serial.Tx_Data[3] ) AND ( Serial.Rx_Data[4] = 0 ) AND ( Serial.Rx_Data[5] = 0 ) THEN
							CT290.Set.Category.Status := 1;
							CT290.Set.Category.StatusString := 'Ok';
						ELSE
							CT290.Set.Category.Status := 2;
							CT290.Set.Category.StatusString := 'Error';
						END_IF;
				END_CASE;
				State := 13;
			END_IF;
	
		13:	(* Arcnet Status *)
			IF CT290.Get[Next].Enable THEN
				Serial.Tx_Data[03] := 002;
				Serial.Tx_Data[04] := 001;
				Serial.Tx_Data[05] := 000;
				Serial.Tx_Data[06] := CT290.Get[Next].ConnectionNode;
				Serial.Tx := 1;
				State := 14;
			ELSE
				CT290.Get[Next].Status := 0;
				CT290.Get[Next].StatusString := 'Not Enabled';
				State := 0;
			END_IF;
	
		14:	(* Status Feedback *)
			IF Serial.Rx > 0 THEN
				IF ( Serial.Rx_Data[3] = 2 ) AND ( Serial.Rx_Data[6] = 1 ) THEN
					CT290.Get[Next].Status := 1;
					CT290.Get[Next].StatusString := 'Connection Ok';
				ELSE
					CT290.Get[Next].Status := 2;
					CT290.Get[Next].StatusString := 'Connection Error';
				END_IF;
				State := 5;
			END_IF;
	
		15:	(* No Connection *)
			FOR Cnt := 0 TO 3 DO
				CT290.Get[Cnt].Status := 0;
				CT290.Get[Cnt].StatusString := 'Not Enabled';
				CT290.Get[Cnt].Output.Status := 0;
				CT290.Get[Cnt].Output.StatusString := 'Not Enabled';
				CT290.Get[Cnt].Register.Status := 0;
				CT290.Get[Cnt].Register.StatusString := 'Not Enabled';
				CT290.Get[Cnt].ActualTimer.Status := 0;
				CT290.Get[Cnt].ActualTimer.StatusString := 'Not Enabled';
				CT290.Get[Cnt].Category.Status := 0;
				CT290.Get[Cnt].Category.StatusString := 'Not Enabled';
			END_FOR;
			CT290.Set.Output.Status := 0;
			CT290.Set.Output.StatusString := 'Not Enabled';
			CT290.Set.Register.Status := 0;
			CT290.Set.Register.StatusString := 'Not Enabled';
			CT290.Set.ActualTimer.Status := 0;
			CT290.Set.ActualTimer.StatusString := 'Not Enabled';
			CT290.Set.Category.Status := 0;
			CT290.Set.Category.StatusString := 'Not Enabled';
			State  := 0;
	
	END_CASE;
	
	IF Serial.Tx = 1 THEN
		Serial.Tx_Data[00] := 115;
		Serial.Tx_Data[01] := 038;
		Serial.Tx_Data[02] := 000;
		LastByte := Serial.Tx_Data[5] * 256 + Serial.Tx_Data[4] + 5;
		CheckSum := 0;
		FOR CheckSumCnt := 2 TO LastByte DO
			CheckSum := CheckSum + Serial.Tx_Data[CheckSumCnt];
		END_FOR;
		Serial.Tx_Data[LastByte + 1] := UINT_TO_USINT( CheckSum MOD 256 );
		Serial.Tx_Data[LastByte + 2] := UINT_TO_USINT( CheckSum / 256 );
		Serial.Tx := UINT_TO_USINT( LastByte ) + 3;
	END_IF;
	
	TimeOutDelay( IN := (( Serial.Tx = 0 ) AND CT290.Enable ) , PT:= 180 );
	IF TimeOutDelay.Q THEN
		Status := 4;
		StatusString := 'Connection to CT290: Timed Out';
	State := 3;
	END_IF;
	
	Serial.Rx := 0;
	
	CT290.Status := Status;
	CT290.StatusString := StatusString;
	
	
END_FUNCTION_BLOCK