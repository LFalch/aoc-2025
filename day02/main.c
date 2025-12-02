#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include <stdbool.h>
#include <sys/types.h>
#define _GNU_SOURCE 1
#define _DEFAULT_SOURCE 1

//   4174379265
// 455439374640

uint64_t numPlaces (uint64_t n);
uint64_t sumInvalids(uint64_t from, uint64_t to) {
    uint64_t sum = 0;
    for (uint64_t n = from; n <= to; n++) {
        uint32_t places = numPlaces(n);
        if (places % 2 == 0) {
            uint64_t digits = powl(10, places / 2);
            if (n / digits == n % digits) {
                sum += n;
            }
        }
    }
    return sum;
}
uint64_t sumInvalidsExt(uint64_t from, uint64_t to, uint64_t *simpleSum) {
    uint64_t sum = 0;
    for (uint64_t n = from; n <= to; n++) {
        uint32_t places = numPlaces(n);
        for (uint32_t pl = places / 2; pl > 0; pl--) {
            if (places % pl != 0) continue;
            uint32_t reps = places / pl;
            uint64_t digits = powl(10, pl);

            uint64_t val = n;
            uint32_t part = n % digits;

            bool invalid = true;
            for (uint32_t i = 1; i < reps; i++) {
                val /= digits;
                if (val % digits != part) {
                    invalid = false;
                    break;
                }
            }

            if (invalid) {
                if (pl == places / 2 && places % 2 == 0)
                    *simpleSum += n;
                sum += n;
                break;
            }
        }
    }
    return sum;
}

int main(int argc, char* argv[]) {
    FILE *f = fopen(argc > 1 ? argv[1] : "input.txt", "r");
    uint64_t invalidSum = 0, invalidSumExt = 0;
    do {
        uint64_t from, to;
        if (fscanf(f, "%lu-%lu", &from, &to) < 0) {
            fprintf(stderr, "aaaaaaaaa!");
            return -1;
        }
        // invalidSum += sumInvalids(from, to);
        invalidSumExt += sumInvalidsExt(from, to, &invalidSum);
    } while (fgetc(f) == ',');
    printf("invalidSum: %lu\n", invalidSum);
    printf("invalidSumExt: %lu\n", invalidSumExt);
}

uint64_t numPlaces (uint64_t n) {
    if (n < 10) return 1;
    if (n < 100) return 2;
    if (n < 1000) return 3;
    if (n < 10000) return 4;
    if (n < 100000) return 5;
    if (n < 1000000) return 6;
    if (n < 10000000) return 7;
    if (n < 100000000) return 8;
    if (n < 1000000000) return 9;
    return 9 + numPlaces(n / 1000000000);
}
