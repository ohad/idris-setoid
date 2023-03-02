<style>
body {
  width: 80%;
  max-width: 700px;
  margin: auto;
}
code {
  background-color: whitesmoke;
}
pre code {
  display: block;
}
</style>
```idris hide
module Tutorial

import Data.Setoid
import Syntax.PreorderReasoning
import Syntax.PreorderReasoning.Setoid
import Data.List.Elem
import Data.List
import Data.Nat
import Data.Vect
import Data.Fin
import Data.Relation.Equivalence
import Frex
import Frex.Algebra
import Frexlet.Monoid
import Frexlet.Monoid.Commutative
import Notation.Additive
import Frexlet.Monoid.Notation.Additive
import Frexlet.Monoid.Commutative.Nat
import Syntax.WithProof

%default total
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
```idris
Rel : Type -> Type
Rel ty = ty -> ty -> Type
```
```idris hide
%hide Tutorial.Rel
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
%hide Tutorial.MkEquivalence
%hide Tutorial.Equivalence.relation
```
We equip the built-in relation `Equal` with the structure of an equivalence
relation, using the constructor `Refl` and the stdlib functions `sym`, and
`trans`:
```idris
EqualEquivalence : Equivalence a
EqualEquivalence = MkEquivalence
  { relation = (===)
  , reflexive = \x => Refl
  , symmetric = \x,y,x_eq_y => sym x_eq_y
  , transitive = \x,y,z,x_eq_y,y_eq_z => trans x_eq_y y_eq_z
  }
```
```idris hide
%hide Tutorial.EqualEquivalence
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
Lets continue to construct the equivalence relation over `SameDiff`:
```idris
  , symmetric = \x,y,x_eq_y => Check $ Calc $
      |~ y.pos + x.neg
      ~~ x.pos + y.neg ..<(x_eq_y.same)
```
  We take the proof `x_eq_y.same : x.pos + y.neg = y.pos + x.neg` and
  appeal to the symmetric equation.  In the justification of the final
  step, we replace the last dot `(...)` with a left-pointing arrow `(..<)`,
  a mnemonic for reversing the reasoning step.
```idris
  , transitive = \x,y,z,x_eq_y,y_eq_z => Check $ plusRightCancel _ _ y.pos
      $ Calc $
      |~ x.pos + z.neg + y.pos
      ~~ x.pos + (y.pos + z.neg) ...(solve 3 Monoid.Commutative.Free.Free
                                     {a = Nat.Additive} $
                                     (X 0 .+. X 1) .+. X 2
                                  =-= X 0 .+. (X 2 .+. X 1))
      ~~ x.pos + (z.pos + y.neg) ...(cong (x.pos +) $ y_eq_z.same)
      ~~ (x.pos + y.neg) + z.pos ...(?h02{-solve 3 Monoid.Commutative.Free.Free
                                     {a = Nat.Additive} $
                                     X 0 .+. (X 1 .+. X 2)
                                 =-= (X 0 .+. X 2) .+. X 1-})
      ~~ (y.pos + x.neg) + z.pos ...(cong (+ z.pos) ?h002)
      ~~ z.pos + x.neg + y.pos   ...(?h01 {-}solve 3 Monoid.Commutative.Free.Free
                                     {a = Nat.Additive} $
                                     (X 0 .+. X 1) .+. X 2
                                 =-= (X 2 .+. X 1) .+. X 0-})
  }
```
This proof is more involved:

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

## Inductive `INTEGER`s

We'll show how to use setoids to verify the properties of the integers.
Currently in Idris, the `Integer` type is primitive, and while expressions
without any variables such as `2 + (3*5)` reduce to a single value during
type-checking, expressions with variables such as `5 + (3 * x)` reduce to their
primitives, which we cannot prove anything about:
```
prim__add_Integer 5 (prim__mul_Integer 3 x)
```

