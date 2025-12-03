const std = @import("std");

fn validate_range(from: u64, to: u64, extSum: *u64, simpleSum: *u64) void {
    for (from..to + 1) |n| {
        const places = numPlaces(n);
        var pl = places / 2;
        while (pl > 0) : (pl -= 1) {
            if (places % pl != 0) continue;
            const reps = places / pl;
            const digits = pow10_(pl);

            const part = n % digits;

            var val = n;
            var invalid = true;
            for (1..reps) |_| {
                val /= digits;
                if (val % digits != part) {
                    invalid = false;
                    break;
                }
            }
            if (invalid) {
                if (pl == places / 2 and places % 2 == 0)
                    simpleSum.* += n;
                extSum.* += n;
                break;
            }
        }
    }
}

fn openInput() !std.fs.File {
    var args = std.process.args();
    _ = args.skip();
    const path = args.next() orelse "input.txt";
    return std.fs.cwd().openFile(path, .{});
}

pub fn main() !void {
    const input = try openInput();
    defer input.close();
    var buf: [512]u8 = undefined;
    var reader = input.reader(&buf);
    const interface = &reader.interface;

    var part1: u64 = 0;
    var part2: u64 = 0;

    while (try interface.takeDelimiter(',')) |line| {
        const line_t = std.mem.trim(u8, line, "\n\t\r ");
        const dash = std.mem.indexOfScalar(u8, line_t, '-') orelse return error.NoDash;
        const from = try std.fmt.parseInt(u64, line_t[0..dash], 10);
        const to = try std.fmt.parseInt(u64, line_t[dash + 1 ..], 10);

        validate_range(from, to, &part2, &part1);
    }

    var stdout_wrt = std.fs.File.stdout().writer(&buf);
    const stdout = &stdout_wrt.interface;
    defer stdout.flush() catch {};

    try stdout.print("part 1: {}\npart 2: {}\n", .{ part1, part2 });
}

fn numPlaces(n: u64) u8 {
    if (n < 10) return 1;
    if (n < 100) return 2;
    if (n < 1000) return 3;
    if (n < 10000) return 4;
    if (n < 100000) return 5;
    if (n < 1000000) return 6;
    if (n < 10000000) return 7;
    if (n < 100000000) return 8;
    if (n < 1000000000) return 9;
    return 9 + numPlaces(n / 1000000000);
}
fn pow10_(n: u8) u64 {
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
        else => return 10000000000 * pow10_(n - 10),
    }
}
