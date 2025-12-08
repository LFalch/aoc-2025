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

    fn dist_sq(a: Coord, b: Coord) f32 {
        const x: u64 = @max(a.x, b.x) - @min(a.x, b.x);
        const y: u64 = @max(a.y, b.y) - @min(a.y, b.y);
        const z: u64 = @max(a.z, b.z) - @min(a.z, b.z);

        return @floatFromInt(x * x + y * y + z * z);
    }
};
const Dist = struct {
    dist: f32,
    i: u16,
    j: u16,
};

const N: usize = 1000;

fn solve(ctx: aoc.Context) AnswerType {
    var f = ctx.file_data;

    var list = std.ArrayList(Coord).initCapacity(ctx.arena, 1000) catch unreachable;
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
    const del_size: []u16 = ctx.arena.alloc(u16, list.items.len) catch unreachable;
    @memset(del_size, 1);

    for (0..N) |smallest| {
        const dist = distances[smallest];
        const old = delegation[dist.j];
        const new = delegation[dist.i];
        if (new == old) continue;
        del_size[new] += del_size[old];
        del_size[old] = 0;

        for (delegation) |*d| {
            if (d.* == old) d.* = new;
        }
    }

    std.mem.sortUnstable(u16, del_size, {}, std.sort.desc(u16));

    var total: AnswerType = del_size[0];
    total *= del_size[1];
    total *= del_size[2];
    return total;
}
