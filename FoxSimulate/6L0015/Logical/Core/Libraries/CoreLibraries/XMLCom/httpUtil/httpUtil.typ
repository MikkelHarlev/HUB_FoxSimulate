TYPE
	HTTP_Header_typ : STRUCT
		prio	: UDINT ;
		clen	: UDINT ;
		host	: UDINT ;
		cont	: UDINT ;
		ctype	: UDINT ;
		restlen	: UDINT ;
		res	: ARRAY[0..31] OF USINT ;
	END_STRUCT;
END_TYPE