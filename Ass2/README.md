# Ass2 — Control Flow: AST + Intermediate Code Generation

## Objective

Extend the AST and ICG techniques from PE5 and PE6 to handle **control flow statements** — specifically **`if-else`** and **`do-while`** constructs. The program builds a unified AST for the entire program, prints its postorder traversal, and then generates **intermediate code (quadruples) with labels and gotos** for control flow.

---

## What is Control Flow in ICG?

High-level control flow constructs like `if-else` and `while` loops don't exist in low-level machine code. Instead, the compiler translates them into **conditional jumps (gotos)** and **labels**:

### if-else Translation

```c
// High-level                          // Three-Address Code
if (a < b) {                           if a < b is FALSE goto L0
    x = 1;                             x = 1
} else {                               goto L1
    x = 2;                         L0: x = 2
}                                   L1: (continue)
```

### do-while Translation

```c
// High-level                          // Three-Address Code
do {                                L0: count = count + 1
    count = count + 1;                  if count != 10 is TRUE goto L0
} while (count != 10);
```

The compiler generates **fresh labels** (`L0`, `L1`, `L2`, ...) and uses `ifFalse`/`ifTrue` + `goto` instructions to implement the branching logic.

---

## How This Implementation Works

### Architecture

```
test_control.c  ──►  lexer.l (Flex)  ──►  parser.y (Bison)  ──►  AST Postorder + Quadruples
                                               │
                                               ▼
                                           ast.hpp
                                    (Extended ASTNode with
                                     3 children + TAC gen)
```

### Step-by-Step Flow

1. **Lexer (`lexer.l`)** — Extended from PE5/PE6 to also recognize:
   - **Control flow keywords**: `if`, `else`, `do`, `while`
   - **Relational operators**: `<`, `>`, `<=`, `>=`, `==`, `!=` → returned as single `RELOP` token
   - **Braces**: `{ }` for blocks
   - All arithmetic operators from before

2. **Parser (`parser.y`)** — Builds a full AST using these grammar rules:
   - **`stmt_list`** → Chains statements with `SEQ` (sequence) nodes
   - **`if-else`** → `IF LPAREN cond RPAREN LBRACE stmt_list RBRACE ELSE LBRACE stmt_list RBRACE`
     - Creates an `IF` node with **3 children**: condition, true-block, false-block
   - **`do-while`** → `DO LBRACE stmt_list RBRACE WHILE LPAREN cond RPAREN SEMI`
     - Creates a `DO_WHILE` node with **2 children**: body, condition
   - **`cond`** → `IDENTIFIER RELOP IDENTIFIER/NUMBER` — condition node
   - **`assignment`** → Same as PE5/PE6
   - After parsing the entire program, it calls `printPostOrder()` then `generateTAC()`

3. **AST Node (`ast.hpp`)** — Extended with **3 child pointers** to support if-else:
   ```cpp
   struct ASTNode {
       string type;   // "IF", "DO_WHILE", "COND", "ASSIGN", "OP", "ID", "NUM", "SEQ"
       string value;  // Operator symbol or empty
       ASTNode* c1;   // Child 1 (condition / left / body)
       ASTNode* c2;   // Child 2 (true-block / right / condition)
       ASTNode* c3;   // Child 3 (false-block, only for IF)
   };
   ```

4. **Postorder Traversal (`printPostOrder`)** — Visits c1 → c2 → c3 → Root:
   - Prints `value` for IDs, NUMs, OPs, CONDs
   - Prints `=` for ASSIGNs
   - Prints `IF_ELSE` for IF nodes
   - Prints `DO_WHILE` for DO_WHILE nodes

5. **TAC Generation (`generateTAC`)** — Recursive function that handles each node type:

   | Node Type | Action |
   |-----------|--------|
   | `ID` / `NUM` | Return the value string (leaf node) |
   | `SEQ` | Generate TAC for c1, then c2 (sequence) |
   | `OP` / `COND` | Generate TAC for both operands, emit quadruple, return temp |
   | `ASSIGN` | Generate TAC for RHS, emit `(=, result, _, variable)` |
   | `IF` | Generate condition temp → `ifFalse` jump to false label → true block → `goto` end → false label → false block → end label |
   | `DO_WHILE` | Start label → body → condition temp → `ifTrue` jump back to start |

---

## Files

