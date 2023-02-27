
#ifndef RPCD_H
#define RPCD_H

#include "br_rpcd.h"

typedef enum	mission_state { AG_BUSY,  AG_WAIT, AG_FREE } mstate_t;
typedef enum	mission_step  { ST_WDATA, ST_PROC } mstep_t;

typedef struct conn
{
	INT             fd;	            /* server's socket fd			*/
    UDINT           addr;	        /* client's socket address		*/
    UINT			port;           /* client's socket port			*/
    char			outaddr[16];	  /* Server's ip address on this port! */
} conn_t;

/*
 * data needed to communicate with the connector thread
 * all access to this elements have to be synchronized
 * via "sync"
 */
typedef struct liveline
{
	UDINT			sync;			/* to synchronize data			*/
	UDINT			disp;			/* dispatcher for thread control*/
	mstate_t		state;			/* state of the "mission"		*/
	UDINT			id;				/* system id of thread			*/
	const USINT		position;		/* agent position in connector  */
} liveline_t;

#define BUFF_SIZE 8192

typedef struct	ag_buff
{
	UDINT		avail;				/* available bytes on socket	*/
	const UINT	cMaxBuff; 			/* const for max size of buffer */
	char*		loc;				/* buffer for getting data per  */
}ag_buff_t;

typedef struct agent
{
	conn_t			io;				/* io information for connection*/
	liveline_t		channel;		/* info to keep in contact with
									   connector thread				*/
	client_cb_t		rpccb;			/* pointer to rpc call back fubs*/
	const char*		agent_name;		/* name of agent for threading	*/
	ag_buff_t		buff;			/* rw buffer for agent read		*/
	UDINT			sock_max;		/* max size of buffers from recv*/
#ifdef RPC2_DIAG
struct rpc2_diag*	diag;			/* diagnostic struct for dbg	*/
#endif
} agent_t;

/*
 *
 *	Agent thread fp type
 *
 */

typedef void agent_cb_t		( agent_t*	mission );

/*
 *
 *	Connector thread fp type
 *
 */
typedef void connector_cb_t	( rpcd_am_t*mission );

/*
 * Maximum number of workers possible
 */

typedef struct connector_vm
{
	agent_t		agents[ MAX_AGENTS ];	/*	array for agents		*/
	USINT		nagents;				/*	number of allowed		*/
	USINT		lagent;					/*	pos of last agent		*/
	mstate_t	state;					/*	connector thread state	*/
}connector_vm_t;


/*
 * now the "real" connector and agend function implementations
 *
 *
 */

void rpcd_agent_thread		( agent_t* mission );
void rpcd_connector_thread	( rpcd_am_t* mission );
void prClrScreen ( void );
void prNewline ( void );
void prString ( char*, UDINT );
void prIdent( UDINT );


UDINT init_agent	( USINT );
UDINT suspend_agent ( agent_t* );


#endif


