const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    _ = target;
    const mode = b.standardReleaseOptions();
    _ = mode;
}
