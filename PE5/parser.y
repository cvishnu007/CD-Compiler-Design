%{
#include <iostream>
#include <string>
#include <cstdlib>
#include "ast.hpp"

using namespace std;

extern int yylex();
extern int yylineno;
void yyerror(const char* s);

%}

/* Define the union to hold either string lexemes or AST Node pointers */
%code requires {
    #include "ast.hpp"
}

%union {
    char* str;
    ASTNode* node;
}

%token <str> IDENTIFIER NUMBER
%token ASSIGN PLUS MINUS MUL DIV LPAREN RPAREN SEMI

/* Map our grammar rules to return ASTNode pointers */
%type <node> expr term factor assignment

%%

program:
    stmt_list
    ;

stmt_list:
    stmt
    | stmt_list stmt
    ;

stmt:
    assignment SEMI {
        cout << "Postorder Traversal: ";
        printPostOrder($1);
        cout << "\n\n";
        freeAST($1); // Clean up memory
    }
    | expr SEMI {
        cout << "Postorder Traversal: ";
        printPostOrder($1);
        cout << "\n\n";
        freeAST($1);
    }
    ;

assignment:
    IDENTIFIER ASSIGN expr {
        $$ = new ASTNode("=", new ASTNode($1), $3);
    }
    ;

expr:
    expr PLUS term { $$ = new ASTNode("+", $1, $3); }
    | expr MINUS term { $$ = new ASTNode("-", $1, $3); }
    | term { $$ = $1; }
    ;

term:
    term MUL factor { $$ = new ASTNode("*", $1, $3); }
    | term DIV factor { $$ = new ASTNode("/", $1, $3); }
    | factor { $$ = $1; }
    ;

factor:
    IDENTIFIER { $$ = new ASTNode($1); }
    | NUMBER { $$ = new ASTNode($1); }
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
    
    cout << "==============================================\n";
    cout << " AST POSTORDER (REVERSE POLISH) GENERATOR\n";
    cout << "==============================================\n\n";
    
    yyparse();
    
    if (argc > 1) fclose(yyin);
    return 0;
}