const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    try aoc.run_solution(u64, solve);
}

fn solve(ctx: aoc.Context) u64 {
    var f = ctx.file_data;

    var froms = std.ArrayList(u64).initCapacity(ctx.arena, 256) catch unreachable;
    var tos = std.ArrayList(u64).initCapacity(ctx.arena, 256) catch unreachable;
    while (true) {
        const from = f.read_number(u64);
        if (from == 0) break;
        froms.append(ctx.arena, from) catch unreachable;

        std.debug.assert(f.accept("-"));
        const to = f.read_number(u64);
        tos.append(ctx.arena, to) catch unreachable;
        _ = f.accept("\n");
    }

    std.mem.sort(u64, froms.items, {}, less_than);
    std.mem.sort(u64, tos.items, {}, less_than);

    var i: usize = 0;
    var fresh_count: u64 = 0;

    while (i < froms.items.len) {
        const from = froms.items[i];
        var to = tos.items[i];

        i += 1;
        while (i < froms.items.len and to >= froms.items[i]) {
            to = tos.items[i];
            i += 1;
        }
        fresh_count += to - from + 1;
    }

    return fresh_count;
}

fn less_than(_: void, a: u64, b: u64) bool {
    return a < b;
}
