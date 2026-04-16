%{
#include <iostream>
#include <string>
#include "ast.hpp"

using namespace std;

extern int yylex();
extern int yylineno;
void yyerror(const char* s);

int temp_count = 0;
int label_count = 0;
%}

%code requires {
    #include "ast.hpp"
}

%union {
    char* str;
    ASTNode* node;
}

%token IF ELSE DO WHILE LBRACE RBRACE LPAREN RPAREN SEMI
%token <str> IDENTIFIER NUMBER RELOP ASSIGN PLUS MINUS MUL DIV

%type <node> program stmt_list stmt cond expr term factor assignment

%%

program:
    stmt_list {
        cout << "\n==============================================\n";
        cout << " 1. AST POSTORDER TRAVERSAL\n";
        cout << "==============================================\n";
        printPostOrder($1);
        cout << "\n\n";

        cout << "==============================================\n";
        cout << " 2. INTERMEDIATE CODE (QUADRUPLES)\n";
        cout << "==============================================\n";
        generateTAC($1);
        cout << "==============================================\n\n";

        freeAST($1);
    }
    ;

/* S acts as a sequence of statements to match the trailing 'S' in your grammar */
stmt_list:
    stmt { $$ = $1; }
    | stmt_list stmt { $$ = new ASTNode("SEQ", "", $1, $2); }
    ;

/* The core Control Flow rules based on your prompt */
stmt:
    IF LPAREN cond RPAREN LBRACE stmt_list RBRACE ELSE LBRACE stmt_list RBRACE {
        $$ = new ASTNode("IF", "", $3, $6, $10);
    }
    | DO LBRACE stmt_list RBRACE WHILE LPAREN cond RPAREN SEMI {
        $$ = new ASTNode("DO_WHILE", "", $3, $7);
    }
    | assignment SEMI { $$ = $1; }
    ;

/* C -> T_ID rel T_ID (Extended slightly to allow Numbers as well as IDs) */
cond:
    IDENTIFIER RELOP IDENTIFIER { 
        $$ = new ASTNode("COND", $2, new ASTNode("ID", $1), new ASTNode("ID", $3)); 
    }
    | IDENTIFIER RELOP NUMBER { 
        $$ = new ASTNode("COND", $2, new ASTNode("ID", $1), new ASTNode("NUM", $3)); 
    }
    ;

assignment:
    IDENTIFIER ASSIGN expr {
        $$ = new ASTNode("ASSIGN", "=", new ASTNode("ID", $1), $3);
    }
    ;

/* Basic Arithmetic from PE5 */
expr:
    expr PLUS term { $$ = new ASTNode("OP", "+", $1, $3); }
    | expr MINUS term { $$ = new ASTNode("OP", "-", $1, $3); }
    | term { $$ = $1; }
    ;

term:
    term MUL factor { $$ = new ASTNode("OP", "*", $1, $3); }
    | term DIV factor { $$ = new ASTNode("OP", "/", $1, $3); }
    | factor { $$ = $1; }
    ;

factor:
    IDENTIFIER { $$ = new ASTNode("ID", $1); }
    | NUMBER { $$ = new ASTNode("NUM", $1); }
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
    if (argc > 1) fclose(yyin);
    return 0;
}