#include "../include/Assembly.hpp"

// REMEMBER: STACK IS TOP-DOWN!!!

std::map<std::string, std::string>  regMapILOCtoASM;
std::map<std::string, bool>         regASMfree;


std::list<AsmCode> generateAsm(std::list<IlocCode> ilocList)
{
    createMaps();

    std::list<AsmCode> asmList = std::list<AsmCode>();
    std::string nullstr = std::string();

    // ignore ILOC code prologue (register init and main() call)
    for (int i = 0; i < 9; i++) ilocList.pop_front();

    asmList.push_back(AsmCode(std::string(".file"), std::string("\"\""), nullstr)); // define empty filename
    asmList.push_back(AsmCode(std::string(".text"), nullstr, nullstr));

    bool global_vars_exist = false;

    // for every global var, insert init code
    for (std::pair<std::string, SymbolTableEntry*> item : *scopeStack->back()->symbolTable)
    {
        if (item.second->entryNature == TABLE_NATURE_VAR)
        {
            global_vars_exist = true;
            asmList.push_back(AsmCode(std::string(".globl"), item.first, nullstr));
            asmList.push_back(AsmCode(std::string(".data"), nullstr, nullstr));
            asmList.push_back(AsmCode(std::string(".align"), std::string("4"), nullstr));
            asmList.push_back(AsmCode(std::string(".type"), item.first, std::string("@object")));
            asmList.push_back(AsmCode(std::string(".size"), item.first, std::string("4")));
            asmList.push_back(AsmCode(item.first));
            asmList.push_back(AsmCode(std::string(".long"), std::string("0"), nullstr));
        }
    }

    if (global_vars_exist) asmList.push_back(AsmCode(std::string(".text"), nullstr, nullstr));

    // translate every function from ILOC to ASM
    while (!ilocList.empty())
    {
        std::string funcLabel = *ilocList.front().label;
        std::string funcName = findFuncByLabel(funcLabel);
        ilocList.pop_front();

        std::string auxString1, auxString2;
        bool end_of_function = false;

        asmList.push_back(AsmCode(std::string(".globl"), funcName, nullstr));
        asmList.push_back(AsmCode(std::string(".type"), funcName, std::string("@function")));
        asmList.push_back(AsmCode(funcName));                                                       // func label
        asmList.push_back(AsmCode(std::string("pushq"), std::string("%rsp"), nullstr));             // save old rsp
        asmList.push_back(AsmCode(std::string("pushq"), std::string("%rbp"), nullstr));             // save old rbp
        asmList.push_back(AsmCode(std::string("movq"), std::string("%rsp"), std::string("%rbp")));  // new rbp = old rsp (equivalent to i2i)

        // translate each ILOC instruction until the end of current function
        // (i.e. until the starting label of next function)
        while (!end_of_function && !ilocList.empty()) {
            IlocCode inst = ilocList.front();
            std::string instLabel  = (inst.label != nullptr)     ? *(inst.label)     : std::string();
            std::string instFstArg = (inst.firstArg != nullptr)  ? *(inst.firstArg)  : std::string();
            std::string instSecArg = (inst.secondArg != nullptr) ? *(inst.secondArg) : std::string();
            std::string instTrdArg = (inst.thirdArg != nullptr)  ? *(inst.thirdArg)  : std::string();

            switch(inst.opcode)
            {
            // the only halt inst is in the (ignored) prologue of the ILOC code 
            // case HALT:    break;
            
            case NOP:
                // test if end of function
                if (findFuncByLabel(instLabel) != nullstr) end_of_function = true;
                else
                {
                    asmList.push_back(AsmCode(instLabel));
                    ilocList.pop_front();
                }
                break;


            // Arithmetic instructions "inst r1, r2 => r1" translated to "inst r2, r1" because 
            // the result is saved in the second argument
            case ADD:
                auxString1 = registerILOCtoASM(instSecArg, ilocList);
                asmList.push_back(AsmCode(std::string("addl"), auxString1, registerILOCtoASM(instTrdArg, ilocList)));
                liberateRegisterASM(auxString1);
                ilocList.pop_front();
                break;
            case SUB:
                auxString1 = registerILOCtoASM(instSecArg, ilocList);
                asmList.push_back(AsmCode(std::string("subl"), auxString1, registerILOCtoASM(instTrdArg, ilocList)));
                liberateRegisterASM(auxString1);
                ilocList.pop_front();
                break;
            case MULT:
                // imull is the signed multiplication inst
                auxString1 = registerILOCtoASM(instSecArg, ilocList);
                asmList.push_back(AsmCode(std::string("imul"), auxString1, registerILOCtoASM(instTrdArg, ilocList)));
                liberateRegisterASM(auxString1);
                ilocList.pop_front();
                break;
            case DIV:
                // save rax and rdx to restore later
                asmList.push_back(AsmCode(std::string("pushq"), std::string("%rax"), nullstr));
                asmList.push_back(AsmCode(std::string("pushq"), std::string("%rdx"), nullstr));

                auxString1 = registerILOCtoASM(instSecArg, ilocList);
                asmList.push_back(AsmCode(std::string("movl"), registerILOCtoASM(instFstArg, ilocList), std::string("%eax")));
                asmList.push_back(AsmCode(std::string("cltd"), nullstr, nullstr));
                asmList.push_back(AsmCode(std::string("idivl"), auxString1, nullstr));
                asmList.push_back(AsmCode(std::string("movl"), std::string("%eax"), registerILOCtoASM(instTrdArg, ilocList)));

                // restore rax and rdx
                asmList.push_back(AsmCode(std::string("popq"), std::string("%rdx"), nullstr));
                asmList.push_back(AsmCode(std::string("popq"), std::string("%rax"), nullstr));

                liberateRegisterASM(auxString1);
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

                    asmList.push_back(AsmCode(std::string("pushq"), std::string("%rax"), nullstr));

                    // Translate "jumpI -> L0" to "call foo", assuming L0 is the head label of function foo
                    asmList.push_back(AsmCode(std::string("call"), findFuncByLabel(*ilocList.front().firstArg), nullstr));
                    
                    asmList.push_back(AsmCode(std::string("movl"), std::string("%eax"), std::string("-12(%rsp)")));
                    asmList.push_back(AsmCode(std::string("popq"), std::string("%rax"), nullstr));
                    
                    
                    ilocList.pop_front();
                }
                // The only other case is when we update the RSP. In this case, we need to translate
                // the instruction to a subtraction, as the stack in the ASM code grows downwards.
                else
                {
                    // second arg is a literal, third arg is a register
                    auxString1 = std::string("$") + instSecArg;
                    asmList.push_back(AsmCode(std::string("subq"), auxString1, registerILOCtoASM(instTrdArg, ilocList)));
                    ilocList.pop_front();
                }
                break;


            case LOADI:
                auxString1 = std::string("$") + instFstArg;
                asmList.push_back(AsmCode(std::string("movl"), auxString1, registerILOCtoASM(instTrdArg, ilocList)));
                ilocList.pop_front();
                break;
            case LOADAI:
                // loadAI rfp, 0 =>... is the start of the function return sequence
                if (instFstArg == std::string("rfp") && instSecArg == std::string("0"))
                {
                    // Ignore this and the next five instructions:
                    // loadAI rfp, 0 => ...     Get ret address (ret inst will do)
                    // loadAI rfp, 4 => ...     Get old RSP value (pop inst will do)
                    // loadAI rfp, 8 => ...     Get old RFP/RBP value (pop inst will do)
                    // i2i ... => rsp           
                    // i2i ... => rfp           
                    // jump -> ...              Jump to ret address (ret inst will do)
                    for (int i = 0; i < 6; i++) ilocList.pop_front();
                    
                    // In the main function, we need to set %eax to be the return value. This is because
                    // we normally (for other functions) save the return value in the stack (rbp,12).
                    if (funcName == std::string("main"))
                    {
                        asmList.push_back(AsmCode(std::string("movl"), std::string("-12(%rbp)"), std::string("%eax")));
                    }

                    asmList.push_back(AsmCode(std::string("movq"), std::string("%rbp"), std::string("%rsp")));
                    asmList.push_back(AsmCode(std::string("popq"), std::string("%rbp"), nullstr));
                    asmList.push_back(AsmCode(std::string("popq"), std::string("%rsp"), nullstr));
                    asmList.push_back(AsmCode(std::string("ret"), nullstr, nullstr));
                    // asmList.push_back(AsmCode(std::string(".size"), funcName, std::string(".-") + funcName));
                }
                else
                {
                    // global var access
                    if (instFstArg == std::string("rbss"))
                    {
                        auxString1 = retrieveGlobalNameFromDesloc(instSecArg) + std::string("(%rip)");
                    }
                    // local var access
                    else
                    {
                        auxString1 = std::string("-") + instSecArg + std::string("(") + registerILOCtoASM(instFstArg, ilocList) + std::string(")");
                    }

                    asmList.push_back(AsmCode(std::string("movl"), auxString1, registerILOCtoASM(instTrdArg, ilocList)));
                    ilocList.pop_front();
                }

                break;


            case STOREAI:
                auxString2 = registerILOCtoASM(instTrdArg, ilocList);
                
                // store global var
                if (instFstArg == std::string("rbss"))
                {
                    auxString1 = retrieveGlobalNameFromDesloc(instSecArg) + std::string("(%rip)");
                    asmList.push_back(AsmCode(std::string("movl"), auxString2, auxString1));
                }
                // store local var
                else
                {
                    auxString1 = std::string("-") + instSecArg + std::string("(") + registerILOCtoASM(instFstArg, ilocList) + std::string(")");
                    asmList.push_back(AsmCode(std::string("movl"), auxString2, auxString1));
                }

                ilocList.pop_front();

                // when we store a register to memory, we NEVER use it anymore, so we can free it to be used again
                liberateRegisterASM(auxString2);
                break;


            // These two uses of i2i are dealt with in other parts of the code:
            // - in the function return sequence, we ignore it (see LOADI)
            // - in the beginning of the function we ignore it (because the "movq rsp, rfp" is done before this switch) 
            // Here we deal only with its use in the ternary operator.
            case I2I:
                if (instFstArg != std::string("rsp") && instTrdArg != std::string("rbp"))
                {
                    auxString1 = registerILOCtoASM(instFstArg, ilocList);
                    auxString2 = registerILOCtoASM(instTrdArg, ilocList);
                    asmList.push_back(AsmCode(std::string("movl"), auxString1, auxString2));
                }
                ilocList.pop_front();
                break;

            
            // Here we only deal with jumpI instructions outside of function calls. For function calls see case ADDI
            case JUMPI:
                asmList.push_back(AsmCode(std::string("jmp"), instFstArg, nullstr));
                ilocList.pop_front();
                break;

            // Here we don't need to do anything because jump instructions are only used in function return sequence (see case LOADI)
            // case JUMP:    break;

            // Ignore because it is treted in the CMPs
            // case CBR:     break;

            case CMP_LT:
                auxString1 = registerILOCtoASM(instFstArg, ilocList);
                auxString2 = registerILOCtoASM(instSecArg, ilocList);
                asmList.push_back(AsmCode(std::string("cmpl"), auxString2, auxString1));
                ilocList.pop_front();

                // Here we take the cbr instruction
                auxString1 = *ilocList.front().secondArg;
                auxString2 = *ilocList.front().thirdArg;
                asmList.push_back(AsmCode(std::string("jl"), auxString1, nullstr));
                asmList.push_back(AsmCode(std::string("jge"), auxString2, nullstr));
                ilocList.pop_front();
                break;
            case CMP_LE:
                auxString1 = registerILOCtoASM(instFstArg, ilocList);
                auxString2 = registerILOCtoASM(instSecArg, ilocList);
                asmList.push_back(AsmCode(std::string("cmpl"), auxString2, auxString1));
                ilocList.pop_front();

                // Here we take the cbr instruction
                auxString1 = *ilocList.front().secondArg;
                auxString2 = *ilocList.front().thirdArg;
                asmList.push_back(AsmCode(std::string("jle"), auxString1, nullstr));
                asmList.push_back(AsmCode(std::string("jg"), auxString2, nullstr));
                ilocList.pop_front();
                break;
            case CMP_EQ:
                auxString1 = registerILOCtoASM(instFstArg, ilocList);
                auxString2 = registerILOCtoASM(instSecArg, ilocList);
                asmList.push_back(AsmCode(std::string("cmpl"), auxString2, auxString1));
                ilocList.pop_front();

                // Here we take the cbr instruction
                auxString1 = *ilocList.front().secondArg;
                auxString2 = *ilocList.front().thirdArg;
                asmList.push_back(AsmCode(std::string("je"), auxString1, nullstr));
                asmList.push_back(AsmCode(std::string("jne"), auxString2, nullstr));
                ilocList.pop_front();
                break;
            case CMP_GE:
                auxString1 = registerILOCtoASM(instFstArg, ilocList);
                auxString2 = registerILOCtoASM(instSecArg, ilocList);
                asmList.push_back(AsmCode(std::string("cmpl"), auxString2, auxString1));
                ilocList.pop_front();

                // Here we take the cbr instruction
                auxString1 = *ilocList.front().secondArg;
                auxString2 = *ilocList.front().thirdArg;
                asmList.push_back(AsmCode(std::string("jge"), auxString1, nullstr));
                asmList.push_back(AsmCode(std::string("jl"), auxString2, nullstr));
                ilocList.pop_front();
                break;
            case CMP_GT:
                auxString1 = registerILOCtoASM(instFstArg, ilocList);
                auxString2 = registerILOCtoASM(instSecArg, ilocList);
                asmList.push_back(AsmCode(std::string("cmpl"), auxString2, auxString1));
                ilocList.pop_front();

                // Here we take the cbr instruction
                auxString1 = *ilocList.front().secondArg;
                auxString2 = *ilocList.front().thirdArg;
                asmList.push_back(AsmCode(std::string("jg"), auxString1, nullstr));
                asmList.push_back(AsmCode(std::string("jle"), auxString2, nullstr));
                ilocList.pop_front();
                break;
            case CMP_NE:
                auxString1 = registerILOCtoASM(instFstArg, ilocList);
                auxString2 = registerILOCtoASM(instSecArg, ilocList);
                asmList.push_back(AsmCode(std::string("cmpl"), auxString2, auxString1));
                ilocList.pop_front();

                // Here we take the cbr instruction
                auxString1 = *ilocList.front().secondArg;
                auxString2 = *ilocList.front().thirdArg;
                asmList.push_back(AsmCode(std::string("jne"), auxString1, nullstr));
                asmList.push_back(AsmCode(std::string("je"), auxString2, nullstr));
                ilocList.pop_front();
                break;
            default:
                std::cout << "Something went wrong. Exiting..." << std::endl;
                exit(1);
                break;
            }

        }

    }

    return asmList;

}

