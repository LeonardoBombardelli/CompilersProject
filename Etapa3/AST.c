#include "definitions.h"
#include "AST.h"

/* Schnorrrrrrr nos deixa usar Cpp pfvr a gente poderia resolver isso com classes de forma mais elegante :c */

Node* CreateGenericNode(NodeType type)
{
    Node* node = (Node *) malloc(sizeof(Node));

    node->nodeType = type;
    node->sequenceNode = NULL;
    return(node);
}


Node* create_node_function_declaration (Node* firstCommand, Node* nextFunction)
{
    Node* newNode = CreateGenericNode(NODE_FUNCTION_DECLARATION);

    newNode->n_function_declaration.firstCommand = firstCommand;
    newNode->n_function_declaration.nextFunction = nextFunction;

    return newNode;
}

Node* create_node_var_access (ValorLexico* identifier, Node* index)
{
    Node* newNode = CreateGenericNode(NODE_VAR_ACCESS);

    newNode->n_var_access.identifier = identifier;
    newNode->n_var_access.index = index;

    return newNode;
}

Node* create_node_var_attr (ValorLexico* identifier, Node* indexVector, Node* expression)
{
    Node* newNode = CreateGenericNode(NODE_VAR_ATTR);

    newNode->n_var_attr.identifier = identifier;
    newNode->n_var_attr.indexVector = indexVector;
    newNode->n_var_attr.expression = expression;

    return newNode;
}

Node* create_node_input (Node* input)
{
    Node* newNode = CreateGenericNode(NODE_INPUT);

    newNode->n_input.input = input;

    return newNode;
}

Node* create_node_output (Node* output)
{
    Node* newNode = CreateGenericNode(NODE_OUTPUT);

    newNode->n_output.output = output;

    return newNode;
}

Node* create_node_function_call (Node* expressionList)
{
    Node* newNode = CreateGenericNode(NODE_FUNCTION_CALL);

    newNode->n_function_call.expressionList = expressionList;

    return newNode;
}

Node* create_node_shift_left (ValorLexico* identifier, Node* indexVector, Node* expression)
{
    Node* newNode = CreateGenericNode(NODE_SHIFT_LEFT);newNode->n_shift_right;
    newNode->n_shift_right.expression = expression;

    return newNode;
}

Node* create_node_break ()
{
    Node* newNode = CreateGenericNode(NODE_BREAK);

    return newNode;
}

Node* create_node_continue ()
{
    Node* newNode = CreateGenericNode(NODE_CONTINUE);

    return newNode;
}

Node* create_node_return (Node* toReturn)
{
    Node* newNode = CreateGenericNode(NODE_RETURN);

    newNode->n_return.toReturn = toReturn;

    return newNode;
}

Node* create_node_if (Node* expression, Node* ifTrue, Node* ifFalse)
{
    Node* newNode = CreateGenericNode(NODE_IF);

    newNode->n_if.expression = expression;
    newNode->n_if.ifTrue = ifTrue;
    newNode->n_if.ifFalse = ifFalse;

    return newNode;
}

Node* create_node_for_loop (Node* attr, Node* expression,Node* incOrDec, Node* firstCommand)
{
    Node* newNode = CreateGenericNode(NODE_FOR_LOOP);

    newNode->n_for_loop.attr = attr;
    newNode->n_for_loop.expression = expression;
    newNode->n_for_loop.incOrDec = incOrDec;
    newNode->n_for_loop.firstCommand = firstCommand;

    return newNode;
}

Node* create_node_while_loop (Node* expression, Node* firstCommand)
{
    Node* newNode = CreateGenericNode(NODE_WHILE_LOOP);

    newNode->n_while_loop.expression = expression;
    newNode->n_while_loop.firstCommand = firstCommand;

    return newNode;
}

Node* create_node_vector_index (ValorLexico* identifier, Node* index)
{
    Node* newNode = CreateGenericNode(NODE_VECTOR_INDEX);

    newNode->n_vector_index.identifier = identifier;
    newNode->n_vector_index.index = index;

    return newNode;
}

Node* create_node_unary_operation (ValorLexico* operation, Node* expression1)
{
    Node* newNode = CreateGenericNode(NODE_UNARY_OPERATION);

    newNode->n_unary_operation.operation = operation;
    newNode->n_unary_operation.expression1 = expression1;

    return newNode;
}

Node* create_node_binary_operation (ValorLexico* operation, Node* expression1, Node* expression2)
{
    Node* newNode = CreateGenericNode(NODE_BINARY_OPERATION);

    newNode->n_binary_operation.operation = operation;
    newNode->n_binary_operation.expression1 = expression1;
    newNode->n_binary_operation.expression2 = expression2;

    return newNode;
}

Node* create_node_ternary_operation (Node* expression1, Node* expression2, Node* expression3)
{
    Node* newNode = CreateGenericNode(NODE_TERNARY_OPERATION);

    newNode->n_ternary_operation.expression1 = expression1;
    newNode->n_ternary_operation.expression2 = expression2;
    newNode->n_ternary_operation.expression3 = expression3;

    return newNode;
}

Node* create_node_literal (ValorLexico* literal)
{
    Node* newNode = CreateGenericNode(NODE_LITERAL);

    newNode->n_literal.literal = literal;

    return newNode;
}

/* Free operations */

void FreeValorLexico(ValorLexico* val)
{
    if(val->tokenType == TOKEN_TYPE_COMPOSITE_OP || val->tokenType == TOKEN_TYPE_IDENTIFIER)
    {
        free(val->tokenValue.string);
    }

    if(val->tokenType == TOKEN_TYPE_LITERAL)
    {
        if(val->literalType == LITERAL_TYPE_STRING)
        {
            free(val->tokenValue.string);
        }
    }

    free(val);
}

void FreeTree(Node* treeRoot)
{
    
}
