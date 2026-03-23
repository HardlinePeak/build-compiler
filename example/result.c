#include <stdio.h>

int main(void) {
    #define add_token(id) if (id != -1)\
        printf("%u\n", id);
    char * stream = "Example data — it is your variable.";
    // char * stream и add_token(unsigned int) — на ваше попечение и реализацию!
    unsigned int token;
    while (*stream != 0) {
        token = -1;
        if (stream[0] == 'E' && stream[1] == 'x' && stream[2] == 'a' && stream[3] == 'm' && stream[4] == 'p' && stream[5] == 'l' && stream[6] == 'e') {
            token = 0; 
            stream += 7;
        } else
        if (stream[0] == 't' && stream[1] == 'e' && stream[2] == 's' && stream[3] == 't') {
            token = 1; 
            stream += 4;
        } else
            stream++;
        if (token == 0 && stream[0] == ' ' && stream[1] == 'd' && stream[2] == 'a' && stream[3] == 't' && stream[4] == 'a') {
            token = 2; 
            stream += 5;
        } else
            stream++;
        add_token(token);
    }
}
