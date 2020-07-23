:- op(950, xfx, <-).
:- op(650, yfx, '<>').
:- op(950, xfx, <=).
:- op(950, xfx, <--).

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
