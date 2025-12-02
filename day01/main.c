#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>

int turnDial(int dial, int turn, char direction, int *clicks) {
    if (direction == 'R') {
        for (int i = 0; i < turn; i++) {
            dial = (dial + 1) % 100;
            if (dial == 0) *clicks += 1;
        }
    } else if (direction == 'L') {
        for (int i = 0; i < turn; i++) {
            dial = (dial + 99) % 100;
            if (dial == 0) *clicks += 1;
        }
    } else
        printf(stderr, "bad directoin!");

    return dial;
}

int main(int argc, char* argv[]) {
    char *path = argc > 1 ? argv[1] : "input.txt"; 
    FILE *f = fopen(path, "r");

    int dial = 50;

    char l;
    int turn, countZ = 0, countClick = 0;
    while (fscanf(f, "%c%d\n", &l, &turn) != EOF) {
        printf("%c%d   ", l, turn);
        int clicks = 0;
        dial = turnDial(dial, turn, l, &clicks);
        if (clicks > 0) {
            countClick += clicks;
            printf("%d! ", clicks);
        }
        dial = (dial + (turn / 100 + 1) * 100) % 100;
        if (dial == 0) countZ++;
        printf("-> %d\n", dial);
    }

    printf("count zero: %d\n", countZ);
    printf("count click: %d\n", countClick);
    fclose(f);
}
