module Data.Relation.Equivalence

import public Control.Relation
import public Control.Order
import Data.Vect
import public Data.Fun.Nary

import public Data.Setoid.Notation

public export
record Equivalence (A : Type) where
  constructor MkEquivalence
  0 relation: Rel A
  reflexive : (x       : A) -> relation x x
  symmetric : (x, y    : A) -> relation x y -> relation y x
  transitive: (x, y, z : A) -> relation x y -> relation y z
                            -> relation x z
public export
EqualEquivalence : Equivalence a
EqualEquivalence = MkEquivalence
  { relation = (===)
  , reflexive = \_ => Refl
  , symmetric = \_,_, Refl => Refl
  , transitive = \_,_,_,Refl,Refl => Refl
  }

public export
(/\) : (e1, e2 : Equivalence a) -> Equivalence a
e1 /\ e2 = MkEquivalence
  { relation = \x,y => (e1.relation x y, e2.relation x y)
  , reflexive = \x => (e1.reflexive x, e2.reflexive x)
  , symmetric = \x,y,x_rel_y => ( e1.symmetric _ _ $ fst x_rel_y
                                , e2.symmetric _ _ $ snd x_rel_y
                                )
  , transitive = \x,y,z,x_rel_y,y_rel_z =>
      ( e1.transitive _ _ _ (fst x_rel_y) (fst y_rel_z)
      , e2.transitive _ _ _ (snd x_rel_y) (snd y_rel_z)
      )

  }

-- Unfortunately, stdlib's Preorder doesn't have a construct, so we
-- use this workaround:

public export
record PreorderData A (rel : Rel A) where
  constructor MkPreorderData
  reflexive : (x : A) -> rel x x
  transitive : (x,y,z : A) -> rel x y -> rel y z -> rel x z

public export
[PreorderWorkaround] (Reflexive ty rel, Transitive ty rel) => Preorder ty rel where

public export
MkPreorderWorkaround : {preorderData : PreorderData ty rel} -> Order.Preorder ty rel
MkPreorderWorkaround {preorderData} =
  let reflexiveArg = MkReflexive {ty, rel} $
                     lam Hidden (\y => rel y y) preorderData.reflexive
      transitiveArg = MkTransitive {ty} {rel} $
                      Nary.curry 3 Hidden
                       (\[x,y,z] =>
                         x `rel` y ->
                         y `rel` z ->
                         x `rel` z)
                       (\[x,y,z] => preorderData.transitive _ _ _)

  in PreorderWorkaround

public export
MkPreorder : {0 a : Type} -> {0 rel : Rel a}
  -> (reflexive : (x : a) -> rel x x)
  -> (transitive : (x,y,z : a) -> rel x y -> rel y z -> rel x z)
  -> Preorder a rel
MkPreorder reflexive transitive
  = MkPreorderWorkaround {preorderData = MkPreorderData reflexive transitive}
