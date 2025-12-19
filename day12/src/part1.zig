const std = @import("std");
const aoc = @import("aoc");

const AnswerType: type = u32;

pub fn main() !void {
    try aoc.run_solution(AnswerType, solve);
}

const Present = std.bit_set.IntegerBitSet(9);

fn solve(ctx: aoc.Context) AnswerType {
    var f = ctx.file_data;
    var presents: [6]Present = undefined;

    while (true) {
        const f_before = f;
        const index = f.read_number(u8);
        if (!f.accept(":\n")) {
            f = f_before;
            break;
        }
        const present = &presents[index];
        present.* = .initEmpty();

        for (0..9) |space| {
            const set = f.accept("#");
            if (set) {
                present.set(space);
            } else std.debug.assert(f.accept("."));
            if (space % 3 == 2) std.debug.assert(f.accept("\n"));
        }

        _ = f.read_space();
    }

    var total: AnswerType = 0;
    while (!f.is_done()) {
        const n = f.read_number(u8);
        std.debug.assert(f.accept("x"));
        const m = f.read_number(u8);
        std.debug.assert(f.accept(":"));
        var present_amount: [6]u8 = undefined;
        for (&present_amount) |*pa| {
            std.debug.assert(f.accept(" "));
            pa.* = f.read_number(u8);
        }
        _ = f.read_space();

        if (doTheyFit(presents, n, m, present_amount)) total += 1;
    }

    return total;
}

fn doTheyFit(presents: [6]Present, n: u8, m: u8, amounts: [6]u8) bool {
    var area = @as(u16, n) * m;
    for (presents, amounts) |p, a| {
        area = std.math.sub(u16, area, @intCast(p.count() * a)) catch return false;
    }
    aoc.dbgPrint("just about with {d} to spare\n", .{area});
    return true;
}
