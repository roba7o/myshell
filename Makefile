# myshell -- build file
#
# make          build ./myshell
# make asan     build ./myshell_asan with AddressSanitizer
# make clean    remove binaries

CC      = cc
CFLAGS  = -std=c11 -Wall -Wextra -Wstrict-prototypes -g
SRC     = $(wildcard src/*.c)
TARGET  = myshell

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $(SRC)

asan: $(SRC)
	$(CC) $(CFLAGS) -fsanitize=address -o $(TARGET)_asan $(SRC)

clean:
	rm -rf $(TARGET) $(TARGET)_asan *.dSYM

.PHONY: asan clean
