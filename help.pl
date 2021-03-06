:- multifile(help/2).
:- discontiguous(help/2).
:- dynamic(help/2).

help :-
	write('Please note that psh is very incomplete, with no releases or stable interfaces.'), nl,
	write('Supported commands: '),
	forall(help(C/N,_), (write(C/N), write(' '))),
	nl, nl,
	write('For help with Command, run help(Command).'), nl.

help(C) :- atom(C), findall(N-H, help(C/N,H), H), keysort(H,H0), forall(member(N-M, H0), put_help_msg(C,N,M)).
help(C/N) :- help(C/N, H), put_help_msg(C,N,H).

put_help_msg(C,N,M) :- puts(C/N), write('\t'), puts(M).
