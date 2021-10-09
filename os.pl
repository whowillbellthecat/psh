:- foreign(tz(-integer)).
:- foreign(force_set(+positive,+positive)).
:- foreign(dir_file(+string,-atom), [choice_size(1)]).
:- foreign(tty_dim(-positive,-positive)).
:- foreign(pl_isatty(+positive)).
:- foreign(pass_sigint).
:- foreign(new_pgid).
:- foreign(pl_tcsetpgrp(+positive, +positive)).
:- foreign(c_read(+positive, -term)).
:- foreign(tcsetvtime(+positive)).
:- foreign(do_exec(+string,term)).
:- foreign(pwait(+positive, -atom, -positive)).

tcsetpgrp(X,Y) :- pl_tcsetpgrp(X,Y).

isatty/1 ?> 'true iff the stream term X references a tty'.
isatty('$stream'(Fd)) :- pl_isatty(Fd).
isatty(X) :- atom(X), !, current_alias('$stream'(Fd),X), pl_isatty(Fd).

isatty/0 ?> 'true iff user_input references a tty'.
isatty :- current_alias(S,user_input), isatty(S).

tty_dim/2 ?> 'X and Y are the width and height of the tty'
	@> isatty -> tty_dim(_,_) ; true.
