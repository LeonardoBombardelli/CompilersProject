#ifndef ASM_HPP
#define ASM_HPP

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

    AsmCode(std::string label, std::string opcode, std::string firstArg, std::string secondArg) {
        this->label     = label;
        this->opcode    = opcode;
        this->firstArg  = firstArg;
        this->secondArg = secondArg;
    }

    std::string label;
    std::string opcode;
    std::string firstArg;
    std::string secondArg;

};

void generateAsm(std::list<IlocCode> code);
std::string findFuncByLabel(std::string label);

#endif