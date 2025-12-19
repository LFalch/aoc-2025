const std = @import("std");
const aoc = @import("aoc");

const AnswerType: type = usize;

pub fn main() !void {
    try aoc.run_solution(AnswerType, solve);
}

const Button = std.bit_set.IntegerBitSet(16);
const Path = struct {
    status: LightStatus,
    buttons_pressed: std.bit_set.IntegerBitSet(16),
};
const LightStatus = std.bit_set.IntegerBitSet(16);

fn solve(ctx: aoc.Context) AnswerType {
    var f = ctx.file_data;

    var sum: AnswerType = 0;

    while (!f.is_done()) {
        var lights = LightStatus.initEmpty();
        std.debug.assert(f.accept("["));
        var index: usize = 0;
        while (!f.accept("]")) : (index += 1) {
            if (f.accept("#"))
                lights.set(index)
            else
                std.debug.assert(f.accept("."));
        }
        var buttons = std.ArrayList(Button).initCapacity(ctx.arena, 16) catch unreachable;

        _ = f.read_space();
        while (f.accept("(")) {
            var button = Button.initEmpty();
            while (true) {
                const toggle = f.read_number(u4);
                button.set(toggle);
                if (f.accept(",")) continue else {
                    std.debug.assert(f.accept(")"));
                    break;
                }
            }
            _ = f.read_space();
            buttons.appendBounded(button) catch unreachable;
        }
        f.file_data = f.file_data[std.mem.indexOfScalar(u8, f.file_data, '\n').? + 1 ..];

        sum += bfs(lights, buttons.items, ctx.gpa);
    }

    return sum;
}

fn bfs(target_status: LightStatus, buttons: []const Button, gpa: std.mem.Allocator) usize {
    var queue1 = std.ArrayList(Path).empty;
    defer queue1.deinit(gpa);
    var queue2 = std.ArrayList(Path).empty;
    defer queue2.deinit(gpa);

    var n: usize = 0;
    queue2.append(gpa, .{ .status = target_status, .buttons_pressed = .initEmpty() }) catch unreachable;

    while (true) {
        n += 1;
        std.debug.assert(queue2.items.len > 0);
        for (queue2.items) |path| {
            var unset = path.buttons_pressed.iterator(.{ .kind = .unset });
            while (unset.next()) |button_index_to_press| {
                if (button_index_to_press >= buttons.len) break;
                const button_to_press = buttons[button_index_to_press];

                const new_status = path.status.xorWith(button_to_press);
                if (new_status == LightStatus.initEmpty()) return n;

                var buttons_pressed = path.buttons_pressed;
                buttons_pressed.set(button_index_to_press);
                queue1.append(gpa, .{
                    .status = new_status,
                    .buttons_pressed = buttons_pressed,
                }) catch unreachable;
            }
        }
        queue2.clearRetainingCapacity();

        std.mem.swap(std.ArrayList(Path), &queue1, &queue2);
    }
}
