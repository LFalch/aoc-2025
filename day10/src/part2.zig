const std = @import("std");
const aoc = @import("aoc");

const Allocator = std.mem.Allocator;

const AnswerType: type = usize;

pub fn main() !void {
    try aoc.run_solution(AnswerType, solve);
}

fn solve(ctx: aoc.Context) AnswerType {
    var f = ctx.file_data;

    var sum: AnswerType = 0;
    var sum_mutex = std.Thread.Mutex{};
    var pool: std.Thread.Pool = undefined;
    pool.init(.{ .allocator = ctx.gpa }) catch @panic("can't start pool");

    while (!f.is_done()) {
        std.debug.assert(f.accept("["));
        f.file_data = f.file_data[std.mem.indexOfScalar(u8, f.file_data, ']').? + 1 ..];

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
        _ = f.read_space();

        var lights = Lights{};
        std.debug.assert(f.accept("{"));
        const num = b: {
            var index: u5 = 0;
            while (true) : (index += 1) {
                const joltage = f.read_number(u16);
                lights.joltages[index] = joltage;
                if (f.accept(",")) continue else {
                    std.debug.assert(f.accept("}"));
                    break;
                }
            }
            break :b index + 1;
        };

        std.debug.assert(f.read_space());

        pool.spawn(smallest_solution, .{ lights, num, buttons.items, ctx.gpa, &sum, &sum_mutex }) catch @panic("no space for job");
    }

    pool.deinit();

    return sum;
}

fn smallest_solution(target: Lights, num: u8, buttons: []Button, gpa: Allocator, sum: *AnswerType, sum_mutex: *std.Thread.Mutex) void {
    const combinations = button_combinations(gpa, buttons);
    defer gpa.free(combinations);

    for (combinations) |c| {
        aoc.dbgPrint("  {d} {any}\n", .{ c.amnt_pressed, c.power_use.joltages[0..num] });
    }
    const n = smallest_from_combo(target, combinations, num).?;
    aoc.dbgPrint("{d}\n", .{n});
    sum_mutex.lock();
    sum.* += n;
    sum_mutex.unlock();
}

fn smallest_from_combo(target: Lights, combinations: []ButtonCombination, num: usize) ?AnswerType {
    if (target.zero()) {
        return 0;
    }

    var res: ?AnswerType = null;
    for (combinations) |comb| {
        if (!comb.power_use.lte(target)) {
            continue;
        }
        if (!comb.power_use.sameParity(target)) {
            continue;
        }

        const next_target = b: {
            const tj: @Vector(16, u16) = target.joltages;
            const cuj: @Vector(16, u16) = comb.power_use.joltages;

            const half_diff = (tj - cuj) / @as(@Vector(16, u16), @splat(2));
            break :b Lights{ .joltages = half_diff };
        };
        const next_res = smallest_from_combo(next_target, combinations, num) orelse continue;
        const cand_res = 2 * next_res + comb.amnt_pressed;

        res = if (res) |r|
            @min(cand_res, r)
        else
            cand_res;
    }
    return res;
}

const Button = std.bit_set.IntegerBitSet(16);
const Lights = struct {
    joltages: [16]u16 = @splat(0),

    inline fn zero(self: Lights) bool {
        return std.mem.allEqual(u16, &self.joltages, 0);
    }

    fn press(self: *Lights, button: Button) void {
        var iter = button.iterator(.{ .kind = .set });
        while (iter.next()) |i| {
            self.joltages[i] += 1;
        }
    }

    fn lte(a: Lights, b: Lights) bool {
        const ja: @Vector(16, u16) = a.joltages;
        const jb: @Vector(16, u16) = b.joltages;

        return @reduce(.And, ja <= jb);
    }

    fn sameParity(a: Lights, b: Lights) bool {
        const ja: @Vector(16, u16) = a.joltages;
        const jb: @Vector(16, u16) = b.joltages;
        const two: @Vector(16, u16) = @splat(2);

        return @reduce(.And, ja % two == jb % two);
    }
};

const ButtonCombination = struct {
    power_use: Lights,
    amnt_pressed: u8,
};

fn button_combinations(a: Allocator, buttons: []Button) []ButtonCombination {
    const n_buttons: u6 = @intCast(buttons.len);
    const cap = @as(usize, 1) << n_buttons;

    const res = a.alloc(ButtonCombination, cap) catch unreachable;
    for (res, 0..) |*el, n| {
        var presses = Button{ .mask = @intCast(n) };
        var l = Lights{};
        var iter = presses.iterator(.{});
        while (iter.next()) |j| {
            l.press(buttons[j]);
        }
        el.* = .{ .power_use = l, .amnt_pressed = @intCast(presses.count()) };
    }
    return res;
}
