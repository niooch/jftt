%{
  #include <stdio.h>
  int yylex();
  void yyerror(char*);
%}
%union { char * text; }
%type <text> T L
%token <text> id
%token <text> decl_char decl_int
%%
D : T L ';' { YYACCEPT; }
  ;
L : id { printf("%s %s;\n", $<text>0, $1); free($1); }
  | L ',' id { printf("%s %s;\n", $<text>0, $3); free($3); }
  ;
T : decl_int { $$ = "int"; }
  | decl_char { $$ = "char"; }
  ;
%%
void yyerror(char *s)
{
  printf("%s",s);
}
int main()
{
yyparse();
return 0;
}

