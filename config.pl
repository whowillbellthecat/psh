:- dynamic(config/2).
:- multifile(config/2).
:- discontiguous(config/2).

config(editor, X) :- environ('EDITOR', X).
config(editor, X) :- environ('VISUAL', X).
config(editor, vi).

known_editor_line_flag(vi, '-c').

config(editor_line_flag, X) :- config(editor,E), !, known_editor_line_flag(E, X).

config(pshrc,~/'.pshrc').