| File | Purpose |
|------|---------|
| `lexer.l` | Flex lexer — tokenizes keywords, relational ops, identifiers, numbers, operators, and braces |
| `parser.y` | Bison parser — builds a full program AST with control flow nodes, then traverses and generates TAC |
| `ast.hpp` | Extended `ASTNode` (3 children) + `printPostOrder()` + `generateTAC()` + `newTemp()` + `newLabel()` + `emit()` |
| `test_control.c` | Valid sample input — an if-else block and a do-while loop |
| `test_error.c` | Error input — missing else, missing semicolon, missing parentheses |
| `Makefile` | Build automation |

---

## Build & Run

```bash
cd Ass2
make clean
make
```

### Run with valid input

```bash
./control_flow.exe test_control.c
```

### Run with error input

```bash
./control_flow.exe test_error.c
```

---

## Sample Input (`test_control.c`)

```c
// 1. Test If-Else Block
if (a < b) {
    x = 1;
} else {
    x = 2;
}

// 2. Test Do-While Block
do {
    count = count + 1;
} while (count != 10);
```

## Sample Output

### Part 1: AST Postorder Traversal

```
==============================================
 1. AST POSTORDER TRAVERSAL
==============================================
a b < x 1 = x 2 = IF_ELSE count count 1 + = count 10 != DO_WHILE SEQ
```

### Reading the Postorder

Breaking it down by construct:

| Segment | Meaning |
|---------|---------|
| `a b <` | Condition: `a < b` |
| `x 1 =` | True branch: `x = 1` |
| `x 2 =` | False branch: `x = 2` |
| `IF_ELSE` | The if-else node |
| `count count 1 + =` | Body: `count = count + 1` |
| `count 10 !=` | Condition: `count != 10` |
| `DO_WHILE` | The do-while node |
| `SEQ` | Sequence — links the if-else and do-while statements |

### Part 2: Intermediate Code (Quadruples)

```
==============================================
 2. INTERMEDIATE CODE (QUADRUPLES)
==============================================
(<, a, b, t0)
(ifFalse, t0, _, L0)
(=, 1, _, x)
(goto, _, _, L1)
(label, _, _, L0)
(=, 2, _, x)
(label, _, _, L1)
(label, _, _, L2)
(+, count, 1, t1)
(=, t1, _, count)
(!=, count, 10, t2)
(ifTrue, t2, _, L2)
==============================================
```

### Walkthrough: if-else Quadruples

```
(<, a, b, t0)              ← Evaluate condition a < b, store boolean in t0
(ifFalse, t0, _, L0)       ← If t0 is FALSE (a >= b), jump to L0 (else block)
(=, 1, _, x)               ← TRUE branch: x = 1
(goto, _, _, L1)            ← Skip the else block, jump to end
(label, _, _, L0)           ← ELSE label
(=, 2, _, x)               ← FALSE branch: x = 2
(label, _, _, L1)           ← END label (both paths converge here)
```

### Walkthrough: do-while Quadruples

```
(label, _, _, L2)           ← Loop START label
(+, count, 1, t1)          ← Body: t1 = count + 1
(=, t1, _, count)           ← Body: count = t1
(!=, count, 10, t2)         ← Evaluate condition: count != 10, store in t2
(ifTrue, t2, _, L2)         ← If t2 is TRUE (count != 10), jump back to L2
```

---

## How This Connects to PE5 and PE6

| Component | PE5 | PE6 | Ass2 |
|-----------|-----|-----|------|
| AST construction | ✅ Binary tree | ❌ | ✅ Extended with 3 children |
| Postorder traversal | ✅ | ❌ | ✅ Extended with IF_ELSE, DO_WHILE |
| TAC / Quadruples | ❌ | ✅ Arithmetic only | ✅ Arithmetic + labels + gotos |
| Control flow | ❌ | ❌ | ✅ if-else, do-while |
| Labels & jumps | ❌ | ❌ | ✅ `newLabel()`, ifFalse, ifTrue, goto |

Ass2 is essentially **PE5 + PE6 combined and extended** with control flow support.

---

## Errors Caught

| Error Type | Example | Parser Output |
|------------|---------|---------------|
| Missing `else` branch | `if (a < b) { x = 1; }` (no else) | `Syntax Error` — grammar requires `if (...) { ... } else { ... }` |
| Missing `;` after do-while | `} while (count != 10)` (no `;`) | `Syntax Error` — parser expects `;` after `)` |
| Missing `()` around condition | `if a < b { ... }` | `Syntax Error` — parser expects `(` after `if` keyword |
