%option noyywrap yylineno nodefault

%{
#include "parser_bison.h"
#include <stdlib.h>
#include <stdio.h>
%}

digit   [0-9]+

%%
^[ \t]*"#".*           {
                      }
"\\\n"                 {
                      }
{digit}                {
                          long long v = strtoll(yytext, NULL, 10);
                          yylval.num = v;
                          return NUM;
                      }
"+"                    { return ADD; }
"-"                    { return SUB; }
"*"                    { return MUL; }
"/"                    { return DIV; }
"^"                    { return POW; }
"("                    { return '('; }
")"                    { return ')'; }
"\n"                   { return EOL; }
[ \t\r]+               { /* pomijamy */ }
.                      {
                          fprintf(stderr,
                                  "Błąd leksykalny (linia %d): nieznany znak '%s'\n",
                                  yylineno, yytext);
                      }
%%
