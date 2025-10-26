%option noyywrap

%{
#include <stdio.h>

/* Stany dla różnych rodzajów stringów */
%}
%x S_SQ S_DQ S_TSQ S_TDQ

%%

/* --- POCZĄTKOWY STAN: kod Pythona --- */

/* Zachowaj shebang z początku wiersza */
^#![^\n]*\n                 { ECHO; }

/* Start POTRÓJNYCH stringów z opcjonalnym prefixem (r, f, b, u i kombinacje) */
([rRuUbBfF]{0,2})\"\"\"     { ECHO; BEGIN(S_TDQ); }
([rRuUbBfF]{0,2})\'\'\'     { ECHO; BEGIN(S_TSQ); }

/* Start zwykłych stringów z opcjonalnym prefixem */
([rRuUbBfF]{0,2})\"         { ECHO; BEGIN(S_DQ); }
([rRuUbBfF]{0,2})\'         { ECHO; BEGIN(S_SQ); }

/* Komentarz – usuń od # do końca wiersza (zachowaj newline, jeśli jest) */
#[^\n]*                     { /* drop */ }
\n                          { ECHO; }

/* Pozostałe znaki w kodzie wypisujemy bez zmian */
.                           { ECHO; }

/* --- STAN: podwójnie cudzysłowowy string "..." --- */
<S_DQ>{
  \\ .                      { ECHO; }                /* sekwencja ucieczki */
  \"                        { ECHO; BEGIN(INITIAL);} /* zamknięcie stringa */
  [^\n\\"]+                 { ECHO; }                /* zwykłe znaki */
  \n                        { ECHO; }                /* (niedozwolone w Py, ale przepuść) */
  .                         { ECHO; }                /* cokolwiek innego */
}

/* --- STAN: pojedynczo cudzysłowowy string '...' --- */
<S_SQ>{
  \\ .                      { ECHO; }
  \'                        { ECHO; BEGIN(INITIAL);}
  [^\n\\']+                 { ECHO; }
  \n                        { ECHO; }
  .                         { ECHO; }
}

/* --- STAN: potrójny string """...""" --- */
<S_TDQ>{
  \\ .                      { ECHO; }                /* sekwencje ucieczki */
  \"\"\"                    { ECHO; BEGIN(INITIAL);} /* koniec potrójnego */
  ""                        { ECHO; }                /* para cudzysłowów wewnątrz */
  "                         { ECHO; }                /* pojedynczy cudzysłów wewnątrz */
  [^\\"]+                   { ECHO; }                /* wszystko inne (w tym \n) */
  .                         { ECHO; }
}

/* --- STAN: potrójny string '''...''' --- */
<S_TSQ>{
  \\ .                      { ECHO; }
  \'\'\'                    { ECHO; BEGIN(INITIAL);}
  ''                        { ECHO; }
  '                         { ECHO; }
  [^\\']+                   { ECHO; }
  .                         { ECHO; }
}

<<EOF>>                     { return 0; }

%%

int main(void) {
    yylex();
    return 0;
}

