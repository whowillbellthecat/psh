esc('\33\').
csi(X) :- esc(Esc), atom_concat(Esc,'[',X).
csi(C,R) :- esc(Esc), atom_concat(Esc,'[',X), atom_concat(X,C,R).

clear :- write <-- csi('2J'), write <-- csi('H').
