#include <sys/types.h>
#include <dirent.h>
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

PlBool dir_file(char *dir, PlLong *file) {
	DIR *dirp, **cp;
	struct dirent *dp;
	cp = Pl_Get_Choice_Buffer(DIR **);
	if (Pl_Get_Choice_Counter() == 0) {
		if ((dirp = opendir(dir)) == NULL) {
			Pl_No_More_Choice();
			return PL_FALSE;
		}
		*cp = dirp;
	} else
		dirp = *cp;
	
	if ((dp = readdir(dirp)) == NULL) {
		Pl_No_More_Choice();
		closedir(dirp);
		return PL_FALSE;
	}

	*file = Pl_Create_Atom(dp->d_name);
	return PL_TRUE;
}
