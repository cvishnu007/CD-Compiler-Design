CC = g++
CFLAGS = -std=c++11

all: symbol_table

symbol_table: lex.yy.c parser.tab.cpp
	$(CC) $(CFLAGS) lex.yy.c parser.tab.cpp -o symbol_table

parser.tab.cpp parser.tab.hpp: parser.y
	bison -d -o parser.tab.cpp parser.y

lex.yy.c: lexer.l parser.tab.hpp
	flex lexer.l

clean:
	rm -f lex.yy.c parser.tab.cpp parser.tab.hpp symbol_table