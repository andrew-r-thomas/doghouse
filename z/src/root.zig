const std = @import("std");
const testing = std.testing;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}

// TODO think about padding
// TODO we might need a min
const size: usize = 1024;
const window_size: usize = size / 2;
const thresh = 0.1;

pub fn detect_pitch(signal: [size]f32, sample_rate: usize) usize {

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
