CC = gcc
FLAGS = -ansi -Wall -pedantic -O3
PREFIX = /usr/local

bf: bf.c
	$(CC) $(FLAGS) -o $@ $<

install: bf
	mv bf $(PREFIX)/bin

helloworld: helloworld.c
	$(CC) $(FLAGS) -o $@ $<

helloworld.c: helloworld.bf bf
	./bf -c $< > $@

haskell: Naive SamB

Naive: Brainfuck/Naive.hs Brainfuck/NaiveInterpreter.hs
	ghc --make Brainfuck/NaiveInterpreter.hs -o Naive

SamB: Brainfuck/SamB.hs
	ghc --make Brainfuck/SamB.hs -o SamB

clean:
	rm -f bf
	rm -f helloworld
	rm -f helloworld.c
	rm -f Brainfuck/*.o Brainfuck/*.hi
	rm -f Naive
	rm -f SamB

.PHONY: clean
