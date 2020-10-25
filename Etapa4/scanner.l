
%{
    #include "parser.tab.h"
    #include "../include/lexicalvalue.hpp"

    extern "C" int yylex();

    int numberLines = 1;
    void create_token_not_literal(TokenType token_type);
    void create_token_literal(LiteralType literal_type);

%}
%option yylineno

DIGIT [0-9]
LETTER [A-Za-z_]
ALNUM ({DIGIT}|{LETTER})
INTEGER {DIGIT}+
EXP [Ee][+|-]?{INTEGER}

/* Multiple line comments state. Check more at https://ftp.gnu.org/old-gnu/Manuals/flex-2.5.4/html_node/flex_11.html */
%x MULTIPLE_LINE_COMMENT

%%

 /* reserved words */
 /* no need to call create_token_not_literal for these */

"int"       { return TK_PR_INT       ; }
"float"     { return TK_PR_FLOAT     ; }
"bool"      { return TK_PR_BOOL      ; }
"char"      { return TK_PR_CHAR      ; }
"string"    { return TK_PR_STRING    ; }
"if"        { return TK_PR_IF        ; }
"then"      { return TK_PR_THEN      ; }
"else"      { return TK_PR_ELSE      ; }
"while"     { return TK_PR_WHILE     ; }
"do"        { return TK_PR_DO        ; }
"input"     { return TK_PR_INPUT     ; }
"output"    { return TK_PR_OUTPUT    ; }
"return"    { return TK_PR_RETURN    ; }
"const"     { return TK_PR_CONST     ; }
"static"    { return TK_PR_STATIC    ; }
"foreach"   { return TK_PR_FOREACH   ; }
"for"       { return TK_PR_FOR       ; }
"switch"    { return TK_PR_SWITCH    ; }
"case"      { return TK_PR_CASE      ; }
"break"     { return TK_PR_BREAK     ; }
"continue"  { return TK_PR_CONTINUE  ; }
"class"     { return TK_PR_CLASS     ; }
"private"   { return TK_PR_PRIVATE   ; }
"public"    { return TK_PR_PUBLIC    ; }
"protected" { return TK_PR_PROTECTED ; }
"end"       { return TK_PR_END       ; }
"default"   { return TK_PR_DEFAULT   ; }


 /* composite operators */

"<=" { create_token_not_literal(TOKEN_TYPE_COMPOSITE_OP); return TK_OC_LE  ; }
">=" { create_token_not_literal(TOKEN_TYPE_COMPOSITE_OP); return TK_OC_GE  ; }
"==" { create_token_not_literal(TOKEN_TYPE_COMPOSITE_OP); return TK_OC_EQ  ; }
"!=" { create_token_not_literal(TOKEN_TYPE_COMPOSITE_OP); return TK_OC_NE  ; }
"&&" { create_token_not_literal(TOKEN_TYPE_COMPOSITE_OP); return TK_OC_AND ; }
"||" { create_token_not_literal(TOKEN_TYPE_COMPOSITE_OP); return TK_OC_OR  ; }
">>" { create_token_not_literal(TOKEN_TYPE_COMPOSITE_OP); return TK_OC_SR  ; }
"<<" { create_token_not_literal(TOKEN_TYPE_COMPOSITE_OP); return TK_OC_SL  ; }


 /* special chars */

"," { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
";" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
":" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"(" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
")" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"[" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"]" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"{" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"}" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"+" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"-" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"|" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"*" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"/" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"<" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
">" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"=" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"!" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"&" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"%" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"#" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"^" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"." { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"$" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }
"?" { create_token_not_literal(TOKEN_TYPE_SPECIAL_CHAR); return yytext[0]; }



 /* literals */

"false"                   { create_token_literal(LITERAL_TYPE_BOOL); return TK_LIT_FALSE; }
"true"                    { create_token_literal(LITERAL_TYPE_BOOL); return TK_LIT_TRUE; }

['][^\'][']               { create_token_literal(LITERAL_TYPE_CHAR); return TK_LIT_CHAR; }
[']\\[rnt][']             { create_token_literal(LITERAL_TYPE_CHAR); return TK_LIT_CHAR; }
["][^\"\n]*["]            { create_token_literal(LITERAL_TYPE_STRING); return TK_LIT_STRING; }

{INTEGER}                 { create_token_literal(LITERAL_TYPE_INTEGER); return TK_LIT_INT; }
{INTEGER}\.{DIGIT}+{EXP}? { create_token_literal(LITERAL_TYPE_FLOAT); return TK_LIT_FLOAT; }

{DIGIT}({ALNUM}|_)+       { return TOKEN_ERRO; } /* identifier starting with number */
{LETTER}{ALNUM}*          { create_token_not_literal(TOKEN_TYPE_IDENTIFIER); return TK_IDENTIFICADOR; }


 /* comments */

[/][/][^\n]* { }                            /* single line comment */

[/][*] { BEGIN(MULTIPLE_LINE_COMMENT); }    /* multiline comment */
<MULTIPLE_LINE_COMMENT>{
    [*][/] { BEGIN(INITIAL); }
    [\n]   { numberLines+=1; }
    .      { }
}


 /* others */

[ \r\t]+ {  }
[\n] { numberLines+=1; }

. { return TOKEN_ERRO; }

%%

void create_token_not_literal(TokenType token_type) {
    yylval.valor_lexico = (ValorLexico*) calloc(1, sizeof(ValorLexico));
    yylval.valor_lexico->line_number = yylineno;
    yylval.valor_lexico->tokenType = token_type;
    yylval.valor_lexico->literalType = NOT_LITERAL_TYPE;

    if (token_type == TOKEN_TYPE_SPECIAL_CHAR)
    {
        yylval.valor_lexico->tokenValue.character = yytext[0];
    }
    else // TOKEN_TYPE_COMPOSITE_OP or TOKEN_TYPE_IDENTIFIER
    {
        yylval.valor_lexico->tokenValue.string = strdup(yytext);
    }
}

void create_token_literal(LiteralType literal_type) {
    yylval.valor_lexico = (ValorLexico*) calloc(1, sizeof(ValorLexico));
    yylval.valor_lexico->line_number = yylineno;
    yylval.valor_lexico->tokenType = TOKEN_TYPE_LITERAL;
    yylval.valor_lexico->literalType = literal_type;

    char *tmp1 = (char *) calloc(strlen(yytext)+1,sizeof(char));
    char *tmp2 = (char *) calloc(strlen(yytext)+1,sizeof(char));

    switch(literal_type) {
        case LITERAL_TYPE_INTEGER:
            yylval.valor_lexico->tokenValue.integer = atoi(yytext);
            break;

        case LITERAL_TYPE_FLOAT:
            yylval.valor_lexico->tokenValue.floating = atof(yytext);
            break;

        case LITERAL_TYPE_CHAR:
            if (yytext[1] == '\\')    // if literal was an escaped char
            {
                char escaped_char;
                switch(yytext[2]) {
                    case 'r': escaped_char = '\r'; break;
                    case 'n': escaped_char = '\n'; break;
                    case 't': escaped_char = '\t';
                }
                yylval.valor_lexico->tokenValue.character = escaped_char;
            }
            else
            {
                yylval.valor_lexico->tokenValue.character = yytext[1];
            }
            break;

        case LITERAL_TYPE_BOOL:
            // strcmp returns 0 if equal
            yylval.valor_lexico->tokenValue.boolean = strcmp(yytext, "true") ? false : true;
            break;

        case LITERAL_TYPE_STRING:
            tmp1 = strcpy(tmp1, &yytext[1]);
            tmp2 = strncpy(tmp2,tmp1,strlen(tmp1)-1);

            yylval.valor_lexico->tokenValue.string = strdup(tmp2);

            break;
        
        default:
            printf("Erro!!!");
    }
    
    free(tmp1); tmp1 = NULL;
    free(tmp2); tmp2 = NULL;  
}

int get_line_number() {
    return numberLines;
}
