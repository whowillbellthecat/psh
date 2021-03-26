:- op(402, fx, rm).
:- op(402, xfy, mv).
:- op(402, fx, mkdir).
:- op(402, fx, rmdir).

rm X :- atom_resolve(X,X0), unlink(X0).

X mv Y :- atom_resolve(X,X0), atom_resolve(Y,Y0), rename_file(X0,Y0).
mkdir X :- atom_resolve(X,X0), make_directory(X0).
rmdir X :- atom_resolve(X,X0), delete_directory(X0).
