:- include('list.pl').
:- include('io.pl').
:- include('atom.pl').

:- op(800, fx, ls).
:- op(800, fx, lsd).
:- op(800, fx, cd).
:- op(800, fx, pwd).
:- op(800, fx, fl).

hidden_file_path(P) :- atom_concat('.',_,P).
directory(D) :- file_property(D,type(directory)).
prefix(X,Y,R) :- atom_join([X,Y],'/',R), !. % is this the correct place for cut?

ls(D,F) :- directory_files(D,T), exclude(hidden_file_path,T,F).
ls D :- ls(D,F), maplist(puts,F).
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
	filter(P,T,F),
	N0 is N-1,
	maplist(prefix(D),T,T0),
	filter(directory,T0,Ds),
	maplist(find(P,N0),Ds,Fs0),
	flatten(Fs0,R),
	append(F,R,Fs).

find(P,N,D) :- nonvar(D), find(P,N,D,F), maplist(puts,F),!.
find(P,D,O) :- var(O), find(P,D,1,O).
find(P,D) :- nonvar(D), find(P,D,'.',F), maplist(puts,F),!.
find(P,O) :- var(O), find(P,1,'.',O).
find(P) :- nonvar(P), find(P,1), !.
find(O) :- var(O), find(atom,1).

%file listing, with output similar to listing/1.
fl(X,M) :- atom_concat(X, '.pl', F),open(F,read,S), readall(S,M).
fl(X) :- nonvar(X), fl(X,M), maplist(portray_clause,M),!.
fl X :- var(X), find(endswith('.pl'),X).
(fl) :- fl(X), maplist(puts,X).