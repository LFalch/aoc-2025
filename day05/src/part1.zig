const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    try aoc.main_with_bench(u32, {}, solve);
}

var buf: [8 * 512 + 8 * 1024]u8 = undefined;

fn solve(fd: aoc.FileData, _: void) u32 {
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    const alloc = fba.allocator();
    var f = fd;

    var froms = std.ArrayList(u64).initCapacity(alloc, 256) catch unreachable;
    var tos = std.ArrayList(u64).initCapacity(alloc, 256) catch unreachable;
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

    var ingredients = std.ArrayList(u64).initCapacity(alloc, 1024) catch unreachable;
    while (true) {
        const ingredient = f.read_number(u64);
        if (ingredient == 0) break;
        _ = f.read_space();
        ingredients.append(alloc, ingredient) catch unreachable;
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