std::string findFuncByLabel(std::string label)
{
    for (std::pair<std::string, std::string*> item : *auxFuncLabelMap)
    {
        if (*item.second == label) return item.first;
    }

    return std::string();
}

std::string registerILOCtoASM(std::string ilocReg, std::list<IlocCode> ilocCodeList)
{
    if (ilocReg == std::string("rsp")) return std::string("%rsp");
    if (ilocReg == std::string("rfp")) return std::string("%rbp");

    std::map<std::string, std::string>::iterator it = regMapILOCtoASM.find(ilocReg);
    
    if(it != regMapILOCtoASM.end())
    {
        return it->second;
    }

    else
    {
        return allocateRegisterASM(ilocReg, ilocCodeList);
    }
    
}

void liberateRegisterASM(std::string asmReg)
{
    regASMfree[asmReg] = false;
    
    bool notFound = true;
    std::map<std::string, std::string>::iterator it = regMapILOCtoASM.begin();

    while(notFound && it == regMapILOCtoASM.end())
    {
        if(it->second == asmReg)
        {
            notFound = false;
            regMapILOCtoASM.erase(it);
        }

        ++it;
    }

    return;
}


std::string allocateRegisterASM(std::string ilocReg, std::list<IlocCode> ilocCodeList)
{
    std::map<std::string, bool>::iterator it = regASMfree.begin();
    
    while(it != regASMfree.end())
    {
        if(it->second == false)
        {
            it->second = true;
            regMapILOCtoASM[ilocReg] = it->first;
            return it->first;
        }
        ++it;
    } 

    bool anyLiberated = false;
    for(std::pair<std::string, std::string> item: regMapILOCtoASM)
        anyLiberated = anyLiberated || passiveLiberateASMreg(item.first, ilocCodeList);

    // From here on out, we were supposed to implement a spill mechanism for the registers.

    return(std::string());
}

