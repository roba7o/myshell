# Building a Shell in C

A self-directed course. Seven milestones, from an empty directory to a shell
with builtins, redirection, and pipes.

## How this works

Each milestone file has the same shape:

| Section | What it's for |
|---|---|
| **Goal** | What works when you're finished |
| **Background** | Free reading, time-boxed, with what to focus on. Do this *first*. |
| **The concept** | The mechanism, explained. Read before coding. |
| **Build it** | Tasks. Deliberately not pseudocode. |
| **Traps** | Bugs that will bite. Read *before* you get stuck. |
| **Done when** | Concrete checks. Run them. |
| **Questions** | Answer in your own words before moving on. |

**Nothing in this course is written for you.** No starter code, no Makefile,
no skeleton files — you type every character of this project, including the
build system. The curriculum names the syscall you need and explains what it
does; wiring it up is the work.

If you want a finished shell there are hundreds on GitHub. The point is the
hour you spend not understanding `dup2`, followed by the moment you do.

## The rules

1. **Read the background first.** Ten minutes of reading saves two hours of
   flailing at a man page.
2. **Commit at each milestone.** You want to see how it grew.
3. **Answer the questions in writing.** In a comment, a notes file, or out loud
   to the wall. Feynman's rule: if you can't explain it, you don't have it.
4. **Run the sanitiser build regularly.** Memory bugs hide until they don't.
5. **Don't read a reference shell** until you've finished a milestone. Then read
   one and compare — *that* part is genuinely useful.

## Milestones

| # | File | You'll learn | Roughly |
|---|---|---|---|
| 0 | [Environment](curriculum/00_environment.md) | Toolchain, flags, compiling by hand | an hour |
| 1 | [Make](curriculum/01_make.md) | Build systems. You write the Makefile. | an afternoon |
| 2 | [The REPL](curriculum/02_repl.md) | Terminal I/O, buffering, EOF | 2–4 hours |
| 3 | [fork and exec](curriculum/03_fork_exec.md) | **Processes.** The big one. | a week |
| 4 | [Builtins](curriculum/04_builtins.md) | Why `cd` can't be a program | 2–4 hours |
| 5 | [Redirection](curriculum/05_redirection.md) | File descriptors, `dup2` | a week |
| 6 | [Pipes](curriculum/06_pipes.md) | IPC, and why shells deadlock | a week |

Milestone 3 is the conceptual jump. Everything after it is variations on
"arrange the file descriptors, then exec."

## Core references

All free.

- **[OSTEP](https://pages.cs.wisc.edu/~remzi/OSTEP/)** — *Operating Systems:
  Three Easy Pieces*. Free PDF chapters, genuinely well written. Chapters 4, 5
  and 39 are the backbone of this course.
- **[Beej's Guide to Unix IPC](https://beej.us/guide/bgipc/)** — short,
  practical, funny. fork, pipes, signals.
- **[GNU Make Manual](https://www.gnu.org/software/make/manual/make.html)** —
  only the introduction chapter is needed.
- **`man`** — `man 2 fork` for syscalls, `man 3 printf` for library functions.
  The section number matters.
- **[POSIX: Shell Command Language](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)**
  — dry, but it's the source of truth for what a shell is *supposed* to do.

### One warning

Stephen Brennan's *Write a Shell in C* is the top Google result and it's a good
article — but it hands you working code for milestones 2–4. Read it **after**
you've done them, as a comparison. Reading it first turns this into a typing
exercise.

## Scope

We stop after pipes. That's a real shell: it runs commands, has builtins,
redirects, and pipes.

Missing: signal handling (Ctrl-C behaves oddly), background jobs (`&`), job
control (`fg`/`bg`), quoting, and variable expansion. Those are worth doing if
you enjoy it, but they're a long tail of fiddly detail with a lower
concept-per-hour ratio. Seven milestones is the right amount to take with you
into C++.