A natural alternative is to implement an `INTEGER` type inductively:
```idris
data INTEGER
  = ANat Nat
  | NegS Nat

```
The constructor `ANat : Nat -> INTEGER` embeds the natural numbers as
the non-negative integers. The constructor `NegS : Nat -> INTEGER` embeds
them as negative, with `NegS n` representing the integer `-(1 + n)`.
We can now implement the basic `Num`eric interface:
```idris
fromInteger' : (x : Integer) -> INTEGER
fromInteger' x =
  if x < 0
  then NegS $ cast (-1 - x)
  else ANat $ cast x

ANat_Plus_NegS : (k,j : Nat) -> INTEGER
ANat_Plus_NegS 0 j = NegS j
ANat_Plus_NegS (S k) 0 = ANat k
ANat_Plus_NegS (S k) (S j) = ANat_Plus_NegS k j

Plus,Mult : (x,y : INTEGER) -> INTEGER
(ANat k) `Plus` (ANat j) = ANat (k + j)
(NegS k) `Plus` (NegS j) = NegS (1 + k + j)
(ANat k) `Plus` (NegS j) = ANat_Plus_NegS k j
(NegS j) `Plus` (ANat k) = ANat_Plus_NegS k j

NatMult : Nat -> INTEGER -> INTEGER
NatMult 0 x = ANat 0
NatMult (S k) x = x `Plus` NatMult k x

Neg : INTEGER -> INTEGER
Neg (ANat 0) = ANat 0
Neg (ANat (S k)) = NegS k
Neg (NegS k) = ANat (S k)

(ANat k) `Mult` y = NatMult k y
(NegS k) `Mult` y = Neg $ NatMult (S k) y

Num INTEGER where
  fromInteger = fromInteger'
  (+) = Plus
  (*) = Mult
```
If it's not already clear from these definitions, reasoning about `INTEGER`s
is going to involve a _lot_ of case splitting. We'll use an appropriate setoid
to simplify these combinatorics.


## Setoids

A _setoid_ is a type equipped with an equivalence relation:
```idris
record Setoid where
  constructor MkSetoid
  0 U : Type
  equivalence : Equivalence U
```
```idris hide
%hide Tutorial.Setoid.U
%hide Tutorial.Setoid
```
For example, represent the integers using this setoid:
```idris2
INTSetoid : Setoid
INTSetoid = MkSetoid INT SameDiffEquivalence
```

We can turn any type into a setoid using the equality relation:
```idris hide
[IgnoreThis]
```
```idris
Cast Type Setoid where
  cast x = MkSetoid x EqualEquivalence

INTEGERSetoid : Setoid
INTEGERSetoid = cast INTEGER
```
A key difference between the setoids `INTEGERSetoid` and `INTSetoid`:

* In `INTEGERSetoid`, every equivalence class has a unique representative,
by definition:
```idris
uniqueRep : (x,y : INTEGER) -> INTEGERSetoid .equivalence.relation x y -> x = y
uniqueRep _ _ prf = prf
```

* In `INTSetoid`, we have many equivalent representatives:
```idris
Ex2 : (x : Nat) -> INTSetoid .equivalence.relation (0 .-. 0) (x .-. x)
Ex2 0 = Check Refl
Ex2 (S k) = Check $ Calc $
  |~ 0 + (S k)
  ~~ S k       ...(Refl)
  ~~ S (k + 0) ..<(cong S $ plusZeroRightNeutral _)
  ~~ (S k) + 0 ...(Refl)
```

## Homomorphisms

We can convert between the two integer representations:
```idris
toINT : INTEGER -> INT
toINT (ANat k) = k .-. 0
toINT (NegS k) = 0 .-. (S k)

fromINT : (pos, neg: Nat) -> INTEGER
fromINT pos 0 = ANat pos
fromINT 0 (S k) = NegS k
fromINT (S pos) (S neg) = fromINT pos neg

Cast INTEGER INT where
  cast = toINT

Cast INT INTEGER where
  cast (pos .-. neg) = fromINT pos neg
```
These two functions _preserve_ the equivalence relations of
the corresponding setoids, a property that makes them setoid _homomorphisms_:
```idris
0
SetoidHomomorphism : (a,b : Setoid) -> (f : U a -> U b) -> Type
SetoidHomomorphism a b f
  = (x,y : U a) -> a.equivalence.relation x y
  -> b.equivalence.relation (f x) (f y)
```
```idris hide
%hide Tutorial.SetoidHomomorphism
%unbound_implicits off
```
```idris
toINTHomo : (INTEGERSetoid `SetoidHomomorphism` INTSetoid) cast
fromINTHomo : (INTSetoid `SetoidHomomorphism` INTEGERSetoid) cast
```
```idris hide
%unbound_implicits on
```
In one direction, the proof is in fact a special case of a general principle:
```idris
(.IsMate) : (b : Setoid) -> (f : x -> U b) -> (cast x `SetoidHomomorphism` b) f
b.IsMate f i i Refl = b.equivalence.reflexive (f i)

toINTHomo = INTSetoid .IsMate cast
```
In the other direction, we'll some lemmata:
```idris
lemma1 : (pos,neg,k : Nat) -> INTSetoid .equivalence.relation
  ((k + pos) .-. (k + neg))
  (pos .-. neg)
lemma1 pos neg k = Check $ solve 3 Monoid.Commutative.Free.Free
                                     {a = Nat.Additive} $
                                     (X 0 .+. X 1) .+. X 2
                                 =-= X 1 .+. (X 0 .+. X 2)

lemma2 : (pos,neg,k : Nat) -> INTEGERSetoid .equivalence.relation
  (cast $ (k + pos) .-. (k + neg))
  (cast $ pos .-. neg)

lemma2aux : (pos,neg,k : Nat) -> INTEGERSetoid .equivalence.relation
  (fromINT (k + pos) (k + neg))
  (fromINT pos neg)
lemma2aux pos neg 0 = Refl
lemma2aux pos neg (S k) = lemma2aux pos neg k

lemma2 = lemma2aux
lemma2' : (pos,neg,k : Nat) -> INTEGERSetoid .equivalence.relation
  (cast $ (pos + k) .-. (neg + k))
  (cast $ pos .-. neg)
lemma2' pos neg k = Calc $
  |~ cast ((pos + k) .-. (neg + k))
  ~~ cast ((k + pos) .-. (k + neg))
                        ...(cong2 (\x,y => cast $ x .-. y)
                               (plusCommutative _ _)
                               (plusCommutative _ _))
  ~~ cast (pos .-. neg) ...(lemma2 pos neg k)
```

