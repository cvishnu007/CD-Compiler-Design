%{
#include <iostream>
#include <string>
#include <cstdlib>
#include "symtab.hpp"

using namespace std;

extern int yylex();
extern int yylineno;
void yyerror(const char* s);

SymbolTable symtab;
string current_type = "";
%}

/* We define a custom struct so an expression passes both its Value and its Type up the tree */
%code requires {
    struct ExprResult {
        double val;
        int type; // 0 for int, 1 for float
    };
}

%union {
    char* str;
    int ival;
    double fval;
    ExprResult expr_val;
}

%token <str> IDENTIFIER
%token <ival> INT_LIT
%token <fval> FLOAT_LIT
%token INT_KW FLOAT_KW
%token ASSIGN PLUS MINUS MUL DIV LPAREN RPAREN COMMA SEMI

%type <expr_val> expr term factor
%type <str> type_specifier

%%

program:
    stmt_list
    ;

stmt_list:
    stmt
    | stmt_list stmt
    ;

stmt:
    declaration SEMI
    | assignment_list SEMI
    ;

declaration:
    type_specifier ident_list
    ;

type_specifier:
    INT_KW   { current_type = "int"; }
    | FLOAT_KW { current_type = "float"; }
    ;

ident_list:
    IDENTIFIER { symtab.declare($1, current_type); }
    | ident_list COMMA IDENTIFIER { symtab.declare($3, current_type); }
    ;

assignment_list:
    assignment
    | assignment_list COMMA assignment
    ;

assignment:
    IDENTIFIER ASSIGN expr {
        Symbol* sym = symtab.lookup($1);
        if (!sym) {
            cerr << "[Semantic Error] Variable '" << $1 << "' not declared before use at line " << yylineno << "\n";
        } else {
            int sym_type = (sym->type == "int") ? 0 : 1;
            if (sym_type != $3.type) {
                cerr << "[Type Mismatch Error] Cannot assign value of different type to variable '" << $1 << "' at line " << yylineno << "\n";
            } else {
                sym->value = $3.val;
                sym->initialized = true;
            }
        }
    }
    ;

expr:
    expr PLUS term {
        if ($1.type != $3.type) cerr << "[Type Mismatch] Adding different types at line " << yylineno << "\n";
        $$.type = $1.type; $$.val = $1.val + $3.val;
    }
    | expr MINUS term {
        if ($1.type != $3.type) cerr << "[Type Mismatch] Subtracting different types at line " << yylineno << "\n";
        $$.type = $1.type; $$.val = $1.val - $3.val;
    }
    | term { $$ = $1; }
    ;

term:
    term MUL factor {
        if ($1.type != $3.type) cerr << "[Type Mismatch] Multiplying different types at line " << yylineno << "\n";
        $$.type = $1.type; $$.val = $1.val * $3.val;
    }
    | term DIV factor {
        if ($1.type != $3.type) cerr << "[Type Mismatch] Dividing different types at line " << yylineno << "\n";
        $$.type = $1.type; 
        if ($3.val == 0) { cerr << "[Math Error] Division by zero!\n"; $$.val = 0; } 
        else $$.val = $1.val / $3.val;
    }
    | factor { $$ = $1; }
    ;

factor:
    IDENTIFIER {
        Symbol* sym = symtab.lookup($1);
        if (!sym) {
            cerr << "[Semantic Error] Variable '" << $1 << "' used before declaration at line " << yylineno << "\n";
            $$.type = 0; $$.val = 0;
        } else {
            $$.type = (sym->type == "int") ? 0 : 1;
            $$.val = sym->value;
        }
    }
    | INT_LIT { $$.type = 0; $$.val = $1; }
    | FLOAT_LIT { $$.type = 1; $$.val = $1; }
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
        if (!yyin) return 1;
    }
    yyparse();
    symtab.printTable();
    if (argc > 1) fclose(yyin);
    return 0;
}