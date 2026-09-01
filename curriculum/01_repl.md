# Milestone 1 — The REPL

**Goal:** a prompt that reads a line, echoes it back, and loops until you type
`exit` or press Ctrl-D.

No commands run yet. This is the skeleton every shell sits on.

---

## Background

*20 minutes.*

- `man 3 getline` — read it properly. Note that it **allocates for you** and
  can grow the buffer. This solves the "what if the line is longer than my
  array" problem you hit in `11_strings`.
- `man 3 fgets` — the alternative. You know this one.
- Skim [Beej's IPC guide, section 1](https://beej.us/guide/bgipc/) for the
  general shape of things. Don't study it yet.

---

## The concept

A shell is a **R**ead–**E**val–**P**rint **L**oop. Forever:

```
print a prompt
read a line
if it's empty or EOF, handle it
evaluate it        <- this is milestones 2-5
loop
```

Two things about the terminal that will confuse you if you don't know them now:

**Buffering.** `stdout` to a terminal is *line buffered* — nothing appears
until you write a `\n`. Your prompt has no newline (that's the point of a
prompt). So it can sit invisible in the buffer while your shell waits for
input, and your shell looks frozen. You met this in `11_strings`. Same fix.

**EOF is not an error.** Ctrl-D at the start of a line means "no more input."
Every read function reports this differently:

| Function | On EOF |
|---|---|
| `fgets` | returns `NULL` |
| `getline` | returns `-1` |
| `scanf` family | returns `EOF` (which is `-1`, and is *not* `0`) |

A shell that ignores EOF spins forever at 100% CPU when its stdin closes. You
saw exactly this in the `abc` retry loop.

---

## Build it

1. **The loop.** Print a prompt, read a line, print `You typed: <line>`, repeat.
2. **Choose your reader.** `getline` or `fgets`. If you pick `fgets`, decide
   what happens when someone types a 500-character line — and try it.
3. **Handle EOF.** Ctrl-D should exit cleanly, not hang and not crash.
4. **Handle the empty line.** Just pressing enter should re-prompt, not error.
5. **Strip the trailing newline.** Both readers keep it. You'll be comparing
   this string against `"exit"` shortly, and `"exit\n" != "exit"`.
6. **Add `exit`.** A literal string compare for now — proper builtins are
   milestone 3.

---

## Traps

- **Invisible prompt.** See buffering above.
- **The newline you forgot to strip.** It will haunt every string comparison
  and every `execvp` argument. Kill it at the source, once.
- **`getline` leaks.** It mallocs. You free it — once, at the end. Read the man
  page on reusing the buffer across calls; it's cleverer than it looks.
- **Ctrl-C.** Right now it kills your shell. That's expected — signals are
  beyond our scope. Don't fix it yet.

---

## Done when

```sh
$ ./myshell
myshell> hello world
You typed: hello world
myshell> 
myshell> exit
$
```

And both of these terminate rather than hanging:

```sh
echo "hi" | ./myshell
./myshell < /dev/null
```

And this is clean:

```sh
make asan && ./myshell_asan   # type a few lines, then Ctrl-D
```

---

## Questions

1. Why does a prompt need `fflush(stdout)` but `printf("hello\n")` doesn't?
2. `getline` mallocs a buffer for you. Who owns it — and what does that mean
   about where `free` goes?
3. What's the difference between "user pressed enter on an empty line" and
   "input has ended"? How does your code tell them apart?
