PROGRAM _INIT
	LogListNo := 0;
	LogNo	  := 1; (*Default startlog (master)*)
	LogNoOld  := 0;
	Scroll_0( DelayScroll := 800, DelayRepeat := 100, pTimeReference := ADR( g_Core.Services.Time.Runtime.MilliSeconds ));
	Scroll_1( DelayScroll := 800, DelayRepeat := 100, pTimeReference := ADR( g_Core.Services.Time.Runtime.MilliSeconds ));
END_PROGRAM

