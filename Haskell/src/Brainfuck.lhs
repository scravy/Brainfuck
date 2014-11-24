A Brainfuck Interpreter in Haskell
==================================

This is a tiny brainfuck interpreter, writte in Haskell,
with the following Language Extensions:

> {-# LANGUAGE Haskell2010, LambdaCase, NegativeLiterals, GADTs, RecordWildCards #-}

In order to be rebuked by GHC, we order it to warn us about anything
(except when a variable name is reused in some subordinate scope):

> {-# OPTIONS_GHC -Wall -fno-warn-name-shadowing #-}

We are using three helper functions:

- `getArgs` for retrieving the command line arguments, given to the program
- `<$>` which is just a handy infix operator meaning `fmap`
- `nicify` which we can use to pretty print the AST of a brainfuck program

> import System.Environment (getArgs)
> import Data.Functor ((<$>))
> import Text.Nicify (nicify)

The memory of the brainfuck machine is all integers. According to the brainfuck
specification those should be BigIntegers, but we might want to change that to
native integers (which do overflow) in order go gain performance. Therefore we
define a `Word` as `Integer` which may easily be replaced with `Int64` or `Int`.

> type Word = Integer

The main function of our program works as follows:

- It retrieves the input supplied on STDIN via `getContents`,
- It maps every character into the `Word` type of the Brainfuck VM,
- It analyzes the command line arguments,
- parses the file (using the optimizer or not using the optimizer), and
- according to the arguments prints them or executes the program in the VM.

> main :: IO ()
> main = do
>     stdin <- map (fromIntegral . toInteger . fromEnum) <$> getContents
> 
>     getArgs >>= \case
>         ["-p", f] -> parseBrainfuck <$> readFile f >>= printAST
> 
>         ["-o", f] -> parseBrainfuck' <$> readFile f >>= printAST
> 
>         ["-s", f] -> parseBrainfuck <$> readFile f >>= executeAST stdin
> 
>         [f] -> parseBrainfuck' <$> readFile f >>= executeAST stdin
> 
>         _ -> putStrLn $  "You need to specify exactly one argument: "
>                       ++ "The brainfuck script-file to execute."

A few helper functions, so that we do not repeat ourselves too much:

>   where
>     printAST = either putStrLn (putStrLn . nicify. show)

`-p` and `-o` will print the abstract syntax tree. `printAST` will
either print (`putStrLn`) an error message or `show` (`a -> String`)
the AST, pretty print if (`nicify :: String -> String`) and put it
to the screen (`putStrLn`).

>     executeAST input = either putStrLn (mapM_ printChar . runBrainfuck input)

`executeAST` works just as `printAST`, just that instead of pretty
printing and showing the AST it will execute it using the given `input`
and print every resulting character (`mapM_` is `map` on monads discarding
the result (`mapM :: [m a] -> m [a]` whereas `mapM_ :: [m a] -> m ()`).

We ignore the result since we are only interested in the side effects
(induced by `putStrLn :: String -> IO ()`. The result type `IO ()` merely
means "this function is performing IO").

>     printChar = putStr . return . toEnum . fromIntegral

A few more helper functions which get rid of the need to supply the
accumulator arguments to the actual functions which we are going to
define later on:

> parseBrainfuck, parseBrainfuck' :: String -> Either String Program
> 
> parseBrainfuck' = fmap optimize . parseBrainfuck
> parseBrainfuck = parse [] []
> 
> runBrainfuck :: Input -> Program -> [Word]
> runBrainfuck input = exec (mkVM input)

Let's write a Brainfuck Interpreter!


A Brainfuck Parser
------------------

First we define the types needed for parsing a Brainfuck Script.

A `Program` consists of a Sequence of Steps, which we will model
as Abstract Syntax Trees (after all Brainfuck programs may contain
loops):

> type Program = [AST]

An actual Abstract Syntax Tree (`AST`) is either
- an `Inc` operation (resembling `+` and `-`)
- a `Mem` operation which moved the memory pointer (`>` and `<`)
- `Get` which retrieves a character as an integer from stdin (`,`)
- `Put` which prints the current memory cell to stdin (`.`)
- or a Loop - which contains a program which is conditionally executed.

Note that this structure is capable of holding optimized Brainfuck
programs which do not `Inc` or `Mem` one but an arbitrary number of
steps.

> data AST where
>     Inc  :: Word -> AST
>     Mem  :: Word -> AST
>     Get  :: AST
>     Put  :: AST
>     Loop :: Program -> AST
>   deriving (Show)

The above definition uses GADT Syntax (Generalized Algebraic Data Types).
Without `-XGADTs` this might be expressed in Standard Haskell as follows:

    data AST = Inc Word | Mem Word | Get | Put | Loop Program

The parser is a recursive functions that iterates on its input until
nothing is left. Since the Brainfuck script might be malformed
(mismatched braces) it returns either a `String` or a `Program`.

Brainfuck has a fairly simple syntax. There are 8 control characters
of which only two pose a problem to parsing. ".,+-><" can be translated
into `Put`, `Get`, `Inc 1` (`Inc -1` respectively) and `Mem 1` (`Mem -1`).

Note that Standard Haskell requires you to enclose negative literals in
parenthesis. We avoid that using `-XNegativeLiterals`.

Whenever we encounter an opening rectangular bracket (`[`) we parse
a new subprogram. Everything we know so far is being pushed on the
first accumulator (a stack of 'super programs', `[Program]`).

The second accumulator holds the program we read so far.

The third argument is simply the list containing the script.

> parse :: [Program] -> Program -> String -> Either String Program

Our strategy for parsing a brainfuck program is as follows:
Given a Brainfuck program (Like `,+[-.,+]`, which is the shortest
`cat` that ever was or will be), we parse the ordinary control
characters until we hit a loop (`[-.,+]`). That loop is actually a
subprogram to parse:

    parse ",+[-.,]+"

results in "I got `,+` so far, now parse the subprogram."

The parser then pushes what we got so far onto the stack:

    [ Get , Inc 1 ]

and goes on parsing the subprogram as if it was an ordinary program.
When reaching the end of the subprogram (= the end of the loop, `]`)
we push the subprogram into the topmost 'super program':

    [ Get , Inc 1 , Loop [ ... ] ]

If the parser were to parse "++[.,[,]-]" it would do

    parse "++[.,[,]-]"

which results in

    [ Get , Put ]
    [ Inc 1 , Inc 1 ]

reading the subprogram ",". Encountering `]` it will then push
the subprogram `[ Get ]` we just read into the topmost program
as a subprogam (a `Loop`):

    [ Get , Put , Loop [ Get ] ]
    [ Inc 1 , Inc 1 ]

At the end we are left with an empty stack of programs and the
complete program:

    [ Inc 1 , Inc 1 , Loop [ Get , Put , Loop [ Get ] , Inc (-1) ] ]

This technique is known as shift-reduce parsing
(push on the stack, combine with topmost;
 or: shift through the input, fold ("reduce") into a Tree).

See http://en.wikipedia.org/wiki/Shift-reduce_parser


Here is the implementation:

The parser distinguishes whether its input argument (the script)
actually contains a character or does not contain anything anymore:

> parse blocks block = \case
> 
>     x : xs -> case x of

In case of the 6 easy commands, we just go on (`next`), putting the
command read in the program (see the definition of `next`).

>         '.' -> next $ Put
>         ',' -> next $ Get
>         '+' -> next $ Inc 1
>         '-' -> next $ Inc -1
>         '>' -> next $ Mem 1
>         '<' -> next $ Mem -1

In case of the opening rectangular bracket (`[`) we take the current
program (`block`) and push it onto the first accumulator. The now following
subprogram is yet empty (`[]`). Read the rest (`xs`).

>         '[' -> parse (block : blocks) [] xs

A closing bracket poses a challenge. If we do not have any 'super programs'
we have nothing to continue parsing on (this is the case when there is a
closing bracket with no opening one preceeding it).

In all other cases (`otherwise`) we use the tail of the current stack of
'super programs' and continue on the head.

Note since that lists in Haskell allow only for efficient appending at
the front we have to reverse the block which defines the `Loop` which
is now completely read.

>         ']'
>           | null blocks -> fail "encountered closing brace while there is no opening one"
>           | otherwise   -> parse (tail blocks) (Loop (reverse block) : head blocks) xs

Every character that is not one of the 8 control characters of Brainfuck
is ignored and we just continue parsing the rest (`xs`) of the script
without changing any of the given arguments (`blocks` and `block`).

>         _ -> parse blocks block xs

`next` is defined as "prepend the new command to the current block
                      and go on parsing the rest":

>       where
>         next = \cmd -> parse blocks (cmd : block) xs

When we run out of characters ('end of file', 'the empty script')
we check whether there are `blocks` remaining (everything is fine
if the stack of 'super programs' is empty). If there are super programs
remaining we are stuck in an unclosed loop.

>     _
>       | null blocks -> return (reverse block)
>       | otherwise   -> fail "unclosed open braces left"

That is the complete parser which turns a
`String` (a list of characters, `[Char]`)
into a `Program`.


The Optimizer
-------------

Brainfuck programs are utterly inefficient. Part of that
stems from the fact that there is no way of expressing
"add 17 to the current memory cell" (you do "add 1" 17 times).
We can do better by optimizing our program.

> optimize :: Program -> Program

The optimizer combines adjacent `Inc` and `Mem` operations:

> optimize = \case
>     Inc n : Inc m : zs -> optimize $ Inc (n + m) : zs
>     Mem n : Mem m : zs -> optimize $ Mem (n + m) : zs

Note that `$` is just an infix operator doing function application
(`($) :: (a -> b) -> a -> b`). Haskell programmers typically use `$`
to get rid of too many distracting (annoying?) parenthesis.

So `optimize $ ...` is really the same thing as `optimize (...)`.

In case of a loop it recursively descends into that subprogram:

>     Loop xs : zs       -> Loop (optimize xs) : optimize zs

In all other cases it leaves the current command untouched (`z`)
and proceeds optimizing the rest (`optimize zs`).

>     z : zs             -> z : optimize zs

Everything else (the only matching case is [] actually) results
in the empty program (`[]`, since programs are defined as lists of ASTs).

>     _                  -> []

That was fun! We are now able to parse a Brainfuck script into a
`Program` and we even optimize it.


The Brainfuck Virtual Machine
-----------------------------

A Brainfuck script executes on the Brainfuck VM, which consists of
a memory, an input, and a call stack.

> data VM = VM {
>     memory    :: Memory
>   , input     :: Input
>   , callStack :: [Program]
>  }

While in most imperative languages one would model the memory as
a mutable array, we do not do that in Haskell. Also the Brainfuck
specification does not impose any limits on the memory (it is
basically endless in both directions).

This is how you might model the Brainfuck VM's Memory:

    0 0 0 0 4 8 9 0 3 0 3 1 0
                ^

It is finite (there are bounds left and right) and there is a
pointer pointing at the current cell. An imperative program would
then just change that cell the pointer is pointing at.

We use a different approach: The Brainfuck Memory is actually
three things:

+ The current cell
+ The memory in front of the current cell
+ The memory behind the current cell

These might be modeled as lists. So the above memory instance
would become:

+ 9
+ `[ 8, 4, .. ]` (preceeding)
+ `[ 0, 3, 0, 3, 1, .. ]` (following)

Note that the dots imply that the list might be infinitely large
(the rest is assumed to be zeros).

Here is how we might write that model down in Haskell:

> type Memory = ([Word], Word, [Word])

The input is just a list of `Word`s:

> type Input = [Word]

We may define a factory for creating VMs with an empty memory and empty
call stack using a given input like so:

> mkVM :: Input -> VM
> mkVM input = VM { memory = ([], 0, []), input = input, callStack = [] }

Running the Brainfuck VM takes an existing VM and a Program, returning
its output (a list of `Word`s that were put using `Put` (`.` in BF)).

> exec :: VM -> Program -> [Word]
> 
> exec vm@(VM { .. }) (command : commands) = case command of
> 
>     Inc n -> next (updateMemory (upd (+ n)) vm)
> 
>     Mem n -> next (updateMemory (move n)    vm)
> 
>     Get
>       | null input -> []
>       | otherwise  -> next (updateInput tail . updateMemory (upd (const (head input))) $ vm)
> 
>     Put -> cell : next vm
> 
>     Loop commands'
>       | cell == 0 -> next vm
>       | otherwise -> exec (vm { callStack = commands' : commands : callStack }) commands'
> 
>   where
>     next = \vm' -> exec vm' commands
> 
>     (_, cell, _) = memory
> 
>     upd f (lc, cc, rc) = (lc, f cc, rc)
> 
>     move n mem@(lc, cc, rc)
>       | n > 0     = move (n - 1) (cc : lc, safeHead 0 rc, drop 1 rc)
>       | n < 0     = move (n + 1) (drop 1 lc, safeHead 0 lc, cc : rc)
>       | otherwise = mem
> 
>     safeHead def = \case
>         x : _ -> x
>         _     -> def
> 
>     updateMemory f vm@(VM { .. }) = vm { memory = f memory }
>     updateInput  f vm@(VM { .. }) = vm { input  = f input }
> 
> exec vm@(VM { .. }) [] = case callStack of
> 
>     commands : commands' : callStack'
>       | cell == 0 -> exec (vm { callStack = callStack' }) commands'
>       | otherwise -> exec vm commands
> 
>     _ -> []
> 
>   where
>     (_, cell, _) = memory

