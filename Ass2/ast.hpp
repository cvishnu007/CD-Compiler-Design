#ifndef AST_HPP
#define AST_HPP

#include <iostream>
#include <string>

using namespace std;

// Global counters for temporaries and labels
extern int temp_count;
extern int label_count;

inline string newTemp() { return "t" + to_string(temp_count++); }
inline string newLabel() { return "L" + to_string(label_count++); }
inline void emit(string op, string arg1, string arg2, string result) {
    if (arg1 == "") arg1 = "_";
    if (arg2 == "") arg2 = "_";
    cout << "(" << op << ", " << arg1 << ", " << arg2 << ", " << result << ")\n";
}

// AST Node Structure (Supports up to 3 children for if-else: cond, true_block, false_block)
struct ASTNode {
    string type;   // "IF", "DO_WHILE", "COND", "ASSIGN", "OP", "ID", "NUM", "SEQ"
    string value;  
    ASTNode* c1;
    ASTNode* c2;
    ASTNode* c3;

    ASTNode(string t, string v = "", ASTNode* child1 = nullptr, ASTNode* child2 = nullptr, ASTNode* child3 = nullptr) {
        type = t; value = v; c1 = child1; c2 = child2; c3 = child3;
    }
};

// PE5: Postorder Traversal (Reverse Polish / Tree Printing)
inline void printPostOrder(ASTNode* node) {
    if (!node) return;
    printPostOrder(node->c1);
    printPostOrder(node->c2);
    printPostOrder(node->c3);
    
    if (node->type == "ID" || node->type == "NUM") cout << node->value << " ";
    else if (node->type == "OP" || node->type == "COND") cout << node->value << " ";
    else if (node->type == "ASSIGN") cout << "= ";
    else if (node->type == "IF") cout << "IF_ELSE ";
    else if (node->type == "DO_WHILE") cout << "DO_WHILE ";
}

// PE6: Intermediate Code Generation (Quadruples)
inline string generateTAC(ASTNode* node) {
    if (!node) return "";

    if (node->type == "ID" || node->type == "NUM") {
        return node->value;
    }
    else if (node->type == "SEQ") {
        generateTAC(node->c1);
        generateTAC(node->c2);
        return "";
    }
    else if (node->type == "OP" || node->type == "COND") {
        string left = generateTAC(node->c1);
        string right = generateTAC(node->c2);
        string t = newTemp();
        emit(node->value, left, right, t);
        return t;
    }
    else if (node->type == "ASSIGN") {
        string right = generateTAC(node->c2);
        emit("=", right, "", node->c1->value);
        return node->c1->value;
    }
    else if (node->type == "IF") {
        // c1: Condition, c2: True Block, c3: False Block
        string cond_temp = generateTAC(node->c1);
        string l_false = newLabel();
        string l_end = newLabel();

        emit("ifFalse", cond_temp, "", l_false);
        generateTAC(node->c2); // True statements
        emit("goto", "", "", l_end);
        
        emit("label", "", "", l_false);
        generateTAC(node->c3); // False statements
        
        emit("label", "", "", l_end);
        return "";
    }
    else if (node->type == "DO_WHILE") {
        // c1: Body, c2: Condition
        string l_start = newLabel();
        
        emit("label", "", "", l_start);
        generateTAC(node->c1); // Execute body
        
        string cond_temp = generateTAC(node->c2); // Evaluate condition
        emit("ifTrue", cond_temp, "", l_start);
        return "";
    }
    return "";
}

inline void freeAST(ASTNode* node) {
    if (!node) return;
    freeAST(node->c1); freeAST(node->c2); freeAST(node->c3);
    delete node;
}

#endif