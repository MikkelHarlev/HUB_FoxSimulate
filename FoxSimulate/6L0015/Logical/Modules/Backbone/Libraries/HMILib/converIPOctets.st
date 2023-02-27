
(* Merges IP octets to string *)
FUNCTION convertIPoctets
	
	error := FALSE;
	StatusMessage := '';
	
	//Validation
	IF(Octets[0] > 255 OR Octets[1] > 255 OR Octets[2] > 255 OR Octets[3] > 255) THEN
		error := TRUE;
	END_IF
	
	IF(NOT error) THEN
		
		//Octet 1
		tempString := DINT_TO_STRING(Octets[0]);
		IPString := tempString;
		IPString := CONCAT(IPString, '.');
		//Octet 2
		tempString := DINT_TO_STRING(Octets[1]);
		IPString := CONCAT(IPString, tempString);
		IPString := CONCAT(IPString, '.');
		//Octet 3
		tempString := DINT_TO_STRING(Octets[2]);
		IPString := CONCAT(IPString, tempString);
		IPString := CONCAT(IPString, '.');
		//Octet 4
		tempString := DINT_TO_STRING(Octets[3]);
		IPString := CONCAT(IPString, tempString);
	
		convertIPoctets := TRUE;
	ELSE
		convertIPoctets := FALSE;
	END_IF
		
END_FUNCTION
