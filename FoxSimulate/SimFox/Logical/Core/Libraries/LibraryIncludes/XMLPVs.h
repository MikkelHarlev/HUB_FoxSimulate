/* Automation Studio Generated Header File, Format Version 1.00 */
/* do not change */
#ifndef XMLPVS_H_
#define XMLPVS_H_
#define _WEAK	__attribute__((__weak__))

#include <bur/plctypes.h>



/* Constants */
_WEAK const unsigned short XMLPVS_BUSY = 65535;
_WEAK const unsigned short XMLPVS_NOFUNCTION = 65004;
_WEAK const unsigned short XMLPVS_REGFUNC = 65003;
_WEAK const unsigned short XMLPVS_RPCD = 65004;
_WEAK const unsigned short XMLPVS_WRDATAMOD = 65001;
_WEAK const unsigned short XML_SALLR_INIT = 65000;


/* Datatypes */
typedef struct XMLPVsinit_int_typ
{
	unsigned long rpc2dident;
	unsigned long IV_ident;
	unsigned long rpc_ident;
	unsigned long step;
} XMLPVsinit_int_typ;

typedef struct XMLPVsinit_typ
{
	plcstring ParamModule[80+1];
	xml_diag diag;
	XMLPVsinit_int_typ internal;
} XMLPVsinit_typ;



/* Datatypes of function blocks */


/* Prototyping of functions and function blocks */
signed long XMLPVsinit(unsigned long ident, unsigned long pparam);
signed long XMLPVsportinit(unsigned long ident, unsigned long pparam, unsigned short port);



#endif /* XMLPVS_H_ */

