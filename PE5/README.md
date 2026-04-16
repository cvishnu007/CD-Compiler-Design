# PE5 — Abstract Syntax Tree (AST) Generation

## Objective

Design and implement an **Abstract Syntax Tree (AST)** generator for arithmetic expressions and assignments using Flex and Bison. The program builds a tree representation of each statement and prints its **postorder traversal** (Reverse Polish Notation).

---

## What is an AST?

An **Abstract Syntax Tree** is a tree representation of the syntactic structure of source code. Unlike a parse tree which includes every grammar detail, the AST only captures the **essential semantics** — operators, operands, and their relationships.

### Example: `d = a + b * c`

```
        =
       / \
      d   +
         / \
        a   *
           / \
          b   c
```

The tree naturally encodes **operator precedence** — `*` is a child of `+`, so it's evaluated first.

### What is Postorder Traversal?

**Postorder** visits: Left child → Right child → Root. This produces **Reverse Polish Notation (RPN)**, which is useful for stack-based evaluation.

For the tree above: **`d a b c * + =`**

| Step | Action | Stack State |
|------|--------|-------------|
| `d` | Push d | `[d]` |
| `a` | Push a | `[d, a]` |
| `b` | Push b | `[d, a, b]` |
| `c` | Push c | `[d, a, b, c]` |
| `*` | Pop b,c → push b*c | `[d, a, b*c]` |
| `+` | Pop a,b*c → push a+b*c | `[d, a+b*c]` |
| `=` | Pop d,a+b*c → assign | `[]` |

---

## How This Implementation Works

### Architecture

```
test_ast.c  ──►  lexer.l (Flex)  ──►  parser.y (Bison)  ──►  Postorder Output
                                           │
                                           ▼
                                       ast.hpp
                                   (ASTNode struct)
```

### Step-by-Step Flow

1. **Lexer (`lexer.l`)** — Simple tokenizer for:
   - **Identifiers**: `a`, `b`, `result`
   - **Numbers**: `5`, `3.14`
   - **Operators**: `= + - * / ( ) ;`

2. **Parser (`parser.y`)** — Grammar rules that **build** ASTNode objects:
   - `factor` → Creates **leaf nodes** for identifiers and numbers
   - `term` → Handles `*` and `/` — creates an internal node with operator as value
   - `expr` → Handles `+` and `-` — same
   - `assignment` → `IDENTIFIER = expr` → creates an `=` node with ID on left and expression tree on right
   - After each statement (`;`), the parser calls `printPostOrder()` and then `freeAST()` to clean up

3. **AST Node (`ast.hpp`)** — A simple struct:
   ```cpp
   struct ASTNode {
       string value;       // Operator (+, -, *, /) or operand (a, 5)
       ASTNode* left;      // Left child
       ASTNode* right;     // Right child
   };
   ```
   - **Leaf nodes**: `left = right = nullptr`, value is the identifier/number
   - **Internal nodes**: value is the operator, children are sub-expressions

4. **Traversal Functions**:
   - `printPostOrder(node)` — Recursively prints Left → Right → Root
   - `freeAST(node)` — Recursively deletes all nodes to prevent memory leaks

---

## Files

| File | Purpose |
|------|---------|
| `lexer.l` | Flex lexer — tokenizes identifiers, numbers, and operators |
| `parser.y` | Bison parser — builds ASTNode trees for each statement, prints postorder, and frees memory |
| `ast.hpp` | `ASTNode` struct with `printPostOrder()` and `freeAST()` functions |
| `test_ast.c` | Valid sample input — simple and complex expressions |
| `test_error.c` | Error input — consecutive operators, mismatched parens, missing semicolons |
| `Makefile` | Build automation |

---

## Build & Run

```bash
cd PE5
make clean
make
```

### Run with valid input

```bash
./ast_generator.exe test_ast.c
```

### Run with error input

```bash
./ast_generator.exe test_error.c
```

---

## Sample Input (`test_ast.c`)

```c
// Simple addition
5 + 3;

// Multiplication happens before addition
5 + 3 * 2;

// Parentheses force addition to happen first
(5 + 3) * 2;

// The expression from PE4!
d = a + b * c;
```

## Sample Output

```
==============================================
 AST POSTORDER (REVERSE POLISH) GENERATOR
==============================================

Postorder Traversal: 5 3 +

Postorder Traversal: 5 3 2 * +

Postorder Traversal: 5 3 + 2 *

Postorder Traversal: d a b c * + =
```

### Walkthrough

| Input | AST (Tree) | Postorder (RPN) | Explanation |
|-------|-----------|-----------------|-------------|
| `5 + 3;` | `+(5, 3)` | `5 3 +` | Simple binary addition |
| `5 + 3 * 2;` | `+(5, *(3, 2))` | `5 3 2 * +` | `*` binds tighter, so it's deeper in the tree |
| `(5 + 3) * 2;` | `*(+(5, 3), 2)` | `5 3 + 2 *` | Parentheses make `+` happen first (deeper in tree) |
| `d = a + b * c;` | `=(d, +(a, *(b, c)))` | `d a b c * + =` | Full assignment with operator precedence |

Notice how `5 + 3 * 2` and `(5 + 3) * 2` produce **different** postorder outputs because the tree structure is different — this proves the AST correctly encodes precedence.

---

## Errors Caught

| Error Type | Example | Parser Output |
|------------|---------|---------------|
| Consecutive operators | `b = 5 + * 3;` | `Syntax Error at line 8: syntax error` |
| Mismatched parentheses | `c = (5 + 3;` | `Syntax Error at line 11: syntax error` |
| Missing semicolon | `d = a + b` (no `;`) | `Syntax Error` — expects `;` but hits EOF |
