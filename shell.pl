(rm)/1 ?> 'remove file X'.
rm X => ( directory(X) -> delete_directory(X) ; unlink(X) ).

(mv)/2 ?> 'rename file X to Y'.
X mv Y => rename_file(X,Y).

(mkdir)/1 ?> 'create a directory named X'.
mkdir X => make_directory(X).

files/2 ?> 'R is a file in X (choice points used to enumerate files; unless all choice points are visited, X is never closed)'.
files(X), [R] => dir_file(X,R).

help((ls)/2, 'unify R with a list of atoms containing the names of files in the directory X').
help((ls)/1, 'unify R with a list of atoms containing the names of files in the current directory').
help((ls)/1, 'output files in the directory X').
help((ls)/0, 'output files in the current directory').

ls(D), [F] => directory_files(D,T), exclude(hidden_file_path,T,F).
ls O :- var(O), !, ls('.',O).
ls D :- nonvar(D),ls(D,F),columnize(F,R),maplist(println,R).
(ls) :- ls '.'.
