:- op(402, fx, rm).
:- op(402, xfy, mv).
:- op(402, fx, mkdir).

rm(X) => ( directory(X) -> delete_directory(X) ; unlink(X) ).
mv(X,Y) => rename_file(X,Y).
mkdir(X) => make_directory(X).
