PROGRAM _CYCLIC
	//	execute cyclic part only if no error occured 
	pThis ACCESS ADR(g_Core.Services.Operator);
	(* Find lowest number of arrays etc... *)
	RNoOfCARPanels 		:= MIN(SIZEOF(OPHandler)/SIZEOF(OPHandler[0]),SIZEOF(g_Core.Services.HMIHandler.Runtime.Handler)/SIZEOF(g_Core.Services.HMIHandler.Runtime.Handler[0]));
	RNoOfCARPanels 		:= MIN(RNoOfCARPanels,g_Core.Services.Blackbox.Configuration.Master.ProductionUnits);
	RMaxNoOfOperators 	:= MIN((SIZEOF(OPFunction[0].OPStatus)/SIZEOF(OPFunction[0].OPStatus[0])),10);
	
	pThis.Runtime.isEnabled 	:= g_Core.System.Runtime.isOperatorEnabled;
	pThis.Runtime.HMIShow 	:= NOT pThis.Runtime.isEnabled;
	
	//********************************************************************
	// Init Handling, only once
	//********************************************************************
	IF EDGEPOS(pThis.Runtime.isEnabled) THEN
		IF g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler <> 0 THEN
			OpInit.Enable 				:= 1;
			OpInit.pDevice 				:= ADR('operator');
			OpInit.pStringArray 		:= ADR(OPHandler[0].Vis.ItemList);
			OpInit.SizeStringArray 		:= SIZEOF(OPHandler[0].Vis.ItemList);
			OpInit.pEntryStruct 		:= ADR(OPHandler[0].Entry);
			OpInit.SizeEntryStruct 		:= SIZEOF(OPHandler[0].Entry);
			OpInit.pListInfoStruct 		:= ADR(OPHandler[0].ListInfo);
			OpInit.SizeListInfoStruct 	:= SIZEOF(OPHandler[0].ListInfo);
			OpInit.ArrayElementTotal 	:= SIZEOF(OPHandler[0].Vis.ItemList) / SIZEOF (OPHandler[0].Vis.ItemList[0]);
			OpInit.ListType 			:= LIST_TYPE_OPERATOR;
			OpInit.SizeMemAlloc 		:= 500000;
			OpInit();
	
			(*	If Init function was successful, copy Ident of library to all other functions *)
			IF (OpInit.Status = 0) THEN
				OPFunction[0].Ident 						:= OpInit.Ident;
				OPHandler[0].Cmd.cmdLoadList 				:= 1;
				RDontNotify 								:= TRUE;
				OPFunction[0].State 						:= OP_CHECK_COMMAND;
				pThis.Runtime.initState 					:= RUNTIME;
			ELSE
				OPHandler[0].ListInfo.Status 				:= OpInit.Status;
				OPHandler[0].ListInfo.ErrStringInfo 		:= OpInit.ErrStringInfo;
				OPHandler[0].ListInfo.ErrStringDetail 		:= OpInit.ErrStringDetail;
				pThis.Runtime.initState 					:= ERROR;
			END_IF
			pThis.Runtime.initState := RUNTIME;
		END_IF
		RETURN;
	END_IF	
	IF pThis.Runtime.initState = INIT AND NOT pThis.Runtime.isEnabled THEN
		pThis.Runtime.initState := RUNTIME;
	END_IF	
	
	// Fill with empty names = # x
	IF EDGENEG(pThis.Runtime.isEnabled) OR EDGEPOS((pThis.Runtime.initState = RUNTIME)) THEN
		FOR x := 0 TO RMaxNoOfOperators-1 DO
			pThis.Runtime.No[x].Name 	:= '# ';
			pThis.Runtime.No[x].Number 	:= 0;
			itoa((x+1), ADR(TmpString));
			strcat(ADR(pThis.Runtime.No[x].Name),ADR(TmpString));
		END_FOR;		
	END_IF
	
	//********************************************************************
	// HMI Input
	//********************************************************************
	FOR i := 0 TO RNoOfCARPanels - 1 DO 
		IF OPHandler[i].Cmd.cmdSelect = 1 THEN
			OPHandler[i].Cmd.cmdSelect 	:= 0;
			RSearchOK[i] 				:= 1;
			CallPageControllerLink(1, g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler); // Goto OpMainPage 
		END_IF
		IF OPHandler[i].Cmd.cmdLogout = 1 THEN
			OPHandler[i].Cmd.cmdLogout 			:= 0;
			OPHandler[i].Entry.OperatorNo 		:= 0; // Logout
			OPHandler[i].Cmd.cmdSearchNumber 	:= 1;
			OPHandler[i].Cmd.cmdSelect 			:= 1;
			RSearchOK[i] 						:= 1;
		END_IF
	END_FOR
	
	FOR i := 0 TO RMaxNoOfOperators - 1 DO 
		// External Input.
		IF (pThis.Interface.operator[i].isLoad AND NOT isLoading) THEN
			pThis.Interface.operator[i].isLoad := FALSE;
			isLoading := TRUE;
			OPHandler[0].Entry.OperatorNo    		 := UDINT_TO_UINT(pThis.Interface.operator[i].ID);
			OPFunction[0].OperatorCompletion := i;
			IF (pThis.Interface.operator[i].ID = 0) THEN
				OPHandler[0].Cmd.cmdLogout := 1;
			ELSE
				OPHandler[0].Cmd.cmdSearchNumber := TRUE;
			END_IF
		END_IF
	
		// Look for result.
		IF (isLoading) THEN
			IF (OPHandler[0].Rdy.rdySearchNumber = 1) THEN
				RSearchOK[0] := 1;
				OPHandler[0].Rdy.rdySearchNumber := FALSE;	
				// Operator found.
				isLoading := FALSE;
			END_IF
		END_IF
	END_FOR
	
	//********************************************************************
	// Output
	//********************************************************************
	FOR i := 0 TO RNoOfCARPanels-1 DO 
		IF RSearchOK[i] THEN
			RSearchOK[i] := 0;
			OPFunction[i].OperatorCompletion 							:= LIMIT(0,OPFunction[i].OperatorCompletion,RMaxNoOfOperators -1);
			pThis.Runtime.No[OPFunction[i].OperatorCompletion].Number 	:= LIMIT(0,OPHandler[i].Entry.OperatorNo,65535);
			pThis.Runtime.No[OPFunction[i].OperatorCompletion].Name 	:= OPHandler[i].Entry.Name;
		
			// Cockpit log
			LogData_0(Type:=OPERATOR, Lane:=1, Info1:=OPFunction[i].OperatorCompletion + 1, Info2:=LIMIT(0,OPHandler[i].Entry.OperatorNo,65535), Info3:=LIMIT(0,OPHandler[i].Entry.OperatorNo,65535) > 0, MessageA:= ADR(OPHandler[i].Entry.Name));
		END_IF	
	END_FOR
	
	//**********************************************************************************************************************************
	// Function handling, 1 for each panel	 				 								    
	//********************************************************************
	//FOR i := 0 TO RNoOfCARPanels-1 DO
	
	FOR i := 0 TO 0 DO
		IF g_Core.Services.HMIHandler.Runtime.Handler[i].pVCHandler <> 0 THEN
			// Update button in HMI	 				 								    
			IF g_Core.Services.HMIHandler.Runtime.Handler[i].SystemInitDone = 1 AND g_Core.System.Runtime.isOperatorEnabled AND NOT OPFunction[i].OperatorEnable  THEN
				IF g_Core.Services.System.Runtime.file.IconsEnabled THEN 
					ButtonId := 101;
				ELSE
					ButtonId:= 43;
				END_IF	
				UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler, 3, 5, ButtonId, 0, 8);
				UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler, 5, 5, ButtonId, 0, 8);
				UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler, 6, 5, ButtonId, 0, 8);
				UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler, 7, 5, ButtonId, 0, 8); 
				OPFunction[i].OperatorEnable := TRUE;
			END_IF
			IF g_Core.Services.HMIHandler.Runtime.Handler[i].SystemInitDone = 1 AND NOT g_Core.System.Runtime.isOperatorEnabled AND OPFunction[i].OperatorEnable  THEN
				UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler, 3, 5, 0, 0, 0);
				UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler, 5, 5, 0, 0, 0);
				UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler, 6, 5, 0, 0, 0);
				OPFunction[i].OperatorEnable := FALSE;
			END_IF
	 
			CASE OPFunction[i].State OF
				// check for command to do *)
				OP_CHECK_COMMAND:
					// load list 
					IF (OPHandler[i].Cmd.cmdLoadList = 1) THEN
						OPHandler[i].Rdy.rdyLoadList 	:= 0;
						OpLoad.Enable 					:= 1;
						OpLoad.Ident 					:= OPFunction[i].Ident;
						OpLoad.pStringArray 			:= ADR(OPHandler[i].Vis.ItemList);
						OpLoad.pEntryStruct 			:= ADR(OPHandler[i].Entry);
						OpLoad.pListInfoStruct 			:= ADR(OPHandler[i].ListInfo);
						OpLoad.pSourceName 				:= ADR('operator.csv');
						OpLoad();
						
						OPFunction[i].State := OP_LOAD;
						
						IF NOT RDontNotify THEN
							Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_OPEN_120, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
						END_IF							
						RDontNotify := FALSE;
	
					// save list
					ELSIF (OPHandler[i].Cmd.cmdSaveList = 1) THEN
						OPHandler[i].Rdy.rdySaveList 	:= 0;
						OpSave.Enable 					:= 1;
						OpSave.Ident 					:= OPFunction[i].Ident;
						OpSave.pDestName 				:= OpLoad.pSourceName;
						
						OpSave();
						OPFunction[i].State 	:= OP_SAVE;
						Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_SAVE_121, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
	
					// scroll list
					ELSIF (OPHandler[i].Cmd.cmdScroll <> 0) THEN
 
						// Scroll 
						IF OPHandler[i].Cmd.cmdScroll > 0 THEN
							IF RCycleCount > OPFunction[i].ReScrollTimeout THEN // Don't scroll each scan
								OPHandler[i].Rdy.rdyScroll 				:= 0;
								OpScroll.Enable 						:= 1;
								OpScroll.Ident 							:= OPFunction[i].Ident;
								OpScroll.pListInfoStruct 				:= OpInit.pListInfoStruct;
								OpScroll.cmdScroll 						:= OPHandler[i].Cmd.cmdScroll;
								OpScroll.pListInfoStruct 				:= ADR(OPHandler[i].ListInfo);
								OpScroll.pStringArray 					:= ADR(OPHandler[i].Vis.ItemList);
								OpScroll.pEntryStruct 					:= ADR(OPHandler[i].Entry);
	
								OpScroll();
								OPFunction[i].State 			:= OP_SCROLL;
								OPFunction[i].ReScrollTimeout 	:= RCycleCount + TaskCycleTime; 
							END_IF
						END_IF
	
					// add item to list
					ELSIF (OPHandler[i].Cmd.cmdAddItem = 1) THEN
						OPHandler[i].Rdy.rdyAddItem 		:= 0;
						OpAdd.cmdAdd 						:= 1;
						OpAdd.optDoSort 					:= OPHandler[i].Option.DoSortAfterAdd;
						OpAdd.Enable 						:= 1;
						OpAdd.Ident 						:= OPFunction[i].Ident;
						
						OpAdd();
						OPHandler[i].Option.DoSortAfterAdd 	:= 0;
						OPFunction[i].State 		:= OP_ADD;
	
					// delete item in list
					ELSIF (OPHandler[i].Cmd.cmdDeleteItem = 1) THEN
						OPHandler[i].Rdy.rdyDeleteItem 	:= 0;
						OpDelete.optDeleteAll 			:= 0;
						OpDelete.Enable 				:= 1;
						OpDelete.Ident 					:= OPFunction[i].Ident;
						
						OpDelete();
						OPFunction[i].State 	:= OP_DELETE;
	
					// delete whole list
					ELSIF (OPHandler[i].Cmd.cmdDeleteList = 1) THEN
						OPHandler[i].Rdy.rdyDeleteList 	:= 0;
						OpDelete.optDeleteAll 			:= 1;
						OpDelete.Enable 				:= 1;
						OpDelete.Ident 					:= OPFunction[i].Ident;
						
						OpDelete();
						OPFunction[i].State 	:= OP_DELETE_LIST;
	
					//	Lock/unlock functions in library 
					ELSIF (OPHandler[i].Cmd.cmdLockList = 1) OR  (OPHandler[i].Cmd.cmdLockList = 2) THEN
						OpLock.Enable 	:= 1;
						OpLock.Ident 	:= OPFunction[i].Ident;
						IF OPHandler[i].Cmd.cmdLockList = 1 THEN
							OPHandler[i].Rdy.rdyLockList 	:= 0;
							OpLock.LockNumber 				:= LIST_LOCK_DEF;
						ELSE
							OPHandler[i].Rdy.rdyUnlockList 	:= 0;
							OpLock.LockNumber 				:= 0;
						END_IF
							
						OpLock();
						OPFunction[i].State := OP_LOCK;
	
					// search operator name in list
					ELSIF (OPHandler[i].Cmd.cmdSearchName = 1) THEN
						OPHandler[i].Rdy.rdySearchName 	:= 0;
						OpSearch.OptionSearch 			:= LIST_SEARCH_NAME;
						OpSearch.Enable 				:= 1;
						OpSearch.pListInfoStruct 		:= ADR(OPHandler[i].ListInfo);
						OpSearch.pStringArray 			:= ADR(OPHandler[i].Vis.ItemList);
						OpSearch.pEntryStruct 			:= ADR(OPHandler[i].Entry);
						OpSearch.Ident 					:= OPFunction[i].Ident;
						
						OpSearch();
						OPFunction[i].State 	:= OP_SEARCH_NAME;
	
					// search operator number in list
					ELSIF (OPHandler[i].Cmd.cmdSearchNumber = 1) THEN
						OPHandler[i].Rdy.rdySearchNumber 	:= 0;
						OpSearch.OptionSearch 				:= LIST_SEARCH_NUMBER_0;
						OpSearch.Enable 					:= 1;
						OpSearch.pListInfoStruct 			:= ADR(OPHandler[i].ListInfo);
						OpSearch.pStringArray 				:= ADR(OPHandler[i].Vis.ItemList);
						OpSearch.pEntryStruct 				:= ADR(OPHandler[i].Entry);
						OpSearch.Ident 						:= OPFunction[i].Ident;
						
						OpSearch();
						OPFunction[i].State 		:= OP_SEARCH_NUMBER;
	
					// edit actual item in list
					ELSIF (OPHandler[i].Cmd.cmdEditItem = 1) THEN
						OPHandler[i].Rdy.rdyEditItem 	:= 0;
						OpEdit.Enable 					:= 1;
						OpEdit.Ident 					:= OPFunction[i].Ident;
						
						OpEdit();
						OPFunction[i].State 	:= OP_EDIT;
					END_IF;
	
				// load customer & article list from file
				OP_LOAD:
					IF (OpLoad.Status = LIST_HAND_BUSY) THEN
						OpLoad.Enable 	:= 1;
						OpLoad.Ident 	:= OPFunction[i].Ident;
						OpLoad();
					ELSE
						OPHandler[i].Cmd.cmdLoadList 	:= 0;
						OPFunction[i].State 	:= OP_CHECK_COMMAND;
						
						IF (OpLoad.Status = 0) THEN
							OPFunction[i].ListLoaded 	:= TRUE;
							// Set all ready
							OPHandler[i].Rdy 					:= RdyTrue;
							OPHandler[i].ListInfo.ErrStringInfo := 'List loaded';
							
							// Do Load on all other panels
							IF i = 0 THEN
								FOR x := 1 TO RNoOfCARPanels-1 DO
									OPHandler[x].Cmd.cmdLoadList 	:= 1;
									OPFunction[x].Ident 	:= OPFunction[0].Ident;
									OPFunction[x].State 	:= OP_CHECK_COMMAND;
								END_FOR
							END_IF
						END_IF;
					END_IF;
	
				// save customer & article list to file
				OP_SAVE:
					IF (OpSave.Status = LIST_HAND_BUSY) THEN
						OpSave.Enable 		:= 1;
						OpSave.Ident 		:= OPFunction[i].Ident;
						OpSave.pDestName	:= OpLoad.pSourceName;
						OpSave();
					ELSE
						OPHandler[i].Cmd.cmdSaveList 	:= 0;
						OPFunction[i].State 	:= OP_CHECK_COMMAND;
						
						IF (OpSave.Status = 0) THEN
							OPHandler[i].Rdy.rdySaveList 		:= 1;
							OPHandler[i].ListInfo.ErrStringInfo := 'List saved';
						END_IF;
					END_IF;
	
				// scroll in customer & article list
				OP_SCROLL:
					IF (OpScroll.Status = LIST_HAND_BUSY) THEN
						OpScroll.Enable := 1;
						OpScroll.Ident 	:= OPFunction[i].Ident;
						OpScroll();
					ELSE
						IF OPHandler[i].Cmd.cmdScroll > 2 THEN
							OPHandler[i].Cmd.cmdScroll := 0;
						END_IF
						
						OPFunction[i].State := OP_CHECK_COMMAND;
						
						IF (OpScroll.Status = 0) THEN
							OPHandler[i].Rdy.rdyScroll 			:= 1;
							OPHandler[i].ListInfo.ErrStringInfo := 'List scrolled';
						END_IF;
					END_IF;
	
				// add item to customer & article list
				OP_ADD:
					IF (OpAdd.Status = LIST_HAND_BUSY) THEN
						OpAdd.Enable 	:= 1;
						OpAdd.Ident 	:= OPFunction[i].Ident;
						OpAdd();
					ELSE
						OPHandler[i].Cmd.cmdAddItem := 0;
						OPFunction[i].State := OP_CHECK_COMMAND;
						
						IF (OpAdd.Status = 0) THEN
							OPHandler[i].Rdy.rdyAddItem 		:= 1;
							OPHandler[i].ListInfo.ErrStringInfo := 'List added';
						END_IF;
					END_IF;
	
				// delete item in list
				OP_DELETE:
					IF (OpDelete.Status = LIST_HAND_BUSY) THEN
						OpDelete.Enable := 1;
						OpDelete.Ident 	:= OPFunction[i].Ident;
						OpDelete();
					ELSE
						OPHandler[i].Cmd.cmdDeleteItem 	:= 0;
						OPFunction[i].State 	:= OP_CHECK_COMMAND;
						
						IF (OpDelete.Status = 0) THEN
							OPHandler[i].Rdy.rdyDeleteItem 		:= 1;
							OPHandler[i].ListInfo.ErrStringInfo := 'Item deleted';
						END_IF;
					END_IF;
	
				// delete whole list
				OP_DELETE_LIST:
					IF (OpDelete.Status = LIST_HAND_BUSY) THEN
						OpDelete.Enable := 1;
						OpDelete.Ident 	:= OPFunction[i].Ident;
						OpDelete();
					ELSE
						OPHandler[i].Cmd.cmdDeleteList 	:= 0;
						OPFunction[i].State 	:= OP_CHECK_COMMAND;
						
						IF (OpDelete.Status = 0) THEN
							OPHandler[i].Rdy.rdyDeleteList 		:= 1;
							OPHandler[i].ListInfo.ErrStringInfo := 'List deleted';
						END_IF;
					END_IF;
	
				//	Lock/unlock functions in library 
				OP_LOCK:
					IF (OpLock.Status = LIST_HAND_BUSY) THEN
						OpLock.Enable 	:= 1;
						OpLock.Ident 	:= OPFunction[i].Ident;
						OpLock();
					ELSE
						OPHandler[i].Cmd.cmdLockList 	:= 0;
						OPFunction[i].State 	:= OP_CHECK_COMMAND;
						
						IF (OpLock.Status = 0) THEN
							IF OpLock.LockNumber = LIST_LOCK_DEF THEN
								OPHandler[i].Rdy.rdyLockList 		:= 1;
								OPHandler[i].ListInfo.ErrStringInfo := 'List locked';
							ELSE
								OPHandler[i].Rdy.rdyUnlockList 		:= 1;
								OPHandler[i].ListInfo.ErrStringInfo := 'List unlocked';
							END_IF
						END_IF
					END_IF
	
				// search operator name in list
				OP_SEARCH_NAME:
					IF (OpSearch.Status = LIST_HAND_BUSY) THEN
						OpSearch.Enable := 1;
						OpSearch.Ident 	:= OPFunction[i].Ident;
						OpSearch();
					ELSE
						OPHandler[i].Cmd.cmdSearchName 	:= 0;
						OPFunction[i].State 	:= OP_CHECK_COMMAND;
						
						IF (OpSearch.Status = 0) THEN
							OPHandler[i].Rdy.rdySearchName 		:= 1;
							OPHandler[i].ListInfo.ErrStringInfo := 'Name search';
						END_IF;
					END_IF;
	
				// search operator number in list
				OP_SEARCH_NUMBER:
					IF (OpSearch.Status = LIST_HAND_BUSY) THEN
						OpSearch.Enable := 1;
						OpSearch.Ident 	:= OPFunction[i].Ident;
						OpSearch();
					ELSE
						IF (OpSearch.Status = 50312) THEN
	 						OPHandler[i].Entry.OperatorNo := 9999;
							OPHandler[i].Entry.Name := 'Not Found';
						END_IF	
						OPHandler[i].Cmd.cmdSearchNumber 		:= 0;
						OPFunction[i].State 			:= OP_CHECK_COMMAND;
						
						IF (OpSearch.Status = 0) THEN
							OPHandler[i].Rdy.rdySearchNumber 	:= 1;
							OPHandler[i].ListInfo.ErrStringInfo := 'Number search';
						ELSE
							isLoading := FALSE;
						END_IF;
					END_IF;
	
				// edit entry of operator list
				OP_EDIT:
					IF (OpEdit.Status = LIST_HAND_BUSY) THEN
						OpEdit.Enable 	:= 1;
						OpEdit.Ident 	:= OPFunction[i].Ident;
						OpEdit();
					ELSE
						OPHandler[i].Cmd.cmdEditItem 	:= 0;
						OPFunction[i].State 	:= OP_CHECK_COMMAND;
						IF (OpEdit.Status = 0) THEN
							OPHandler[i].Rdy.rdyEditItem 		:= 1;
							OPHandler[i].ListInfo.ErrStringInfo := 'Item edited';
						END_IF;
					END_IF;
			END_CASE;
	
			// Timeout for error text
			IF OPFunction[i].State = OP_CHECK_COMMAND THEN
				IF RCycleCount > (OPFunction[i].TextTimeout + 400) THEN 
					OPHandler[i].ListInfo.ErrStringInfo 	:= '';
					OPHandler[i].ListInfo.ErrStringDetail 	:= '';
				END_IF
			ELSE
				OPFunction[i].TextTimeout := RCycleCount; 
			END_IF
		END_IF;
	END_FOR;
	RCycleCount := RCycleCount +1;
	
	// HMI information
	FOR i := 0 TO RNoOfCARPanels-1 DO
		IF (g_Core.Services.HMIHandler.Runtime.Handler[i].PageControllerID = PageOPSelect) OR (g_Core.Services.HMIHandler.Runtime.Handler[i].PageControllerID = PageOPEdit) THEN
			IF g_Core.Services.HMIHandler.Runtime.Handler[i].pVCHandler <> 0 THEN
				 OPFunction[i].Status.BtUpStat 		:= SEL((OPHandler[i].ListInfo.ActEntryInLayer <= 0) ,0,1);
				 OPFunction[i].Status.BtDwStat 		:= SEL((OPHandler[i].ListInfo.ActEntryInLayer +1 >= OPHandler[i].ListInfo.NumberEntryInLayer),0,1);
	 			 OPFunction[i].Status.BtDeleteStat 	:= SEL((OPHandler[i].ListInfo.NextLayerLastLayer=1),0,1);
	 			 OPFunction[i].Status.BtEnterStat 	:= SEL((OPHandler[i].ListInfo.Status<>0),0,1);
				IF i = 0 THEN OPFunction[i].Status.BtLoadSaveStat := 0; ELSE OPFunction[i].Status.BtLoadSaveStat := 1; END_IF // Only Load, Save on main panel
			END_IF
	
			// Error information, Only if detail information
			IF (OPHandler[i].ListInfo.ErrStringDetail > '') THEN	
				g_Core.Services.Alarmhandler.Interface.FileError.Show 		:= TRUE;
				g_Core.Services.Alarmhandler.Interface.FileError.InfoText 	:= OPHandler[i].ListInfo.ErrStringInfo;
				g_Core.Services.Alarmhandler.Interface.FileError.DetailText := OPHandler[i].ListInfo.ErrStringDetail;
			
			// No error information
			ELSE
				g_Core.Services.Alarmhandler.Interface.FileError.Show 		:= FALSE;
				g_Core.Services.Alarmhandler.Interface.FileError.InfoText 	:= '';
				g_Core.Services.Alarmhandler.Interface.FileError.DetailText := '';
			END_IF
		END_IF
	END_FOR
	
	// Graphs calculations

	// NegEdge Started
	EdgeNegISControlPlc := EDGENEG(g_Core.System.Runtime.isStatisticsRunning);
	
	FOR x := 0 TO RMaxNoOfOperators-1 DO
		// Hide All
		 OPFunction[0].OPStatus[x].Hide := 1;
	END_FOR
		
	FOR x := 0 TO (g_Core.Services.Blackbox.Configuration.Master.ProductionUnits -1) DO 
		ActInfo.Count	:= GetData(ServerNo:=1, Type:=12, Lane:=(x+1), Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
		ActInfo.Time	:= GetData(ServerNo:=1, Type:=OPERATOR_LOGGED_TIME, Lane:=(x+1), Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
		ActInfo.Norm 	:= g_Core.Services.CAR.Runtime.No[x].Norm;
	
		IF EdgeNegISControlPlc THEN
			TempInfo[x].Count 			:= TempInfo[x].Count + ActInfo.Count;
			TempInfo[x].Time 			:= TempInfo[x].Time + ActInfo.Time;
			TempInfo[x].CustomerNumber 	:= g_Core.Services.CAR.Runtime.No[x].CustomerNumber;
			TempInfo[x].ArticleNumber 	:= g_Core.Services.CAR.Runtime.No[x].ArticleNumber;
			TempInfo[x].RecipeNumber 	:= g_Core.Services.CAR.Runtime.No[x].RecipeNumber;
		END_IF
	
		// Reset temp values
		IF (g_Core.Services.CAR.Runtime.No[x].CustomerNumber <> TempInfo[x].CustomerNumber) OR (g_Core.Services.CAR.Runtime.No[x].ArticleNumber <> TempInfo[x].ArticleNumber) OR (g_Core.Services.CAR.Runtime.No[x].RecipeNumber <> TempInfo[x].RecipeNumber) THEN 
			TempInfo[x].CustomerNumber	:= g_Core.Services.CAR.Runtime.No[x].CustomerNumber;
			TempInfo[x].ArticleNumber 	:= g_Core.Services.CAR.Runtime.No[x].ArticleNumber;
			TempInfo[x].RecipeNumber 	:= g_Core.Services.CAR.Runtime.No[x].RecipeNumber;
			TempInfo[x].Count 			:= 0;
			TempInfo[x].Time 			:= 0;
		END_IF 
	
		// Show..?
		IF (x < g_Core.Services.Blackbox.Configuration.Master.ProductionUnits) THEN
			IF g_Core.System.Runtime.isOperatorEnabled THEN
				OPFunction[0].OPStatus[x].Hide 		:= FALSE;
			ELSIF (ActInfo.Norm > 0) THEN
				// Add support for combining all counters as one inlet.
				IF (x = 0 AND g_Core.System.Runtime.isCondenseGraphs OR NOT g_Core.System.Runtime.isCondenseGraphs) THEN
					// Show if PU is active...
					OPFunction[0].OPStatus[x].Hide 	:= NOT UDINT_TO_BOOL(GetData(ServerNo := 1, Type:= 29, Lane:= 1+i, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)));
				END_IF
			END_IF
		END_IF
		//OPFunction[0].OPStatus[x].Hide OR NOT pThis.Runtime.isEnabled;	
	END_FOR
	
	// Draw Performance
	FOR i := 0 TO (g_Core.Services.Blackbox.Configuration.Master.ProductionUnits -1) DO
		IF g_Core.System.Runtime.isCondenseGraphs THEN
			x := 0;
		ELSE
			x := i;
		END_IF
		// Clear onscreen performance counter
		OPFunction[0].OPStatus[i].Performance := 0;
		
		// Pull the performance data from the blackbox.
		IF ((ActInfo.Norm > 0) AND ((ActInfo.Count + TempInfo[x].Count) > 2)) THEN
			OPFunction[0].OPStatus[x].Performance := OPFunction[0].OPStatus[x].Performance + (UDINT_TO_REAL(ActInfo.Count + TempInfo[x].Count) / ((UDINT_TO_REAL(ActInfo.Time + TempInfo[x].Time) / 3600) * UINT_TO_REAL(ActInfo.Norm)) * 100);
		END_IF
		
		pThis.Runtime.No[x].Performance := REAL_TO_UINT(OPFunction[0].OPStatus[x].Performance);
	END_FOR;
	
	// Show same in all panels		
	FOR i := 0 TO RNoOfCARPanels-1 DO
		OPFunction[i].OPStatus := OPFunction[0].OPStatus;
	END_FOR;

END_PROGRAM

