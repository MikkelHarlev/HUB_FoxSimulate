
#ifndef HTTPSCAN_H
#define HTTPSCAN_H

typedef enum prio { eNOPRIO =-1, eLOWPRIO=0, eHIGHPRIO=1, eSYSPRIO=2, eNOREQUEST=222 } prio_t;

/*
 *	Type to get httpHeader fields.
 *	all fields are output, and will
 *	be initialized in the structure
 */
typedef struct httpHeader
{
	prio_t		prio;	/* priority, -1 == standard	*/
	UDINT		clen;	/* content str len	til end	*/
	const char* host;	/* ptr to host				*/
	const char* cont;	/* ptr to content			*/
	const char* ctype;	/* ptr to content type		*/
	UDINT		restlen;/* size of missing content	*/
	USINT		res[sizeof(UDINT)*8];
} httpHeader_t;


unsigned long httpStripHead	(unsigned long string, unsigned short *len);

/*if content == 0, only header will be generated */
unsigned long httpGenHead	(unsigned long buffer, unsigned long content, unsigned long clen, prio_t prio );

/*	
	this function will return the _real_ len of the header 
	the buffer will be used to genereate the header.
*/
unsigned long httpHeadGen	(unsigned long buffer, unsigned long clen, prio_t prio );

unsigned long httpHeadSetIp (unsigned long ipaddr);


USINT		  httpParseHead	(unsigned long string, unsigned long len, httpHeader_t* head );
#endif /* HTTPSCAN_H */
