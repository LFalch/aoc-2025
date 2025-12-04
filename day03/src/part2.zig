const std = @import("std");
const aoc = @import("aoc");
const main_lib = @import("main.zig");

pub fn main() !void {
    try aoc.main_with_bench(u64, {}, solve);
}

fn solve(fd: aoc.FileData, _: void) u64 {
    var sum: u64 = 0;

    var lines = std.mem.splitScalar(u8, fd.file_data, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        sum += main_lib.findBestJoltageNaryTuple(line, 12) catch unreachable;
    }

    return sum;
}
