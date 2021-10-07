

do_tests :- forall((psh_meta(C/N, _, T), T \= []), (write(C/N), write('\t'), maplist(do_test,T), nl )).
do_test(T) :- call(T) -> write('.') ; nl, write(T), nl, fail.
