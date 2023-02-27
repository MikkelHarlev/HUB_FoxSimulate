
#ifndef SAX_STACK_H
#define SAX_STACK_H

#ifdef WIN32
#ifndef UDINT
#define UDINT unsigned long
#endif
#else /* BR_AR */
#include <bur/plctypes.h>
#endif

#define MAX_STACK 512

/* shift reduce parsing state */
typedef enum { eShift = 0, eReduce, eUndef } srDir_t;

typedef struct saxStack
{
	int		stack[MAX_STACK];
	int		ptr;
	srDir_t	dir;
} saxStack_t;

saxStack_t*	initSAXstack	( void );
void	resetSAXstack	( saxStack_t* );
int		saxPop			( saxStack_t* );
int		saxPush			( saxStack_t*,int key );
int		saxPrev			( saxStack_t* );
int		saxLKUP			( saxStack_t*,int pos );
int		saxCurr			( saxStack_t* );
srDir_t	saxShiftReduce	( saxStack_t* );
void	closeSAXstack	( saxStack_t*);

extern saxStack_t 	gSStack;

#endif /* SAX_STACK_H */


