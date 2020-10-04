#include <stdio.h>
#include <stdbool.h>

typedef enum 
{
    NODE_FUNCTION_DECLARATION    ,
    NODE_VAR_ACCESS              ,
    NODE_VAR_ATTR                ,
    NODE_INPUT                   ,
    NODE_OUTPUT                  ,
    NODE_FUNCTION_CALL           ,
    NODE_SHIFT_LEFT              ,
    NODE_SHIFT_RIGHT             ,
    NODE_BREAK                   ,
    NODE_CONTINUE                ,
    NODE_RETURN                  ,
    NODE_IF                      ,
    NODE_FOR_LOOP                ,
    NODE_WHILE_LOOP              ,
    NODE_VECTOR_INDEX            ,
    NODE_UNARY_OPERATION         ,
    NODE_BINARY_OPERATION        ,
    NODE_TERNARY_OPERATION       ,
    NODE_LITERAL

} NodeType;

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
    NOT_LITERAL_TYPE        //Caso, obviamente, não seja um literal :)

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
