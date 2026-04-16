%{
#include <stdio.h>
#include <stdlib.h>

extern int yylineno;
extern char* yytext;
extern int yylex();
void yyerror(const char *s);
%}

/* Tokens */
%token INT FLOAT CHAR DOUBLE
%token IF ELSE DO WHILE FOR SWITCH CASE DEFAULT BREAK
%token ID NUM
%token EQ NEQ LE GE AND OR INC DEC

/* Precedence */
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%right '='
%left OR
%left AND
%left EQ NEQ
%left '<' '>' LE GE
%left '+' '-'
%left '*' '/' '%'
%right INC DEC UMINUS

%%

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
    | expression_statement
    | if_statement
    | do_while_statement
    | while_statement
    | for_statement
    | switch_statement
    | break_statement
    | block
    ;

block:
    '{' statements '}'
    ;

/* --- Declarations & Arrays --- */
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

/* Handles: a, a=5, a[10], a[5][5] */
var:
    ID
    | ID array_dims
    | ID '=' expression
    ;

/* Handles recursive multidimensional arrays like [1][2][3][4] */
array_dims:
    '[' expression ']'
    | array_dims '[' expression ']'
    ;

/* --- Control Structures --- */
if_statement:
    IF '(' expression ')' statement %prec LOWER_THAN_ELSE
    | IF '(' expression ')' statement ELSE statement
    ;

do_while_statement:
    DO statement WHILE '(' expression ')' ';'
    ;

while_statement:
    WHILE '(' expression ')' statement
    ;

/* For loops support comma-separated expressions (e.g., i=0, j=0) */
for_statement:
    FOR '(' expr_list_opt ';' expr_list_opt ';' expr_list_opt ')' statement
    ;

switch_statement:
    SWITCH '(' expression ')' '{' case_list '}'
    ;

case_list:
    case_item case_list
    | /* empty */
    ;

case_item:
    CASE expression ':' statements
    | DEFAULT ':' statements
    ;

break_statement:
    BREAK ';'
    ;

/* --- Expressions --- */
expression_statement:
    expression ';'
    | ';' /* Handles empty statements */
    ;

/* Optional expression list for For-Loops */
expr_list_opt:
    expr_list
    | /* empty */
    ;

expr_list:
    expression
    | expr_list ',' expression
    ;

expression:
    ID '=' expression
    | ID array_dims '=' expression
    | expression '+' expression
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
    | ID INC
    | ID DEC
    | INC ID
    | DEC ID
    | '(' expression ')'
    | ID
    | ID array_dims
    | NUM
    ;

%%

void yyerror(const char *s) {
    printf("Syntax error at line %d, token %s: %s\n", yylineno, yytext, s);
}

int main() {
    return yyparse();
}