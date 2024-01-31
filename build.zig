const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const main = b.addExecutable(.{
        .name = "doghouse",
        .target = target,
    });
    main.addCSourceFile(.{
        .file = .{ .path = "main.c" },
    });
    const info = b.addStaticLibrary(.{
        .name = "info.plist",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .path = "info.zig" },
    });
    main.linkLibrary(info);

    b.installArtifact(main);
}
