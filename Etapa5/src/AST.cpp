
#include "../include/AST.hpp"

Node* CreateGenericNode(NodeCategory category)
{
    Node* node = (Node *) malloc(sizeof(Node));

    node->nodeCategory = category;
    node->nodeType     = NODE_TYPE_INDEF;
    node->sequenceNode = NULL;
    node->code         = new std::list<IlocCode>;
    node->tl           = new std::list<std::string*>;
    node->fl           = new std::list<std::string*>;
    return(node);
}


Node* create_node_function_declaration (ValorLexico* identifier, Node* firstCommand)
{
    Node* newNode = CreateGenericNode(NODE_FUNCTION_DECLARATION);

    newNode->n_function_declaration.identifier = identifier;
    newNode->n_function_declaration.firstCommand = firstCommand;

    return newNode;
}

Node* create_node_var_access (ValorLexico* identifier, NodeType nodeType)
{
    Node* newNode = CreateGenericNode(NODE_VAR_ACCESS);
    newNode->nodeType = nodeType;

    newNode->n_var_access.identifier = identifier;

    return newNode;
}

Node* create_node_vector_access (Node* var, Node* index, NodeType nodeType)
{
    Node* newNode = CreateGenericNode(NODE_VECTOR_ACCESS);
    newNode->nodeType = nodeType;

    newNode->n_vector_access.var = var;
    newNode->n_vector_access.index = index;

    return newNode;
}

Node* create_node_var_attr (Node* identifier, Node* expression)
{
    Node* newNode = CreateGenericNode(NODE_VAR_ATTR);
    newNode->nodeType = identifier->nodeType;

    newNode->n_var_attr.identifier = identifier;
    newNode->n_var_attr.expression = expression;

    return newNode;
}

