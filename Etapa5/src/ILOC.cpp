#include "../include/ILOC.hpp"

int labelIndex;
int registerIndex;

std::string* createLabel()
{
    std::string *label = new std::string;
    *label = std::string("L" + std::to_string(labelIndex++));
    return label;
}

std::string* createRegister()
{
    std::string *reg = new std::string;
    *reg = std::string("r" + std::to_string(registerIndex++));
    return reg;
}

std::string opcodeToString(Operations opcode)
{
    switch(opcode)
    {
    case NOP:     return std::string("NOP");
    case ADD:     return std::string("ADD");
    case SUB:     return std::string("SUB");
    case MULT:    return std::string("MULT");
    case DIV:     return std::string("DIV");
    case ADDI:    return std::string("ADDI");
    case SUBI:    return std::string("SUBI");
    case RSUBI:   return std::string("RSUBI");
    case MULTI:   return std::string("MULTI");
    case DIVI:    return std::string("DIVI");
    case RDIVI:   return std::string("RDIVI");
    case AND:     return std::string("AND");
    case ANDI:    return std::string("ANDI");
    case OR:      return std::string("OR");
    case ORI:     return std::string("ORI");
    case LOADI:   return std::string("LOADI");
    case LOAD:    return std::string("LOAD");
    case LOADAI:  return std::string("LOADAI");
    case STORE:   return std::string("STORE");
    case STOREAI: return std::string("STOREAI");
    case I2I:     return std::string("I2I");
    case JUMPI:   return std::string("JUMPI");
    case JUMP:    return std::string("JUMP");
    case CBR:     return std::string("CBR");
    case CMP_LT:  return std::string("CMP_LT");
    case CMP_LE:  return std::string("CMP_LE");
    case CMP_EQ:  return std::string("CMP_EQ");
    case CMP_GE:  return std::string("CMP_GE");
    case CMP_GT:  return std::string("CMP_GT");
    case CMP_NE:  return std::string("CMP_NE");
    default:      return std::string("(no op)");
    }
}

void PrintIlocCode(std::list<IlocCode> code)
{
    for (IlocCode instruction : code)
    {
        if (instruction.label != nullptr) std::cout << *(instruction.label) << ": ";
        std::cout << opcodeToString(instruction.opcode) << " ";
        if (instruction.firstArg  != NULL) std::cout << *(instruction.firstArg)  << " "; else std::cout << "NULL ";
        if (instruction.secondArg != NULL) std::cout << *(instruction.secondArg) << " "; else std::cout << "NULL ";
        if (instruction.thirdArg  != NULL) std::cout << *(instruction.thirdArg)  << "\n"; else std::cout << "NULL\n";
        // TODO: some instructions have -> or => so we'll need to check each case
    }
}