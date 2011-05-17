CC = gcc
FLAGS = -ansi -Wall -pedantic -O3

brainfuck: brainfuck.c
	$(CC) $(FLAGS) -o $@ $<

clean:
	rm -f brainfuck

.PHONY: clean
