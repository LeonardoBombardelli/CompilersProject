#ifndef AST_HPP
#define AST_HPP

#include "lexicalvalue.hpp"
#include "ILOC.hpp"
#include <cstdlib>
#include <list>
#include <iostream>
#include <cstring>

typedef enum 
{
    NODE_FUNCTION_DECLARATION    ,
    NODE_VAR_ACCESS              ,
    NODE_VECTOR_ACCESS           ,
    NODE_VAR_ATTR                ,
    NODE_VAR_INIT                ,
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
    NODE_UNARY_OPERATION         ,
    NODE_BINARY_OPERATION        ,
    NODE_TERNARY_OPERATION       ,
    NODE_LITERAL                 ,
    NODE_INDEF

} NodeCategory;

typedef enum
{
    NODE_TYPE_INT    ,
    NODE_TYPE_FLOAT  ,
    NODE_TYPE_CHAR   ,
    NODE_TYPE_BOOL   ,
    NODE_TYPE_STRING ,
    NODE_TYPE_INDEF  ,

} NodeType;

struct node_function_declaration {
    ValorLexico* identifier;
    struct node* firstCommand;
};

struct node_var_access {
    ValorLexico* identifier;
};

struct node_vector_access {
    struct node* var;
    struct node* index;
};

struct node_var_attr {
    struct node* identifier;
    struct node* expression;
};

struct node_var_init {
    struct node* identifier;
    struct node* expression;
};

struct node_input {
    struct node* input;
};

struct node_output {
    struct node* output;
};

struct node_function_call {
    ValorLexico* identifier;
    struct node* expressionList;
};

struct node_shift_left {
    struct node* identifier;
    struct node* shiftNumber;
};

struct node_shift_right {
    struct node* identifier; 
    struct node* shiftNumber;
};

struct node_break {

};

struct node_continue {

};

struct node_return {
    struct node* toReturn;
};

struct node_if {
    struct node* expression;
    struct node* ifTrue;
    struct node* ifFalse;
};

struct node_for_loop {
    struct node* attr;
    struct node* expression;
    struct node* incOrDec;
    struct node* firstCommand;    
};

struct node_while_loop {
    struct node* expression;
    struct node* firstCommand;
};

struct node_unary_operation {
    ValorLexico* operation;
    struct node* expression1;
};

struct node_binary_operation {
    ValorLexico* operation;
    struct node* expression1;
    struct node* expression2;
};

struct node_ternary_operation {
    struct node* expression1;
    struct node* expression2;
    struct node* expression3;
};

struct node_literal {
    ValorLexico* literal;
};

typedef struct node {
    NodeCategory nodeCategory;
    NodeType     nodeType;
    struct node* sequenceNode;

    std::string local;
    std::list<IlocCode> *code;
    std::list<std::string*> *tl;
    std::list<std::string*> *fl;

    union 
    {
        struct node_function_declaration    n_function_declaration    ;
        struct node_var_access              n_var_access              ;
        struct node_vector_access           n_vector_access           ;
        struct node_var_attr                n_var_attr                ;
        struct node_var_init                n_var_init                ;
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
        struct node_unary_operation         n_unary_operation         ;
        struct node_binary_operation        n_binary_operation        ;
        struct node_ternary_operation       n_ternary_operation       ;
        struct node_literal                 n_literal                 ;
    };
     
} Node;

Node* CreateGenericNode(NodeCategory category);

Node* create_node_function_declaration (ValorLexico* identifier, Node* firstCommand);
Node* create_node_var_access           (ValorLexico* identifier, NodeType nodeType);
Node* create_node_vector_access        (Node* var, Node* index, NodeType nodeType);
Node* create_node_var_attr             (Node* identifier, Node* expression);
Node* create_node_var_init             (Node* identifier, Node* expression);
Node* create_node_input                (Node* input);
Node* create_node_output               (Node* output);
Node* create_node_function_call        (ValorLexico* identifier, Node* expressionList, NodeType nodeType);
Node* create_node_shift_left           (Node* identifier, Node* shiftNumber);
Node* create_node_shift_right          (Node* identifier, Node* shiftNumber);
Node* create_node_break                ();
Node* create_node_continue             ();
Node* create_node_return               (Node* toReturn);
Node* create_node_if                   (Node* expression, Node* ifTrue, Node* ifFalse);
Node* create_node_for_loop             (Node* attr, Node* expression, Node* incOrDec, Node* firstCommand);
Node* create_node_while_loop           (Node* expression, Node* firstCommand);
Node* create_node_unary_operation      (ValorLexico* operation, Node* expression1, NodeType nodeType);
Node* create_node_binary_operation     (ValorLexico* operation, Node* expression1, Node* expression2, NodeType nodeType);
Node* create_node_ternary_operation    (Node* expression1, Node* expression2, Node* expression3, NodeType nodeType);
Node* create_node_literal              (ValorLexico* literal, NodeType nodeType);

/* Free operations */

void FreeValorLexico(ValorLexico* val);
void FreeTree(Node* treeRoot);
void FreeNode(Node* node);

/* Print operations */

void PrintAll(Node* treeRoot);
void PrintNode(Node* node, Node* parent);
void PrintLabel(Node* node);

#endif