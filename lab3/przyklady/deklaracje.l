%option noyywrap
%{
  #include <string.h>
  #include "deklaracje_y.h"
%}
id [_a-zA-Z][_a-zA-Z0-9]*
%%
"int"  { return decl_int; }
"char" { return decl_char; }
{id}   { yylval.text=strdup(yytext); return id; }
";"    { return ';'; }
","    { return ','; }
\n
.
%%
