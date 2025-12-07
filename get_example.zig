const std = @import("std");

const START: []const u8 = "<pre><code>";
const END: []const u8 = "</code></pre>";

pub fn main() !void {
    const alloc = std.heap.smp_allocator;

    var buf = std.io.Writer.Allocating.init(alloc);
    defer buf.deinit();

    const day = b: {
        var args = std.process.args();
        _ = args.skip();
        const day = args.next().?;
        break :b try std.fmt.parseInt(u8, day, 10);
    };
    {
        var client = std.http.Client{ .allocator = alloc };
        defer client.deinit();

        const url = try std.fmt.allocPrint(alloc, "https://adventofcode.com/2025/day/{d}", .{day});
        defer alloc.free(url);

        const res = try client.fetch(.{
            .method = .GET,
            .location = .{ .url = url },
            .response_writer = &buf.writer,
        });
        std.debug.assert(res.status == .ok);
    }
    const slice = try buf.toOwnedSlice();
    defer alloc.free(slice);

    const code = std.mem.indexOf(u8, slice, START).? + START.len;
    const end = std.mem.indexOfPos(u8, slice, code, END).?;

    const s = try std.fmt.allocPrint(alloc, "day{d:02}/test.txt", .{day});
    defer alloc.free(s);
    const f = try std.fs.cwd().createFile(s, .{ .exclusive = true });
    defer f.close();

    try f.writeAll(slice[code..end]);
}
