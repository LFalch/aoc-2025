const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    try aoc.run_solution(u32, solve);
}

fn solve(ctx: aoc.Context) u32 {
    const fd = ctx.file_data;
    var sum: u32 = 0;

    const w = std.mem.indexOfScalar(u8, fd.file_data, '\n').? + 1;
    const h = fd.file_data.len / w;

    for (0..h) |y| {
        for (0..w - 1) |x| {
            if (fd.file_data[x + y * w] != '@')
                continue;

            var rolls: u8 = 0;

            for (y -| 1..@min(y + 2, h)) |y1| {
                for (x -| 1..x + 2) |x1| {
                    rolls += @intFromBool(fd.file_data[x1 + y1 * w] == '@');
                }
            }

            if (rolls < 5) {
                sum += 1;
            }
        }
    }

    return sum;
}
