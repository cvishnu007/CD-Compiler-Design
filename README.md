clear
# Compiler Design — Practical Experiments

> Instructions to build and run **PE3**, **PE4**, **PE5**, **PE6**, and **Ass2**.  
> All projects use **Flex** (lexer), **Bison** (parser), and **g++** (C++11).

---

## Prerequisites

Make sure the following tools are installed and available in your `PATH`:

| Tool     | Purpose              | Install (Windows – MSYS2/MinGW)        |
| -------- | -------------------- | --------------------------------------- |
| `g++`    | C++ compiler         | `pacman -S mingw-w64-x86_64-gcc`       |
| `flex`   | Lexical analyser     | `pacman -S flex`                        |
| `bison`  | Parser generator     | `pacman -S bison`                       |
| `make`   | Build automation     | `pacman -S make`                        |

> **Tip:** If you're using plain CMD/PowerShell, install these via [MSYS2](https://www.msys2.org/) and add the `mingw64/bin` folder to your system `PATH`.

Verify installation:

```bash
g++ --version
flex --version
bison --version
make --version
```

---

## Quick Reference

| Folder | Experiment | Description | Executable | Test File | Error Test File |
|--------|-----------|-------------|------------|-----------|----------------|
| `PE3/` | Symbol Table Construction | Parses C-like code and builds a scoped symbol table | `symbol_table.exe` | `test.c` | `test_error.c` |
| `PE4/` | Expression Evaluation with Type Checking | Evaluates arithmetic expressions with type‑mismatch and undeclared‑variable detection | `evaluator.exe` | `test_eval.c` | `test_error.c` |
| `PE5/` | AST Generation (Postorder Traversal) | Builds an Abstract Syntax Tree and prints its postorder (reverse‑Polish) traversal | `ast_generator.exe` | `test_ast.c` | `test_error.c` |
| `PE6/` | Intermediate Code Generation (Quadruples) | Generates three‑address code in quadruple format `(op, arg1, arg2, result)` | `tac_generator.exe` | `test_icg.c` | `test_error.c` |
| `Ass2/` | Control Flow ICG (if‑else, do‑while) | Combines AST + ICG for control‑flow statements | `control_flow.exe` | `test_control.c` | `test_error.c` |

---

## How to Build & Run

The steps are identical for every experiment — only the folder name changes.

### General Steps

```bash
# 1. Navigate to the experiment folder
cd <FOLDER>

# 2. Build the project
make clean
make

# 3. Run with the provided test file
./<executable> <test_file>
```

---

### PE3 — Symbol Table Construction

```bash
cd PE3
make clean
make
./symbol_table.exe test.c
```

**What it does:** Parses `test.c` (typedefs, structs, functions, variables with pointer/storage‑class annotations) and prints a formatted symbol table showing name, kind, type, storage class, size, scope, location, and initial value.

**Expected output (sample):**

```
==============================================
 SYMBOL TABLE
==============================================
Name           Kind           Type           Storage     Size    Scope   Line:Col    InitVal
----------------------------------------------
MyInt          typedef        int            none        4       0       1:13        null
Point          struct-tag     struct         none        0       0       3:8         null
x              variable       int            auto        4       1       4:9         0
...
```

#### ⚠️ Error Testing

```bash
./symbol_table.exe test_error.c
```

**Errors in `test_error.c`:**

| Line | Error | What the Parser Reports |
|------|-------|-------------------------|
| 5 | `int a = 5` — missing semicolon | `Syntax Error at line X, col Y: syntax error` |
| 10 | `struct Broken {` — missing closing `}` and `;` | `Syntax Error` — parser never finds the closing brace |
| 13 | `calculate(...)` — missing return type before function name | `Syntax Error` — parser expects a type specifier (`int`, `float`, etc.) before an identifier |

---

### PE4 — Expression Evaluation with Type Checking

```bash
cd PE4
make clean
make
./evaluator.exe test_eval.c
```

