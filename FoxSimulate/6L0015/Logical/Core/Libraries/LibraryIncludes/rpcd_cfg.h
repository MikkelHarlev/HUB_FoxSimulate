#ifndef RPCD_CFG_H
#define RPCD_CFG_H

/* define needed for SockLayer.h to avoid fixing clib name collisions */
#define NO_CPORT 266

#define RPC2_DIAG 1
#define MAX_AGENTS	32

#ifndef WIN32
#define RPC_ASSERT( exp ) ( (!(exp)) ? ERRxfatal( 0xC390, 0, #exp ) : 0 )
#include <bur/plctypes.h>

#ifndef true
#define true TRUE
#endif

#ifndef false
#define false FALSE
#endif

#define BR_AR 2.3
#define CAST (UDINT)
#else
#define RPC_ASSERT( exp ) ( (!exp) ? assert( exp ) : 0 )

#define CAST
typedef unsigned char plcbit;
typedef unsigned long plctime;
typedef unsigned long plcdt;
typedef char plcstring;
typedef  plcbit          BOOL;
typedef  signed char     SINT;
typedef  signed short    INT;
typedef  signed long     DINT;
typedef  unsigned char   USINT;
typedef  unsigned short  UINT;
typedef  unsigned long   UDINT;
typedef  float           REAL;
typedef  plctime         TIME;
typedef  plcdt           DT;
typedef  plcdt           DATE_AND_TIME;
typedef  plcstring       STRING;
#endif


#ifndef TRUE
#define TRUE ( 1==1 )
#endif

#ifndef FALSE
#define FALSE ( !TRUE )
#endif



#endif


