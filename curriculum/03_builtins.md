# Milestone 3 — Builtins

**Goal:** `cd`, `exit`, and `pwd` work. And you understand why they *have* to
be built in.

Short milestone, big idea.

---

## Background

*30 minutes.*

- `man 2 chdir`
- `man 3 getcwd` — note it can allocate for you, or fill a buffer you supply.
- `man 3 getenv` — for `cd` with no arguments.
- `which cd` — run it. Then run `which ls`. Notice the difference, and sit
  with it for a moment before reading on.

---

## The concept

### The question

Every command so far runs in a **child process**. `cd` changes the working
directory. So:

```
fork()                    -> child created
child: chdir("/tmp")      -> child's cwd is now /tmp
child: _exit(0)           -> child dies
parent: still where it started
```

The child changed *its own* working directory and then ceased to exist. The
parent — your shell, the process that actually needs to move — never budged.

**Every process has its own working directory.** It's inherited from the
parent at `fork` time, and changing yours never affects anyone else's. There
is no syscall to change another process's cwd. That's not an oversight, it's
isolation working as designed.

So `cd` cannot be an external program. Not in your shell, not in bash, not
anywhere. It must run **inside the shell process itself** — no fork.

This is why `/bin/cd` either doesn't exist on your system or is a stub that
does nothing useful.

### The general rule

A command must be a builtin if it needs to **change the shell's own state**:

| Builtin | State it changes |
|---|---|
| `cd` | working directory |
| `exit` | whether the shell is alive |
| `export` | the shell's environment |
| `source` | everything — runs commands in the current shell |

Everything else can be a separate program.

---

## Build it

1. **Dispatch before forking.** After tokenizing, check `argv[0]` against your
   builtin list *first*. Fork only if it isn't one. Getting this order wrong
   is the whole lesson.
2. **`cd`**
   - `cd <dir>` — `chdir`, and report failure with `perror`.
   - `cd` with no argument — go to `$HOME`. What if `$HOME` isn't set?
   - Decide what `cd` with two arguments should do.
3. **`exit`**
   - `exit` and `exit 3`. Clean up first — free anything outstanding.
4. **`pwd`** — trivial once you've read `getcwd`, and a good sanity check.
5. **Structure.** You now have two dispatch paths and a growing `main`. This
   is the natural point to split into multiple files. The Makefile already
   picks up anything in `src/`.

---

## Traps

- **Forking for builtins.** Everything appears to work — no error, no crash —
  and `cd` silently does nothing. If your `cd` "runs fine" but `pwd` disagrees,
  this is why.
- **`cd` with no args crashing.** `argv[1]` is `NULL`. Check it.
- **`getenv` returning NULL.** It does that when the variable isn't set.
- **Leaking on `exit`.** Your last chance to free. Check with ASan.

---

## Done when

```sh
myshell> pwd
/Users/you/Documents/programmingSelfStudy/C/myshell
myshell> cd /tmp
myshell> pwd
/tmp
myshell> cd
myshell> pwd
/Users/you
myshell> cd /nonexistent
myshell: cd: /nonexistent: No such file or directory
myshell> exit 3
$ echo $?
3
```

The `cd /tmp` then `pwd` sequence is the proof. If the directory change
persists across two commands, you did it right.

---

## Questions

1. Explain to someone non-technical why `cd` can't be a program like `ls` is.
2. `ls` runs in a child. That child has its own working directory. Where did
   that come from?
3. Why is `exit` a builtin? What would `/bin/exit` even do?
4. Your shell now has two kinds of command. Is that a wart, or is it
   fundamental? Could a shell be designed with only one kind?
