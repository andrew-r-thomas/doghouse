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

fn build_lags(comptime W: i32) @Vector(W, i32) {
    var lags_arr: [W]i32 = undefined;
    for (0..W) |i| {
        lags_arr[i] = i;
    }
    const vec: @Vector(W, i32) = lags_arr;
    return vec;
}

const lags = build_lags(window_size);

fn detect_pitch(signal: [size]f32) f32 {
    const signal_vec: @Vector(size, f32) = signal;
    const diff = diff_fn(0, signal_vec);
    _ = diff;

    // // TODO see if we can SIMD
    // // TODO only use one array if possible
    // var diffs: [window_size]f32 = undefined;
    // for (0..window_size) |lag| {
    //     diffs[lag] = diff_fn(lag, signal);
    // }

    // var cmndfs: [window_size]f32 = undefined;
    // for (0..window_size) |lag| {
    //     cmndfs[lag] = cmndf(lag, diffs);
    // }

    return 0.0;
}

fn diff_fn(lag: i32, signal_vec: @Vector(size, f32)) f32 {
    const x = @shuffle(f32, signal_vec, undefined, lags);
    _ = x;
    const lag_splat: @Vector(window_size, i32) = @splat(@as(i32, lag));
    const mask_x_lag = lags + lag_splat;
    const x_lag = @shuffle(f32, signal_vec, undefined, mask_x_lag);
    _ = x_lag;
    // const x: @Vector(window_size, f32) = signal[0..window_size].*;
    // var x_lag_arr: [window_size]f32 = undefined;
    // x_lag_arr[0] = signal[lag..(lag + window_size)];
    // const x_lag: @Vector(window_size, f32) = x_lag_arr;
    // const diff = x - x_lag;
    // return @reduce(.Add, diff * diff);
    return 0.0;
}

fn cmndf(comptime lag: usize, diffs: [window_size]f32) f32 {
    if (lag == 0) return 1;

    const vec: @Vector(lag, f32) = diffs[0..lag].*;
    const sum = @reduce(.Add, vec);
    return diffs[lag] / (sum / lag);
}
