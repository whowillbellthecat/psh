(&&)/3 ?> 'true iff unary predicate/closure X holds for Y and for Z'
  @> &&(length([a,b,c]), number, 3)
  @> \+ &&(length([a,b,c]),length([a,b,c,d]),_).
&&(P,Q,X) :- call(P,X), call(Q,X).

(&&)/2 ?> 'true iff X and Y are true'
  @> true && true
  @> \+ false && true
  @> \+ true && false
  @> \+ false && false.
P && Q :- call(P), call(Q).

(or)/3 ?> 'true iff unary predicate/closure X is holds for either Y or Z'
  @> or(length([a,b,c]), length([a,b]), 2)
  @> \+ or(length([a]), length([]), 17).
or(P,Q,X) :- call(P,X); call(Q,X).

(or)/2 ?> 'true iff X or Y are true'
  @> fail or true
  @> true or true
  @> true or fail
  @> \+ false or false.
P or Q :- call(P) ; call(Q).

% todo: write a helper predicate that defines predicate definition forms (e.g., DCGs, psh-specific, (:-)/2, etc.).
cf/2 ?> 'true iff the principal functor in the predicate definition Y is X, where X = P/N'
  @> cf(t/2, (t(_,_) :- _))
  @> \+ cf(t/3, (t(_,_) :- _))
  @> cf(t/3, (t(_), [_,_] => _)).
cf(H/N, Clause) :- clause_head_functor(Clause,H,N).

(\+)/2 ?> 'defined such that call((\\+ p), Y) is interpreted as \\+ p(Y)'
  @> \+(length([a,b,c]), 4).
\+(X,Y) :- \+ call(X,Y).
