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

    var map = std.AutoHashMap(CacheKey, u64).init(std.heap.smp_allocator);
    defer map.deinit();
    while (try reader.interface.takeDelimiter('\n')) |line| {
        part1 += findBestJoltagePair(line);

        defer map.clearRetainingCapacity();
        part2 += try findBestJoltageNaryTuple(line, 12, &map);
    }

    var stdout = std.fs.File.stdout().writer(&buf);
    defer stdout.interface.flush() catch {};

    try stdout.interface.print("part 1: {}\npart 2: {}\n", .{ part1, part2 });
}

const CacheKey = struct {
    bank_ptr: usize,
    bank_len: usize,
    n: u8,
};

fn findBestJoltagePair(bank: []u8) u8 {
    var max: u8 = 0;
    for (0..bank.len) |i|
        for (i + 1..bank.len) |j| {
            const joltage = (bank[i] - '0') * 10 + bank[j] - '0';
            if (joltage > max) max = joltage;
        };

    return max;
}
fn findBestJoltageNaryTuple(bank: []u8, n: u8, cache: *std.AutoHashMap(CacheKey, u64)) !u64 {
    if (n == 0) return 0;
    const key = CacheKey{ .bank_ptr = @intFromPtr(bank.ptr), .bank_len = bank.len, .n = n };
    if (cache.get(key)) |max|
        return max;

    var max: u64 = 0;
    for (0..bank.len) |i| {
        if (bank.len - i < n) break;
        const digit = (bank[i] - '0') * pow10(n - 1);
        const sum = digit + try findBestJoltageNaryTuple(bank[i + 1 ..], n - 1, cache);
        if (sum > max) {
            max = sum;
        }
    }
    try cache.put(key, max);
    return max;
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
