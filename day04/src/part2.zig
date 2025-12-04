const std = @import("std");
const aoc = @import("aoc");

pub fn main() !void {
    try aoc.main_with_bench(u32, {}, solve);
}

var buf1: [32 * 1024]u8 = undefined;
var buf2: [32 * 1024]u8 = undefined;

fn solve(fd: aoc.FileData, _: void) u32 {
    var sum: u32 = 0;

    const board = buf1[0..fd.file_data.len];
    const board2 = buf2[0..fd.file_data.len];
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

                for (subSaturating(y, 1)..@min(y + 2, h)) |y1| {
                    for (subSaturating(x, 1)..x + 2) |x1| {
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

fn subSaturating(a: anytype, b: anytype) @TypeOf(a, b) {
    const res, const overflow = @subWithOverflow(a, b);
    if (overflow == 1) return 0 else return res;
}
