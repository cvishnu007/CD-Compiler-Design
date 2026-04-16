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