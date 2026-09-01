# Building a Shell in C

A self-directed course. Five milestones, each one a working shell that does
more than the last.

## How this works

Each milestone file has the same shape:

| Section | What it's for |
|---|---|
| **Goal** | What your shell can do when you're finished |
| **Background** | Free reading, with what to focus on. Do this *first*. |
| **The concept** | The OS mechanism, explained. Read before coding. |
| **Build it** | Tasks. Deliberately not pseudocode. |
| **Traps** | Bugs that will bite you. Read *before* you get stuck. |
| **Done when** | Concrete checks. Run them. |
| **Questions** | Answer in your own words before moving on. |

**These files never contain the solution.** They tell you which syscall you
need and what it does; wiring it up is yours. That's the whole point — if you
want a finished shell there are hundreds on GitHub.

## The rules

1. **Read the background first.** Ten minutes of reading saves two hours of
   flailing at a man page.
2. **Commit at each milestone.** `git commit -m "milestone 2: fork and exec"`.
   You want to be able to look back at how it grew.
3. **Answer the questions in writing.** In a comment, in a notes file, out
   loud to the wall. Feynman's rule: if you can't explain it, you don't have it.
4. **Run `make asan` regularly.** Memory bugs in C hide until they don't.
5. **Don't read a reference shell implementation** until you've finished a
   milestone. Then read one and compare — that part is genuinely useful.

## Milestones

| # | File | You'll learn | Roughly |
|---|---|---|---|
| 0 | [Setup](curriculum/00_setup.md) | Project layout, build, sanitizers | an hour |
| 1 | [The REPL](curriculum/01_repl.md) | Terminal I/O, buffering, EOF | 2–4 hours |
| 2 | [fork and exec](curriculum/02_fork_exec.md) | **Processes.** The big one. | a week |
| 3 | [Builtins](curriculum/03_builtins.md) | Why `cd` can't be a program | 2–4 hours |
| 4 | [Redirection](curriculum/04_redirection.md) | File descriptors, `dup2` | a week |
| 5 | [Pipes](curriculum/05_pipes.md) | IPC, and why shells deadlock | a week |

Milestone 2 is the conceptual jump. Everything after it is variations on
"arrange the file descriptors, then exec."

## Core references

You'll use these throughout. All free.

- **[OSTEP](https://pages.cs.wisc.edu/~remzi/OSTEP/)** — *Operating Systems:
  Three Easy Pieces*. Free PDF chapters, genuinely well written. The
  Virtualization section is what you want.
- **[Beej's Guide to Unix IPC](https://beej.us/guide/bgipc/)** — short,
  practical, funny. Covers fork, pipes, signals.
- **`man`** — `man 2 fork`, `man 2 dup2`. Section 2 is syscalls, section 3 is
  library functions. `man 3 printf` vs `man 1 printf` matters.
- **[POSIX spec: Shell Command Language](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)**
  — the actual standard. Dry, but it's the source of truth for *what a shell
  is supposed to do*.

### One warning

Stephen Brennan's *Write a Shell in C* is the top Google result and it is a
good article — but it hands you working code for milestones 1–3. Read it
**after** you've done them, as a comparison. Reading it first turns this into
a typing exercise.

## A note on scope

We stop after pipes. That's a real shell: it runs commands, has builtins,
redirects, and pipes. What's missing is signal handling (Ctrl-C behaves oddly),
background jobs (`&`), and job control (`fg`/`bg`).

Those are worth doing if you enjoy it, but they are a long tail of fiddly
detail with a lower concept-per-hour ratio. You said you don't want to be
stuck in C forever — five milestones is the right amount to take with you into
C++.
