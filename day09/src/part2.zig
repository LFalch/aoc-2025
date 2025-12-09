const std = @import("std");
const aoc = @import("aoc");

const AnswerType: type = u64;

pub fn main() !void {
    try aoc.run_solution(AnswerType, solve);
}

fn solve(ctx: aoc.Context) AnswerType {
    var f = ctx.file_data;
    var points = std.ArrayList(struct { u32, u32 }).empty;
    while (!f.is_done()) {
        const x = f.read_number(u32);
        _ = f.accept(",");
        const y = f.read_number(u32);
        _ = f.read_space();
        points.append(ctx.arena, .{ x, y }) catch unreachable;
    }
    var biggest: AnswerType = 0;
    for (points.items, 0..) |p, i| {
        p2_loop: for (points.items[i + 1 ..]) |p2| {
            const x, const X = min_max(p.@"0", p2.@"0");
            const y, const Y = min_max(p.@"1", p2.@"1");

            var px, var py = points.getLast();
            for (0..points.items.len) |next| {
                const nx, const ny = points.items[next];

                if (px == nx) {
                    if (x < px and px < X) {
                        const y_start, const y_end = min_max(py, ny);

                        if (y_end > y and y_start < Y) {
                            aoc.dbgPrint("skipping rectangle {d},{d} -- {d},{d} because of line {d},{d}-{d}\n", .{ x, y, X, Y, px, y_start, y_end });
                            continue :p2_loop;
                        }
                    }
                } else {
                    std.debug.assert(py == ny);
                    if (y < py and py < Y) {
                        const x_start, const x_end = min_max(px, nx);

                        if (x_end > x and x_start < X) {
                            aoc.dbgPrint("skipping rectangle {d},{d} -- {d},{d} because of line {d}-{d},{d}\n", .{ x, y, X, Y, py, x_start, x_end });
                            continue :p2_loop;
                        }
                    }
                }
                px, py = .{ nx, ny };
            }

            const area = @as(u64, (X - x + 1)) * (Y - y + 1);
            biggest = @max(biggest, area);
        }
    }

    return biggest;
}

inline fn min_max(a: anytype, b: anytype) struct { @TypeOf(a, b), @TypeOf(a, b) } {
    return if (a < b) .{ a, b } else .{ b, a };
}
inline fn abs_sub(a: anytype, b: anytype) @TypeOf(a, b) {
    const max, const min = min_max(a, b);
    return max - min;
}
