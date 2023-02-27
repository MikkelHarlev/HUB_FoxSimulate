#ifndef BR_RPCD_H
#define BR_RPCD_H

#include "rpcd_cfg.h"


typedef UDINT	rpcident_t;		/* ident for communication with rpc user fb */
typedef DINT	rpstat_t;		/* status of rpc cb funcs					*/
typedef UDINT rpcmem_t;		/* free memory back */

typedef enum	{ RUN, WAIT, ERR } rpcd_stat_t;

/*
	rpcident_t : 	ident set by rpclock_cb_t
	UDINT :			ident needed to write back via rpcwrite_cb_t
	const char**:	buffer to parse
	cont UDINT*:	ptr to len of parse buffer
*/
typedef rpstat_t	(rpcproc_cb_t)	( rpcident_t, UDINT, const char** buf, const UDINT* len );
typedef rpstat_t	(rpclock_cb_t)	( rpcident_t* );
typedef rpstat_t	(rpcunlock_cb_t)( rpcident_t  );
typedef rpstat_t	(rpcstat_cb_t)	( rpcident_t  );
typedef rpstat_t	(rpcreset_cb_t)	( rpcident_t  );
/*typedef rpcmem_t  (rpcparsemem_cb_t) ( rpcident_t  );
typedef rpcmem_t  (rpcsaxmem_cb_t) ( rpcident_t  );*/

/* cb func to write answer, no need to generate header, header will be generated automatically */
typedef INT			(rpcwrite_cb_t)	( UDINT, const char*, UDINT );
#ifdef RPCDEBUG
typedef rpstat_t	(rpcdebug_cb_t)	( const char* buf, const UDINT len );
#endif

typedef struct client_cb
{
	rpclock_cb_t*	lock;		/* lock the "resource" == pareser		*/
	rpcproc_cb_t*	process;	/* process the data						*/
	rpcstat_cb_t*	status;		/* check the status of process			*/
	rpcreset_cb_t*	reset;		/* reset the processor					*/
	rpcunlock_cb_t*	unlock;		/* unlock the "resource"				*/
/*	rpcparsemem_cb_t* parsemem;*/	/* get free parser memory */
/*	rpcsaxmem_cb_t* saxmem;		*//* get free sax memory */
#ifdef RPCDEBUG
	rpcdebug_cb_t*	debug;		/* for internal purposes only !!!		*/
#endif
}client_cb_t;

#ifdef RPC2_DIAG
/* diagnostic structure */
typedef struct rpc2_diag
{
	struct connector_vm*	vm;
	DINT 					sockstate[MAX_AGENTS];
}rpc2_diag_t;
#endif

typedef struct rpcd_am
{
	UDINT			port;		/* port to listen to					*/
	UDINT			aprio;		/* priority of agent threads			*/
	UDINT			sprio;		/* priority of system/exceptions		*/
	USINT			nwork;		/* number of working threads (max 64)	*/
	UDINT			dispatch;	/* ident for dispatcher INIT TO 0 !!!   */
	client_cb_t		rpccb;		/* type for call back functon pointers	*/
	UDINT			mmIdent;	/* set to 0 once, and never touch again	*/
	UDINT			sock_max;	/* size of socket send buff computed	*/
#ifdef RPC2_DIAG
	rpc2_diag_t*	diag; 		/* ptr to diagnostic struct, see rpcd.h
														for more details*/
#endif
} rpcd_am_t;

typedef struct rpcd_cfg
{
	UDINT		cprio;		/* priority of connection thread				*/
	BOOL		recover;	/* true if server should recover on error		*/
	rpcd_am_t	mission;	/* mission data for agent threads				*/
} rpcd_cfg_t;


rpcident_t	rpcd_boot( rpcd_cfg_t* cfg );
BOOL		rpcd_kill( rpcident_t );
rpcd_stat_t	rpcd_info( rpcident_t );
INT			rpcwrite ( UDINT ident, const char* cont , UDINT len );

#ifdef RPC2_DIAG
typedef void ( printIdent_t)( UDINT  );
typedef void ( printStr_t)	( const char* , const UDINT );
typedef void ( printNL_t )	( void );
typedef void ( clearScr_t)	( void );

extern void setDebug		( UDINT ident );
extern void debugVM		( USINT, USINT, printIdent_t*, printStr_t*, printNL_t*, clearScr_t* );
extern void debugTHconn	( printIdent_t*, printStr_t*, printNL_t*, clearScr_t* );
extern void debugTHagent	( printIdent_t*, printStr_t*, printNL_t*, clearScr_t* );

#endif /*RPC2_DIAG */



#endif


