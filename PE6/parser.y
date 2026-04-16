%{
#include <iostream>
#include <string>
#include <cstdlib>
#include <cstring>

using namespace std;

extern int yylex();
extern int yylineno;
void yyerror(const char* s);

// Global counter for temporary variables
int temp_count = 0;

// Function to generate new temporaries (t0, t1, t2...)
string newTemp() {
    return "t" + to_string(temp_count++);
}

// Function to print the Intermediate Code in Quadruple format
void emit(string op, string arg1, string arg2, string result) {
    // If an argument is empty (like in an assignment), we just print a blank space or underscore
    if (arg2 == "") arg2 = "_"; 
    cout << "(" << op << ", " << arg1 << ", " << arg2 << ", " << result << ")\n";
}

%}

%union {
    char* str;
}

%token <str> IDENTIFIER NUMBER
%token ASSIGN PLUS MINUS MUL DIV LPAREN RPAREN SEMI

/* The semantic value of an expression is the string of where its result is stored 
   (e.g., a variable name or a temporary like "t0") */
%type <str> expr term factor assignment

%%

program:
    stmt_list
    ;

stmt_list:
    stmt
    | stmt_list stmt
    ;

stmt:
    assignment SEMI { cout << "--------------------------------\n"; }
    | expr SEMI { cout << "--------------------------------\n"; }
    ;

assignment:
    IDENTIFIER ASSIGN expr {
        // Quadruple for assignment: (=, source, empty, destination)
        emit("=", $3, "", $1);
        $$ = strdup($1);
        
        // Reset temp counter after a full statement is completed (optional, but keeps output clean)
        temp_count = 0; 
    }
    ;

expr:
    expr PLUS term {
        string t = newTemp();
        emit("+", $1, $3, t);
        $$ = strdup(t.c_str()); // Pass the temp variable up the tree
    }
    | expr MINUS term {
        string t = newTemp();
        emit("-", $1, $3, t);
        $$ = strdup(t.c_str());
    }
    | term { $$ = $1; }
    ;

term:
    term MUL factor {
        string t = newTemp();
        emit("*", $1, $3, t);
        $$ = strdup(t.c_str());
    }
    | term DIV factor {
        string t = newTemp();
        emit("/", $1, $3, t);
        $$ = strdup(t.c_str());
    }
    | factor { $$ = $1; }
    ;

factor:
    IDENTIFIER { $$ = $1; }
    | NUMBER { $$ = $1; }
    | LPAREN expr RPAREN { $$ = $2; }
    ;

%%

void yyerror(const char* s) {
    cerr << "Syntax Error at line " << yylineno << ": " << s << endl;
}

int main(int argc, char** argv) {
    extern FILE* yyin;
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            cerr << "Cannot open file.\n";
            return 1;
        }
    }
    
    cout << "================================\n";
    cout << " INTERMEDIATE CODE (QUADRUPLES) \n";
    cout << " Format: (op, arg1, arg2, result)\n";
    cout << "================================\n";
    
    yyparse();
    
    if (argc > 1) fclose(yyin);
    return 0;
}