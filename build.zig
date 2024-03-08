const std = @import("std");

fn get_day_directory(day: u8) ![3]u8 {
    var mainfile = [3]u8{ '0', '0', '0' };
    var number = day;
    var index: usize = 0;

    while (number > 0) {
        const place_index: usize = 2 - index;
        const digit = @mod(number, 10);
        mainfile[place_index] = 48 + digit;

        number = @divFloor(number, 10);
        index += 1;
    }

    return mainfile;
}

pub fn build(b: *std.Build) !void {
    b.top_level_steps = .{};

    // get options
    const day = b.option(u8, "d", "Day") orelse 1;
    const part = b.option(u8, "p", "Part") orelse 1;
    const input = b.option([]const u8, "i", "Input filename without extension") orelse "main";
    std.debug.print("Running Day:`{}` Part:`{}` Input:`{s}`\n", .{ day, part, input });

    // generate filenames
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const day_directory = try get_day_directory(day);
    const mainfile_alloc = gpa.allocator();
    const mainfile = try std.fmt.allocPrint(mainfile_alloc, "src/{s}/part{d}.zig", .{ day_directory, part });
    defer mainfile_alloc.free(mainfile);
    const inputfile_alloc = gpa.allocator();
    const inputfile_path = try std.fmt.allocPrint(inputfile_alloc, "src/{s}/inputs/{s}.txt", .{ day_directory, input });
    defer inputfile_alloc.free(inputfile_path);

    // create artifact
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "advent-of-code-in-zig",
        .root_source_file = .{ .path = mainfile },
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    // add common module
    const common_module = b.addModule("common", .{
        .source_file = .{ .path = "src/common.zig" },
    });
    exe.addModule("common", common_module);

    // create run step
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run app");
    run_step.dependOn(&run_cmd.step);

    // add run arguments
    const inputfile = try std.fs.cwd().openFile(inputfile_path, .{});
    defer inputfile.close();
    var input_buffer: [1024 * 1024]u8 = undefined;
    const bytes_read = try inputfile.read(&input_buffer);
    run_cmd.addArg(input_buffer[0..bytes_read]);
}