**What it does:** Declares `int` and `float` variables, evaluates expressions like `d = a + b * c`, and checks for:
- Undeclared variable usage
- Type mismatches in assignments and arithmetic

**Expected output (sample):**

```
[Semantic Error] Variable 'e' not declared before use at line 9
[Type Mismatch Error] Cannot assign value of different type to variable 'a' at line 11
[Type Mismatch] Adding different types at line 12

=== Symbol Table ===
...
```

#### ⚠️ Error Testing

```bash
./evaluator.exe test_error.c
```

**Errors in `test_error.c`:**

| Line | Error | What the Parser Reports |
|------|-------|-------------------------|
| 12 | `z = 5;` — variable `z` was never declared | `[Semantic Error] Variable 'z' not declared before use` |
| 15 | `a = 3.14;` — assigning a `float` literal to an `int` variable | `[Type Mismatch Error] Cannot assign value of different type to variable 'a'` |
| 18 | `b = a + x;` — adding `int` (`a`) and `float` (`x`) | `[Type Mismatch] Adding different types` |
| 21 | `a = b / 0;` — division by zero | `[Math Error] Division by zero!` |

---

### PE5 — AST Generation (Postorder / Reverse Polish)

```bash
cd PE5
make clean
make
./ast_generator.exe test_ast.c
```

**What it does:** Parses arithmetic expressions and assignments, builds an AST for each statement, and prints its **postorder traversal** (reverse Polish notation).

**Expected output (sample):**

```
==============================================
 AST POSTORDER (REVERSE POLISH) GENERATOR
==============================================

Postorder Traversal: 5 3 +

Postorder Traversal: 5 3 2 * +

Postorder Traversal: 5 3 + 2 *

Postorder Traversal: d a b c * + =
```

#### ⚠️ Error Testing

```bash
./ast_generator.exe test_error.c
```

**Errors in `test_error.c`:**

| Line | Error | What the Parser Reports |
|------|-------|-------------------------|
| 8 | `b = 5 + * 3;` — two operators in a row, missing operand between `+` and `*` | `Syntax Error at line 8: syntax error` |
| 11 | `c = (5 + 3;` — opening `(` with no matching `)` | `Syntax Error at line 11: syntax error` |
| 14 | `d = a + b` — missing semicolon at end of statement | `Syntax Error` — parser expects `;` but hits end‑of‑file |

> **Note:** The first valid statement `a = 5 + 3;` will still produce correct output before the parser encounters the errors.

---

### PE6 — Intermediate Code Generation (Quadruples)

```bash
cd PE6
make clean
make
./tac_generator.exe test_icg.c
```

**What it does:** Generates **three‑address code** in quadruple format for each statement.

**Expected output (sample):**

```
================================
 INTERMEDIATE CODE (QUADRUPLES)
 Format: (op, arg1, arg2, result)
================================
(*, b, c, t0)
(+, a, t0, t1)
(=, t1, _, d)
--------------------------------
(+, x, y, t0)
(-, x, y, t1)
(*, t0, t1, t2)
(/, t2, 2, t3)
(=, t3, _, result)
--------------------------------
```

#### ⚠️ Error Testing

```bash
./tac_generator.exe test_error.c
```

**Errors in `test_error.c`:**

| Line | Error | What the Parser Reports |
|------|-------|-------------------------|
| 8 | `x = ;` — empty right‑hand side, no expression after `=` | `Syntax Error at line 8: syntax error` |
| 11 | `y = a + + b;` — double operator, missing operand between `+` and `+` | `Syntax Error at line 11: syntax error` |
| 14 | `z = (a + b * c;` — unmatched opening parenthesis | `Syntax Error at line 14: syntax error` |

> **Note:** The first valid statement `d = a + b * c;` will generate correct quadruples before errors are hit.

---

### Ass2 — Control Flow ICG (if‑else & do‑while)

```bash
cd Ass2
make clean
make
./control_flow.exe test_control.c
```

