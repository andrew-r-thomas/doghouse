const std = @import("std");
const mach_sysaudio = @import("mach_sysaudio");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const doghouse = b.addModule(
        "doghouse",
        .{
            .root_source_file = .{ .path = "src/doghouse.zig" },
            .target = target,
            .optimize = optimize,
        },
    );

    const exe = b.addExecutable(.{
        .name = "example",
        .root_source_file = .{ .path = "examples/example.zig" },
        .target = target,
        .optimize = optimize,
    });

    const mach_sysaudio_dep = b.dependency("mach_sysaudio", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("mach-sysaudio", mach_sysaudio_dep.module("mach-sysaudio"));

    exe.root_module.addImport("doghouse", doghouse);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the example");
    run_step.dependOn(&run_cmd.step);
}
