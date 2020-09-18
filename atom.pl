:- op(399,xfy,++).

endswith(E,A) :- atom_concat(_,E,A).
startswith(S,A) :- atom_concat(S,_,A).

resolve_atom(X,X) :- atom(X), !.
resolve_atom(X,Y) :- callable(X), call(X,Y), atom(Y).

++(X,Y,R) :- atom(X), atom(Y), atom_concat(X,Y,R).
++(X,Y,R) :- callable(X), call(X,X0), ++(X0,Y,R).
++(X,Y,R) :- callable(Y), call(Y,Y0), ++(X,Y0,R).
X++Y :- X++Y <> (=).
