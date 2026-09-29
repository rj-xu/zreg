const std = @import("std");
const Mask = @import("mask.zig").Mask;
const RegRo = @import("reg.zig").RegRo;
const RegRw = @import("reg.zig").RegRw;

fn GenBitField(comptime T: type, comptime Self: type) type {
    return struct {
        pub fn read(comptime self: Self) T {
            return self.reg.extract(self.mask);
        }
        pub fn write(comptime self: Self, val: T) void {
            self.reg.modify(self.mask, val);
        }
    };
}

fn GenBfBool(comptime Self: type) type {
    return struct {
        pub fn read(comptime self: Self) bool {
            return self.reg.extract(self.mask) != 0;
        }
        pub fn write(comptime self: Self, val: bool) void {
            self.reg.modify(self.mask, if (val) 1 else 0);
        }
    };
}

fn GenBfEnum(comptime E: type, comptime Self: type) type {
    return struct {
        pub fn read(comptime self: Self) E {
            return @enumFromInt(self.reg.extract(self.mask));
        }
        pub fn write(comptime self: Self, val: E) void {
            self.reg.modify(self.mask, @intFromEnum(val));
        }
    };
}

pub fn BitFieldRo(comptime T: type) type {
    return struct {
        reg: RegRo(T),
        mask: Mask(T),

        const Base = GenBitField(T, @This());
        pub const read = Base.read;
    };
}

pub fn BitField(comptime T: type) type {
    return struct {
        reg: RegRw(T),
        mask: Mask(T),

        const Base = GenBitField(T, @This());
        pub const read = Base.read;
        pub const write = Base.write;
    };
}

pub fn BfBoolRo(comptime T: type) type {
    return struct {
        reg: RegRo(T),
        mask: Mask(T),

        const Base = GenBfBool(@This());
        pub const read = Base.read;
    };
}

pub fn BfBool(comptime T: type) type {
    return struct {
        reg: RegRw(T),
        mask: Mask(T),

        const Base = GenBfBool(@This());
        pub const read = Base.read;
        pub const write = Base.write;
    };
}

pub fn BfEnumRo(comptime T: type, comptime E: type) type {
    return struct {
        reg: RegRo(T),
        mask: Mask(T),

        const Base = GenBfEnum(E, @This());
        pub const read = Base.read;
    };
}

pub fn BfEnum(comptime T: type, comptime E: type) type {
    return struct {
        reg: RegRw(T),
        mask: Mask(T),

        const Base = GenBfEnum(E, @This());
        pub const read = Base.read;
        pub const write = Base.write;
    };
}

pub fn BfTrigger(comptime T: type) type {
    return struct {
        reg: RegRw(T),
        mask: Mask(T),
        high: T = 1,
        low: T = 0,

        pub inline fn trigger(comptime self: @This()) void {
            self.reg.modify(self.mask, self.high);
            self.reg.modify(self.mask, self.low);
        }
    };
}

test {
    const reg_mod = @import("reg.zig");
    try reg_mod.init(std.testing.allocator);
    defer reg_mod.deinit();

    const Mask16 = @import("mask.zig").Mask16;
    const ro = comptime reg_mod.RegRo16{ .addr = 0x6000 };
    const rw = comptime reg_mod.RegRw16{ .addr = 0x6000 };
    rw.write(0b1011_0100); // bit2 = 1, bits(5,4) = 0b11

    const b = comptime BfBoolRo(u16){ .reg = ro, .mask = Mask16.bit(2) };
    try std.testing.expect(b.read());

    const Mode = enum(u2) { a = 0, b = 1, c = 2, d = 3 };
    const e = comptime BfEnumRo(u16, Mode){ .reg = ro, .mask = Mask16.bits(5, 4) };
    try std.testing.expectEqual(Mode.d, e.read());

    const f = comptime BitFieldRo(u16){ .reg = ro, .mask = Mask16.bits(7, 4) };
    try std.testing.expectEqual(@as(u16, 0b1011), f.read());
}
