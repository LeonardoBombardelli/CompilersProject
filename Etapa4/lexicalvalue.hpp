#include <cstdio>
#include <cstdbool>

typedef enum
{
    TOKEN_TYPE_SPECIAL_CHAR    ,
    TOKEN_TYPE_COMPOSITE_OP    ,
    TOKEN_TYPE_IDENTIFIER      ,
    TOKEN_TYPE_LITERAL

} TokenType;

typedef enum
{
    LITERAL_TYPE_INTEGER ,
    LITERAL_TYPE_FLOAT   ,
    LITERAL_TYPE_CHAR    ,
    LITERAL_TYPE_BOOL    ,
    LITERAL_TYPE_STRING  ,
    NOT_LITERAL_TYPE

} LiteralType;

typedef union tokenValue
{
    int integer    ;
    float floating ;
    char character ;
    bool boolean   ;
    char* string   ;

} TokenValue;

typedef struct valorLexico {
    int line_number;
    TokenType tokenType;
    LiteralType literalType;
    TokenValue tokenValue;

} ValorLexico;
