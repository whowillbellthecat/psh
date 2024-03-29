:- multifile(psh_meta/3).
:- discontiguous(psh_meta/3).
:- dynamic(psh_meta/3).

help/0 ?> 'output available commands'.
help :-
	puts('Please note that psh is very incomplete, with no releases or stable interfaces.'), nl,
	puts('Supported commands: '),
	findall(C/N,psh_meta(C/N,_,_), X),
	columnize_if_tty <-- sort <-- maplist(swap(write_to_atom),X),
	nl,nl,
	write('For help with Command, run help(Command).'), nl.

help/1 ?> 'output documentation for all clauses matching X where X = PrincipalFunctor or X = PrincipalFunctor/Arity'.
help(C) :- atom(C), !, findall(N-H, psh_meta(C/N,H,_), H), keysort(H,H0), forall(member(N-M, H0), put_help_msg(C,N,M)).
help(C/N) :- forall(psh_meta(C/N, H, _), put_help_msg(C,N,H)).

put_help_msg(C,N,M) :- puts(C/N), write('\t'), puts(M), put_source_code(C/N).

put_source_code(C/N) :- config(help_outputs_code, true), !, nl, where(C/N,File), whichline(C/N,Line), puts('Defined in':File:Line), fl +C/N.
put_source_code(C/N).
