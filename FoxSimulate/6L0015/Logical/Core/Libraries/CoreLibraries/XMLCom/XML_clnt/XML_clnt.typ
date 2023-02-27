TYPE
	XML_sendint_typ : STRUCT
		already_sent	: UDINT ;
		headerlen	: UDINT ;
		header	: STRING[200] ;
		header_gen	: BOOL ;
		finished	: BOOL ;
		step	: USINT ;
	END_STRUCT;
	XML_send_typ : STRUCT
		data_ptr	: UDINT ;
		len	: UDINT ;
		priority	: USINT ;
		internal	: XML_sendint_typ ;
	END_STRUCT;
	XML_readint_typ : STRUCT
		read_step	: UDINT ;
		next_buffer	: UDINT ;
		headstat	: USINT ;
		head	: HTTP_Header_typ ;
	END_STRUCT;
	XML_read_typ : STRUCT
		buffer	: UDINT ;
		size	: UDINT ;
		internal	: XML_readint_typ ;
	END_STRUCT;
END_TYPE