```idris
fromINTHomo (p1 .-. n1) (p2 .-. n2) x_samediff_y = Calc $
  |~ cast (p1 .-. n1)
  ~~ cast ((p1 + n2) .-. (n1 + n2))  ..<(Tutorial.lemma2' _ _ _)
  ~~ cast {to = INTEGER}
          ((p2 + n1) .-. (n2 + n1))  ...(cong2 (\x,y => cast $ x .-. y)
                                           (x_samediff_y.same)
                                           (plusCommutative _ _))
  ~~ cast (p2 .-. n2)                ...(Tutorial.lemma2' _ _ _)
```

We define the type of setoid homomorphisms:
```idris
record (~>) (A,B : Setoid) where
  constructor MkSetoidHomomorphism
  H : U A -> U B
  homomorphic : SetoidHomomorphism A B H
```
```idris hide
%hide Tutorial.(~>)
```
And use it to package the two functions as homomorphisms:
```idris
ToINT : INTEGERSetoid ~> INTSetoid
ToINT = MkSetoidHomomorphism _ toINTHomo
FromINT : INTSetoid ~> INTEGERSetoid
FromINT = MkSetoidHomomorphism _ fromINTHomo
```

The setoid methodology is affectionately called _setoid hell_, because as we
need to propagate the setoid equivalence through complex structures,
we accrue bigger and bigger proof obligations. This situation can be
ameliorated by packaging the homomorphism condition in compositional building
blocks.

For example, the identity setoid homomorphism
and the composition of setoid homomorphisms:
```idris
id : (a : Setoid) -> a ~> a
id a = MkSetoidHomomorphism Prelude.id $ \x, y, prf => prf

(.) : {a,b,c : Setoid} -> b ~> c -> a ~> b -> a ~> c
g . f = MkSetoidHomomorphism (H g . H f) $ \x,y,prf =>
  g.homomorphic _ _ (f.homomorphic _ _ prf)
```
```idris hide
%hide Tutorial.id
%hide Tutorial.(.)
```
As another example, we can package the information about preservation
of setoid relations in more abstract setoids like this setoid of setoid
homomorphisms:
```idris
0 SetoidHomoExtensionality : {a,b : Setoid} -> (f, g : a ~> b) -> Type
SetoidHomoExtensionality f g = (x : U a) ->
        b.equivalence.relation (f.H x) (g.H x)

(~~>) : (a,b : Setoid) -> Setoid
(~~>) a b = MkSetoid (a ~> b) $
  MkEquivalence
  { relation = SetoidHomoExtensionality
  , reflexive = \f,v       =>
      b.equivalence.reflexive (f.H v)
  , symmetric = \f,g,prf,w =>
      b.equivalence.symmetric _ _ (prf w)
  , transitive = \f,g,h,f_eq_g,g_eq_h,q =>
      b.equivalence.transitive _ _ _
        (f_eq_g q) (g_eq_h q)
  }
```
```idris hide
%hide Tutorial.(~~>)
```

## Isomorphisms and Setoid Equational Reasoning

