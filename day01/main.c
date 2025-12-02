#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>

int turnDial(int dial, int turn, char direction, int *clicks) {
    if (direction == 'R') {
        *clicks += (dial + turn) / 100;
        return (dial + turn) % 100;
    } else if (direction == 'L') {
        *clicks += (dial - turn) / -100 + (turn >= dial) - (dial == 0);
        return (dial + 100 - (turn % 100)) % 100;
    }

    fprintf(stderr, "bad direction!");
    return -1;
}

int main(int argc, char* argv[]) {
    char *path = argc > 1 ? argv[1] : "input.txt"; 
    FILE *f = fopen(path, "r");

    int dial = 50;

    char l;
    int turn, countZ = 0, countClick = 0;
    while (fscanf(f, "%c%d\n", &l, &turn) != EOF) {
        dial = turnDial(dial, turn, l, &countClick);
        dial = (dial + (turn / 100 + 1) * 100) % 100;
        if (dial == 0) countZ++;
    }

    printf("count zero: %d\n", countZ);
    printf("count click: %d\n", countClick);
    fclose(f);
}
