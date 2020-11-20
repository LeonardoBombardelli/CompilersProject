#ifndef ILOC_HPP
#define ILOC_HPP

#include <cstdlib>
#include <list>
#include <string>
#include <iostream>

typedef enum
{
    HALT,
    NOP,
    ADD,
    SUB,
    MULT,
    DIV,
    ADDI,
    LOADI,
    LOADAI,
    STOREAI,
    I2I,
    JUMPI,
    JUMP,
    CBR,
    CMP_LT,
    CMP_LE,
    CMP_EQ,
    CMP_GE,
    CMP_GT,
    CMP_NE

} Operations;

class IlocCode {

public:
    IlocCode(Operations opcode, std::string firstArg, std::string secondArg, std::string thirdArg) {
        this->label     = NULL;
        this->opcode    = opcode;
        this->firstArg  = new std::string; *(this->firstArg) = firstArg;
        this->secondArg = new std::string; *(this->secondArg) = secondArg;
        this->thirdArg  = new std::string; *(this->thirdArg) = thirdArg;
    }

    IlocCode(std::string label, Operations opcode, std::string firstArg, std::string secondArg, std::string thirdArg) {
        this->label     = new std::string; *(this->label) = label;
        this->opcode    = opcode;
        this->firstArg  = new std::string; *(this->firstArg) = firstArg;
        this->secondArg = new std::string; *(this->secondArg) = secondArg;
        this->thirdArg  = new std::string; *(this->thirdArg) = thirdArg;
    }
    IlocCode(Operations opcode, std::string* firstArg, std::string* secondArg, std::string* thirdArg) {
        this->label     = NULL;
        this->opcode    = opcode;
        this->firstArg  = firstArg;
        this->secondArg = secondArg;
        this->thirdArg  = thirdArg;
    }

    IlocCode(std::string* label, Operations opcode, std::string* firstArg, std::string* secondArg, std::string* thirdArg) {
        this->label     = label;
        this->opcode    = opcode;
        this->firstArg  = firstArg;
        this->secondArg = secondArg;
        this->thirdArg  = thirdArg;
    }


    std::string* label;
    Operations opcode;
    std::string* firstArg;
    std::string* secondArg;
    std::string* thirdArg;

};

// manage label and register names
extern int labelIndex;
extern int registerIndex;
std::string* createLabel();
std::string createLabelDirect();
std::string* createRegister();
std::string createRegisterDirect();

void PrintIlocCode(std::list<IlocCode> code);

#endif