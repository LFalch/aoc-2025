const std = @import("std");
const aoc = @import("aoc");

const AnswerType: type = u64;

pub fn main() !void {
    try aoc.run_solution(AnswerType, solve);
}

fn solve(ctx: aoc.Context) AnswerType {
    const fd = ctx.file_data.file_data;

    const w = std.mem.indexOfScalar(u8, fd, '\n').? + 1;

    var total: AnswerType = 1;

    const beams = ctx.arena.alloc(u64, w - 1) catch unreachable;
    @memset(beams, 0);
    const old_beams = ctx.arena.alloc(u64, beams.len) catch unreachable;

    const start_tachyon = std.mem.indexOfScalar(u8, fd[0..w], 'S').?;
    beams[start_tachyon] = 1;

    var y_offset = w;
    while (y_offset < fd.len) : (y_offset += w) {
        @memcpy(old_beams, beams);
        for (old_beams, 0..) |beam_amt, i| {
            if (beam_amt == 0) continue;

            if (fd[y_offset + i] == '^') {
                beams[i - 1] += beam_amt;
                beams[i] -= beam_amt;
                beams[i + 1] += beam_amt;
                total += beam_amt;
            }
        }
    }

    return total;
}
