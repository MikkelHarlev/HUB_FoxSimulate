PROGRAM _CYCLIC
	
	IF 	(g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <> PageIoTrcEdit AND
		g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <> PageIoTrcView) OR IoListInit_0.Status <> 0 THEN
		RETURN;
	END_IF
	
	(*	generate signal for scroll continues if button pressed longer	*)
	TriggScrollDown.CLK := USINT_TO_BOOL(IoStatus.cmdScrollDown);
	TriggScrollUp.CLK := USINT_TO_BOOL(IoStatus.cmdScrollUp);
	TriggScrollDown();
	TriggScrollUp();
	
	(*	Check for Scrolling Up	*)
	IF (TriggScrollUp.Q = 1) THEN	(*	Button Pressed	*)
		IoListScroll_0.cmdUp := 1;
	ELSIF (TriggScrollUp.CLK = 1) THEN
		TimeCounterUp := TimeCounterUp + TaskCycleTime;
		IF (TimeCounterUp > TimePermanentScroll)  THEN
			IoListScroll_0.cmdUp := 1;
		END_IF;
	ELSE
		TimeCounterUp := 0;
	END_IF;
	
	
	(*	Check for Scrolling Down	*)
	IF (TriggScrollDown.Q = 1) THEN	(*	Button Pressed	*)
		IoListScroll_0.cmdDown := 1;
	ELSIF (TriggScrollDown.CLK = 1) THEN
		TimeCounterDown := TimeCounterDown + TaskCycleTime;
		IF (TimeCounterDown > TimePermanentScroll)  THEN
			IoListScroll_0.cmdDown := 1;
		END_IF;
	ELSE
		TimeCounterDown := 0;
	END_IF;
	
	
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID =	PageIoTrcEdit THEN
		IoListScroll_0.IoType := IO_LIST_D_LIST;(* 4 *)
	
		IoListScroll_0.Enable := 1;
		IF (LastPage <> g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID) THEN
			IoListScroll_0.cmdInit := 1;
		END_IF;
	
		IF EDGENEG(g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 1) THEN // Only if when key is released
			g_Core.Services.IOTrace.Runtime.cmdAdd := 1;
		ELSIF EDGENEG(g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 2) THEN (* Start Front trig *)
			g_Core.Services.IOTrace.Runtime.cmdStart := 1;
		ELSIF EDGENEG(g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 4) THEN (* Reset *)
			g_Core.Services.IOTrace.Runtime.cmdReset := 1;
		END_IF	
		
	ELSIF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID =	PageIoTrcView THEN
		IF LastPage <> g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID THEN 	(* Just entered this page *)
			GraphCurTimeLine := 0;				(* Set time line to 0 *)
		END_IF
	
		IF (g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler <> 0) AND ReDraw THEN
			IF VA_Saccess(1, g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler) = 0 THEN
				(* Draw background box *)
				FromX 	:= GraphTimeOffSet;
				GraphWidth 	:= GraphXWindowSize;
				FromY 	:= GraphCurveOffSet-10;
				GraphHeight	:= g_Core.Services.IOTrace.Runtime.numberOfTraceIO*GraphCurveHeight+SCREEN_SIZE*3+20;
				VA_Rect(1, g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler, FromX, FromY, GraphWidth, GraphHeight,GraphColorBackground,GraphColorBorder);
				(* Draw help lines under each curve *)
				FromX 	:= 	GraphTimeOffSet;
				ToX 	:= FromX + GraphXWindowSize;
				FOR i := 0 TO g_Core.Services.IOTrace.Runtime.numberOfTraceIO-1 DO
					FromY	:= (i*GraphCurveHeight)+GraphCurveOffSet+GraphValueHeight+1;
					Linestatus := VA_Line(1, g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler, FromX, FromY, ToX, FromY, GraphColorGrid);(* 8 help lines below each curve *)
				END_FOR
				(* Draw time grid below *)
				FromX 	:= GraphTimeOffSet;
				ToX 	:= FromX + GraphXWindowSize;
				FromY 	:= GraphCurveOffSet + (g_Core.Services.IOTrace.Runtime.numberOfTraceIO*GraphCurveHeight)+10;
				Linestatus := VA_Line(1, g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler, FromX, FromY, ToX, FromY, 0(* Color *));(* time line *)
	
				FOR i := 0 TO GraphXWindowSize BY 20 DO
					FromX 	:= GraphTimeOffSet + i;
					IF i MOD 100 = 0 THEN(* Every 5:th bar is longer *)
						ToY	:= FromY - 6;
						itoa((i*ZoomFactor)+GraphCurTimeLine, ADR(BarTime));
				 		VA_Textout (1, g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler,6(* FontIndex*),FromX(*X*),FromY+2(*Y*),0(* fg Col *),UINT_TO_USINT(GraphColorBackground)(* Bg col *),BarTime);
					ELSE
						ToY	:= FromY - 3;
					END_IF
					Linestatus := VA_Line(1, g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler, FromX, FromY, FromX, ToY, 0);(* One mark for 200 ms *)
				END_FOR
		 		VA_Textout (1, g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler,6(* FontIndex*),FromX-5(*X*),FromY+2(*Y*),0(* fg Col *),UINT_TO_USINT(GraphColorBackground)(* Bg col *),'ms');
				VA_Srelease(1, g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler);
			END_IF
		END_IF
		IF (g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler <> 0) AND ReDraw AND g_Core.Services.IOTrace.Runtime.Mode = 10 THEN (* only if trace is completed *)
			IF VA_Saccess(1, g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler) = 0 THEN
				GraphStartTime := GraphCurTimeLine;
				GraphStopTime := GraphCurTimeLine+ GraphXWindowSize*ZoomFactor;
				(* start with line 0 *)
				FOR i := 0 TO g_Core.Services.IOTrace.Runtime.numberOfTraceIO-1 DO
					IF g_Core.Services.IOTrace.Runtime.IoData[i].Pointer > 0 THEN (* this  is used *)
						FirstDrawDone := FALSE;
						IF g_Core.Services.IOTrace.Runtime.IoData[i].Index < 1 THEN (* Can not loop negative times *)
							g_Core.Services.IOTrace.Runtime.IoData[i].Index := 1;
						END_IF
						FOR index := 0 TO g_Core.Services.IOTrace.Runtime.IoData[i].Index-1 DO (* Search all records *)
							Found := FALSE;
							(* Get record start time *)
							TimeSinceStart := g_Core.Services.IOTrace.Runtime.IoData[i].StartCycle[index] - g_Core.Services.IOTrace.Runtime.TrigStartCycle;
	
							(* Check if record should be plotted *)
							IF (TimeSinceStart >= GraphStartTime) THEN (* Record might be plotted *)
								IF TimeSinceStart < GraphStopTime THEN (* Start is with in range *)
									Found := TRUE;		(* Value is withing range, plott it! *)
								ELSE
									IF NOT FirstDrawDone THEN (* No data used yet, so use this one *)
										TimeSinceStart := GraphStartTime; (* Set start to window start *)
										Found := TRUE;
									ELSE (* There is already made a curve, skip this value and exit loop *)
										index := g_Core.Services.IOTrace.Runtime.IoData[i].Index;
									END_IF
								END_IF
							ELSIF TimeSinceStart < GraphStartTime THEN  (* Record is from before window start *)
								(* check if next value is also before *)
								IF g_Core.Services.IOTrace.Runtime.IoData[i].StartCycle[index+1] > 0 THEN (* Is there a next record *)
									NextTimeSinceStart := g_Core.Services.IOTrace.Runtime.IoData[i].StartCycle[index+1] - g_Core.Services.IOTrace.Runtime.TrigStartCycle;
									IF NextTimeSinceStart < GraphStartTime THEN  (* This record is also from before, use that instead in next loop *)
										;(*Don't use this record, get next *)
									ELSE (* This is the record just before the window, use it *)
										TimeSinceStart := GraphStartTime; (* Set start to window start *)
										Found := TRUE;
									END_IF
								ELSE (* no next record, use this one *)
									TimeSinceStart := GraphStartTime; (* Set start to window start *)
									Found := TRUE;
								END_IF
							END_IF
	
							IF Found THEN	(* This record is valid and should be plotted *)
								(* Scale values *)
								FromX 	:=	(TimeSinceStart - GraphStartTime)/ZoomFactor;
								IF FromX > GraphXWindowSize THEN
									FromX := GraphXWindowSize;
								END_IF
								IF	g_Core.Services.IOTrace.Runtime.IoData[i].StartCycle[index+1] = 0 THEN (* No next value *)
									TimeDiff :=	g_Core.Services.IOTrace.Runtime.CycleCounter-g_Core.Services.IOTrace.Runtime.IoData[i].StartCycle[index];(* Up to last cycle *)
								ELSIF (g_Core.Services.IOTrace.Runtime.IoData[i].StartCycle[index] - g_Core.Services.IOTrace.Runtime.TrigStartCycle) < GraphStartTime  THEN (* Start before this time window *)
									TimeDiff := g_Core.Services.IOTrace.Runtime.IoData[i].StartCycle[index+1] - GraphStartTime - g_Core.Services.IOTrace.Runtime.TrigStartCycle;
								ELSE
									TimeDiff := g_Core.Services.IOTrace.Runtime.IoData[i].StartCycle[index+1] - g_Core.Services.IOTrace.Runtime.IoData[i].StartCycle[index];
								END_IF
								ToX := FromX + (TimeDiff/ZoomFactor);
								IF ToX > GraphXWindowSize THEN
									ToX := GraphXWindowSize;
								END_IF
								FromX 	:= 	FromX+GraphTimeOffSet;(*Add offset for window position *)
								ToX 	:= 	ToX+GraphTimeOffSet;(*Add offset for window position *)
	
								FromY 	:= (1-g_Core.Services.IOTrace.Runtime.IoData[i].Value[index])*GraphValueHeight;
								FromY 	:= FromY+(i*GraphCurveHeight)+GraphCurveOffSet;
								ToY 	:= (g_Core.Services.IOTrace.Runtime.IoData[i].Value[index])*GraphValueHeight;
								ToY 	:= ToY +(i*GraphCurveHeight)+GraphCurveOffSet;
								Color 	:= GraphColorBase[i];
								IF FirstDrawDone THEN
									Linestatus := VA_Line(1, g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler, FromX, FromY, FromX, ToY, Color);(* Vertical bar *)
								ELSE
									FirstDrawDone := TRUE;(* Only draw vertical bar after first one *)
								END_IF
								Linestatus := VA_Line(1, g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler, FromX, FromY, ToX, FromY, Color);(* Horisontal bar *)
							ELSIF TimeSinceStart > GraphStopTime THEN
								index := g_Core.Services.IOTrace.Runtime.IoData[i].Index; (* No more on this curve, Exit! *)
							END_IF
						END_FOR
					ELSE
						i := g_Core.Services.IOTrace.Runtime.numberOfTraceIO; (* Exit *)
					END_IF
				END_FOR
				VA_Srelease(1, g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler);
				ReDraw := FALSE;
			END_IF
		END_IF
		IF LastMode <> g_Core.Services.IOTrace.Runtime.Mode THEN 	(* Trace mode has changed *)
			IF g_Core.Services.IOTrace.Runtime.Mode = 10 THEN 	(* Just stopped *)
				ReDraw := TRUE;				(* Update the Graph *)
			END_IF
		END_IF
		IF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 1) THEN
			g_Core.Services.IOTrace.Runtime.cmdStart := 1;
		ELSIF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 2) THEN
			g_Core.Services.IOTrace.Runtime.ExternTrig := TRUE;
		ELSIF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 3) THEN
			g_Core.Services.IOTrace.Runtime.cmdStop := TRUE;
		ELSIF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 4) THEN
			ReDraw := TRUE;					(* Update the graph *)
		END_IF
	//	g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed := 0;(* always clear key *)
		IF ZoomFactorcmd > 0 THEN
			IF ZoomFactor = 1 THEN
				ZoomFactor := 10;
			ELSIF ZoomFactor = 2 THEN
				ZoomFactor := 1;
			ELSIF ZoomFactor = 5 THEN
				ZoomFactor := 2;
			ELSE
				ZoomFactor := 5;
			END_IF	
			ReDraw 			:= TRUE;		(* Update the graph *)
			ZoomFactorString[0] := ZoomFactorString[ZoomFactor];
			ZoomFactorcmd 		:= 0;
			GraphCurTimeLine	:= 0;
		END_IF
	END_IF
	LastPage := g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID;
	LastMode := g_Core.Services.IOTrace.Runtime.Mode;
	
	IoListScroll_0();
	IoStatus.SelectedItem:= UINT_TO_USINT(IoListScroll_0.SelectedItem);
	
	(*	Select trig IO *)
	IF g_Core.Services.IOTrace.Runtime.cmdTrig > 0 THEN (* Select new trigger *)
		IF g_Core.Services.IOTrace.Runtime.cmdTrig = 1 THEN (* Select next io as trigger *)
			IF g_Core.Services.IOTrace.Runtime.TrigIndex < UINT_TO_INT(g_Core.Services.IOTrace.Runtime.numberOfTraceIO-1) THEN
				g_Core.Services.IOTrace.Runtime.TrigIndex := g_Core.Services.IOTrace.Runtime.TrigIndex + 1;
			END_IF
		ELSIF g_Core.Services.IOTrace.Runtime.cmdTrig = 2 THEN (* Select previous io as trigger *)
			IF g_Core.Services.IOTrace.Runtime.TrigIndex >= 0 THEN
				g_Core.Services.IOTrace.Runtime.TrigIndex := g_Core.Services.IOTrace.Runtime.TrigIndex - 1;
			END_IF
		END_IF
		(* Show what io is the trigger, if g_Core.Services.IOTrace.Runtime.TrigIndex = -1, this means No_Trigger *)
		FOR i := 0 TO g_Core.Services.IOTrace.Runtime.numberOfTraceIO-1 DO
			IF i = INT_TO_UINT(g_Core.Services.IOTrace.Runtime.TrigIndex) THEN
				strcpy(ADR(TrigList[i]),ADR('<<'));
			ELSE
				strcpy(ADR(TrigList[i]),ADR(' '));
			END_IF
		END_FOR
		g_Core.Services.IOTrace.Runtime.cmdTrig := 0;
	END_IF
	
	IF g_Core.Services.IOTrace.Runtime.cmdAdd > 0 THEN
		FOR i := 0 TO g_Core.Services.IOTrace.Runtime.numberOfTraceIO-1 DO
			IF g_Core.Services.IOTrace.Runtime.IoData[i].Pointer = 0 THEN (* this  is not used yet *)
				IF i = 0 THEN
					g_Core.Services.IOTrace.Runtime.TrigIndex := 0;
					g_Core.Services.IOTrace.Runtime.cmdTrig := 9; (* just to refresh screen *)
				END_IF
				strcpy(ADR(g_Core.Services.IOTrace.Runtime.IoData[i].Name),ADR(IoStatus.IoInfoStruct.ActIoName));
				g_Core.Services.IOTrace.Runtime.IoData[i].Pointer := IoStatus.IoInfoStruct.ActIoAdr;
				g_Core.Services.IOTrace.Runtime.IoData[i].TType  := 1;(* BOOL only so far *)
				i := g_Core.Services.IOTrace.Runtime.numberOfTraceIO; (* Exit *)
			END_IF
		END_FOR
		g_Core.Services.IOTrace.Runtime.cmdAdd := 0;
	END_IF
	
	IF g_Core.Services.IOTrace.Runtime.cmdStart > 0 THEN
		FOR i := 0 TO g_Core.Services.IOTrace.Runtime.numberOfTraceIO-1 DO
			IF g_Core.Services.IOTrace.Runtime.IoData[0].Pointer > 0 THEN
				g_Core.Services.IOTrace.Runtime.IoData[0].OldValue := -1;			(* To force recording also first cycle *)
				FOR index := 0 TO MAXTRACELOGITEMS DO
					g_Core.Services.IOTrace.Runtime.IoData[i].Value[index] := 0;
					g_Core.Services.IOTrace.Runtime.IoData[i].StartCycle[index] := 0;
				END_FOR
			END_IF
			g_Core.Services.IOTrace.Runtime.IoData[i].Index := 0;
		END_FOR
		IF g_Core.Services.IOTrace.Runtime.cmdStart = 1 THEN
			g_Core.Services.IOTrace.Runtime.Mode := 1; 		(* Start record and wait for trig start *)
		ELSIF g_Core.Services.IOTrace.Runtime.cmdStart = 2 THEN
			g_Core.Services.IOTrace.Runtime.Mode := 5; 		(* Start record and wait for trig stop	 *)
		END_IF
		g_Core.Services.IOTrace.Runtime.CycleCounter 		:= 0;
		g_Core.Services.IOTrace.Runtime.TrigStartCycle 	:= 0;
		g_Core.Services.IOTrace.Runtime.TrigStopCycle 	:= MAXTRACECYCLES;
		g_Core.Services.IOTrace.Runtime.TrigStart 		:= FALSE;
		g_Core.Services.IOTrace.Runtime.RecordEnable 		:= FALSE;
		g_Core.Services.IOTrace.Runtime.ExternTrig 		:= FALSE;
		g_Core.Services.IOTrace.Runtime.TrigStartCycle	:= 0;(* Default to be able to see data even if trig is not found *)
		g_Core.Services.IOTrace.Runtime.cmdStart 			:= 0;
		g_Core.Services.IOTrace.Runtime.cmdStop 			:= 0;
		IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageIoTrcEdit THEN
			PageSwapDelay := 6;
		END_IF		
	END_IF
	
	IF g_Core.Services.IOTrace.Runtime.cmdReset > 0 THEN
		g_Core.Services.IOTrace.Runtime.CycleCounter := 0;
		g_Core.Services.IOTrace.Runtime.Mode := 0;
		FOR i := 0 TO g_Core.Services.IOTrace.Runtime.numberOfTraceIO-1 DO
			g_Core.Services.IOTrace.Runtime.IoData[i].Pointer := 0;
			g_Core.Services.IOTrace.Runtime.IoData[i].Name := '';
			g_Core.Services.IOTrace.Runtime.IoData[i].TType := 0;
			strcpy(ADR(TrigList[i]),ADR(' '));
		END_FOR
		g_Core.Services.IOTrace.Runtime.cmdReset := 0;
	END_IF
	
	IF GraphAddTimeLine	> 0 THEN
		GraphAddTimeLine := 0;
		IF 	GraphCurTimeLine < (g_Core.Services.IOTrace.Runtime.CycleCounter-GraphXWindowSize-100) THEN
			GraphCurTimeLine := GraphCurTimeLine + 100*ZoomFactor;
			ReDraw := TRUE;
		END_IF
	END_IF
	IF GraphSubTimeLine	> 0 THEN
		GraphSubTimeLine	:= 0;
		IF 	GraphCurTimeLine > 99 THEN
			GraphCurTimeLine := GraphCurTimeLine - 100*ZoomFactor;
			ReDraw := TRUE;
		END_IF
	END_IF
	IF g_Core.Services.IOTrace.Runtime.CycleCounter > 0 THEN
		GraphCurTimeLineBar := REAL_TO_UINT(((UINT_TO_INT(GraphCurTimeLine)*1.0)/UINT_TO_INT(g_Core.Services.IOTrace.Runtime.CycleCounter-GraphXWindowSize-g_Core.Services.IOTrace.Runtime.TrigStartCycle-1))*100);
	ELSE
		GraphCurTimeLineBar := 0;
	END_IF
	
	CASE g_Core.Services.IOTrace.Runtime.Mode OF
		0:	ModeString := 'Idle';
		1:	ModeString := 'Wait for trig';
		2:	ModeString := 'Recording';
		5:	ModeString := 'Wait for EndTrig';
		6:	ModeString := 'Stoping';
		10:	ModeString := 'Done';
		ELSE
			ModeString := 'Not used';
	END_CASE
	
	
	IF PageSwapDelay > 0 THEN
		PageSwapDelay := PageSwapDelay -1;
		IF PageSwapDelay = 0 THEN
			CallPageControllerLink(PageIoTrcView, g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
		END_IF
	END_IF

END_PROGRAM

