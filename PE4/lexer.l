%{
#include "parser.tab.hpp"
#include <string.h>
#include <stdlib.h>
%}

%option noyywrap
%option yylineno

%%
"int"       { return INT_KW; }
"float"     { return FLOAT_KW; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return IDENTIFIER; }
[0-9]+                 { yylval.ival = atoi(yytext); return INT_LIT; }
[0-9]+\.[0-9]+         { yylval.fval = atof(yytext); return FLOAT_LIT; }

"="         { return ASSIGN; }
"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return MUL; }
"/"         { return DIV; }
"("         { return LPAREN; }
")"         { return RPAREN; }
","         { return COMMA; }
";"         { return SEMI; }

"//".* { /* Ignore single-line comments */ }
"/*"([^*]|\*+[^*/])*\*+"/" { /* Ignore multi-line comments */ }

[ \t\r\n]+  { /* ignore whitespace */ }
.           { return yytext[0]; }
%%