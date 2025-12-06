const std = @import("std");
const aoc = @import("aoc");

const AnswerType: type = u64;

pub fn main() !void {
    try aoc.run_solution(AnswerType, solve);
}

fn solve(ctx: aoc.Context) AnswerType {
    const fd = ctx.file_data;
    const width = std.mem.indexOfScalar(u8, fd.file_data, '\n').? + 1;

    var sum: AnswerType = 0;

    var problem_i: usize = 0;
    while (std.mem.indexOfAny(u8, fd.file_data[problem_i..], "+*")) |i| {
        problem_i += i;
        const num_width = std.mem.indexOfAny(u8, fd.file_data[problem_i + 1 ..], "+*") orelse fd.file_data.len - (problem_i + 1);

        switch (fd.file_data[problem_i]) {
            '+' => {
                var index = problem_i - width;

                while (true) {
                    var num: AnswerType = 0;
                    for (fd.file_data[index .. index + num_width]) |c| {
                        if (c == ' ') continue;
                        num = num * 10 + (c - '0');
                    }
                    sum += num;

                    if (index < width) break else index -= width;
                }
            },
            '*' => {
                var product: AnswerType = 1;
                var index = problem_i - width;

                while (true) {
                    var num: AnswerType = 0;
                    for (fd.file_data[index .. index + num_width]) |c| {
                        if (c == ' ') continue;
                        num = num * 10 + (c - '0');
                    }
                    product *= num;

                    if (index < width) break else index -= width;
                }

                sum += product;
            },
            else => unreachable,
        }

        problem_i += 1;
    }

    return sum;
}
