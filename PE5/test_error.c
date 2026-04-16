// ERROR TEST FILE FOR PE5 — AST Generation (Postorder)
// This file contains deliberate syntax errors to test the parser's error reporting.

// 1. Valid statement (should work fine)
a = 5 + 3;

// 2. ERROR: Missing operand — two operators in a row
b = 5 + * 3;

// 3. ERROR: Mismatched parentheses — missing closing paren
c = (5 + 3;

// 4. ERROR: Missing semicolon at end of statement
d = a + b
