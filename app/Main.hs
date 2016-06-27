{-# LANGUAGE CPP #-}
module Main where

import System.Process.Popen
import Prelude hiding (getLine)
import Foreign.C.String
import Foreign.C.Types
import Foreign.Ptr
import Foreign.Marshal.Alloc

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

getLine :: CStream -> IO (Maybe String)
getLine cStream = do
  linePtr <- withCStream cStream getLineShim
  if (linePtr == nullPtr)
    then return Nothing
    else do
     line <- peekCString linePtr
     free linePtr
     return (Just line)

main :: IO ()
main = do
  stream <- popen dirCommand R
  printLines stream
  _ <- pclose stream
  return ()

foreign import ccall safe "cbits/GetLine.H getLineShim" getLineShim ::
    Ptr () -> IO (Ptr CChar)
