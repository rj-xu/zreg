const std = @import("std");

const zreg = @import("zreg");

const RegRw32 = zreg.RegRw32;
const FlagRw32 = zreg.FlagRw32;

const CRYPTO = struct {
    const BASE = 0x1a00;
    const CONFIG = struct {
        pub const REG = RegRw32{ .addr = BASE + 0x00 };

        pub const EVENT_NUM = REG.bits(1, 0);
        pub const EVENT_EN = REG.bit(3);
        pub const EVENT_ID = REG.bits(5, 4);
    };
};

const X = enum(u5) {
    X1 = 0,
    X2,
    X3,

    const Flag = FlagRw32(@This(), RegRw32{ .addr = 0x1a00 });
};

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();

    try zreg.init(gpa.allocator());
    defer zreg.deinit();

    std.debug.print("Hello, World!\n", .{});

    const a = CRYPTO.CONFIG.EVENT_NUM.read();
    std.debug.print("a: {}\n", .{a});

    const b = CRYPTO.CONFIG.EVENT_EN.read();
    std.debug.print("b: {}\n", .{b});

    const c = CRYPTO.CONFIG.EVENT_ID.read();
    std.debug.print("c: {}\n", .{c});

    const d = X.Flag.isSet(X.X1);
    std.debug.print("d: {}\n", .{d});

    const e = X.Flag.isSetAll(&.{ X.X1, X.X2 });
    std.debug.print("e: {}\n", .{e});
}
