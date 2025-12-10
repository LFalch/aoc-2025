const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    try aoc.run_solution(u64, solve);
}

inline fn sumTo(n: u64) u64 {
    return (n * (n + 1)) / 2;
}

fn solve(ctx: aoc.Context) u64 {
    var f = ctx.file_data;

    var sum: u64 = 0;

    while (!f.is_done()) {
        const a = f.file_data.len;
        const from = f.read_number(u64);
        const from_pl: u8 = @intCast(a - f.file_data.len);
        std.debug.assert(f.accept("-"));
        const upto = f.read_number(u64);
        _ = f.accept(",");
        _ = f.read_space();

        var n = if (from_pl % 2 == 0) from else aoc.pow10(from_pl);
        if (n > upto) continue;

        const sum_before = sum;
        counter: switch (n) {
            10...99 => if (upto <= 99) {
                sum += 11 * (sumTo(upto / 11) - sumTo((n - 1) / 11));
            } else {
                sum += 11 * ((comptime sumTo(9)) - sumTo((n - 1) / 11));
                n = 1000;
                if (n < upto) continue :counter n;
            },
            1000...9999 => if (upto <= 9999) {
                sum += 101 * (sumTo(upto / 101) - sumTo((n - 1) / 101));
            } else {
                sum += 101 * ((comptime sumTo(9999 / 101)) - sumTo((n - 1) / 101));
                n = 100000;
                if (n < upto) continue :counter n;
            },
            100000...999999 => if (upto <= 999999) {
                sum += 1001 * (sumTo(upto / 1001) - sumTo((n - 1) / 1001));
            } else {
                sum += 1001 * ((comptime sumTo(999999 / 1001)) - sumTo((n - 1) / 1001));
                n = 10000000;
                if (n < upto) continue :counter n;
            },
            10000000...99999999 => if (upto <= 99999999) {
                sum += 10001 * (sumTo(upto / 10001) - sumTo((n - 1) / 10001));
            } else {
                sum += 10001 * ((comptime sumTo(99999999 / 10001)) - sumTo((n - 1) / 10001));
                n = 1000000000;
                if (n < upto) continue :counter n;
            },
            1000000000...9999999999 => if (upto <= 9999999999) {
                sum += 100001 * (sumTo(upto / 100001) - sumTo((n - 1) / 100001));
            } else {
                sum += 100001 * ((comptime sumTo(9999999999 / 100001)) - sumTo((n - 1) / 100001));
                n = 100000000000;
                if (n < upto) continue :counter n;
            },
            else => unreachable,
        }
        if (from_pl % 2 == 0) {
            aoc.dbgPrint("{d}-{d} #{d}\n", .{ from, upto, sum - sum_before });
        } else {
            aoc.dbgPrint("{d} ({d})-{d} #{d}\n", .{ from, aoc.pow10(from_pl), upto, sum - sum_before });
        }
    }

    return sum;
}
