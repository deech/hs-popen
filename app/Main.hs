{-# LANGUAGE CPP #-}
module Main where

import System.Process.Popen
import Data.Maybe (isJust)
import Prelude hiding (getLine)

dirCommand :: String
#ifdef mingw32_HOST_OS
dirCommand = "dir"
#else
dirCommand = "ls"
#endif

printLines :: CStream -> IO ()
printLines stream = do
  line <- getLine stream
  maybe (return ())
        (\l -> putStr l >> printLines stream)
        line

main :: IO ()
main = do
  stream <- popen dirCommand R
  printLines stream
  _ <- pclose stream
  return ()
