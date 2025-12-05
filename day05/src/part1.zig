const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();
    try aoc.main_with_bench(u32, .{gpa.allocator()}, solve);
}

fn solve(fd: aoc.FileData, ctx: struct { std.mem.Allocator }) u32 {
    const alloc = ctx[0];
    var f = fd;

    var froms = std.ArrayList(u64).initCapacity(alloc, 256) catch unreachable;
    defer froms.deinit(alloc);
    var tos = std.ArrayList(u64).initCapacity(alloc, 256) catch unreachable;
    defer tos.deinit(alloc);
    while (true) {
        const from = f.read_number(u64);
        if (from == 0) break;
        froms.append(alloc, from) catch unreachable;

        std.debug.assert(f.accept("-"));
        const to = f.read_number(u64);
        tos.append(alloc, to) catch unreachable;
        _ = f.accept("\n");
    }
    _ = f.read_space();

    std.mem.sort(u64, froms.items, {}, less_than);
    std.mem.sort(u64, tos.items, {}, less_than);

    var fresh_count: u32 = 0;
    while (true) {
        const ingredient = f.read_number(u64);
        if (ingredient == 0) break;
        _ = f.read_space();
        for (froms.items, tos.items) |from, to| {
            if (ingredient >= from and ingredient <= to) {
                fresh_count += 1;
                break;
            } else if (ingredient < from)
                break;
        }
    }

    return fresh_count;
}

fn less_than(_: void, a: u64, b: u64) bool {
    return a < b;
}
