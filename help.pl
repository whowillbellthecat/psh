:- multifile(help/2).
:- discontiguous(help/2).
:- dynamic(help/2).

:- multifile(psh_meta/3).
:- discontiguous(psh_meta/3).
:- dynamic(psh_meta/3).

help :-
	puts('Please note that psh is very incomplete, with no releases or stable interfaces.'), nl,
	puts('Supported commands: '),
	findall(C/N,(help(C/N,_) ; psh_meta(C/N,_,_)), X),
	maplist(println) <-- maplist(swap(write_to_atom),X) <> columnize,
	nl,nl,
	write('For help with Command, run help(Command).'), nl.

help(C) :- atom(C), findall(N-H, (help(C/N,H);psh_meta(C/N,H,_)), H), keysort(H,H0), forall(member(N-M, H0), put_help_msg(C,N,M)).
help(C/N) :- help(C/N, H), !, put_help_msg(C,N,H).
help(C/N) :- psh_meta(C/N, H, _), put_help_msg(C,N,H).

put_help_msg(C,N,M) :- puts(C/N), write('\t'), puts(M), put_source_code(C/N).

put_source_code(C/N) :- config(help_outputs_code, true), !, nl, where(C/N,File), whichline(C/N,Line), puts('Defined in':File:Line), fl +C/N.
put_source_code(C/N).
