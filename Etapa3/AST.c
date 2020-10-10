
#include "AST.h"

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

Node* create_node_var_access (ValorLexico* identifier)
{
    Node* newNode = CreateGenericNode(NODE_VAR_ACCESS);

    newNode->n_var_access.identifier = identifier;

    return newNode;
}

Node* create_node_vector_access (Node* var, Node* index)
{
    Node* newNode = CreateGenericNode(NODE_VECTOR_ACCESS);

    newNode->n_vector_access.var = var;
    newNode->n_vector_access.index = index;

    return newNode;
}

Node* create_node_var_attr (Node* identifier, Node* expression)
{
    Node* newNode = CreateGenericNode(NODE_VAR_ATTR);

    newNode->n_var_attr.identifier = identifier;
    newNode->n_var_attr.expression = expression;

    return newNode;
}

Node* create_node_var_init (Node* identifier, Node* expression)
{
    Node* newNode = CreateGenericNode(NODE_VAR_INIT);

    newNode->n_var_init.identifier = identifier;
    newNode->n_var_init.expression = expression;

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

Node* create_node_function_call (ValorLexico* identifier, Node* expressionList)
{
    Node* newNode = CreateGenericNode(NODE_FUNCTION_CALL);

    newNode->n_function_call.identifier = identifier;
    newNode->n_function_call.expressionList = expressionList;

    return newNode;
}

Node* create_node_shift_left (Node* identifier, Node* expression)
{
    Node* newNode = CreateGenericNode(NODE_SHIFT_LEFT);
    newNode->n_shift_left.identifier = identifier;
    newNode->n_shift_left.expression = expression;

    return newNode;
}

Node* create_node_shift_right (Node* identifier, Node* expression)
{
    Node* newNode = CreateGenericNode(NODE_SHIFT_RIGHT);
    newNode->n_shift_right.identifier = identifier;
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
        if(node->n_var_access.identifier != NULL)
            FreeValorLexico(node->n_var_access.identifier);
        break;

    case NODE_VECTOR_ACCESS:
        if(node->n_vector_access.var != NULL)
            FreeNode(node->n_vector_access.var);
        if(node->n_vector_access.index != NULL)
            FreeNode(node->n_vector_access.index);
        break;
    
    case NODE_VAR_ATTR:
        if(node->n_var_attr.expression != NULL)
            FreeNode(node->n_var_attr.expression);
        if(node->n_var_attr.identifier != NULL)
            FreeNode(node->n_var_attr.identifier);
        break;

    case NODE_VAR_INIT:
        if(node->n_var_init.expression != NULL)
            FreeNode(node->n_var_init.expression);
        if(node->n_var_init.identifier != NULL)
            FreeNode(node->n_var_init.identifier);
        break;

    case NODE_INPUT:
        if(node->n_input.input != NULL)
            FreeNode(node->n_input.input);
        break;
    
    case NODE_OUTPUT:
        if(node->n_output.output != NULL)
            FreeNode(node->n_output.output);
        break;

    case NODE_FUNCTION_CALL:
        if(node->n_function_call.expressionList != NULL)
            FreeNode(node->n_function_call.expressionList);
        if(node->n_function_call.identifier != NULL)
            FreeValorLexico(node->n_function_call.identifier);
        break;

    case NODE_SHIFT_LEFT:
        if(node->n_shift_left.expression != NULL)
            FreeNode(node->n_shift_left.expression);
        if(node->n_shift_left.identifier != NULL)
            FreeNode(node->n_shift_left.identifier);
        break;

    case NODE_SHIFT_RIGHT:
        if(node->n_shift_right.expression != NULL)
            FreeNode(node->n_shift_right.expression);
        if(node->n_shift_right.identifier != NULL)
            FreeNode(node->n_shift_right.identifier);
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
        if(node->n_for_loop.expression != NULL)
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
    }

    free(node);
}

void PrintAll(Node* treeRoot)
{
    PrintNode(treeRoot);
    PrintLabel(treeRoot);
}

