const std = @import("std");
const aoc = @import("aoc");

const AnswerType: type = u64;

pub fn main() !void {
    try aoc.run_solution(AnswerType, solve);
}

fn solve(ctx: aoc.Context) AnswerType {
    var f = ctx.file_data;
    var list = std.ArrayList(AnswerType).empty;
    var num_cols: usize = 0;

    while (true) {
        _ = f.read_space();
        const n = f.read_number(AnswerType);
        if (n == 0) break;
        list.append(ctx.arena, n) catch unreachable;
        if (f.accept("\n") and num_cols == 0) {
            num_cols = list.items.len;
        }
    }
    _ = f.read_space();
    var sum: AnswerType = 0;
    for (0..num_cols) |i| {
        if (f.accept("+")) {
            var j: usize = i;
            while (j < list.items.len) : (j += num_cols) {
                sum += list.items[j];
            }
        } else if (f.accept("*")) {
            var product: AnswerType = 1;
            var j: usize = i;
            while (j < list.items.len) : (j += num_cols) {
                product *= list.items[j];
            }
            sum += product;
        } else unreachable;
        _ = f.read_space();
    }
    return sum;
}
