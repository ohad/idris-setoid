import Control.Relation

import Syntax.PreorderReasoning
{-
import Data.List.Elem
import Data.List
import Data.Nat
import Data.Vect.Properties
import Data.Fin
import Data.Relation
import Data.Relation.Equivalence
import Control.Relation
-}
import Data.Vect
import Data.Relation.Equivalence
import Data.Setoid.Vect.Functional
import Frex
import Frex.Free
import Frex.Free.Construction
import Frex.Algebra
import Frex.Model
{-
-}
import Frexlet.Monoid
import Frexlet.Monoid.Commutative
import Notation.Additive
import Frexlet.Monoid.Notation.Additive
import Frexlet.Monoid.Commutative.Nat

import Data.Setoid
import Data.Setoid.Definition
import Frex.Signature
import Frex.Presentation
import Frex.Algebra
import Frex.Model
import Frex.Powers

{-
import Syntax.WithProof
import Data.Setoid.Definition
import Data.Setoid.Vect.Inductive
import Syntax.PreorderReasoning.Setoid

-}
%default total

private infix 8 .-.

record INT where
  constructor (.-.)
  pos, neg : Nat

record SameDiff (x, y : INT) where
  constructor Check
  same : (x.pos + y.neg === y.pos + x.neg)
0
foo : (MkEquivalence ((MkSetoid Nat (EqualEquivalence)).VectEquality)
  (\xs,i => (EqualEquivalence) .reflexive (index i xs))
  (\xs,ys,prf,i => (EqualEquivalence) .symmetric (index i xs) (index i ys) (prf i))
  (\xs,ys,zs,prf1,prf2,i =>
    (EqualEquivalence) .transitive (index i xs) (index i ys) (index i zs) (prf1 i) (prf2 i))
  ).relation [1,1,1] [1,1,1]

foo = ?aref

blah : (x0, x1, x2 : Nat) -> (x0 + x1) + x2 === x0 + (x2 + x1)

0
SameDiffEquivalence : Equivalence INT
SameDiffEquivalence = MkEquivalence
  { relation = SameDiff
  , reflexive = \x => Check $ Calc $
      |~ x.pos + x.neg
      ~~ x.pos + x.neg ...(Refl)
  , symmetric = \x,y,x_eq_y => Check $ Calc $
      |~ y.pos + x.neg
      ~~ x.pos + y.neg ..<(x_eq_y.same)
  , transitive = \x,y,z,x_eq_y,y_eq_z => Check $ plusRightCancel _ _ y.pos
      $ Calc $
      |~ x.pos + z.neg + y.pos
      ~~ x.pos + (y.pos + z.neg) ...(
        let u = solve 3 Monoid.Commutative.Free.Free
                                     {a = Nat.Additive}   {prf = foo}
                                     $
                                     (X 0 .+. X 1) .+. X 2
                                  =-= X 0 .+. (X 2 .+. X 1)
        in ?h189171)
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
