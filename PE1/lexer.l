%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Global flag to handle comma separation in the JSON array */
int first_token = 1;

/* Function to print a token as a formatted JSON object and handle character escaping */
void print_json_token(const char* type, const char* lexeme) {
    if (!first_token) {
        printf(",\n");
    }
    first_token = 0;
    
    printf("  {\n    \"type\": \"%s\",\n    \"lexeme\": \"", type);
    
    /* Safely escape special characters for valid JSON */
    for (int i = 0; lexeme[i] != '\0'; i++) {
        switch (lexeme[i]) {
            case '"':  printf("\\\""); break;
            case '\\': printf("\\\\"); break;
            case '\b': printf("\\b"); break;
            case '\f': printf("\\f"); break;
            case '\n': printf("\\n"); break;
            case '\r': printf("\\r"); break;
            case '\t': printf("\\t"); break;
            default:   putchar(lexeme[i]);
        }
    }
    printf("\"\n  }");
}
%}

/* --- Upgraded Regular Definitions --- */
LETTER      [a-zA-Z_]
DIGIT       [0-9]
HEX_DIGIT   [0-9a-fA-F]

    /* Suffixes for constants */
INT_SUFFIX  ([uU][lL]{0,2}|[lL]{1,2}[uU]?)
FLOAT_SUFFIX [fFlL]

    /* Identifiers and Constants with Suffixes */
IDENTIFIER  {LETTER}({LETTER}|{DIGIT})*
INTEGER     {DIGIT}+{INT_SUFFIX}?
FLOAT       ({DIGIT}*\.{DIGIT}+|{DIGIT}+\.)([eE][+-]?{DIGIT}+)?{FLOAT_SUFFIX}?
HEX         0[xX]{HEX_DIGIT}+{INT_SUFFIX}?

    /* Strings and Chars with optional L, u, U, u8 prefixes */
STR_PREFIX  (L|u|U|u8)?
STRING      {STR_PREFIX}\"([^\\\"]|\\.)*\"
CHAR        {STR_PREFIX}\'([^\\\']|\\.)*\'

%%

    /* --- Comments and Whitespace --- */
"/*"([^*]|\*+[^*/])*\*+"/"  { /* Ignore */ }
"//".* { /* Ignore */ }
[ \t\n\r]+                  { /* Ignore */ }

    /* --- Upgraded Keywords (Including C99/C11) --- */
"auto"|"break"|"case"|"char"|"const"|"continue"|"default"|"do"|"double"|"else"|"enum"|"extern"|"float"|"for"|"goto"|"if"|"inline"|"int"|"long"|"register"|"restrict"|"return"|"short"|"signed"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"|"unsigned"|"void"|"volatile"|"while"|"_Bool"|"_Complex"|"_Atomic" {
    print_json_token("KEYWORD", yytext);
}

    /* --- Multi-line Preprocessor Directives --- */
    /* Matches '#' followed by anything. If it sees a '\' followed by a newline, it keeps going */
^[ \t]*#([^\n]|\\\n)* { 
    print_json_token("PREPROCESSOR", yytext); 
}

    /* --- Identifiers --- */
{IDENTIFIER}                { print_json_token("IDENTIFIER", yytext); }

    /* --- Constants --- */
{HEX}                       { print_json_token("CONSTANT_HEX", yytext); }
{FLOAT}                     { print_json_token("CONSTANT_FLOAT", yytext); }
{INTEGER}                   { print_json_token("CONSTANT_INTEGER", yytext); }

    /* --- Strings and Characters --- */
{STRING}                    { print_json_token("STRING_LITERAL", yytext); }
{CHAR}                      { print_json_token("CHAR_LITERAL", yytext); }

    /* --- Operators (Added Ellipsis '...') --- */
"..."|"=="|"!="|"<="|">="|">>"|"<<"|"++"|"--"|"&&"|"||"|"+="|"-="|"*="|"/="|"%="|"<<="|">>="|"&="|"^="|"|="|"->" {
    print_json_token("OPERATOR", yytext);
}
"+"|"-"|"*"|"/"|"%"|"<"|">"|"="|":"|"?"|"!"|"&"|"|"|"^"|"~"|"." {
    print_json_token("OPERATOR", yytext);
}

    /* --- Punctuators / Separators --- */
"{"|"}"|"["|"]"|"("|")"|";"|"," {
    print_json_token("PUNCTUATOR", yytext);
}

    /* --- Catch-all --- */
.                           { print_json_token("UNKNOWN_TOKEN", yytext); }

%%

/* --- User Code Section --- */

int yywrap() {
    return 1;
}

int main(int argc, char **argv) {
    // 1. Handle input file
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror("Error opening input file");
            return 1;
        }
        yyin = file;
    }
    
    // 2. Redirect stdout to a file named "tokens.json"
    // Now, all printf() calls will write to this file automatically!
    FILE *outfile = freopen("tokens.json", "w", stdout);
    if (!outfile) {
        perror("Error creating output file");
        return 1;
    }
    
    // 3. Start generating JSON
    printf("[\n");
    
    yylex(); 
    
    printf("\n]\n");
    
    // Close the file when done
    fclose(outfile);
    
    // Print a success message to stderr so it shows up on the console, not in the JSON file
    fprintf(stderr, "Success! Tokens saved to tokens.json\n");
    
    return 0;
}