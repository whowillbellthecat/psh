:- include('file.pl').
:- include('external.pl').
:- include('misc.pl').

:- op(950, xfx, <-).
:- op(650, yfx, '<>').
:- op(950, xfx, <=).
:- op(950, xfx, <--).
:- op(799, xfx, via).
:- op(100, fx, edit).

via(X,F,R) :- R <-- fl F <> filter(cf(X)).
X via F :- maplist(portray_clause) <-- X via F.

edit(T) :- atom(T), atom_concat(T,'.pl',F), vi F.
%edit(-F) :-  figure out what file its from and edit that ? or edit listing then copy into file
%edit(X via F) :-  % for this to work I'll need a way to reinsert edited content into the file.
	% what I need is a bidirectional mapping to/from the concise notation I prefer to use so
	% that I can map portray_clause<->concise notation. Though without care comments will end up being removed.

X <- P :- call(P,X).

Z <-- P :- \+ functor(P,(<>),_), var(Z), call(P,Z).
Z <-- P :- functor(P,(<>),_), var(Z), ([V|Vs] <= P), call(V,X), maplist(call,Vs,[X|Ts],Y), reverse(Y,[Z|Zs]), reverse(Zs,Ts).
Z <-- P :- callable(Z), (R <-- P), call(Z,R), !. %may not be best place for cut?

V <= (P<>Q<>[R|Rs]) :- V <= (P<>[Q,R|Rs]).
V <= (P<>Q<>R) :- V <= (P<>[Q|[R]]).
[P|Q] <= (P<>Q) :- list(Q), \+ functor(P,(<>),_), \+ functor(Q,(<>),_).
[P|[Q]] <= (P<>Q) :- \+ list(Q), \+ functor(P,(<>),_), \+ functor(Q,(<>),_).
[V] <= V :- \+ list(V), \+ functor(V,(<>),_).

P <> Q :- (X <-- P <> Q), (list(X)->maplist(puts,X);puts(X)), !.

prompt(X,Y) :- repeat,print(X),read(Y),(Y=end_of_file->halt;true).

start(X) :- prompt(X,Y),call(Y),start(X).
start :- start('$ ').

:- initialization(start).
