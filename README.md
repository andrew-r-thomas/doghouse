## doghouse

doghouse is a pitch detection library written in the zig language. It's still in very early stages, and for now it just implements the [Yin pitch detection algorithm](http://audition.ens.fr/adc/pdf/2002_JASA_YIN.pdf).

the name is inspired by [this wonderful article](https://www.objc.io/issues/24-audio/audio-dog-house/).

## usage

```zig
const doghouse = @import("doghouse");

const yin = doghouse.Yin(1024);
var A: [1024]f32 = undefined;
for (0..1024) |i| {
    A[i] = @sin(@as(f32, @floatFromInt(i)) * std.math.pi * 2 * 440);
}

const yin = dogohouse.Yin(1024);
const pitch = yin.detect_pitch(A, 44100);

std.debug.assert(std.math.approxEqAbs(f32, pitch, 440.0, 1.0));
```
