import Text.ParserCombinators.Parsec
import Control.Monad (sequence_)
import Control.Monad.State
import Foreign
import System (getArgs)
import Prelude hiding (read)
import System.IO (hFlush, stdout) 

type BF a b = StateT (Ptr a) IO b
read  :: (Storable a, Integral a) => BF a a
write :: (Storable a, Integral a) => a -> BF a ()
read    = do p <- get; liftIO (peek p)
write x = do p <- get; liftIO (poke p x)
 
loop :: (Storable a, Integral a) => BF a b -> BF a ()
loop body = do x <- read;
               when (x /= 0) (body >> loop body)
 
putc, getc, prev, next, decr, incr
    :: (Storable a, Integral a) => BF a ()
 
putChar' x = putChar x >> hFlush stdout >> return ()

putc = read >>= (liftIO . putChar' . toEnum . fromEnum)
getc = liftM  (toEnum . fromEnum) (liftIO getChar) >>= write
 
prev = do p <- get; put (advancePtr p (-1))
next = do p <- get; put (advancePtr p 1)
decr = do x <- read; write (x-1)
incr = do x <- read; write (x+1)
 
parseInstrs :: (Storable a, Integral a) => Parser  (BF a ())
parseInstr :: (Storable a, Integral a) => Parser  (BF a ())
 
parseInstr  = liftM loop (between (char '[') (char ']') parseInstrs)
              <|> (char '<' >> return prev)
              <|> (char '>' >> return next)
              <|> (char '-' >> return decr)
              <|> (char '+' >> return incr)
              <|> (char '.' >> return putc)
              <|> (char ',' >> return getc)
              <|> (noneOf "]" >> return (return ()))
 
parseInstrs = liftM sequence_ (many parseInstr)
 
 
main = do [name] <- getArgs
          source <- readFile name
          tape <- (mallocBytes 10000 :: IO (Ptr Word8))
          (either print (`evalStateT` tape)) (parse parseInstrs name source)
