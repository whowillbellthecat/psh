
:- op(800, fx, cat).

puts(M,S) :- write(M,S), nl(S).
puts(M) :- write(M), nl.

println([]) :- put_code(10).
println([M|Ms]) :- put_code(M),println(Ms).

gets(S,M) :-
	get_code(S, C),
	( (C= -1->M=C)
	; ([C]="\n"->M=[])
	; ([C]="\r"->gets(S,M))
	; M=[C|T],gets(S,T)).

slurp(S,M) :- gets(S,L), (L= -1->M=[];M=[L|Ls],slurp(S,Ls)), !.
readall(S,M) :- read(S,L), (L= end_of_file->M=[];M=[L|Ls],readall(S,Ls)), !.

cat(F,L) :- open(F,read,S), slurp(S,L).
cat F :- nonvar(F), cat(F,L), maplist(println,L),!.
cat F :- var(F), slurp(user_input, F).
(cat) :- slurp(user_input,L), maplist(println,L).
