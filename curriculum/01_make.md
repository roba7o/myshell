# Milestone 1 — Make

**Goal:** you write the project `Makefile`. `make`, `make asan`, and
`make clean` all work, and you understand every line you typed.

You skipped this in lecture 17. It's worth an afternoon — you're about to use
it several hundred times.

---

## Background

*30 minutes.*

- [GNU Make Manual, sections 2.1–2.6](https://www.gnu.org/software/make/manual/make.html#Introduction)
  — "An Introduction to Makefiles". Just that chapter.
- `man make`

Skip anything about pattern rules and functions on the first pass.

---

## Why make exists

At the end of milestone 0 you typed this twice:

```sh
cc -std=c11 -Wall -Wextra -Wstrict-prototypes -g -o myshell src/main.c
```

By milestone 4 you'll have five source files. Three problems appear:

1. **Typing.** Long commands, retyped constantly, mistyped occasionally.
2. **Waste.** Changing one file recompiles all five.
3. **Memory.** Come back in three weeks and the flags are gone from your head.

`make` fixes all three. You write the recipe once; it works out what actually
needs rebuilding.

---

## The anatomy of a rule

Every rule has the same three parts:

```make
target: prerequisites
	recipe
```

- **target** — the file to produce (or a name, if it produces nothing)
- **prerequisites** — files it depends on
- **recipe** — shell commands that build it

Read it as a sentence: *"To build `target`, I need `prerequisites`, and here's
how."*

A toy example — not your project:

```make
hello: hello.c
	cc -o hello hello.c
```

*To build `hello` I need `hello.c`, and this is the command.*

### How make decides to do anything

It compares **timestamps**. If `hello` is newer than `hello.c`, there's
nothing to do — you get `make: 'hello' is up to date.` If you edit `hello.c`,
its timestamp jumps ahead, and now the rule runs.

That's the entire mechanism. Not magic, just file dates.

### THE TAB RULE

**Recipe lines must start with a literal TAB character. Not spaces.**

This is make's most notorious wart. Four spaces looks identical on screen and
fails with:

```
Makefile:2: *** missing separator.  Stop.
```

If you see that message, it is nearly always this. VS Code may be configured
to convert tabs to spaces — for `Makefile`, turn that off. Check with:

```sh
cat -A Makefile | head
```

Real tabs show as `^I`.

---

## Things you'll want

### The default goal

Running `make` with no arguments builds **the first target in the file**.
Everything else needs naming: `make asan`.

So put the thing you build most often first.

### Variables

```make
CC     = cc
CFLAGS = -std=c11 -Wall -Wextra -g
```

Use them with `$(CC)` and `$(CFLAGS)`. The point isn't brevity — it's having
**one place** to change a flag rather than four.

### Phony targets

```make
clean:
	rm -f hello
```

`clean` doesn't produce a file called `clean`. So if a file named `clean` ever
existed, make would see it as up to date and refuse to run.

Declaring it phony fixes that:

```make
.PHONY: clean
```

Anything that's a *command* rather than a *file* — `clean`, `test`, `asan` —
should be listed there.

### Automatic variables

Inside a recipe, make defines some shorthands:

| Variable | Means |
|---|---|
| `$@` | the target |
| `$^` | all prerequisites |
| `$<` | the first prerequisite |

So the toy rule becomes:

```make
hello: hello.c
	$(CC) $(CFLAGS) -o $@ $^
```

Same thing, but nothing is repeated. Rename the target and the recipe follows.

### Finding files automatically

```make
SRC = $(wildcard src/*.c)
```

`SRC` becomes every `.c` file in `src/`. Add a new source file and it's picked
up with no Makefile edit — which matters, because you'll split your code up
around milestone 4.

---

## Build it

Write `Makefile` in the project root. Work up in these steps, running `make`
after each so you see what changed.

**Step 1.** One rule that builds `myshell` from `src/main.c`, with the full
flag list from milestone 0. Hardcode everything. Confirm `make` builds it and
running `make` again says it's up to date.

**Step 2.** Pull `CC` and `CFLAGS` out into variables at the top.

**Step 3.** Replace the repeated filenames with `$@` and `$^`.

**Step 4.** Replace `src/main.c` with a `SRC` variable using `wildcard`. Test
it: add a throwaway second `.c` file in `src/`, run `make`, confirm it gets
compiled, then delete it.

**Step 5.** Add an `asan` target that builds `myshell_asan` with
`-fsanitize=address` on top of the normal flags.

**Step 6.** Add `clean`, removing `myshell`, `myshell_asan`, and `*.dSYM`.

**Step 7.** Add the `.PHONY` line. Then test it properly:

```sh
touch clean          # create a file called clean
make clean           # does it still work?
rm -f clean
```

**Step 8.** Add a comment block at the top listing the three targets and what
they do. In three weeks you'll be glad.

---

## Decoding make's error messages

| Message | What it means |
|---|---|
| `missing separator` | Spaces instead of a tab. Always. |
| `No rule to make target 'x'` | You asked for `x` and no rule produces it. Usually a typo or a missing file. |
| `Nothing to be done for 'all'` | Target is up to date. Use `make -B` to force, or `touch` a source. |
| `*** [myshell] Error 1` | Your *compiler* failed, not make. The real error is above this line. |

That last one catches everyone — scroll **up** past make's complaint to find
the actual compiler output.

---

## Done when

```sh
make            # builds ./myshell
make            # says it is up to date
make asan       # builds ./myshell_asan
make clean      # both binaries gone
```

- [ ] Editing `src/main.c` causes the next `make` to rebuild
- [ ] `make` with no changes does nothing
- [ ] `cat -A Makefile` shows `^I` at the start of every recipe line
- [ ] `make clean` works even when a file called `clean` exists
- [ ] You can explain every line without looking it up

```sh
git add -A && git commit -m "milestone 1: makefile"
```

---

## Questions

1. How does make know whether to rebuild? What exactly does it compare?
2. Why does `clean` need `.PHONY` when `myshell` doesn't?
3. What does `make` with no arguments build, and how does it choose?
4. Your Makefile compiles all sources into the binary in one command. Real
   projects compile each `.c` to a `.o` first, then link. What does that buy —
   and why doesn't it matter for a project this size?
5. If `make` says `Error 1`, whose error is it?
