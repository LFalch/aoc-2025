const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    try aoc.run_solution(u32, solve);
}

fn solve(ctx: aoc.Context) u32 {
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
    _ = f.read_space();

    std.mem.sort(u64, froms.items, {}, less_than);
    std.mem.sort(u64, tos.items, {}, less_than);

    var ingredients = std.ArrayList(u64).initCapacity(ctx.arena, 1024) catch unreachable;
    while (true) {
        const ingredient = f.read_number(u64);
        if (ingredient == 0) break;
        _ = f.read_space();
        ingredients.append(ctx.arena, ingredient) catch unreachable;
    }
    std.mem.sort(u64, ingredients.items, {}, less_than);

    var fresh_count: u32 = 0;
    var i_int: usize = 0;
    outer: for (ingredients.items) |ingredient| {
        while (ingredient > tos.items[i_int]) {
            i_int += 1;
            if (i_int >= tos.items.len) break :outer;
        }
        if (ingredient >= froms.items[i_int]) {
            fresh_count += 1;
        }
    }

    return fresh_count;
}

fn less_than(_: void, a: u64, b: u64) bool {
    return a < b;
}
