%{
#include "parser.tab.hpp"
#include <string.h>

int yycolumn = 1;

// Macro to automatically track line and column locations for Bison
#define YY_USER_ACTION \
    yylloc.first_line = yylloc.last_line = yylineno; \
    yylloc.first_column = yycolumn; \
    yylloc.last_column = yycolumn + yyleng - 1; \
    yycolumn += yyleng;
%}

%option noyywrap
%option yylineno

%%
"int"       { yylval.str = strdup(yytext); return TYPE; }
"float"     { yylval.str = strdup(yytext); return TYPE; }
"char"      { yylval.str = strdup(yytext); return TYPE; }
"void"      { yylval.str = strdup(yytext); return TYPE; }
"double"    { yylval.str = strdup(yytext); return TYPE; }

"auto"      { yylval.str = strdup(yytext); return STORAGE; }
"static"    { yylval.str = strdup(yytext); return STORAGE; }
"extern"    { yylval.str = strdup(yytext); return STORAGE; }
"register"  { yylval.str = strdup(yytext); return STORAGE; }

"struct"    { return STRUCT; }
"union"     { return UNION; }
"enum"      { return ENUM; }
"typedef"   { return TYPEDEF; }

"{"         { return LBRACE; }
"}"         { return RBRACE; }
"("         { return LPAREN; }
")"         { return RPAREN; }
";"         { return SEMI; }
","         { return COMMA; }
"="         { return ASSIGN; }
"*"         { return STAR; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return IDENTIFIER; }
[0-9]+(\.[0-9]+)?      { yylval.str = strdup(yytext); return NUMBER; }
\"[^\"]*\"             { yylval.str = strdup(yytext); return STRING_LIT; }

\n          { yycolumn = 1; }
[ \t\r]+    { /* Ignore whitespace */ }
"//".* { /* Single-line comment */ }
"/*"([^*]|\*+[^*/])*\*+"/" { /* Multi-line comment */ }
.           { return yytext[0]; }
%%