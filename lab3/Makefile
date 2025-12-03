FLAGS = -O3

.PHONY: all clean

all: calc

calc: parser.y lex.l
	bison -d -o parser_bison.c parser.y
	flex -o lex_flex.c lex.l
	gcc $(FLAGS) -o calc parser_bison.c lex_flex.c cialo.c -lfl

clean:
	rm -f calc parser_bison.c parser_bison.h lex_flex.c
	rm -f *.o
