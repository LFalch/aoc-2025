const std = @import("std");
const aoc = @import("aoc");

const AnswerType: type = usize;

pub fn main() !void {
    try aoc.run_solution(AnswerType, solve);
}

const Button = std.bit_set.IntegerBitSet(16);
const Lights = struct {
    joltages: [16]u16 = @splat(0),

    inline fn zero(self: Lights) bool {
        return std.mem.allEqual(u16, &self.joltages, 0);
    }
};

fn solve(ctx: aoc.Context) AnswerType {
    var f = ctx.file_data;

    var sum: AnswerType = 0;
    var sum_mutex = std.Thread.Mutex{};
    var pool: std.Thread.Pool = undefined;
    pool.init(.{ .allocator = ctx.gpa, .n_jobs = 16 }) catch @panic("can't start pool");

    var node = std.Progress.start(.{ .root_name = "machines", .estimated_total_items = std.mem.count(u8, f.file_data, "\n") });
    defer node.end();

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
        var index: u5 = 0;
        while (true) : (index += 1) {
            const joltage = f.read_number(u16);
            lights.joltages[index] = joltage;
            if (f.accept(",")) continue else {
                std.debug.assert(f.accept("}"));
                break;
            }
        }

        std.debug.assert(f.read_space());

        pool.spawn(work, .{ lights, buttons, node, ctx.gpa, &sum, &sum_mutex }) catch @panic("no space for job");
    }

    pool.deinit();

    return sum;
}

fn work(l: Lights, b: std.ArrayList(Button), node: std.Progress.Node, gpa: std.mem.Allocator, sum: *AnswerType, sum_mutex: *std.Thread.Mutex) void {
    aoc.dbgPrint("working!\n", .{});
    var lights = l;
    var buttons = b;
    const num = std.mem.indexOfScalar(u16, &l.joltages, 0) orelse l.joltages.len;

    aoc.dbgPrint("  ", .{});
    for (b.items) |but| {
        aoc.dbgPrint("{b:0>[width]} ", .{ .@"0" = but.mask, .width = num });
    }
    _ = std.io.Writer.print;

    aoc.dbgPrint("{any}:\n", .{l.joltages[0..num]});

    const sub_node = node.start("buttons", 0);
    defer sub_node.end();
    const n = simplify(sub_node, &lights, &buttons);
    if (n > 0)
        aoc.dbgPrint("!!! did {d} simplifications\n", .{n});
    const m = if (lights.zero()) n else n +
        (linear(sub_node, gpa, lights.joltages[0..num], buttons.items) catch unreachable);
    aoc.dbgPrint("worked\n\n", .{});
    sum_mutex.lock();
    sum.* += m;
    sum_mutex.unlock();
}

fn simplify(node: std.Progress.Node, l: *Lights, buttons: *std.ArrayList(Button)) usize {
    var simplifications: usize = 0;

    var sub_node = node.start("simplify", 0);
    defer sub_node.end();

    var found_smth = true;
    find_smth: while (found_smth) {
        found_smth = false;
        sub_node.setCompletedItems(0);
        sub_node.setEstimatedTotalItems(buttons.items.len);
        outer: for (buttons.items, 0..) |*b1, i| {
            defer sub_node.setCompletedItems(i);

            var b = b1.*;
            for (buttons.items, 0..) |b2, j| {
                if (i == j) continue;

                b = b.differenceWith(b2);
                if (b.mask == 0) continue :outer;
            }

            {
                // joltage_adjustment
                var smallest_js = Button.initEmpty();
                var smallest: u16 = std.math.maxInt(u16);
                var iter = b1.iterator(.{});
                while (iter.next()) |index| {
                    const joltage = l.joltages[index];
                    if (joltage < smallest) {
                        smallest = joltage;
                        smallest_js = Button.initEmpty();

                        smallest_js.set(index);
                    } else if (joltage == smallest) {
                        smallest_js.set(index);
                    }
                }
                // if the set of the smallest joltages the button affects is not a subset of the joltages only this button affects
                // then we try the next button
                if (b.differenceWith(smallest_js) != Button.initEmpty()) continue :outer;

                b = b.intersectWith(smallest_js);
                iter = b1.iterator(.{});
                while (iter.next()) |index| {
                    l.joltages[index] -= smallest;
                }

                simplifications += smallest;
            }

            if (l.zero()) return simplifications;

            _ = buttons.swapRemove(i);

            found_smth = true;
            continue :find_smth;
        }
    }
    std.debug.assert(buttons.items.len > 0);

    return simplifications;
}

const Equation = GenericEquation(f32, f32);
const IntEquation = GenericEquation(i32, i32);