Going the round-trip `INTEGER` to `INT` and back to `INTEGER` always produces
the same result:
```idris
FromToId : (x : INTEGER) ->
  INTEGERSetoid .equivalence.relation
    (cast $ cast {to = INT} x)
    x
FromToId (ANat k) = Refl
FromToId (NegS k) = Refl
```
Going the other round-trip, `INT` to `INTEGER` and back to `INT`, may produce
different results, for example `toINT (fromINT 8 3)` is `5 .-. 0`. However, the
result is always equivalent to the input:
```idris
ToFromId : (x : INT) ->
  INTSetoid .equivalence.relation
    (cast $ cast {to = INTEGER} x)
    x
ToFromId' : (pos,neg : Nat) ->
  INTSetoid .equivalence.relation
    (cast $ cast {to = INTEGER} $ pos .-. neg)
    (pos .-. neg)

ToFromId' pos 0 = Check Refl
ToFromId' 0 (S k) = Check Refl
```
In the last case, we employ setoid equational reasoning:
```idris
ToFromId' (S pos) (S neg) = CalcWith INTSetoid $
  |~ cast {from = INTEGER}
          (cast $ (S pos) .-. (S neg))
  ~~ cast {from = INTEGER}
          (cast $ pos .-. neg)
                         .=.(Refl)
  ~~ pos .-. neg         ...(ToFromId' _ _)
  ~~ (S pos) .-. (S neg) ..<(lemma1 pos neg 1)

ToFromId (pos .-. neg) = ToFromId' pos neg
```
Setoid equational reasoning introduces additional 'operation' on the thought
bubble:

* when the middle dot is `=`, we use reflexivity to turn an appropriate
propositional equality `Equal x y` to the setoid relation, with the
operations `(.=.)` and `(.=<)`.

As with homomorphisms, we package setoid isomorphisms into a type and
they too form a setoid:
```idris
record Isomorphism {a, b : Setoid} (Fwd : a ~> b) (Bwd : b ~> a) where
  constructor IsIsomorphism
  BwdFwdId : (a ~~> a).equivalence.relation (Bwd . Fwd) (id a)
  FwdBwdId : (b ~~> b).equivalence.relation (Fwd . Bwd) (id b)
```
```idris hide
%hide Tutorial.Isomorphism
````
```idris
record (<~>) (a, b : Setoid) where
  constructor MkIsomorphism
  Fwd : a ~> b
  Bwd : b ~> a

  Iso : Isomorphism Fwd Bwd
```
```idris hide
%hide Tutorial.(<~>)
````
and we may form a setoid `a <~~> b` of setoid isomorphisms between the
setoids `a` and `b`, and so on.

Using these concepts, we can package the isomorphism up:
```idris
INTEGERisoINT : INTSetoid <~> INTEGERSetoid
INTEGERisoINT = MkIsomorphism
  { Fwd = FromINT
  , Bwd =   ToINT
  , Iso = IsIsomorphism
      { BwdFwdId = ToFromId
      , FwdBwdId = FromToId
      }
  }
```

## Arithmetic on `INT`: uniformly algebraic reasoning

One advantage `INT` has over `INTEGER` is that the artihemtic in `INT` is
uniform: we need no case-splitting to define addition and multiplication:
```idris
Plus', Mult' : (x,y : INT) -> INT
x ` Plus' ` y = (x.pos + y.pos) .-. (x.neg + y.neg)
x ` Mult' ` y = (x.pos * y.pos + x.neg * y.neg) .-. (x.pos*y.neg + x.neg * y.pos)

Num INT where
  (+) = Plus'
  (*) = Mult'
  fromInteger x =
    if x < 0
    then 0 .-. cast (- x)
    else cast x .-. 0
