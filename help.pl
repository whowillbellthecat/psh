:- multifile(help/2).
:- discontiguous(help/2).
:- dynamic(help/2).

:- multifile(psh_meta/3).
:- discontiguous(psh_meta/3).
:- dynamic(psh_meta/3).

help :-
	write('Please note that psh is very incomplete, with no releases or stable interfaces.'), nl,
	write('Supported commands: '),
	forall((help(C/N,_) ; psh_meta(C/N,_,_)), (write(C/N), write(' '))),
	nl, nl,
	write('For help with Command, run help(Command).'), nl.

help(C) :- atom(C), findall(N-H, (help(C/N,H);psh_meta(C/N,H,_)), H), keysort(H,H0), forall(member(N-M, H0), put_help_msg(C,N,M)).
help(C/N) :- help(C/N, H), !, put_help_msg(C,N,H).
help(C/N) :- psh_meta(C/N, H, _), put_help_msg(C,N,H).

put_help_msg(C,N,M) :- puts(C/N), write('\t'), puts(M), put_source_code(C/N).

put_source_code(C/N) :- g_read(help_outputs_code, 0), !.
put_source_code(C/N) :- g_read(help_outputs_code, 1), nl, where(C/N,File), whichline(C/N,Line), puts('Defined in':File:Line), fl +C/N.
