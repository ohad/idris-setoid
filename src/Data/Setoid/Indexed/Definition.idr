||| Basic definition and notation for indexed setoids
module Data.Setoid.Indexed.Definition

import public Control.Relation

import public Data.Setoid.Definition

import Syntax.PreorderReasoning.Setoid

infix 5 ~>, ~~>, <~>

%ambiguity_depth 4
%default total

public export
record IndexedEquivalence (0 A : Type) (0 B : A -> Type) where
  constructor MkIndexedEquivalence
  0 relation : (i : A) -> Rel (B i)
  reflexive  : (i : A) -> (x       : B i) -> relation i x x
  symmetric  : (i : A) -> (x, y    : B i) -> relation i x y -> relation i y x
  transitive : (i : A) -> (x, y, z : B i) -> relation i x y -> relation i y z -> relation i x z

public export
EqualIndexedEquivalence : (0 b : a -> Type) -> IndexedEquivalence a b
EqualIndexedEquivalence b = MkIndexedEquivalence
  { relation   = \_ => (===)
  , reflexive  = \_, _ => Refl
  , symmetric  = \_, _, _ => symmetric
  , transitive = \_, _, _, _ => transitive
  }

public export
record IndexedSetoid (0 A : Type) where
  constructor MkIndexedSetoid
  0 U : A -> Type
  equivalence : IndexedEquivalence A U

||| Creates an indexed setoid from a family of setoids.
public export
bundle : (a -> Setoid) -> IndexedSetoid a
bundle x = MkIndexedSetoid
  { U = U . x
  , equivalence = MkIndexedEquivalence
    { relation   = \i => (x i).equivalence.relation
    , reflexive  = \i => (x i).equivalence.reflexive
    , symmetric  = \i => (x i).equivalence.symmetric
    , transitive = \i => (x i).equivalence.transitive
    }
  }

||| Extracts the setoid at an index.
public export
index : IndexedSetoid a -> (i : a) -> Setoid
index x i = MkSetoid
  { U = x.U i
  , equivalence = MkEquivalence
    { relation   = x.equivalence.relation i
    , reflexive  = x.equivalence.reflexive i
    , symmetric  = x.equivalence.symmetric i
    , transitive = x.equivalence.transitive i
    }
  }

namespace ToSetoid
  public export
  irrelevantCast : (0 b : a -> Type) -> IndexedSetoid a
  irrelevantCast b = MkIndexedSetoid { U = b , equivalence = EqualIndexedEquivalence b }

public export
Cast (a -> Type) (IndexedSetoid a) where
  cast b = irrelevantCast b

public export 0
IndexedSetoidHomomorphism : (x, y : IndexedSetoid a) -> (f : (i : a) -> x.U i -> y.U i) -> Type
IndexedSetoidHomomorphism x y f = (i : a) -> (a, b : x.U i)
  -> x.equivalence.relation i a b -> (y.equivalence.relation i `on` f i) a b

public export
record (~>) {0 a : Type} (x, y : IndexedSetoid a) where
  constructor MkIndexedSetoidHomomorphism
  H : (i : a) -> x.U i -> y.U i
  homomorphic : IndexedSetoidHomomorphism x y H

public export
mate : {y : IndexedSetoid a} -> ((i : a) -> x i -> y.U i) -> irrelevantCast x ~> y
mate f = MkIndexedSetoidHomomorphism
  { H = f
  , homomorphic = \_, _, _, Refl => y.equivalence.reflexive _ _
  }

||| Identity IndexedSetoid homomorphism
public export
id : (0 x : IndexedSetoid a) -> x ~> x
id x = MkIndexedSetoidHomomorphism { H = \_ => id , homomorphic = \_, _, _ => id }

||| Composition of IndexedSetoidSetoid homomorphisms
public export
(.) : {0 x, y, z : IndexedSetoid a} -> y ~> z -> x ~> y -> x ~> z
f . g = MkIndexedSetoidHomomorphism
  { H = \i => f.H i . g.H i
  , homomorphic = \i, _, _ => f.homomorphic i _ _ . g.homomorphic i _ _
  }

public export 0
pwEq : (0 x, y : IndexedSetoid a) -> Rel (x ~> y)
pwEq x y f g = (i : a) -> (u : x.U i) -> y.equivalence.relation i (f.H i u) (g.H i u)

