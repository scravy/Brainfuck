CC = gcc
FLAGS = -ansi -Wall -pedantic -O3

bf: brainfuck.c
	$(CC) $(FLAGS) -o $@ $<

helloworld: helloworld.c
	$(CC) $(FLAGS) -o $@ $<

helloworld.c: helloworld.bf brainfuck
	./bf -c $< > $@

Naive: Brainfuck/Naive.hs Brainfuck/NaiveInterpreter.hs
	ghc --make Brainfuck/NaiveInterpreter.hs

SamB: Brainfuck/SamB.hs
	ghc --make Brainfuck/SamB.hs

clean:
	rm -f bf
	rm -f helloworld
	rm -f helloworld.c
	rm -f Brainfuck/*.o Brainfuck/*.hi
	rm -f Brainfuck/Interpreter
	rm -f Brainfuck/SamB

.PHONY: clean
