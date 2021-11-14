-- Code adapted from https://github.com/Hardmath123/haskell-lambda-calculus

module Lib
    ( prog
    , eval
    ) where

type Label = String

data Exp = Lam Label Exp
         | App Exp Exp
         | Var Label

instance Show Exp where
  show (Lam label exp) = "(λ" ++ label ++ "." ++ show exp ++ ")"
  show (App exp exp')  = "(" ++ show exp ++ " " ++ show exp' ++ ")"
  show (Var label)     = label

data Lambda = Lambda { lambdaLabel     :: Label
                     , lambdaExp       :: Exp
                     , lambdaParentEnv :: Environment
                     }

instance Show Lambda where
  show (Lambda lambdaLabel lambdaExp lambdaParentEnv) = "(λ" ++ lambdaLabel ++ "." ++ show lambdaExp ++ ")"

data Environment = Root
                 | Environment Label Lambda Environment

labelLookup :: Label -> Environment -> Lambda
labelLookup l Root                           = error $ "Could not find the name " ++ l
labelLookup l (Environment key value parent) = if l == key then value else labelLookup l parent

evalExp :: Environment -> Exp -> Lambda
evalExp env (Lam argname body) = Lambda argname body env
evalExp env (Var name) = labelLookup name env
evalExp env (App function argument) =
  let arg = evalExp env argument
      fn  = evalExp env function
      ne  = Environment (lambdaLabel fn) arg (lambdaParentEnv fn)
  in  evalExp ne (lambdaExp fn)

eval :: Exp -> Lambda
eval = evalExp Root

define :: Label -> Exp -> Exp -> Exp
define name value next = App (Lam name next) value

curryList :: [Label] -> Exp -> Exp
curryList [n] body      = Lam n body
curryList (n:rest) body = Lam n (curryList rest body)

curryCall :: Exp -> [Exp] -> Exp
curryCall e [arg]      = App e arg
curryCall e (arg:rest) = curryCall (App e  arg) rest

prog =
  define "true"  (curryList ["t", "f"]         (Var "t")) $
  define "false" (curryList ["t", "f"]         (Var "f")) $
  define "if"    (curryList ["cond", "t", "f"] (curryCall (Var "cond") [Var "t", Var "f"])) $
  define "and"   (curryList ["a", "b"]         (curryCall (Var "if")   [Var "a", Var "b",     Var "false"])) $
  define "or"    (curryList ["a", "b"]         (curryCall (Var "if")   [Var "a", Var "true",  Var "b"])) $
  define "not"   (curryList ["a"]              (curryCall (Var "if")   [Var "a", Var "false", Var "true"])) $
  curryCall (Var "and") [curryCall (Var "not") [Var "false"], curryCall (Var "or") [Var "true", Var "false"]]
