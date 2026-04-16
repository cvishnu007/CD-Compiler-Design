#ifndef SYMTAB_HPP
#define SYMTAB_HPP

#include <iostream>
#include <string>
#include <unordered_map>
#include <iomanip>

using namespace std;

// Structure to hold variable info
struct Symbol {
    string name;
    string type;      // "int" or "float"
    double value;     // Using double to hold both ints and floats temporarily
    bool initialized; 
};

class SymbolTable {
public:
    unordered_map<string, Symbol> table;

    // Register a new variable
    bool declare(string name, string type) {
        if (table.find(name) != table.end()) return false; // Already exists
        table[name] = {name, type, 0.0, false};
        return true;
    }

    // Find a variable
    Symbol* lookup(string name) {
        if (table.find(name) != table.end()) return &table[name];
        return nullptr;
    }

    // Print the evaluated results
    void printTable() {
        cout << "\n==============================================\n";
        cout << " EVALUATED SYMBOL TABLE \n";
        cout << "==============================================\n";
        cout << left << setw(15) << "Variable"
             << setw(10) << "Type"
             << setw(15) << "Final Value" << "\n";
        cout << "----------------------------------------------\n";
        for (auto const& pair : table) {
            cout << left << setw(15) << pair.second.name
                 << setw(10) << pair.second.type;
            if (pair.second.initialized)
                cout << setw(15) << pair.second.value << "\n";
            else
                cout << setw(15) << "Uninitialized" << "\n";
        }
        cout << "==============================================\n\n";
    }
};

#endif