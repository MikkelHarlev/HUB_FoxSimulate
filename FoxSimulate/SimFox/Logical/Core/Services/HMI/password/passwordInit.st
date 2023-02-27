PROGRAM _INIT
	(* Copy default values *)
	IF g_Core.Services.System.Runtime.isSystemFileValid THEN
		(*	End convert Passord Numbers to strings	*)
		Password.ChangePassword:= Password.PasswordList;
		SystemCopied:= 1;
	END_IF
	
	(* Hide 'Wrong Password' and 'Invalid Password' Texts *)
	Password.WrongPWTextStatus:= 1;
	Password.InvalidPWTextStatus:= 1;
	PagePasswordChanged 	:= LookupPageID(PAGE_SYS_PASSWORD_CHANGE, g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
END_PROGRAM

