:- op(100, fx, vi).
:- op(100, fx, make).
:- op(100, fx, file).
:- op(100, fx, add).
:- op(100, fx, diff).
:- op(100, fx, man).

cmd(X,Y) :- atom_join(X,' ',C), popen(C,read,S), slurp(S,Y), close(S).

% is it possible to always detect when I want to interpret first arg as codes vs filename vs prolog terms?
% I should consider folding ivi/edit/vi into the fewer predicates.
vi(C,F) :- number(C),atom(F), write_to_atom(A,C), spawn(vi,['-c',A,F]).
vi(F,M) :- atom(F), var(M), cat(F, A), vi(A,M).
vi(D,M) :- \+ atom(D),temporary_file('',psh_,T),open(T,write,S),maplist(println(S),D),close(S),vi T,cat(T,M),unlink(T),!.
vi F :- spawn(vi, [F]).
(vi) :- spawn(vi, []).

ivi(D,M) :- temporary_file('',psh_,T),open(T,write,S),maplist(portray_clause(S),D),close(S),vi T, open(T,read,S0),
	readall(S0,M),close(S0),unlink(T),!.

%is using an atom as the response appropriate here?
file(X,M) :- atom_concat('file ',X,C), popen(C,read,S), gets(S,M0), close(S),atom_codes(M,M0).
file(X) :- spawn(file, [X]).

make install :- spawn(doas, [make, install]), !.
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

less(M) :- popen(less,write,S),maplist(println(S),M),close(S).
man(M) :- spawn(man,[M]).
