const std = @import("std");

fn doubles(n: u8) u32 {
    if (n == 0) return 0;

    var counter: u8 = 1;
    var answer: u32 = 1;
    while (counter < n) : (counter += 1) {
        answer *= 2;
    }

    return answer;
}

pub fn part1(input: []const u8) u32 {
    var line_width: usize = 0;
    var n_winning_numbers: usize = 0;
    var n_have_numbers: usize = 0;
    var winning_numbers_start: usize = 0;
    var have_numbers_start: usize = 0;

    init_nums: while (input[line_width] != 0) : (line_width += 1) {
        switch (input[line_width]) {
            ':' => {
                winning_numbers_start = line_width + 2;
            },
            '|' => {
                have_numbers_start = line_width + 2;
                n_winning_numbers = @divExact((line_width - winning_numbers_start), 3);
            },
            '\n' => {
                n_have_numbers = @divExact((line_width + 1 - have_numbers_start), 3);
                line_width += 1;
                break :init_nums;
            },
            else => {},
        }
    }

    const num_lines = @divExact(input.len, line_width);
    var line_index: usize = 0;
    var points: u32 = 0;

    while (line_index < num_lines) : (line_index += 1) {
        var line_correct: u8 = 0;
        var winning_number_index: usize = 0;
        while (winning_number_index < n_winning_numbers) : (winning_number_index += 1) {
            var have_number_index: usize = 0;
            is_win: while (have_number_index < n_have_numbers) : (have_number_index += 1) {
                const winning_number_buffer_start = (line_index * line_width) + winning_numbers_start + (3 * winning_number_index);
                const current_winning_number = input[winning_number_buffer_start .. winning_number_buffer_start + 2];

                const have_number_buffer_start = (line_index * line_width) + have_numbers_start + (3 * have_number_index);
                const current_have_number = input[have_number_buffer_start .. have_number_buffer_start + 2];

                if (std.mem.eql(u8, current_winning_number, current_have_number)) {
                    line_correct += 1;
                    break :is_win;
                }
            }
        }

        points += doubles(line_correct);
    }

    return points;
}

pub fn part2(input: []const u8) !u32 {
    var line_width: usize = 0;
    var n_winning_numbers: usize = 0;
    var n_have_numbers: usize = 0;
    var winning_numbers_start: usize = 0;
    var have_numbers_start: usize = 0;

    init_nums: while (input[line_width] != 0) : (line_width += 1) {
        switch (input[line_width]) {
            ':' => {
                winning_numbers_start = line_width + 2;
            },
            '|' => {
                have_numbers_start = line_width + 2;
                n_winning_numbers = @divExact((line_width - winning_numbers_start), 3);
            },
            '\n' => {
                n_have_numbers = @divExact((line_width + 1 - have_numbers_start), 3);
                line_width += 1;
                break :init_nums;
            },
            else => {},
        }
    }

    const num_lines = @divExact(input.len, line_width);
    var line_index: usize = 0;
    var scratchcards: u32 = 0;

    const allocator = std.heap.page_allocator;
    var card_num_tracker = try allocator.alloc(u32, num_lines);
    defer allocator.free(card_num_tracker);

    var i: usize = 0;
    while (i < card_num_tracker.len) : (i += 1) {
        card_num_tracker[i] = 1;
    }

    while (line_index < num_lines) : (line_index += 1) {
        var line_correct: u8 = 0;
        var winning_number_index: usize = 0;
        while (winning_number_index < n_winning_numbers) : (winning_number_index += 1) {
            var have_number_index: usize = 0;
            is_win: while (have_number_index < n_have_numbers) : (have_number_index += 1) {
                const winning_number_buffer_start = (line_index * line_width) + winning_numbers_start + (3 * winning_number_index);
                const current_winning_number = input[winning_number_buffer_start .. winning_number_buffer_start + 2];

                const have_number_buffer_start = (line_index * line_width) + have_numbers_start + (3 * have_number_index);
                const current_have_number = input[have_number_buffer_start .. have_number_buffer_start + 2];

                if (std.mem.eql(u8, current_winning_number, current_have_number)) {
                    line_correct += 1;
                    break :is_win;
                }
            }
        }

        var card_adder: u8 = @as(u8, @intCast(line_index)) + 1;
        const card_adder_end: u8 = @as(u8, @intCast(line_index)) + line_correct;

        while (card_adder <= card_adder_end) : (card_adder += 1) {
            const card_adder_as_index = @as(usize, @intCast(card_adder));
            if (card_adder_as_index >= num_lines) break;
            card_num_tracker[card_adder_as_index] += (1 * card_num_tracker[line_index]);
        }
    }

    var j: usize = 0;
    while (j < card_num_tracker.len) : (j += 1) {
        scratchcards += card_num_tracker[j];
    }

    return scratchcards;
}
