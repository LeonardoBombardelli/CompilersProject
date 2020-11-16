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

std::string createLabelDirect()
{
    return std::string("L" + std::to_string(labelIndex++));
}

std::string createRegisterDirect()
{
    return std::string("r" + std::to_string(registerIndex++));
}

void PrintIlocCode(std::list<IlocCode> code)
{
    for (IlocCode inst : code)
    {
        std::string first  = (inst.firstArg != nullptr)  ? *(inst.firstArg)  : std::string();
        std::string second = (inst.secondArg != nullptr) ? *(inst.secondArg) : std::string();
        std::string third  = (inst.thirdArg != nullptr)  ? *(inst.thirdArg)  : std::string();

        if (inst.label != nullptr) std::cout << *(inst.label) << ": ";

        switch(inst.opcode)
        {
        case HALT:    std::cout << "halt"; break;
        case NOP:     break;
        case ADD:     std::cout << "add " << first << ", " << second << " => " << third; break;
        case SUB:     std::cout << "sub " << first << ", " << second << " => " << third; break;
        case MULT:    std::cout << "mult " << first << ", " << second << " => " << third; break;
        case DIV:     std::cout << "div " << first << ", " << second << " => " << third; break;
        case ADDI:    std::cout << "addI " << first << ", " << second << " => " << third; break;
        case LOADI:   std::cout << "loadI " << first << " => " << third; break;
        case LOADAI:  std::cout << "loadAI " << first << ", " << second << " => " << third; break;
        case STOREAI: std::cout << "storeAI " << third << " => " << first << ", " << second; break;
        case I2I:     std::cout << "i2i " << first << " => " << third; break;
        case JUMPI:   std::cout << "jumpI -> " << first; break;
        case JUMP:    std::cout << "jump -> " << first; break;
        case CBR:     std::cout << "cbr " << first << " -> " << second << ", " << third; break;
        case CMP_LT:  std::cout << "cmp_LT " << first << ", " << second << " -> " << third; break;
        case CMP_LE:  std::cout << "cmp_LE " << first << ", " << second << " -> " << third; break;
        case CMP_EQ:  std::cout << "cmp_EQ " << first << ", " << second << " -> " << third; break;
        case CMP_GE:  std::cout << "cmp_GE " << first << ", " << second << " -> " << third; break;
        case CMP_GT:  std::cout << "cmp_GT " << first << ", " << second << " -> " << third; break;
        case CMP_NE:  std::cout << "cmp_NE " << first << ", " << second << " -> " << third; break;
        default:      break;
        }
        
        std::cout << std::endl;

    }
}