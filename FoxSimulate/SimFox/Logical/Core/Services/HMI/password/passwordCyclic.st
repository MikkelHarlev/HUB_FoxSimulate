PROGRAM _CYCLIC
(* Copy default values *)
	IF SystemCopied = 0 AND g_Core.Services.System.Runtime.isSystemFileValid THEN
		(*	Convert Password Numbers to strings	*)
		locPassword.Code := g_Core.Services.System.Runtime.file.Password[0];
		DeCode_0(PassWordAdr:=ADR(locPassword));
		Password.PasswordList[0] := locPassword.String;
		locPassword.Code := g_Core.Services.System.Runtime.file.Password[1];
		DeCode_0(PassWordAdr:=ADR(locPassword));
		Password.PasswordList[1] := locPassword.String;
		locPassword.Code := g_Core.Services.System.Runtime.file.Password[2];
		DeCode_0(PassWordAdr:=ADR(locPassword));
		Password.PasswordList[2] := locPassword.String;
		(*	End convert Passord Numbers to strings	*)
		Password.ChangePassword:= Password.PasswordList;
		SystemCopied:= 1;
		
		(* 3 times wrong password entered *)
		Password.PasswordCodeOut:= g_Core.Services.System.Runtime.file.Password[1];
	END_IF

	IF g_Core.System.Runtime.isInitDone THEN
	(* Hide / show password edit *)
		FOR i := 0 TO 2 DO
			Password.StatusPasswordEdit[i]:= (g_Core.Services.HMIHandler.Runtime.Handler[0].PasswordLevel < i);
		END_FOR
	
		RunPwChange := FALSE;
		FOR i := 0 TO (g_Core.Services.HMIHandler.Runtime.HandlersRunning -1) DO
			IF g_Core.Services.HMIHandler.Runtime.Handler[i].PageControllerID = PagePasswordChanged THEN
				RunPwChange := TRUE;
					END_IF
		END_FOR
	
		IF RunPwChange THEN
			(* Check for changed passwords *)
			IF Password.PasswordChanged <> 0 THEN
				Password.InvalidPWTextStatus:= 1;
				(* Check, if Password already exists *)
			FOR i:= 0 TO 2 DO
				IF Password.ChangePassword[Password.PasswordChanged-1] = Password.PasswordList[i] THEN
					Password.ChangePassword[Password.PasswordChanged-1]:= Password.PasswordList[Password.PasswordChanged-1];
						Password.PasswordChanged:= 0;
						Password.InvalidPWTextStatus:= 0;
						EXIT;
					END_IF
				END_FOR
						(* If password does not already exist - accept it and save in file *)
				IF Password.InvalidPWTextStatus = 1 THEN
					Password.PasswordList[Password.PasswordChanged-1]:= Password.ChangePassword[Password.PasswordChanged-1];
							(*	Convert strings	to coded passwords	*)
					locPassword.String := Password.PasswordList[0];
					EnCode_0(PassWordAdr:=ADR(locPassword));
					//TODO BAD!!!
					g_Core.Services.System.Runtime.file.Password[0] := locPassword.Code;
					locPassword.String := Password.PasswordList[1];
					EnCode_0(PassWordAdr:=ADR(locPassword));
					g_Core.Services.System.Runtime.file.Password[1] := locPassword.Code;
					locPassword.String := Password.PasswordList[2];
					EnCode_0(PassWordAdr:=ADR(locPassword));
					g_Core.Services.System.Runtime.file.Password[2] := locPassword.Code;
					(*	End convert strings to coded passwords	*)
					g_Core.Services.System.Interface.isCmdSave := 1;
					Password.PasswordChanged:= 0;
						(* Update password in HMI *)
				FOR i := 0 TO (g_Core.Services.HMIHandler.Runtime.HandlersRunning -1) DO
					g_Core.Services.HMIHandler.Runtime.Handler[i].InitPassword := 1;
				END_FOR
			END_IF
				END_IF
			END_IF
	END_IF
END_PROGRAM

