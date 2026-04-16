// ERROR TEST FILE FOR PE6 — Intermediate Code Generation (Quadruples)
// This file contains deliberate syntax errors to test the parser's error reporting.

// 1. Valid statement (should generate correct quadruples)
d = a + b * c;

// 2. ERROR: Empty assignment — missing right-hand side expression
x = ;

// 3. ERROR: Double operator — consecutive operators without operand
y = a + + b;

// 4. ERROR: Unmatched parenthesis
z = (a + b * c;