fn GenericEquation(Coef: type, Sum: type) type {
    return struct {
        coefficients: [16]Coef = @splat(0),
        sum: Sum,

        const zero = Equation{ .sum = 0 };

        fn add(self: Equation, other: Equation) Equation {
            var result = self;
            result.sum += other.sum;
            for (&result.coefficients, &other.coefficients) |*c1, c2| {
                c1.* += c2;
            }
            return result;
        }
        fn sub(self: Equation, other: Equation) Equation {
            var result = self;
            result.sum -= other.sum;
            for (&result.coefficients, &other.coefficients) |*c1, c2| {
                c1.* -= c2;
            }
            return result;
        }
        fn scale(self: Equation, scalar: f32) Equation {
            var result = self;
            result.sum *= scalar;
            for (&result.coefficients) |*c1|
                c1.* *= scalar;

            return result;
        }
        fn trivial(self: Equation, n_cos: usize) ?usize {
            var one_place: ?usize = null;
            for (self.coefficients[0..n_cos], 0..) |c, i| {
                if (c == 1) {
                    if (one_place) |_| {
                        return null;
                    } else one_place = i;
                } else if (c != 0) return null;
            }
            return one_place;
        }
    };
}

fn smallest_legal_solution(node: std.Progress.Node, gpa: std.mem.Allocator, equations: []const Equation, n_cos: usize) usize {
    var assignments: [16]?u16 = @splat(null);
    var buffer1: [16]Equation = undefined;
    var buffer2: [16]Equation = undefined;

    var unsolved = std.ArrayList(Equation).initBuffer(&buffer1);
    var unsolved2 = std.ArrayList(Equation).initBuffer(&buffer2);

    // initial assignments
    for (equations) |equation| {
        if (equation.trivial(n_cos)) |place| {
            assignments[place] = @intFromFloat(equation.sum);
            aoc.dbgPrint("v{d} = {?d}\n", .{ place, assignments[place] });
            node.completeOne();
        } else unsolved.addOneAssumeCapacity().* = equation;
    }
    for (unsolved.items) |e| {
        aoc.dbgPrint("{any} ", .{e.coefficients[0..n_cos]});
        aoc.dbgPrint("{d}\n", .{e.sum});
    }

    while (true) {
        // set zeroes
        var was_okay: Button = .initFull();
        var err: f32 = 0;
        for (unsolved.items) |equation| {
            var touched: Button = .initEmpty();
            var sum: f32 = 0;
            for (equation.coefficients[0..n_cos], assignments[0..n_cos], 0..) |c, val, i| {
                if (c == 0) continue;
                if (val) |v| {
                    sum += c * @as(f32, @floatFromInt(v));
                } else {
                    // pretend it's set to zero (the minimum)
                    touched.set(i);
                }
            }
            const diff = @abs(sum - equation.sum);
            if (diff >= 0.001) {
                err += diff;
                was_okay = was_okay.differenceWith(touched);
            }
        }
        if (err == 0) {
            var total: usize = assignments[0].?;
            for (assignments[1..n_cos]) |a| {
                total += a orelse 0;
            }
            aoc.dbgPrint("fast-forward\n", .{});
            return total;
        }
        aoc.dbgPrint("err: {d}\n", .{err});
        var set = false;
        for (assignments[0..n_cos], 0..) |*v, i| {
            if (v.*) |_| continue;
            aoc.dbgPrint("checking {d}\n", .{i});
            if (was_okay.isSet(i)) {
                set = true;
                aoc.dbgPrint("setting {d}\n", .{i});
                v.* = 0;
                node.completeOne();
                for (unsolved.items) |*e| {
                    aoc.dbgPrint("seting {d} to 0\n", .{e.coefficients[i]});
                    e.coefficients[i] = 0;
                }
            }
        }

        for (unsolved.items) |e| {
            aoc.dbgPrint("{any} ", .{e.coefficients[0..n_cos]});
            aoc.dbgPrint("{d}\n", .{e.sum});
        }

        unsolved2.items.len = unsolved.items.len;
        @memcpy(unsolved2.items, unsolved.items);
        unsolved.items.len = 0;

        for (unsolved2.items) |equation| {
            if (equation.trivial(n_cos)) |place| {
                set = true;
                assignments[place] = @intFromFloat(equation.sum);
                aoc.dbgPrint("v{d} = {?d}\n", .{ place, assignments[place] });
                node.completeOne();
            } else unsolved.addOneAssumeCapacity().* = equation;
        }
        if (!set) break;

        aoc.dbgPrint("checking ass\n", .{});

        for (assignments, 0..) |a, i| {
            const assignment = if (a) |v| v else continue;
            aoc.dbgPrint("v{d} = {d}:\n", .{ i, assignment });
            for (unsolved.items) |*e| {
                aoc.dbgPrint("{any} {d}\n", .{ e.coefficients[0..n_cos], e.sum });
                const coff = &e.coefficients[i];
                if (coff.* != 0) {
                    aoc.dbgPrint("setting {d} to 0 adding {d} to {d}\n", .{
                        coff.*,
                        coff.* * @as(f32, @floatFromInt(assignment)),
                        e.sum,
                    });
                    e.sum += coff.* * @as(f32, @floatFromInt(assignment));
                    coff.* = 0;
                }
            }
        }
    }

    for (assignments[0..n_cos], 0..) |a, i| {
        if (a) |v| aoc.dbgPrint("v{d} = {d} ", .{ i, v });
    }
    aoc.dbgPrint("\n", .{});
    for (unsolved.items) |e| {
        aoc.dbgPrint("{any} ", .{e.coefficients[0..n_cos]});
        aoc.dbgPrint("{d}\n", .{e.sum});
    }

    // isolate
    {
        unsolved2.items.len = unsolved.items.len;
        @memcpy(unsolved2.items, unsolved.items);
        unsolved.items.len = 0;

        for (assignments[0..n_cos], 0..) |*a, vi| {
            if (a.*) |_| continue;

            // find equation involving var `vi`
            var found: ?Equation = null;
            for (unsolved2.items) |*eq| {
                const cof = eq.coefficients[vi];
                if (cof == 0) continue;

                if (found) |f| {
                    eq.* = eq.sub(f.scale(cof));
                    eq.coefficients[vi] = 0;
                } else {
                    const factor = 1 / cof;
                    eq.* = eq.scale(factor);
                    found = eq.*;
                }
            }
            const first_eq = found.?;
            unsolved.appendAssumeCapacity(first_eq);
        }
    }

    aoc.dbgPrint("\n", .{});
    for (unsolved.items) |e| {
        aoc.dbgPrint("{any} ", .{e.coefficients[0..n_cos]});
        aoc.dbgPrint("{d}\n", .{e.sum});
    }
    aoc.dbgPrint("look at this ^\n", .{});

    // return

    const n_node = node.start("n", 0);
    defer n_node.end();

    const min = b: {
        var min: u16 = 0;

        for (assignments[0..n_cos]) |a| {
            if (a) |val| min += val;
        }

        break :b min;
    };

    var n: u16 = 0;
    n_node.setCompletedItems(n + min);
    while (true) : (n += 1) {
        var tentative_assignments: [16]u16 = undefined;

        const i_node = n_node.start("i", n_cos);
        defer i_node.end();

        // // TODO: don't solve the remainder like this
        if (left(i_node, gpa, &tentative_assignments, assignments[0..n_cos], unsolved.items, n)) {
            aoc.dbgPrint("found! {d} :)\n\n", .{n});
            return min + n;
        }
    }
}

