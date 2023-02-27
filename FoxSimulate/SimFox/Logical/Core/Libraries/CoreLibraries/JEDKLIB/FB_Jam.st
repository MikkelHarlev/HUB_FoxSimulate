FUNCTION_BLOCK FB_Jam
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Author:			Jensen Denmark
	
		Function:    	Jam
	
		Description: 	Handle Jams.
	
		Dependences:	
	
		Interfaces:  	
	
		History:		30-05-2006		V0.01		CRT
																														  *)
	(*----------------------------------------------* cyclic program *----------------------------------------------------*)
	(*
		Description:
		
		
		Inputs:		Enable			USINT	0 = OFF, 1 = Alarm if 1 Item is lost, 2 = Alarm if 2 Items is lost... 
					Reset			BOOL	Reset Qeue
					Start			BOOL	Trigs the function and put one item in qeue
					Stop			BOOL	Remove one item from qeue
					JamTimeOut		UINT	Timeout ( TaskClass Scantime used )
					JamTolerence	UINT	Tolerence ( TaskClass Scantime used )
					
		Outputs:	Jam				BOOL	Set if Jam occurs
					Status			USINT	Status of the function
	
	(*--------------------------------------------------------------------------------------------------------------------*)
	
	IF CntAdr <> oldCntAdr THEN
		InitDone := FALSE;
	END_IF
	oldCntAdr := CntAdr;
	
	(* Init *)
	IF NOT InitDone THEN
		IF CntAdr > 0 THEN
			Counter ACCESS (CntAdr);
		ELSE
			Status   := 3;
			StatusString := 'CntAdr = 0';
			RETURN;
		END_IF;
		InitDone  := 1;
		Reset     := 1;
	END_IF;
	
	(* Disable Function *)
	IF Enable = 0 THEN
		Start := 0;
		Stop  := 0;
		Jam   := 0;
		RETURN;
	END_IF;
	
	(* Reset *)
	IF Reset OR ResetTrig THEN
		Reset     := 0;
		ResetTrig := 0;
		FOR Cnt := 0 TO 9 DO
			JamQeue[Cnt] := 0;
		END_FOR;
	END_IF;
	
	(* Check Qeue *)
	Status       := 0;
	StatusString := 'Buffer Empty';
	StatusCnt    := 0;
	FOR Cnt := 0 TO 9 DO
		IF JamQeue[Cnt] > 0 THEN
			StatusCnt := StatusCnt + 1;
		END_IF;
	END_FOR;
	
	IF StatusCnt > 0 THEN
		IF StatusCnt = 10 THEN
			Status := 2;
			StatusString := 'Buffer Full';
		ELSE
			Status := 1;
			StatusString := 'Buffer In Use';
		END_IF;
	END_IF;
	
	(* Put Element in Qeue *)
	IF Start AND ( Status <> 2 ) THEN
		Cnt   := 10;
		REPEAT
			Cnt := Cnt - 1;
			UNTIL ( JamQeue[Cnt] = 0 ) OR ( Cnt = 0 )
		END_REPEAT;
		JamQeue[Cnt] := Counter + JamTimeOut;
	END_IF;
	Start := 0;
	
	(* Remove Element from Qeue *)
	IF Stop AND ( Status > 0 ) THEN
		TimeOutCheck := Counter + JamTimeOut - JamQeue[9] ;
		FOR Cnt := 0 TO 9 DO
			IF ( Counter > ( JamQeue[Cnt] - JamTolerence)) AND ( Counter < ( JamQeue[Cnt] + JamTolerence)) THEN
				JamQeue[Cnt] := 0;
				ResetTrig    := ResetJam;
				ResetJam     := 0;
			END_IF;
		END_FOR;
	END_IF;
	Stop := 0;
	
	(* Check Jam *)
	Jam    := 0;
	JamCnt := 0;
	FOR Cnt := 0 TO 9 DO
		IF ( Counter > ( JamQeue[Cnt] + JamTolerence )) AND ( JamQeue[Cnt] <> 0 ) THEN
			JamCnt := JamCnt + 1;
			IF JamCnt >= Enable THEN
				Jam := 1;
			END_IF;
			(* Reset 'check for jam' timeout *)
			IF Counter > ( JamQeue[Cnt] + ResetTimeOut ) THEN
				JamQeue[Cnt] := 0;
			END_IF;
		END_IF;
	END_FOR;
	
END_FUNCTION_BLOCK