CC = gcc
FLAGS = -ansi -Wall -pedantic -O3

brainfuck: brainfuck.c
	$(CC) $(FLAGS) -o $@ $<

helloworld: helloworld.c
	$(CC) $(FLAGS) -o $@ $<

helloworld.c: helloworld.bf brainfuck
	./brainfuck -c $< > $@

Interpreter: Brainfuck.hs Interpreter.hs
	ghc --make Interpreter.hs

clean:
	rm -f brainfuck
	rm -f helloworld
	rm -f helloworld.c
	rm -f *.o *.hi
	rm -f Interpreter

.PHONY: clean