Node* create_node_var_init (Node* identifier, Node* expression)
{
    Node* newNode = CreateGenericNode(NODE_VAR_INIT);
    newNode->nodeType = identifier->nodeType;

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

Node* create_node_function_call (ValorLexico* identifier, Node* expressionList, NodeType nodeType)
{
    Node* newNode = CreateGenericNode(NODE_FUNCTION_CALL);
    newNode->nodeType = nodeType;

    newNode->n_function_call.identifier = identifier;
    newNode->n_function_call.expressionList = expressionList;

    return newNode;
}

Node* create_node_shift_left (Node* identifier, Node* shiftNumber)
{
    Node* newNode = CreateGenericNode(NODE_SHIFT_LEFT);
    newNode->n_shift_left.identifier = identifier;
    newNode->n_shift_left.shiftNumber = shiftNumber;

    return newNode;
}

Node* create_node_shift_right (Node* identifier, Node* shiftNumber)
{
    Node* newNode = CreateGenericNode(NODE_SHIFT_RIGHT);
    newNode->n_shift_right.identifier = identifier;
    newNode->n_shift_right.shiftNumber = shiftNumber;

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

Node* create_node_for_loop (Node* attr, Node* expression, Node* incOrDec, Node* firstCommand)
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

Node* create_node_unary_operation (ValorLexico* operation, Node* expression1, NodeType nodeType)
{
    Node* newNode = CreateGenericNode(NODE_UNARY_OPERATION);
    newNode->nodeType = nodeType;

    newNode->n_unary_operation.operation = operation;
    newNode->n_unary_operation.expression1 = expression1;

    return newNode;
}

Node* create_node_binary_operation (ValorLexico* operation, Node* expression1, Node* expression2, NodeType nodeType)
{
    Node* newNode = CreateGenericNode(NODE_BINARY_OPERATION);
    newNode->nodeType = nodeType;

    newNode->n_binary_operation.operation = operation;
    newNode->n_binary_operation.expression1 = expression1;
    newNode->n_binary_operation.expression2 = expression2;

    return newNode;
}

Node* create_node_ternary_operation (Node* expression1, Node* expression2, Node* expression3, NodeType nodeType)
{
    Node* newNode = CreateGenericNode(NODE_TERNARY_OPERATION);
    newNode->nodeType = nodeType;

    newNode->n_ternary_operation.expression1 = expression1;
    newNode->n_ternary_operation.expression2 = expression2;
    newNode->n_ternary_operation.expression3 = expression3;

    return newNode;
}

Node* create_node_literal (ValorLexico* literal, NodeType nodeType)
{
    Node* newNode = CreateGenericNode(NODE_LITERAL);
    newNode->nodeType = nodeType;

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
    if(node == NULL)
    {
        return;
    }

    if(node->sequenceNode != NULL)
    {
        FreeNode(node->sequenceNode);
    }

    switch (node->nodeCategory)
    {
    case NODE_FUNCTION_DECLARATION:
        FreeValorLexico(node->n_function_declaration.identifier);
        FreeNode(node->n_function_declaration.firstCommand);
        break;

    case NODE_VAR_ACCESS:
        FreeValorLexico(node->n_var_access.identifier);
        break;

    case NODE_VECTOR_ACCESS:
        FreeNode(node->n_vector_access.var);
        FreeNode(node->n_vector_access.index);
        break;
    
    case NODE_VAR_ATTR:
        FreeNode(node->n_var_attr.identifier);
        FreeNode(node->n_var_attr.expression);
        break;

    case NODE_VAR_INIT:
        FreeNode(node->n_var_init.identifier);
        FreeNode(node->n_var_init.expression);
        break;

    case NODE_INPUT:
        FreeNode(node->n_input.input);
        break;
    
    case NODE_OUTPUT:
        FreeNode(node->n_output.output);
        break;

    case NODE_FUNCTION_CALL:
        FreeValorLexico(node->n_function_call.identifier);
        FreeNode(node->n_function_call.expressionList);
        break;

    case NODE_SHIFT_LEFT:
        FreeNode(node->n_shift_left.identifier);
        FreeNode(node->n_shift_left.shiftNumber);
        break;

    case NODE_SHIFT_RIGHT:
        FreeNode(node->n_shift_right.identifier);
        FreeNode(node->n_shift_right.shiftNumber);
        break;

    case NODE_BREAK:
        break;
    
    case NODE_CONTINUE:
        break;

    case NODE_RETURN:
        FreeNode(node->n_return.toReturn);
        break;
    
    case NODE_IF:
        FreeNode(node->n_if.expression);
        FreeNode(node->n_if.ifTrue);
        FreeNode(node->n_if.ifFalse);
        break;
    
    case NODE_FOR_LOOP:
        FreeNode(node->n_for_loop.attr);
        FreeNode(node->n_for_loop.expression);
        FreeNode(node->n_for_loop.incOrDec);
        FreeNode(node->n_for_loop.firstCommand);
        break;

    case NODE_WHILE_LOOP:
        FreeNode(node->n_while_loop.expression);
        FreeNode(node->n_while_loop.firstCommand);
        break;
    
    case NODE_UNARY_OPERATION:
        FreeValorLexico(node->n_unary_operation.operation);
        FreeNode(node->n_unary_operation.expression1);
        break;
    
    case NODE_BINARY_OPERATION:
        FreeValorLexico(node->n_binary_operation.operation);
        FreeNode(node->n_binary_operation.expression1);
        FreeNode(node->n_binary_operation.expression2);
        break;
    
    case NODE_TERNARY_OPERATION:
        FreeNode(node->n_ternary_operation.expression1);
        FreeNode(node->n_ternary_operation.expression2);
        FreeNode(node->n_ternary_operation.expression3);
        break;
    
    case NODE_LITERAL:
        FreeValorLexico(node->n_literal.literal);
        break;

    default:
        printf("Erro ao desalocar memoria!!!");
    }

    free(node);
}

void PrintAll(Node* treeRoot)
{
    PrintNode(treeRoot, NULL);
    PrintLabel(treeRoot);
}

void PrintNode(Node* node, Node* parent)
{
    if(node == NULL)
    {
        return;
    }

    if(parent != NULL)
    {
        printf("%p, %p\n", parent, node);
    }

    switch (node->nodeCategory)
    {
    case NODE_FUNCTION_DECLARATION:
        PrintNode(node->n_function_declaration.firstCommand, node);
        break;

    case NODE_VAR_ACCESS:
        break;

    case NODE_VECTOR_ACCESS:
        PrintNode(node->n_vector_access.var, node);
        PrintNode(node->n_vector_access.index, node);
        break;
    
    case NODE_VAR_ATTR:
        PrintNode(node->n_var_attr.identifier, node);
        PrintNode(node->n_var_attr.expression, node);
        break;

    case NODE_VAR_INIT:
        PrintNode(node->n_var_init.identifier, node);
        PrintNode(node->n_var_init.expression, node);
        break;

    case NODE_INPUT:
        PrintNode(node->n_input.input, node);
        break;
    
    case NODE_OUTPUT:
        PrintNode(node->n_output.output, node);
        break;

    case NODE_FUNCTION_CALL:
        PrintNode(node->n_function_call.expressionList, node);
        break;

    case NODE_SHIFT_LEFT:
        PrintNode(node->n_shift_left.identifier, node);
        PrintNode(node->n_shift_left.shiftNumber, node);
        break;

    case NODE_SHIFT_RIGHT:
        PrintNode(node->n_shift_right.identifier, node);
        PrintNode(node->n_shift_right.shiftNumber, node);
        break;

    case NODE_BREAK:
        break;
    
    case NODE_CONTINUE:
        break;

    case NODE_RETURN:
        PrintNode(node->n_return.toReturn, node);
        break;
    
    case NODE_IF:
        PrintNode(node->n_if.expression, node);
        PrintNode(node->n_if.ifTrue, node);
        PrintNode(node->n_if.ifFalse, node);
        break;
    
    case NODE_FOR_LOOP:
        PrintNode(node->n_for_loop.attr, node);
        PrintNode(node->n_for_loop.expression, node);
        PrintNode(node->n_for_loop.incOrDec, node);
        PrintNode(node->n_for_loop.firstCommand, node);
        break;

    case NODE_WHILE_LOOP:
        PrintNode(node->n_while_loop.expression, node);
        PrintNode(node->n_while_loop.firstCommand, node);
        break;
    
    case NODE_UNARY_OPERATION:
        PrintNode(node->n_unary_operation.expression1, node);
        break;
    
    case NODE_BINARY_OPERATION:
        PrintNode(node->n_binary_operation.expression1, node);
        PrintNode(node->n_binary_operation.expression2, node);
        break;
    
    case NODE_TERNARY_OPERATION:
        PrintNode(node->n_ternary_operation.expression1, node);
        PrintNode(node->n_ternary_operation.expression2, node);
        PrintNode(node->n_ternary_operation.expression3, node);
        break;
    
    case NODE_LITERAL:
        break;

    default:
        printf("Erro ao printar!!!");
    }

    if(node->sequenceNode != NULL)
    {
        PrintNode(node->sequenceNode, node);
    }

}

void PrintLabel(Node* node)
{
    if(node == NULL)
    {
        return;
    }

    switch (node->nodeCategory)
    {
    case NODE_FUNCTION_DECLARATION:
        printf("%p [label=\"%s\"]\n", node, node->n_function_declaration.identifier->tokenValue.string);
        PrintLabel(node->n_function_declaration.firstCommand);
        break;

    case NODE_VAR_ACCESS:
        printf("%p [label=\"%s\"]\n", node, node->n_var_access.identifier->tokenValue.string);
        break;
    
    case NODE_VECTOR_ACCESS:
        printf("%p [label=\"[]\"]\n", node);
        PrintLabel(node->n_vector_access.var);
        PrintLabel(node->n_vector_access.index);
        break;
    
    case NODE_VAR_ATTR:
        printf("%p [label=\"=\"]\n", node);
        PrintLabel(node->n_var_attr.identifier);
        PrintLabel(node->n_var_attr.expression);
        break;

    case NODE_VAR_INIT:
        printf("%p [label=\"<=\"]\n", node);
        PrintLabel(node->n_var_init.identifier);
        PrintLabel(node->n_var_init.expression);
        break;

    case NODE_INPUT:
        printf("%p [label=\"input\"]\n", node);
        PrintLabel(node->n_input.input);
        break;
    
    case NODE_OUTPUT:
        printf("%p [label=\"output\"]\n", node);
        PrintLabel(node->n_output.output);
        break;

    case NODE_FUNCTION_CALL:
        printf("%p [label=\"call %s\"]\n", node, node->n_function_call.identifier->tokenValue.string);
        PrintLabel(node->n_function_call.expressionList);
        break;

    case NODE_SHIFT_LEFT:
        printf("%p [label=\"<<\"]\n", node);
        PrintLabel(node->n_shift_left.identifier);
        PrintLabel(node->n_shift_left.shiftNumber);
        break;

    case NODE_SHIFT_RIGHT:
        printf("%p [label=\">>\"]\n", node);
        PrintLabel(node->n_shift_right.identifier);
        PrintLabel(node->n_shift_right.shiftNumber);
        break;

    case NODE_BREAK:
        printf("%p [label=\"break\"]\n", node);
        break;
    
    case NODE_CONTINUE:
        printf("%p [label=\"continue\"]\n", node);
        break;

    case NODE_RETURN:
        printf("%p [label=\"return\"]\n", node);
        PrintLabel(node->n_return.toReturn);
        break;
    
    case NODE_IF:
        printf("%p [label=\"if\"]\n", node);
        PrintLabel(node->n_if.expression);
        PrintLabel(node->n_if.ifTrue);
        PrintLabel(node->n_if.ifFalse);
        break;
    
    case NODE_FOR_LOOP:
        printf("%p [label=\"for\"]\n", node);
        PrintLabel(node->n_for_loop.attr);
        PrintLabel(node->n_for_loop.expression);
        PrintLabel(node->n_for_loop.incOrDec);
        PrintLabel(node->n_for_loop.firstCommand);
        break;

    case NODE_WHILE_LOOP:
        printf("%p [label=\"while\"]\n", node);
        PrintLabel(node->n_while_loop.expression);
        PrintLabel(node->n_while_loop.firstCommand);
        break;
    
    case NODE_UNARY_OPERATION:
        if (node->n_unary_operation.operation->tokenType == TOKEN_TYPE_SPECIAL_CHAR)
            printf("%p [label=\"%c\"]\n", node, node->n_binary_operation.operation->tokenValue.character);
        PrintLabel(node->n_unary_operation.expression1);
        break;
    
    case NODE_BINARY_OPERATION:
        if (node->n_binary_operation.operation->tokenType == TOKEN_TYPE_SPECIAL_CHAR)
            printf("%p [label=\"%c\"]\n", node, node->n_binary_operation.operation->tokenValue.character);
        if (node->n_binary_operation.operation->tokenType == TOKEN_TYPE_COMPOSITE_OP)
            printf("%p [label=\"%s\"]\n", node, node->n_binary_operation.operation->tokenValue.string);

        PrintLabel(node->n_binary_operation.expression1);
        PrintLabel(node->n_binary_operation.expression2);
        break;
    
    case NODE_TERNARY_OPERATION:
        printf("%p [label=\"?:\"]\n", node);
        PrintLabel(node->n_ternary_operation.expression1);
        PrintLabel(node->n_ternary_operation.expression2);
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