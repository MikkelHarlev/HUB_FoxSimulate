#ifndef SAX_HASH_H
#define SAX_HASH_H


typedef unsigned long HASH;

#ifdef WIN32
/*typedef char XML_Char;*/
#ifndef UDINT
#define UDINT	unsigned long
#endif
#else
/*typedef XML_Char* KEY;*/
#endif
/*
	MAX_HASH corresponds to the maximum "elements" possibel
	see sax_impl.h for more details
*/
#define MAX_HASH 19

typedef struct hEntry
{
	KEY		name;
	HASH	hash;
}hEntry_t;

/*
hEntry_t	hArray[MAX_HASH];*/

UDINT 			initHash		( void );
int 			getKey			( const char* k );
int				getKey_nodelim	( const char* k, int len );
hEntry_t*		getEntry		( int );
unsigned long	hash_nodelim	( KEY s, int len );

#endif /*SAX_HASH_H*/


