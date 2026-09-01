# Milestone 3 — fork and exec

**Goal:** `ls -l`, `echo hello`, `/bin/date` all actually run.

**This is the milestone.** Everything before it was setup; everything after is
variations. Take your time here. A week is normal.

---

## Background

*Two hours. Do it properly — this is the conceptual core.*

- **[OSTEP Chapter 4 — The Abstraction: The Process](https://pages.cs.wisc.edu/~remzi/OSTEP/cpu-intro.pdf)**
  What a process *is*: address space, registers, open files.
- **[OSTEP Chapter 5 — The Process API](https://pages.cs.wisc.edu/~remzi/OSTEP/cpu-api.pdf)**
  `fork`, `exec`, `wait`, and *why they are separate calls*. This chapter is
  the single best explanation of this material anywhere. Read it twice.
- `man 2 fork` — focus on RETURN VALUES. It returns twice.
- `man 3 exec` — read the whole family table. Know why you want `execvp`.
- `man 2 waitpid` — and the `WIFEXITED` / `WEXITSTATUS` macros.

---

## The concept

### fork returns twice

This is the sentence that breaks people, so sit with it:

```
pid_t pid = fork();
```

After this line, **there are two processes**, both executing this same line,
both about to look at `pid`. They have identical memory — but they are copies,
not shared.

| In the... | `pid` holds |
|---|---|
| parent | the child's PID (a positive number) |
| child | `0` |
| parent, on failure | `-1` |

So `if (pid == 0)` is how a process asks *"am I the child?"* Both branches of
that `if` run — in different processes.

### exec replaces, it doesn't call

`execvp("ls", args)` does **not** run `ls` and come back. It throws away the
current program — your code, your variables, all of it — and replaces it with
`ls` in the same process.

**A successful `exec` never returns.** So any line after it only executes if
it *failed*. That's not a quirk to work around; it's how you detect failure.

### Why two calls?

Because between `fork` and `exec`, the child is *your code running in a fresh
process*. That gap is where you set things up — change directory, redirect
file descriptors, reassign stdin. Milestones 5 and 6 live entirely inside that
gap. A combined "spawn" call would give you nowhere to stand.

### argv must be NULL-terminated

`execvp` takes `char *const argv[]`. It has no length parameter — it walks the
array until it finds `NULL`. Forget that and it walks off into garbage memory.

For `ls -l`:

```
argv[0] = "ls"      <- yes, the program name goes in argv[0]
argv[1] = "-l"
argv[2] = NULL
```

This is the `char **` from lecture 12, in the wild.

---

## Build it

### Part A — the tokenizer

Split `"ls -l /tmp"` into a `NULL`-terminated `char **`.

- `strtok` is the easy route. Read `man 3 strtok` carefully — it **modifies
  the string you give it** and keeps hidden state between calls. Know both
  before you use it.
- Decide your storage: fixed `char *argv[64]`, or malloc'd and grown. Either
  is fine now. Write down which you chose and why.
- Split on spaces and tabs. Quoting (`echo "a b"`) is a rabbit hole — skip it,
  note it as future work.

Test the tokenizer on its own before wiring it to anything.

### Part B — run one command

1. `fork()`.
2. Check for `-1`. Fork *can* fail.
3. In the child: `execvp(argv[0], argv)`.
4. In the child, after the exec: it failed. Print an error (`perror` is your
   friend) and terminate the child — **with `_exit(127)`, not `return`.**
5. In the parent: `waitpid` for the child.
6. Report the exit status using `WIFEXITED` and `WEXITSTATUS`.

### Part C — see it for yourself

Before the exec, have both processes print their own `getpid()` and their
`getppid()`. Watch two processes appear from one line of code. Delete it after
— but do it once.

---

## Traps

- **`return` instead of `_exit` after a failed exec.** The child would fall
  back into your shell's loop — and now you have *two shells* reading the same
  terminal, fighting over every keystroke. Bewildering to debug. Use `_exit`.
- **Forgetting `argv[0]`.** The program name is the first argument, not
  separate from them. `ls -l` is `{"ls", "-l", NULL}`.
- **Forgetting the `NULL`.** Undefined behaviour, and ASan will catch it.
- **Not waiting.** The child becomes a zombie. Run `ps` and look for `<defunct>`
  / `Z` — do this deliberately once, so you recognise it later.
- **`strtok` on a string literal.** It writes into its argument. A literal is
  read-only memory; you get a crash. Your input buffer from `getline` is fine.
- **Assuming exec returns on success.** It doesn't. Ever.

---

## Done when

```sh
myshell> ls -l
(real listing)
myshell> echo hello world
hello world
myshell> /bin/date
(the date)
myshell> nonexistent_command
myshell: nonexistent_command: No such file or directory
myshell> exit
```

- Your shell survives a failed command and keeps prompting.
- `ps` shows no zombies after running several commands.
- `make asan` is clean.
- `git commit -m "milestone 3: fork and exec"`.

---

## Questions

Answer these in writing. If you can't, re-read OSTEP 5.

1. After `fork()`, how many processes are executing the next line?
2. Why does `fork` return `0` to the child but a PID to the parent? Why not
   the other way round, or the same value to both?
3. What happens to the child's memory when `exec` succeeds?
4. Why must a shell `wait` for its children? What is a zombie, concretely?
5. What would break if there were a single `spawn(program, args)` call instead
   of `fork` + `exec`? Be specific — name a shell feature that becomes
   impossible.

Question 5 is the one that matters. It's the reason for the next three
milestones.
