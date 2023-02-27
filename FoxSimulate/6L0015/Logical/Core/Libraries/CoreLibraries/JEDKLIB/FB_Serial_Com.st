FUNCTION_BLOCK FB_Serial_Com
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Author:			Jensen Denmark
	
		Function:    	Serial_Com
	
		Description: 	Handle Serial Communication.
	
		Dependences:	
	
		Interfaces:  	
	
		History:		30-12-2005		V0.01		CRT
																														  *)
	(*----------------------------------------------* cyclic program *----------------------------------------------------*)
	(*
	
	
	
	
	*)
	(*--------------------------------------------------------------------------------------------------------------------*)
	
	
	(* Initialize Config Structure *)
	DataAdr := ADR( Serial );
	IF NOT InitDone THEN
		InitDone    := 1;
		IF NOT UseExtendedConfig THEN
			config_struct.idle     := 4;
			config_struct.delimc   := 0;
			config_struct.delim[0] := 0;
			config_struct.delim[1] := 0;
			config_struct.tx_cnt   := 8;
			config_struct.rx_cnt   := 8;
			config_struct.tx_len   := 256;
			config_struct.rx_len   := 256;
			config_struct.argc     := 0;
			config_struct.argv     := 0;
		END_IF;
	END_IF;
	
	CASE State OF
		0:	(* Wait for Command *)
			IF ( IdentFrmOpen = 0 ) THEN
				State := 1;
			ELSE
				(* Send Data *)
				IF Serial.Tx > 0 THEN
					FRM_gbuf_0();
					IF ( FRM_gbuf_0.status = 0 ) THEN
						memcpy( FRM_gbuf_0.buffer, ADR( Serial.Tx_Data ), Serial.Tx );
						FRM_write_0.buffer := FRM_gbuf_0.buffer;
						FRM_write_0.buflng := Serial.Tx;
						FRM_write_0();
						Serial.Tx := 0;
						IF ( FRM_write_0.status <> 0 ) THEN
							FRM_robuf_0.buffer := FRM_gbuf_0.buffer;
							FRM_robuf_0.buflng := FRM_gbuf_0.buflng;
							FRM_robuf_0();
							State := 3;
						END_IF;
					ELSE
						State := 3;
					END_IF;
				END_IF;
				FRM_read_0();
				IF ( FRM_read_0.status = 0 ) THEN
					memcpy( ADR( Serial.Rx_Data ), FRM_read_0.buffer, FRM_read_0.buflng );
					FRM_rbuf_0.buffer := FRM_read_0.buffer;
					FRM_rbuf_0.buflng := FRM_read_0.buflng;
					FRM_rbuf_0();
					IF ( FRM_rbuf_0.status <> 0 ) THEN
						State := 3;
					ELSE
						Serial.Rx := UINT_TO_USINT( FRM_read_0.buflng );
					END_IF;
				ELSIF ( FRM_read_0.status <> 1 ) AND ( FRM_read_0.status <> 60 ) THEN
					State := 3;
				END_IF;
			END_IF;
	
		1:	(* Open Serial Channel *)
			FRM_xopen_0.enable := 1;
			FRM_xopen_0.config := ADR( config_struct );
			FRM_xopen_0.device := ADR( Port );
			FRM_xopen_0.mode   := ADR( ComSettings );
			FRM_xopen_0();
			FRM_xopen_0.enable := 0;
			IF ( FRM_xopen_0.status = 0 ) THEN
				IdentFrmOpen := FRM_xopen_0.ident;
				State := 2;
			ELSE
				State := 3;
			END_IF;
	
		2:	(* Enable Buffers *)
			FRM_gbuf_0.enable  := 1;
			FRM_gbuf_0.ident   := IdentFrmOpen;
			FRM_write_0.enable := 1;
			FRM_write_0.ident  := IdentFrmOpen;
			FRM_robuf_0.enable := 1;
			FRM_robuf_0.ident  := IdentFrmOpen;
			FRM_rbuf_0.enable  := 1;
			FRM_rbuf_0.ident   := IdentFrmOpen;
			FRM_read_0.enable  := 1;
			FRM_read_0.ident   := IdentFrmOpen;
			Status := 1;
			State := 0;
	
		3:	(* Close Serial Channel *)
			IF ( IdentFrmOpen <> 0 ) THEN
				FRM_close_0.enable := 1;
				FRM_close_0.ident := IdentFrmOpen;
				FRM_close_0();
				IdentFrmOpen := 0;
				Status :=  0;
			END_IF;
            State := 0;
    END_CASE;
    
    // Test for rail...
    IF (dInit = 1) THEN
        dInit := 0;
        FRM_close_0.enable := 1;
        FRM_close_0.ident := IdentFrmOpen;
        FRM_close_0();
        Status := 2; // Serial ports closed...
    END_IF
	
	IF Serial.Tx > 0 THEN
		TimeOutDelay( IN := 1, PT := 100 );
		IF TimeOutDelay.Q THEN
			Serial.Tx := 0;
		END_IF;
	END_IF;
	
	
END_FUNCTION_BLOCK