const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    try aoc.run_solution(u32, solve);
}

fn solve(ctx: aoc.Context) u32 {
    const fd = ctx.file_data;
    var sum: u32 = 0;

    const board = ctx.arena.alloc(u8, fd.file_data.len) catch unreachable;
    const board2 = ctx.arena.alloc(u8, fd.file_data.len) catch unreachable;
    @memcpy(board, fd.file_data);
    @memcpy(board2, fd.file_data);

    const w = std.mem.indexOfScalar(u8, board, '\n').? + 1;
    const h = board.len / w;

    var removeRolls = true;

    while (removeRolls) {
        removeRolls = false;
        for (0..h) |y| {
            for (0..w - 1) |x| {
                if (board[x + y * w] != '@')
                    continue;

                var rolls: u8 = 0;

                for (y -| 1..@min(y + 2, h)) |y1| {
                    for (x -| 1..x + 2) |x1| {
                        rolls += @intFromBool(board[x1 + y1 * w] == '@');
                    }
                }

                if (rolls < 5) {
                    sum += 1;
                    removeRolls = true;
                    board2[x + y * w] = '.';
                }
            }
        }
        @memcpy(board, board2);
    }

    return sum;
}
