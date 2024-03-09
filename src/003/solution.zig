const std = @import("std");

const VERBOSE = true;

fn is_symbol(item: u8) bool {
    return (item != '\n' and item != '.' and (item < 48 or item > 57));
}

fn string_to_u64(array: []u8) u64 {
    var part_val: u64 = 0;
    var index: usize = 0;
    while (index < array.len) : (index += 1) {
        const place_value: usize = array.len - index - 1;
        const digit_value = @as(u64, array[index] - 48);
        var multiplier: u64 = 1;
        for (0..place_value) |_| {
            multiplier *= 10;
        }
        part_val += (digit_value * multiplier);
    }
    return part_val;
}

fn part_value(number: []u8, row: usize, col: usize, table: []const u8, line_width: usize) u64 {
    const start: usize = if (col == 0) 0 else col - 1;
    const end: usize = if (col + number.len > line_width - 1) line_width - 1 else col + number.len;

    var x: usize = start;
    var y: usize = if (row == 0) 0 else row - 1;

    return while ((y <= row + 1) and (x <= end + 1)) {
        const cell_number: usize = (y * (line_width + 1)) + x;
        if (x < 0 or y < 0 or cell_number > table.len) {
            x += 1;
            continue;
        }

        if (x > end or end >= line_width) {
            x = start;
            y += 1;
            continue;
        } else if (y == row and x >= col and x < col + number.len) {
            x += 1;
            continue;
        }

        const cell = table[cell_number];
        if (is_symbol(cell)) break string_to_u64(number);
        x += 1;
    } else 0;
}

fn adjacent_gear(number: []u8, row: usize, col: usize, table: []const u8, line_width: usize) ?usize {
    const start: usize = if (col == 0) 0 else col - 1;
    const end: usize = if (col + number.len > line_width - 1) line_width - 1 else col + number.len;

    var x: usize = start;
    var y: usize = if (row == 0) 0 else row - 1;

    return while ((y <= row + 1) and (x <= end + 1)) {
        const cell_number: usize = (y * (line_width + 1)) + x;
        if (x < 0 or y < 0 or cell_number >= table.len) {
            x += 1;
            continue;
        }

        if (x > end or end >= line_width) {
            x = start;
            y += 1;
            continue;
        } else if (y == row and x >= col and x < col + number.len) {
            x += 1;
            continue;
        }

        if (table[cell_number] == '*') break cell_number;
        x += 1;
    } else null;
}

pub fn part1(input: []const u8) !u64 {
    var answer: u64 = 0;

    var line_width: usize = 0;
    while (input[line_width] != '\n') {
        line_width += 1;
    }

    var col: usize = 0;
    var row: usize = 0;
    var number_buffer = std.mem.zeroes([8]u8);
    var number_buffer_index: usize = 0;
    for (input) |char| {
        if (char == '\n') {
            if (number_buffer_index > 0) {
                const number = number_buffer[0..number_buffer_index];
                answer += part_value(number, row, col - number_buffer_index, input, line_width);
                number_buffer = std.mem.zeroes([8]u8);
                number_buffer_index = 0;
            }
            row += 1;
            col = 0;
            continue;
        }

        if (char >= 48 and char <= 57) {
            number_buffer[number_buffer_index] = char;
            number_buffer_index += 1;
        } else if (number_buffer_index > 0) {
            const number = number_buffer[0..number_buffer_index];
            answer += part_value(number, row, col - number_buffer_index, input, line_width);
            number_buffer = std.mem.zeroes([8]u8);
            number_buffer_index = 0;
        }

        col += 1;
    }

    return answer;
}

fn next_index(array: *const [10]u64) usize {
    var index: usize = 0;
    for (array) |*item| {
        if (item.* == 0) {
            return index;
        }
        index += 1;
    }
    return index;
}

pub fn part2(input: []const u8) !u64 {
    var answer: u64 = 0;

    const allocator = std.heap.page_allocator;
    var gear_tracker = try allocator.alloc([10]u64, input.len);
    defer allocator.free(gear_tracker);

    for (gear_tracker) |*gear| {
        gear.* = std.mem.zeroes([10]u64);
    }

    var line_width: usize = 0;
    while (input[line_width] != '\n') {
        line_width += 1;
    }

    var col: usize = 0;
    var row: usize = 0;
    var number_buffer = std.mem.zeroes([8]u8);
    var number_buffer_index: usize = 0;
    for (input) |char| {
        if (char == '\n') {
            if (number_buffer_index > 0) {
                const number = number_buffer[0..number_buffer_index];
                const gear_index = adjacent_gear(number, row, col - number_buffer_index, input, line_width);
                if (gear_index) |found_gear_index| {
                    const next_gear_index_number_index = next_index(&gear_tracker[found_gear_index]);
                    gear_tracker[found_gear_index][next_gear_index_number_index] = string_to_u64(number_buffer[0..number_buffer_index]);
                }
                number_buffer = std.mem.zeroes([8]u8);
                number_buffer_index = 0;
            }
            row += 1;
            col = 0;
            continue;
        }

        if (char >= 48 and char <= 57) {
            number_buffer[number_buffer_index] = char;
            number_buffer_index += 1;
        } else if (number_buffer_index > 0) {
            const number = number_buffer[0..number_buffer_index];
            const gear_index = adjacent_gear(number, row, col - number_buffer_index, input, line_width);
            if (gear_index) |found_gear_index| {
                const next_gear_index_number_index = next_index(&gear_tracker[found_gear_index]);
                gear_tracker[found_gear_index][next_gear_index_number_index] = string_to_u64(number_buffer[0..number_buffer_index]);
            }
            number_buffer = std.mem.zeroes([8]u8);
            number_buffer_index = 0;
        }

        col += 1;
    }

    for (gear_tracker) |gear| {
        const next_gear_index_number_index = next_index(&gear);
        if (next_gear_index_number_index != 2) continue;
        answer += gear[0] * gear[1];
    }

    return answer;
}
