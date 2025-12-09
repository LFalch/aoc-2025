const std = @import("std");
const aoc = @import("aoc");

const AnswerType: type = u64;

pub fn main() !void {
    try aoc.run_solution(AnswerType, solve);
}

fn solve(ctx: aoc.Context) AnswerType {
    var f = ctx.file_data;
    var points = std.ArrayList(struct { u32, u32 }).empty;
    while (!f.is_done()) {
        const x = f.read_number(u32);
        _ = f.accept(",");
        const y = f.read_number(u32);
        _ = f.read_space();
        points.append(ctx.arena, .{ x, y }) catch unreachable;
    }
    var biggest: AnswerType = 0;
    for (points.items, 0..) |p, i| {
        for (points.items[i + 1 ..]) |p2| {
            const area = @as(u64, (abs_sub(p.@"0", p2.@"0") + 1)) * (abs_sub(p.@"1", p2.@"1") + 1);
            biggest = @max(biggest, area);
        }
    }

    return biggest;
}

inline fn abs_sub(x: anytype, y: anytype) @TypeOf(x, y) {
    return if (x > y) x - y else y - x;
}
