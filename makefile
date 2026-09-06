objects = main.o greet.o
CC     = cc
CFLAGS = -std=c11 -Wall -Wextra -Wstrict-prototypes -g


hellomake: $(objects)
	$(CC) $(CFLAGS) -o hellomake $(objects)

main.o: src/main.c src/greet/greet.h
	$(CC) $(CFLAGS)  -c src/main.c

greet.o: src/greet/greet.c src/greet/greet.h
	$(CC) $(CFLAGS)  -c src/greet/greet.c

.PHONY : clean
clean :
	rm hellomake $(objects)
