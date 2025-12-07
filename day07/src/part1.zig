const std = @import("std");
const aoc = @import("aoc");

const AnswerType: type = u32;

pub fn main() !void {
    try aoc.run_solution(AnswerType, solve);
}

fn solve(ctx: aoc.Context) AnswerType {
    const fd = ctx.file_data.file_data;

    const w = std.mem.indexOfScalar(u8, fd, '\n').? + 1;
    const h = fd.len / w;

    var total: AnswerType = 0;

    var beams = std.bit_set.ArrayBitSet(usize, 256).initEmpty();

    const start_tachyon = std.mem.indexOfScalar(u8, fd[0..w], 'S').?;
    beams.set(start_tachyon);

    for (1..h) |y| {
        const line = fd[y * w ..][0..w];

        const old_beams = beams;
        var iterator = old_beams.iterator(.{});
        while (iterator.next()) |beam| {
            if (line[beam] == '^') {
                total += 1;
                beams.unset(beam);
                beams.set(beam - 1);
                beams.set(beam + 1);
            }
        }
    }

    return total;
}
