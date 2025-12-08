const std = @import("std");
const aoc = @import("aoc");

const AnswerType: type = u64;

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

    var last_pair: struct { u16, u16 } = undefined;

    while (true) {
        var smallest: struct {
            dist: u64,
            i: u16,
            j: u16,
        } = .{ .dist = std.math.maxInt(u64), .i = 0, .j = 0 };

        for (0.., list.items[0 .. list.items.len - 1]) |i, a|
            for (list.items[i + 1 ..], i + 1..) |b, j|
                if (delegation[i] != delegation[j]) {
                    const dist = a.dist_sq(b);
                    if (dist < smallest.dist)
                        smallest = .{ .dist = dist, .i = @intCast(i), .j = @intCast(j) };
                };

        if (smallest.i == 0 and smallest.j == 0) break;

        last_pair = .{ smallest.i, smallest.j };

        const old = delegation[smallest.j];
        const new = delegation[smallest.i];

        for (delegation) |*d| {
            if (d.* == old) d.* = new;
        }
    }
    const i, const j = last_pair;

    return @as(u64, list.items[i].x) * @as(u64, list.items[j].x);
}
