# PE4 — Expression Evaluation with Type Checking

## Objective

Design and implement an **expression evaluator** with **semantic analysis** (type checking) for a subset of C using Flex and Bison. The system declares variables with types, evaluates arithmetic expressions at parse time, and detects semantic errors like undeclared variables, type mismatches, and division by zero.

---

## What is Type Checking / Semantic Analysis?

After a program is syntactically correct (passes parsing), the compiler performs **semantic analysis** — checking that the program makes logical sense. Key checks include:

- **Undeclared variable detection** — using a variable that was never declared with `int` or `float`
- **Type compatibility** — ensuring you don't assign a `float` value to an `int` variable, or mix `int` and `float` in arithmetic
- **Runtime safety** — catching division by zero before execution

This is the bridge between **parsing** (syntax) and **code generation** (output).

---

## How This Implementation Works

### Architecture

```
test_eval.c  ──►  lexer.l (Flex)  ──►  parser.y (Bison)  ──►  Errors + Symbol Table
                                            │
                                            ▼
                                       symtab.hpp
                                   (SymbolTable class)
```

### Step-by-Step Flow

1. **Lexer (`lexer.l`)** — Tokenizes input into:
   - **Type keywords**: `int`, `float`
   - **Identifiers**: variable names like `a`, `b`, `x`
   - **Integer literals**: `5`, `10`, `20` → returned as `INT_LIT` with `int` value
   - **Float literals**: `3.14`, `5.5` → returned as `FLOAT_LIT` with `double` value
   - **Operators**: `= + - * / ( ) , ;`

2. **Parser (`parser.y`)** — Handles two kinds of statements:
   - **Declarations**: `int a, b, c;` or `float x;` — registers variables in the symbol table
   - **Assignment lists**: `a = 5, b = 8, c = 9, d = a + b * c;` — evaluates expressions and stores results

3. **Expression Evaluation** — Uses a custom `ExprResult` struct:
   ```cpp
   struct ExprResult {
       double val;  // The computed value
       int type;    // 0 = int, 1 = float
   };
   ```
   - Each `expr`, `term`, and `factor` rule passes both the **value** and **type** up the parse tree
   - Arithmetic follows standard precedence: `*` and `/` before `+` and `-`
   - Parentheses `()` override precedence as expected

4. **Semantic Checks** — Performed inline during parsing:

   | Check | When | Error Message |
   |-------|------|---------------|
   | Undeclared variable | A variable is used in an expression or assigned but never declared | `[Semantic Error] Variable 'X' not declared before use` |
   | Type mismatch (assignment) | Assigning a `float` expression to an `int` variable or vice versa | `[Type Mismatch Error] Cannot assign value of different type to variable 'X'` |
   | Type mismatch (arithmetic) | Adding/subtracting/multiplying/dividing an `int` with a `float` | `[Type Mismatch] Adding different types` |
   | Division by zero | Dividing by a literal `0` | `[Math Error] Division by zero!` |

5. **Symbol Table (`symtab.hpp`)** — Simpler than PE3's, using an `unordered_map`:
   - `declare(name, type)` — registers a new variable
   - `lookup(name)` — returns a `Symbol*` or `nullptr` if not found
   - Tracks: name, type (`"int"` / `"float"`), current value, and whether it's been initialized
   - `printTable()` — shows the final state of all variables after evaluation

---

## Files

| File | Purpose |
|------|---------|
| `lexer.l` | Flex lexer — tokenizes into IDENTIFIER, INT_LIT, FLOAT_LIT, operators |
| `parser.y` | Bison parser — grammar for declarations and expressions with inline type checking and evaluation |
| `symtab.hpp` | `SymbolTable` class with `declare()`, `lookup()`, and `printTable()` |
| `test_eval.c` | Valid + error sample — declarations, evaluations, and deliberate semantic errors |
| `test_error.c` | Dedicated error input — undeclared vars, type mismatches, division by zero |
| `Makefile` | Build automation |

---

## Build & Run

```bash
cd PE4
make clean
make
```

### Run with valid + error input

```bash
./evaluator.exe test_eval.c
```

### Run with dedicated error input

```bash
./evaluator.exe test_error.c
```

---

## Sample Input (`test_eval.c`)

```c
// 1. Declare the variables
int a, b, c, d;
float x;

// 2. The exact evaluation string from your prompt!
a = 5, b = 8, c = 9, d = a + b * c;

// 3. Let's test the error checking
e = 10;          // Error: Variable not declared
x = 5.5;         // Valid
a = x;           // Error: Type mismatch (assigning float to int)
b = a + x;       // Error: Type mismatch (adding int and float)
```

## Sample Output

```
[Semantic Error] Variable 'e' not declared before use at line 9
[Type Mismatch Error] Cannot assign value of different type to variable 'a' at line 11
[Type Mismatch] Adding different types at line 12

==============================================
 EVALUATED SYMBOL TABLE
==============================================
Variable       Type      Final Value
----------------------------------------------
a              int       5
b              int       8
c              int       9
d              int       77
x              float     5.5
==============================================
```

### Reading the Output

- **`d = a + b * c`** → `d = 5 + 8 * 9` → `d = 5 + 72` → **`d = 77`** ✓ (multiplication before addition)
- **`e = 10`** → Error because `e` was never declared with `int` or `float`
- **`a = x`** → Error because `a` is `int` but `x` is `float` (type mismatch)
- **`b = a + x`** → Error because you're adding an `int` (`a`) and `float` (`x`)
- Despite errors, `a` retains its value of `5` (the invalid assignment is rejected)

---

## Expression Evaluation Rules

| Expression | Precedence | Result |
|------------|-----------|--------|
| `a + b * c` | `*` first, then `+` | `a + (b * c)` |
| `(a + b) * c` | `()` forces `+` first | `(a + b) * c` |
| `a - b / c` | `/` first, then `-` | `a - (b / c)` |
| `a / 0` | Division by zero caught | Error reported, result set to 0 |

---

## Errors Caught

| Error Type | Example | Parser Output |
|------------|---------|---------------|
| Undeclared variable | `z = 5;` (z never declared) | `[Semantic Error] Variable 'z' not declared before use` |
| Type mismatch (assignment) | `a = 3.14;` (a is int) | `[Type Mismatch Error] Cannot assign value of different type to variable 'a'` |
| Type mismatch (arithmetic) | `b = a + x;` (int + float) | `[Type Mismatch] Adding different types` |
| Division by zero | `a = b / 0;` | `[Math Error] Division by zero!` |
