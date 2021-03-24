#include <sys/types.h>
#include <time.h>
#include <unistd.h>
#include <gprolog.h>

PlBool tz(PlLong *t) {
	extern long timezone;
	tzset();
	*t = timezone;
	return PL_TRUE;
}

PlBool force_set(PlLong ofd, PlLong nfd) {
        int i, c;
	if (ofd == nfd)
		return PL_TRUE;
        c = close(ofd);
        i = dup(nfd);
        if (i != ofd) {
		c |= close(i);
                return PL_FALSE;
	}
	if (c)
		return PL_FALSE;
	return PL_TRUE;
}
