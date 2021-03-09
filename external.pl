:- op(401, fx, vi).
:- op(401, fx, ed).
:- op(100, fx, make).
:- op(401, fx, file).
:- op(100, fx, add).
:- op(100, fx, diff).
:- op(100, fx, man).

cmd(X,Y) :- atom_join(X,' ',C), popen(C,read,S), slurp(S,Y), close(S).

ied(D,M) :- temporary_file('',psh_,T),open(T,write,S),maplist(portray_clause(S),D),close(S),ed T, open(T,read,S0),
	readall(S0,M),close(S0),unlink(T),!.

ed(C,F) :- number(C), !, atom(F), write_to_atom(A,C), ed_(A,F).
ed(D,M) :- list(D), !, temporary_file('',psh_,T),open(T,write,S),maplist(println(S),D),close(S),ed T,cat(T,M),unlink(T).
ed(F,M) :- atom_resolve(F,F0), var(M), cat(F0, A), ed(A,M).
ed F :- atom_resolve(F,F0), config(editor,E), spawn(E, [F0]).
(ed) :- config(editor, E), spawn(E, []).

ed_(A,F) :- config(editor_line_flag,L), config(editor, E), spawn(E,[L,A,F]).
ed_(_,F) :- ed F.

file(X,M) :- atom_resolve(X,X0), atom_concat('file ',X0,C), popen(C,read,S), gets(S,M0), close(S),atom_codes(M,M0).
file(X) :- atom_resolve(X,X0), spawn(file, [X0]).

make install :- !, config(sudo_cmd, S), spawn(S, [make, install]).
make T :- atom(T), spawn(make, [T]).
(make) :- spawn(make, []).

clear :- spawn(clear,[]).

commit :- spawn(git, [commit]).
status :- spawn(git, [status,'-s']).
add [X|Xs] :- spawn(git, [add,X|Xs]).
add X :- atom(X), spawn(git, [add,X]).
diff [X|Xs] :- spawn(git, ['-P',diff,X|Xs]).
diff X :- atom(X), spawn(git, ['-P',diff,X]).
(diff) :- spawn(git, ['-P',diff]).
push :- spawn(git, [push]).

log(D,M) :- nonvar(D),atom_concat('--git-dir=',D,T),atom_join([git,T,'-P',log,'--oneline'],' ',C),popen(C,read,S),slurp(S,M),close(S).
log(D) :- nonvar(D), atom_concat('--git-dir=',D,T), spawn(git,[T,'-P',log,'--oneline']).
log(M) :- var(M),atom_join([git,'-P',log,'--oneline'],' ',C), popen(C,read,S), slurp(S,M),close(S).
log :- spawn(git, ['-P',log, '--oneline']).

less(M) :- list(M),!,popen(less,write,S),maplist(println(S),M),close(S).
less(M) :- atom_resolve(M,M0),spawn(less,[M0]).
man(M) :- spawn(man,[M]).
