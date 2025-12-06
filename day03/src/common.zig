const std = @import("std");
const aoc = @import("aoc");

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

        joltage += (earliest_biggest_digit - '0') * aoc.pow10(cur_n);
        cur_bank = cur_bank[biggest_pos + 1 ..];
    }

    return joltage;
}
