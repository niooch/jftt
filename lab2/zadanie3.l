%option noyywrap
%option nounput noinput

%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Obsługa raw stringów C++: zapamiętujemy delimiter */
#define RDELIM_MAX 16
static char rdelim[RDELIM_MAX + 1];
static int  rdelim_len = 0;
%}

/* stany */
%x S_SQ S_DQ S_RAW

%%

/* --- KOD C++ ------------------------------------------------------------ */

/* Preprocesor – przepuszczamy całe linie */
^[ \t]*#[^\n]*            { ECHO; }

/* Raw string C++11: R"delim( ... )delim"  (delim: 0..16 [A-Za-z0-9_]) */
R\"([A-Za-z0-9_]{0,16})\( {
    const char *q  = yytext + 2;           /* po R" */
    const char *lp = strchr(q, '(');
    rdelim_len = (int)(lp - q);
    if (rdelim_len > RDELIM_MAX) rdelim_len = RDELIM_MAX;
    memcpy(rdelim, q, (size_t)rdelim_len);
    rdelim[rdelim_len] = '\0';
    ECHO;
    BEGIN(S_RAW);
}

/* Zwykłe stringi/znaki */
\"                        { ECHO; BEGIN(S_DQ); }
\'                        { ECHO; BEGIN(S_SQ); }

/* --- DOXYGEN: ZOSTAWIAMY ----------------------------------------------- */
"///"[^\n]*               { ECHO; }  /* liniowe */
"//!"[^\n]*               { ECHO; }
"/**"([^*]|\*+[^/])*\*+/  { ECHO; }  /* blokowe */
"/*!"([^*]|\*+[^/])*\*+/  { ECHO; }

/* --- Zwykłe komentarze: USUWAMY ---------------------------------------- */
"//"[^\n]*                { /* drop */ }
"/*"([^*]|\*+[^/])*\*+/   { /* drop */ }

/* Nowe linie i reszta kodu */
\n                        { ECHO; }
.                         { ECHO; }

/* --- STAN: "..." -------------------------------------------------------- */
<S_DQ>{
  \\ .                     { ECHO; }
  \"                       { ECHO; BEGIN(INITIAL); }
  [^\n\\"]+                { ECHO; }
  \n                       { ECHO; }
  .                        { ECHO; }
}

/* --- STAN: '...' -------------------------------------------------------- */
<S_SQ>{
  \\ .                     { ECHO; }
  \'                       { ECHO; BEGIN(INITIAL); }
  [^\n\\']+                { ECHO; }
  \n                       { ECHO; }
  .                        { ECHO; }
}

/* --- STAN: R"delim(... )delim" ----------------------------------------- */
<S_RAW>{
  \)                       {
                             int i, ok = 1;
                             for (i = 0; i < rdelim_len; ++i) {
                               int c = yyinput();
                               if (c == 0 || c == EOF) { ok = 0; break; }
                               if (c != (unsigned char)rdelim[i]) { ok = 0; unput(c); while (i--) unput(rdelim[i]); break; }
                             }
                             if (ok) {
                               int c = yyinput();
                               if (c == '"') {
                                 putchar(')');
                                 fwrite(rdelim, 1, (size_t)rdelim_len, stdout);
                                 putchar('"');
                                 BEGIN(INITIAL);
                               } else {
                                 unput(c);
                                 while (i--) unput(rdelim[i]);
                                 ECHO; /* sama ')' */
                               }
                             } else {
                               ECHO;
                             }
                           }
  .|\n                     { ECHO; }
}

/* --- KONIEC ------------------------------------------------------------- */
<<EOF>>                    { return 0; }

%%

int main(void) {
    yylex();
    return 0;
}

