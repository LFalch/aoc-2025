const std = @import("std");
const aoc = @import("aoc");

const AnswerType: type = u32;

pub fn main() !void {
    try aoc.run_solution(AnswerType, solve);
}

fn solve(ctx: aoc.Context) AnswerType {
    var f = ctx.file_data;
    var sum: AnswerType = 0;
    sum += f.read_number(AnswerType);
    // READ DATA
    // CALCULATE RESULT
    return sum;
}
