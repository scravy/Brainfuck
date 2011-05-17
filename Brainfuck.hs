module Brainfuck (brainfuck)
	where

import Data.Char

brainfuck :: [Char] -> IO ()
brainfuck text@(x:xs) = bf [] x (xs ++ " ") [] 0 []
	where
		bf ib '>' (ni:ia) db dp (nd:da)     = bf ('>':ib) ni ia (dp:db) nd da
		bf ib '>' (ni:ia) db dp []          = bf ('>':ib) ni ia (dp:db) 0 []
		bf ib '<' (ni:ia) (pd:db) dp da     = bf ('<':ib) ni ia db pd (dp:da)
		bf ib '<' (ni:ia) [] dp da          = bf ('<':ib) ni ia [] 0 (dp:da)
		bf ib '+' (ni:ia) db dp da          = bf ('+':ib) ni ia db (dp + 1) da
		bf ib '-' (ni:ia) db dp da          = bf ('-':ib) ni ia db (dp - 1) da
		bf ib '[' ia@(ni:is) db 0  da       = bf ib' ni' ia' db 0 da
			where
				(ib', ni', ia') = seek ('[':ib) 0 ia
				seek ib 0 (']':x:xs)    = (']':ib, x, xs)
				seek ib 0 (']':[])      = (']':ib, ' ', [])
				seek ib b ('[':xs)      = seek ('[':ib) (b+1) xs
				seek ib b (']':xs)      = seek (']':ib) (b-1) xs
				seek ib b (x:xs)        = seek (x:ib) b xs
		bf ib '[' (ni:ia) db dp da          = bf ('[':ib) ni ia db dp da
		bf ib ']' (ni:ia) db 0  da          = bf (']':ib) ni ia db 0  da
		bf ib ']' ia@(ni:is) db dp da       = bf ib' ni' ia' db dp da
			where
				(ib', ni', ia') = seek ib 0 (']':ia)
				seek (x:'[':xs) 0 ia    = ('[':xs, x, ia)
				seek ib@('[':xs) 0 ia   = (ib, ']', ia)
				seek (']':xs) b ia      = seek xs (b+1) (']':ia)
				seek ('[':xs) b ia      = seek xs (b-1) ('[':ia) 
				seek (x:xs) b ia        = seek xs b (x:ia)
		bf ib '.' (ni:ia) db dp da          = putc dp >> bf ('.':ib) ni ia db dp da
		bf ib ',' (ni:ia) db dp da          = do c <- getc; bf (',':ib) ni ia db c da
		bf ib _ (ni:ia) db dp da            = bf ib ni ia db dp da
		bf _ _ [] _ _ _                     = return ()

putc x = putChar $ chr $ fromInteger x `mod` 256

getc = do c <- catch getChar (\e -> return '\EOT'); return $ sanitize c
	where sanitize '\EOT' = -1
	      sanitize x      = fromIntegral $ ord x
