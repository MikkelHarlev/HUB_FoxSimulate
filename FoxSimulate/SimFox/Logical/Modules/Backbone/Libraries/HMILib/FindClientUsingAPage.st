
(* TODO: Add your comment here *)
FUNCTION FindClientUsingAPage

	// Check default Client first
	FindClientUsingAPage 										:= 0;// If no Client found using this page, use o as default
 	
	IF (lastClientIndex < 0) THEN
		lastClientIndex := 0;
	END_IF
	IF brdkStrCmp(clientListAdr+(INT_TO_UINT(lastClientIndex)*clientStructSize),ADR(pageName1)) = 0 THEN
		FindClientUsingAPage := lastClientIndex;	// still last client that uses this page
		RETURN;
	ELSIF (pageName2 <> '') AND (brdkStrCmp(clientListAdr+(INT_TO_UINT(lastClientIndex)*clientStructSize),ADR(pageName2)) = 0) THEN
		FindClientUsingAPage := lastClientIndex;	// still last client that uses this page
		RETURN;
	ELSE
		FOR i := 0 TO highestClientSlot DO
		 	IF brdkStrCmp(clientListAdr+(INT_TO_UINT(i)*clientStructSize),ADR(pageName1)) = 0 THEN
				FindClientUsingAPage := i;
				EXIT;
		 	ELSIF brdkStrCmp(clientListAdr+(INT_TO_UINT(i)*clientStructSize),ADR(pageName2)) = 0 THEN
				FindClientUsingAPage := i;
				EXIT;
			END_IF
		END_FOR
	END_IF	

END_FUNCTION
