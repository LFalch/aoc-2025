const std = @import("std");
const testing = std.testing;

fn read(path: []const u8, alloc: std.mem.Allocator) ![]u8 {
    const f = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer f.close();
    const buf = try f.readToEndAlloc(alloc, 32 * 1024);
    return buf;
}

pub const FileData = struct {
    file_data: []const u8,

    pub fn is_done(self: *const FileData) bool {
        return self.file_data.len == 0;
    }

    /// returns if the space was a newline
    pub fn read_space(self: *FileData) bool {
        var n: usize = 0;
        var isNewline = true;
        while (n < self.file_data.len) : (n += 1) {
            const c = self.file_data[n];
            if (!std.ascii.isWhitespace(c)) break;
            if (c != '\n') isNewline = false;
        }

        self.file_data = self.file_data[n..];
        return isNewline;
    }

    pub fn read_number(self: *FileData, int: type) int {
        const info = @typeInfo(int);
        var out: int = 0;
        if (info.int.signedness == .signed) {
            if (self.file_data[0] == '-') {
                var n: usize = 1;
                while (n < self.file_data.len) : (n += 1) {
                    const c = self.file_data[n];
                    if (!std.ascii.isDigit(c)) break else {
                        out = out * 10 - @as(int, @intCast(c - '0'));
                    }
                }

                self.file_data = self.file_data[n..];
                return out;
            }
        }
        var n: usize = 0;
        while (n < self.file_data.len) : (n += 1) {
            const c = self.file_data[n];
            if (!std.ascii.isDigit(c)) break else {
                out = out * 10 + @as(int, @intCast(c - '0'));
            }
        }

        self.file_data = self.file_data[n..];
        return out;
    }

    pub fn accept(self: *FileData, s: []const u8) bool {
        if (self.file_data.len < s.len) return false;
        if (std.mem.eql(u8, self.file_data[0..s.len], s)) {
            self.file_data = self.file_data[s.len..];
            return true;
        } else return false;
    }
};

pub const Timer = struct {
    timestamp: i64,

    pub fn start() Timer {
        const ts = std.time.microTimestamp();
        return .{
            .timestamp = ts,
        };
    }

    pub fn stop(self: @This()) void {
        const now = std.time.microTimestamp();
        const diff = now - self.timestamp;
        const ms = @divTrunc(diff, 1000);
        const us = @mod(diff, 1000);
        var decimals: [3]u8 = undefined;
        zeroFill(&decimals, us);
        std.debug.print("Time: {d}.{s}ms\n", .{ ms, decimals });
    }
};

pub const Context = struct {
    file_data: FileData,
    arena: std.mem.Allocator,
    gpa: std.mem.Allocator,
};

var mem_buf: [256 * 1024]u8 = undefined;

/// Main function that does a benchmark if the answer is given in cmdargs
pub fn run_solution(Answer: type, f: fn (Context) Answer) !void {
    var fba = std.heap.FixedBufferAllocator.init(&mem_buf);

    var input_file: ?[]u8 = null;
    var answer_arg: ?[]u8 = null;
    if (std.os.argv.len > 1) {
        for (std.os.argv[1..]) |arg| {
            const buf = std.mem.span(arg);
            if (std.mem.endsWith(u8, buf, ".txt")) {
                input_file = buf;
            } else {
                answer_arg = buf;
            }
        }
    }
    const file_bytes = try read(if (input_file) |p| p else "input.txt", fba.allocator());

    if (answer_arg) |answer| {
        try bench(Answer, answer, &fba, file_bytes, f);
    } else {
        var da = std.heap.DebugAllocator(.{}).init;
        defer _ = da.deinit();
        const ctx = Context{
            .file_data = .{ .file_data = file_bytes },
            .arena = fba.allocator(),
            .gpa = da.allocator(),
        };
        const timer = Timer.start();
        const answer = f(ctx);
        timer.stop();
        var stdout_buf: [1024]u8 = undefined;
        var stdout = std.fs.File.stdout().writer(&stdout_buf);
        try stdout.interface.print("{any}\n", .{answer});
        try stdout.interface.flush();
    }
}

