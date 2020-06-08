 {-# LANGUAGE TemplateHaskell #-}
module Subst where

import Nat
import Imports

$(singletons [d|

    -- An index: (i.e. just a natural number)
    type Idx = Nat

   -- A substitution (represented by a datatype)
    data Sub a =
       Inc Idx              --  increment by an index amount                
     | a :< Sub a           --  extend a substitution (like cons)
     | Sub a :<> Sub a      --  compose substitutions
        deriving (Eq, Show, Functor) 

    infixr :<     -- like usual cons operator (:)
    infixr :<>    -- like usual composition  (.)
 
   --  Value of the index x in the substitution
    applySub :: SubstDB a => Sub a -> Idx -> a
    applySub (Inc k)        x  = var (plus k x)
    applySub (ty :< s)      Z  = ty
    applySub (ty :< s)   (S x) = applySub s x
    applySub (s1 :<> s2)    x  = subst s2 (applySub s1 x)


    -- identity substitution, leaves all variables alone
    nilSub :: Sub a 
    nilSub = Inc Z

    -- increment, shifts all variable by one
    incSub :: Sub a 
    incSub = Inc (S Z) 

    -- singleton, replace 0 with t, leave everything
    -- else alone
    singleSub :: a -> Sub a
    singleSub t = t :< nilSub

    -- General class for terms that support substitution
    class SubstDB a where
       -- variable data constructor
       var   :: Idx -> a 
       -- term traversal
       subst :: Sub a -> a -> a

    
 
    -- Used in substitution when going under a binder
    lift :: SubstDB a => Sub a -> Sub a
    lift s = var Z :< (s :<> incSub)
 
    -- increment all terms in a list 
    incList :: SubstDB a => [a] -> [a]
    incList = map (subst incSub)

 |])

