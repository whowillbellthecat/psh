#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/wait.h>
#include <dirent.h>
#include <signal.h>
#include <termios.h>
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


PlBool tty_dim(PlLong *width, PlLong *height) {
        struct winsize ws;
        if (ioctl(0, TIOCGWINSZ, &ws) != 0)
		 Pl_Err_System(Pl_Create_Atom("could not get terminal size"));
	*width = ws.ws_col;
	*height = ws.ws_row;
        return PL_TRUE;
}

void handler(int sig) { }

PlBool pass_sigint() {
	signal(SIGINT, handler);
	return PL_TRUE;
}

PlBool new_pgid() {
	pid_t pid;
	pid = getpid();
	if (setpgid(pid, pid) == 0)
		return PL_TRUE;
	return PL_FALSE;
}

PlBool pl_tcsetpgrp(PlLong fd, PlLong pgrp_id) {
	tcsetpgrp(fd, pgrp_id);
	return PL_TRUE;
}

PlBool c_read(PlLong fd, PlTerm *codes) {
	char buf[4];
	int n;
	n = read(fd, buf, 3);
	buf[n] = 0;
	if (n>0)
		*codes = Pl_Mk_Codes(buf);
	else if (n == 0)
		*codes = Pl_Mk_Code(-1);
	else
		return PL_FALSE;
	return PL_TRUE;
}

PlBool tcsetvtime(PlLong vtime) {
	struct termios *tp;
	tcgetattr(0, tp);
	tp->c_cc[VTIME] = vtime;
	tcsetattr(0, TCSANOW, tp);
	return PL_TRUE;
}

PlBool do_exec(char *comm, PlTerm args) {
	int n,i;
	PlTerm array[20];
	n = Pl_Rd_Proper_List_Check(args, array);
	char *my_args[n+2];
	my_args[0] = comm;
	for(i=1;i<=n;i++) {
		my_args[i] = Pl_Rd_String_Check(array[i-1]);
	}
	my_args[i] = 0;
	execvp(comm, my_args);
}

PlBool pwait(PlLong pid, PlLong *mode, PlLong *status) {
	pid_t p;
	int n;
	p = waitpid(pid, &n, WUNTRACED);
	if (WIFSTOPPED(n)) {
		*mode = Pl_Create_Atom("stopped");
		*status = 0;
	} else if (WIFEXITED(n)) {
		*mode = Pl_Create_Atom("exited");
		*status = WEXITSTATUS(n);
	} else if (WIFSIGNALED(n)) {
		*mode = Pl_Create_Atom("signaled");
		*status = WTERMSIG(n);
	} else
		Pl_Err_System(Pl_Create_Atom("unknown wait status -something went very wrong"));
	return PL_TRUE;
}
