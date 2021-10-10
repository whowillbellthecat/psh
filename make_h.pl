build_dir/1 ?> 'X is an atom representing the build directory'.
build_obj/2 ?> 'X and Y are atoms representing, respectively, the path of a file and the path of that file\'s build object'.

resolve_clauses/3 ?> 'X and Y are equal length lists and Z is a difference list containing the conjunction of atom_resolve clauses for each pair of elements'
  @> resolve_clauses([a,b,c], [d,e,f], (atom_resolve(a,d), atom_resolve(b,e), atom_resolve(c,f), p(d),q(f))/(p(d),q(f)))
  @> resolve_clauses([A,B,C], [D,E,F], (atom_resolve(A,D), atom_resolve(B,E), atom_resolve(C,F), p(D),q(F))/(p(D),q(F))).

psh_clause_line/3 ?> 'X is a predicate build with psh, Y is the arity, and Z is the line number it was defined on'
  @> psh_clause_line(resolve_clauses,3,_).

clause_head_functor/3 ?> 'X is a psh clause, Y is the head functor of that clause, and Z is the arity of the predicate'
  @> clause_head_functor((p(_,_), [_,_,_] => _ ), p, 5)
  @> clause_head_functor((test :- _), test, 0)
  @> clause_head_functor((t(_) => _), t, 1).

init_build_directory/0 ?> 'create build_dir if it does not already exist'.

psh_commit/1 ?> 'X is the git commit hash of HEAD at the time psh was build'.
%  @> psh_commit(A), cmd(git,['rev-parse','HEAD'],read,[X]), atom_codes(A,X).
