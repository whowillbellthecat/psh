puts/2 ?> 'write Y to stream X followed by a newline'.
puts(S,M) :- write(S,M), nl(S).

puts/1 ?> 'write X out, followed by a newline'.
puts(M) :- write(M), nl.

println/2 ?> 'output codes Y to stream X followed by a newline'.
println(S,[]) :- put_code(S,10).
println(S,[M|Ms]) :- put_code(S,M),println(S,Ms).

println/1 ?> 'output codes X to user_output followed by a newline'.
println(M) :- println(user_output, M).

gets/2 ?> 'Y is a codes list containing a line read from stream X (until nl or eof(-1))'.
gets(S,M) :-
	get_code(S, C),
	( (C= -1->M=C)
	; ([C]="\n"->M=[])
	; ([C]="\r"->gets(S,M))
	; gets(S,T),(T= -1->M=[C];M=[C|T])).

gets/1 ?> 'Y is a codes list containing a line read from user_input (until nl or eof(-1))'.
gets(M) :- gets(user_input,M).

slurp/2 ?> 'Y is a list of lines read (as codes lists) from stream X (until eof(-1))'.
slurp(S,M) :- gets(S,L), (L= -1->M=[];M=[L|Ls],slurp(S,Ls)).

readall/2 ?> 'Y is a list of terms read via read/2 from stream X (until end_of_file))'.
readall(S,M) :- read(S,L), (L= end_of_file->M=[];M=[L|Ls],readall(S,Ls)).


(cat)/2 ?> 'Y is a list of lines read from the file described by the path X'.
cat(F,L) :- atom_resolve(F,F0), open(F0,read,S), slurp(S,L).

(cat)/1 ?> 'output the contents of the file described by the path Y'.
(cat)/1 ?> 'X is a list of lines read from user_input'.
cat F :- nonvar(F), cat(F,L), maplist(println,L),!.
cat F :- var(F), slurp(user_input, F).

(cat)/0 ?> 'output lines read from user_input'.
(cat) :- slurp(user_input,L), maplist(println,L).
