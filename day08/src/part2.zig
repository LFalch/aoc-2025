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

    fn dist_sq(a: Coord, b: Coord) f32 {
        const x: u64 = @max(a.x, b.x) - @min(a.x, b.x);
        const y: u64 = @max(a.y, b.y) - @min(a.y, b.y);
        const z: u64 = @max(a.z, b.z) - @min(a.z, b.z);

        return @floatFromInt(x * x + y * y + z * z);
    }
};
const Dist = struct {
    // float because its smaller the indeces fit in its alignment, using u64 was slower
    dist: f32,
    i: u16,
    j: u16,
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

    const distances = ctx.arena.alloc(Dist, ((list.items.len + 1) * list.items.len) / 2 - list.items.len) catch unreachable;
    {
        var index: usize = 0;
        for (0.., list.items[0 .. list.items.len - 1]) |i, a|
            for (i + 1.., list.items[i + 1 ..]) |j, b| {
                distances[index] = .{
                    .i = @intCast(i),
                    .j = @intCast(j),
                    .dist = a.dist_sq(b),
                };
                index += 1;
            };
    }
    std.mem.sortUnstable(Dist, distances, {}, struct {
        fn lt(_: void, a: Dist, b: Dist) bool {
            return a.dist < b.dist;
        }
    }.lt);

    const delegation: []u16 = ctx.arena.alloc(u16, list.items.len) catch unreachable;
    for (0.., delegation) |i, *d|
        d.* = @intCast(i);

    var last_pair: struct { u16, u16 } = undefined;

    for (distances) |smallest| {
        last_pair = .{ smallest.i, smallest.j };

        const old = delegation[smallest.j];
        const new = delegation[smallest.i];

        for (delegation) |*d| {
            if (d.* == old)
                d.* = new;
        }
        if (std.mem.allEqual(u16, delegation, new)) break;
    }
    const i, const j = last_pair;

    return @as(u64, list.items[i].x) * @as(u64, list.items[j].x);
}
