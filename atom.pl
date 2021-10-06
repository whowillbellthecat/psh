help(endswith/2, 'true iff Y ends with X').
help(startswith/2, 'true iff Y starts with X').

endswith(E,A) :- atom_concat(_,E,A).
startswith(S,A) :- atom_concat(S,_,A).

atom_resolve/2 ?> 'attempt to resolve X to an atom; if X is nonground, it is called as a unary predicate'
  @> atom_resolve(//this/(is)/a/test, '/this/is/a/test')
  @> atom_resolve(test/here, 'test/here')
  @> atom_resolve(test/'321' dot pdf, 'test/321.pdf')
  @> atom_resolve(test/321 dot 7, 'test/321.7').

atom_resolve(X,X) :- atom(X), !.
atom_resolve(X,Y) :- number(X), !, number_atom(X,Y).
atom_resolve(X,Y) :- callable(X), call(X,Y), atom(Y).

(++)/3 ?> 'R is the concatenation of X and Y'
  @> ++(test,ing,testing)
  @> ++(1,test,'1test')
  @> ++(t,7,'t7')
  @> ++('!@^&*$(.', '*&', '!@^&*$(.*&')
  @> ++(1,3,'13')
  @> ++('',t,t)
  @> ++(t,'',t)
  @> ++('','','')
  @> ++(test/ing,here/(is),'test/inghere/is').

(++)/2 ?> 'Output the concatenation of X and Y'.

++(X,Y,R) :- atom_resolve(X,X0), atom_resolve(Y,Y0), atom_concat(X0,Y0,R).
X++Y :- X++Y <> (=).

help((dot)/3, 'concatenate atoms X and Y with a \'.\' character').
help((dot)/2, 'output the result of concatenating atoms X and Y with a \'.\' character').

dot(X,Y,R) :- R <- X++'.'++Y.
X dot Y :- X dot Y <> (=).
