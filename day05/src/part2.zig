const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    try aoc.main_with_bench(u64, {}, solve);
}

var buf: [4096]u8 = undefined;

fn solve(fd: aoc.FileData, _: void) u64 {
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