const Map = std.HashMap(u32, void, Ctx, 75);
const Ctx = struct {
    pub inline fn hash(_: @This(), n: u32) u32 {
        return n;
    }
    pub inline fn eql(_: @This(), a: u32, b: u32) bool {
        return a == b;
    }

    pub inline fn key(n: u16, ta: []u16) u32 {
        var hasher = std.hash.XxHash3.init(0);
        hasher.update(std.mem.sliceAsBytes(ta));
        hasher.update(std.mem.asBytes(&n));
        return @truncate(hasher.final());
    }
};

inline fn left(node: std.Progress.Node, gpa: std.mem.Allocator, tentative_assignments: []u16, assignments: []const ?u16, equations: []const Equation, n: u16) bool {
    std.debug.assert(tentative_assignments.len >= assignments.len);
    std.debug.assert(assignments.len >= equations.len);
    var cache = Map.init(gpa);
    defer cache.deinit();
    return left_inner(node, &cache, 0, 0, assignments.len, tentative_assignments.ptr, assignments.ptr, equations.ptr, n);
}

fn left_inner(node: std.Progress.Node, cache: *Map, ei: usize, i: usize, len: usize, tentative_assignments: [*]u16, assignments: [*]const ?u16, equations: [*]const Equation, n: u16) bool {
    node.completeOne();

    const k = Ctx.key(n, tentative_assignments[0..i]);
    if (cache.get(k)) |_| return false;

    if (i == len) {
        if (n != 0) return false;

        for (equations[0..ei]) |e| {
            var sum: f32 = 0;
            for (e.coefficients[0..len], tentative_assignments) |c, ta| {
                if (c != 0) {
                    sum += c * @as(f32, @floatFromInt(ta));
                }
            }
            if (sum != e.sum) return false;
        }
        return true;
    }

    if (assignments[i]) |a| {
        tentative_assignments[i] = a;
        return left_inner(node, cache, ei, i + 1, len, tentative_assignments, assignments, equations, n);
    }

    const eq = equations[ei];

    // find lower and upper bound of `unknown` based on equation
    const low: u16, const high: u16 = b: {
        var tentative_sum = eq.sum;
        for (eq.coefficients[0..i], tentative_assignments) |co, ta| {
            tentative_sum -= co * @as(f32, @floatFromInt(ta));
        }

        const rem: f32 = @floatFromInt(n);

        var smallest: f32 = 0;
        var biggest: f32 = 0;
        for (eq.coefficients[i + 1 .. len], i + 1..) |co, j| {
            if (assignments[j]) |a| {
                tentative_sum -= co * @as(f32, @floatFromInt(a));
            } else {
                smallest = @min(smallest, -co);
                biggest = @max(biggest, -co);
            }
        }

        const lower = tentative_sum + smallest * rem;
        const upper = tentative_sum + biggest * rem;

        const high = @max(0, @min(upper, rem));
        const low = @min(high, @max(@ceil(lower), 0));

        break :b .{ @intFromFloat(low), @intFromFloat(high) };
    };

    const unknown = &tentative_assignments[i];
    node.increaseEstimatedTotalItems(high - low);
    for (low..high + 1) |n2_big| {
        const n2: u16 = @intCast(n2_big);
        unknown.* = n2;
        if (left_inner(node, cache, ei + 1, i + 1, len, tentative_assignments, assignments, equations, n - n2)) return true;
    }
    cache.put(k, {}) catch {};
    return false;
}

