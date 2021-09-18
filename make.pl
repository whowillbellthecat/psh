:- include('op.pl').

:- dynamic(psh_clause_line/3).
:- dynamic(included/1).

build_dir('build').
build_obj(F,R) :- build_dir(B), atom_concat(B,'/',B0), atom_concat(B0,F,R).

resolve_clauses([X|Xs],[Y|Ys],(atom_resolve(X,Y), R)/T) :- resolve_clauses(Xs,Ys,R/T).
resolve_clauses([],[],T/T).

expand_psh_include(:-(psh_include(T)), :-(include(R))) :- prolog_file_name(T, F), build_obj(F,R), assertz(included(F)).

apply_expand(P, [X|Xs], [R|Rs]) :- call(P, X, R), !, apply_expand(P,Xs,Rs).
apply_expand(P, [X|Xs], [X|Rs]) :- apply_expand(P, Xs, Rs).
apply_expand(_, [], []).

expand_command_clause((Head => Body), (H0 :- B)) :-
	Head = (P,Q), !,
	functor(P,_,_),
	list(Q),
	expand_command_clause((P => Body), (H :- B)),
	H =.. Xs,
	append(Xs,Q,Ys),
	H0 =.. Ys.

expand_command_clause((Head => Body), (Head0 :- R)) :-
        Head =.. [F|Vars],
        length(Vars,N),
        length(Vars0,N),
        Head0 =.. [F|Vars0],
        resolve_clauses(Vars0,Vars,R/Body).

psh_clause_metadata(X, R) :- findall(psh_clause_line(F,N,L), psh_clause_line(F,N,L), D), append(X,D,R).

psh_clause_defines(X,R) :-
	(  g_read(psh_clause_line_defined, 0)
	-> R = [(:-multifile(psh_clause_line/3)),(:-discontiguous(psh_clause_line/3))|X],
	   g_assign(psh_clause_line_defined, 1)
	;  R = X ).

readall(S,M) :- read(S,L),
	(  L = end_of_file
	-> M = []
	;  M = [L|Ls],
		(  clause_head_functor(L,F,N)
		-> stream_line_column(S,Line,_),
		   assertz(psh_clause_line(F, N, Line))
		;  true ),
	  readall(S,Ls)).

clause_head_functor((P :- _), F, N) :- !, functor(P,F,N).
clause_head_functor(((P, _) => _), F, N) :- !, functor(P,F,N).
clause_head_functor((P => _), F, N) :- !, functor(P,F,N).
clause_head_functor(((P, _) --> _), F, N) :- !, functor(P,F,N).
clause_head_functor((P --> _), F, N) :- !, functor(P,F,N).
clause_head_functor(P, F, N) :- functor(P,F,N), F \= (:-).

transform --> psh_clause_defines, apply_expand(expand_command_clause), apply_expand(expand_psh_include), psh_clause_metadata.

make_transform(InF) :-
	retractall(psh_clause_line(_,_,_)),
	build_obj(InF,OutF),
	open(InF,read,ReadS),
	readall(ReadS, Data),
	close(ReadS),
	transform(Data, Data0),
	open(OutF,write,WriteS),
	maplist(portray_clause(WriteS), Data0),
	close(WriteS),
	(  included(F)
	-> retract(included(F)), make_transform(F)
	;  true ).

make_transform :-
	init_build_directory,
	directory_files('.',T),
	findall(E,
		(  member(E, T),
		   atom_concat(_,'.pl',E)),
	    Targets),
	forall(member(E, Targets), make_transform(E)),
	halt.

init_build_directory :- build_dir(B), catch(make_directory(B), error(system_error('File exists'),make_directory/1), true).

main :- argument_list([X]), init_build_directory, make_transform(X), halt.

:- initialization(main).
