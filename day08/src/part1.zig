const std = @import("std");
const aoc = @import("aoc");

const AnswerType: type = u32;

pub fn main() !void {
    try aoc.run_solution(AnswerType, solve);
}

const Coord = struct {
    x: u32,
    y: u32,
    z: u32,

    fn dist_sq(a: Coord, b: Coord) u64 {
        const x: u64 = @max(a.x, b.x) - @min(a.x, b.x);
        const y: u64 = @max(a.y, b.y) - @min(a.y, b.y);
        const z: u64 = @max(a.z, b.z) - @min(a.z, b.z);

        return x * x + y * y + z * z;
    }
};

const N: usize = 1000;

fn solve(ctx: aoc.Context) AnswerType {
    var f = ctx.file_data;

    var list = std.ArrayList(Coord).initCapacity(ctx.arena, 1024) catch unreachable;
    while (!f.is_done()) {
        const x = f.read_number(u32);
        std.debug.assert(f.accept(","));
        const y = f.read_number(u32);
        std.debug.assert(f.accept(","));
        const z = f.read_number(u32);
        std.debug.assert(f.read_space());
        list.append(ctx.arena, .{ .x = x, .y = y, .z = z }) catch unreachable;
    }
    const delegation: []u16 = ctx.arena.alloc(u16, list.items.len) catch unreachable;
    for (0.., delegation) |i, *d|
        d.* = @intCast(i);
    const del_size: []u16 = ctx.arena.alloc(u16, list.items.len) catch unreachable;
    @memset(del_size, 1);
    var checked_connections = std.AutoArrayHashMap(struct { u16, u16 }, void).init(ctx.arena);

    for (0..N) |_| {
        var smallest: struct {
            dist: u64,
            i: u16,
            j: u16,
        } = .{ .dist = std.math.maxInt(u64), .i = 0, .j = 0 };

        for (0.., list.items[0 .. list.items.len - 1]) |i, a|
            for (list.items[i + 1 ..], i + 1..) |b, j|
                if (!checked_connections.contains(.{ @intCast(i), @intCast(j) })) {
                    const dist = a.dist_sq(b);
                    if (dist < smallest.dist)
                        smallest = .{ .dist = dist, .i = @intCast(i), .j = @intCast(j) };
                };

        checked_connections.put(.{ smallest.i, smallest.j }, {}) catch unreachable;

        const old = delegation[smallest.j];
        const new = delegation[smallest.i];
        if (new == old) continue;
        del_size[new] += del_size[old];
        del_size[old] = 0;

        for (delegation) |*d| {
            if (d.* == old) d.* = new;
        }
    }

    var found: usize = 0;
    var biggest: [3]u16 = undefined;
    for (0.., del_size) |d, s| {
        var i: usize = 0;
        while (i < found) : (i += 1) {
            if (s > del_size[biggest[i]]) break;
        }
        if (i < biggest.len) {
            if (found < biggest.len) found += 1;
            if (i < found)
                @memmove(biggest[i + 1 .. found], biggest[i .. found - 1]);
            biggest[i] = @intCast(d);
        }
    }

    var total: AnswerType = 1;
    for (biggest) |b| {
        total *= del_size[b];
    }
    return total;
}
