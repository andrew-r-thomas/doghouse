const std = @import("std");
const sysaudio = @import("mach-sysaudio");
const doghouse = @import("doghouse");

// Note: this Info.plist file gets embedded into the final binary __TEXT,__info_plist
// linker section. On macOS this means that NSMicrophoneUsageDescription is set. Without
// that being set, the application would be denied access to the microphone (the prompt
// for microphone access would not even appear.)
//
// The linker is just a convenient way to specify this without building a .app bundle with
// a separate Info.plist file.
export var __info_plist: [663:0]u8 linksection("__TEXT,__info_plist") =
    (
    \\ <?xml version="1.0" encoding="UTF-8"?>
    \\ <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    \\ <plist version="1.0">
    \\ <dict>
    \\   <key>CFBundleDevelopmentRegion</key>
    \\   <string>English</string>
    \\   <key>CFBundleIdentifier</key>
    \\   <string>com.my.app</string>
    \\   <key>CFBundleInfoDictionaryVersion</key>
    \\   <string>6.0</string>
    \\   <key>CFBundleName</key>
    \\   <string>myapp</string>
    \\   <key>CFBundleDisplayName</key>
    \\   <string>My App</string>
    \\   <key>CFBundleVersion</key>
    \\   <string>1.0.0</string>
    \\   <key>NSMicrophoneUsageDescription</key>
    \\   <string>To record audio from your microphone</string>
    \\ </dict>
    \\ </plist>
).*;

var recorder: sysaudio.Recorder = undefined;

pub fn main() !void {
    _ = __info_plist;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var ctx = try sysaudio.Context.init(null, gpa.allocator(), .{});
    defer ctx.deinit();
    try ctx.refresh();

    const device = ctx.defaultDevice(.capture) orelse return error.NoDevice;

    recorder = try ctx.createRecorder(device, readCallback, .{});
    defer recorder.deinit();

    try recorder.start();

    while (true) {}
}

const yin = doghouse.Yin(1024, 0.1);
var buff: [1024]f32 = [_]f32{0.0} ** 1024;
fn readCallback(_: ?*anyopaque, input: []const u8) void {
    const format_size = recorder.format().size();
    const samples = input.len / format_size;
    std.mem.rotate(f32, &buff, samples);

    sysaudio.convertFrom(f32, buff[samples..], recorder.format(), input);
    const htz: usize = @intFromFloat(yin.detect_pitch(buff, recorder.sampleRate()));
    // TODO put in a separate thread
    std.debug.print("{d} hertz\n", .{htz});
}
