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


Node* create_node_function_declaration (Node* firstCommand, ValorLexico* identifier)
{
    Node* newNode = CreateGenericNode(NODE_FUNCTION_DECLARATION);

    newNode->n_function_declaration.firstCommand = firstCommand;
    newNode->n_function_declaration.identifier = identifier;

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

Node* create_node_input (ValorLexico* input)
{
    Node* newNode = CreateGenericNode(NODE_INPUT);

    newNode->n_input.input = input;

    return newNode;
}

Node* create_node_output (ValorLexico* output)
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
    FreeNode(treeRoot);
}

void FreeNode(Node* node)
{
    if(node->sequenceNode != NULL)
    {
        FreeNode(node->sequenceNode);
    }

    switch (node->nodeType)
    {
    case NODE_FUNCTION_DECLARATION:
        if(node->n_function_declaration.firstCommand != NULL)
            FreeNode(node->n_function_declaration.firstCommand);
        if(node->n_function_declaration.identifier != NULL)
            FreeValorLexico(node->n_function_declaration.identifier);
        break;

    case NODE_VAR_ACCESS:
        if(node->n_var_access.index != NULL)
            FreeNode(node->n_var_access.index);
        if(node->n_var_access.identifier != NULL)
            FreeValorLexico(node->n_var_access.identifier);
        break;
    
    case NODE_VAR_ATTR:
        if(node->n_var_attr.expression != NULL)
            FreeNode(node->n_var_attr.expression);
        if(node->n_var_attr.identifier != NULL)
            FreeValorLexico(node->n_var_attr.identifier);
        if(node->n_var_attr.indexVector != NULL)
            FreeNode(node->n_var_attr.indexVector);
        break;

    case NODE_INPUT:
        if(node->n_input.input != NULL)
            FreeValorLexico(node->n_input.input);
        break;
    
    case NODE_OUTPUT:
        if(node->n_output.output != NULL)
            FreeValorLexico(node->n_output.output);
        break;

    case NODE_FUNCTION_CALL:
        if(node->n_function_call.expressionList != NULL)
            FreeNode(node->n_function_call.expressionList);
        break;

    case NODE_SHIFT_LEFT:
        if(node->n_shift_left.expression != NULL)
            FreeNode(node->n_shift_left.expression);
        if(node->n_shift_left.identifier != NULL)
            FreeValorLexico(node->n_shift_left.identifier);
        if(node->n_shift_left.indexVector != NULL)
            FreeNode(node->n_shift_left.indexVector);
        break;

    case NODE_SHIFT_RIGHT:
        if(node->n_shift_right.expression != NULL)
            FreeNode(node->n_shift_right.expression);
        if(node->n_shift_right.identifier != NULL)
            FreeValorLexico(node->n_shift_right.identifier);
        if(node->n_shift_right.indexVector != NULL)
            FreeNode(node->n_shift_right.indexVector);
        break;

    case NODE_BREAK:
        break;
    
    case NODE_CONTINUE:
        break;

    case NODE_RETURN:
        if(node->n_return.toReturn != NULL)
            FreeNode(node->n_return.toReturn);
        break;
    
    case NODE_IF:
        if(node->n_if.expression != NULL)
            FreeNode(node->n_if.expression);
        if(node->n_if.ifFalse != NULL)
            FreeNode(node->n_if.ifFalse);
        if(node->n_if.ifTrue != NULL)
            FreeNode(node->n_if.ifTrue);
        break;
    
    case NODE_FOR_LOOP:
        if(node->n_for_loop.attr != NULL)
            FreeNode(node->n_for_loop.attr);
        if(node->n_for_loop.expression != NULL);
            FreeNode(node->n_for_loop.expression);
        if(node->n_for_loop.firstCommand != NULL)
            FreeNode(node->n_for_loop.firstCommand);
        if(node->n_for_loop.incOrDec != NULL)
            FreeNode(node->n_for_loop.incOrDec);
        break;

    case NODE_WHILE_LOOP:
        if(node->n_while_loop.expression != NULL)
            FreeNode(node->n_while_loop.expression);
        if(node->n_while_loop.firstCommand != NULL)
            FreeNode(node->n_while_loop.firstCommand);
        break;
    
    case NODE_UNARY_OPERATION:
        if(node->n_unary_operation.expression1 != NULL)
            FreeNode(node->n_unary_operation.expression1);
        if(node->n_unary_operation.operation != NULL)
            FreeValorLexico(node->n_unary_operation.operation);
        break;
    
    case NODE_BINARY_OPERATION:
        if(node->n_binary_operation.expression1 != NULL)
            FreeNode(node->n_binary_operation.expression1);
        if(node->n_binary_operation.expression2 != NULL)
            FreeNode(node->n_binary_operation.expression2);
        if(node->n_binary_operation.operation != NULL)
            FreeValorLexico(node->n_binary_operation.operation);
        break;
    
    case NODE_TERNARY_OPERATION:
        if(node->n_ternary_operation.expression1 != NULL)
            FreeNode(node->n_ternary_operation.expression1);
        if(node->n_ternary_operation.expression2 != NULL)
            FreeNode(node->n_ternary_operation.expression2);
        if(node->n_ternary_operation.expression3 != NULL)
            FreeNode(node->n_ternary_operation.expression3);
        break;
    
    case NODE_LITERAL:
        if(node->n_literal.literal != NULL)
            FreeValorLexico(node->n_literal.literal);
        break;

    default:
        printf("Erro ao desalocar memoria!!!");
        //TODO: CRIAR UM DEFAULT
    }

    free(node);
}

void PrintAll(Node* treeRoot)
{

}

void PrintNode(Node* node)
{

}

void PrintLabel(Node* node)
{

}