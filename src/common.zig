const std = @import("std");
const print = std.debug.print;

pub fn get_input() ![:0]const u8 {
    const allocator = std.heap.page_allocator;
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    _ = args.next();
    const input = args.next() orelse unreachable;
    return input;
}
