# Milestone 6 — Pipes

**Goal:** `ls | wc -l` works. Then `ls | grep .c | wc -l`.

The final milestone, and the one where everybody deadlocks at least once.

---

## Background

*Two hours.*

- **[Beej's Guide to Unix IPC — Pipes](https://beej.us/guide/bgipc/html/#pipes)**
  Short, and directly on target. Read the whole pipes section.
- `man 2 pipe` — note it fills in an array of **two** fds and which end is
  which.
- Re-skim your `dup2` notes from milestone 5. This is that, twice.

---

## The concept

### What a pipe is

```c
int fd[2];
pipe(fd);
```

A kernel buffer with two ends:

- `fd[0]` — the **read** end
- `fd[1]` — the **write** end

Mnemonic: 0 is stdin-ish (read), 1 is stdout-ish (write). Write bytes into
`fd[1]`, read them out of `fd[0]`.

### The shape of `ls | wc -l`

```
      ┌──────────┐                    ┌──────────┐
      │   ls     │ fd 1 ──> pipe ──> fd 0 │  wc -l   │
      └──────────┘                    └──────────┘
```

Two children. The left one's stdout is the pipe's write end; the right one's
stdin is the pipe's read end. Both are `dup2` — exactly what you did in
milestone 5, just pointing at a pipe instead of a file.

The parent creates the pipe *before* forking, so both children inherit it.

### The bit that will get you

**A pipe's read end returns EOF only when every write end is closed.**

After `pipe()` then two `fork()`s, the write end exists in *three* processes:
the parent and both children. If the parent forgets to close its copy, then
from `wc`'s point of view a writer is still alive — so it waits. Forever.

`ls` finishes. `wc` hangs. Your shell hangs waiting for `wc`. Nothing is
crashed, nothing is wrong in any way a debugger will show you. It just sits
there.

**Close every pipe fd you are not actively using — in the parent and in both
children.** This is not tidiness; it is the correctness condition.

### Wait for both

The parent forks twice, so it waits twice. `wc` may well finish before `ls`
does — don't assume an order.

---

## Build it

### Part A — two stages

Start with exactly one pipe. Get `ls | wc -l` working before anything else.

1. Split the token list on `|` into two commands.
2. `pipe(fd)`.
3. `fork` the left child: `dup2(fd[1], 1)`, close **both** `fd[0]` and `fd[1]`,
   then exec.
4. `fork` the right child: `dup2(fd[0], 0)`, close both, then exec.
5. **Parent: close both ends.** Yes, both. Say out loud why.
6. `waitpid` twice.

Write down, before coding, which of the four fds each of the three processes
should close. Getting this on paper first will save you an evening.

### Part B — n stages

Generalise to `a | b | c | ...`. Loop, carrying "the read end of the previous
pipe" from one iteration to the next.

Design decision worth thinking about: do you create all the pipes up front, or
one per iteration and close as you go? One is much easier to get right.

### Part C — combine with milestone 5

`ls | grep .c > out.txt` should work. Redirection applies to individual
commands within the pipeline; the pipe applies between them. If your data
structures are right this is nearly free — if it's painful, that's information
about your design.

---

## Traps

- **The hang.** Covered above. It is *always* an unclosed write end. When it
  happens, list every process holding that fd and find the one you forgot.
- **`dup2` before closing, not after.** Order matters. Duplicate first, then
  close the originals.
- **Closing an fd you still need.** The opposite failure. `dup2` first.
- **Only waiting once.** You leave a zombie and may return to the prompt before
  output is finished.
- **Builtins in a pipeline.** `echo hi | cat` — `echo` is external, fine. But
  what should `cd /tmp | wc` do? Real shells run the builtin in a subshell and
  the `cd` has no effect. Note the issue; you don't have to solve it.

### Debugging a hang

`Ctrl-C`, then:

```sh
ps -o pid,stat,command | grep -E "myshell|wc|ls"
```

A process in state `S` is sleeping — waiting on something. That's your
unclosed fd. On macOS `lsof -p <pid>` will show you exactly which descriptors
a process still holds.

---

## Done when

```sh
myshell> ls | wc -l
      12
myshell> ls | grep '\.c' | wc -l
       3
myshell> cat < in.txt | sort | uniq > out.txt
myshell> echo done
done
```

Cross-check every result against `zsh`. Same input, same output.

- No hangs.
- No zombies.
- `make asan` clean.
- `git commit -m "milestone 6: pipes"`.

---

## Questions

1. Why does the parent close both ends of the pipe immediately after forking?
2. `wc` waits for EOF on its stdin. What exactly causes that EOF to arrive?
3. Why does an unclosed write end hang rather than error?
4. What's in the pipe — a file on disk, or something else? Where does the data
   live?
5. What happens if `ls` produces more output than the pipe buffer can hold
   before `wc` reads any of it? (This one is worth looking up. It's the reason
   pipes work on files of any size.)

---

## You're done

You have a shell that runs commands, has builtins, redirects, and pipes. That
is not a toy — it's the core of what a shell *is*, and you built every part of
it from syscalls.

### What you skipped, and what it'd cost

| Feature | The concept behind it |
|---|---|
| Ctrl-C not killing the shell | Signals, `sigaction` |
| `sleep 10 &` | Process groups, `SIGCHLD` reaping |
| `fg` / `bg` / Ctrl-Z | Job control, `tcsetpgrp` — genuinely hard |
| `echo "a b"` as one arg | Quoting. A real parser. |
| `$HOME`, `$?` | Variable expansion |
| `*.c` | Globbing (`man 3 glob`) |

Quoting and variables are the most *useful* next steps. Signals and job
control are the most *educational*.

### Now read someone else's

This is the point where reading a reference implementation pays off. Compare
your structure to:

- **[dash](https://git.kernel.org/pub/scm/utils/dash/dash.git/)** — small,
  POSIX, readable.
- **[Stephen Brennan's tutorial shell](https://brennan.io/2015/01/16/write-a-shell-in-c/)**
  — tiny, and now safe to read.
- **bash** — enormous. Interesting to grep, not to read.

Ask yourself where they made different choices than you did, and why.

### Then C++

You said you don't want to be stuck in C forever, and this is a good exit
point. Worth noticing on the way out: RAII exists precisely because of the
`close`/`free` discipline you just spent five milestones maintaining by hand.
You'll appreciate destructors more having done this.
