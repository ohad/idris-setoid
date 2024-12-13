||| Basic definition and notation for setoids
module Data.Setoid.Definition

import public Control.Relation

import public Data.Relation.Equivalence

%default total

public export
record Setoid where
  constructor MkSetoid
  0 U : Type
  equivalence : Data.Relation.Equivalence.Equivalence U

public export
reflect : (a : Setoid) -> {x, y : U a} -> x = y -> a.equivalence.relation x y
reflect a Refl = a.equivalence.reflexive _

public export
cast : (a : Setoid) -> Preorder (U a) (a.equivalence.relation)
cast a = MkPreorder a.equivalence.reflexive a.equivalence.transitive

namespace ToSetoid
  public export
  irrelevantCast : (0 a : Type) -> Setoid
  irrelevantCast a = MkSetoid a EqualEquivalence

public export
Cast Type Setoid where
  cast a = irrelevantCast a

public export 0
SetoidHomomorphism : (a,b : Setoid)
  -> (f : U a -> U b) -> Type
SetoidHomomorphism a b f
  = (x,y : U a) -> a.equivalence.relation x y
  -> b.equivalence.relation (f x) (f y)

public export
record (~>) (A,B : Setoid) where
  constructor MkSetoidHomomorphism
  H : U A -> U B
  homomorphic : SetoidHomomorphism A B H

public export
mate : {b : Setoid} -> (a -> U b) -> (irrelevantCast a ~> b)
mate f = MkSetoidHomomorphism f $ \x,y, prf => reflect b (cong f prf)

||| Identity Setoid homomorphism
public export
id : (a : Setoid) -> a ~> a
id a = MkSetoidHomomorphism Prelude.id $ \x, y, prf => prf

||| Composition of Setoid homomorphisms
public export
(.) : {a,b,c : Setoid} -> b ~> c -> a ~> b -> a ~> c
g . f = MkSetoidHomomorphism (H g . H f) $ \x,y,prf => g.homomorphic _ _ (f.homomorphic _ _ prf)

public export
(~~>) : (a,b : Setoid) -> Setoid
(~~>) a b = MkSetoid (a ~> b) $
  let 0 relation : (f, g : a ~> b) -> Type
      relation f g = (x : U a) ->
        b.equivalence.relation (f.H x) (g.H x)
  in MkEquivalence
  { relation
  , reflexive = \f,v       =>
      b.equivalence.reflexive (f.H v)
  , symmetric = \f,g,prf,w =>
      b.equivalence.symmetric _ _ (prf w)
  , transitive = \f,g,h,f_eq_g, g_eq_h, q =>
      b.equivalence.transitive _ _ _
        (f_eq_g q) (g_eq_h q)
  }

public export
post : {a,b,c : Setoid} -> b ~> c -> (a ~~> b) ~> (a ~~> c)
post h = MkSetoidHomomorphism
  { H = (h .)
  , homomorphic = \f1,f2,prf,x => h.homomorphic _ _ (prf x)
  }

||| Quotient a type by an function into a setoid
|||
||| Instance of the more general coequaliser of two setoid morphisms.
public export
Quotient : (b : Setoid) -> (a -> U b) -> Setoid
Quotient b q = MkSetoid a $
  let 0 relation : a -> a -> Type
      relation x y = b.equivalence.relation (q x) (q y)
  in MkEquivalence
    { relation = relation
    , reflexive  = \x      =>
        b.equivalence.reflexive  (q x)
    , symmetric  = \x,y    =>
        b.equivalence.symmetric  (q x) (q y)
    , transitive = \x,y,z  =>
        b.equivalence.transitive (q x) (q y) (q z)
    }
