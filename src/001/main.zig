const std = @import("std");

const INTEGER_STRING_DICTIONARY = [9][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };
const INCLUDE_WORDS = true;

fn is_integer_string_for(integer: usize, string: []const u8) bool {
    if (!INCLUDE_WORDS) return false;

    const integer_string_len = INTEGER_STRING_DICTIONARY[integer].len;
    if (string.len != integer_string_len) return false;

    return for (0..integer_string_len) |index| {
        if (INTEGER_STRING_DICTIONARY[integer][index] != string[index]) {
            break false;
        }
    } else true;
}

fn can_match_integer_string_for(integer: usize, string: []const u8) bool {
    if (!INCLUDE_WORDS) return false;

    return for (0..string.len) |index| {
        if (INTEGER_STRING_DICTIONARY[integer][index] != string[index]) {
            break false;
        }
    } else true;
}

fn can_match_integer_string(string: []const u8) bool {
    if (!INCLUDE_WORDS) return false;

    return for (0..9) |index| {
        if (can_match_integer_string_for(index, string)) {
            break true;
        }
    } else false;
}

fn string_to_integer(string: []const u8) u8 {
    if (string.len == 1 and string[0] >= 49 and string[0] <= 57) {
        return @as(u8, @intCast(string[0] - 48));
    }

    if (!INCLUDE_WORDS) return 0;

    return for (1..10) |integer_index| {
        if (is_integer_string_for(integer_index - 1, string)) {
            break @as(u8, @intCast(integer_index));
        }
    } else 0;
}

fn is_integer_string(string: []const u8) bool {
    if (string.len == 1 and string[0] >= 49 and string[0] <= 57) {
        return true;
    } else if (INCLUDE_WORDS) {
        const integer_string_value = string_to_integer(string);
        return integer_string_value > 0;
    } else {
        return false;
    }
}

fn line_integer(line: []const u8) u8 {
    var first_integer: u8 = 0;
    var last_integer: u8 = 0;
    var search_start: usize = 0;
    var search_end: usize = 1;

    while (search_end <= line.len) {
        // if empty search
        if (search_start == search_end) {
            search_end += 1;
            continue;
        }

        const string_value = line[search_start..search_end];
        // std.debug.print("| {s}\n", .{string_value}); // uncomment for verbose search

        // if string_values is an int
        const integer_value = @as(u8, @intCast(string_to_integer(string_value)));
        if (integer_value > 0) {
            if (first_integer == 0) {
                first_integer = integer_value;
            }
            last_integer = integer_value;
            search_start += 1; // continue the search instead of skipping. this covers "oneight"
            continue;
        }

        if (can_match_integer_string(string_value)) { // if possible match, extend search
            search_end += 1;
            continue;
        } else if (search_end - search_start > 1) { // if not possible match and search is big, pop first character from search
            search_start += 1;
            continue;
        } else { // if not possible match and search is only single character, move onto next character
            search_end += 1;
            continue;
        }
    }

    const current_line_integer = (first_integer * 10) + last_integer;
    // std.debug.print("{d} for {s}\n", .{ current_line_integer, line }); // uncomment for per line search
    return current_line_integer;
}

// run with `zig run .\src\001\main.zig -- src/001/input.txt`
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

    // calculate sum
    var buf: [1024]u8 = undefined;
    var sum: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        sum += @as(u32, @intCast(line_integer(line)));
    }

    std.debug.print("Answer: {d}", .{sum});
}
