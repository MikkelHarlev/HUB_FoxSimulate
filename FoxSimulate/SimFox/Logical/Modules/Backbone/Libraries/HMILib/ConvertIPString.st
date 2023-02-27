
(* Splits IP string to four IP octets *)
FUNCTION convertIPString
	
	strLength 																	:= strlen(ADR(IPString));
	octetTemp[0] 																:= 0;
	status 																		:= TRUE;
	StatusMessage 																:= '';
	Octets[0] 																	:= 0; 
	Octets[1] 																	:= 0; 
	Octets[2] 																	:= 0; 
	Octets[3] 																	:= 0;
	
	IF (strLength > 6 AND strLength < 16) THEN
	
		// Run through the ip string and check it has the correct format.
		FOR i:=0 TO strLength-1 DO
			currentCharAscii 													:= brdkStrCharAt(ADR(IPString),i,ADR(currentChar));
			IF (octetCount < 4) THEN // We must encounter period within of series of 4 characters or less
				IF (currentCharAscii = 46) THEN // '.' We have an octet
					brdkStrCpy(ADR(octetsStr[r]),ADR(octetTemp));
					r 															:= r + 1; 
					octetTemp[0] 												:= 0;
					octetCount 													:= 255; // +1 later in loop will make it 0 when next char is found
				ELSE
					IF (currentCharAscii > 57 OR currentCharAscii < 48) THEN // An octet must only consists of numbers
						status 													:= FALSE; 
						brdkStrCpy(ADR(StatusMessage),ADR('Char with value '));
						brdkStrDintToA(currentCharAscii,ADR(OctetIdxStr),0);
						brdkStrCat(ADR(StatusMessage),ADR(OctetIdxStr));
						brdkStrCat(ADR(StatusMessage),ADR('found in string'));
						EXIT;
					ELSE
						octetTemp[octetCount]									:= currentCharAscii;
						octetTemp[octetCount+1]									:= 0;// Mke sure sring always ends with a NULL
						IF( i=strLength-1) THEN // If its the last element empty the buffer
							brdkStrCpy(ADR(octetsStr[r]),ADR(octetTemp));
						END_IF
					END_IF
				END_IF
				octetCount 														:= octetCount + 1;
			ELSE
				//The octet have to many characters
				status 															:= FALSE; 
				StatusMessage 													:= 'To many Elements in octet nr:';
				OctetIdxStr 													:= USINT_TO_STRING(r);
				brdkStrCat(ADR(StatusMessage),ADR(OctetIdxStr));
				EXIT;
			END_IF
			IF r=4 THEN // only 4 octets allowed 
				StatusMessage 													:= 'Too many Punktuations'; 
				status 															:= FALSE;
				convertIPString 												:= FALSE;
				EXIT;
			END_IF
		END_FOR
		
		IF (status = TRUE) THEN
			convertIPString 													:= TRUE;
			Octets[0] 															:= atoi(ADR(octetsStr[0])); 
			Octets[1] 															:= atoi(ADR(octetsStr[1])); 
			Octets[2] 															:= atoi(ADR(octetsStr[2])); 
			Octets[3] 															:= atoi(ADR(octetsStr[3]));
		ELSE
			convertIPString 													:= FALSE;
			Octets[0] 															:= 0; 
			Octets[1] 															:= 0; 
			Octets[2] 															:= 0; 
			Octets[3] 															:= 0;
		END_IF
	
	ELSE
		StatusMessage 															:= 'Bad Ip String to Long og to Short'; 
		convertIPString 														:= FALSE;
	END_IF
	
END_FUNCTION
