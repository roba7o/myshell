FILE = src/main.c
CC     = cc
CFLAGS = -std=c11 -Wall -Wextra -Wstrict-prototypes -g
ASAN_FLAG = -fsanitize=address


myshell: $(FILE)
	$(CC) $(CFLAGS) -o myshell $(FILE)

asan: $(FILE)
	$(CC) $(CFLAGS) $(ASAN_FLAG) -o myshell_asan $(FILE)

.PHONY : clean asan
clean :
	rm -f myshell myshell_asan
