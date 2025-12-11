const std = @import("std");
const aoc = @import("aoc");

const AnswerType: type = u64;

pub fn main() !void {
    try aoc.run_solution(AnswerType, solve);
}

const SVR = a_to_z_to_num("svr");
const DAC = a_to_z_to_num("dac");
const FFT = a_to_z_to_num("fft");
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
    var memoisation_table = Table.init(ctx.arena);

    return path_find(&memoisation_table, &devs, SVR, false, false);
}

const Table = std.AutoArrayHashMap(Args, u64);
const Args = struct {
    from: u16,
    dac_visited: bool,
    fft_visited: bool,
};

fn path_find(table: *Table, devs: *const std.AutoArrayHashMapUnmanaged(u16, []const u16), from: u16, dac_visited: bool, fft_visited: bool) AnswerType {
    if (table.get(.{ .from = from, .dac_visited = dac_visited, .fft_visited = fft_visited })) |v| {
        aoc.dbgPrint(":))) {d} #{d}\n", .{ from, v });

        return v;
    }

    const neighbours = devs.get(from).?;

    var sum: AnswerType = 0;
    for (neighbours) |neighbour| {
        const dac = dac_visited or neighbour == DAC;
        const fft = fft_visited or neighbour == FFT;

        aoc.dbgPrint("{d}->{d} {} {}\n", .{ from, neighbour, dac, fft });

        if (neighbour == OUT) {
            if (dac and fft) sum += 1;
        } else sum += path_find(table, devs, neighbour, dac, fft);
    }
    table.put(.{ .from = from, .dac_visited = dac_visited, .fft_visited = fft_visited }, sum) catch unreachable;
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
