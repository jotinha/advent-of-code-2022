#include <stdio.h>
#include <stdlib.h>

int decode(char code) {
    // if A or X ->1, B or Y -> 2, C or Z -> 3
    return (code - 'A') % 23 + 1;
}
int pick2(int code1, char strategy) {
    if (strategy == 'Y') { // draw
        return code1;
    } else if (strategy == 'Z') { // win
        //1->2 2->3 3->1       
        return code1 % 3 + 1; 
    } else { // lose
        //1->3 2->1 3->2
        return (code1+1) % 3 + 1;
    }
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
    char code1, code2, strategy ;
    int total = 0;
 
    FILE *fp;
    if ((fp = fopen("input","rt")) == NULL) {
        exit(1);    
    }

    //while(fgets(line,8,fp) != NULL) {
    while(fscanf(fp, "%c %c\n", &code1, &strategy) == 2) {
        code1 = decode(code1);
        code2 = pick2(code1, strategy);
        int outcome = play(code1, code2);
        int points = code2 + outcome * 3;
        printf("%d %d %d %d\n", code1, code2, outcome, points);
        total += points;
    }
    printf("Total points: %d\n", total);
    
}

