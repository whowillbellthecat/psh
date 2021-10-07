:- dynamic(config/2).
:- multifile(config/2).
:- discontiguous(config/2).


config/2 ?> 'Y is the value of the config option X. Some options may create choicepoints'.
config(editor, X) :- environ('EDITOR', X).
config(editor, X) :- environ('VISUAL', X).
config(editor, vi).

known_editor_line_flag(vi, '-c').

config(editor_line_flag, X) :- config(editor,E), !, known_editor_line_flag(E, X).

config(pshrc,~/'.pshrc').

config(sudo_cmd, X) :- environ('SUDO', X).
config(sudo_cmd, doas) :- \+ environ('SUDO',_).

config/1 ?> 'output value of configurable XX'.
config(X) :- config(X,Y), write(Y), nl.

config/0 ?> 'output current configuration'.
config :- forall(configurable(X,_),
	(  config(X,Y)
	-> write_to_atom(A,Y), format('~24a ~a~n', [X,A])
	;  '<unset>' ++ X )).

configurable(editor, atom).
configurable(editor_line_flag, atom).
configurable(sudo_cmd, atom).
configurable(pshrc, term).
configurable(help_outputs_code, bool).

set/2 ?> 'set the configuration option X to value Y'.
set(X,Y) :- configurable(X,Type), !, config_typecheck(Type,Y), ( retractall(config(X,_)) -> asserta(config(X,Y)) ; asserta(config(X,Y)) ).
set(X,_) :- throw(error(not_configurable(X), set/2)).

unset/1 ?> 'unset the configuration option X'.
unset(X) :- retractall(config(X,_)), ! ; \+ config(X,_).

config_typecheck(X,Y) :- type_data(X,Y), !.
config_typecheck(_,Y) :- throw(error(type_error(Y), config_typecheck/2)).

type_data(atom, Y) :- atom(Y).
type_data(term, _).
type_data(bool, true).
type_data(bool, false).
