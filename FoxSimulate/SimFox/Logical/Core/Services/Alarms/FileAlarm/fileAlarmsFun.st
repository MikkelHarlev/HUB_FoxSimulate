(* Removed Filelayer for HMI task *)
FUNCTION RunFileErrorLayer
	IF AdrFileErrorLayer > 0 THEN
		pFileErrorLayer ACCESS AdrFileErrorLayer;
		CASE pFileErrorLayer.State OF
			(* Idle *)
			0:
				IF	(pFileErrorLayer.Show) THEN
					IF (pFileErrorLayer.InfoText <> pFileErrorLayer.OldInfoText OR pFileErrorLayer.DetailText <> pFileErrorLayer.OldDetailText OR pFileErrorLayer.ReCheckError) THEN
						pFileErrorLayer.ReCheckError 	:= FALSE;
						pFileErrorLayer.State 			:= 5;
						pFileErrorLayer.Delay			:= 5;
					END_IF
				END_IF

			(* Delay to check status of text strings *)
			5:
				IF (pFileErrorLayer.Delay > 0) THEN
					pFileErrorLayer.Delay := pFileErrorLayer.Delay - 1;
				END_IF
				IF (pFileErrorLayer.Delay = 0) THEN
					pFileErrorLayer.State			:= 10;
				END_IF

			(*Check that text are still valid...  *)
			10:
				IF (pFileErrorLayer.InfoText > '' OR pFileErrorLayer.DetailText > '') THEN
					pFileErrorLayer.ShowLayer 	:= 0;				(* Show layer *)
					pFileErrorLayer.State		:= 15;
				ELSE
					pFileErrorLayer.ShowLayer 	:= 1;				(* Hide layer *)
					pFileErrorLayer.State		:= 0;
				END_IF

			(* Wait acknowledge *)
			15:
				IF (pFileErrorLayer.Acknowledge) THEN
					pFileErrorLayer.Acknowledge := FALSE;
					pFileErrorLayer.ShowLayer 	:= 1;				(* Hide layer *)
					pFileErrorLayer.State		:= 0;
				END_IF
		END_CASE

		pFileErrorLayer.OldInfoText 	:= pFileErrorLayer.InfoText;
		pFileErrorLayer.OldDetailText 	:= pFileErrorLayer.DetailText;

		IF (NOT pFileErrorLayer.Show) THEN
			pFileErrorLayer.ShowLayer 	:= 1;				(* Hide layer *)
			pFileErrorLayer.State		:= 0;
		END_IF
		RunFileErrorLayer := 0;
	ELSE
		RunFileErrorLayer := 1;
 	END_IF		
END_FUNCTION