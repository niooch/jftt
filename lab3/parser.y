%{
#include <stdio.h>
#include "cialo.h"
extern int yylex(void);
extern int yyparse(void);
int yyerror(char const* s);

char* resultRPN = "\0"; //wynik w notacji odwrotnej polskiej
char* errorMess = "\0"; //komunikat o bledzie
%}

%union {
    long long int num;
}

%type <num> NUM
%token ADD SUB MUL DIV POW
%token EOL
%token SYNTAX_ERR

%left ADD SUB
%left MUL DIV
%right POW
%right UMINUS

%type <num> expr term power unary atom
%type <num> expNoPow expTerm expUnary expAtom

%%

input:
    %empty                  { 
                                printf(">> ");
                            }
    | input line
    ;

line:
    EOL                     {
                                printf(">> "); 
                            }
    | expr EOL              {
                                printf("|-> RPN   %s\n", resultRPN);    //zapisz RPN
                                printf("\\->Wynik: %lld\n", $1);        //zapisz wynik
                                printf(">> ");

                                strncpy(resultRPN, "\0", 1);            //reset RPN
                            }
    | error EOL             {
                                if(strcmp(errorMess, "\0") == 0) {
                                    strcpy(errorMess, "Błąd składniowy\n", 20);
                                }
                                printf("ERROR: %s\n", errorMess); //zapisz błąd
                                printf(">> ");

                                strncpy(errorMess, "\0", 1);           //reset błędu
                                strncpy(resultRPN, "\0", 1);            //reset RPN
                            }
    ;

expr:
    expr ADD term           {
                                $$ = $1 + $3;
                                char buffer[50];
                                snprintf(buffer, 50, "%s %s +", resultRPN, $3_str);
                                strncpy(resultRPN, buffer, sizeof(buffer));
                            }
    | expr SUB term         {
                                $$ = $1 - $3;
                                char buffer[50];
                                snprintf(buffer, 50, "%s %s -", resultRPN, $3_str);
                                strncpy(resultRPN, buffer, sizeof(buffer));
                            }
    | term                  { $$ = $1; }
    ;

term:
    term MUL power          {
                                $$ = $1 * $3;
                                char buffer[50];
                                snprintf(buffer, 50, "%s %s *", resultRPN, $3_str);
                                strncpy(resultRPN, buffer, sizeof(buffer));
                            }
    | term DIV power        {
                                if($3 == 0) {
                                    strcpy(errorMess, "Błąd: dzielenie przez zero\n", 30);
                                    YYABORT;
                                }
                                $$ = $1 / $3;
                                char buffer[50];
                                snprintf(buffer, 50, "%s %s /", resultRPN, $3_str);
                                strncpy(resultRPN, buffer, sizeof(buffer));
                            }
    | power                 { $$ = $1; }
    ;
power:
    unary POW power         {
                                $$ = 1;
                                for(long long int i = 0; i < $3; i++) {
                                    $$ *= $1;
                                }
                                char buffer[50];
                                snprintf(buffer, 50, "%s %s ^", resultRPN, $3_str);
                                strncpy(resultRPN, buffer, sizeof(buffer));
                            }
    | unary                 { $$ = $1; }
    ;
unary:
    SUB unary %prec UMINUS  {
                                $$ = -$2;
                                char buffer[50];
                                snprintf(buffer, 50, "%s %s neg", resultRPN, $2_str);
                                strncpy(resultRPN, buffer, sizeof(buffer));
                            }
    | atom                  { $$ = $1; }
    ;
atom:
    NUM                     { 
                                $$ = $1;
                                char buffer[50];
                                snprintf(buffer, 50, "%s %lld", resultRPN, $1);
                                strncpy(resultRPN, buffer, sizeof(buffer));
                            }
    | '(' expr ')'          { $$ = $2; }
    ;
%%

int yyerror(char const* s) {
    if(strcmp(s, "syntax error") == 0 && strcmp(errorMess, "\0") == 0) {
        strcpy(errorMess, "Błąd składniowy\n", 20);
    }
    return 0;
}

int main(void) {
    printf("Kalkulator - Notacja Odwrotna Polska (RPN)\n");
    printf("Wpisz wyrażenie do obliczenia lub Ctrl+D aby zakończyć.\n");
    printf(">> ");
    return yyparse();
}




