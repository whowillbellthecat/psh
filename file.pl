:- psh_include(pipe).
:- psh_include(atom).
:- psh_include(list).
:- psh_include(io).

~/(X), [R] => environ('HOME',H), atom_join([H,X],'/',R).
~/X :- ~/X <> (=).

//(X), [R] => atom_concat('/', X, R).
//X :- //X <> (=).

/(X,Y), [R] => atom_join([X,Y],'/',R).
X/Y :- X/Y <> (=).

://(X,Y), [R] => atom_join([X,Y],'://',R).
X://Y :- X://Y <> (=).

hidden_file_path(P) :- atom_concat('.',_,P).
special_file_path('.'). special_file_path('..').
directory(D) => file_property(D,type(directory)).
file_exists_(F) => file_exists(F).
prefix(X,Y,R) :- atom_join([X,Y],'/',R), !. % is this the correct place for cut?

path_file(X/Y,Y).
path_file(X,Y) :- atom(X), X == Y.
path_file(//X, X).
path_file(~/X, X).

% todo: possible race condition; need O_CREAT|O_EXCL (create file and error if file already exists)
copy_file(F0,F1) :-
	(  file_exists_(F1), directory(F1)
	-> path_file(F0, F), copy_file_(F0, F1/F)
	;  copy_file_(F0,F1) ).
copy_file_(F0,F1) =>
	\+ file_exists(F1), open(F0,read,Source,[type(binary)]), open(F1,write,Sink,[type(binary)]), add_stream_mirror(Source,Sink),
	get_discard(Source), close(Source), close(Sink).
get_discard(S) :- repeat, get_byte(S,-1).

help((ls)/2, 'unify R with a list of atoms containing the names of files in the directory X').
help((ls)/1, 'unify R with a list of atoms containing the names of files in the current directory').
help((ls)/1, 'output files in the directory X').
help((ls)/0, 'output files in the current directory').

ls(D), [F] => directory_files(D,T), exclude(hidden_file_path,T,F).
ls O :- var(O), !, ls('.',O).
ls D :- nonvar(D),ls(D,F),columnize(F,R),maplist(println,R).
(ls) :- ls '.'.

columnize(X,Out) :-
	tty_dim(W,_),
        T <- max_list <-- maplist(atom_length,X),
        C #= W // (T + 1),
        maplist(atom_codes,X,X0),
        maplist(pad(32,T),X0,R0),  % is this right? or should it be pad to the longest item in each row?
        merge_every(C, R0, R),
        maplist(fold(append_with(32)), R, Out).

help((cd)/0, 'change the current working directory to $HOME').
help((cd)/1, 'change the current working directory to X').
help((pwd)/0, 'print the current working directory').
help((pwd)/1, 'unify X with the current working directory').

cd X => change_directory(X). (cd) :- cd '~'.
pwd X :- working_directory(X). (pwd) :- pwd X, puts(X).

% todo : add unlimited depth

find(_,0,[],[]).
find(P,0,D,R) :- atom(D),(call(P,D)->R=[D];R=[]), !.
find(P,N,D,Fs) :-
	callable(P),
	atom(D),
	N > 0,
	directory_files(D,T),
	exclude(special_file_path,T,T0),
	N0 is N-1,
	maplist(prefix(D),T0,T1),
	filter(P,T,F),
	maplist(prefix(D),F,F0),
	filter(directory,T1,Ds),
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
fl(+X/N,M) :- !, M <-- where X/N <> via(X/N).
fl(X), [M] => prolog_file_name(X,F), open(F, read, S), readall(S,M).
fl X :- nonvar(X), !, fl(X,M), maplist(portray_clause,M).
fl X :- var(X), find(endswith('.pl'),X).
(fl) :- fl(X), maplist(puts,X).

where(X/N,F) :- functor(C,X,N), predicate_property(C,prolog_file(F)).
where (X/N) :- where(X/N,F), puts(F).

whichline(X/N,L) :- functor(C,X,N), predicate_property(C,prolog_line(L)).
whichline(X/N) :- puts <-- whichline(X/N).
