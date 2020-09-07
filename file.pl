:- include('pipe.pl').
:- include('list.pl').
:- include('io.pl').
:- include('atom.pl').

:- op(100, fx, ls).
:- op(100, fx, lsd).
:- op(100, fx, cd).
:- op(100, fx, pwd).
:- op(401, fx, fl).
:- op(401, fx, where).

:- op(400,fx,~/).

~/(X,R) :- environ('HOME',H), atom_join([H,X],'/',R).
~/X :- ~/X <> (=).

/(X,Y,R) :- atom(X), !, atom_join([X,Y],'/',R).
/(X,Y,R) :- callable(X), call(X,X0), /(X0,Y,R).
X/Y :- X/Y <> (=).

hidden_file_path(P) :- atom_concat('.',_,P).
directory(D) :- file_property(D,type(directory)).
prefix(X,Y,R) :- atom_join([X,Y],'/',R), !. % is this the correct place for cut?

ls(D,F) :- directory_files(D,T), exclude(hidden_file_path,T,F).
ls O :- var(O), ls('.',O).
ls D :- nonvar(D), ls(D,F), maplist(puts,F).
(ls) :- ls '.'.

lsd(D,F) :- ls(D,F0), filter(directory,F0,F).
lsd D :- lsd(D,F), maplist(puts,F).
(lsd) :- lsd '.'.

cd X :- change_directory(X). (cd) :- cd '~'.
pwd X :- working_directory(X). (pwd) :- pwd X, puts(X).

% todo : add unlimited depth

find(_,0,[],[]).
find(P,0,D,R) :- atom(D),(call(P,D)->R=[D];R=[]), !.
find(P,N,D,Fs) :-
	callable(P),
	atom(D),
	N > 0,
	directory_files(D,T),
	N0 is N-1,
	maplist(prefix(D),T,T0),
	filter(P,T,F),
	maplist(prefix(D),F,F0),
	filter(directory,T0,Ds),
	maplist(find(P,N0),Ds,Fs0),
	flatten(Fs0,R),
	append(F0,R,Fs), sort(Fs).

find(P,N,D) :- nonvar(D), find(P,N,D,F), maplist(puts,F),!.
find(P,D,O) :- var(O), find(P,D,1,O).
find(P,D) :- nonvar(D), find(P,D,'.',F), maplist(puts,F),!.
find(P,O) :- var(O), find(P,1,'.',O).
find(P) :- nonvar(P), find(P,1), !.
find(O) :- var(O), find(atom,1,'.',O).
find :- find(atom,1).

%file listing, with output similar to listing/1.
fl(X,M) :- atom(X), \+ endswith('.pl',X), atom_concat(X, '.pl', F),open(F,read,S), readall(S,M).
fl(F,M) :- atom(F), endswith('.pl',F),open(F,read,S), readall(S,M).
fl(+X/N,M) :- M <-- where X/N <> via(X/N).
fl X :- nonvar(X), fl(X,M), maplist(portray_clause,M),!.
fl X :- var(X), find(endswith('.pl'),X).
(fl) :- fl(X), maplist(puts,X).

where(X/N,F) :- functor(C,X,N), predicate_property(C,prolog_file(F)).
where (X/N) :- where(X/N,F), puts(F).

whichline(X/N,L) :- functor(C,X,N), predicate_property(C,prolog_line(L)).
whichline(X/N) :- puts <-- whichline(X/N).
