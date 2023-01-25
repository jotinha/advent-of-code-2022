#include <stdio.h>
#include <stdlib.h>

int decode(char c) {
    // if A or X ->1, B or Y -> 2, C or Z -> 3
    return (c - 'A') % 23 + 1;
}

int pick2(int code1, int strategy) {
    return 
        strategy == 2 ? code1 : // Y draw
        strategy == 3 ? code1 % 3 + 1 : // Z win (1->2 2->3 3->1)
        strategy == 1 ? (code1+1) % 3 + 1 : // X lose (1->3 2->1 3->2)
        -1;
}

int play(int a, int b) {
    // 0 if losing, 1 if draw, 2 if win
    int diff = (b-a);
    return
        diff == 2 ? 0 : // scisors loses to rock
        diff == -2 ? 2 : // rocks beats scisors 
        diff+1;
}

int score(int code1, int code2) {
    return code2 + play(code1,code2) * 3;
}

int main(void) {
    //printf("Hello world\n");

    char c1, c2;
    int ans1 = 0, ans2= 0;
 
    FILE *fp;
    if ((fp = fopen("input","rt")) == NULL) {
        exit(1);    
    }

    //while(fgets(line,8,fp) != NULL) {
    while(fscanf(fp, "%c %c\n", &c1, &c2) == 2) {
        int code1 = decode(c1);
        int code2 = decode(c2);
        ans1 += score(code1, code2);
        ans2 += score(code1, pick2(code1, code2));
    }
    printf("%d,%d\n", ans1, ans2);

    fclose(fp); 
}

