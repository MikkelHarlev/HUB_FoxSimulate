TYPE
	XMLPVsinit_int_typ : STRUCT
		rpc2dident	: UDINT ;
		IV_ident	: UDINT ;
		rpc_ident	: UDINT ;
		step	: UDINT ;
	END_STRUCT;
	XMLPVsinit_typ : STRUCT
		ParamModule	: STRING[80] ;
		diag	: xml_diag ;
		internal	: XMLPVsinit_int_typ ;
	END_STRUCT;
END_TYPE