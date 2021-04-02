rm X => ( directory(X) -> delete_directory(X) ; unlink(X) ).
X mv Y => rename_file(X,Y).
mkdir X => make_directory(X).

files(X), [R] => dir_file(X,R).
