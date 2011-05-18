import Brainfuck.Naive

import System (getArgs)
import System.Console.GetOpt


main = do
	args <- getArgs
	func <- if length args == 1 then
		readFile $ head args
		else
			if length args == 2 && args !! 0 == "-r" then
				return $ args !! 1
				else
					getContents
	brainfuck func
