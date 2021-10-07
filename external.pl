:- dynamic(psh_job_record/2).
%% todo: the spawn/cmd/etc. predicates need to be cleaned up. Each has different limitations. Luckily,
%% my_spawn/3 provides the basis for unifying them (eventually).

my_spawn(X,Args,Status,fg) :- fork_prolog(N),
        (  N == 0
        -> new_pgid, prolog_pid(P0), tcsetpgrp(0,P0), do_exec(X,Args)
        ;  tcsetpgrp(0, N), job_wait(N,Status) ).
my_spawn(X,Args,Status,bg) :- fork_prolog(N), (  N == 0 -> new_pgid, do_exec(X,Args) ; true ).
my_spawn(X,Args,Status) :- my_spawn(X,Args,Status,fg).
my_spawn(X,Args) :- my_spawn(X,Args,0), Args \= signaled.


job_wait/2 ?> 'Y is the wait status of process X; this predicate is job-control-aware'.
job_wait(Pid,Status) :-
	pwait(Pid,Mode,Status), prolog_pid(P), tcsetpgrp(0, P),
	(  Mode == stopped
	-> asserta(psh_job_record(stopped,Pid))
	;  true ).

fg/2 ?> 'Y is the wait status of pgid X after resuming the job'.
fg(Pid,Status) :- retract(psh_job_record(stopped, Pid)), send_signal(Pid,'SIGCONT'), tcsetpgrp(0, Pid), job_wait(Pid,Status).
fg/1 ?> 'resume pgid X in the foreground; false if pgid X terminates with nonzero exit status'.
fg(Pid) :- fg(Pid, 0).

bg/1 ?> 'resume pgid X in the background'.
bg(Pid) :- retract(psh_job_record(stopped, Pid)), send_signal(Pid,'SIGCONT'). %% todo: track background processes (and when they terminate)

bg/0 ?> 'resume last process in background'.
bg :- psh_job_record(stopped,T), !, bg(T).
bg :- puts('No matching job').

fg/0 ?> 'resume last process in foreground'.
fg :- psh_job_record(stopped,T), !, fg(T).
fg :- puts('No matching job').

cmd(Comm,Args,Output) :- spawn(Comm,Args,InW,OutR,ErrR), close(InW), close(ErrR), slurp(OutR, Output), close(OutR).
cmd(Comm,Args,Input,Output) :-
	spawn(Comm,Args,InW,OutR,ErrR),
	close(ErrR),
        maplist(println(InW), Input),
	close(InW),
        slurp(OutR, Output),
	close(OutR).

spawn(Comm, Args, InW, OutR, ErrR) :-
	create_pipe(InR, InW), create_pipe(OutR,OutW), create_pipe(ErrR,ErrW),
	fork_prolog(N),
	(   N == 0
	-> ( close(InW), close(OutR), close(ErrR),
	     spawn_(Comm, Args, InR, OutW, ErrW),
	     halt ; halt )
	;   close(InR), close(OutW), close(ErrW) ).

spawn_(Comm,Args,'$stream'(In),'$stream'(Out),'$stream'(Err)) :-
	force_set(0, In),
	force_set(1, Out),
	force_set(2, Err),
	spawn(Comm, Args).

ied/2 ?> 'Y is a list of terms contained in a temporary file initialized with the contents of the list of terms X after being edited in editor'.
ied(D,M) :- temporary_file('',psh_,T),open(T,write,S),maplist(portray_clause(S),D),close(S),ed T, open(T,read,S0),
	readall(S0,M),close(S0),unlink(T).

(ed)/2 ?> 'if X is a number and Y is an atom representing a file path, then open file Y at line X in editor'.
(ed)/2 ?> 'Y is a list of lines (as codes) containing the result of editing a temporary file initialized with X (a list of lines (as codes))'.
(ed)/2 ?> 'X is a file path, Y is a list of lines (as codes) containing the result of editing the file at X with editor'.
ed(C,F) :- number(C), !, atom(F), write_to_atom(A,C), ed_(A,F).
ed(D,M) :- list(D), !, temporary_file('',psh_,T),open(T,write,S),maplist(println(S),D),close(S),ed T,cat(T,M),unlink(T).
ed(F), [M] => var(M), cat(F, A), ed(A,M).

(ed)/1 ?> 'edit file given by path X with editor'.
ed F => config(editor,E), my_spawn(E, [F]).

(ed)/0 ?> 'run editor'.
(ed) :- config(editor, E), my_spawn(E, []).

ed_(A,F) :- config(editor_line_flag,L), config(editor, E), my_spawn(E,[L,A,F]).
ed_(_,F) :- ed F.

(file)/2 ?> 'R is an atom containing the file type given by file(1) for the file given by the path expression X'.
file(X), [M] => cmd(file,[X],M0), atom_codes(M,M0).

(file)/1 ?> 'run file(1) on the file given by the path expression X'.
file(X) => spawn(file, [X]).

make T :- T == install, !, config(sudo_cmd, S), spawn(S, [make, install]).
make T :- atom(T), spawn(make, [T]).
(make) :- spawn(make, []).

commit/0 ?> 'git commit'.
commit :- spawn(git, [commit]).

status/0 ?> 'git status'.
status :- spawn(git, [status,'-s']).

(add)/1 ?> 'git add the file represented by path expression X'.
add X => spawn(git, [add,X]).

(diff)/1 ?> 'git -P diff X, where X is a path expression'.
diff X => spawn(git, ['-P',diff,X]).

(diff)/0 ?> 'git -P diff'.
(diff) :- spawn(git, ['-P',diff]).

(push)/0 ?> 'git push'.
push :- spawn(git, [push]).

log/2 ?> 'Y is a list of lines (as codes) with the git log for the repository given by path expression X'.
log(D), [M] => atom_concat('--git-dir=',D,T), cmd(git, [T,'-P',log,'--oneline'], M).

log/1 ?> 'output git log data if X is a path expression'.
log/1 ?> 'X is a list of lines (as codes) with the git log data for the current directory'.
log(D) => !, atom_concat('--git-dir=',D,T), spawn(git,[T,'-P',log,'--oneline']).
log(M) :- var(M),cmd(git,['-P',log,'--oneline'],M).

log/0 ?> 'output git log data for the current directory'.
log :- spawn(git, ['-P',log, '--oneline']).

less(M) :- list(M),!,popen(less,write,S),maplist(println(S),M),close(S).
less(M) => spawn(less,[M]).

(man)/1 ?> 'display the man page for X where X is an atom or a pair Section-PageName'.
man(M) :- atom(M), !, spawn(man,[M]).
man(Section-Page) :- number(Section), atom(Page), spawn(man,[Section,Page]).
