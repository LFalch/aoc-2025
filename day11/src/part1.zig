const std = @import("std");
const aoc = @import("aoc");

const AnswerType: type = u32;

pub fn main() !void {
    try aoc.run_solution(AnswerType, solve);
}

const YOU = a_to_z_to_num("you");
const OUT = a_to_z_to_num("out");

fn solve(ctx: aoc.Context) AnswerType {
    var f = ctx.file_data;

    var devs = std.AutoArrayHashMapUnmanaged(u16, []const u16).empty;
    devs.ensureTotalCapacity(ctx.arena, 1024) catch unreachable;

    while (!f.is_done()) {
        const label = f.file_data[0..3];
        f.file_data = f.file_data[3..];
        const id = a_to_z_to_num(label);
        std.debug.assert(f.accept(":"));

        var out_ids = std.ArrayList(u16).empty;

        while (!f.read_space()) {
            const out_label = f.file_data[0..3];
            f.file_data = f.file_data[3..];
            out_ids.append(ctx.arena, a_to_z_to_num(out_label[0..])) catch unreachable;
        }

        const slice = out_ids.toOwnedSlice(ctx.arena) catch unreachable;
        devs.put(ctx.arena, id, slice) catch unreachable;
    }

    return path_find(&devs, YOU);
}

fn path_find(devs: *const std.AutoArrayHashMapUnmanaged(u16, []const u16), from: u16) u32 {
    var sum: u32 = 0;
    for (devs.get(from).?) |neighbour| {
        aoc.dbgPrint("{d}->{d}\n", .{ from, neighbour });
        if (neighbour == OUT) sum += 1 else sum += path_find(devs, neighbour);
    }
    return sum;
}

fn a_to_z_to_num(ascii: []const u8) u16 {
    var num: u16 = 0;
    for (ascii) |c| {
        num *= ('z' - 'a' + 1);
        num += c - 'a';
    }
    return num;
}
