module Main where

import           Lib (eval, prog)

main = do
  print prog
  putStrLn "=>"
  print $ eval prog
