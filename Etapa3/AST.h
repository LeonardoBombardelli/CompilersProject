#include "definitions.h"

struct node_function_declaration {
    Node* firstCommand;
    Node* nextFunction;
};

struct node_var_access {
    ValorLexico* identifier;
    Node* index;
};

struct node_var_attr {
    ValorLexico* identifier; 
    Node* indexVector;
    Node* expression;
};

struct node_input {
    Node* input;
};

struct node_output {
    Node* output;
};

struct node_function_call {
    Node* expressionList;
};

struct node_shift_left {
    ValorLexico* identifier;
    Node* indexVector;
    Node* expression;
};

struct node_shift_right {
    ValorLexico* identifier;
    Node* indexVector;
    Node* expression;
};

struct node_break {

};

struct node_continue {

};

struct node_return {
    Node* toReturn;
};

struct node_if {
    Node* expression;
    Node* ifTrue;
    Node* ifFalse;
};

struct node_for_loop {
    Node* attribution;
    Node* expression;
    Node* incOrDec;
    Node* firstCommand;
};

struct node_while_loop {
    Node* expression;
    Node* firstCommand;
};

struct node_vector_index {
    ValorLexico* identifier;
    Node* index
};


struct node_unary_operation {
    ValorLexico* operation;
    Node* expression;
};

struct node_binary_operation {
    ValorLexico* operation;
    Node* expression1;
    Node* expression2;
};

struct node_ternary_operation {
    Node* expression1;
    Node* expression2;
    Node* expression3;
};

struct node_literal {
    ValorLexico* literal;
};

typedef struct node {
    NodeType nodeType;

    union 
    {
        struct node_function_declaration    n_function_declaration    ;
        struct node_var_access              n_var_access              ;
        struct node_var_attr                n_var_attr                ;
        struct node_input                   n_input                   ;
        struct node_output                  n_output                  ;
        struct node_function_call           n_function_call           ;
        struct node_shift_left              n_shift_left              ;
        struct node_shift_right             n_shift_right             ;
        struct node_break                   n_break                   ;
        struct node_continue                n_continue                ;
        struct node_return                  n_return                  ;
        struct node_if                      n_if                      ;
        struct node_for_loop                n_for_loop                ;
        struct node_while_loop              n_while_loop              ;
        struct node_vector_index            n_vector_index            ;
        struct node_unary_operation         n_unary_operation         ;
        struct node_binary_operation        n_binary_operation        ;
        struct node_ternary_operation       n_ternary_operation       ;
        struct node_literal                 n_literal                 ;
    };
     
} Node;


Node* CreateGenericNode(NodeType nodeType);
Node* Create
