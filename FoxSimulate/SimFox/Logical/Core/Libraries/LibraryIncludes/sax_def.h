
#ifndef SAX_DEF_H
#define SAX_DEF_H

#ifdef WIN32
#define XML_RPC_API __declspec(dllexport)

#ifndef INT
#define INT		short
#endif
#ifndef UINT
#define UINT	unsigned short
#endif
#ifndef UDINT
#define UDINT	unsigned long
#endif
#ifndef USINT
#define USINT	unsigned char
#endif
#else
#define XML_RPC_API

#ifndef XML_Char_defined
typedef char XML_Char;
#define XML_Char_defined 1
#endif
#endif

/*
	defining the maximal memory a func call my take.
	this includes:
		function name
		all parameters
			simple values
			structs ( which may include arrays again )
			strings
			arrays ( which may include structs again )
	8 are sufficient for very HUGE nested structures

#define MAX_FUNC_CALL_SIZE	8192000
*/
/*
	maximum significancy of function names.
	32 should be fine for IEC
	longer names will be cut!

#define MAX_FUNC_NAME	1024
*/
/*
	maximum number of parameters per function call
	could implement it to be dynamically -> would cost execution time


#define MAX_PARAMS		100
 */
/*
	maximum elements for array
	again, could be dynamic, but in prototype static

#define MAX_ARRAY_SIZE	1024
 */

/*
  Parameters define the preallocated, and therfore maximum size per function call
  for certain elements of the XML-RPC call. For each parameter where 0 is give, the
  "default values will be used. See "documentation above for the default values.

	f_call_size
		defining the maximal memory a func call my take.
		this includes:
			function name
			all parameters
				simple values
				structs ( which may include arrays again )
				strings
				arrays ( which may include structs again )
		all following arguments will be allocated from the buffer allocated above
	f_name_len
		maximum significancy of function names.
		32 should be fine for IEC, longer names will be cut!
	p_num
		maximum number of parameters per function call
		could implement it to be dynamically -> would cost execution time
	a_elem
		maximum elements for array and structs ( members)
		again, could be dynamic, but in prototype static
 */
XML_RPC_API UDINT	initSAX			( UDINT f_call_size, UINT f_name_len, UINT p_num, UINT a_elem );

/*
	call closeSAX with the return value of initSAX
*/
XML_RPC_API void	closeSAX		( UDINT handle );


/*
 *	reset the SAX parser after an error condition to clean initial state
 */

XML_RPC_API void	resetSAX		( UDINT handle );


/*
 *	set the response call back function for ONE session only
 *	will be reset automatically for the next parse session
 *  type and data can be set to an "origin" information for
 *	finally called function. This will help the CB function
 *	have the context who initiated the parse process.
 */
XML_RPC_API void	setSingleRespCB	( UDINT handle, UDINT cb, USINT type, UDINT data );

/*
 *	set the ident for the call back function needed to
 *	write an answer to the client
 */

void	setSAXcbIdent( UDINT handle, UDINT ident );

/*
	ask sax if finished parsing the file
*/

XML_RPC_API USINT	finishedSAX		( UDINT handle );

/*
	will return true, if have to send a response
	if false, no response needed
*/
XML_RPC_API USINT	responseSAX		( UDINT handle );

XML_RPC_API void	charHandler		( void *userData, const XML_Char *s, int len );
XML_RPC_API void	endElement		( void *userData, const char *name );
XML_RPC_API void	startElement	( void *userData, const char *name, const char **atts );

#endif /*SAX_DEF_H*/


