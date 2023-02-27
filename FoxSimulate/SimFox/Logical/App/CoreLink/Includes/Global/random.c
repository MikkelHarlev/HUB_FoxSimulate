#ifdef _DEFAULT_INCLUDES
	#include <AsDefault.h>
#endif

static unsigned long int suivant = 1;

int rand()
{
	suivant = suivant * 1103515245 + 12345;
	return (unsigned int)(suivant/65536)%32768;
	return 1;
}

void srand(unsigned int amorce)
{
	suivant = amorce;
}


