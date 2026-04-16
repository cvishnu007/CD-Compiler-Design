%{
#include <iostream>
#include <string>
#include <cstdlib>
#include <cstring>
#include "symtab.hpp"

using namespace std;

extern int yylex();
extern int yylineno;
extern int yycolumn;
void yyerror(const char* s);

SymbolTable symtab;

// Global state trackers for parsing definitions
string current_type = "";
string current_storage = "auto";
int pointer_level = 0;

// Helper to calculate byte size of C basic types
int get_size(string type, int ptr_lvl) {
    if (ptr_lvl > 0) return 8; // Pointer size
    if (type == "int") return 4;
    if (type == "float") return 4;
    if (type == "char") return 1;
    if (type == "double") return 8;
    if (type == "void") return 0;
    return 4; // Default
}

// Helper to format type strings (e.g. "int**")
string format_type(string base, int ptr_lvl) {
    string res = base;
    for(int i=0; i<ptr_lvl; i++) res += "*";
    return res;
}
%}

%code requires {
    #include <string>
}

%union {
    char* str;
}

%locations

%token <str> IDENTIFIER NUMBER STRING_LIT TYPE STORAGE
%token STRUCT UNION ENUM TYPEDEF
%token LBRACE RBRACE LPAREN RPAREN SEMI COMMA ASSIGN STAR

%%

program:
    program_unit
    | program program_unit
    ;

program_unit:
    declaration
    | func_definition
    | struct_definition
    ;

storage_opt:
    /* empty */ { current_storage = "auto"; }
    | STORAGE   { current_storage = $1; }
    ;

/* Unifying the base type removes the Shift/Reduce parsing conflict */
base_type:
    storage_opt TYPE { current_type = $2; }
    ;

/* Variables and Typedefs */
declaration:
    base_type decl_list SEMI { 
        current_storage = "auto"; 
        current_type = ""; 
    }
    | TYPEDEF TYPE IDENTIFIER SEMI {
        symtab.insert($3, "typedef", $2, "none", get_size($2, 0), @3.first_line, @3.first_column);
    }
    ;

decl_list:
    declarator
    | decl_list COMMA declarator
    ;

declarator:
    pointer_opt IDENTIFIER {
        string t = format_type(current_type, pointer_level);
        symtab.insert($2, "variable", t, current_storage, get_size(current_type, pointer_level), @2.first_line, @2.first_column);
        pointer_level = 0;
    }
    | pointer_opt IDENTIFIER ASSIGN NUMBER {
        string t = format_type(current_type, pointer_level);
        symtab.insert($2, "variable", t, current_storage, get_size(current_type, pointer_level), @2.first_line, @2.first_column, $4);
        pointer_level = 0;
    }
    | pointer_opt IDENTIFIER ASSIGN STRING_LIT {
        string t = format_type(current_type, pointer_level);
        symtab.insert($2, "variable", t, current_storage, get_size(current_type, pointer_level), @2.first_line, @2.first_column, $4);
        pointer_level = 0;
    }
    ;

pointer_opt:
    /* empty */ { pointer_level = 0; }
    | pointers
    ;

pointers:
    STAR { pointer_level++; }
    | pointers STAR { pointer_level++; }
    ;

/* Struct Definitions */
struct_definition:
    STRUCT IDENTIFIER {
        symtab.insert($2, "struct-tag", "struct", "none", 0, @2.first_line, @2.first_column);
        symtab.enterScope();
    } LBRACE struct_member_list RBRACE SEMI {
        symtab.leaveScope();
    }
    ;

struct_member_list:
    declaration
    | struct_member_list declaration
    ;

/* Function Definitions */
func_definition:
    base_type pointer_opt IDENTIFIER LPAREN {
        // By moving this block AFTER the LPAREN, the parser knows for sure it's a function!
        string ret_type = format_type(current_type, pointer_level) + "()";
        symtab.insert($3, "function", ret_type, current_storage, 0, @3.first_line, @3.first_column);
        symtab.enterScope(); // Parameters exist in the function's scope
        pointer_level = 0;
    } param_list_opt RPAREN LBRACE stmt_list RBRACE {
        symtab.leaveScope();
        current_storage = "auto";
    }
    ;

param_list_opt:
    /* empty */
    | param_list
    ;

param_list:
    param
    | param_list COMMA param
    ;

param:
    TYPE pointer_opt IDENTIFIER {
        string t = format_type($1, pointer_level);
        symtab.insert($3, "parameter", t, "auto", get_size($1, pointer_level), @3.first_line, @3.first_column);
        pointer_level = 0;
    }
    ;

/* Blocks and Statements */
stmt_list:
    /* empty */
    | stmt_list stmt
    ;

stmt:
    declaration
    | compound_stmt
    | IDENTIFIER ASSIGN expr SEMI
    | IDENTIFIER LPAREN RPAREN SEMI /* Basic func call */
    ;

compound_stmt:
    LBRACE { symtab.enterScope(); } stmt_list RBRACE { symtab.leaveScope(); }
    ;

expr:
    IDENTIFIER
    | NUMBER
    ;

%%

void yyerror(const char* s) {
    cerr << "Syntax Error at line " << yylineno << ", col " << yycolumn << ": " << s << endl;
}

int main(int argc, char** argv) {
    extern FILE* yyin;
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            cerr << "Cannot open input file: " << argv[1] << endl;
            return 1;
        }
    } else {
        cout << "Reading from standard input. Press Ctrl+D to finish." << endl;
    }
    
    yyparse();
    symtab.printTable();
    
    if(argc > 1) fclose(yyin);
    return 0;
}