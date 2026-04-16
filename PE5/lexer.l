%{
#include "parser.tab.hpp"
#include <string.h>
#include <stdlib.h>
%}

%option noyywrap
%option yylineno

%%
[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return IDENTIFIER; }
[0-9]+(\.[0-9]+)?      { yylval.str = strdup(yytext); return NUMBER; }

"="         { return ASSIGN; }
"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return MUL; }
"/"         { return DIV; }
"("         { return LPAREN; }
")"         { return RPAREN; }
";"         { return SEMI; }

[ \t\r\n]+  { /* ignore whitespace */ }
"//".* { /* Ignore single-line comments */ }
.           { return yytext[0]; }
%%