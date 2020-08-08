rot(P,X,Y,Z) :- call(P,Z,X,Y).
rot(P,X,Y,Z,A) :- call(P,Z,X,Y,A).
swap(P,X,Y) :- call(P,Y,X).
swap(P,X,Y,Z) :- call(P,Y,X,Z).
dup(P,X,X) :- call(P,X).
drop(P,X) :- call(P,X,_).
drop(P,X,Y) :- call(P,X,Y,_).
