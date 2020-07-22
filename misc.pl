
%match clause with predicate name, e.g. `filter(cf(pred/2), Domain, Matching)`
cf(H/N,(H0:-_)) :- functor(H0,H,N), !.
cf(H,(H0:-_)) :- atom(H),functor(H0,H,_).