fn reduced_row_echelon(equations: []Equation, n_cos: usize) []Equation {
    var matrix = equations;
    // row echelon
    // h := 1 /* Initialization of the pivot row */
    var pivot_eq: u8 = 0;
    // k := 1 /* Initialization of the pivot column */
    var pivot_co: u8 = 0;

    while (pivot_eq < matrix.len and pivot_co < n_cos) {
        // /* Find the k-th pivot: */
        // i_max := argmax (i = h ... m, abs(A[i, k]))
        const i_eq_max = b: {
            var biggest_index: usize = undefined;
            var biggest_value: f32 = 0;
            for (matrix[pivot_eq..], pivot_eq..) |e, index| {
                const co = @abs(e.coefficients[pivot_co]);
                if (co > biggest_value) {
                    biggest_value = co;
                    biggest_index = index;
                }
            }
            // if A[i_max, k] = 0:
            //     /* No pivot in this column, pass to next column */
            //     k := k + 1
            if (biggest_value == 0) {
                pivot_co += 1;
                continue;
            }
            break :b biggest_index;
        };
        // swap rows(h, i_max)
        std.mem.swap(Equation, &matrix[pivot_eq], &matrix[i_eq_max]);
        const pivot = matrix[pivot_eq].coefficients[pivot_co];

        // /* Do for all rows below pivot: */
        for (matrix[pivot_eq + 1 ..]) |*pe| {
            const c = pe.coefficients[pivot_co];
            if (c == 0) continue;
            const f = @divExact(c, pivot);
            pe.* = pe.sub(matrix[pivot_eq].scale(f));
        }
        // /* Increase pivot row and column */
        pivot_co += 1;
        pivot_eq += 1;
    }

    // reduce
    {
        var cur_row = matrix.len - 1;
        while (true) {
            const leading_column = for (matrix[cur_row].coefficients, 0..) |co, c_i| {
                if (co != 0) break c_i;
            } else {
                if (cur_row == 0) break;
                cur_row -= 1;
                matrix.len -= 1;
                continue;
            };
            matrix[cur_row] = matrix[cur_row].scale(1 / matrix[cur_row].coefficients[leading_column]);

            for (matrix[0..cur_row]) |*r| {
                const val = r.coefficients[leading_column];
                if (val != 0) {
                    r.* = r.sub(matrix[cur_row].scale(val));
                }
            }

            if (cur_row == 0) break;
            cur_row -= 1;
        }
    }

    return matrix;
}

fn linear(node: std.Progress.Node, gpa: std.mem.Allocator, target_joltages: []u16, buttons: []const Button) !usize {
    var equation_buf: [16]Equation = undefined;
    const matrix = b: {
        var count: usize = 0;

        equation_loop: for (target_joltages, 0..) |jolt, j| {
            if (jolt > 0) {
                var new_eq = Equation{ .sum = @floatFromInt(jolt) };
                for (buttons, 0..) |b, i| {
                    if (b.isSet(j))
                        new_eq.coefficients[i] = 1.0;
                }
                for (equation_buf[0..count]) |old_eq| {
                    if (std.meta.eql(old_eq, new_eq)) {
                        aoc.dbgPrint("meo!\n", .{});
                        continue :equation_loop;
                    }
                }

                equation_buf[count] = new_eq;
                count += 1;
            }
        }
        break :b equation_buf[0..count];
    };

    if (matrix.len == 0) return 0;

    const n_cos = buttons.len;
    node.setEstimatedTotalItems(n_cos);
    const reduced = reduced_row_echelon(matrix, n_cos);

    return smallest_legal_solution(node, gpa, reduced, n_cos);
}
