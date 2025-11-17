%option noyywrap

%{
#include <stdio.h>
%}

/* Stany dla różnych rodzajów stringów */
%x SQ        
%x DQ        
%x TSQ       
%x TDQ       

%%

<INITIAL>\'\'\'        { BEGIN(TSQ); }
<INITIAL>\"\"\"        { BEGIN(TDQ); }
<INITIAL>\'            { ECHO; BEGIN(SQ); }
<INITIAL>\"            { ECHO; BEGIN(DQ); }
<INITIAL>#[^\n]*       { /* komentarz ignorujemy */ }
<INITIAL>\n            { ECHO; }
<INITIAL>.             { ECHO; }
<SQ>\\[^\n]            { ECHO; }
<SQ>\'                 { ECHO; BEGIN(INITIAL); }
<SQ>\n                 { ECHO; }
<SQ>.                  { ECHO; }
<DQ>\\[^\n]            { ECHO; }
<DQ>\"                 { ECHO; BEGIN(INITIAL); }
<DQ>\n                 { ECHO; }
<DQ>.                  { ECHO; }
<TSQ>\'\'\'            { BEGIN(INITIAL); }
<TSQ>\n                { ECHO; }
<TSQ>.                 { /*ignore*/ }
<TDQ>\"\"\"            { BEGIN(INITIAL); }
<TDQ>\n                { ECHO; }
<TDQ>.                 {/*ignore*/ }

<<EOF>>                { return 0; }

%%

int main(void) {
    yylex();
    return 0;
}
