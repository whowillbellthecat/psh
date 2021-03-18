:- include('help.pl').
:- include('comb.pl').
:- include('file.pl').
:- include('external.pl').
:- include('misc.pl').
:- include('config.pl').
:- include('tty.pl').

:- op(799, xfx, via).
:- op(401, fx, edit).

via(X,F,R) :- R <-- fl F <> filter(cf(X)).
X via F :- maplist(portray_clause) <-- X via F.

help((edit)/1, 'if X = +F/N, edit the containing file for functor F with arity N in editor').
help((edit)/1, 'if atom(X), append \'.pl\' and open in editor').

edit T :- atom_resolve(T,T0), atom_concat(T0,'.pl',F), ed F.
edit(+P/N) :- atom(P), where(P/N, F), whichline(P/N,L), ed(L,F).

help(edit_pshrc/0, 'open pshrc in editor, then consult after editing').
help(load_pshrc/0, 'reconsult pshrc').

edit_pshrc :- T <- config(pshrc) <> atom_resolve, ed T, consult(T).
load_pshrc :- T <- config(pshrc) <> atom_resolve, file_exists(T), consult(T).

prompt(X,Y) :- repeat,print(X),read(Y),nonvar(Y),(Y=end_of_file->halt;true).

start(X) :- prompt(X,Y),call(Y),start(X).
start :- load_pshrc, !, start('$ ').
start :- start('$ ').

main :- argument_list(X), handle_arguments(X).

handle_arguments(['-r']) :- !, start.
handle_arguments(['-c',C]) :- !, ( call(C) ; true ), halt.
handle_arguments([]) :- !, ( readline_hack ; true ), start.
handle_arguments([X]) :- !, consult(X), start.
handle_arguments(_) :- write('Error: unknown mode of operation'), nl, halt.

% This is an ugly hack to provide a way to ensure rlwrap is used even when psh is
% executing directly (e.g., as a login shell). I use rlwrap because it supports vi-like
% keybindings, and the get-key predicates assume LINEDIT (which I don't want to use).
% I should eventually^tm use the C FFI to implement the primitives I need, but for now
% this works. Note that this will only take effect if PSH_RLWRAP is set.
readline_hack :- environ('LINEDIT', no), environ('PSH_RLWRAP',_), spawn(rlwrap, [psh,'-r']), halt.

:- initialization(main).
