const std = @import("std");

const VERBOSE = true;

const N_RED_CUBES: u32 = 12;
const N_GREEN_CUBES: u32 = 13;
const N_BLUE_CUBES: u32 = 14;

const COLORS: [3][]const u8 = .{ "red", "green", "blue" };
const COLOR_COUNT: [3]u32 = .{ 12, 13, 14 };

fn is_possible_cubes(current_color: []const u8, current_count: u32) bool {
    std.debug.print("checking {s} with {d}\n", .{ current_color, current_count });
    return for (COLORS, 0..) |color, index| {
        if (std.mem.eql(u8, color, current_color)) {
            break current_count <= COLOR_COUNT[index];
        }
    } else false;
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

fn is_possible_game(line: []const u8) !u32 {
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
                if (VERBOSE) std.debug.print("Disqualifying Game {d} for having {d} {s}\n", .{ game_number, count, color });
                break :outer;
            }
        }
    }

    if (is_possible and VERBOSE) std.debug.print("Counting Game {d}\n", .{game_number});
    return if (is_possible) game_number else 0;
}

pub fn main() !void {
    // get input file
    const allocator = std.heap.page_allocator;
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    _ = args.next(); // exe
    const inputfile = args.next();
    if (inputfile == null) {
        std.debug.print("Input file required.", .{});
        return;
    }

    // get file content
    var file = try std.fs.cwd().openFile(inputfile.?, .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    const in_stream = buf_reader.reader();

    // calculate answer
    var buf: [1024]u8 = undefined;
    var answer: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        // answer += try is_possible_game(line); // part 1
        answer += try game_power(line); // part 2
    }

    std.debug.print("Answer: {d}", .{answer});
}
