:- op(100, fx, vi).
:- op(100, fx, make).
:- op(100, fx, file).
:- op(100, fx, add).
:- op(100, fx, diff).

% todo : vi/2 should spawn vi with a temporary file, and then unify the 2nd var with contents of that file.
%    by default as a list of lines but possibly consider vi/3 with an early param specifying the mode/interpretation

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
diff [X|Xs] :- spawn(git, [diff,X|Xs]).
diff X :- atom(X), spawn(git, [diff,X]).
(diff) :- spawn(git, [diff]).
