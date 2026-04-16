%{
#include "parser.tab.h" /* Use your Bison header filename here */
#include <stdio.h>
%}

%option yylineno
%option noyywrap

%%

[ \t\r\n]+               { /* Ignore whitespace */ }
"//".* { /* Ignore single-line comments */ }
"/*"([^*]|\*+[^*/])*\*+"/" { /* Ignore multi-line comments */ }

    /* Types */
"int"       { return INT; }
"float"     { return FLOAT; }
"char"      { return CHAR; }
"double"    { return DOUBLE; }

    /* Control Structures */
"if"        { return IF; }
"else"      { return ELSE; }
"do"        { return DO; }
"while"     { return WHILE; }
"for"       { return FOR; }
"switch"    { return SWITCH; }
"case"      { return CASE; }
"default"   { return DEFAULT; }
"break"     { return BREAK; }

    /* Identifiers and Numbers */
[a-zA-Z_][a-zA-Z0-9_]* { return ID; }
[0-9]+(\.[0-9]+)?      { return NUM; }

    /* Multi-character Operators */
"=="        { return EQ; }
"!="        { return NEQ; }
"<="        { return LE; }
">="        { return GE; }
"&&"        { return AND; }
"||"        { return OR; }
"++"        { return INC; }
"--"        { return DEC; }

    /* Single character operators and punctuators */
.           { return yytext[0]; }

%%