# Milestone 4 — Redirection

**Goal:** `ls > out.txt`, `wc -l < out.txt`, `echo hi >> out.txt` all work.

Now you find out what that gap between `fork` and `exec` is *for*.

---

## Background

*One hour.*

- **[OSTEP Chapter 39 — Files and Directories](https://pages.cs.wisc.edu/~remzi/OSTEP/file-intro.pdf)**
  Read the sections on file descriptors and on `dup2`. The redirection example
  near the end is exactly this milestone.
- `man 2 open` — the flags matter: `O_WRONLY`, `O_CREAT`, `O_TRUNC`, `O_APPEND`.
  Note that `O_CREAT` requires a third argument.
- `man 2 dup2` — short page, read every line.
- `man 2 close`.

---

## The concept

### A file descriptor is an index

Every process has a table of open files. A file descriptor is just an **index
into that table** — a small integer, nothing more.

Three are open before your program starts:

| fd | Name | Where it points by default |
|---|---|---|
| 0 | stdin | your keyboard |
| 1 | stdout | your terminal |
| 2 | stderr | your terminal |

When `printf` writes, it writes to **fd 1**. It has no idea what's on the other
end — terminal, file, pipe, socket. It just writes to slot 1.

### The trick

That indirection is the whole mechanism. `ls` writes to fd 1 unconditionally.
So to send its output to a file, you don't change `ls` — you change **what fd
1 points at** before `ls` starts running.

```
dup2(fd, 1)
```

means: *make slot 1 point at whatever `fd` points at.* If slot 1 was already
open, it's closed first. Now anything written to fd 1 goes to your file.

### Where this has to happen

**In the child, after `fork`, before `exec`.**

- Not in the parent — you'd redirect your own shell's output into the file and
  never see a prompt again.
- Not after `exec` — there is no "after exec". Your code is gone.

That gap is the only place it can go. This is the answer to question 5 of
milestone 2.

### Why it survives exec

`exec` replaces your program's *memory*, but the file descriptor table belongs
to the **process**, not the program. It survives. So the redirection you set up
is still in place when `ls` starts.

That single fact is what makes Unix redirection work.

---

## Build it

### Part A — parse the operators

Find `>`, `<`, `>>` in the token list. For each, the *next* token is the
filename, and neither the operator nor the filename is part of `argv`.

```
ls -l > out.txt
->  argv = {"ls", "-l", NULL},  stdout goes to "out.txt"
```

Decide how you carry that information from the parser to the child. A small
struct is the obvious move — you did lecture 13.

Handle the error cases: `ls >` with no filename, and `>` on its own.

### Part B — apply it

In the child, after `fork`, before `exec`:

1. `open` the file with the right flags.
2. Check for failure. `perror` and `_exit`.
3. `dup2` onto fd 0 or 1.
4. `close` the original fd — it's redundant now, and leaked fds accumulate.
5. `exec`.

### Part C — the flags

Work out from `man 2 open` what `>` and `>>` need:

- `>` — write, create if missing, and **truncate** if it exists.
- `>>` — write, create if missing, and **append**.
- `<` — read only.

And when you pass `O_CREAT`, what's the third argument, and what does `0644`
mean? Look it up; you'll meet those numbers for the rest of your career.

---

## Traps

- **Redirecting in the parent.** Your shell's own stdout goes to the file. No
  more prompt. If your shell goes silent after one command, this is it.
- **Forgetting to `close`.** Works fine at first. Then you run 250 commands and
  hit the per-process fd limit. Check yours with `ulimit -n`.
- **`open` failing silently.** A read redirect from a missing file must be an
  error, not an empty read.
- **Truncating too early.** `> file` truncates when it's opened. Think about
  `cat file > file` — and try it, in a scratch directory.
- **Leaving the operators in `argv`.** Then `ls` gets a literal `>` argument
  and complains it can't find a file called `>`.

---

## Done when

```sh
myshell> ls > out.txt
myshell> cat out.txt
(the listing)
myshell> wc -l < out.txt
      12
myshell> echo appended >> out.txt
myshell> tail -1 out.txt
appended
myshell> cat < nonexistent
myshell: nonexistent: No such file or directory
myshell> echo still alive
still alive
```

The last two matter: a failed redirect must not kill your shell.

Then check for fd leaks — run 50 redirects in a loop and confirm your shell
still works.

`git commit -m "milestone 4: redirection"`.

---

## Questions

1. Why must `dup2` happen in the child rather than the parent?
2. `exec` wipes out your program. Why does the redirection survive it?
3. `ls` has no idea it's writing to a file. Why is that a *good* design?
4. What does `dup2(fd, 1)` do to whatever fd 1 pointed at before?
5. You now have two file descriptors pointing at the same file. Why close one?
