#include "definitions.h"

typedef struct node {
    Node* nextNode;
    NodeType nodeType;

    union 
    {
        struct node_function_list    ;
        struct node_command_list     ;
        struct node_expression_list  ;
        struct node_var_attr         ;
        struct node_input            ;
        struct node_output           ;
        struct node_function_call    ;
        struct node_shift_left       ;
        struct node_shift_right      ;
        struct node_break            ;
        struct node_continue         ;
        struct node_return           ;
        struct node_if               ;
        struct node_for_loop         ;
        struct node_while_loop       ;
        struct node_vector_index     ;
        struct node_unary_operation  ;
        struct node_binary_operation ;
        struct node_ternary_operation;
        struct node_literal          ;
    };
     
} Node;


