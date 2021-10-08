rt/0 ?> 'spawn psh and run tests (for running tests on a newly compiled version without exiting the shell you are using)'.
rt :- spawn(psh,['-c','do_tests.']).

do_tests/0 ?> 'run all tests'.
do_tests :- forall((psh_meta(C/N, _, T), T \= []), (write_to_atom(X,C/N), format('~30a\t', [X]), maplist(do_test,T), nl )).

do_test/1 ?> 'run all tests for X'.
do_test(T) :- call(T) -> write('.') ; nl, write(T), nl, fail.
