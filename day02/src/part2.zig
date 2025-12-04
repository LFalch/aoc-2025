const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    try aoc.main_with_bench(u64, {}, solve);
}

fn solve(fd: aoc.FileData, _: void) u64 {
    var f = fd;

    var sum: u64 = 0;

    while (!f.is_done()) {
        const from = f.read_number(u64);
        std.debug.assert(f.accept("-"));
        const to = f.read_number(u64);
        _ = f.accept(",");
        _ = f.read_space();

        for (from..to + 1) |n| {
            const places = aoc.numPlaces(n);
            var pl = places / 2;
            while (pl > 0) : (pl -= 1) {
                if (places % pl != 0) continue;
                const reps = places / pl;
                const digits = aoc.pow10(pl);

                const part = n % digits;

                var val = n;
                var invalid = true;
                for (1..reps) |_| {
                    val /= digits;
                    if (val % digits != part) {
                        invalid = false;
                        break;
                    }
                }
                if (invalid) {
                    sum += n;
                    break;
                }
            }
        }
    }

    return sum;
}
