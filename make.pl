:- op(1200,xfx,=>).
:- include('op.pl').

build_dir('build').
build_obj(F,R) :- build_dir(B), atom_concat(B,'/',B0), atom_concat(B0,F,R).

resolve_clauses([X|Xs],[Y|Ys],(atom_resolve(X,Y), R)/T) :- resolve_clauses(Xs,Ys,R/T).
resolve_clauses([],[],T/T).

expand_psh_include(:-(psh_include(T)), :-(include(R))) :- prolog_file_name(T, F), build_obj(F,R).

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

% todo : dedupelicate this. Copied from io so I don't pull in other dependencies
readall(S,M) :- read(S,L), (L= end_of_file->M=[];M=[L|Ls],readall(S,Ls)), !.

transform(X,R) :- apply_expand(expand_command_clause, X, X0), apply_expand(expand_psh_include, X0, R).

make_transform(InF) :-
	build_obj(InF,OutF),
	open(InF,read,ReadS),
	readall(ReadS, Data),
	close(ReadS),
	transform(Data, Data0),
	open(OutF,write,WriteS),
	maplist(portray_clause(WriteS), Data0),
	close(WriteS).

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


:- initialization(make_transform).
