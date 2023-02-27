PROGRAM _INIT
	(*------------------------------------------------- Init Program -----------------------------------------------------*)
	(* Machine Information *)
	PageInfo := LookupPageID(PAGE_SYS_INFORMATION,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
	PageSystem := LookupPageID(PAGE_SYSTEM,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
	
	// Load Revision number from Version.dat file. The Version.dat file should automaticly be updated on each update/commit. check tortoise settings. 
	memset(ADR(RevisionString),0,SIZEOF(RevisionString));
	DatObjInfo_0(enable:=1, pName:=ADR('Version'));
	IF (DatObjInfo_0.status = doERR_MODULNOTFOUND) THEN
		RevisionString := 'n/a';
	ELSE //DataObject found
		DataObjectLenght := DatObjInfo_0.len;
		IF DataObjectLenght > SIZEOF(RevisionString) THEN
			DataObjectLenght := SIZEOF(RevisionString);
		END_IF
		DatObjRead_0(enable:=1, ident:=DatObjInfo_0.ident, Offset:=0, pDestination:=ADR(RevisionString), len:=DataObjectLenght);
	END_IF
	
	CoreFramworkVersion := RevisionString;
	ProgramVersion := g_Core.System.Configuration.SystemDescription.ProgramVersion;
	
	// Machine Info Data Creator
	fDevice	:= 'system';
	ReadMachineInfoDataObject := 1;
END_PROGRAM

