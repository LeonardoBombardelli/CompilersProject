#include "../include/ILOC.hpp"

int labelIndex;
int registerIndex;

std::string* createLabel() {
    std::string *label = new std::string;
    *label = std::string("L" + std::to_string(labelIndex++));
    return label;
}

std::string* createRegister() {
    std::string *reg = new std::string;
    *reg = std::string("r" + std::to_string(registerIndex++));
    return reg;
}
