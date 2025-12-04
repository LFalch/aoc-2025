const std = @import("std");

fn openInput() !std.fs.File {
    var args = std.process.args();
    _ = args.skip();
    const path = args.next() orelse "input.txt";
    return std.fs.cwd().openFile(path, .{});
}

pub fn main() !void {
    const input = try openInput();
    defer input.close();
    var buf: [4096]u8 = undefined;
    var reader = input.reader(&buf);

    var part1: u64 = 0;
    var part2: u64 = 0;

    while (try reader.interface.takeDelimiter('\n')) |line| {
        part1 += try findBestJoltageNaryTuple(line, 2);
        part2 += try findBestJoltageNaryTuple(line, 12);
    }

    var stdout = std.fs.File.stdout().writer(&buf);
    defer stdout.interface.flush() catch {};

    try stdout.interface.print("part 1: {}\npart 2: {}\n", .{ part1, part2 });
}

// greedy solution, likely much faster than the top-down dynamic one
pub fn findBestJoltageNaryTuple(bank: []const u8, n: u8) !u64 {
    var cur_bank = bank;
    var cur_n = n;

    var joltage: u64 = 0;

    while (cur_n > 0) {
        // shortcut
        if (cur_n == cur_bank.len)
            return joltage + try std.fmt.parseInt(u64, cur_bank, 10);

        cur_n -= 1;

        // don't look for it at the _n - 1_ last digits because then we'd end up with a subbank that's too small
        const earliest_biggest_digit = std.mem.max(u8, cur_bank[0 .. cur_bank.len - cur_n]);
        const biggest_pos = std.mem.indexOfScalar(u8, cur_bank, earliest_biggest_digit).?;

        joltage += (earliest_biggest_digit - '0') * pow10(cur_n);
        cur_bank = cur_bank[biggest_pos + 1 ..];
    }

    return joltage;
}

fn pow10(n: u8) u64 {
    switch (n) {
        0 => return 1,
        1 => return 10,
        2 => return 100,
        3 => return 1000,
        4 => return 10000,
        5 => return 100000,
        6 => return 1000000,
        7 => return 10000000,
        8 => return 100000000,
        9 => return 1000000000,
        10 => return 10000000000,
        11 => return 100000000000,
        12 => return 1000000000000,
        else => return 10000000000000 * pow10(n - 12),
    }
}