bool passiveLiberateASMreg(std::string ilocReg, std::list<IlocCode> ilocCodeList)
{
    for(IlocCode inst: ilocCodeList)
    {
        if(ilocReg == *(inst.firstArg) || ilocReg == *(inst.secondArg) || ilocReg == *(inst.thirdArg)) return false;
    }

    liberateRegisterASM(regMapILOCtoASM[ilocReg]);

    return true;
}

void createMaps()
{
    regMapILOCtoASM = std::map<std::string, std::string>();
    regASMfree = std::map<std::string, bool>();

    regASMfree["%eax"] = false;
    regASMfree["%ecx"] = false;
    regASMfree["%edx"] = false;
    regASMfree["%ebx"] = false;
    regASMfree["%esi"] = false;
    regASMfree["%edi"] = false;
    regASMfree["%r8d"] = false;
    regASMfree["%r9d"] = false;
    regASMfree["%r10d"] = false;
    regASMfree["%r11d"] = false;
    regASMfree["%r12d"] = false;
    regASMfree["%r13d"] = false;
    regASMfree["%r14d"] = false;
    regASMfree["%r15d"] = false;
    
}

std::string retrieveGlobalNameFromDesloc(std::string desloc)
{
    for (std::pair<std::string, SymbolTableEntry*> item : *scopeStack->back()->symbolTable)
    {
        if(std::to_string(item.second->desloc) == desloc)
            return item.first;
    }

    return std::string();
}

void PrintAsmCode(std::list<AsmCode> code)
{
    std::string nullstr = std::string();

    for (AsmCode inst : code)
    {
        if (inst.label != nullstr) std::cout << inst.label << ":";
        else
        {
            std::cout << "\t" << inst.opcode;
            if (inst.firstArg != nullstr) std::cout << "\t" << inst.firstArg;
            if (inst.secondArg != nullstr) std::cout << ", " << inst.secondArg;
        }
        std::cout << std::endl;
    }

}