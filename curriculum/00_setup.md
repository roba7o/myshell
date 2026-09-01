# Milestone 0 — Setup

**Goal:** `make` produces a `./myshell` that starts, prints something, and
exits. Nothing more.

Boring, but you want the build working before you're also debugging `fork`.

---

## Background

None. Get building.

If your `make` is rusty, lecture 17 of the tutorial covers it.

---

## What's already here

A `Makefile` is provided — you're here to learn operating systems, not to
fight `make`. Read it anyway, it's short:

```make
CFLAGS  = -std=c11 -Wall -Wextra -Wstrict-prototypes -g
SRC     = $(wildcard src/*.c)
```

| Flag | Why |
|---|---|
| `-std=c11` | Pin the language version. No surprises. |
| `-Wall -Wextra` | You already know these. Non-negotiable. |
| `-Wstrict-prototypes` | Catches `int main()` where you meant `int main(void)`. |
| `-g` | Debug symbols, so ASan and lldb can name your lines. |
| `$(wildcard src/*.c)` | Any `.c` you add to `src/` gets compiled. No Makefile edits later. |

There's also `make asan`, which rebuilds with AddressSanitizer. Use it often.

---

## Build it

1. Create `src/main.c`. A `main` that prints a banner and returns 0 is plenty.
2. Run `make`. Confirm `./myshell` runs.
3. Run `make asan`, confirm `./myshell_asan` runs.
4. Run `make clean`, confirm both disappear.
5. `git add -A && git commit -m "milestone 0: scaffold"`.

---

## Think ahead

You're about to write a program that reads lines, splits them into words,
runs programs, and manages file descriptors. That's four separate jobs.

Don't design it all now — you don't know enough yet, and premature structure
is worse than none. But **expect to split `main.c` up around milestone 3**,
probably into something like `input`, `parse`, and `exec`. The `wildcard` in
the Makefile means new files just work.

---

## Done when

```
make && ./myshell && make clean
```

runs without warnings and without complaint.
