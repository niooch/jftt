%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

static long lineCount = 0;
static long wordCount = 0;

static void normalizeAndEmit(const char* text, int len){
    const char *p = text, *end = text + len;


