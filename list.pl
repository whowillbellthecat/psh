% Y is a list consisting of N repetitions of X.
repeat(_,0,[]).
repeat(X,N,[X|Y]) :- N>0, N0 is N-1, repeat(X,N0,Y).

filter(_,[],[]). filter(P,[X|Xs],Y):-(call(P,X)->Y=[X|Ys];Y=Ys),filter(P,Xs,Ys),!.
exclude(P,X,Y) :- filter(P,X,T), subtract(X,T,Y).

% todo: fix these
% aplist is 'applicative list', it implements APL style operator lifting.
aplist(P,X,Y) :- ground(X), ground(Y), call(P,X,Y).
aplist(P,X,[Y|Ys]) :- length([Y|Ys],N), ground(X), repeat(X,N,R), maplist(P,R,[Y|Ys]).
aplist(P,[X|Xs],Y) :- length([X|Xs],N), ground(Y), repeat(Y,N,R), maplist(P,[X|Xs],R).

aplist(P,X,Y,Z) :- ground(X), ground(Y), ground(Z), call(P,X,Y,Z).
aplist(P,X,[Y|Ys],Z) :- length([Y|Ys],N), ground(X), repeat(X,N,R), maplist(P,R,[Y|Ys],Z).
aplist(P,[X|Xs],Y,Z) :- length([X|Xs],N), ground(Y), repeat(Y,N,R), maplist(P,[X|Xs],R,Z).
aplist(P,X,Y,[Z|Zs]) :- length([Z|Zs],N), ground(Y), repeat(Y,N,R), maplist(P,X,R,[Z|Zs]).

atom_join([X],_,X).
atom_join([X|Xs],C,R) :- atom_join(Xs,C,Rs),atom_concat(X,C,R0),atom_concat(R0,Rs,R).

limit(C,X,Y) :- C < 0, reverse(X,X0), C0 is abs(C), limit(C0,X0,Y).
limit(C,[X|Xs],[X|Y]) :- C > 0, C0 is C-1, limit(C0,Xs,Y).
limit(0,_,[]).
limit(_,[],[]).
limit(C,X) :- limit(C,X,Y), maplist(puts,Y).
