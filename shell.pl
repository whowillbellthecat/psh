(rm)/1 ?> 'remove file X'.
rm X => ( directory(X) -> delete_directory(X) ; unlink(X) ).

(mv)/2 ?> 'rename file X to Y'.
X mv Y => rename_file(X,Y).

(mkdir)/1 ?> 'create a directory named X'.
mkdir X => make_directory(X).

files/2 ?> 'R is a file in X (choice points used to enumerate files; unless all choice points are visited, X is never closed)'.
files(X), [R] => dir_file(X,R).
