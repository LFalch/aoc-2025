const std = @import("std");
const aoc = @import("aoc");
const main_lib = @import("main.zig");

pub fn main() !void {
    try aoc.run_solution(u64, solve);
}

fn solve(ctx: aoc.Context) u64 {
    const fd = ctx.file_data;
    var sum: u64 = 0;

    var lines = std.mem.splitScalar(u8, fd.file_data, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        sum += main_lib.findBestJoltageNaryTuple(line, 12) catch unreachable;
    }

    return sum;
}