fn bench(Answer: type, answer: []u8, fba: *std.heap.FixedBufferAllocator, file_bytes: []const u8, f: fn (Context) Answer) !void {
    var timer = AvgTimer.init();
    defer timer.deinit();

    const fba_end_index = fba.end_index;
    const ctx = Context{
        .file_data = .{ .file_data = file_bytes },
        .arena = fba.allocator(),
        .gpa = std.heap.smp_allocator,
    };

    const benchmark_start = std.time.milliTimestamp();

    while (!timer.is_full() and (timer.next_time < 10 or (std.time.milliTimestamp() - benchmark_start < MAX_BENCHMARK_TIME_MS))) {
        fba.end_index = fba_end_index;
        timer.start();
        const calculated = f(ctx);
        timer.stop();
        fba.end_index = fba_end_index;
        const printed = try std.fmt.allocPrint(fba.allocator(), "{any}", .{calculated});
        defer fba.allocator().free(printed);
        if (!std.mem.eql(u8, printed, answer)) {
            std.debug.panic("incorrect result during benchmark, got {d}\n", .{calculated});
        }
    }
}

const MAX_TIMES_TO_RUN = 10_000;
const MAX_BENCHMARK_TIME_MS = 4_800;

fn zeroFill(buf: []u8, int: anytype) void {
    var n = int;
    var p: usize = buf.len - 1;
    while (p < buf.len) {
        buf[p] = '0' + @as(u8, @intCast(@rem(n, 10)));
        n = @divTrunc(n, 10);
        p -%= 1;
    }
}

pub const AvgTimer = struct {
    timestamp: i64,
    times: [MAX_TIMES_TO_RUN]u32,
    next_time: usize = 0,

    pub fn init() AvgTimer {
        return .{
            .timestamp = undefined,
            .times = undefined,
        };
    }
    pub fn deinit(self: *AvgTimer) void {
        std.mem.sortUnstable(u32, self.times[0..self.next_time], {}, std.sort.asc(u32));
        const outlier_count = (3 * self.next_time) / 10;
        const times = self.times[outlier_count .. self.next_time - outlier_count];

        var sum: u128 = 0;
        for (times) |time| {
            sum += time;
        }
        const avg = @divTrunc(sum, times.len);
        sum = 0;
        for (times) |time| {
            const x = @as(i64, time) - @as(i64, @intCast(avg));
            sum += @intCast(x * x);
        }
        const variance = @divTrunc(sum, times.len);
        const std_dev = std.math.sqrt(variance);

        const ms = @divTrunc(avg, 1000);
        const us = @mod(avg, 1000);
        var decimals: [3]u8 = undefined;
        zeroFill(&decimals, us);
        var buf: [256]u8 = undefined;
        var stdout = std.fs.File.stdout().writer(&buf);
        stdout.interface.print("{d}.{s}ms ± {d}µs (n={d})\n", .{ ms, decimals, std_dev, times.len }) catch @panic("print failed!?");
        stdout.interface.flush() catch @panic("print failed!?");
    }

    pub fn is_full(self: *const AvgTimer) bool {
        return self.next_time >= MAX_TIMES_TO_RUN;
    }

    /// Do not run without checking `is_full`
    pub fn start(self: *AvgTimer) void {
        const ts = std.time.microTimestamp();
        self.timestamp = ts;
    }

    /// Do not run without `start`
    pub fn stop(self: *AvgTimer) void {
        const now = std.time.microTimestamp();
        const diff = now - self.timestamp;
        self.times[self.next_time] = @intCast(diff);
        self.next_time += 1;
    }
};

pub fn numPlaces(n: u64) u8 {
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
pub fn pow10(n: u8) u64 {
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
