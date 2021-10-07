($)/2 ?> 'Y is the value stored in gprolog global variable designated by X'.
$(X,Y) :- g_read(X,Y).

($)/1 ?> 'output the value stored in gprolog global variable designated by X'.
$X :- puts <-- g_read(X).

X <- P :- var(X), !, call(P,X).
X <- P :- atom(X), call(P,Y), g_assign(X,Y).

Z <-- P :- \+ functor(P,(<>),_), var(Z), call(P,Z).
Z <-- P :- functor(P,(<>),_), var(Z), ([V|Vs] <= P), call(V,X), maplist(call,Vs,[X|Ts],Y), reverse(Y,[Z|Zs]), reverse(Zs,Ts).
Z <-- P :- callable(Z), (R <-- P), call(Z,R), !. %may not be best place for cut?

'<--'(V,P,X) :- callable(V), Z <-- P, call(V,Z,X).

V <= (P<>Q<>[R|Rs]) :- V <= (P<>[Q,R|Rs]).
V <= (P<>Q<>R) :- V <= (P<>[Q|[R]]).
[P|Q] <= (P<>Q) :- list(Q), \+ functor(P,(<>),_), \+ functor(Q,(<>),_).
[P|[Q]] <= (P<>Q) :- \+ list(Q), \+ functor(P,(<>),_), \+ functor(Q,(<>),_).
[V] <= V :- \+ list(V), \+ functor(V,(<>),_).

P <> Q :- (X <-- P <> Q), (list(X)->maplist(puts,X);puts(X)), !.
<>(P,Q,R) :- R <-- P <> Q.

<>(P,Q,I,R) :- R <-- =(I) <> P <> Q.
