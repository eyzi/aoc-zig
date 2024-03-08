const std = @import("std");

const VERBOSE = true;

fn is_symbol(item: u8) bool {
    return (item != '\n' and item != '.' and (item < 48 or item > 57));
}

fn string_to_u32(array: []u8) u32 {
    var part_val: u32 = 0;
    var index: usize = 0;
    while (index < array.len) : (index += 1) {
        const place_value: usize = array.len - index - 1;
        const digit_value = @as(u32, array[index] - 48);
        var multiplier: u32 = 1;
        for (0..place_value) |_| {
            multiplier *= 10;
        }
        part_val += (digit_value * multiplier);
    }
    return part_val;
}

fn part_value(number: []u8, row: usize, col: usize, table: []const u8, line_width: usize) u32 {
    const start: usize = if (col == 0) 0 else col - 1;
    const end: usize = if (col + number.len > line_width - 1) line_width - 1 else col + number.len;

    var x: usize = start;
    var y: usize = if (row == 0) 0 else row - 1;

    // std.debug.print("checking from {} to {} for line {} starting at {}\n", .{ start, end, row, col });

    return while ((y < row + 1) or (x < end + 1)) {
        // std.debug.print("checking cell {d},{d}", .{ x, y });

        if (x > end or end >= line_width) {
            // std.debug.print(" returning\n", .{});
            x = start;
            y += 1;
            // std.debug.print("next check: {},{}\n", .{ x, y });
            continue;
        } else if (y == row and x >= col and x < col + number.len) {
            // std.debug.print(" with number value\n", .{});
            x += 1;
            // std.debug.print("next check: {},{}\n", .{ x, y });
            continue;
        }

        const cell_number: usize = (y * (line_width + 1)) + x;
        if (cell_number > table.len) break 0;

        const cell = table[cell_number];
        if (is_symbol(cell)) break string_to_u32(number);
        // std.debug.print(" with value {c} at index {any}\n", .{ cell, cell_number });
        x += 1;
    } else 0;
}

pub fn part1(input: []const u8) !u32 {
    var answer: u32 = 0;

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
                // std.debug.print("new answer is {}\n", .{answer});
                number_buffer = std.mem.zeroes([8]u8);
                number_buffer_index = 0;
            }
            row += 1;
            col = 0;
            continue;
        }

        if (char >= 49 and char <= 57) {
            number_buffer[number_buffer_index] = char;
            number_buffer_index += 1;
        } else if (number_buffer_index > 0) {
            const number = number_buffer[0..number_buffer_index];
            answer += part_value(number, row, col - number_buffer_index, input, line_width);
            // std.debug.print("new answer is {}\n", .{answer});
            number_buffer = std.mem.zeroes([8]u8);
            number_buffer_index = 0;
        }

        col += 1;
    }

    return answer;
}
