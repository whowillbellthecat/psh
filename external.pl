:- op(100, fx, vi).
:- op(100, fx, make).
:- op(100, fx, file).
:- op(100, fx, add).
:- op(100, fx, diff).

vi(F,M) :- temporary_file('',psh_,T), cat(F, A), open(T,write,S), maplist(println(S),A), close(S), vi T, cat(T,M), unlink(T).
vi F :- spawn(vi, [F]).
(vi) :- spawn(vi, []).

%is using an atom as the response appropriate here?
file(X,M) :- atom_concat('file ',X,C), popen(C,read,S), gets(S,M0), close(S),atom_codes(M,M0).
file(X) :- spawn(file, [X]).

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

log :- spawn(git, ['-P',log, '--oneline']).
log(M) :- atom_join(['git','-P',log,'--oneline'],' ',C), popen(C,read,S), slurp(S,M),close(S).
