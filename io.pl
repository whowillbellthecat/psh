
:- op(100, fx, cat).

puts(S,M) :- write(S,M), nl(S).
puts(M) :- write(M), nl.

println(S,[]) :- put_code(S,10).
println(S,[M|Ms]) :- put_code(S,M),println(S,Ms).
println(M) :- println(user_output, M).

gets(S,M) :-
	get_code(S, C),
	( (C= -1->M=C)
	; ([C]="\n"->M=[])
	; ([C]="\r"->gets(S,M))
	; gets(S,T),(T= -1->M=[C];M=[C|T])).

gets(M) :- gets(user_input,M).

slurp(S,M) :- gets(S,L), (L= -1->M=[];M=[L|Ls],slurp(S,Ls)), !.
readall(S,M) :- read(S,L), (L= end_of_file->M=[];M=[L|Ls],readall(S,Ls)), !.

cat(F,L) :- open(F,read,S), slurp(S,L).
cat F :- nonvar(F), cat(F,L), maplist(println,L),!.
cat F :- var(F), slurp(user_input, F).
(cat) :- slurp(user_input,L), maplist(println,L).
