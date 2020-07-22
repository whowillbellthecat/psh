:- include('file.pl').

:- op(800, fx, cd).
:- op(800, fx, ls).
:- op(800, fx, lsd).
:- op(800, fx, find).
:- op(800, fx, pwd).
:- op(800, fx, cat).
:- op(800, fx, fl).
:- op(950, xfx, <-).
:- op(850, yfx, '<>').
:- op(1150, xfx, <=).
:- op(1150, xfx, <--).

X <- P :- call(P,X).
Z <-- P :- \+ functor(P,(<>),_), var(Z), call(P,Z).
Z <-- P :- functor(P,(<>),_), var(Z), ([V|Vs] <= P), call(V,X), maplist(call,Vs,[X|Ts],Y), reverse(Y,[Z|Zs]), reverse(Zs,Ts).
Z <-- P :- callable(Z), (R <-- P), call(Z,R), !. %may not be best place for cut?

V <= (P<>Q<>[R|Rs]) :- V <= (P<>[Q,R|Rs]).
V <= (P<>Q<>R) :- V <= (P<>[Q|[R]]).
[P|Q] <= (P<>Q) :- list(Q), \+ functor(P,(<>),_), \+ functor(Q,(<>),_).
[P|[Q]] <= (P<>Q) :- \+ list(Q), \+ functor(P,(<>),_), \+ functor(Q,(<>),_).
[V] <= V :- \+ list(V), \+ functor(V,(<>),_).