**What it does:** Parses `if-else` and `do-while` control‑flow constructs, builds an AST, prints a **postorder traversal**, and then generates **intermediate code with labels and gotos**.

**Expected output (sample):**

```
==============================================
 1. AST POSTORDER TRAVERSAL
==============================================
a b < x 1 = x 2 = IF count count 1 + = count 10 != DO_WHILE SEQ

==============================================
 2. INTERMEDIATE CODE (QUADRUPLES)
==============================================
(if, a < b, _, L0)
(goto, _, _, L1)
(label, _, _, L0)
(=, 1, _, x)
(goto, _, _, L2)
(label, _, _, L1)
(=, 2, _, x)
(label, _, _, L2)
(label, _, _, L3)
(+, count, 1, t0)
(=, t0, _, count)
(if, count != 10, _, L3)
==============================================
```

#### ⚠️ Error Testing

```bash
./control_flow.exe test_error.c
```

**Errors in `test_error.c`:**

| Line | Error | What the Parser Reports |
|------|-------|-------------------------|
| 5–7 | `if (...) { ... }` — missing the required `else` branch | `Syntax Error` — the grammar mandates `if (...) { ... } else { ... }` |
| 13 | `} while (count != 10)` — missing semicolon `;` after `do-while` | `Syntax Error` — parser expects `;` after the closing `)` |
| 16 | `if a < b {` — missing parentheses `()` around the condition | `Syntax Error` — parser expects `(` after `if` keyword |

---

## Project Structure

```
CD/
├── PE3/                         # Symbol Table Construction
│   ├── lexer.l                  # Flex lexer rules
│   ├── parser.y                 # Bison grammar + main()
│   ├── symtab.hpp               # SymbolTable class
│   ├── test.c                   # Sample C input (valid)
│   ├── test_error.c             # Error test input (syntax errors)
│   └── Makefile
│
├── PE4/                         # Expression Evaluator + Type Checking
│   ├── lexer.l
│   ├── parser.y
│   ├── symtab.hpp
│   ├── test_eval.c              # Sample input (valid + semantic errors)
│   ├── test_error.c             # Error test input (semantic errors)
│   └── Makefile
│
├── PE5/                         # AST (Postorder Traversal)
│   ├── lexer.l
│   ├── parser.y
│   ├── ast.hpp                  # ASTNode struct + traversal
│   ├── test_ast.c               # Sample input (valid)
│   ├── test_error.c             # Error test input (syntax errors)
│   └── Makefile
│
├── PE6/                         # Intermediate Code (Quadruples)
│   ├── lexer.l
│   ├── parser.y
│   ├── test_icg.c               # Sample input (valid)
│   ├── test_error.c             # Error test input (syntax errors)
│   └── Makefile
│
└── Ass2/                        # Control Flow (if-else, do-while) + ICG
    ├── lexer.l
    ├── parser.y
    ├── ast.hpp                  # Extended ASTNode with TAC generation
    ├── test_control.c           # Sample input (valid)
    ├── test_error.c             # Error test input (syntax errors)
    └── Makefile
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `'make' is not recognized` | Install `make` via MSYS2 or use `mingw32-make` instead |
| `'flex' is not recognized` | Add MSYS2's `usr/bin` to your PATH |
| `'bison' is not recognized` | Same as above — ensure MSYS2 bin dirs are in PATH |
| `undefined reference to 'yylex'` | Run `make clean` first, then `make` (stale generated files) |
| `Permission denied` on `.exe` | You may need to unblock the file or run from an admin terminal |
| `cannot open input file` | Make sure you're in the correct folder and the test file exists |

---

## Custom Test Inputs

You can create your own test files and pass them as arguments:

```bash
# Example: custom test for PE6
echo "x = a + b * c - d / e;" > my_test.c
./tac_generator.exe my_test.c
```

Or run interactively (type expressions, then press **Ctrl+Z** on Windows or **Ctrl+D** on Linux to finish):

```bash
./tac_generator.exe
d = a + b * c;
^Z
```

---

*Last updated: April 2026*
