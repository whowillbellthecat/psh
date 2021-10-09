% This file is for psh developement and does not get built with psh. It is intended to be consulted if working on psh (add to pshrc).
% (A more roboust mechanism for its use may eventually be added).


% crude but effective. lists undocumented and untested predicates. intended to be consulted if working on psh (add to pshrc).

no_docs :-
	maplist(println) <-- columnize <-- sort <-- findall(P/N, (psh_clause_line(P,N,_), \+ psh_meta(P/N,_,_))) <> maplist(swap(write_to_atom)).

no_tests :-
	maplist(println) <-- columnize <-- sort <-- findall(P/N,
			( psh_clause_line(P,N,_), (\+ psh_meta(P/N,_,_) ; \+ (psh_meta(P/N,_,L), L \= [])))) <> maplist(swap(write_to_atom)).

spellcheck :- spellcheck([]).

spellcheck(R) :-
        findall(H, psh_meta(_/_,H,_),X),
        maplist(atom_codes,X,X0),
        T <- cmd(spell,[],X0) &= spellcheck_,
	maplist(atom_codes,R,T).

spellcheck_([X|Xs]) :- \+ (X #>= 65, X #=< 90), spellcheck_(Xs).
spellcheck_([]).
