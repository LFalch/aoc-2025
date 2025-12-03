const std = @import("std");

fn turnDial(dial: i32, turn: i32, direction: u8, clicks: *u32) !i32 {
    if (direction == 'R') {
        clicks.* += @intCast(@divTrunc(dial + turn, 100));
        return @mod(dial + turn, 100);
    } else if (direction == 'L') {
        clicks.* += @intCast(@divTrunc(dial - turn, -100) + @intFromBool(turn >= dial) - @intFromBool(dial == 0));
        return @mod(dial + 100 - @mod(turn, 100), 100);
    }

    return error.BadDirection;
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

    var dial: i32 = 50;
    var countZ: u32 = 0;
    var countClicks: u32 = 0;

    while (try interface.takeDelimiter('\n')) |line| {
        const dir = line[0];
        const turn = try std.fmt.parseInt(i32, line[1..], 10);
        dial = try turnDial(dial, turn, dir, &countClicks);
        if (dial == 0) countZ += 1;
    }

    var stdout_wrt = std.fs.File.stdout().writer(&buf);
    const stdout = &stdout_wrt.interface;
    defer stdout.flush() catch {};

    try stdout.print("count zero: {}\ncount click: {}\n", .{ countZ, countClicks });
}
