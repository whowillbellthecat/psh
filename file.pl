:- psh_include(pipe).
:- psh_include(atom).
:- psh_include(list).
:- psh_include(io).

(~/)/2 ?> 'R is an atom representing the path X prefixed with the value of the environment variable HOME'.
~/(X), [R] => environ('HOME',H), atom_join([H,X],'/',R).
(~/)/1 ?> 'output an atom representing the path expression ~/X'.
~/X :- ~/X <> (=).

(//)/2 ?> 'R is an atom representing the path expression //X'
  @> //(test/path,'/test/path')
  @> //(t,'/t')
  @> //('', '/').
//(X), [R] => atom_concat('/', X, R).
(//)/1 ?> 'output an atom represting the path expression //X'.
//X :- //X <> (=).

(/)/3 ?> 'R is an atom representing the path expression X/Y'
  @> /(test,here,'test/here')
  @> /(test dot t, l dot pdf, 'test.t/l.pdf')
  @> /(test,test/here,'test/test/here').
/(X,Y), [R] => atom_join([X,Y],'/',R).

(/)/2 ?> 'output an atom representing the path expression X/Y'.
X/Y :- X/Y <> (=).

(://)/3 ?> 'R is an atom representing the path expression X :// Y'
  @> ://(http, example dot com, 'http://example.com').
://(X,Y), [R] => atom_join([X,Y],'://',R).
(://)/2 ?> 'output an atom representing the path expression X :// Y'.
X://Y :- X://Y <> (=).

hidden_file_path(P) :- atom_concat('.',_,P).
special_file_path('.'). special_file_path('..').

directory/1 ?> 'X is a directory'.
directory(D) => file_property(D,type(directory)).

file_exists_(F) => file_exists(F).
prefix(X,Y,R) :- atom_join([X,Y],'/',R).

% XXX: is it 'correct' that path file doesn't use atom resolve?
path_file/2 ?> 'Y is the file component of path X'
  @> path_file(this/(is)/a/test, test)
  @> path_file(this, this)
  @> path_file(~/test/here, here)
  @> path_file(//t/e/f, f)
  @> path_file(//t, t).

path_file(X,_) :- var(X), throw(error(instantiation_error,path_file/2)).
path_file(X/Y,Y) :- !.
path_file(X,Y) :- atom(X), !, X == Y.
path_file(//X, X) :- !.
path_file(~/X, X).

% todo: possible race condition; need O_CREAT|O_EXCL (create file and error if file already exists)

copy_file/2 ?> 'copy file at path X to path Y; if Y denotes a directory then copy file X into directory Y'.
copy_file(F0,F1) :-
	(  file_exists_(F1), directory(F1)
	-> path_file(F0, F), copy_file_(F0, F1/F)
	;  copy_file_(F0,F1) ).
copy_file_(F0,F1) =>
	\+ file_exists(F1), open(F0,read,Source,[type(binary)]), open(F1,write,Sink,[type(binary)]), add_stream_mirror(Source,Sink),
	get_discard(Source), close(Source), close(Sink).
get_discard(S) :- repeat, get_byte(S,-1).


% todo: implement a columnize/3 that takes tty size and is easier to test
% todo: implement a columnize/1 that prints to tty

columnize/3 ?> 'Y is a list of lines (as codes) of length Z-1, each containing elements of X (list of atoms) arranged neatly into columns'
  @> columnize([this,is,a,test],["this","is  ","a   ","test"],5)
  @> columnize([this,is,another,test,here],["this    is     ", "another test   ", "here   "] ,20)
  @> \+ columnize([t],_,0)
  @> columnize([t],[[116]],400).

columnize([],[[]],_).
columnize([X|Xs],Out,Width) :-
	T <- max_list <-- maplist(atom_length,[X|Xs]),
	Width #> T,
	Cols #= Width // (T + 1),
	maplist(atom_codes,[X|Xs],X0),
	maplist(pad(32,T),X0,R0), % should this pad only to the longest item in each col?
	merge_every(Cols, R0, R),
	maplist(fold(append_with(32)), R, Out).

columnize/2 ?> 'Y is a list of lines (as codes) each containing elements of X (list of atoms) arranged neatly into columns'
  @> columnize([],[[]]).
columnize(X,R) :- tty_dim(Width,_), columnize(X,R,Width).

columnize/1 ?> 'Output the items of X (list of atoms) arranged neatly into columns'.
columnize(X) :- maplist(println) <-- columnize(X).

(cd)/1 ?> 'change the current working directory to X'.
cd X => change_directory(X). 

(cd)/0 ?> 'change the current working directory to $HOME'.
(cd) :- cd '~'.

(pwd)/1 ?> 'unify X with the current working directory'.
pwd X :- working_directory(X).

(pwd)/0 ?> 'print the current working directory'.
(pwd) :- pwd X, puts(X).

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


(fl)/2 ?> 'R is a list containing the clauses of X where X is a file path or predicate expression'.
fl(+X/N,M) :- psh_clause_line(X,N,_), !, where(X/N, F), decompose_file_name(F, Dir, Filename, '.pl'), atom_concat(Prefix,'build/',Dir), M <- X/N via Prefix/Filename dot pl.
fl(+X/N,M) :- !, M <- where X/N <> via(X/N).
fl(X), [M] => prolog_file_name(X,F), open(F, read, S), readall(S,M).

(fl)/1 ?> 'output the clauses of X where X is a file path or predicate expression'.
(fl)/1 ?> 'R is a list of atoms containing files ending with \'.pl\' in the current directory'.
fl X :- nonvar(X), !, fl(X,M), maplist(portray_clause,M).
fl X :- var(X), find(endswith('.pl'),X).

(fl)/0 ?> 'output a list of files ending in \'.pl\' in the current directory'.
(fl) :- fl(X), maplist(puts,X).

(where)/2 ?> 'R is the filename the predicate X/N was defined in'.
where(X/N,F) :- functor(C,X,N), predicate_property(C,prolog_file(F)).

(where)/1 ?> 'output the filename the predicate X/N was defined in'.
where (X/N) :- where(X/N,F), puts(F).

whichline/2 ?> 'R is the line number predicate X/N was defined on'.
whichline(X/N,L) :- functor(C,X,N), predicate_property(C,prolog_line(L)).

whichline/1 ?> 'output the line number predicate X/N was defined on'.
whichline(X/N) :- puts <-- whichline(X/N).
