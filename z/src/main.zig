const std = @import("std");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    const check: [size]f32 = [_]f32{0.0} ** size;
    const pitch = detect_pitch(check, 44100);
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
// TODO we might need a min
const size: usize = 1024;
const window_size: usize = size / 2;
const thresh = 0.1;

fn detect_pitch(signal: [size]f32, sample_rate: usize) usize {

    // // TODO see if we can SIMD
    // // TODO only use one array if possible
    var diffs: [window_size]f32 = undefined;
    for (0..window_size) |lag| {
        diffs[lag] = diff_fn(lag, signal);
    }

    var sample: usize = undefined;
    var min: f32 = undefined;
    var arg_min: usize = undefined;

    // I don't think this for loop is going away,
    // but we might be able to get rid of the rest
    for (0..window_size) |lag| {
        const cmndf_val = cmndf(lag, diffs);
        if (cmndf_val < thresh) {
            sample = lag;
            break;
        } else {
            if (cmndf_val < min) {
                min = cmndf_val;
                arg_min = lag;
            }
        }
    }

    if (sample == undefined) sample = arg_min;

    return sample_rate / sample;
}

fn diff_fn(lag: usize, signal: [size]f32) f32 {
    const x: @Vector(window_size, f32) = signal[0..window_size].*;
    // this is a little silly, i feel like the compiler could be smarter
    const x_lag: @Vector(window_size, f32) = signal[lag..(lag + window_size)][0..window_size].*;

    const diff = x - x_lag;

    return @reduce(.Add, diff * diff);
}

fn cmndf(lag: usize, diffs: [window_size]f32) f32 {
    if (lag == 0) return 1;

    // TODO we can SIMD this somehow, I just know it
    var sum: f32 = 0;
    for (0..lag) |i| {
        sum += diffs[i];
    }

    return diffs[lag] / (sum / @as(f32, @floatFromInt(lag)));
}
