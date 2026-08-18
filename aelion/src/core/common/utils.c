#include "utils.h"
#include <ctype.h>
#include <string.h>

void trim(char* str) {
    int len = strlen(str);
    while(len > 0 && str[len-1] == ' ') len--;
    str[len] = '\0';
}

void lowercase(char* str) {
    for(int i=0; str[i]; i++)
        str[i] = tolower(str[i]);
}