```
Concretely, we can reduce reasoning about these `INT` operations to reasoning
about equational properties of `Nat`. Given a rich simplification suite, such as
[`Frex`](http://www.github.com/frex-project/idris-frex), discharging these
equations is as simple as calling the simplifier. For example, lets construct
the additive commutative monoid over `INT`, complete with the proofs it forms
a commutative monoid that respects the setoid equivalence.
```idris
INTMonoid : CommutativeMonoid
INTMonoid = MakeModel
```
First, we define the structure of an algebra (`INT`, (`+`), `0`)$$:
```idris

  { a = MkSetoidAlgebra
    { algebra = MkAlgebra
        { U = INT
        , Sem = \case
            Neutral => 0
            Product => (+)
        }
```
Next, we show the algebra structure is compatible with the setoid structure
`INTSetoid`:
```idris
    , equivalence = SameDiffEquivalence
    , congruence = \case
        MkOp Neutral => \[],[],prf => Check Refl
        MkOp Product => \[x1,y1],[x2,y2],prf =>
          let 0 lemma : (u,v,w,z : Nat) -> (u + v) + (w + z) = (u + w) + (v + z)
              lemma u v w z = solve 4
                              Monoid.Commutative.Free.Free
                                     {a = Nat.Additive} $
                                     ((X 0 .+. X 1) .+. (X 2 .+. X 3))
                                 =-= ((X 0 .+. X 2) .+. (X 1 .+. X 3))
          in Check $ Calc $
          |~ (x1.pos + y1.pos) + (x2.neg + y2.neg)
          ~~ (x1.pos + x2.neg) + (y1.pos + y2.neg) ...(lemma _ _ _ _)
          ~~ (x2.pos + x1.neg) + (y2.pos + y1.neg) ...(cong2 (+)
                                                             (prf 0).same
                                                             (prf 1).same)
          ~~ (x2.pos + y2.pos) + (x1.neg + y1.neg) ...(lemma _ _ _ _)
    }
```
Finally, we prove the commutative monoid axioms by calling `Frex`:
```idris
    , validate = \case
      (Mon LftNeutrality) => \[p .-. n] => (INTSetoid).equivalence.reflexive _
      (Mon RgtNeutrality) => \[p .-. n] => Check $ Calc $
        |~ (p + 0) + n
        ~~ p + (n + 0) ...(solve 2
                              Monoid.Commutative.Free.Free
                                     {a = Nat.Additive} $
                                     ((X 0 .+. O1) .+. X 1)
                                 =-= (X 0 .+. (X 1 .+. O1)))
      (Mon Associativity) => \[p1 .-. n1, p2 .-. n2, p3 .-. n3] => Check $ Calc $
        |~ (p1 + (p2 + p3)) + ((n1 + n2) + n3)
        ~~ ((p1 + p2) + p3) + (n1 + (n2 + n3))
           ...(solve 6 Monoid.Commutative.Free.Free {a = Nat.Additive} $
              (X 0 .+. (X 1 .+. X 2)) .+. ((X 3 .+. X 4) .+. X 5)
         =-= ((X 0 .+. X 1) .+. X 2) .+. (X 3 .+. (X 4 .+. X 5))
               )
      Commutativity => \[p1 .-. n1, p2 .-. n2] => Check $ Calc $
        |~ (p1 + p2) + (n2 + n1)
        ~~ (p2 + p1) + (n1 + n2)
          ...(solve 4 Monoid.Commutative.Free.Free {a = Nat.Additive} $
              ((X 0 .+. X 1) .+. (X 2 .+. X 3))
          =-= ((X 1 .+. X 0) .+. (X 3 .+. X 2)))
  }
```
Assuming we have a semi-ring simplifier for the arithmetic structure over the
natural numbers $(\mathbb N, (+), 0, (\cdot), 1)$, we can similarly uniformly
construct the multiplicative integers and the resulting ring.

## Transporting structure
The isomorphism `INTSetoid <~> INTEGERSetoid` is compatible with the various
arithmetic operators in the following way:
```idris
record BinOp where
  constructor Op
  setoid : Setoid
  op : (U setoid -> U setoid -> U setoid)

0 Compatible : (opa, opb : BinOp) ->
  (U opa.setoid -> U opb.setoid) -> Type
((Op a fa) `Compatible` (Op b fb)) h =
  (x,y : U a) -> b.equivalence.relation
    (h (x `fa` y))
    ((h x) `fb` (h y))

toINTisAddHomo :
  ((Op INTEGERSetoid (+)) `Compatible` (Op INTSetoid (+)))
    (ToINT).H
```
To show it, we'll follow the definition of `toINT`, first show that
`ANat_Plus_NegS` is compatible:
```idris
compatibleANAT_Plus_NegS : (k1,k2,j1,j1 : Nat) ->
  toINT (ANat_Plus_NegS (k1 + k2) (1 + j1 + j2))


toINTisAddHomo (ANat k) (ANat j) = ?toINTisAddHomo_rhs_2
toINTisAddHomo (ANat k) (NegS j) = ?toINTisAddHomo_rhs_3
toINTisAddHomo (NegS j) (ANat k) = ?toINTisAddHomo_rhs_4
toINTisAddHomo (NegS j) (NegS k) = ?toINTisAddHomo_rhs_5

```
