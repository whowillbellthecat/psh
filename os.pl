:- foreign(tz(-integer)).
:- foreign(force_set(+positive,+positive)).
:- foreign(dir_file(+string,-atom), [choice_size(1)]).
:- foreign(pl_tty_dim(+positive,-positive,-positive)).
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

tty_dim/2 ?> 'X and Y are the width and height of the tty'.
tty_dim(X,Y) :- tty_dim(user_output, X, Y).

tty_dim/3 ?> 'X is a stream term, Y and Z are the width and height of the associated tty'
  @> isatty(user_input) -> tty_dim(user_input,_,_) ; true
  @> isatty(user_output) -> tty_dim(user_output,_,_) ; true
  @> isatty(user_error) -> tty_dim(user_error,_,_) ; true.

tty_dim('$stream'(Fd),X,Y) :- pl_tty_dim(Fd, X, Y).
tty_dim(S,X,Y) :- atom(S), current_alias('$stream'(Fd),S), pl_tty_dim(Fd, X, Y).
