const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    try aoc.main_with_bench(u32, {}, solve);
}

fn solve(fd: aoc.FileData, _: void) u32 {
    var f = fd;

    var dial: i32 = 50;
    var countZ: u32 = 0;

    while (!f.is_done()) {
        const dir: enum { left, right } = if (f.accept("L")) .left else if (f.accept("R")) .right else unreachable;
        const turn = f.read_number(i32);
        _ = f.read_space();

        dial = switch (dir) {
            .left => @mod(dial + turn, 100),
            .right => @mod(dial + 100 - @mod(turn, 100), 100),
        };
        if (dial == 0) countZ += 1;
    }

    return countZ;
}
