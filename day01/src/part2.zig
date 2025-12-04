const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    try aoc.main_with_bench(u32, {}, solve);
}

fn solve(fd: aoc.FileData, _: void) u32 {
    var f = fd;

    var dial: i32 = 50;
    var countClicks: u32 = 0;

    while (!f.is_done()) {
        const dir: enum { left, right } = if (f.accept("L")) .left else if (f.accept("R")) .right else unreachable;
        const turn = f.read_number(i32);
        _ = f.read_space();

        dial = d: switch (dir) {
            .left => {
                countClicks += @intCast(@divTrunc(dial + turn, 100));
                break :d @mod(dial + turn, 100);
            },
            .right => {
                countClicks += @intCast(@divTrunc(dial - turn, -100) + @intFromBool(turn >= dial) - @intFromBool(dial == 0));
                break :d @mod(dial + 100 - @mod(turn, 100), 100);
            },
        };
    }

    return countClicks;
}
