CC = gcc
FLAGS = -ansi -Wall -pedantic -O3

brainfuck: brainfuck.c
	$(CC) $(FLAGS) -o $@ $<

helloworld: helloworld.c
	$(CC) $(FLAGS) -o $@ $<

helloworld.c: helloworld.bf brainfuck
	./brainfuck -c $< > $@

clean:
	rm -f brainfuck
	rm -f helloworld
	rm -f helloworld.c

.PHONY: clean
