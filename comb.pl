rot(P,X,Y,Z) :- call(P,Z,X,Y).
swap(P,X,Y) :- call(P,Y,X).
dup(P,X,X) :- call(P,X).
drop(P,X) :- call(P,X,_).
