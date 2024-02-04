## doghouse

doghouse is a pitch detection library written in the zig language. It's still in very early stages, and for now it just implements the [Yin pitch detection algorithm](http://audition.ens.fr/adc/pdf/2002_JASA_YIN.pdf).

the name is inspired by [this wonderful article](https://www.objc.io/issues/24-audio/audio-dog-house/).

## usage

```zig
const doghouse = @import("doghouse");

const sec_per_samp: f32 = 1.0 / 44100.0;
var A: [1024]f32 = undefined;

for (0..1024) |i| {
    const float_idx: f32 = @floatFromInt(i);
    const val: f32 = @sin(float_idx * sec_per_samp * std.math.pi * 2 * 100);
    A[i] = val;
}

const yin = Yin(1024);
const pitch = yin.detect_pitch(A, 44100);

std.debug.assert(std.math.approxEqAbs(f32, pitch, 1000, 10));
```
