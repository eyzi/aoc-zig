const std = @import("std");

const N_RED_CUBES: u32 = 12;
const N_GREEN_CUBES: u32 = 13;
const N_BLUE_CUBES: u32 = 14;

const Set = struct {
    u32,
    u32,
    u32,
};

fn is_possible_game(line: []const u8) !u32 {
    var game_number: u32 = 0;
    var is_possible: bool = false;

    var line_sections = std.mem.split(u8, line, ": ");

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

            if ((std.mem.eql(u8, color, "blue") and count > N_BLUE_CUBES) or
                (std.mem.eql(u8, color, "green") and count > N_GREEN_CUBES) or
                (std.mem.eql(u8, color, "red") and count > N_RED_CUBES))
            {
                std.debug.print("Disqualifying Game {d} as it has {d} {s}\n", .{ game_number, count, color });
                return 0;
            }
        }
    }
    is_possible = true;
    if (is_possible) std.debug.print("{d}\n", .{game_number});
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
        answer += try is_possible_game(line);
    }

    std.debug.print("Answer: {d}", .{answer});
}
