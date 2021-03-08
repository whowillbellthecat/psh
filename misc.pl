:- op(500,yfx,&&).
:- op(500,yfx,or).

&&(P,Q,X) :- call(P,X), call(Q,X).
P && Q :- call(P), call(Q).

or(P,Q,X) :- call(P,X); call(Q,X).
P or Q :- call(P) ; call(Q).

%match clause with predicate name, e.g. `filter(cf(pred/2), Domain, Matching)`
cf(H/N,(H0:-_)) :- functor(H0,H,N), !.
cf(H,(H0:-_)) :- atom(H),functor(H0,H,_).

%defined such that call((\+ p),Y) is interpreted as \+ p(Y).
\+(X,Y) :- \+ call(X,Y).
