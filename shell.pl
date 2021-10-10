(rm)/1 ?> 'remove file X'.
rm X => ( directory(X) -> delete_directory(X) ; unlink(X) ).

(mv)/2 ?> 'rename file X to Y'.
X mv Y => rename_file(X,Y).

(mkdir)/1 ?> 'create a directory named X'.
mkdir X => make_directory(X).

files/2 ?> 'R is a file in X (choice points used to enumerate files; unless all choice points are visited, X is never closed)'.
files(X), [R] => dir_file(X,R).

(ls)/2 ?> 'R is a list of atoms containing the names of files in the directory X'.
(ls)/1 ?> 'R is a list of atoms containing the names of flies in the current directory'.
(ls)/1 ?> 'output files in the directory X'.
% @> cmd('./psh',['-c','ls.'],"",T), T0 <- cmd(ls,[],"") &= \+(append(".",_)), sort(T), sort(T0),
%    (T == T0 ; throw(error(test((ls)/1), T == T0))).

(ls)/0 ?> 'output files in the current directory'.

ls(D), [F] => directory_files(D,T), exclude(hidden_file_path,T,F).
ls O :- var(O), !, ls('.',O).
ls D :- nonvar(D), columnize_if_tty <-- ls(D).
(ls) :- ls '.'.
