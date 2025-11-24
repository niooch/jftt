%{
#define YYSTYPE int
#include<stdio.h>
extern int yylineno;  // z lex-a
int yylex();
int yyerror(char*);
%}
%token VAL
%token AND
%token OR
%token NOT
%token LNAW
%token PNAW
%token END
%token ERROR
%%
input:
    | input line
;
line: expe END 	{ printf("Linia %d = %s\n",yylineno-1,($$?"true":"false")); }
    | error END	{ printf("Błąd składni w linii %d!\n",yylineno-1); }
;
expe: expt		{ $$ = $1; }
    | expe OR expt	{ $$ = $1 || $3; }
;
expt: expf		{ $$ = $1; }
    | expt AND expf	{ $$ = $1 && $3; }
;
expf: VAL		
    | NOT expf 		{ $$ = !$2; }
    | LNAW expe PNAW	{ $$ = $2; }
;
%%
int yyerror(char *s)
{
    printf("%s\n",s);	
    return 0;
}

int main()
{
    yyparse();
    printf("Przetworzono linii: %d\n",yylineno-1);
    return 0;
}
