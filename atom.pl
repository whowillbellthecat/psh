endswith(E,A) :- atom_concat(_,E,A).
startswith(S,A) :- atom_concat(S,_,A).
