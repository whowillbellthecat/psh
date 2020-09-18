:- op(399,xfy,++).
:- op(399,xfy,++.).

endswith(E,A) :- atom_concat(_,E,A).
startswith(S,A) :- atom_concat(S,_,A).

atom_resolve(X,X) :- atom(X), !.
atom_resolve(X,Y) :- callable(X), call(X,Y), atom(Y).

++(X,Y,R) :- atom_resolve(X,X0), atom_resolve(Y,Y0), atom_concat(X0,Y0,R).
X++Y :- X++Y <> (=).

++.(X,Y,R) :- R <- X++'.'++Y.
X ++. Y :- X ++. Y <> (=).
