#include "../include/ILOC.hpp"

int labelIndex;
int registerIndex;

std::string createLabel() {
    return "L" + std::to_string(labelIndex++);
}

std::string createRegister() {
    return "r" + std::to_string(registerIndex++);
}
