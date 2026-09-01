# myshell

A POSIX shell, written in C, built from scratch to learn how operating systems
actually work.

This is a **learning project**, not a product. The goal is not a better shell —
it is to make process creation, file descriptors, and IPC concrete by building
them rather than reading about them.

## Start here

[CURRICULUM.md](CURRICULUM.md)

## Build

```
make            # ./myshell
make asan       # ./myshell_asan, with AddressSanitizer
make clean
```

## Layout

```
curriculum/     the course. one file per milestone.
src/            your code.
tests/          your own test scripts.
```
