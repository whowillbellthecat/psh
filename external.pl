:- op(100, fx, vi).
:- op(100, fx, make).

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
