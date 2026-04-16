# PE3 — Symbol Table Construction

## Objective

Design and implement a **Symbol Table** for a subset of C using Flex (lexer) and Bison (parser). The symbol table records every identifier declared in the source program along with its metadata — type, storage class, scope level, byte size, and location.

---

## What is a Symbol Table?

A Symbol Table is a core data structure used by compilers during the **semantic analysis** phase. It stores information about every identifier (variables, functions, parameters, struct tags, typedefs) encountered during parsing. The compiler uses this table to:

- Check if a variable has been **declared before use**
- Resolve the **type** and **size** of each identifier
- Track **scope** (global vs. local vs. nested blocks)
- Store **storage class** attributes (`auto`, `static`, `extern`, `register`)

---

## How This Implementation Works

### Architecture

```
test.c  ──►  lexer.l (Flex)  ──►  parser.y (Bison)  ──►  Symbol Table Output
                                       │
                                       ▼
                                  symtab.hpp
                              (SymbolTable class)
```

### Step-by-Step Flow

1. **Lexer (`lexer.l`)** — Tokenizes the input C source code. It recognizes:
   - **Type keywords**: `int`, `float`, `char`, `void`, `double`
   - **Storage class specifiers**: `auto`, `static`, `extern`, `register`
   - **Struct/Union/Enum/Typedef** keywords
   - **Identifiers**, **numbers**, **string literals**
   - **Operators and delimiters**: `{ } ( ) ; , = *`
   - Also tracks **line numbers** and **column positions** via `YY_USER_ACTION`

2. **Parser (`parser.y`)** — Defines the grammar rules for:
   - **Variable declarations**: `int x;`, `static float pi = 3.14;`, `char *msg = "Hello";`
   - **Pointer declarations**: `int *p;`, `char **argv;` (handles multiple levels of `*`)
   - **Struct definitions**: `struct Point { int x; int y; };` (with nested scope)
   - **Function definitions**: `void calculate(int a, int b) { ... }` (parameters + body)
   - **Typedefs**: `typedef int MyInt;`
   - **Nested scopes**: `{ int temp; }` inside functions

3. **Symbol Table (`symtab.hpp`)** — A `SymbolTable` class that:
   - Stores a `vector<Symbol>` where each `Symbol` holds:
     - `name` — identifier name
     - `kind` — `variable`, `function`, `parameter`, `struct-tag`, `typedef`
     - `type` — `int`, `float`, `int*`, `char**`, `void()`, etc.
     - `storageClass` — `auto`, `static`, `extern`, `register`
     - `size` — byte size (4 for `int`, 8 for `double`, 8 for pointers, etc.)
     - `scope` — 0 = global, 1+ = nested local scopes
     - `line`, `col` — source location
     - `initVal` — initial value if present, else `"null"`
   - Manages scope with `enterScope()` / `leaveScope()` (increments/decrements a counter)
   - `printTable()` outputs a neatly formatted table

### Scope Tracking

The parser tracks scope depth by calling `enterScope()` when entering:
- A **struct body** `{`
- A **function body** `{`
- A **compound statement** (nested block) `{`

And `leaveScope()` when the matching `}` is parsed.

---

## Files

| File | Purpose |
|------|---------|
| `lexer.l` | Flex lexer — tokenizes C source into tokens (TYPE, IDENTIFIER, STORAGE, etc.) |
| `parser.y` | Bison parser — grammar rules for declarations, structs, functions. Calls `symtab.insert()` on each identifier |
| `symtab.hpp` | `SymbolTable` class with `insert()`, `enterScope()`, `leaveScope()`, and `printTable()` |
| `test.c` | Valid sample input — typedefs, structs, global vars with storage classes, functions with params and nested scopes |
| `test_error.c` | Error input — missing semicolons, unclosed struct braces, missing return types |
| `Makefile` | Build automation using `flex`, `bison`, and `g++` |

---

## Build & Run

```bash
cd PE3
make clean
make
```

### Run with valid input

```bash
./symbol_table.exe test.c
```

### Run with error input

```bash
./symbol_table.exe test_error.c
```

---

## Sample Input (`test.c`)

```c
typedef int MyInt;

struct Point {
    int x = 0;
    int y = 0;
};

static float global_pi = 3.14;
extern char* shared_msg = "Hello";

void calculate(int multiplier) {
    int result = 0;

    {
        // Nested Scope
        int temp_var = 10;
        result = temp_var;
    }
}
```

## Sample Output

```
==============================================
 SYMBOL TABLE
==============================================
Name           Kind           Type           Storage     Size    Scope   Line:Col    InitVal
----------------------------------------------
MyInt          typedef        int            none        4       0       1:13        null
Point          struct-tag     struct         none        0       0       3:8         null
x              variable       int            auto        4       1       4:9         0
y              variable       int            auto        4       1       5:9         0
global_pi      variable       float          static      4       0       8:14        3.14
shared_msg     variable       char*          extern      8       0       9:14        "Hello"
calculate      function       void()         extern      0       0       11:6        null
multiplier     parameter      int            auto        4       1       11:20       null
result         variable       int            auto        4       1       12:9        0
temp_var       variable       int            auto        4       2       16:13       10
==============================================
```

### Reading the Output

- **`MyInt`** is a `typedef` at global scope (0) — aliases `int`
- **`Point`** is a `struct-tag` — the struct members `x` and `y` are at scope 1 (inside the struct body)
- **`global_pi`** has `static` storage, **`shared_msg`** has `extern` — specified explicitly in the source
- **`calculate`** is a `function` with return type `void()` — its parameter `multiplier` is at scope 1
- **`temp_var`** is at scope **2** — it's inside a nested `{ }` block within the function

---

## Errors Caught

| Error Type | Example | Parser Output |
|------------|---------|---------------|
| Missing semicolon | `int a = 5` (no `;`) | `Syntax Error at line X, col Y: syntax error` |
| Unclosed struct | `struct Broken { int x;` (no `};`) | `Syntax Error` — parser never finds closing brace |
| Missing return type | `calculate(int a) { }` | `Syntax Error` — expects a type keyword before the identifier |
