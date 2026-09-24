const std = @import("std");

const zreg = @import("zreg");

const RegRw = zreg.RegRw;
const bit = zreg.bit;
const bits = zreg.bits;
const flag = zreg.flag;

const CRYPTO = struct {
    const BASE = 0x1a00;
    const CONFIG = struct {
        pub const REG = RegRw{ .addr = BASE + 0x00, .size = 4 };
        pub const EVENT_NUM = REG.bits(1, 0);
        pub const EVENT_EN = REG.bit(3);
        pub const EVENT_ID = REG.bits(5, 4);
    };
};

const X = enum(u5) {
    X1 = 0,
    X2,
    X3,


    const FLAG = flag(
        @This(),
        RegRw{ .addr = 0x1a00, .size = 4 },
    );
};

pub fn main() void {
    zreg.init();

    std.debug.print("Hello, World!\n", .{});

    const a = CRYPTO.CONFIG.EVENT_NUM.read();
    std.debug.print("a: {d}\n", .{a});

    const b = CRYPTO.CONFIG.EVENT_EN.read();
    std.debug.print("b: {d}\n", .{b});

    const c = CRYPTO.CONFIG.EVENT_ID.read();
    std.debug.print("c: {d}\n", .{c});

    const d = X.FLAG.isSet(X.X1);
    std.debug.print("d: {}\n", .{d});

    const e = X.FLAG.isSetAll(X.FLAG.Set.initMany(&.{ X.X1, X.X2 }));
    std.debug.print("e: {}\n", .{e});

    const f = X.FLAG.isSetUnsafe(.{ X.X1, X.X2 });
    std.debug.print("f: {}\n", .{f});
}
