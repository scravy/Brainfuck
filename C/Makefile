CC = gcc
FLAGS = -ansi -Wall -pedantic -O3
PREFIX = /usr/local

bf: bf.c
	$(CC) $(FLAGS) -o $@ $<

install: bf
	mv bf $(PREFIX)/bin

helloworld: helloworld.c
	$(CC) $(FLAGS) -o $@ $<

prime: prime.c
	$(CC) $(FLAGS) -o $@ $<

helloworld.c: ../_scripts/helloworld.bf bf
	./bf -c $< > $@

prime.c: ../_scripts/prime.bf bf
	./bf -c $< > $@

clean:
	rm -f bf
	rm -f helloworld
	rm -f helloworld.c
	rm -f prime
	rm -f prime.c

.PHONY: clean
