#ifndef AST_HPP
#define AST_HPP

#include <iostream>
#include <string>

using namespace std;

// Structure for an Abstract Syntax Tree Node
struct ASTNode {
    string value;
    ASTNode* left;
    ASTNode* right;

    // Constructor
    ASTNode(string val, ASTNode* l = nullptr, ASTNode* r = nullptr) {
        value = val;
        left = l;
        right = r;
    }
};

// Recursive function to print Postorder Traversal (Reverse Polish Notation)
inline void printPostOrder(ASTNode* node) {
    if (node == nullptr) return;
    
    // 1. Traverse Left
    printPostOrder(node->left);
    
    // 2. Traverse Right
    printPostOrder(node->right);
    
    // 3. Print Root
    cout << node->value << " ";
}

// Memory management: clean up the tree after we are done
inline void freeAST(ASTNode* node) {
    if (node == nullptr) return;
    freeAST(node->left);
    freeAST(node->right);
    delete node;
}

#endif