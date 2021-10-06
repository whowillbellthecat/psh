% crude but effective. lists undocumented and untested predicates. intended to be consulted if working on psh (add to pshrc).
% this does not get built as part of psh

no_docs :-
	maplist(println) <-- columnize <-- sort <-- findall(P/N, (psh_clause_line(P,N,_), \+ psh_meta(P/N,_,_))) <> maplist(swap(write_to_atom)).

no_tests :-
	maplist(println) <-- columnize <-- sort <-- findall(P/N, (psh_clause_line(P,N,_), (\+ psh_meta(P/N,_,_) ; \+ psh_meta(P/N,_,L), L \= []))) <> maplist(swap(write_to_atom)).
