:- op(1200,xfx,=>).
:- include('op.pl').

resolve_clauses([X|Xs],[Y|Ys],(atom_resolve(X,Y), R)/T) :- resolve_clauses(Xs,Ys,R/T).
resolve_clauses([],[],T/T).

expand_command_clause((Head => Body), (H0 :- B)) :-
	Head = (P,Q), !,
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

expand_command_clauses([(Head => Body)|Xs], [Y|Ys]) :- !, expand_command_clause((Head => Body), Y), expand_command_clauses(Xs, Ys).
expand_command_clauses([A|B], [A|C]) :- expand_command_clauses(B, C).
expand_command_clauses([], []).

% todo : dedupelicate this. Copied from io so I don't pull in other dependencies
readall(S,M) :- read(S,L), (L= end_of_file->M=[];M=[L|Ls],readall(S,Ls)), !.

make_transform(F) :-
	prolog_file_name(F,InF),
	atom_concat('p_',InF, OutF),
	open(InF,read,ReadS),
	readall(ReadS, Data),
	close(ReadS),
	expand_command_clauses(Data,Data0),
	open(OutF,write,WriteS),
	maplist(portray_clause(WriteS), Data0),
	close(WriteS).

make_transform :-
	make_transform(shell),
	make_transform((file)),
	halt.

:- initialization(make_transform).
