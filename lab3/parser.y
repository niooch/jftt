%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cialo.h"

extern int yylex(void);
int yyerror(char const* s);

#define RPN_BUF 1024
#define ERR_BUF 256

static char resultRPN[RPN_BUF] = "";
static char errorMess[ERR_BUF] = "";

static void rpn_append(const char *s) {
    size_t len = strlen(resultRPN);
    size_t add = strlen(s);
    if (len + add + 1 >= RPN_BUF) {
        return;
    }
    strcat(resultRPN, s);
}

static void rpn_append_num(long long v) {
    char buf[64];
    snprintf(buf, sizeof(buf), "%lld ", v);
    rpn_append(buf);
}

static const long long SHIFT = 0;

%}

%union {
    long long int num;
}

%token <num> NUM
%token ADD SUB MUL DIV POW
%token EOL

%left ADD SUB
%left MUL DIV
%right POW
%right UMINUS

%type <num> expr term power unary atom
%type <num> expNoPow expTerm expUnary expAtom

%%


input:
    | input line
    ;

line:
      EOL                   {
                                printf(">> ");
                            }
    | expr EOL
                            {
                                long long res = cMod($1, SHIFT);

                                printf("|-> RPN   %s\n", resultRPN);
                                printf("\\-> Wynik: %lld\n", res);
                                printf(">> ");

                                resultRPN[0] = '\0';   
                                errorMess[0] = '\0';   
                            }
    | error EOL
                            {
                                if (errorMess[0] == '\0') {
                                    snprintf(errorMess, ERR_BUF, "Błąd składniowy");
                                }
                                printf("ERROR: %s\n", errorMess);
                                printf(">> ");

                                resultRPN[0] = '\0';
                                errorMess[0] = '\0';
                                yyerrok;
                            }
    ;


expr:
      expr ADD term
                            {
                                $$ = cAdd($1, $3, SHIFT);
                                rpn_append("+ ");
                            }
    | expr SUB term
                            {
                                $$ = cSub($1, $3, SHIFT);
                                rpn_append("- ");
                            }
    | term
                            {
                                $$ = $1;
                            }
    ;


term:
      term MUL power
                            {
                                $$ = cMul($1, $3, SHIFT);
                                rpn_append("* ");
                            }
    | term DIV power
                            {
                                if (cMod($3, SHIFT) == 0) {
                                    snprintf(errorMess, ERR_BUF, "Błąd: dzielenie przez zero");
                                    YYABORT;
                                }
                                $$ = cDiv($1, $3, SHIFT);
                                rpn_append("/ ");
                            }
    | power
                            {
                                $$ = $1;
                            }
    ;


power:
      unary
                            {
                                $$ = $1;
                            }
    | unary POW expNoPow
                            {
                                long long base = cMod($1, SHIFT);
                                long long exp  = cMod($3, SHIFT);

                                $$ = cPow(base, exp, SHIFT);
                                rpn_append("^ ");
                            }
    ;


unary:
      SUB unary %prec UMINUS
                            {
                                $$ = cSub(0, $2, SHIFT);
                                rpn_append("neg ");
                            }
    | atom
        {
            $$ = $1;
        }
    ;


atom:
      NUM
                            {
                                $$ = cMod($1, SHIFT);
                                rpn_append_num($$);
                            }
    | '(' expr ')'
                            {
                                $$ = $2;
                            }
    ;


expNoPow:
      expTerm
                            {
                                $$ = $1;
                            }
    | expNoPow ADD expTerm
                            {
                                $$ = cAdd($1, $3, SHIFT-1);
                                rpn_append("+ ");
                            }
    | expNoPow SUB expTerm
                            {
                                $$ = cSub($1, $3, SHIFT-1);
                                rpn_append("- ");
                            }
    ;

expTerm:
      expUnary
                            {
                                $$ = $1;
                            }
    | expTerm MUL expUnary
                            {
                                $$ = cMul($1, $3, SHIFT-1);
                                rpn_append("* ");
                            }
    | expTerm DIV expUnary
                            {
                                if (cMod($3, SHIFT-1) == 0) {
                                    snprintf(errorMess, ERR_BUF, "Dzielenie przez zero w wykładniku");
                                    YYABORT;
                                }
                                $$ = cDiv($1, $3, SHIFT-1);
                                rpn_append("/ ");
                            }
    ;

expUnary:
      SUB expUnary %prec UMINUS
                            {
                                $$ = cSub(0, $2, SHIFT-1);
                                rpn_append("neg ");
                            }
    | expAtom
                            {
                                $$ = $1;
                            }
    ;

expAtom:
      NUM
                            {
                                $$ = cMod($1, SHIFT-1);
                                rpn_append_num($$);
                            }
    | '(' expNoPow ')'
                            {
                                $$ = $2;
                            }
    ;

%%

int yyerror(char const* s) {
    if (strcmp(s, "syntax error") == 0 && errorMess[0] == '\0') {
        snprintf(errorMess, ERR_BUF, "Błąd składniowy");
    }
    return 0;
}

int main(void) {
    printf("Kalkulator - Notacja Odwrotna Polska (RPN) w GF(%d)\n", P);
    printf("Wpisz wyrażenie do obliczenia lub Ctrl+D aby zakończyć.\n");
    printf(">> ");
    return yyparse();
}
