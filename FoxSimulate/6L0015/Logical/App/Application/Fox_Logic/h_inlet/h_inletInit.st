

PROGRAM _INIT

	INIT_H_INLET := FALSE;
	
	FBTshirtBlastLeft(MemNameAdr := ADR('TshirtBlastLeft'), CntNameAdr:=ADR('g_HPulsCounter'), CntOutNameAdr := ADR('g_MilliSeconds'), Mode := 1);
	FBTshirtBlastRight(MemNameAdr := ADR('TshirtBlastRight'), CntNameAdr:=ADR('g_HPulsCounter'), CntOutNameAdr := ADR(g_MilliSeconds), Mode := 1);

	FBSleeveBlastLeft(MemNameAdr := ADR('SleeveBlastLeft'), CntNameAdr:=ADR('g_HPulsCounter'), CntOutNameAdr := ADR('g_MilliSeconds'), Mode := 1);
	FBSleeveBlastRight(MemNameAdr := ADR('SleeveBlastRight'), CntNameAdr:=ADR('g_HPulsCounter'), CntOutNameAdr := ADR('g_MilliSeconds'), Mode := 1);
	
	enableFB;

END_PROGRAM