public export
(~~>) : (x, y : IndexedSetoid a) -> Setoid
x ~~> y = MkSetoid (x ~> y) $ MkEquivalence
  { relation   = pwEq x y
  , reflexive  = \f, i, u => y.equivalence.reflexive i (f.H i u)
  , symmetric  = \f, g, eq, i, u => y.equivalence.symmetric i _ _ (eq i u)
  , transitive = \f, g, h, eq, eq', i, u => y.equivalence.transitive i _ _ _ (eq i u) (eq' i u)
  }

public export
post : {0 x, y, z : IndexedSetoid a} -> y ~> z -> (x ~~> y) ~> (x ~~> z)
post f = MkSetoidHomomorphism
  { H = (.) f
  , homomorphic = \_, _, eq, i, u => f.homomorphic i _ _ $ eq i u
  }

||| Two indexed setoid homomorphism are each other's inverses
public export
record IndexedIsomorphism {0 a : Type} {0 x, y : IndexedSetoid a} (Fwd : x ~> y) (Bwd : y ~> x) where
  constructor IsIndexedIsomorphism
  BwdFwdId : (x ~~> x).equivalence.relation (Bwd . Fwd) (id x)
  FwdBwdId : (y ~~> y).equivalence.relation (Fwd . Bwd) (id y)

||| Indexed setoid isomorphism
namespace Indexed
  public export
  record (<~>) {0 a : Type} (0 x, y : IndexedSetoid a) where
    constructor MkIsomorphism
    Fwd : x ~> y
    Bwd : y ~> x
    isomorphic : IndexedIsomorphism Fwd Bwd

||| Identity (isomorphism _)
public export
refl : {x : IndexedSetoid a} -> x <~> x
refl = MkIsomorphism
  { Fwd = id x
  , Bwd = id x
  , isomorphic = IsIndexedIsomorphism
    { BwdFwdId = \_, _ => x.equivalence.reflexive _ _
    , FwdBwdId = \_, _ => x.equivalence.reflexive _ _
    }
  }

||| Reverse an isomorphism
public export
sym : Indexed.(<~>) a b -> b <~> a
sym iso = MkIsomorphism
  { Fwd = iso.Bwd
  , Bwd = iso.Fwd
  , isomorphic = IsIndexedIsomorphism
    { BwdFwdId = iso.isomorphic.FwdBwdId
    , FwdBwdId = iso.isomorphic.BwdFwdId
    }
  }

||| Compose isomorphisms
public export
trans : {x, z : IndexedSetoid a} -> x <~> y -> y <~> z -> x <~> z
trans iso iso' = MkIsomorphism
  { Fwd = iso'.Fwd . iso.Fwd
  , Bwd = iso.Bwd . iso'.Bwd
  , isomorphic = IsIndexedIsomorphism
    { BwdFwdId = \i, u => CalcWith (index x i) $
      |~ iso.Bwd.H i (iso'.Bwd.H i (iso'.Fwd.H i (iso.Fwd.H i u)))
      ~~ iso.Bwd.H i (iso.Fwd.H i u)                               ...(iso.Bwd.homomorphic i _ _ $ iso'.isomorphic.BwdFwdId i _)
      ~~ u                                                         ...(iso.isomorphic.BwdFwdId i u)
    , FwdBwdId = \i, u => CalcWith (index z i) $
      |~ iso'.Fwd.H i (iso.Fwd.H i (iso.Bwd.H i (iso'.Bwd.H i u)))
      ~~ iso'.Fwd.H i (iso'.Bwd.H i u)                             ...(iso'.Fwd.homomorphic i _ _ $ iso.isomorphic.FwdBwdId i _)
      ~~ u                                                         ...(iso'.isomorphic.FwdBwdId i u)
    }
  }

public export
IndexedIsoEquivalence : Equivalence (IndexedSetoid a)
IndexedIsoEquivalence = MkEquivalence
  { relation   = \x, y => x <~> y
  , reflexive  = \_ => refl
  , symmetric  = \_, _ => sym
  , transitive = \_, _, _ => trans
  }

||| Quotient a type by a function into an indexed setoid
|||
||| Instance of the more general coequaliser of two indexed setoid morphisms.
public export
Quotient : forall x . (y : IndexedSetoid a) -> ((i : a) -> x i -> y.U i) -> IndexedSetoid a
Quotient y f = MkIndexedSetoid
  { U = x
  , equivalence = MkIndexedEquivalence
    { relation   = \i => y.equivalence.relation i `on` f i
    , reflexive  = \i, _ => y.equivalence.reflexive i _
    , symmetric  = \i, _, _ => y.equivalence.symmetric i _ _
    , transitive = \i, _, _, _ => y.equivalence.transitive i _ _ _
    }
  }
