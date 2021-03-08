:- dynamic(config/2).
:- multifile(config/2).
:- discontiguous(config/2).

config(editor, X) :- environ('EDITOR', X).
config(editor, X) :- environ('VISUAL', X).
config(editor, vi).

config(pshrc,~/'.pshrc').
