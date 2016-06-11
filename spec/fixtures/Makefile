
CC = gcc
CFLAGS=-O2 -Wall -Wextra -Werror -fPIC

%.o: %.c %.h
	$(CC) -c $@ $< $(CFLAGS)

build: fixtures.o
	$(CC) -fPIC -shared -o libfixtures.so -O2 -pipe *.o

clean:
	rm *.o
	rm *.so

