const std = @import("std");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    const check: [size]f32 = [_]f32{0.0} ** size;
    const pitch = detect_pitch(check);
    _ = pitch;

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

// TODO think about padding
const size: usize = 1024;
const window_size: usize = size / 2;

fn detect_pitch(signal: [size]f32) f32 {
    // // TODO see if we can SIMD
    // // TODO only use one array if possible
    var diffs: [window_size]f32 = undefined;
    for (0..window_size) |lag| {
        diffs[lag] = diff_fn(lag, signal);
    }

    var cmndfs: [window_size]f32 = undefined;
    for (0..window_size) |lag| {
        cmndfs[lag] = cmndf(lag, diffs);
    }

    return 0.0;
}

fn diff_fn(lag: usize, signal: [size]f32) f32 {
    const x: @Vector(window_size, f32) = signal[0..window_size].*;
    // this is a little silly, i feel like the compiler could be smarter
    const x_lag: @Vector(window_size, f32) = signal[lag..(lag + window_size)][0..window_size].*;

    const diff = x - x_lag;

    return @reduce(.Add, diff * diff);
}

fn cmndf(comptime lag: usize, diffs: [window_size]f32) f32 {
    if (lag == 0) return 1;

    const vec: @Vector(lag, f32) = diffs[0..lag].*;
    const sum = @reduce(.Add, vec);
    return diffs[lag] / (sum / lag);
}
