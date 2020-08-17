:- op(649, yf, each).
:- op(648, xfy, with).
:- op(648, yfx, &=).
:- op(620, yfx, fold).
:- op(399, yfx, @).

each(Y with X,Q,R) :- P <- Y with X, maplist(call,P,Q,R),!.
each(P,Q,R) :- maplist(P,Q,R).
each(P,Q) :- maplist(puts) <-- maplist(P,Q).

with(P,A,R) :- list(A), R <- =(A) <> with_(P) each.
with(P,A,R) :- \+ list(A), with_(P,A,R).
with_(P,A,R) :- P=.. P0, append(P0,[A],P1), R =.. P1.

fold(P, Acc, [X|Xs],R) :- call(P,Acc,X,Acc0), fold(P,Acc0,Xs,R).
fold(_,Acc,[],Acc).
fold(P,[X|Xs],R) :- fold(P,X,Xs,R).

P &= Q :- P <> filter(Q).
&=(P,Q,R) :- <>(P,filter(Q),R).

% Y is a list consisting of N repetitions of X.
repeat(_,0,[]).
repeat(X,N,[X|Y]) :- N>0, N0 is N-1, repeat(X,N0,Y).

filter(_,[],[]). filter(P,[X|Xs],Y):-(call(P,X)->Y=[X|Ys];Y=Ys),filter(P,Xs,Ys),!.
exclude(P,X,Y) :- filter(P,X,T), subtract(X,T,Y).

atom_join([X],_,X).
atom_join([X|Xs],C,R) :- atom_join(Xs,C,Rs),atom_concat(X,C,R0),atom_concat(R0,Rs,R).

limit(C,X,Y) :- C < 0, reverse(X,X0), C0 is abs(C), limit(C0,X0,Y).
limit(C,[X|Xs],[X|Y]) :- C > 0, C0 is C-1, limit(C0,Xs,Y).
limit(0,_,[]).
limit(_,[],[]).
limit(C,X) :- \+ list(C), limit(C,X,Y), maplist(puts,Y).
limit(X,Y) :- var(Y), limit(10,X,Y).
limit(X,Y) :- list(X), limit(10,X,Y).
limit(X) :- limit(10,X).

takeWhile(P,[X|Xs],[X|Ys]) :- call(P,X), takeWhile(P,Xs,Ys).
takeWhile(P,[X|_],[]) :- \+ call(P,X).

zip([X|Xs],[Y|Ys], [X-Y|Zs]) :- zip(Xs,Ys,Zs).
zip([],[],[]).

zipWith(P,[X|Xs],[Y|Ys],[Z|Zs]) :- call(P,X,Y,Z), zipWith(P,Xs,Ys,Zs).
zipWith(_,[],[],[]).

@(X,[Y|Ys],[Z|Zs]) :- nth(Y,X,Z), @(X,Ys,Zs).
@(_,[],[]).
X @ Y :- puts <-- X @ Y.

order(X,Y) :- Y <- swap(zip(_)) <-- keysort <-- zip(X) <-- reverse <-- length(X) <> (#<).

group(X,Y):-S<-sort(X),M<-msort(X),length(S,A),repeat([],A,I),N<-order(X),group(S,M,N,I,Y).
group([X|Xs],[X|Ys],[N|Ns],[I|Is],Zs) :- group([X|Xs],Ys,Ns,[[N|I]|Is],Zs).
group([X|Xs],[Y|Ys],[N|Ns],[I|Is],[I0|Zs]) :- X \= Y, reverse(I,I0), group(Xs,[Y|Ys],[N|Ns],Is,Zs).
group([_],[],[],[X],[Y]) :- reverse(X,Y).

groupby(X,Y,Z) :- list(X), group(X,G), maplist(@(Y),G,Z).
groupby(X,Y,Z) :- callable(X), maplist(X,Y,Y0), groupby(Y0,Y,Z).
groupby(X,Y) :- groupby(X,Y) <> (=).
