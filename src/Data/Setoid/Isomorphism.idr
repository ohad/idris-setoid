module Data.Setoid.Isomorphism

import Data.Setoid.Definition

||| Two setoid homomorphism are each other's inverses
public export
record Isomorphism {a, b : Setoid} (Fwd : a ~> b) (Bwd : b ~> a) where
  constructor IsIsomorphism
  BwdFwdId : (a ~~> a).equivalence.relation (Bwd . Fwd) (id a)
  FwdBwdId : (b ~~> b).equivalence.relation (Fwd . Bwd) (id b)

||| Setoid isomorphism
public export
record (<~>) (a, b : Setoid) where
  constructor MkIsomorphism
  Fwd : a ~> b
  Bwd : b ~> a

  Iso : Isomorphism Fwd Bwd

||| Identity (isomorphism _)
public export
refl : {a : Setoid} -> a <~> a
refl = MkIsomorphism (id a) (id a) (IsIsomorphism a.equivalence.reflexive a.equivalence.reflexive)

||| Reverse an isomorphism
public export
sym : a <~> b -> b <~> a
sym iso = MkIsomorphism iso.Bwd iso.Fwd (IsIsomorphism iso.Iso.FwdBwdId iso.Iso.BwdFwdId)

||| Compose isomorphisms
public export
trans : {a,b,c : Setoid} -> (a <~> b) -> (b <~> c) -> (a <~> c)
trans ab bc = MkIsomorphism (bc.Fwd . ab.Fwd) (ab.Bwd . bc.Bwd) (IsIsomorphism i1 i2)
  where i1 : (x : U a) -> a.equivalence.relation (ab.Bwd.H (bc.Bwd.H (bc.Fwd.H (ab.Fwd.H x)))) x
        i1 x = a.equivalence.transitive _ _ _ (ab.Bwd.homomorphic _ _ (bc.Iso.BwdFwdId _)) (ab.Iso.BwdFwdId x)

        i2 : (x : U c) -> c.equivalence.relation (bc.Fwd.H (ab.Fwd.H (ab.Bwd.H (bc.Bwd.H x)))) x
        i2 x = c.equivalence.transitive _ _ _ (bc.Fwd.homomorphic _ _ (ab.Iso.FwdBwdId _)) (bc.Iso.FwdBwdId x)

public export
IsoEquivalence : Equivalence Setoid
IsoEquivalence = MkEquivalence (<~>) (\_ => refl) (\_,_ => sym) (\_,_,_ => trans)

public export
(<~~>) : (a,b : Setoid) -> Setoid
a <~~> b = MkSetoid (a <~> b)
  $ MkEquivalence
  { relation = \f,g => ( (a ~~> b).equivalence.relation f.Fwd g.Fwd
                       , (b ~~> a).equivalence.relation f.Bwd g.Bwd
                       )
  , reflexive = \f => ( (a ~~> b).equivalence.reflexive _
                      , (b ~~> a).equivalence.reflexive _
                      )
  , symmetric = \f,g,prf =>
      ( (a ~~> b).equivalence.symmetric _ _ (fst prf)
      , (b ~~> a).equivalence.symmetric _ _ (snd prf)
      )
  , transitive = \f,g,h,f_prf_g,g_prf_h =>
      ( (a ~~> b).equivalence.transitive _ _ _ (fst f_prf_g) (fst g_prf_h)
      , (b ~~> a).equivalence.transitive _ _ _ (snd f_prf_g) (snd g_prf_h)
      )
  }
