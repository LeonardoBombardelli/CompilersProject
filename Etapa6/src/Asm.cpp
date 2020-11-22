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
            // the only halt inst is in the (ignored) prologue of the ILOC code 
            // case HALT:    break;
            
            case NOP:
                asmList.push_back(AsmCode(instLabel, "nop", nullstr, nullstr));
                break;


            // Arithmetic instructions "inst r1, r2 => r1" translated to "inst r2, r1" because 
            // the result is saved in the second argument
            case ADD:
                asmList.push_back(AsmCode("addl", instSecArg, instTrdArg));
                ilocList.pop_front();
                break;
            case SUB:
                asmList.push_back(AsmCode("subl", instSecArg, instTrdArg));
                ilocList.pop_front();
                break;
            case MULT:
                // imull is the signed multiplication inst
                asmList.push_back(AsmCode("imull", instSecArg, instTrdArg));
                ilocList.pop_front();
                break;
            case DIV:
                // idivl is the signed division inst
                asmList.push_back(AsmCode("idivl", instSecArg, instTrdArg));
                ilocList.pop_front();
                break;


            case ADDI:
                // addI rpc... is the start of the function call sequence
                if (instFstArg == std::string("rpc"))
                {
                    // Ignore this and the next three instructions:
                    // addI rpc, 5 => tmp       Return address is calculated by call inst...
                    // storeAI tmp => rsp,0     ...and also pushed by call inst.
                    // storeAI rsp => rsp,4     Both RSP and RFP/RBP will be pushed...
                    // storeAI rfp => rsp,8     ...in the beginning of the callee function
                    for (int i = 0; i < 4; i++) ilocList.pop_front();

                    // Translate "jumpI -> L0" to "call foo", assuming L0 is the head label of function foo
                    asmList.push_back(AsmCode("call", findFuncByLabel(*ilocList.front().firstArg), nullstr));
                    ilocList.pop_front();
                }
                // The only other case is when we update the RSP. In this case, we need to translate
                // the instruction to a subtraction, as the stack in the ASM code grows downwards.
                else
                {
                    asmList.push_back(AsmCode("subq", instSecArg, instTrdArg));
                    ilocList.pop_front();
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

        } while (/* not start of another function */true);

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