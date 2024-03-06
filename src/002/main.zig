const std = @import("std");

const N_RED_CUBES = 12;
const N_GREEN_CUBES = 13;
const N_BLUE_CUBES = 14;

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

    const answer: u32 = 0;

    std.debug.print("Answer: {d}", .{answer});
}
