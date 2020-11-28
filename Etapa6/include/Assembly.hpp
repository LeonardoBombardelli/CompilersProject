#ifndef ASSEMBLY_HPP
#define ASSEMBLY_HPP

#include "ILOC.hpp"
#include "Scope.hpp"

extern std::list<Scope *> *scopeStack;
extern std::map<std::string, std::string*> *auxFuncLabelMap;

class AsmCode {

public:
    AsmCode(std::string opcode, std::string firstArg, std::string secondArg) {
        this->label     = std::string();
        this->opcode    = opcode;
        this->firstArg  = firstArg;
        this->secondArg = secondArg;
    }

    AsmCode(std::string label) {
        this->label     = label;
        this->opcode    = std::string();
        this->firstArg  = std::string();
        this->secondArg = std::string();
    }

    std::string label;
    std::string opcode;
    std::string firstArg;
    std::string secondArg;

};

std::list<AsmCode> generateAsm(std::list<IlocCode> code);
std::string findFuncByLabel(std::string label);
std::string registerILOCtoASM(std::string ilocReg, std::list<IlocCode> ilocCodeList);
std::string allocateRegisterASM(std::string ilocReg, std::list<IlocCode> ilocCodeList);
void liberateRegisterASM(std::string asmReg);
bool passiveLiberateASMreg(std::string ilocReg, std::list<IlocCode> ilocCodeList);
void createMaps();
std::string retrieveGlobalNameFromDesloc(std::string desloc);
void PrintAsmCode(std::list<AsmCode> code);

#endif