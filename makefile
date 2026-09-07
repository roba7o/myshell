objects = main.o
CC     = cc
CFLAGS = -std=c11 -Wall -Wextra -Wstrict-prototypes -g -fsanitize=address


myshell: $(objects)
	$(CC) $(CFLAGS) -o myshell $(objects)

main.o: src/main.c
	$(CC) $(CFLAGS)  -c src/main.c


.PHONY : clean
clean :
	rm myshell $(objects)
