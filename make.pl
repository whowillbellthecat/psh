:- include(psh_make).

main_ :- argument_list(['-c',Commit,X]), asserta(m_psh_commit(Commit)), psh_make(X) -> halt ; halt.
main :- catch(main_, T, (write(T), nl, halt(1))).

:- initialization(main).
