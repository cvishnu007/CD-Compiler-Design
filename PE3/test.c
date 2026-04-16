typedef int MyInt;

struct Point {
    int x = 0;
    int y = 0;
};

static float global_pi = 3.14;
extern char* shared_msg = "Hello";

void calculate(int multiplier) {
    int result = 0;
    
    {
        // Nested Scope
        int temp_var = 10;
        result = temp_var;
    }
}