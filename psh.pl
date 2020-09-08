:- include('comb.pl').
:- include('file.pl').
:- include('external.pl').
:- include('misc.pl').

:- op(799, xfx, via).
:- op(401, fx, edit).

via(X,F,R) :- R <-- fl F <> filter(cf(X)).
X via F :- maplist(portray_clause) <-- X via F.

edit T :- atom(T), atom_concat(T,'.pl',F), vi F.
edit(+P/N) :- atom(P), where(P/N, F), whichline(P/N,L), vi(L,F).

load_pshrc :- file_exists('~/.pshrc'), consult('~/.pshrc').

prompt(X,Y) :- repeat,print(X),read(Y),nonvar(Y),(Y=end_of_file->halt;true).

start(X) :- prompt(X,Y),call(Y),start(X).
start :- load_pshrc, start('$ ').

:- initialization(start).
