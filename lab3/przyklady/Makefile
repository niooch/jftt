FLAGS = -W -O3

.PHONY = all clean cleanall

all: deklaracje bool-calc bool-calc-rpn

deklaracje: deklaracje.y deklaracje.l
	bison -o deklaracje_y.c -d deklaracje.y
	flex -o deklaracje_l.c deklaracje.l
	$(CC) $(FLAGS) -o deklaracje deklaracje_y.c deklaracje_l.c

bool-calc: bool-calc.y bool-calc.l
	bison -o bool-calc_y.c -d bool-calc.y
	flex -o bool-calc_l.c bool-calc.l
	$(CC) $(FLAGS) -o bool-calc bool-calc_y.c bool-calc_l.c

bool-calc-rpn: bool-calc-rpn.y bool-calc.l
	bison -o bool-calc-rpn_y.c -d bool-calc-rpn.y
	flex -o bool-calc_l.c bool-calc.l
	$(CC) $(FLAGS) -o bool-calc-rpn bool-calc-rpn_y.c bool-calc_l.c

clean:
	rm -f *.c *.h

cleanall: clean
	rm -f deklaracje bool-calc bool-calc-rpn
