// ERROR TEST FILE FOR PE4 — Expression Evaluation + Type Checking
// This file contains deliberate semantic errors to test the parser's error detection.

// 1. Declare some variables
int a, b;
float x;

// 2. Valid assignments
a = 10, b = 20;

// 3. ERROR: Using an undeclared variable
z = 5;

// 4. ERROR: Type mismatch — assigning a float literal to an int variable
a = 3.14;

// 5. ERROR: Type mismatch in arithmetic — adding int and float
b = a + x;

// 6. ERROR: Division by zero
a = b / 0;
