// ERROR TEST FILE FOR PE3 — Symbol Table Construction
// This file contains deliberate syntax errors to test the parser's error reporting.

// 1. Missing semicolon after variable declaration
int a = 5

// 2. Missing closing brace in struct definition
struct Broken {
    int x;
    float y;

// 3. Missing return type for function
calculate(int a, int b) {
    int result = 0;
}
