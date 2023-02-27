PROGRAM _CYCLIC
	(* Set Alarm Message For Acopos, On HMI *)
	CASE taskState OF
		INIT:	
			IF (g_Core.System.Runtime.isInitDone) THEN
				IF g_Core.Services.System.Runtime.file.IconsEnabled THEN 
					ButtonId := 138;
				ELSE
					ButtonId:= 39;
				END_IF	
				
				IF (g_Core.System.Configuration.adrAxisVarName > 0) THEN
					GetAdr(ADR(adrAxis), g_Core.System.Configuration.adrAxisVarName);
					// We most likely got the pointers :)
					IF (adrAxis > 0) THEN
						pAxis ACCESS adrAxis;
						UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, 20, 3, ButtonId, 2, 25);
						// Set task state to runtime!
						taskState := RUNTIME; 
					END_IF
				END_IF	
			END_IF
			
		RUNTIME:

			AcpAlarmCheck.Vc.Trigger[0] := g_Core.Services.AcoposAlarm.Runtime.Error; 

			(* Check For Acopos Error, Only If CurrentPage = Page_Alarm_Acp_Error Or New Error *)
			IF EDGEPOS (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = 25) OR
				((EDGEPOS (g_Core.Services.AcoposAlarm.Runtime.Error) OR EDGENEG (g_Core.Services.AcoposAlarm.Runtime.Error)) AND g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = 25) THEN
				(* If Error, Goto The First Axis Whit Error *)
				IF g_Core.Services.AcoposAlarm.Runtime.Error THEN
					FOR Cnt := g_Core.Services.AcoposAlarm.Runtime.FirstDrive TO g_Core.Services.AcoposAlarm.Runtime.LastDrive DO
						IF (NOT pAxis[Cnt].ready OR pAxis[Cnt].state >= AX_ERROR) AND (pAxis[Cnt].axisRef > 0) THEN
							i := Cnt;
							EXIT;
						END_IF
					END_FOR
					AcpAlarm.NodeNumber := StartNode + UINT_TO_USINT (i);
				ELSE
					AcpAlarm.NodeNumber := StartNode;
				END_IF

				(* Clear Listbox *)
				FOR Cnt := g_Core.Services.AcoposAlarm.Runtime.FirstDrive TO g_Core.Services.AcoposAlarm.Runtime.LastDrive DO
                    IF (pAxis[Cnt].axisRef > 0) THEN
					    strcpy(ADR(AcpAlarm.AcpArray[Cnt]),ADR(''));
                    END_IF
				END_FOR

				(* Set Axis Whit Error In Listbox *)
				i := 0;
				FOR Cnt := g_Core.Services.AcoposAlarm.Runtime.FirstDrive TO g_Core.Services.AcoposAlarm.Runtime.LastDrive DO
					IF (NOT pAxis[Cnt].ready OR pAxis[Cnt].state >= AX_ERROR) AND (pAxis[Cnt].axisRef > 0) THEN
						strcpy(ADR(AcpAlarm.AcpArray[i]),ADR(NodeText[Cnt]));
						i := i + 1;
					END_IF
				END_FOR
				AcpAlarm.SelectedItem := 0;
				Info := 0;
			END_IF
    
			(*--------------------------------------------------------------------------------------------------------------------*)
			(* Info To Vis *)
			(*--------------------------------------------------------------------------------------------------------------------*)

			IF AcpAlarm.NodeNumber >= StartNode THEN
				AcpAlarm.status     := pAxis[AcpAlarm.NodeNumber - StartNode].errorList[Info].status;
				AcpAlarm.errorID    := pAxis[AcpAlarm.NodeNumber - StartNode].errorList[Info].errorID;
				AcpAlarm.errorInfo  := pAxis[AcpAlarm.NodeNumber - StartNode].errorList[Info].errorInfo;
				AcpAlarm.line1      := pAxis[AcpAlarm.NodeNumber - StartNode].errorList[Info].line1;
				AcpAlarm.line2      := pAxis[AcpAlarm.NodeNumber - StartNode].errorList[Info].line2;
			END_IF
			
			(*--------------------------------------------------------------------------------------------------------------------*)
			(* Change Acopos Error Number *)
			(*--------------------------------------------------------------------------------------------------------------------*)

			(* Goto Next Error *)
			IF AcpAlarm.cmdNextError = 1 THEN
				AcpAlarm.cmdNextError := 0;
				IF Info < 4 THEN
					Info := Info + 1;
				END_IF
			END_IF

			(* Goto Previus Error *)
			IF AcpAlarm.cmdPrevError = 1 THEN
				AcpAlarm.cmdPrevError := 0;
				IF Info > 0 THEN
					Info := Info - 1;
				END_IF
			END_IF

			(*--------------------------------------------------------------------------------------------------------------------*)
			(* Change Acopos Node Number *)
			(*--------------------------------------------------------------------------------------------------------------------*)

			(* Goto Next Nodenumber *)
			IF AcpAlarm.cmdNextAcp = 1 THEN
				AcpAlarm.cmdNextAcp := 0;
				IF AcpAlarm.NodeNumber < (StartNode + g_Core.Services.AcoposAlarm.Runtime.LastDrive) THEN
					Info := 0;
					AcpAlarm.NodeNumber := AcpAlarm.NodeNumber + 1;
				END_IF
			END_IF

			(* Goto Previus Nodenumber *)
			IF AcpAlarm.cmdPrevAcp = 1 THEN
				AcpAlarm.cmdPrevAcp := 0;
				IF AcpAlarm.NodeNumber > StartNode THEN
					Info := 0;
					AcpAlarm.NodeNumber := AcpAlarm.NodeNumber - 1;
				END_IF
			END_IF

			(*--------------------------------------------------------------------------------------------------------------------*)
			(* Scroll In Acopos Error Node *)
			(*--------------------------------------------------------------------------------------------------------------------*)

			(* Scroll Up *)
			IF AcpAlarm.cmdScrollUp = 1 THEN
				AcpAlarm.cmdScrollUp := 0;
				IF AcpAlarm.SelectedItem > g_Core.Services.AcoposAlarm.Runtime.FirstDrive THEN
					AcpAlarm.SelectedItem := AcpAlarm.SelectedItem - 1;
				END_IF
			END_IF

			(* Scroll Down *)
			IF AcpAlarm.cmdScrollDown = 1 THEN
				AcpAlarm.cmdScrollDown := 0;
				IF AcpAlarm.SelectedItem < g_Core.Services.AcoposAlarm.Runtime.LastDrive THEN
					AcpAlarm.SelectedItem := AcpAlarm.SelectedItem + 1;
				END_IF
			END_IF
	END_CASE
END_PROGRAM

