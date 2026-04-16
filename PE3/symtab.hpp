#ifndef SYMTAB_HPP
#define SYMTAB_HPP

#include <iostream>
#include <string>
#include <vector>
#include <iomanip>

using namespace std;

// Structure to hold information about each identifier
struct Symbol {
    string name;
    string kind;         // variable, function, parameter, struct-tag, etc.
    string type;         // int, float, int*, etc.
    string storageClass; // auto, static, extern, register
    int size;            // size in bytes
    int scope;           // 0 = global, 1+ = local blocks
    int line;
    int col;
    string initVal;      // initial value if present
};

class SymbolTable {
public:
    vector<Symbol> symbols;
    int current_scope = 0;

    // Scope management
    void enterScope() { current_scope++; }
    void leaveScope() { current_scope--; }

    // Insert a new symbol into the table
    void insert(string name, string kind, string type, string storage, int size, int line, int col, string initVal = "null") {
        // Default storage to auto if none provided
        if (storage.empty() || storage == "none") {
            if (current_scope == 0 && kind != "struct-tag" && kind != "typedef") storage = "extern";
            else storage = "auto";
        }
        
        symbols.push_back({name, kind, type, storage, size, current_scope, line, col, initVal});
    }

    // Print the table in a clear format
    void printTable() {
        cout << "\n" << string(110, '=') << "\n";
        cout << " SYMBOL TABLE \n";
        cout << string(110, '=') << "\n";
        cout << left << setw(15) << "Name"
             << setw(15) << "Kind"
             << setw(15) << "Type"
             << setw(12) << "Storage"
             << setw(8)  << "Size"
             << setw(8)  << "Scope"
             << setw(12) << "Line:Col"
             << setw(15) << "InitVal" << "\n";
        cout << string(110, '-') << "\n";
        
        for (const auto& s : symbols) {
            string loc = to_string(s.line) + ":" + to_string(s.col);
            cout << left << setw(15) << s.name
                 << setw(15) << s.kind
                 << setw(15) << s.type
                 << setw(12) << s.storageClass
                 << setw(8)  << s.size
                 << setw(8)  << s.scope
                 << setw(12) << loc
                 << setw(15) << s.initVal << "\n";
        }
        cout << string(110, '=') << "\n\n";
    }
};

#endif