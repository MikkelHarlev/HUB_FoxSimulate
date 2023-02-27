(* Gets namespace and Key from message *)
FUNCTION_BLOCK getNamespaceKey
	isStartFound											:= FALSE;
	isStartBraceFound										:= FALSE;
	isStartDollarSignFound									:= FALSE;
	isNameSpaceFound										:= FALSE;
	isKeyFound												:= FALSE;
	memset(ADR(strNamespace),0,SIZEOF(strNamespace));
	memset(ADR(strKey),0,SIZEOF(strKey));
	
	FOR charNo := 0 TO strlen(adrMessageString) DO
		pChar ACCESS adrMessageString + charNo;
		
		IF isStartFound THEN
			IF isNameSpaceFound THEN
				IF pChar = 125 THEN
					isKeyFound								:= TRUE;
					EXIT;
				ELSE
					memset(ADR(strChar),0,SIZEOF(strChar));
					memcpy(ADR(strChar),adrMessageString + charNo, 1);
					strcat(ADR(strKey),ADR(strChar));
				END_IF
			ELSE
				IF pChar = 47 THEN
					isNameSpaceFound						:= TRUE;
				ELSE
					memset(ADR(strChar),0,SIZEOF(strChar));
					memcpy(ADR(strChar),adrMessageString + charNo, 1);
					strcat(ADR(strNamespace),ADR(strChar));
				END_IF
			END_IF
		ELSE
			IF pChar = 123 THEN
				isStartBraceFound							:= TRUE;
			ELSIF pChar = 36 THEN
				isStartDollarSignFound						:= TRUE;
			END_IF
			
			IF isStartBraceFound AND isStartDollarSignFound THEN
				isStartFound								:= TRUE;
			END_IF
		END_IF
	END_FOR
	
	IF isStartFound AND isStartBraceFound AND isStartDollarSignFound AND isNameSpaceFound AND isKeyFound THEN
		isFound												:= TRUE;
	ELSE
		isFound												:= FALSE;
	END_IF

END_FUNCTION_BLOCK