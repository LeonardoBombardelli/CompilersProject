#include "../include/Asm.hpp"

// REMEMBER: STACK IS TOP-DOWN!!!

void generateAsm(std::list<IlocCode> ilocList)
{
    std::list<AsmCode> asmList = std::list<AsmCode>();
    std::string nullstr = std::string();

    // ignore ILOC code prologue (register init and main() call)
    for (int i = 0; i < 9; i++) ilocList.pop_front();

    asmList.push_back(AsmCode(std::string(".file"), nullstr, nullstr)); // define empty filename
    asmList.push_back(AsmCode(std::string(".text"), nullstr, nullstr));

    // for every global var, insert init code
    for (std::pair<std::string, SymbolTableEntry*> item : *scopeStack->back()->symbolTable)
    {
        if (item.second->entryNature == TABLE_NATURE_VAR)
        {
            asmList.push_back(AsmCode(std::string(".globl"), item.first, nullstr));
            asmList.push_back(AsmCode(std::string(".data"), nullstr, nullstr));
            asmList.push_back(AsmCode(std::string(".align"), std::string("4"), nullstr));
            asmList.push_back(AsmCode(std::string(".type"), item.first, std::string("@object")));
            asmList.push_back(AsmCode(std::string(".size"), item.first, std::string("4")));
            asmList.push_back(AsmCode(item.first, nullstr, nullstr, nullstr));
            asmList.push_back(AsmCode(std::string(".long"), std::string("0"), nullstr));
        }
    }

    asmList.push_back(AsmCode(std::string(".text"), nullstr, nullstr));

    while (!ilocList.empty())
    {
        std::string label = *ilocList.front().label;
        ilocList.pop_front();
        std::string funcName = findFuncByLabel(label);

        asmList.push_back(AsmCode(std::string(".globl"), funcName, nullstr));
        asmList.push_back(AsmCode(std::string(".type"), funcName, std::string("@object")));
        asmList.push_back(AsmCode(funcName, nullstr, nullstr, nullstr));    // func label
        asmList.push_back(AsmCode("pushq", "%rsp", nullstr));               // save old rsp
        asmList.push_back(AsmCode("pushq", "%rbp", nullstr));               // save old rbp
        asmList.push_back(AsmCode("movq", "%rsp", "%rbp"));                 // new rbp = old rsp

        do {
            IlocCode inst = ilocList.front();
            std::string instLabel  = *(inst.label);
            std::string instFstArg = *(inst.firstArg);
            std::string instSecArg = *(inst.secondArg);
            std::string instTrdArg = *(inst.thirdArg);

            switch(inst.opcode)
            {
            // case HALT:    break;
            case NOP:
                asmList.push_back(AsmCode(instLabel, "nop", nullstr, nullstr));
                break;
            case ADD:     break;
            case SUB:     break;
            case MULT:    break;
            case DIV:     break;
            case ADDI:
                
                if (instFstArg == std::string("rpc"))
                {
                    
                }

                break;
            case LOADI:   break;
            case LOADAI:  break;
            case STOREAI: break;
            case I2I:     break;
            case JUMPI:   break;
            case JUMP:    break;
            case CBR:     break;
            case CMP_LT:  break;
            case CMP_LE:  break;
            case CMP_EQ:  break;
            case CMP_GE:  break;
            case CMP_GT:  break;
            case CMP_NE:  break;
            default:      break;
            }

        } while (/**/true);

    }



}

std::string findFuncByLabel(std::string label)
{
    for (std::pair<std::string, std::string*> item : *auxFuncLabelMap)
    {
        if (*item.second == label) return item.first;
    }

    return std::string();
}