:- include(psh_make).

main_ :- argument_list([X]), psh_make(X) -> halt ; halt.
main :- catch(main_, T, (write(T), nl, halt(1))).

:- initialization(main).
