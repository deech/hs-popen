module System.Process.Popen
  (
    popen,
    pclose,
    fileno,
    CStream,
    PopenMode(..),
    withCStream
  )
where

import Foreign.C.String
import Foreign.C.Types
import Foreign.Ptr

newtype CStream = CStream (Ptr ())
data PopenMode = R | W deriving (Eq, Show)

-- | Creates a stream, analog of C's popen
popen :: String -> PopenMode -> IO CStream
popen s mode =
  withCString s
   (\sPtr ->
       withCString (case mode of
                     R -> "r"
                     W -> "w")
         (\modePtr -> popenShim sPtr modePtr >>= return . CStream))

-- | Closes a stream. Returns `Left ()` if the status code is -1 and the status code otherwise.
pclose :: CStream -> IO (Either () CInt)
pclose (CStream streamPtr) = do
  status <- pcloseShim streamPtr
  case status of
    (-1) -> return (Left ())
    _ -> return (Right status)

-- | Gets the file descriptor number from the stream.
fileno :: CStream -> IO CInt
fileno (CStream streamPtr) = filenoShim streamPtr

withCStream :: CStream -> (Ptr () -> IO a) -> IO a
withCStream (CStream streamPtr) f = f streamPtr

foreign import ccall safe "cbits/PopenShim.H popenShim" popenShim ::
    Ptr CChar -> Ptr CChar -> IO (Ptr ())

foreign import ccall safe "cbits/popenShim.H filenoShim" filenoShim ::
    Ptr () -> IO CInt

foreign import ccall safe "cbits/popenShim.H pcloseShim" pcloseShim ::
    Ptr () -> IO CInt
