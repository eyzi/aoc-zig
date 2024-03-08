const std = @import("std");

const N_RED_CUBES: u32 = 12;
const N_GREEN_CUBES: u32 = 13;
const N_BLUE_CUBES: u32 = 14;

const COLORS: [3][]const u8 = .{ "red", "green", "blue" };
const COLOR_COUNT: [3]u32 = .{ 12, 13, 14 };

fn is_possible_cubes(current_color: []const u8, current_count: u32) bool {
    return for (COLORS, 0..) |color, index| {
        if (std.mem.eql(u8, color, current_color)) {
            break current_count <= COLOR_COUNT[index];
        }
    } else false;
}

fn game_value(line: []const u8) !u32 {
    var game_number: u32 = 0;
    var is_possible: bool = true;

    var linefeed_separator = std.mem.split(u8, line, "\n");
    var line_sections = std.mem.split(u8, linefeed_separator.next().?, ": ");

    var game_sections = std.mem.split(u8, line_sections.next().?, " ");
    _ = game_sections.next();
    game_number = try std.fmt.parseInt(u32, game_sections.next().?, 10);
    var game_sets = std.mem.split(u8, line_sections.next().?, "; ");

    outer: while (game_sets.next()) |set| {
        var cubes = std.mem.split(u8, set, ", ");
        while (cubes.next()) |cube| {
            var cube_sections = std.mem.split(u8, cube, " ");
            const count = try std.fmt.parseInt(u32, cube_sections.next().?, 10);
            const color = cube_sections.next().?;

            if (!is_possible_cubes(color, count)) {
                is_possible = false;
                break :outer;
            }
        }
    }

    return if (is_possible) game_number else 0;
}

fn game_power(line: []const u8) !u32 {
    var game_number: u32 = 0;
    var max_blue: u32 = 0;
    var max_green: u32 = 0;
    var max_red: u32 = 0;

    var linefeed_separator = std.mem.split(u8, line, "\n");
    var line_sections = std.mem.split(u8, linefeed_separator.next().?, ": ");

    var game_sections = std.mem.split(u8, line_sections.next().?, " ");
    _ = game_sections.next();
    game_number = try std.fmt.parseInt(u32, game_sections.next().?, 10);
    var game_sets = std.mem.split(u8, line_sections.next().?, "; ");

    while (game_sets.next()) |set| {
        var cubes = std.mem.split(u8, set, ", ");
        while (cubes.next()) |cube| {
            var cube_sections = std.mem.split(u8, cube, " ");
            const count = try std.fmt.parseInt(u32, cube_sections.next().?, 10);
            const color = cube_sections.next().?;

            if (std.mem.eql(u8, color, "blue") and count > max_blue) {
                max_blue = count;
            } else if (std.mem.eql(u8, color, "green") and count > max_green) {
                max_green = count;
            } else if (std.mem.eql(u8, color, "red") and count > max_red) {
                max_red = count;
            }
        }
    }

    return max_blue * max_green * max_red;
}

pub fn sum_game_value(input: []const u8) !u32 {
    var answer: u32 = 0;

    var line_buffer: [1024]u8 = std.mem.zeroes([1024]u8);
    var line_char_counter: usize = 0;
    for (input) |char| {
        if (std.mem.eql(u8, &[1]u8{char}, "\n")) {
            const line = line_buffer[0..line_char_counter];
            answer += try game_value(line);
            line_buffer = std.mem.zeroes([1024]u8);
            line_char_counter = 0;
        } else {
            line_buffer[line_char_counter] = char;
            line_char_counter += 1;
        }
    }

    return answer;
}

pub fn sum_game_power(input: []const u8) !u32 {
    var answer: u32 = 0;

    var line_buffer: [1024]u8 = std.mem.zeroes([1024]u8);
    var line_char_counter: usize = 0;
    for (input) |char| {
        if (std.mem.eql(u8, &[1]u8{char}, "\n")) {
            const line = line_buffer[0..line_char_counter];
            answer += try game_power(line);
            line_buffer = std.mem.zeroes([1024]u8);
            line_char_counter = 0;
        } else {
            line_buffer[line_char_counter] = char;
            line_char_counter += 1;
        }
    }

    return answer;
}
