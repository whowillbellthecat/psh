# Overview
## What is psh?

Psh is an experimental non-posix system shell. The shell replaces the GNU Prolog repl
with a commited-choice repl that hides variable bindings and defines a library of useful
predicates.

## Should I use it?

Probably not for any serious use. For a time it was my login shell, but it has no other users to my
knowledge, and recently, I haven't even been using it.

Psh is incomplete and has no releases or stable interfaces. In addition, there have been no serious
commits for some time.

## Why did you work on it if the design is a dead end?

I wanted to learn prolog. I started with two assumptions:
- Using prolog more frequently will accelerate learning
- Using prolog for something it is supposed to be bad at will accelerate learning
- Prolog would be more accessible with ide-like cli utilities

Psh was originally an inside-out IDE in prolog for its own code base. As I tried to spend
more time in the IDE, it morphed into a shell.

## What does psh support?

- Most valid prolog (modulo some parenthesis around operators)
- Basic file system interaction
- help/0 and help/1 predicates (run `help(P).` in psh for information about P)
- ide-like predicates (e.g., jump to definition in editor)
- A very limited form of job control
- Some applicative-like operators for pretending predicates are functions

## What does psh not support?
- Pipeline constructors for composing external processes
- High level FD redirection mechanisms
- Background process tracking
- Detailed documentation/structure
- Static typing
- Interruptable bultins/predicates
- Signal trapping
- Non-hacky line editing (if you use vi-mode)

# Usage

## Building
psh can be built by running `make` (any posix make). gplc - the gprolog compiler - and gcc are build dependencies.
clang may work, but builds failed with clang previously. Some noncritical psh commands have other runtime dependencies (e.g.,
`less/1` assumes less is installed).

The build process will first build make.pl, which will then expand psh specific constructs in the psh
source. The expanded prolog files are named build/*.pl and subsequently compiled with gplc (which will
call CC to compile os.c). The syntax of the psh source code requires make.pl to expand them. Currently,
code loaded into psh must be valid prolog and thus cannot use these constructs.

## Configuration
Run `config.` to see configuration option and `set(Key, Value).` to set option Key to Value. Psh will try to use VISUAL/EDITOR for your
text editor, and SUDO for your raise-privledges command of not set otherwise.

Note that values set this way do not persist. In order to perist them, something like the following to `~/.pshrc` (this is regular prolog):

```Prolog
init :-
   set(_Key0, _Value0),
   set(_Key1, _Value1),
   set(_Key2, _Value2).
:- initialization(init/0).

```

In the example, the variables starting with an underscore would be replaced with actual settings and (lowercase or quoted) values.
If this doesn't make sense, look for an introductory resource on prolog and familiarize yourself with the syntax.

## Notes on usage

Currently, line editing support is a bit underwhelming. GProlog does provide its own 'linedit' mechanism which
allows expanding prolog atoms. It doesn't, however, support extension or vi-like keybindings. If vi-like keybindings
are needed, install rlwrap, set LINEDIT='no', set PSH_RLWRAP, and set the vi editing mode in ~/.inputrc (see readline(3));
doing so will cause psh to run itself under rlwrap automatically. I hope to eventually implement at least basic line editing
functionality, supporting at least a subset of vi keybindings, line history, and basic file-path-aware tab completion.

Psh itself also implements operators using op/3, which can be used in code loaded into psh (e.g., via
consult, [user], etc.). The op/3 directives are in op.pl so that they can be included separately.

The predicate help/0 will output the documented subset of implemented predicates. Psh predicates intended for
use at the psh top level are highly modal. In particular, if a predicate p/(n+1) has an 'output' variable,
it is generally the last variable, and p/n will generally output to the terminal. In the help output, X, Y, and Z are
used positionally to stand in for the first, second, and third predicate variables.

There are two primary composition operators: (<>)/2 and (<--)/2. The expression (p <> q) is equivalent to
(p(X), q(X,Y), puts(Y)), with the additional property that if Y is a list puts is lifted over it. The expression
(p <-- q) is equivalent to (call(q,X), call(p,X)). These expressions can be chained (e.g., (s <-- p <> q <> r)).

Due to the way these are implemented, routines which require variables to be instantiated early may throw errors
when using (<>). This can be corrected by using (<--) instead. These operators are likely to be replaced. Their
use can be made more convenient with the combinatorial predicates (dup, rot, swap, etc) which resemble their forth
counterparts.

Currently, psh will resolve predicates to atoms in some cases. This faculty enables inputing structural path expressions
Due to the current mechanism, any functor f/n with an associated predicate f/n+1 where n>0 can be used in path expressions,
but this is liable to change. The principal constructors are:
```
	(//X)		relative path -> root-prefixed absolute path
	(~/X)		relative path -> user-home-prefixed absolute path
	(X/Y)		path -> file component -> path
	(X dot Y)	atom -> atom -> atom (joined by a '.' character)
	(X ++ Y)	atom -> atom -> atom (concatenation)
```

The underlying predicate that accomplishes this is atom_resolve/2. In psh source files, the following expansion occurs:

```
	p(Q), [R] => q(Q,T), r(T,R).
```
		expands to:
```Prolog
	p(Q,R) :- atom_resolve(Q,Q0), q(Q0,T), r(T,R).
```

That is to say that occurrences of (=>) in the psh source indicate expressions which take path expressions as input (the
list following the predicate in the head of the clause, mirroring DCG semi-context notation, indicates a list of variables
of the head functor which should not be affected by the aforementioned transformation).

# Examples

```
log <> length.                              % how many git commits have been made?
fl (file).                                  % output the code in file.pl via portray_clause
fl +(fl)/2 <> length.                       % how many clauses does fl/2 have as defined?
find(startswith('3')) &= endswith('.pdf').  % find files starting with 3 and ending with '.pdf'
find(startswith('3') && endswith('.pdf')).  % another way of expressing the same

% read a list of files starting with '3' and ending with '.pdf' into a variable, edit its contents with editor,
% and then assign the edited result to the global variable test (read back in as a list via read/2).
test <- ied <-- find(startswith('3')) &= startswith('.pdf').

% output list of filenames that would be captured by the regex `(.*).pdf$'
find(drop(rot(atom_concat,'.pdf'))) <> maplist(rot(atom_concat,'.pdf')).

% count number of commits since last push
X <- cmd([git,'show-ref','origin/master']) <> nth(1) <> limit(7), log <> takeWhile(\+ prefix(X)) <> length.

%%%%
% example session demonstrating the use of some of the operators;
% lines starting with `$' represent user input:
%%%%
$ test <- =([a,b,c,d,e]).   % repeat each element n times where n is the 1-origin index of the element
$ I <- (rot(fd_domain,1) <-- $test <> length) <> fd_dom, $test <> swap(repeat) with I each.
[a]
[b,b]
[c,c,c]
[d,d,d,d]
[e,e,e,e,e]
$ t <- =([[a,b,c],[d,e],[f,g,h],[d,e],[i,j,k,l],[m,n],[o]]).  % sort list of lists by frequency of list lengths
$ (sortby(length) <-- $t <> groupby(length)) <> fold(append). % n.b. groupby/sortby are not stable
[o]
[i,j,k,l]
[a,b,c]
[f,g,h]
[d,e]
[d,e]
[m,n]
```

--

The lists by length frequency problem is taken from 'Ninety-Nine Prolog Problems', see:
    https://www.ic.unicamp.br/~meidanis/courses/mc336/2009s2/prolog/problemas/
