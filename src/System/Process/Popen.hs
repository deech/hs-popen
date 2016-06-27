module System.Process.Popen
  (
    popen,
    pclose,
    fileno,
    getLine,
    CStream,
    PopenMode(..)
  )
where

import Foreign.C.String
import Foreign.C.Types
import Foreign.Ptr
import Foreign.Marshal.Alloc
import Prelude hiding (getLine)

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

-- | Gets a line from the stream.
getLine :: CStream -> IO (Maybe String)
getLine (CStream streamPtr)= do
  linePtr <- getLineShim streamPtr
  if (linePtr == nullPtr)
    then return Nothing
    else do
     line <- peekCString linePtr
     free linePtr
     return (Just line)

foreign import ccall safe "Examples/PopenShim.H popenShim" popenShim ::
    Ptr CChar -> Ptr CChar -> IO (Ptr ())

foreign import ccall safe "Examples/popenShim.H filenoShim" filenoShim ::
    Ptr () -> IO CInt

foreign import ccall safe "Examples/popenShim.H pcloseShim" pcloseShim ::
    Ptr () -> IO CInt

foreign import ccall safe "Examples/popenShim.H getLineShim" getLineShim ::
    Ptr () -> IO (Ptr CChar)
