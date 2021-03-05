:- op(399,xfy,++).
:- op(399,xfy,dot).

endswith(E,A) :- atom_concat(_,E,A).
startswith(S,A) :- atom_concat(S,_,A).

atom_resolve(X,X) :- atom(X), !.
atom_resolve(X,Y) :- callable(X), call(X,Y), atom(Y).

++(X,Y,R) :- atom_resolve(X,X0), atom_resolve(Y,Y0), atom_concat(X0,Y0,R).
X++Y :- X++Y <> (=).

dot(X,Y,R) :- R <- X++'.'++Y.
X dot Y :- X dot Y <> (=).
