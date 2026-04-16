# PE6 — Intermediate Code Generation (Three-Address Code)

## Objective

Design and implement an **Intermediate Code Generator (ICG)** that translates arithmetic expressions and assignments into **Three-Address Code (TAC)** represented in **Quadruple format** using Flex and Bison.

---

## What is Intermediate Code Generation?

ICG is a phase in the compiler that sits between **syntax analysis** (parsing) and **code generation** (machine code). It translates source code into an **intermediate representation (IR)** that is:

- **Machine-independent** — not tied to any specific CPU architecture
- **Easier to optimize** — simpler structure than source code
- **Straightforward to translate** — into target machine code or assembly

### Three-Address Code (TAC)

TAC is the most common form of IR. Each instruction has **at most three operands**:

```
result = arg1 op arg2
```

For example, `d = a + b * c` becomes:

```
t0 = b * c
t1 = a + t0
d  = t1
```

Each complex expression is broken down into simple operations using **temporary variables** (`t0`, `t1`, `t2`, ...).

### Quadruple Format

A quadruple is a 4-field representation: `(operator, argument1, argument2, result)`.

| Quadruple | Meaning |
|-----------|---------|
| `(*, b, c, t0)` | `t0 = b * c` |
| `(+, a, t0, t1)` | `t1 = a + t0` |
| `(=, t1, _, d)` | `d = t1` |

The `_` is used when an argument slot is unused (like assignment which only has one source).

---

## How This Implementation Works

### Architecture

```
test_icg.c  ──►  lexer.l (Flex)  ──►  parser.y (Bison)  ──►  Quadruple Output
```

### Step-by-Step Flow

1. **Lexer (`lexer.l`)** — Same as PE5. Tokenizes identifiers, numbers, and operators.

2. **Parser (`parser.y`)** — Grammar is similar to PE5, but instead of building an AST, each rule **emits quadruples directly**:
   - `factor` → Returns the name of the identifier or number as a string
   - `term` → On `*` or `/`, generates a new temp, emits a quadruple, and returns the temp name
   - `expr` → On `+` or `-`, same approach
   - `assignment` → Emits `(=, source, _, destination)`
   - After each statement, the `temp_count` resets to `0` for clean output

3. **Key Functions**:
   ```cpp
   // Generate fresh temporary: t0, t1, t2, ...
   string newTemp() {
       return "t" + to_string(temp_count++);
   }

   // Print one quadruple
   void emit(string op, string arg1, string arg2, string result) {
       cout << "(" << op << ", " << arg1 << ", " << arg2 << ", " << result << ")\n";
   }
   ```

4. **Semantic Values** — Unlike PE5 (which passes `ASTNode*` pointers), PE6 passes **strings** (`char*`) up the parse tree. The string is the name of the variable or temporary that holds the result of that sub-expression.

### Translation Example: `d = a + b * c`

The parser processes this bottom-up:

| Grammar Rule | Action | Emitted Quadruple |
|-------------|--------|-------------------|
| `factor → b` | Return `"b"` | — |
| `factor → c` | Return `"c"` | — |
| `term → term * factor` | `t0 = newTemp()`, emit, return `"t0"` | `(*, b, c, t0)` |
| `factor → a` | Return `"a"` | — |
| `expr → expr + term` | `t1 = newTemp()`, emit, return `"t1"` | `(+, a, t0, t1)` |
| `assignment → d = expr` | emit assignment | `(=, t1, _, d)` |

---

## Files

| File | Purpose |
|------|---------|
| `lexer.l` | Flex lexer — tokenizes identifiers, numbers, and operators |
| `parser.y` | Bison parser — grammar rules that emit quadruples using `newTemp()` and `emit()` |
| `test_icg.c` | Valid sample input — simple and complex expressions |
| `test_error.c` | Error input — empty RHS, double operators, unmatched parens |
| `Makefile` | Build automation |

---

## Build & Run

```bash
cd PE6
make clean
make
```

### Run with valid input

```bash
./tac_generator.exe test_icg.c
```

### Run with error input

```bash
./tac_generator.exe test_error.c
```

---

## Sample Input (`test_icg.c`)

```c
// The classic example
d = a + b * c;

// A more complex example with parentheses
result = (x + y) * (x - y) / 2;
```

## Sample Output

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

### Walkthrough: `d = a + b * c`

```
Step 1:  b * c           →  (*, b, c, t0)        t0 holds the product
Step 2:  a + t0           →  (+, a, t0, t1)       t1 holds the sum
Step 3:  d = t1           →  (=, t1, _, d)        store result in d
```

### Walkthrough: `result = (x + y) * (x - y) / 2`

```
Step 1:  x + y            →  (+, x, y, t0)        t0 = x + y
Step 2:  x - y            →  (-, x, y, t1)        t1 = x - y
Step 3:  t0 * t1          →  (*, t0, t1, t2)      t2 = (x+y) * (x-y)
Step 4:  t2 / 2           →  (/, t2, 2, t3)       t3 = result
Step 5:  result = t3      →  (=, t3, _, result)    store in 'result'
```

Notice how parentheses change the order of emission — `(x + y)` is evaluated **before** the `*`, unlike `a + b * c` where `b * c` comes first.

---

## Comparison: PE5 (AST) vs PE6 (TAC)

| Aspect | PE5 — AST | PE6 — TAC |
|--------|----------|----------|
| Output | Tree structure (postorder print) | Flat sequence of quadruples |
| Data structure | `ASTNode*` pointers | `char*` strings (temp names) |
| Temporaries | None (implicit in tree) | Explicit `t0`, `t1`, `t2`... |
| Use case | Tree-based optimizations, further analysis | Direct translation to assembly/machine code |

---

## Errors Caught

| Error Type | Example | Parser Output |
|------------|---------|---------------|
| Empty RHS | `x = ;` (nothing after `=`) | `Syntax Error at line 8: syntax error` |
| Consecutive operators | `y = a + + b;` | `Syntax Error at line 11: syntax error` |
| Unmatched parenthesis | `z = (a + b * c;` | `Syntax Error at line 14: syntax error` |
