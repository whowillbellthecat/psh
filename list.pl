each(Y with X,Q,R) :- P <- Y with X, maplist(call,P,Q,R),!.
each(P,Q,R) :- maplist(P,Q,R).
each(P,Q) :- maplist(puts) <-- maplist(P,Q).

with(P,A,R) :- list(A), R <- =(A) <> with_(P) each.
with(P,A,R) :- \+ list(A), with_(P,A,R).
with_(P,A,R) :- P=.. P0, append(P0,[A],P1), R =.. P1.

fold(P, Acc, [X|Xs],R) :- call(P,Acc,X,Acc0), fold(P,Acc0,Xs,R).
fold(_,Acc,[],Acc).
fold(P,[X|Xs],R) :- fold(P,X,Xs,R).

(&=)/3 ?> 'X &= Y is shorthand for P &= filter(Y)'.
&=(P,Q,R) :- <>(P,filter(Q),R).
(&=)/2 ?> 'X &= Y is shorthand for P &= filter(Y)'.
P &= Q :- P <> filter(Q).

repeat/3 ?> 'Z is a list containing Y repetitions of X'
  @> repeat(t,0,[])
  @> repeat(t,1,[t])
  @> repeat(7,10,[7,7,7,7,7,7,7,7,7,7])
  @> (repeat(X,N,[t,t,t]), X == t, N == 3)
  @> (repeat("test",3,Z), Z == ["test", "test", "test"])
  @> (repeat(abc,M,R), R = [abc,abc,abc], M == 3).
repeat(_,0,[]).
repeat(X,N,[X|Y]) :- N #> 0, N #= N0 + 1, repeat(X,N0,Y).

filter/3 ?> 'R is a list of elements of Y for which call(X,Y) holds'
  @> filter(<(3), [1,3,7,8,3,7], [7,8,7])
  @> filter(swap(length,2), ["hi","there","test","me"], ["hi","me"])
  @> filter(atom,[1,a,b,7,3,c,de], [a,b,c,de]).
filter(_,[],[]).
filter(P,[X|Xs],Y):-(call(P,X)->Y=[X|Ys];Y=Ys),filter(P,Xs,Ys).

exclude/3 ?> 'R is the list of elements of Y for which call(X,Y) does not hold'
  @> exclude(<(3), [1,3,7,8,3,7], [1,3,3])
  @> exclude(swap(length,2), ["hi","there","test","me"], ["there","test"])
  @> exclude(atom,[1,a,b,7,3,c,de], [1,7,3]).
exclude(P,X,Y) :- filter(P,X,T), subtract(X,T,Y).

atom_join/3 ?> 'R is the atom formed by joining the list of atoms X with atom C'
  @> atom_join([file,path,example], '/', 'file/path/example')
  @> atom_join(['31257',pdf], '.', '31257.pdf')
  @> atom_join([test], blah, test).
atom_join([X],_,X).
atom_join([X|Xs],C,R) :- atom_join(Xs,C,Rs),atom_concat(X,C,R0),atom_concat(R0,Rs,R).

limit/3 ?> 'Y is a list with up to the first (or last if negative) X entries of the list X'
  @> limit(1,[x],[x])
  @> limit(5, [a,b,c,d,e,f], [a,b,c,d,e])
  @> limit(-1, [a,b,c,d], [d])
  @> limit(0,[],[])
  @> limit(0,[x],[])
  @> limit(1,[],[]).

limit(C,X,Y) :- C < 0, reverse(X,X0), C0 is abs(C), limit(C0,X0,Y).
limit(C,[X|Xs],[X|Y]) :- C > 0, C0 is C-1, limit(C0,Xs,Y).
limit(0,_,[]).
limit(_,[],[]).

limit/2 ?> 'output up to the first (or last if negative) X items of list Y'.
limit/2 ?> 'Y is a list with up to the first 10 items of list X'.
limit(C,X) :- \+ list(C), limit(C,X,Y), maplist(puts,Y).
limit(X,Y) :- var(Y), limit(10,X,Y).
limit(X,Y) :- list(X), limit(10,X,Y).

limit/1 ?> 'output up to the first 10 items of list X'.
limit(X) :- limit(10,X).

