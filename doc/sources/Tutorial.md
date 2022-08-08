```idris hide
module Tutorial

import Data.Setoid
import Syntax.PreorderReasoning
import Syntax.PreorderReasoning.Setoid
import Data.List.Elem
import Data.List
import Data.Nat
import Frex
import Frexlet.Monoid.Commutative
import Notation.Additive
import Frexlet.Monoid.Notation.Additive
import Frexlet.Monoid.Commutative.Nat
```
# Tutorial: Setoids

A _setoid_ is a type equipped with an equivalence relation. Setoids come up when
you need types with a better behaved equality relation, or when you want the
equality relation to carry additional information. After completing this
tutorial you will:

1. Know the user interface to the `setoid` package.
2. Know two different applications in which it can be used:
  + constructing types with an equality relation that's better behaved than
    Idris's built-in `Equal` type.

  + types with an equality relation that carries additional information

If you want to see the source-code behind this tutorial, check the
[source-code](sources/Tutorial.md) out.

## Equivalence relations

A _relation_ over a type `ty` in Idris is any two-argument type-valued function:
```
namespace Control.Relation
  Rel : Type -> Type
  Rel ty = ty -> ty -> Type
```
This definition and its associated interfaces ship with idris's standard
library. Given a relation `rel : Rel ty` and `x,y : ty`, we can form
```x `rel` y : Type```: the type of ways in which `x` and `y` can be related.

For example, two lists _overlap_ when they have a common element:
```idris
record Overlap {0 a : Type} (xs,ys : List a) where
  constructor Overlapping
  common : a
  lhsPos : common `Elem` xs
  rhsPos : common `Elem` ys

```
Lists can overlap in exactly one position:
```idris
Ex1 : Overlap [1,2,3] [6,7,2,8]
Ex1 = Overlapping
  { common = 2
  , lhsPos = There Here
  , rhsPos = There (There Here)
  }
```
But they can overlap in several ways:
```idris
Ex2a ,
Ex2b ,
Ex2c : Overlap [1,2,3] [2,3,2]
Ex2a = Overlapping
  { common = 3
  , lhsPos = There (There Here)
  , rhsPos = There Here
  }
Ex2b = Overlapping
  { common = 2
  , lhsPos = There Here
  , rhsPos = Here
  }
Ex2c = Overlapping
  { common = 2
  , lhsPos = There Here
  , rhsPos = There (There Here)
  }
```
We can think of a relation `rel : Rel ty` as the type of edges in a directed
graph between vertices in `ty`:

* edges have a direction: the type `rel x y` is different to `rel y x`

* multiple different edges between the same vertices `e1, e2 : rel x y`

* self-loops between the same vertex are allowed `loop : rel x x`.

An _equivalence relation_ is a relation that's:

*  _reflexive_: we guarantee a specific way in which every element is related to
  itself;

* _symmetric_: we can reverse an edge between two edges; and

* _transitive_: we can compose paths of related elements into a single edge.

```idris
record Equivalence (A : Type) where
  constructor MkEquivalence
  0 relation: Rel A
  reflexive : (x       : A) -> relation x x
  symmetric : (x, y    : A) -> relation x y -> relation y x
  transitive: (x, y, z : A) -> relation x y -> relation y z
                            -> relation x z
```
```idris hide
%hide Tutorial.Equivalence
```
We equip the built-in relation `Equal` with the structure of an equivalence
relation, using the constructor `Refl` and the stdlib functions `sym`, and
`trans`:
```idris
EqualityEquivalence : Equivalence a
EqualityEquivalence = MkEquivalence
  { relation = (===)
  , reflexive = \x => Refl
  , symmetric = \x,y,x_eq_y => sym x_eq_y
  , transitive = \x,y,z,x_eq_y,y_eq_z => trans x_eq_y y_eq_z
  }
```

We'll use the following relation on pairs of natural numbers as a running
example. We can represent an integer as the difference between a pair of natural
numbers:
```idris
infix 8 .-.

record INT where
  constructor (.-.)
  pos, neg : Nat

record SameDiff (x, y : INT) where
  constructor Check
  same : (x.pos + y.neg === y.pos + x.neg)
```
The `SameDiff x y` relation is equivalent to mathematical equation that states
that the difference between the positive and negative parts is identical:
$$x_{pos} - x_{neg} = y_{pos} - y_{neg}$$
But, unlike the last equation which requires us to define integers and
subtraction, its equivalent `(.same)` is expressed using only addition, and
so addition on `Nat` is enough.