void PrintNode(Node* node)
{
    if(node == NULL)
    {
        return;
    }

    if(node->sequenceNode != NULL)
    {
        printf("%p, %p\n", node, node->sequenceNode);
        PrintNode(node->sequenceNode);
    }

    switch (node->nodeType)
    {
    case NODE_FUNCTION_DECLARATION:
        if(node->n_function_declaration.firstCommand != NULL)
        {
            printf("%p, %p\n", node, node->n_function_declaration.firstCommand);
            PrintNode(node->n_function_declaration.firstCommand);
        }
        break;

    case NODE_VAR_ACCESS:
        break;

    case NODE_VECTOR_ACCESS:
        if(node->n_vector_access.index != NULL)
        {
            printf("%p, %p\n", node, node->n_vector_access.index);
            PrintNode(node->n_vector_access.index);
        }
        if(node->n_vector_access.var != NULL)
        {
            printf("%p, %p\n", node, node->n_vector_access.var);
            PrintNode(node->n_vector_access.var);
        }
        break;
    
    case NODE_VAR_ATTR:
        if(node->n_var_attr.expression != NULL)
        {
            printf("%p, %p\n", node, node->n_var_attr.expression);
            PrintNode(node->n_var_attr.expression);
        }
        if(node->n_var_attr.identifier != NULL)
        {
            printf("%p, %p\n", node, node->n_var_attr.identifier);
            PrintNode(node->n_var_attr.identifier);
        }
        break;

    case NODE_VAR_INIT:
        if(node->n_var_init.expression != NULL)
        {
            printf("%p, %p\n", node, node->n_var_init.expression);
            PrintNode(node->n_var_init.expression);
        }
        if(node->n_var_init.identifier != NULL)
        {
            printf("%p, %p\n", node, node->n_var_init.identifier);
            PrintNode(node->n_var_init.identifier);
        }
        break;

    case NODE_INPUT:
        if(node->n_input.input != NULL)
        {
            printf("%p, %p\n", node, node->n_input.input);
            PrintNode(node->n_input.input);
        }
        break;
    
    case NODE_OUTPUT:
        if(node->n_output.output != NULL)
        {
            printf("%p, %p\n", node, node->n_output.output);
            PrintNode(node->n_output.output);
        }
        break;

    case NODE_FUNCTION_CALL:
        if(node->n_function_call.expressionList != NULL)
        {
            printf("%p, %p\n", node, node->n_function_call.expressionList);
            PrintNode(node->n_function_call.expressionList);
        }
        break;

    case NODE_SHIFT_LEFT:
        if(node->n_shift_left.expression != NULL)
        {
            printf("%p, %p\n", node, node->n_shift_left.expression);
            PrintNode(node->n_shift_left.expression);
        }
        if(node->n_shift_left.identifier != NULL)
        {
            printf("%p, %p\n", node, node->n_shift_left.identifier);
            PrintNode(node->n_shift_left.identifier);
        }
        break;

    case NODE_SHIFT_RIGHT:
        if(node->n_shift_right.expression != NULL)
        {
            printf("%p, %p\n", node, node->n_shift_right.expression);
            PrintNode(node->n_shift_right.expression);
        }
        if(node->n_shift_right.identifier != NULL)
        {
            printf("%p, %p\n", node, node->n_shift_right.identifier);
            PrintNode(node->n_shift_right.identifier);
        }
        break;

    case NODE_BREAK:
        break;
    
    case NODE_CONTINUE:
        break;

    case NODE_RETURN:
        if(node->n_return.toReturn != NULL)
        {
            printf("%p, %p\n", node, node->n_return.toReturn);
            PrintNode(node->n_return.toReturn);
        }
        break;
    
    case NODE_IF:
        if(node->n_if.expression != NULL)
        {
            printf("%p, %p\n", node, node->n_if.expression);
            PrintNode(node->n_if.expression);
        }
        if(node->n_if.ifFalse != NULL)
        {
            printf("%p, %p\n", node, node->n_if.ifFalse);
            PrintNode(node->n_if.ifFalse);
        }
        if(node->n_if.ifTrue != NULL)
        {
            printf("%p, %p\n", node, node->n_if.ifTrue);
            PrintNode(node->n_if.ifTrue);
        }
        break;
    
    case NODE_FOR_LOOP:
        if(node->n_for_loop.attr != NULL)
        {
            printf("%p, %p\n", node, node->n_for_loop.attr);
            PrintNode(node->n_for_loop.attr);
        }
        if(node->n_for_loop.expression != NULL)
        {
            printf("%p, %p\n", node, node->n_for_loop.expression);
            PrintNode(node->n_for_loop.expression);
        }
        if(node->n_for_loop.incOrDec != NULL)
        {
            printf("%p, %p\n", node, node->n_for_loop.incOrDec);
            PrintNode(node->n_for_loop.incOrDec);
        }
        if(node->n_for_loop.firstCommand != NULL)
        {
            printf("%p, %p\n", node, node->n_for_loop.firstCommand);
            PrintNode(node->n_for_loop.firstCommand);
        }
        break;

    case NODE_WHILE_LOOP:
        if(node->n_while_loop.expression != NULL)
        {
            printf("%p, %p\n", node, node->n_while_loop.expression);
            PrintNode(node->n_while_loop.expression);
        }
        if(node->n_while_loop.firstCommand != NULL)
        {
            printf("%p, %p\n", node, node->n_while_loop.firstCommand);
            PrintNode(node->n_while_loop.firstCommand);
        }
        break;
    
    case NODE_UNARY_OPERATION:
        if(node->n_unary_operation.expression1 != NULL)
        {
            printf("%p, %p\n", node, node->n_unary_operation.expression1);
            PrintNode(node->n_unary_operation.expression1);
        }
        break;
    
    case NODE_BINARY_OPERATION:
        if(node->n_binary_operation.expression1 != NULL)
        {
            printf("%p, %p\n", node, node->n_binary_operation.expression1);
            PrintNode(node->n_binary_operation.expression1);
        }
        if(node->n_binary_operation.expression2 != NULL)
        {
            printf("%p, %p\n", node, node->n_binary_operation.expression2);
            PrintNode(node->n_binary_operation.expression2);
        }
        break;
    
    case NODE_TERNARY_OPERATION:
        if(node->n_ternary_operation.expression1 != NULL)
        {
            printf("%p, %p\n", node, node->n_ternary_operation.expression1);
            PrintNode(node->n_ternary_operation.expression1);
        }
        if(node->n_ternary_operation.expression2 != NULL)
        {
            printf("%p, %p\n", node, node->n_ternary_operation.expression2);
            PrintNode(node->n_ternary_operation.expression2);
        }
        if(node->n_ternary_operation.expression3 != NULL)
        {
            printf("%p, %p\n", node, node->n_ternary_operation.expression3);
            PrintNode(node->n_ternary_operation.expression3);
        }
        break;
    
    case NODE_LITERAL:
        break;

    default:
        printf("Erro ao printar!!!");
        //TODO: CRIAR UM DEFAULT
    }
}

