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
    SUBI,
    RSUBI,
    MULTI,
    DIVI,
    RDIVI,
    // shifts?
    AND,
    ANDI,
    OR,
    ORI,
    LOADI,
    LOAD,
    LOADAI,
    // loadA0, storeA0 -> arrays
    STORE,
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
std::string* createRegister();

std::string opcodeToString(Operations opcode);
void PrintIlocCode(std::list<IlocCode> code);

#endif