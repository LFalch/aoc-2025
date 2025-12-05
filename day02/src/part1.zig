const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    try aoc.run_solution(u64, solve);
}

fn solve(ctx: aoc.Context) u64 {
    var f = ctx.file_data;

    var sum: u64 = 0;

    while (!f.is_done()) {
        const from = f.read_number(u64);
        std.debug.assert(f.accept("-"));
        const to = f.read_number(u64);
        _ = f.accept(",");
        _ = f.read_space();

        for (from..to + 1) |n| {
            const places = aoc.numPlaces(n);
            if (places % 2 == 0) {
                const pl = places / 2;
                const digits = aoc.pow10(pl);

                if (n / digits == n % digits) {
                    sum += n;
                }
            }
        }
    }

    return sum;
}