void PrintLabel(Node* node)
{
    switch (node->nodeType)
    {
    case NODE_FUNCTION_DECLARATION:
        printf("%p [label=\"%s\"]\n", node, node->n_function_declaration.identifier->tokenValue.string);
       
        if(node->n_function_declaration.firstCommand != NULL)
            PrintLabel(node->n_function_declaration.firstCommand);
        break;

    case NODE_VAR_ACCESS:
        printf("%p [label=\"%s\"]\n", node, node->n_var_access.identifier->tokenValue.string);
       
        break;
    
    case NODE_VECTOR_ACCESS:
        printf("%p [label=\"[]\"]\n", node);

        if(node->n_vector_access.var != NULL)
            PrintLabel(node->n_vector_access.var);

        if(node->n_vector_access.index != NULL)
            PrintLabel(node->n_vector_access.index);

        break;
    
    case NODE_VAR_ATTR:
        printf("%p [label=\"=\"]\n", node);
       
        if(node->n_var_attr.identifier != NULL)
            PrintLabel(node->n_var_attr.identifier);

        if(node->n_var_attr.expression != NULL)
            PrintLabel(node->n_var_attr.expression);
        
        break;

    case NODE_VAR_INIT:
        printf("%p [label=\"<=\"]\n", node);
       
        if(node->n_var_init.identifier != NULL)
            PrintLabel(node->n_var_init.identifier);

        if(node->n_var_init.expression != NULL)
            PrintLabel(node->n_var_init.expression);
        
        break;

    case NODE_INPUT:
        printf("%p [label=\"input\"]\n", node);

        if(node->n_input.input != NULL)
            PrintLabel(node->n_input.input);
        break;
    
    case NODE_OUTPUT:
        printf("%p [label=\"output\"]\n", node);

        if(node->n_output.output != NULL)
            PrintLabel(node->n_output.output);
        break;

    case NODE_FUNCTION_CALL:
        printf("%p [label=\"call %s\"]\n", node, node->n_function_call.identifier->tokenValue.string);

        if(node->n_function_call.expressionList != NULL)
            PrintLabel(node->n_function_call.expressionList);
        break;

    case NODE_SHIFT_LEFT:
        printf("%p [label=\"<<\"]\n", node);

        if(node->n_shift_left.expression != NULL)
            PrintLabel(node->n_shift_left.expression);

        if(node->n_shift_left.identifier != NULL)
            PrintLabel(node->n_shift_left.identifier);
        break;

    case NODE_SHIFT_RIGHT:
        printf("%p [label=\">>\"]\n", node);

        if(node->n_shift_right.expression != NULL)
            PrintLabel(node->n_shift_right.expression);

        if(node->n_shift_right.identifier != NULL)
            PrintLabel(node->n_shift_right.identifier);
        break;

    case NODE_BREAK:
        printf("%p [label=\"break\"]\n", node);
        break;
    
    case NODE_CONTINUE:
        printf("%p [label=\"continue\"]\n", node);
        break;

    case NODE_RETURN:
        printf("%p [label=\"return\"]\n", node);

        if(node->n_return.toReturn != NULL)
            PrintLabel(node->n_return.toReturn);
        break;
    
    case NODE_IF:
        printf("%p [label=\"if\"]\n", node);

        if(node->n_if.expression != NULL)
            PrintLabel(node->n_if.expression);
 
        if(node->n_if.ifFalse != NULL)
            PrintLabel(node->n_if.ifFalse);
 
        if(node->n_if.ifTrue != NULL)
            PrintLabel(node->n_if.ifTrue);
 
        break;
    
    case NODE_FOR_LOOP:
        printf("%p [label=\"for\"]\n", node);

        if(node->n_for_loop.attr != NULL)
            PrintLabel(node->n_for_loop.attr);

        if(node->n_for_loop.expression != NULL)
            PrintLabel(node->n_for_loop.expression);

        if(node->n_for_loop.firstCommand != NULL)
            PrintLabel(node->n_for_loop.firstCommand);

        if(node->n_for_loop.incOrDec != NULL)
            PrintLabel(node->n_for_loop.incOrDec);

        break;

    case NODE_WHILE_LOOP:
        printf("%p [label=\"while\"]\n", node);

        if(node->n_while_loop.expression != NULL)
            PrintLabel(node->n_while_loop.expression);

        if(node->n_while_loop.firstCommand != NULL)
            PrintLabel(node->n_while_loop.firstCommand);

        break;
    
    case NODE_UNARY_OPERATION:
        if (node->n_unary_operation.operation->tokenType == TOKEN_TYPE_SPECIAL_CHAR)
            printf("%p [label=\"%c\"]\n", node, node->n_binary_operation.operation->tokenValue.character);

        if(node->n_unary_operation.expression1 != NULL)
            PrintLabel(node->n_unary_operation.expression1);

        break;
    
    case NODE_BINARY_OPERATION:
        if (node->n_binary_operation.operation->tokenType == TOKEN_TYPE_SPECIAL_CHAR)
            printf("%p [label=\"%c\"]\n", node, node->n_binary_operation.operation->tokenValue.character);
        if (node->n_binary_operation.operation->tokenType == TOKEN_TYPE_COMPOSITE_OP)
            printf("%p [label=\"%s\"]\n", node, node->n_binary_operation.operation->tokenValue.string);

        if(node->n_binary_operation.expression1 != NULL)
            PrintLabel(node->n_binary_operation.expression1);

        if(node->n_binary_operation.expression2 != NULL)
            PrintLabel(node->n_binary_operation.expression2);

        break;
    
    case NODE_TERNARY_OPERATION:
        printf("%p [label=\"?:\"]\n", node);

        if(node->n_ternary_operation.expression1 != NULL)
            PrintLabel(node->n_ternary_operation.expression1);

        if(node->n_ternary_operation.expression2 != NULL)
            PrintLabel(node->n_ternary_operation.expression2);

        if(node->n_ternary_operation.expression3 != NULL)
            PrintLabel(node->n_ternary_operation.expression3);

        break;
    
    case NODE_LITERAL:
        switch (node->n_literal.literal->literalType)
        {
        case LITERAL_TYPE_INTEGER:
            printf("%p [label=\"%d\"]\n", node, node->n_literal.literal->tokenValue.integer);
            break;

        case LITERAL_TYPE_STRING:
            printf("%p [label=\"%s\"]\n", node, node->n_literal.literal->tokenValue.string);
            break;
        
        case LITERAL_TYPE_BOOL:
            if(node->n_literal.literal->tokenValue.integer)
                printf("%p [label=\"true\"]\n", node);
            else
                printf("%p [label=\"false\"]\n", node);
            break;
        
        case LITERAL_TYPE_FLOAT:
            printf("%p [label=\"%f\"]\n", node, node->n_literal.literal->tokenValue.floating);
            break;
        
        case LITERAL_TYPE_CHAR:
            printf("%p [label=\"%c\"]\n", node, node->n_literal.literal->tokenValue.character);
            break;

        case NOT_LITERAL_TYPE:
            break;
        
        }
        break;

    default:
        printf("Erro ao printar!!!");
    }

    if(node->sequenceNode != NULL)
    {
        PrintLabel(node->sequenceNode);
    }
}