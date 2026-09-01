# Milestone 0 — Environment

**Goal:** a working C toolchain, a project directory, git initialised, and one
program compiled *by hand* so you know what `make` is going to do for you.

No shell code yet. About an hour.

---

## 0.1 — Check your toolchain

macOS doesn't ship a compiler until you ask for one. Run each of these and
confirm you get a version, not an error:

```sh
cc --version
make --version
git --version
lldb --version
```

If `cc` is missing, or you get a popup about developer tools:

```sh
xcode-select --install
```

That installs the Command Line Tools — about 1GB, a few minutes. You don't
need full Xcode.

**What `cc` actually is on your Mac:** a symlink to `clang`. On Linux it's
usually `gcc`. Both accept the same flags for everything in this course, so
the curriculum says `cc` throughout and it works either way.

---

## 0.2 — Check git is configured

```sh
git config --global user.name
git config --global user.email
```

If either is blank, set them. Commits without an identity are annoying to fix
later.

---

## 0.3 — The directory layout

You're standing in the project root already. Create the source directory:

```sh
mkdir src
```

Target layout by the end of the course:

```
myshell/
├── CURRICULUM.md
├── README.md
├── Makefile          <- you write this in milestone 1
├── .gitignore        <- you write this below
├── curriculum/       <- these files
└── src/              <- your code
```

Keeping code in `src/` rather than the root isn't fussiness — in milestone 1
you'll write a Makefile rule that compiles "everything in `src/`", and that
only works if there's a clean directory to point at.

---

## 0.4 — Write a .gitignore

Create `.gitignore` in the project root. It should stop git tracking:

- the compiled binary `myshell`
- the sanitiser build `myshell_asan`
- object files — `*.o`
- macOS debug bundles — `*.dSYM/` (note the trailing slash, they're directories)

**Why this matters:** binaries are large, change on every build, and are
rebuildable from source. Committing them makes your history enormous and every
diff useless. Rule of thumb: if `make` can regenerate it, git shouldn't track
it.

Check it works — after your first compile, `git status` should not list
`myshell`.

---

## 0.5 — Compile something by hand

Before you automate a task you should feel it. Write `src/main.c` — anything
that prints a line and returns 0 — then compile it manually:

```sh
cc -std=c11 -Wall -Wextra -Wstrict-prototypes -g -o myshell src/main.c
```

Run `./myshell`. Then take the command apart, because you'll be encoding these
choices into a Makefile shortly:

| Flag | What it does | Why you want it |
|---|---|---|
| `-std=c11` | Pin the language standard | Without it you get the compiler's default, which varies. No surprises. |
| `-Wall` | Common warnings | You know these. |
| `-Wextra` | More warnings | Catches unused parameters, sign mismatches. |
| `-Wstrict-prototypes` | Flags `int main()` | Empty parens mean "unspecified arguments", not "none". You met this. |
| `-g` | Debug symbols | Lets ASan and lldb name your file and line. Without it, errors point at hex addresses. |
| `-o myshell` | Output name | Otherwise you get `a.out`. |

### Now the sanitiser build

```sh
cc -std=c11 -Wall -Wextra -g -fsanitize=address -o myshell_asan src/main.c
```

`-fsanitize=address` instruments every memory access. It catches buffer
overflows, use-after-free, and double-free at the moment they happen rather
than three functions later. It's roughly 2× slower, which is irrelevant here.

You'll keep two binaries all course: `myshell` for normal use, `myshell_asan`
for when something behaves strangely.

### Feel the problem

Now type both of those commands again from memory. That's the pain `make`
exists to remove — and that's milestone 1.

---

## 0.6 — Editor setup (optional)

You're in VS Code. The **C/C++** extension from Microsoft, or **clangd**, will
give you inline errors and go-to-definition. Neither is required; both save
time on typos.

If you use clangd, it wants a `compile_commands.json` to know your flags.
`bear -- make` generates one. Skip this until it annoys you.

---

## 0.7 — Commit

```sh
git add -A
git status          # confirm myshell is NOT listed
git commit -m "milestone 0: environment"
```

---

## Done when

- [ ] `cc`, `make`, `git`, `lldb` all report versions
- [ ] `src/main.c` exists and compiles with zero warnings
- [ ] `./myshell` runs
- [ ] `./myshell_asan` runs
- [ ] `git status` is clean and doesn't list binaries
- [ ] You can explain what each of the six compiler flags does

---

## Questions

1. Why compile with `-g` when you're not currently debugging?
2. What's the difference between a warning and an error? Why treat warnings as
   though they were errors anyway?
3. You now type two long commands to build two binaries. What happens to that
   burden as the project grows to five source files?
