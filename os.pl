:- foreign(tz(-integer)).
:- foreign(force_set(+positive,+positive)).
:- foreign(dir_file(+string,-atom), [choice_size(1)]).
:- foreign(tty_dim(-positive,-positive)).
:- foreign(pass_sigint).
:- foreign(new_pgid).
:- foreign(pl_tcsetpgrp(+positive, +positive)).
:- foreign(c_read(+positive, -term)).
:- foreign(tcsetvtime(+positive)).

tcsetpgrp(X,Y) :- pl_tcsetpgrp(X,Y).
