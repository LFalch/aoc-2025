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
                for (0..num_width) |j| {
                    var index: usize = problem_i + j - width;
                    var digit: AnswerType = 1;

                    while (true) {
                        const c = fd.file_data[index];
                        if (c != ' ') {
                            sum += digit * (c - '0');
                            digit *= 10;
                        }

                        if (index < width) break else index -= width;
                    }
                }
            },
            '*' => {
                var product: AnswerType = 1;
                for (0..num_width) |j| {
                    var num: AnswerType = 0;

                    var index: usize = problem_i + j - width;
                    var digit: AnswerType = 1;
                    while (true) {
                        const c = fd.file_data[index];
                        if (c != ' ') {
                            num += digit * (c - '0');
                            digit *= 10;
                        }

                        if (index < width) break else index -= width;
                    }

                    product *= num;
                }
                sum += product;
            },
            else => unreachable,
        }

        problem_i += 1;
    }

    return sum;
}
