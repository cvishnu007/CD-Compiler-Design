%{
#include "parser.tab.hpp"
#include <string.h>
%}

%option noyywrap
%option yylineno

%%
"if"        { return IF; }
"else"      { return ELSE; }
"do"        { return DO; }
"while"     { return WHILE; }

"<"|">"|"<="|">="|"=="|"!=" { yylval.str = strdup(yytext); return RELOP; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return IDENTIFIER; }
[0-9]+                 { yylval.str = strdup(yytext); return NUMBER; }

"="         { return ASSIGN; }
"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return MUL; }
"/"         { return DIV; }

"{"         { return LBRACE; }
"}"         { return RBRACE; }
"("         { return LPAREN; }
")"         { return RPAREN; }
";"         { return SEMI; }

[ \t\r\n]+  { /* ignore whitespace */ }
"//".* { /* Ignore single-line comments */ }
.           { return yytext[0]; }
%%