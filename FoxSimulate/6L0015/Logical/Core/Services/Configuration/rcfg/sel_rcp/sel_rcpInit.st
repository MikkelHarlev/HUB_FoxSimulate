PROGRAM _INIT
(* init program *)

	pThis ACCESS ADR(g_Core.Services.Recipe.Runtime);

	pThis.Runtime.Select.ShowLayer := 1;

	pThis.Runtime.CategoryList.MaxFoldPrograms 	:= g_Core.System.Configuration.arrSizeRCfg;

	FOR i := 0 TO pThis.Runtime.CategoryList.MaxFoldPrograms-1 DO
		itoa(i+1, ADR(pThis.Runtime.CategoryList.IdString[i]));
END_FOR
	
END_PROGRAM