% should takeWhile(_,[],[]) fail?
takeWhile/3 ?> 'Z contains successive elements of Y for which unary predicate/closure P holds'
  @> takeWhile(atom,[a,b,c,1,d,e],[a,b,c])
  @> takeWhile(atom,[1,a,2,b,3,c],[])
  @> takeWhile(\+,[false,false,true,false], [false,false]).
takeWhile(P,[X|Xs],[X|Ys]) :- call(P,X), takeWhile(P,Xs,Ys).
takeWhile(P,[X|_],[]) :- \+ call(P,X).

zip/3 ?> 'Z is a list of pairs formed by joining lists X and Y pairwise with the functor (-)/2'.
zip([X|Xs],[Y|Ys], [X-Y|Zs]) :- zip(Xs,Ys,Zs).
zip([],[],[]).

zipWith(P,[X|Xs],[Y|Ys],[Z|Zs]) :- call(P,X,Y,Z), zipWith(P,Xs,Ys,Zs).
zipWith(_,[],[],[]).

@(X,[Y|Ys],[Z|Zs]) :- nth(Y,X,Z), @(X,Ys,Zs).
@(_,[],[]).
X @ Y :- puts <-- X @ Y.

order(X,Y) :- Y <- swap(zip(_)) <-- keysort <-- zip(X) <-- fd_dom <-- length(X) <> rot(fd_domain,1).
sortby(X,Y,Z) :- list(X), order(X,G), Z <- Y@G.
sortby(P,X,Y) :- callable(P), maplist(P,X,X0), order(X0,G), Y <- X@G.

group/2 ?> 'Y is a list of lists of indexes of the items of list X grouped by term equality (in sorted order)'
  @> group([1,2,3,1],[[1,4],[2],[3]])
  @> group([x,a,b,x],[[2],[3],[1,4]])
  @> group([a],[[1]])
  @> group(["test","me","test"],[[2],[1,3]])
  @> \+ group([_,_,_,_,_], _).

group(X,Y):-S<-sort(X),M<-msort(X),length(S,A),repeat([],A,I),N<-order(X),group(S,M,N,I,Y).

group([X|Xs],[X|Ys],[N|Ns],[I|Is],Zs) :- group([X|Xs],Ys,Ns,[[N|I]|Is],Zs).
group([X|Xs],[Y|Ys],[N|Ns],[I|Is],[I0|Zs]) :- X \= Y, reverse(I,I0), group(Xs,[Y|Ys],[N|Ns],Is,Zs).
group([_],[],[],[X],[Y]) :- reverse(X,Y).

groupby(X,Y,Z) :- list(X), group(X,G), maplist(@(Y),G,Z).
groupby(X,Y,Z) :- callable(X), maplist(X,Y,Y0), groupby(Y0,Y,Z).
groupby(X,Y) :- groupby(X,Y) <> (=).


%todo: use difference lists to implement this with(out) append so that
%       the result is a list of lists, not a list of list of lists.
%       n.b. everything is already padded, but should permit join character
merge_every(N,X,R) :- merge_every(N,X,[],R).
merge_every(N,Xs,Acc,[Acc0|R]) :- length(Acc, N), reverse(Acc,Acc0), merge_every(N,Xs,[],R).
merge_every(N,[X|Xs],Acc,R) :- length(Acc, M), M #< N, merge_every(N,Xs,[X|Acc],R).
merge_every(N, [], Acc, [Acc0]) :- length(Acc, M), M #< N, M #> 0, reverse(Acc,Acc0).
merge_every(_,[],[],[]).

append_with(C, X, Y, R) :- append(X,[C|Y], R).

% FIXME: pad(t,_,_,_) crashes
pad/4 ?> 'R is a list containing all elements of Z padded to length Y by item X. Fails if length of Z is more than Y'
  @> pad(t,3,[],[t,t,t])
  @> \+ pad("test",1,[t,t,t],_)
  @> pad("test",4,[t,t,t],[t,t,t,"test"])
  @> \+ pad(abc,0,[t],[])
  @> pad(abc,0,[],[])
  @> pad(1,2,[],[1,1])
  @> \+ pad(_,-1,_,_).
pad(C,N,[X|Xs],[X|R]) :- N #> 0, N0 #= N-1, pad(C,N0,Xs,R).
pad(C,N,[],[C|R]) :- N #> 0, N0 #= N-1, pad(C,N0,[],R).
pad(_,0,[],[]).
