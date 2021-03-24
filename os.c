#include <sys/types.h>
#include <time.h>
#include <unistd.h>
#include <gprolog.h>

PlBool tz(PlLong *t) {
        struct timespec now;
        struct tm *tm;
        if (-1 == clock_gettime(CLOCK_REALTIME, &now))
                return PL_FALSE;
        tm = localtime(&now.tv_sec);
        if(tm == NULL)
                return PL_FALSE;
        *t = tm->tm_gmtoff;
        return PL_TRUE;
}

PlBool force_set(PlLong ofd, PlLong nfd) {
        int i, c;
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
