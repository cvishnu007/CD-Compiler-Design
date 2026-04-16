CC = g++
CFLAGS = -std=c++11

all: evaluator

evaluator: lex.yy.c parser.tab.cpp
	$(CC) $(CFLAGS) lex.yy.c parser.tab.cpp -o evaluator

parser.tab.cpp parser.tab.hpp: parser.y
	bison -d -o parser.tab.cpp parser.y

lex.yy.c: lexer.l parser.tab.hpp
	flex lexer.l

clean:
	rm -f lex.yy.c parser.tab.cpp parser.tab.hpp evaluator.exe