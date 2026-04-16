// ERROR TEST FILE FOR Ass2 — Control Flow ICG (if-else, do-while)
// This file contains deliberate syntax errors to test the parser's error reporting.

// 1. ERROR: if block missing the else branch (parser requires if-else)
if (a < b) {
    x = 1;
}

// 2. ERROR: do-while missing the semicolon at the end
do {
    count = count + 1;
} while (count != 10)

// 3. ERROR: Missing parentheses around the condition
if a < b {
    x = 1;
} else {
    x = 2;
}
