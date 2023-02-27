PROGRAM _INIT

	g_Core.Services.System.Runtime.initState 	:= INIT;
	
	// Parameters for RcpInit
	RcpInit_0.Enable							:= 1;
	RcpInit_0.pStructName						:= ADR('system:SystemFileData');
	RcpInit_0.pRcpInfoStruct					:= ADR(RcpInfo);
	RcpInit_0.LenRcpInfoStruct					:= SIZEOF(RcpInfo);
	RcpInit_0.pFileNameArray					:= 0;
	RcpInit_0.SizeFileNameArray					:= 0;
	RcpInit_0.LinesFileNameArray				:= 0;
	RcpInit_0.cfgWorkWithVar					:= 1;
	RcpInit_0.cfgCompressOn						:= 0;
	RcpInit_0();
	
	// Parameters for RcpLoad
	RcpLoad_0.Enable							:= 1;
	RcpLoad_0.Ident								:= RcpInit_0.Ident;
	RcpLoad_0.pDevice							:= ADR('system');
	RcpLoad_0.pFileName							:= ADR('system.csv');
	
	// Parameters for RcpSave
	RcpSave_0.Enable							:= 1;
	RcpSave_0.Ident								:= RcpInit_0.Ident;
	RcpSave_0.pDevice							:= ADR('system');
	RcpSave_0.pFileName							:= ADR('system.csv');
	RcpSave_0.optHeaderOnly						:= 0;
	
	IF RcpInit_0.Status = 0 THEN
		step	:= SYSTEM_LOAD_FILE;
	ELSE
		step	:= SYSTEM_FILE_ERROR;
	END_IF
END_PROGRAM