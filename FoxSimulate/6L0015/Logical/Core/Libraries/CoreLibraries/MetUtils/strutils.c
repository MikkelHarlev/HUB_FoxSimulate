/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*\
| strutils.c : functions to format strings																		 |
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Version 1.0 NS19990701																						 |
+················································································································+
| No documentation provided. Those functions were taken from a Linux system source archive and 'striped' to fit	 |
| the requirements of the MetPLC system. The user may basicaly only be interested in the 'sprintf' function,	 |
| whitch behaves as described in the ANSI C specification. Please refer to this documentation for more			 |
| information.																									 |
| Version 1.1 SF20040928																						 |
+················································································································+
| New version or AR checks for double functions. So Metric sprintf has been renamed to metsprintf.				 |
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/

#include <stdarg.h>
#include <string.h>
#include <ctype.h>

#include <metutils.h>

/*———[ Constants ]——————————————————————————————————————————————————————————————————————————————————————————————*/

#define MKStrUtilsVersion	"V01.00"							/* version definition for init log				*/

#define ZEROPAD				1									/* pad with zero								*/
#define SIGN				2									/* unsigned/signed long							*/
#define PLUS				4									/* show plus									*/
#define SPACE				8									/* space if plus								*/
#define LEFT				16									/* left justified								*/
#define SPECIAL				32									/* 0x											*/
#define LARGE				64									/* use 'ABCDEF' instead of 'abcdef'				*/

/*———[ Macros ]—————————————————————————————————————————————————————————————————————————————————————————————————*/

#define is_digit(c) ((c) >= '0' && (c) <= '9')		/* we use this so that we can do without the ctype library	*/

#define do_div(n,base) ({	int __res; __res = ((unsigned long) n) % (unsigned) base;	\
							n = ((unsigned long) n) / (unsigned) base; __res;			})

/*———[ Methods ]————————————————————————————————————————————————————————————————————————————————————————————————*/

_BUR_PUBLIC int metsprintf( char * buf, const char *fmt, ... )
{
	va_list args;
	int i;

	va_start(args, fmt);
	i=metvsprintf(buf,fmt,args);
	va_end(args);
	return i;
}
/*··············································································································*/
_BUR_PUBLIC size_t strnlen( const char * s, size_t count )
{
	const char *sc;

	for (sc = s; count-- && *sc != '\0'; ++sc);
	return sc - s;
}
/*··············································································································*/
_BUR_PUBLIC unsigned long simple_strtoul( const char *cp, char **endp, unsigned int base )
{
	unsigned long result = 0,value;
	if (!base)
	{
		base = 10;
		if (*cp == '0')
		{
			base = 8;
			cp++;
			if ((*cp == 'x') && isxdigit((int)(cp[1])))
			{
				cp++;
				base = 16;
			}
		}
	}
	while (	isxdigit((int)*cp) &&
			(value= isdigit((int)*cp) ? *cp-'0' : (islower((int)*cp) ? toupper(*cp) : *cp)-'A'+10)<base )
	{
		result = result*base + value;
		cp++;
	}
	if (endp) *endp = (char *)cp;
	return result;
}
/*··············································································································*/
int skip_atoi(const char **s)
{
	int i=0;

	while (is_digit(**s))
		i = i*10 + *((*s)++) - '0';
	return i;
}
/*··············································································································*/
char * number( char * str, long num, int base, int size, int precision, int type )
{
	char c,sign,tmp[66];
	const char *digits="0123456789abcdefghijklmnopqrstuvwxyz";
	int i;

	if (type & LARGE) digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	if (type & LEFT) type &= ~ZEROPAD;
	if (base < 2 || base > 36) return 0;
	c = (type & ZEROPAD) ? '0' : ' ';
	sign = 0;
	if (type & SIGN)
	{
		if (num < 0) {
			sign = '-';
			num = -num;
			size--;
		} else if (type & PLUS)	{
			sign = '+';
			size--;
		} else if (type & SPACE) {
			sign = ' ';
			size--;
		}
	}
	if (type & SPECIAL)
	{
		if (base == 16) size -= 2;
		else if (base == 8) size--;
	}
	i = 0;
	if (num == 0) tmp[i++]='0';
	else while (num != 0)
		tmp[i++] = digits[do_div(num,base)];
	if (i > precision) precision = i;
	size -= precision;
	if (!(type&(ZEROPAD+LEFT))) while(size-->0) *str++ = ' ';
	if (sign) *str++ = sign;
	if (type & SPECIAL)
	{
		if (base==8)
			*str++ = '0';
		else
			if (base==16)
			{
				*str++ = '0';
				*str++ = digits[33];
			}
	}
	if (!(type & LEFT)) while (size-- > 0) *str++ = c;
	while (i < precision--) *str++ = '0';
	while (i-- > 0) *str++ = tmp[i];
	while (size-- > 0) *str++ = ' ';
	return str;
}
/*··············································································································*/
_BUR_PUBLIC int strtrimend(char* instr)
{
	int i = strlen(instr);
	while (i > 0 && instr[i-1] == ' ')	/* Search for space ' ' */
	{
		instr[i-1] = 0;					/* terminate string */
		i--;
	}
	return i;
}

