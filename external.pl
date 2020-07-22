:- op(800, fx, vi).

% todo : vi/2 should spawn vi with a temporary file, and then unify the 2nd var with contents of that file.
%    by default as a list of lines but possibly consider vi/3 with an early param specifying the mode/interpretation

vi F :- spawn(vi, [F]).
(vi) :- spawn(vi, []).
