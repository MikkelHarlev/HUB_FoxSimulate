
FUNCTION mirrorStartThread : UINT
	VAR_INPUT
		t : MT_MirrorThread;
		tk : CacheTrackEssential_Type;
	END_VAR
END_FUNCTION

FUNCTION mirrorStopThread : UINT
	VAR_INPUT
		t : MT_MirrorThread;
	END_VAR
END_FUNCTION

FUNCTION ChCliFind : UINT
	VAR_INPUT
		ce : CacheTrackEssential_Type;
		data : HangerASCII24_Type;
	END_VAR
END_FUNCTION

FUNCTION ChCliFresh : UINT
	VAR_INPUT
		ce : CacheTrackEssential_Type;
		data : HangerASCII24_Type;
	END_VAR
END_FUNCTION

FUNCTION ChCliForce : UINT
	VAR_INPUT
		ce : CacheTrackEssential_Type;
		data : HangerASCII24_Type;
	END_VAR
END_FUNCTION

FUNCTION ChCliDelete : UINT
	VAR_INPUT
		ce : CacheTrackEssential_Type;
		data : HangerASCII24_Type;
	END_VAR
END_FUNCTION

FUNCTION ChMgrClear : UINT
	VAR_INPUT
		ce : CacheTrackEssential_Type;
	END_VAR
END_FUNCTION

FUNCTION ChCliLastState : UINT
	VAR_INPUT
		ce : CacheTrackEssential_Type;
	END_VAR
END_FUNCTION

FUNCTION ChMirGet : UINT
	VAR_INPUT
		ce : CacheTrackEssential_Type;
		data : HangerASCII24_Type;
		pBatch : REFERENCE TO USINT;
		idx : USINT;
	END_VAR
END_FUNCTION

FUNCTION ChMirGetAck : UINT
	VAR_INPUT
		ce : CacheTrackEssential_Type;
		data : HangerASCII24_Type;
		pBatch : REFERENCE TO USINT;
		idx : USINT;
	END_VAR
END_FUNCTION

FUNCTION ChMirAck : UINT
	VAR_INPUT
		ce : CacheTrackEssential_Type;
		data : HangerASCII24_Type;
		ackBatch : USINT;
		idx : USINT;
	END_VAR
END_FUNCTION

FUNCTION ChMirMarkAll : UINT
	VAR_INPUT
		ce : CacheTrackEssential_Type;
		idx : USINT;
	END_VAR
END_FUNCTION

FUNCTION ChMgrInit : UINT
	VAR_INPUT
		ce : CacheTrackEssential_Type;
		idleMax : UINT;
		sizeMax : UDINT;
	END_VAR
END_FUNCTION

FUNCTION ChMgrCyclic : UINT
	VAR_INPUT
		ce : CacheTrackEssential_Type;
		ctrl : REFERENCE TO UINT;
	END_VAR
END_FUNCTION

FUNCTION ChMgrExit : UINT
	VAR_INPUT
		ce : CacheTrackEssential_Type;
	END_VAR
END_FUNCTION

FUNCTION ChIsNullData : BOOL
	VAR_INPUT
		data : HangerASCII24_Type;
	END_VAR
END_FUNCTION

FUNCTION ChFlgSetUFO : UINT
	VAR_INPUT
		hanger : HangerASCII24_Type;
		state : BOOL;
	END_VAR
END_FUNCTION

FUNCTION ChFlgGetUFO : BOOL
	VAR_INPUT
		hanger : HangerASCII24_Type;
	END_VAR
END_FUNCTION

FUNCTION ChFlgSetValid : UINT
	VAR_INPUT
		hanger : HangerASCII24_Type;
		state : BOOL;
	END_VAR
END_FUNCTION

FUNCTION ChFlgGetValid : BOOL
	VAR_INPUT
		hanger : HangerASCII24_Type;
	END_VAR
END_FUNCTION

FUNCTION ChFlgSetNotFound : UINT
	VAR_INPUT
		hanger : HangerASCII24_Type;
		state : BOOL;
	END_VAR
END_FUNCTION

FUNCTION ChFlgGetNotFound : BOOL
	VAR_INPUT
		hanger : HangerASCII24_Type;
	END_VAR
END_FUNCTION

FUNCTION ChFlgSetDBData : UINT
	VAR_INPUT
		hanger : HangerASCII24_Type;
		state : BOOL;
	END_VAR
END_FUNCTION

FUNCTION ChFlgGetDBData : BOOL
	VAR_INPUT
		hanger : HangerASCII24_Type;
	END_VAR
END_FUNCTION

FUNCTION ChFlgSetAllocate : UINT
	VAR_INPUT
		hanger : HangerASCII24_Type;
		state : BOOL;
	END_VAR
END_FUNCTION

FUNCTION ChFlgGetAllocate : BOOL
	VAR_INPUT
		hanger : HangerASCII24_Type;
	END_VAR
END_FUNCTION

FUNCTION ChFlgSetBadFeed : UINT
	VAR_INPUT
		hanger : HangerASCII24_Type;
		state : BOOL;
	END_VAR
END_FUNCTION

FUNCTION ChFlgGetBadFeed : BOOL
	VAR_INPUT
		hanger : HangerASCII24_Type;
	END_VAR
END_FUNCTION

FUNCTION ChMirUpdate : UINT
	VAR_INPUT
		ce : CacheTrackEssential_Type;
		data : HangerASCII24_Type;
		ackBatch : USINT;
		idx : USINT;
	END_VAR
END_FUNCTION
