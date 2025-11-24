%option noyywrap
%option yylineno
%{
#include "bool-calc_y.h"
int yylex();
%}
%%
[ \t]+ 	;
true 	{ yylval = 1; return VAL; }
false 	{ yylval = 0; return VAL; }
and	{ return AND; }
or 	{ return OR; }
not	{ return NOT; }
\(	{ return LNAW; }
\)	{ return PNAW; }
\n	{ return END; }
.	{ return ERROR; }
%%
