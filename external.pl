%% todo: the spawn/cmd/etc. predicates need to be cleaned up. Each has different limitations. Luckily,
%% my_spawn/3 provides the basis for unifying them (eventually).

my_spawn(X,Args,Status) :- fork_prolog(N),
        (  N == 0
        -> new_pgid, prolog_pid(P0), tcsetpgrp(0,P0), do_exec(X,Args)
        ;  tcsetpgrp(0, N), wait(N,Status), prolog_pid(P), tcsetpgrp(0, P)).
my_spawn(X,Args) :- my_spawn(X,Args,0).

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

ied(D,M) :- temporary_file('',psh_,T),open(T,write,S),maplist(portray_clause(S),D),close(S),ed T, open(T,read,S0),
	readall(S0,M),close(S0),unlink(T),!.

ed(C,F) :- number(C), !, atom(F), write_to_atom(A,C), ed_(A,F).
ed(D,M) :- list(D), !, temporary_file('',psh_,T),open(T,write,S),maplist(println(S),D),close(S),ed T,cat(T,M),unlink(T).
ed(F), [M] => var(M), cat(F, A), ed(A,M).
ed F => config(editor,E), spawn(E, [F]).
(ed) :- config(editor, E), spawn(E, []).

ed_(A,F) :- config(editor_line_flag,L), config(editor, E), spawn(E,[L,A,F]).
ed_(_,F) :- ed F.

file(X), [M] => cmd(file,[X],M0), atom_codes(M,M0).
file(X) => spawn(file, [X]).

make T :- T == install, !, config(sudo_cmd, S), spawn(S, [make, install]).
make T :- atom(T), spawn(make, [T]).
(make) :- spawn(make, []).

commit :- spawn(git, [commit]).
status :- spawn(git, [status,'-s']).
add [X|Xs] :- spawn(git, [add,X|Xs]).
add X :- atom(X), spawn(git, [add,X]).
diff [X|Xs] :- spawn(git, ['-P',diff,X|Xs]).
diff X :- atom(X), spawn(git, ['-P',diff,X]).
(diff) :- spawn(git, ['-P',diff]).
push :- spawn(git, [push]).

log(D,M) :- nonvar(D), atom_concat('--git-dir=',D,T), cmd(git, [T,'-P',log,'--oneline'], M).
log(D) :- nonvar(D), atom_concat('--git-dir=',D,T), spawn(git,[T,'-P',log,'--oneline']).
log(M) :- var(M),cmd(git,['-P',log,'--oneline'],M).
log :- spawn(git, ['-P',log, '--oneline']).

less(M) :- list(M),!,popen(less,write,S),maplist(println(S),M),close(S).
less(M) => spawn(less,[M]).

man(M) :- spawn(man,[M]).
