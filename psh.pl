:- psh_include(op).
:- psh_include(os).
:- psh_include(help).
:- psh_include(comb).
:- psh_include((file)).
:- psh_include(external).
:- psh_include(misc).
:- psh_include(config).
:- psh_include(tty).
:- psh_include(test).
:- psh_include(shell).

via(X,F,R) :- R <-- fl F <> filter(cf(X)).
X via F :- maplist(portray_clause) <-- X via F.

help((edit)/1, 'if X = +F/N, edit the containing file for functor F with arity N in editor').
help((edit)/1, 'if atom(X), append \'.pl\' and open in editor').

edit(+P/N) :- psh_clause_line(P,N,L), !, where(P/N,F),
	psh_build_dir(B),
	decompose_file_name(F, Dir, Filename, '.pl'),
	atom_concat(Prefix, 'build/', Dir), atom_concat(Prefix, Filename, P0), atom_concat(P0, '.pl', Path),
	ed(L,Path).
edit(+P/N) :- atom(P), where(P/N, F), whichline(P/N,L), ed(L,F).
edit(-P/N) :- atom(P), where(P/N, F), whichline(P/N,L), ed(L,F).
edit T => atom_concat(T,'.pl',F), ed F.

help(edit_pshrc/0, 'open pshrc in editor, then consult after editing').
help(load_pshrc/0, 'reconsult pshrc').

edit_pshrc :- T <- config(pshrc) <> atom_resolve, ed T, consult(T).
load_pshrc :- T <- config(pshrc) <> atom_resolve, file_exists(T), consult(T).

prompt(X,Y) :- repeat,print(X),read(Y),nonvar(Y),(Y=end_of_file->halt;true).

start(X) :- prompt(X,Y),once(Y), false.
start :- load_pshrc, !, start('$ ').
start :- start('$ ').

main :- pass_sigint, argument_list(X), handle_arguments(X).

handle_arguments(['-r']) :- !, start.
handle_arguments(['-c',C]) :- !, ( once(C) ; true ), halt.
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
