const std = @import("std");
const common = @import("common");
const solution = @import("solution.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    _ = args.next();
    const input = args.next() orelse unreachable;

    std.debug.print("Answer: {!}", .{solution.exclude_string_integers(input)});
}
