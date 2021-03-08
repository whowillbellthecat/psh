:- include('help.pl').
:- include('comb.pl').
:- include('file.pl').
:- include('external.pl').
:- include('misc.pl').
:- include('config.pl').

:- op(799, xfx, via).
:- op(401, fx, edit).

via(X,F,R) :- R <-- fl F <> filter(cf(X)).
X via F :- maplist(portray_clause) <-- X via F.

help((edit)/1, 'if X = +F/N, edit the containing file for functor F with arity N in vi').
help((edit)/1, 'if atom(X), append \'.pl\' and open in vi').

edit T :- atom(T), atom_concat(T,'.pl',F), vi F.
edit(+P/N) :- atom(P), where(P/N, F), whichline(P/N,L), vi(L,F).

help(edit_pshrc/0, 'open pshrc in vi, then consult after editing').
help(load_pshrc/0, 'reconsult pshrc').

edit_pshrc :- T <- config(pshrc) <> atom_resolve, vi T, consult(T).
load_pshrc :- T <- config(pshrc) <> atom_resolve, file_exists(T), consult(T).

prompt(X,Y) :- repeat,print(X),read(Y),nonvar(Y),(Y=end_of_file->halt;true).

start(X) :- prompt(X,Y),call(Y),start(X).
start :- load_pshrc, !, start('$ ').
start :- start('$ ').

:- initialization(start).
