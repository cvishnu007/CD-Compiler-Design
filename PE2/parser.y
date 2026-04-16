%{
#include <stdio.h>
#include <stdlib.h>

extern int yylineno;
extern char* yytext;
extern int yylex();
void yyerror(const char *s);
%}

/* Token Definitions (Provided by Lex) */
%token INT FLOAT CHAR DOUBLE
%token IF ELSE DO WHILE
%token ID NUM
%token EQ NEQ LE GE AND OR

/* Operator Precedence and Associativity 
   (Lower lines have higher precedence) 
*/
%nonassoc LOWER_THAN_ELSE /* Used to resolve dangling-else conflict */
%nonassoc ELSE

%right '='
%left OR
%left AND
%left EQ NEQ
%left '<' '>' LE GE
%left '+' '-'
%left '*' '/' '%'
%right UMINUS /* Unary minus */

%%

/* --- Grammar Rules --- */

program:
    statements { 
        printf("Syntax valid.\n"); 
        exit(0); 
    }
    ;

statements:
    statements statement
    | /* empty */
    ;

statement:
    declaration
    | assignment
    | if_statement
    | do_while_statement
    | block
    ;

block:
    '{' statements '}'
    ;

/* Declarations (e.g., int x, y = 5;) */
declaration:
    type var_list ';'
    ;

type:
    INT | FLOAT | CHAR | DOUBLE
    ;

var_list:
    var
    | var_list ',' var
    ;

var:
    ID
    | ID '=' expression
    ;

/* Assignments */
assignment:
    ID '=' expression ';'
    ;

/* Control Structures */
if_statement:
    IF '(' expression ')' statement %prec LOWER_THAN_ELSE
    | IF '(' expression ')' statement ELSE statement
    ;

do_while_statement:
    DO statement WHILE '(' expression ')' ';'
    ;

/* Expressions */
expression:
    expression '+' expression
    | expression '-' expression
    | expression '*' expression
    | expression '/' expression
    | expression '%' expression
    | '-' expression %prec UMINUS
    | expression '<' expression
    | expression '>' expression
    | expression LE expression
    | expression GE expression
    | expression EQ expression
    | expression NEQ expression
    | expression AND expression
    | expression OR expression
    | '(' expression ')'
    | ID
    | NUM
    ;

%%

/* --- Error Handling and Main --- */

void yyerror(const char *s) {
    /* Required format: Syntax error at line <n>, token <t>: <message> */
    printf("Syntax error at line %d, token %s: %s\n", yylineno, yytext, s);
}

int main() {
    // Parse from stdin
    return yyparse();
}