/*··············································································································*/
_BUR_PUBLIC int metvsprintf( char *buf, const char *fmt, va_list args )
{
	int len;
	unsigned long num;
	int i, base;
	char * str;
	const char *s;
	int flags;													/* flags to number()							*/
	int field_width;											/* width of output field						*/
	int precision;						/* min. # of digits for integers; max number of chars for from string	*/
	int qualifier;												/* 'h', 'l', or 'L' for integer fields			*/

	for (str=buf ; *fmt ; ++fmt)
	{
		if (*fmt != '%')
		{
			*str++ = *fmt;
			continue;
		}

		flags = 0;												/* process flags								*/
repeat:
		++fmt;													/* this also skips first '%'					*/
		switch (*fmt)
		{
			case '-': flags |= LEFT; goto repeat;
			case '+': flags |= PLUS; goto repeat;
			case ' ': flags |= SPACE; goto repeat;
			case '#': flags |= SPECIAL; goto repeat;
			case '0': flags |= ZEROPAD; goto repeat;
		}

		field_width = -1;										/* get field width								*/
		if (is_digit(*fmt)) field_width = skip_atoi(&fmt);
		else if (*fmt == '*')
		{
			++fmt;
			field_width = va_arg(args, int);					/* it's the next argument						*/
			if (field_width < 0)
			{
				field_width = -field_width;
				flags |= LEFT;
			}
		}

		precision = -1;											/* get the precision							*/
		if (*fmt == '.')
		{
			++fmt;
			if (is_digit(*fmt)) precision = skip_atoi(&fmt);
			else if (*fmt == '*')
			{
				++fmt;
				precision = va_arg(args, int);					/* it's the next argument						*/
			}
		if (precision < 0) precision = 0;
	}

	qualifier = -1;												/* get the conversion qualifier					*/
	if (*fmt == 'h' || *fmt == 'l' || *fmt == 'L')
	{
		qualifier = *fmt;
		++fmt;
	}

	base = 10;													/* default base									*/

	switch (*fmt)
	{
		case 'c':
			if (!(flags & LEFT)) while (--field_width > 0) *str++ = ' ';
			*str++ = (unsigned char) va_arg(args, int);
			while (--field_width > 0) *str++ = ' ';
			continue;
		case 's':
			s = va_arg(args, char *);
			if (!s) s = "<NULL>";
			len = strnlen(s, precision);
			if (!(flags & LEFT)) while (len < field_width--) *str++ = ' ';
			for (i = 0; i < len; ++i) *str++ = *s++;
			while (len < field_width--) *str++ = ' ';
			continue;
		case 'p':
			if (field_width == -1)
			{
				field_width = 2*sizeof(void *);
				flags |= ZEROPAD;
			}
			str = number( str, (unsigned long) va_arg(args, void *), 16, field_width, precision, flags );
			continue;
		case 'n':
			if (qualifier == 'l') {
				long * ip = va_arg(args, long *);
				*ip = (str - buf);
			} else {
				int * ip = va_arg(args, int *);
				*ip = (str - buf);
			}
			continue;
		/* integer number formats - set up the flags and "break" */
		case 'o':
			base = 8;
			break;
		case 'X':
			flags |= LARGE;
		case 'x':
			base = 16;
			break;
		case 'd': case 'i':
			flags |= SIGN;
		case 'u':
			break;
		default:
			if (*fmt != '%') *str++ = '%';
			if (*fmt) *str++ = *fmt;
			else --fmt;
			continue;
	}
	if (qualifier == 'l')
		num = va_arg(args, unsigned long);
	else {
		if (qualifier == 'h') {
			if (flags & SIGN)
				num = (short)va_arg(args, int); // int instead of short since short args will be automatically promoted to int on the stack
			else
				num = (unsigned short)va_arg(args, unsigned int); // same thing here but unsigned
		} else {
			if (flags & SIGN)
				num = va_arg(args, int);
			else
				num = va_arg(args, unsigned int);
		}
	}
	str = number(str, num, base, field_width, precision, flags);
	}
	*str = '\0';
	return str-buf;
}
/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/
