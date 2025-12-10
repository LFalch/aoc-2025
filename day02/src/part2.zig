const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    try aoc.run_solution(u64, solve);
}

const FACTORS_FROM_DIGITS = [_][]const u64{
    &.{}, // 1
    &.{11}, // 2
    &.{111}, // 3
    &.{ 101, 1111 }, // 4
    &.{11111}, // 5
    &.{ 1001, 10101, 111111 }, // 6
    &.{1111111}, // 7
    &.{ 10001, 1010101, 11111111 }, // 8
    &.{ 1001001, 111111111 }, // 9
    &.{ 100001, 101010101, 1111111111 }, // 10
    &.{11111111111}, // 11
    &.{ 1000001, 100010001, 1001001001, 10101010101, 111111111111 }, // 12
    &.{1111111111111}, // 13
    &.{ 10000001, 1010101010101, 11111111111111 }, // 14
};

fn solve(ctx: aoc.Context) u64 {
    var f = ctx.file_data;

    var sum: u64 = 0;

    while (!f.is_done()) {
        const from = f.read_number(u64);
        std.debug.assert(f.accept("-"));
        const upto = f.read_number(u64);
        _ = f.accept(",");
        _ = f.read_space();

        const places_from = aoc.numPlaces(from);
        const places_to = aoc.numPlaces(upto);
        aoc.dbgPrint("{d}-{d}\n", .{ from, upto });
        if (places_from != places_to) {
            std.debug.assert(places_to == places_from + 1);

            for (from..aoc.pow10(places_from)) |n|
                for (FACTORS_FROM_DIGITS[places_from - 1]) |factor|
                    if (n % factor == 0) {
                        aoc.dbgPrint("  {d}\n", .{n});
                        sum += n;
                        break;
                    };
            for (aoc.pow10(places_from)..upto + 1) |n|
                for (FACTORS_FROM_DIGITS[places_to - 1]) |factor|
                    if (n % factor == 0) {
                        aoc.dbgPrint("  {d}\n", .{n});
                        sum += n;
                        break;
                    };
        } else {
            for (from..upto + 1) |n|
                for (FACTORS_FROM_DIGITS[places_from - 1]) |factor|
                    if (n % factor == 0) {
                        aoc.dbgPrint("  {d}\n", .{n});
                        sum += n;
                        break;
                    };
        }
    }

    return sum;
}