The relation `SameDiff` is an equivalence relation. The proofs are
straightforward, and a good opportunity to practice Idris's equational
reasoning combinators from `Syntax.PreorderReasoning`:
```idris
SameDiffEquivalence : Equivalence INT
SameDiffEquivalence = MkEquivalence
  { relation = SameDiff
  , reflexive = \x => Check $ Calc $
      |~ x.pos + x.neg
      ~~ x.pos + x.neg ...(Refl)
```
This equational proof represents the single-step equational proof:

"Calculate:

1.   $x_{pos} + x_{neg}$
2. $= x_{pos} + x_{neg}$ (by reflexivity)"

The mnemonic behind the ASCII-art is that the first step in the proof
starts with a logical-judgement symbol $\vdash$, each step continues with an
equality sign $=$, and justified by a thought bubble `(...)`.

```idris
  , symmetric = \x,y,x_eq_y => Check $ Calc $
      |~ y.pos + x.neg
      ~~ x.pos + y.neg ..<(x_eq_y.same)
```
  In this proof, we were given the proof `x_eq_y.same : x.pos + y.neg = y.pos + x.neg`
  and so we appealed to the symmetric equation. The mnemonic here is that the
  last bubble in the thought bubble `(...)` is replace with a left-pointing arrow,
  reversing the reasoning step.
```idris
  , transitive = \x,y,z,x_eq_y,y_eq_z => Check $ plusRightCancel _ _ y.pos
      $ Calc $
      |~ x.pos + z.neg + y.pos
      ~~ x.pos + (y.pos + z.neg) ...(solve 3 Monoid.Commutative.Free.Free
                                     {a = Nat.Additive} $
                                     (X 0 .+. X 1) .+. X 2
                                  =-= X 0 .+. (X 2 .+. X 1))
      ~~ x.pos + (z.pos + y.neg) ...(cong (x.pos +) $ y_eq_z.same)
      ~~ (x.pos + y.neg) + z.pos ...(solve 3 Monoid.Commutative.Free.Free
                                     {a = Nat.Additive} $
                                     X 0 .+. (X 1 .+. X 2)
                                 =-= (X 0 .+. X 2) .+. X 1)
      ~~ (y.pos + x.neg) + z.pos ...(cong (+ z.pos) ?h2)
      ~~ z.pos + x.neg + y.pos   ...(solve 3 Monoid.Commutative.Free.Free
                                     {a = Nat.Additive} $
                                     (X 0 .+. X 1) .+. X 2
                                 =-= (X 2 .+. X 1) .+. X 0)
  }
```
This proof is a lot more involved:

1. We appeal to the cancellation property of addition:
  $a + c = b + c \Rightarrow a = b$

  This construction relies crucially on the cancellation property. Later, we
  will learn about its general form, called the INT-construction.

2. We rearrange the term, bringing the appropriate part of `y` into contact with
  the appropriate part of `z` and `x` to transform the term.

  Here we use the idris library [`Frex`](http://www.github.com/frex-project/idris-frex)
  that can perform such routine
  rearrangements for common algebraic structures. In this case, we use the
  commutative monoid simplifier from `Frex`.
  If you want to read more about `Frex`, check the
  [paper](https://www.denotational.co.uk/drafts/allais-brady-corbyn-kammar-yallop-frex-dependently-typed-algebraic-simplification.pdf) out.


Idris's `Control.Relation` defines interfaces for properties like reflexivity
and transitivity. While the
setoid package doesn't use them, we'll use them in a few examples.

The `Overlap` relation from Examples 1 and 2 is symmetric:
```idris
Symmetric (List a) Overlap where
  symmetric xs_overlaps_ys = Overlapping
    { common = xs_overlaps_ys.common
    , lhsPos = xs_overlaps_ys.rhsPos
    , rhsPos = xs_overlaps_ys.lhsPos
    }
```
However, `Overlap` is neither reflexive nor transitive:

* The empty list doesn't overlap with itself:
```idris
Ex3 : Not (Overlap [] [])
Ex3 nil_overlaps_nil = case nil_overlaps_nil.lhsPos of
  _ impossible
```

* Two lists may overlap with a middle list, but on different elements. For example:
```idris
Ex4 : ( Overlap [1] [1,2]
      , Overlap [1,2] [2]
      , Not (Overlap [1] [2]))
Ex4 =
  ( Overlapping 1 Here Here
  , Overlapping 2 (There Here) Here
  , \ one_overlaps_two => case one_overlaps_two.lhsPos of
     There _ impossible
  )
```
The outer lists agree on `1` and `2`, respectively, but they can't overlap on
on the first element of either, which exhausts all possibilities of overlap.
