#include <stdio.h>
#include <stdlib.h>

int decode1(char code) {
    return code - 'A' + 1;
}

int decode2(char code) {
    return code - 'X' + 1;
}

int play(int a, int b) {
    // 0 if losing, 1 if draw, 2 if win

    int diff = (b-a);
    if (diff == 2) { // sciscors loses to rock
        return 0;
    } else if (diff == -2) { // rocks beats scisors
        return 2;
    } else {
        return diff+1;
    }
}

int main(void) {
    printf("Hello world\n");

    char line[8];
    char code1, code2;
    int total = 0;
 
    FILE *fp;
    if ((fp = fopen("input","rt")) == NULL) {
        exit(1);    
    }

    //while(fgets(line,8,fp) != NULL) {
    while(fscanf(fp, "%c %c\n", &code1, &code2) == 2) {
        code1 = decode1(code1);
        code2 = decode2(code2);
        int outcome = play(code1, code2);
        int points = code2 + outcome * 3;
        printf("%d %d %d %d\n", code1, code2, outcome, points);
        total += points;
    }
    printf("Total points: %d\n", total);
    
}

