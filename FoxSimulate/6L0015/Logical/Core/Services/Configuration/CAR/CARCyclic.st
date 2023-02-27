PROGRAM _CYCLIC
	IF NOT (g_Core.Services.HMIHandler.Runtime.Handler[0].SystemInitDone AND (g_Core.Services.Machine.Runtime.initState = RUNTIME AND (g_Core.System.Configuration.isRemotePanelModeEnabled = g_Core.System.Runtime.isRemoteReady)) )THEN
		RETURN;
	END_IF 
	
	(* Find lowest number of arrays etc... *)
	RNoOfCARPanels := MIN(SIZEOF(CARHandler)/SIZEOF(CARHandler[0]),SIZEOF(g_Core.Services.HMIHandler.Runtime.Handler)/SIZEOF(g_Core.Services.HMIHandler.Runtime.Handler[0]));
	RNoOfCARPanels := MIN(1,g_Core.Services.Blackbox.Configuration.Master.ProductionUnits);
	IF (isRemote) THEN
		RNoOfCARPanels := 2;
	END_IF
	IF (g_Core.Services.Blackbox.Configuration.Master.MultiRcp) THEN
		RNoOfCARPanels := g_Core.Services.Blackbox.Configuration.Master.ProductionUnits;
	END_IF
	
	g_Core.Services.CAR.Runtime.isEnabled	 := g_Core.System.Runtime.isCustomerEnabled;
	
	IF RInitDone THEN
		g_Core.Services.CAR.Runtime.HMIShow	 := NOT g_Core.Services.CAR.Runtime.isEnabled;
	END_IF
	//********************************************************************
	// Init Handling, only once
	//********************************************************************
	IF RInitDone = FALSE AND g_Core.Services.CAR.Runtime.isEnabled THEN

		IF (CustInit.Status = 0) THEN
			CARFunction[0].Ident := CustInit.Ident;
			CARFunction[0].State := CUST_CHECK_COMMAND;
			CARHandler[0].Cmd.cmdLoadList := 1;
			RDontNotify := TRUE;
			g_Core.Services.CAR.Runtime.initState := RUNTIME;
			RestorePermCAR := TRUE;
			RInitDone := TRUE;
		ELSE 
			CARHandler[0].ListInfo.Status := CustInit.Status;
			CARHandler[0].ListInfo.ErrStringInfo := CustInit.ErrStringInfo;
			CARHandler[0].ListInfo.ErrStringDetail := CustInit.ErrStringDetail;
			g_Core.Services.CAR.Runtime.initState := ERROR;
			RInitDone := TRUE;
		END_IF
		RETURN;
	END_IF	
	IF RInitDone = FALSE AND NOT g_Core.Services.CAR.Runtime.isEnabled THEN
		RestorePermCAR := NOT RestorePermCARDone;
		g_Core.Services.CAR.Runtime.HMIShow		:= TRUE;
		g_Core.Services.CAR.Runtime.initState 	:= RUNTIME;
	END_IF	
	
	// External Load Command support for Remote.
	IF (g_Core.Services.CAR.Interface.isCmdLoad) THEN
		CARHandler[0].Cmd.cmdLoadList 			:= TRUE;
		g_Core.Services.CAR.Interface.isCmdLoad := FALSE;
	END_IF
	
	//********************************************************************
	// Store/restore CAR to/from permanent 
	//********************************************************************
	FOR i := 0 TO RNoOfCARPanels-1 DO 
		IF updatePermCAR[i] THEN
			updatePermCAR[i] := FALSE; 
			PermCAR[i].CustomerNumber := g_Core.Services.CAR.Runtime.No[i].CustomerNumber;
			PermCAR[i].ArticleNumber := g_Core.Services.CAR.Runtime.No[i].ArticleNumber;
			PermCAR[i].RecipeNumber := g_Core.Services.CAR.Runtime.No[i].RecipeNumber;
		END_IF
	END_FOR
	IF RestorePermCAR THEN
		RestorePermCAR := FALSE; 
		RestorePermCARDone := TRUE;
		FOR i := 0 TO RNoOfCARPanels-1 DO 
			// At first boot, permanent will be empty, then make a "wrong change"
			IF (PermCAR[i].CustomerNumber = 0) AND (PermCAR[i].ArticleNumber = 0) AND (PermCAR[i].RecipeNumber = 0) THEN 
				CARFunction[i].RcpCompletion := TRUE;
			ELSE
				g_Core.Services.CAR.Interface.No[i].CustomerNumber := PermCAR[i].CustomerNumber;
				g_Core.Services.CAR.Interface.No[i].ArticleNumber := PermCAR[i].ArticleNumber;
				g_Core.Services.CAR.Interface.No[i].RecipeNumber := PermCAR[i].RecipeNumber;
			END_IF
		END_FOR
	END_IF

	//********************************************************************
	// External Input
	//********************************************************************
	FOR i := 0 TO RNoOfCARPanels-1 DO 
		IF CARFunction[0].ListLoaded = TRUE AND RestorePermCARDone AND NOT CARBusy THEN
			IF (RCustNo[i] <> g_Core.Services.CAR.Interface.No[i].CustomerNumber) OR (RArtNo[i] <> g_Core.Services.CAR.Interface.No[i].ArticleNumber) OR g_Core.Services.CAR.Interface.No[i].cmdSearchCustArtNo THEN
				g_Core.Services.CAR.Interface.No[i].cmdSearchCustArtNo := FALSE;
				RCustNo[i] 	:= g_Core.Services.CAR.Interface.No[i].CustomerNumber;
				RArtNo[i] 	:= g_Core.Services.CAR.Interface.No[i].ArticleNumber;
				// Shoule we remote the arrays of handlers???
				IF (isRemote) THEN
					CARHandler[0].Entry.CustNo 	:=  LIMIT(1,RCustNo[i],65535);
					CARHandler[0].Entry.ArtNo 	:= LIMIT(0,RArtNo[i],65535);
					CARHandler[0].Cmd.cmdSearchCustArtNo 	:= (RCustNo[i] <> 9999) AND (RArtNo[i] <> 9999);
					CARFunction[0].RcpCompletion 	:= (RCustNo[i] = 9999) OR (RArtNo[i] = 9999);
            		CARFunction[0].LaneNoCompletion := i;
					CARBusy := TRUE;
				ELSE
					CARHandler[0].Entry.CustNo 	:=  LIMIT(1,RCustNo[i],65535);
					CARHandler[0].Entry.ArtNo 	:= LIMIT(0,RArtNo[i],65535);
					CARHandler[0].Cmd.cmdSearchCustArtNo := (RCustNo[i] <> 9999) AND (RArtNo[i] <> 9999);
					CARFunction[0].RcpCompletion := (RCustNo[i] = 9999) OR (RArtNo[i] = 9999);
					CARFunction[0].LaneNoCompletion := i;
					CARBusy := TRUE;
				END_IF
            	
			END_IF
		END_IF
		
		// LookUp WrongChange
		IF (g_Core.Services.CAR.Runtime.No[i].CustomerNumber = 9999) AND (g_Core.Services.CAR.Runtime.No[i].ArticleNumber = 9999) THEN
			IF RRcpNo[i] <> g_Core.Services.CAR.Interface.No[i].RecipeNumber THEN  			
				RRcpNo[i] := g_Core.Services.CAR.Interface.No[i].RecipeNumber;
				IF (isRemote) THEN
					RcpCompletion[i] := TRUE;
				ELSE
					RcpCompletion[i] := TRUE;
					//CARFunction[i].RcpCompletion := TRUE;
				END_IF
			END_IF
		END_IF
		
		IF NOT g_Core.Services.CAR.Runtime.isEnabled AND ((i = 0) OR g_Core.Services.Blackbox.Configuration.Master.MultiRcp) THEN
			// New Recipe
			IF (g_Core.Services.CAR.Runtime.No[i].RecipeNumber <> g_Core.Services.CAR.Interface.No[i].RecipeNumber) THEN
				g_Core.Services.CAR.Runtime.No[i].RecipeNumber 	:= LIMIT(1,g_Core.Services.CAR.Interface.No[i].RecipeNumber,99);
				// Get Recipename dynamicly
				getRecipeName;
				g_Core.Services.CAR.Runtime.No[i].RecipeName := recipeName;
				updatePermCAR[i] := TRUE;
				g_Core.Services.CAR.Interface.No[i].isCmdIncrementLoadID := TRUE; 
				// New Norm
				getRecipeNorm;
				IF (g_Core.Services.CAR.Runtime.No[i].Norm <> Norm) THEN
					g_Core.Services.CAR.Runtime.No[i].Norm := Norm;
				END_IF
			END_IF
		
			
		END_IF
	END_FOR
	
	//********************************************************************
	// HMI Input
	//********************************************************************
	FOR i := 0 TO RNoOfCARPanels-1 DO 
		// Customer and Article Selected
		IF CARHandler[i].Cmd.cmdSelect = 1 THEN
			CARHandler[i].Cmd.cmdSelect := 0;
			IF CARHandler[i].ListInfo.NextLayerLastLayer > 0 THEN
				CARHandler[i].Cmd.cmdScroll := 3;
			ELSE
				IF (isRemote) THEN
                	RSearchOK[CARFunction[i].LaneNoCompletion] := 1;
				ELSE
					RSearchOK[CARFunction[i].LaneNoCompletion] := 1;
				END_IF
				CallPageControllerLink(1, g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler); // Goto OpMainPage 
			END_IF
		END_IF
	END_FOR
	
	//********************************************************************
	// Wrong Change
	//********************************************************************
	IF g_Core.Services.CAR.Runtime.isEnabled THEN
		FOR i := 0 TO RNoOfCARPanels-1 DO 
			IF (RcpCompletion[i]) THEN
				CARFunction[i].RcpCompletion := FALSE;
				RcpCompletion[i] := FALSE;
				g_Core.Services.CAR.Runtime.No[i].CustomerNumber:= 9999;
				g_Core.Services.CAR.Runtime.No[i].ArticleNumber := 9999;
				g_Core.Services.CAR.Runtime.No[i].CustomerName:= 'Wrong Change';
				g_Core.Services.CAR.Runtime.No[i].ArticleName := 'Wrong Change';
				g_Core.Services.CAR.Runtime.No[i].RecipeNumber 	:= LIMIT(1,g_Core.Services.CAR.Interface.No[i].RecipeNumber,99);
				// Get Recipename dynamicly
				getRecipeName;
				g_Core.Services.CAR.Runtime.No[i].RecipeName := recipeName;
				updatePermCAR[i] := TRUE;
				g_Core.Services.CAR.Interface.No[i].isCmdIncrementLoadID := TRUE; 
			END_IF
		END_FOR	
	END_IF
	
	//********************************************************************
	// Output
	//********************************************************************
	FOR i := 0 TO RNoOfCARPanels-1 DO 
		IF RSearchOK[i] THEN
			RSearchOK[i] := 0;
			CARBusy := FALSE;     
			g_Core.Services.CAR.Runtime.No[i].CustomerNumber    := LIMIT(1,CARHandler[0].Entry.CustNo,65535);
			g_Core.Services.CAR.Runtime.No[i].ArticleNumber     := LIMIT(0,CARHandler[0].Entry.ArtNo,65535);
			g_Core.Services.CAR.Runtime.No[i].RecipeNumber      := LIMIT(1,CARHandler[0].Entry.RcpNo,99);
			
			// Set also interface
			g_Core.Services.CAR.Interface.No[i].CustomerNumber    := LIMIT(1,CARHandler[0].Entry.CustNo,65535);
			g_Core.Services.CAR.Interface.No[i].ArticleNumber     := LIMIT(0,CARHandler[0].Entry.ArtNo,65535);
			g_Core.Services.CAR.Interface.No[i].RecipeNumber    := LIMIT(1,CARHandler[0].Entry.RcpNo,99); // for updating the input.
			
			// Prevent interface deadlock
			RCustNo[i] 	:= g_Core.Services.CAR.Interface.No[i].CustomerNumber;
			RArtNo[i] 	:= g_Core.Services.CAR.Interface.No[i].ArticleNumber;
			
			updatePermCAR[i] := TRUE;

			g_Core.Services.CAR.Runtime.No[i].CustomerName      := CARHandler[0].ListInfo.StringPrevLayer;
			g_Core.Services.CAR.Runtime.No[i].ArticleName       := CARHandler[0].ListInfo.StringActLayer;
			// Get Recipename dynamicly
			getRecipeName;
			g_Core.Services.CAR.Runtime.No[i].RecipeName := recipeName;
			// Extra information
			IF (CARHandler[0].Entry.Norm = 0) THEN
				getRecipeNorm;
			ELSE 
				Norm := CARHandler[0].Entry.Norm;
			END_IF
			g_Core.Services.CAR.Runtime.No[i].Norm              := Norm;
			
			g_Core.Services.CAR.Runtime.No[i].FlowTimeout       := CARHandler[0].Entry.FlowTimeOut;
			g_Core.Services.CAR.Runtime.No[i].Primary           := CARHandler[0].Entry.Primary;
			g_Core.Services.CAR.Runtime.No[i].Reference         := CARHandler[0].Entry.Reference;
        	g_Core.Services.CAR.Runtime.No[i].LoadID            := g_Core.Services.CAR.Runtime.No[i].LoadID +1;
   		END_IF
	
        // Manual increase counter
		IF g_Core.Services.CAR.Interface.No[i].isCmdIncrementLoadID THEN
			g_Core.Services.CAR.Interface.No[i].isCmdIncrementLoadID := 0;
			g_Core.Services.CAR.Runtime.No[i].LoadID := g_Core.Services.CAR.Runtime.No[i].LoadID +1;
		END_IF	
	END_FOR
	
	//********************************************************************
	// Update all other, if not MultiRcp
	//********************************************************************
	IF NOT g_Core.Services.Blackbox.Configuration.Master.MultiRcp AND (g_Core.Services.Blackbox.Configuration.Master.ProductionUnits > 1) AND NOT isRemote THEN
		FOR x := 1 TO (g_Core.Services.Blackbox.Configuration.Master.ProductionUnits - 1) DO
			g_Core.Services.CAR.Runtime.No[x] := g_Core.Services.CAR.Runtime.No[0];
		END_FOR	
	END_IF	
	
	//**********************************************************************************************************************************
	// Function handling, 1 for each panel	 				 								    
	//********************************************************************
	FOR i := 0 TO RNoOfCARPanels-1 DO
		IF g_Core.Services.HMIHandler.Runtime.Handler[i].pVCHandler <> 0 THEN
			// Update button in HMI	 				 								    
			IF g_Core.Services.HMIHandler.Runtime.Handler[i].SystemInitDone = 1 AND g_Core.System.Runtime.isCustomerEnabled AND NOT CARFunction[i].CustomerEnable  THEN
				IF g_Core.Services.System.Runtime.file.IconsEnabled THEN 
					ButtonId := 155;
				ELSE
					ButtonId:= 36;
				END_IF	
				UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler, 3, 4, ButtonId, 0, 7);
				UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler, 5, 4, ButtonId, 0, 7);
				UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler, 6, 4, ButtonId, 0, 7);
				UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler, 8, 4, ButtonId, 0, 7); 
				CARFunction[i].CustomerEnable := TRUE;
			END_IF
			IF g_Core.Services.HMIHandler.Runtime.Handler[i].SystemInitDone = 1 AND NOT g_Core.System.Runtime.isCustomerEnabled AND CARFunction[i].CustomerEnable  THEN
				UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler, 3, 4, 0, 0, 0);
				UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler, 5, 4, 0, 0, 0);
				UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler, 6, 4, 0, 0, 0);
				CARFunction[i].CustomerEnable := FALSE;
			END_IF
	
			// Handling
			CASE CARFunction[i].State OF
				//*******************************************************
				//	Check for command to do 
				//*******************************************************
				CUST_CHECK_COMMAND:
					//	Load list 
					IF (CARHandler[i].Cmd.cmdLoadList = 1) THEN
						CARHandler[i].Cmd.cmdLoadList := 0;
						CARFunction[i].ListLoaded := FALSE;
						CARHandler[i].Rdy.rdyLoadList := 0;
	
						CustLoad[i].pSourceName := ADR('custart.csv');
						CustLoad[i].pStringArray := ADR(CARHandler[i].Vis.ItemList);
						CustLoad[i].pEntryStruct := ADR(CARHandler[i].Entry);
						CustLoad[i].pListInfoStruct := ADR(CARHandler[i].ListInfo);
	
						CustLoad[i].Enable := 1;
						CustLoad[i].Ident := CARFunction[i].Ident;
						CustLoad[i]();
						CARFunction[i].State := CUST_LOAD;
						IF NOT RDontNotify THEN
							Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_OPEN_120, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
						END_IF							
						RDontNotify := FALSE;
	
					//	save list 
					ELSIF (CARHandler[i].Cmd.cmdSaveList = 1) THEN
						CARHandler[i].Cmd.cmdSaveList := 0;
						CARHandler[i].Rdy.rdySaveList := 0;
						CustSave.Enable := 1;
						CustSave.Ident := CARFunction[i].Ident;
						CustSave.pDestName := CustLoad[i].pSourceName;
						CustSave();
						CARFunction[i].State := CUST_SAVE;
						Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_SAVE_121, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
	
					//	scroll list 
					ELSIF (CARHandler[i].Cmd.cmdScroll <> 0) THEN
						// 1 = Up, 2 = Down, 3 = Right, 4 = Left
						// Stop scrolling up, if allready on top 
						IF (CARHandler[i].Cmd.cmdScroll = 1) AND (CARHandler[i].ListInfo.ActEntryInLayer <= 0) THEN
							CARHandler[i].Cmd.cmdScroll := 0;
					 	END_IF
						// Stop scrolling down, if allready on end 
						IF (CARHandler[i].Cmd.cmdScroll = 2) AND (CARHandler[i].ListInfo.ActEntryInLayer +1 >= CARHandler[i].ListInfo.NumberEntryInLayer) THEN
							CARHandler[i].Cmd.cmdScroll := 0;
					 	END_IF
	 
						// Scroll 
						IF CARHandler[i].Cmd.cmdScroll > 0 THEN
							IF RCycleCount > CARFunction[i].ReScrollTimeout THEN // Don't scroll each scan
								CARHandler[i].Rdy.rdyScroll := 0;
								CustScroll[i].Enable := 1;
								CustScroll[i].Ident := CARFunction[i].Ident;
								CustScroll[i].pListInfoStruct := CustInit.pListInfoStruct;
								CustScroll[i].cmdScroll := CARHandler[i].Cmd.cmdScroll;
	
								CustScroll[i].pListInfoStruct := ADR(CARHandler[i].ListInfo);
								CustScroll[i].pStringArray := ADR(CARHandler[i].Vis.ItemList);
								CustScroll[i].pEntryStruct := ADR(CARHandler[i].Entry);
	
								CustScroll[i]();
								CARFunction[i].State := CUST_SCROLL;
								CARFunction[i].ReScrollTimeout := RCycleCount + TaskCycleTime; 
							END_IF
						END_IF
	
					//	add item to list 
					ELSIF (CARHandler[i].Cmd.cmdAddItem = 1) THEN
						CARHandler[i].Rdy.rdyAddItem := 0;
						CustAdd.Enable := 1;
						CustAdd.Ident := CARFunction[i].Ident;
						CustAdd.cmdAdd := 1;
						CustAdd.optDoSort := CARHandler[i].Option.DoSortAfterAdd;
						CustAdd();
						CARHandler[i].Option.DoSortAfterAdd := 0;
						CARFunction[i].State := CUST_ADD;
	
					//	delete item in list 
					ELSIF (CARHandler[i].Cmd.cmdDeleteItem = 1) THEN
						CARHandler[i].Rdy.rdyDeleteItem := 0;
						CustDelete.Enable := 1;
						CustDelete.Ident := CARFunction[i].Ident;
						CustDelete.optDeleteAll := 0;
						CustDelete();
						CARFunction[i].State := CUST_DELETE;
	
					//	delete whole list 
					ELSIF (CARHandler[i].Cmd.cmdDeleteList = 1) THEN
						CARHandler[i].Rdy.rdyDeleteList := 0;
						CustDelete.Enable := 1;
						CustDelete.Ident := CARFunction[i].Ident;
						CustDelete.optDeleteAll := 1;
						CustDelete();
						CARFunction[i].State := CUST_DELETE_LIST;
	
					//	Lock/unlock functions in library 
					ELSIF (CARHandler[i].Cmd.cmdLockList = 1) OR  (CARHandler[i].Cmd.cmdLockList = 2) THEN
						CustLock.Enable := 1;
						CustLock.Ident := CARFunction[i].Ident;
						IF CARHandler[i].Cmd.cmdLockList = 1 THEN
							CARHandler[i].Rdy.rdyLockList := 0;
							CustLock.LockNumber := LIST_LOCK_DEF;
						ELSE
							CARHandler[i].Rdy.rdyUnlockList := 0;
							CustLock.LockNumber := 0;
						END_IF	
						CustLock();
						CARFunction[i].State := CUST_LOCK;
	
					//	edit actual item in list 
					ELSIF (CARHandler[i].Cmd.cmdEditItem = 1) THEN
						CARHandler[i].Rdy.rdyEditItem := 0;
						CustEdit.Enable := 1;
						CustEdit.Ident := CARFunction[i].Ident;
						CustEdit();
						CARFunction[i].State := CUST_EDIT;
	
					//	search customer/article name in list 
					ELSIF (CARHandler[i].Cmd.cmdSearchCustArt = 1) THEN
						CARHandler[i].Rdy.rdySearchCustArt := 0;
						CustSearch.Enable := 1;
						CustSearch.Ident := CARFunction[i].Ident;
						CustSearch.OptionSearch := LIST_SEARCH_NAME;
						CustSearch.pListInfoStruct := ADR(CARHandler[i].ListInfo);
						CustSearch.pStringArray := ADR(CARHandler[i].Vis.ItemList);
						CustSearch.pEntryStruct := ADR(CARHandler[i].Entry);
						CustSearch();
						CARFunction[i].State := CUST_SEARCH_CUSTART;
	
					//	search customer number in list 
					ELSIF (CARHandler[i].Cmd.cmdSearchCustNo = 1) THEN
						CARHandler[i].Rdy.rdySearchCustNo := 0;
						CustSearch.Enable := 1;
						CustSearch.Ident := CARFunction[i].Ident;
						CustSearch.OptionSearch := LIST_SEARCH_NUMBER_0;
						CustSearch.pListInfoStruct := ADR(CARHandler[i].ListInfo);
						CustSearch.pStringArray := ADR(CARHandler[i].Vis.ItemList);
						CustSearch.pEntryStruct := ADR(CARHandler[i].Entry);
						CustSearch();
						CARFunction[i].State := CUST_SEARCH_CUSTNO;
	
					//	search article number in list 
					ELSIF (CARHandler[i].Cmd.cmdSearchArtNo = 1) THEN
						CARHandler[i].Rdy.rdySearchArtNo := 0;
						CustSearch.Enable := 1;
						CustSearch.Ident := CARFunction[i].Ident;
						CustSearch.OptionSearch := LIST_SEARCH_NUMBER_1;
						CustSearch.pListInfoStruct := ADR(CARHandler[i].ListInfo);
						CustSearch.pStringArray := ADR(CARHandler[i].Vis.ItemList);
						CustSearch.pEntryStruct := ADR(CARHandler[i].Entry);
						CustSearch();
						CARFunction[i].State := CUST_SEARCH_ARTNO;
	
					//	Search Customer and Article number in list 
					ELSIF (CARHandler[i].Cmd.cmdSearchCustArtNo = 1) THEN
						CARHandler[i].Rdy.rdySearchCustArtNo := 0;
						CustSearch.Enable := 1;
						CustSearch.Ident := CARFunction[i].Ident;
						CustSearch.OptionSearch := LIST_SEARCH_NUMBER_2;
						CustSearch.pListInfoStruct := ADR(CARHandler[i].ListInfo);
						CustSearch.pStringArray := ADR(CARHandler[i].Vis.ItemList);
						CustSearch.pEntryStruct := ADR(CARHandler[i].Entry);
						CustSearch();
						CARFunction[i].State := CUST_SEARCH_CUSTARTNO;
					END_IF
	
				//*******************************************************
				// Functions 
				//*******************************************************
				//	load customer & article list from file 
				CUST_LOAD:
					IF (CustLoad[i].Status = OPCU_LIST_BUSY) THEN
						CustLoad[i].Enable := 1;
						CustLoad[i].Ident := CARFunction[i].Ident;
						CustLoad[i]();
					ELSE
						//	Reset command anyway 
						CARHandler[i].Cmd.cmdLoadList := 0;
						CARFunction[i].State := CUST_CHECK_COMMAND;
						IF (CustLoad[i].Status = 0) THEN
							CARFunction[i].ListLoaded := TRUE;
							
							// Set all ready
							CARHandler[i].Rdy := RdyTrue;
							CARHandler[i].ListInfo.ErrStringInfo := 'List loaded';
							g_Core.Services.CAR.Runtime.loadCount := g_Core.Services.CAR.Runtime.loadCount + 1;
						
							// Do Load on all other panels
							IF i = 0 THEN
								FOR x := 1 TO RNoOfCARPanels-1 DO
									CARHandler[x].Cmd.cmdLoadList := 1;
									CARFunction[x].Ident := CARFunction[0].Ident;
									CARFunction[x].State := CUST_CHECK_COMMAND;
								END_FOR
							END_IF
						END_IF
					END_IF
	
				//	save customer & article list to file 
				CUST_SAVE:
					IF (CustSave.Status = OPCU_LIST_BUSY) THEN
						CustSave.Enable := 1;
						CustSave.Ident := CARFunction[i].Ident;
						CustSave.pDestName := CustLoad[i].pSourceName;
						CustSave();
					ELSE
						//	Reset command anyway 
						CARHandler[i].Cmd.cmdSaveList := 0;
						CARFunction[i].State := CUST_CHECK_COMMAND;
						IF (CustSave.Status = 0) THEN
							CARHandler[i].Rdy.rdySaveList := 1;
							CARHandler[i].ListInfo.ErrStringInfo := 'List saved';
							g_Core.Services.CAR.Runtime.saveCount := g_Core.Services.CAR.Runtime.saveCount + 1;
						END_IF
					END_IF
	
				//	scroll in customer & article list 
				CUST_SCROLL:
					IF (CustScroll[i].Status = OPCU_LIST_BUSY) THEN
						CustScroll[i].Enable := 1;
						CustScroll[i].Ident := CARFunction[i].Ident;
						CustScroll[i]();
					ELSE
						//	Reset command anyway 
						IF CARHandler[i].Cmd.cmdScroll > 2 THEN
							CARHandler[i].Cmd.cmdScroll := 0;
						END_IF
						CARFunction[i].State := CUST_CHECK_COMMAND;
						IF (CustScroll[i].Status = 0) THEN
							CARHandler[i].Rdy.rdyScroll := 1;
							CARHandler[i].ListInfo.ErrStringInfo := 'List scrolled';
						END_IF
					END_IF
	
				//	add item to customer & article list 
				CUST_ADD:
					IF (CustAdd.Status = OPCU_LIST_BUSY) THEN
						CustAdd.Enable := 1;
						CustAdd.Ident := CARFunction[i].Ident;
						CustAdd();
					ELSE
						//	Reset command anyway 
						CARHandler[i].Cmd.cmdAddItem := 0;
						CARFunction[i].State := CUST_CHECK_COMMAND;
						IF (CustAdd.Status = 0) THEN
							CARHandler[i].Rdy.rdyAddItem := 1;
							CARHandler[i].ListInfo.ErrStringInfo := 'Item added';
						END_IF
					END_IF
	
				//	delete item in list 
				CUST_DELETE:
					IF (CustDelete.Status = OPCU_LIST_BUSY) THEN
						CustDelete.Enable := 1;
						CustDelete.Ident := CARFunction[i].Ident;
						CustDelete();
					ELSE
						//	Reset command anyway 
						CARHandler[i].Cmd.cmdDeleteItem := 0;
						CARFunction[i].State := CUST_CHECK_COMMAND;
						IF (CustDelete.Status = 0) THEN
							CARHandler[i].Rdy.rdyDeleteItem := 1;
							CARHandler[i].ListInfo.ErrStringInfo := 'Item deleted';
						END_IF
					END_IF
	
				//	delete item in list 
				CUST_DELETE_LIST:
					IF (CustDelete.Status = OPCU_LIST_BUSY) THEN
						CustDelete.Enable := 1;
						CustDelete.Ident := CARFunction[i].Ident;
						CustDelete();
					ELSE
						//	Reset command anyway 
						CARHandler[i].Cmd.cmdDeleteList := 0;
						CARFunction[i].State := CUST_CHECK_COMMAND;
						IF (CustDelete.Status = 0) THEN
							CARHandler[i].Rdy.rdyDeleteList := 1;
							CARHandler[i].ListInfo.ErrStringInfo := 'List deleted';
						END_IF
					END_IF
	
				//	Lock/unlock functions in library 
				CUST_LOCK:
					IF (CustLock.Status = OPCU_LIST_BUSY) THEN
						CustLock.Enable := 1;
						CustLock.Ident := CARFunction[i].Ident;
						CustLock();
					ELSE
						//	Reset command anyway 
						CARHandler[i].Cmd.cmdLockList := 0;
						CARFunction[i].State := CUST_CHECK_COMMAND;
						IF (CustLock.Status = 0) THEN
							IF CustLock.LockNumber = LIST_LOCK_DEF THEN
								CARHandler[i].Rdy.rdyLockList := 1;
								CARHandler[i].ListInfo.ErrStringInfo := 'List locked';
							ELSE
								CARHandler[i].Rdy.rdyUnlockList := 1;
								CARHandler[i].ListInfo.ErrStringInfo := 'List unlocked';
							END_IF
						END_IF
					END_IF
	
				//	edit item in list 
				CUST_EDIT:
					IF (CustEdit.Status = OPCU_LIST_BUSY) THEN
						CustEdit.Enable := 1;
						CustEdit.Ident := CARFunction[i].Ident;
						CustEdit();
					ELSE
						//	Reset command anyway 
						CARHandler[i].Cmd.cmdEditItem := 0;
						CARFunction[i].State := CUST_CHECK_COMMAND;
						IF (CustEdit.Status = 0) THEN
							CARHandler[i].Rdy.rdyEditItem := 1;
							CARHandler[i].ListInfo.ErrStringInfo := 'Item edited';
						END_IF
					END_IF
	
				//	search customer/article name in list 
				CUST_SEARCH_CUSTART:
					IF (CustSearch.Status = OPCU_LIST_BUSY) THEN
						CustSearch.Enable := 1;
						CustSearch.Ident := CARFunction[i].Ident;
						CustSearch();
					ELSE
						//	Reset command anyway 
						CARHandler[i].Cmd.cmdSearchCustArt := 0;
						CARFunction[i].State := CUST_CHECK_COMMAND;
						IF (CustSearch.Status = 0) THEN
							CARHandler[i].Rdy.rdySearchCustArt := 1;
							CARHandler[i].ListInfo.ErrStringInfo := 'CustArt Search';

						END_IF
					END_IF
	
				//	search customer number in list 
				CUST_SEARCH_CUSTNO:
					IF (CustSearch.Status = OPCU_LIST_BUSY) THEN
						CustSearch.Enable := 1;
						CustSearch.Ident := CARFunction[i].Ident;
						CustSearch();
					ELSE
						//	Reset command anyway 
						CARHandler[i].Cmd.cmdSearchCustNo := 0;
						CARFunction[i].State := CUST_CHECK_COMMAND;
						IF (CustSearch.Status = 0) THEN
							CARHandler[i].Rdy.rdySearchCustNo := 1;
							CARHandler[i].ListInfo.ErrStringInfo := 'CustNo Search';
						END_IF
						// Search not found, but ready for next search
						IF (CustSearch.Status = 50312) THEN
							g_Core.Services.CAR.Runtime.No[CARFunction[i].LaneNoCompletion].CustomerNumber:= CARHandler[i].Entry.CustNo;
							g_Core.Services.CAR.Runtime.No[CARFunction[i].LaneNoCompletion].CustomerName:= 'ERROR, not in list';
							CARHandler[i].ListInfo.ErrStringInfo := 'ERROR, not in list';
							CARHandler[i].Rdy.rdySearchCustNo := 1;
						END_IF
					END_IF
	
				//	search customer number in list 
				CUST_SEARCH_ARTNO:
					IF (CustSearch.Status = OPCU_LIST_BUSY) THEN
						CustSearch.Enable := 1;
						CustSearch.Ident := CARFunction[i].Ident;
						CustSearch();
					ELSE
						//	Reset command anyway 
						CARHandler[i].Cmd.cmdSearchArtNo := 0;
						CARFunction[i].State := CUST_CHECK_COMMAND;
						IF (CustSearch.Status = 0) THEN
							CARHandler[i].Rdy.rdySearchArtNo := 1;
							CARHandler[i].ListInfo.ErrStringInfo := 'ArtNo Search';
						END_IF
						// Search not found, but ready for next search
						IF (CustSearch.Status = 50312) THEN
							g_Core.Services.CAR.Runtime.No[CARFunction[i].LaneNoCompletion].ArticleNumber := CARHandler[i].Entry.ArtNo;
							g_Core.Services.CAR.Runtime.No[CARFunction[i].LaneNoCompletion].ArticleName := 'ERROR, not in list';
							CARHandler[i].ListInfo.ErrStringInfo := 'ERROR, not in list';
							CARHandler[i].Rdy.rdySearchArtNo := 1;
							CARBusy := FALSE;
						END_IF
					END_IF
	
				//	Search Customer and Article number in list 
				CUST_SEARCH_CUSTARTNO:
					IF (CustSearch.Status = OPCU_LIST_BUSY) THEN
						CustSearch.Enable := 1;
						CustSearch.Ident := CARFunction[i].Ident;
						CustSearch();
					ELSE
						//	Reset command anyway 
						CARHandler[i].Cmd.cmdSearchCustArtNo := 0;
						CARFunction[i].State := CUST_CHECK_COMMAND;
						IF (CustSearch.Status = 0) THEN
							IF (isRemote) THEN
								RSearchOK[CARFunction[0].LaneNoCompletion] := 1;
							ELSE
								RSearchOK[CARFunction[0].LaneNoCompletion] := 1;
							END_IF
							CARHandler[i].Rdy.rdySearchCustArtNo := 1;
							CARHandler[i].ListInfo.ErrStringInfo := 'CustArtNo Search';
						END_IF
						// Search not found, but ready for next search
						IF (CustSearch.Status = 50312) THEN
							CARHandler[i].Rdy.rdySearchCustArtNo := 1;
							// Error Cust art not found!
							g_Core.Services.CAR.Runtime.No[CARFunction[i].LaneNoCompletion].CustomerNumber:= CARHandler[i].Entry.CustNo;
							g_Core.Services.CAR.Runtime.No[CARFunction[i].LaneNoCompletion].ArticleNumber := CARHandler[i].Entry.ArtNo;
							g_Core.Services.CAR.Runtime.No[CARFunction[i].LaneNoCompletion].CustomerName:= 'ERROR, not in list';
							g_Core.Services.CAR.Runtime.No[CARFunction[i].LaneNoCompletion].ArticleName := 'ERROR, not in list';
							CARHandler[i].ListInfo.ErrStringInfo := 'ERROR, not in list';
							CARBusy := FALSE;
						END_IF
					END_IF
			END_CASE;
	
			// Timeout for error text
			IF CARFunction[i].State = CUST_CHECK_COMMAND THEN
				IF RCycleCount > (CARFunction[i].TextTimeout + 400) THEN 
					CARHandler[i].ListInfo.ErrStringInfo := '';
					CARHandler[i].ListInfo.ErrStringDetail := '';
				END_IF
			ELSE
				CARFunction[i].TextTimeout := RCycleCount; 
			END_IF
		END_IF
	END_FOR
	RCycleCount := RCycleCount +1;
	
	//********************************************************************
	// HMI information
	//********************************************************************
	FOR i := 0 TO RNoOfCARPanels-1 DO
		IF (g_Core.Services.HMIHandler.Runtime.Handler[i].PageControllerID = PageCARSelect) OR (g_Core.Services.HMIHandler.Runtime.Handler[i].PageControllerID = PageCAREdit) THEN
			IF g_Core.Services.HMIHandler.Runtime.Handler[i].pVCHandler <> 0 THEN
				 CARFunction[i].Status.BtUpStat := SEL((CARHandler[i].ListInfo.ActEntryInLayer <= 0) ,0,1);
				 CARFunction[i].Status.BtDwStat := SEL((CARHandler[i].ListInfo.ActEntryInLayer +1 >= CARHandler[i].ListInfo.NumberEntryInLayer),0,1);
				 CARFunction[i].Status.BtLeftStat := SEL((CARHandler[i].ListInfo.ActLayer=1),1,0);
				 CARFunction[i].Status.BtRightStat := SEL((CARHandler[i].ListInfo.NextLayerLastLayer=1),1,0);
				 CARFunction[i].Status.BtEnterStat := SEL(((g_Core.System.Configuration.isRemoteEnabled) AND (CARHandler[i].ListInfo.NextLayerLastLayer=0)),0,1);
	 			 CARFunction[i].Status.BtDeleteStat := SEL((CARHandler[i].ListInfo.NextLayerLastLayer=1),0,1);
				IF i = 0 THEN CARFunction[i].Status.BtLoadSaveStat := 0; ELSE CARFunction[i].Status.BtLoadSaveStat := 1; END_IF // Only Load, Save on main panel
			END_IF
	
			// Error information
			IF (CARHandler[i].ListInfo.ErrStringDetail > '') THEN		(* Only if detail information *)
				g_Core.Services.Alarmhandler.Interface.FileError.Show 		:= TRUE;
				g_Core.Services.Alarmhandler.Interface.FileError.InfoText 	:= CARHandler[i].ListInfo.ErrStringInfo;
				g_Core.Services.Alarmhandler.Interface.FileError.DetailText := CARHandler[i].ListInfo.ErrStringDetail;
		//		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 0, 5, 69, 'File error created.'); 
			ELSE																						(* No error information *)
				g_Core.Services.Alarmhandler.Interface.FileError.Show 		:= FALSE;
				g_Core.Services.Alarmhandler.Interface.FileError.InfoText 	:= '';
				g_Core.Services.Alarmhandler.Interface.FileError.DetailText := '';
			END_IF
		END_IF
	END_FOR
	// EXTRA
	IF TmpDelay > 100 THEN
		TmpDelay := 0;
	END_IF
	TmpDelay := TmpDelay + 1;
	FOR i := 0 TO 1 DO
		IF (g_Core.Services.CAR.Runtime.No[i].RecipeNumber > 0) THEN
			// Get Recipename dynamicly
			IF (TmpDelay > 100) THEN
				getRecipeName;
				g_Core.Services.CAR.Runtime.No[i].RecipeName := recipeName;
			END_IF
		END_IF
	END_FOR
END_PROGRAM
