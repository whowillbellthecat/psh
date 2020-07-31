:- include('comb.pl').
:- include('file.pl').
:- include('external.pl').
:- include('misc.pl').

:- op(799, xfx, via).
:- op(401, fx, edit).

via(X,F,R) :- R <-- fl F <> filter(cf(X)).
X via F :- maplist(portray_clause) <-- X via F.

edit T :- atom(T), atom_concat(T,'.pl',F), vi F.
edit(+P/N) :- atom(P), where(P/N, F), vi F.
%edit(X via F) :-  % for this to work I'll need a way to reinsert edited content into the file.
	% what I need is a bidirectional mapping to/from the concise notation I prefer to use so
	% that I can map portray_clause<->concise notation. Though without care comments will end up being removed.

prompt(X,Y) :- repeat,print(X),read(Y),nonvar(Y),(Y=end_of_file->halt;true).

start(X) :- prompt(X,Y),call(Y),start(X).
start :- start('$ ').

:- initialization(start).
