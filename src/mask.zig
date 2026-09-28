const std = @import("std");

pub fn Mask(comptime T: type) type {
    return struct {
        start: Shift,
        mask: T,

        const Self = @This();
        const Shift = std.math.Log2Int(T);

        pub fn bit(comptime b: Shift) Self {
            return .{ .start = b, .mask = @as(T, 1) << b };
        }

        pub fn bits(comptime hi: Shift, comptime lo: Shift) Self {
            if (hi < lo) @compileError("hi must be greater than or equal to lo");

            const len = @as(u32, hi) - @as(u32, lo) + 1;
            return .{
                .start = lo,
                .mask = (std.math.maxInt(T) >> (@bitSizeOf(T) - len)) << lo,
            };
        }

        pub inline fn get(comptime self: Self, v: T) T {
            return v & self.mask;
        }

        pub inline fn set(comptime self: Self, v: T) T {
            return v | self.mask;
        }

        pub inline fn clear(comptime self: Self, v: T) T {
            return v & ~self.mask;
        }

        pub inline fn toggle(comptime self: Self, v: T) T {
            return v ^ self.mask;
        }

        pub inline fn isSet(comptime self: Self, v: T) bool {
            return (v & self.mask) == self.mask;
        }

        pub inline fn isClear(comptime self: Self, v: T) bool {
            return (v & self.mask) == 0;
        }

        pub inline fn extract(comptime self: Self, val: T) T {
            return self.get(val) >> self.start;
        }

        pub inline fn insert(comptime self: Self, v: T, x: T) T {
            return self.clear(v) | ((x << self.start) & self.mask);
        }
    };
}

pub const Mask32 = Mask(u32);
pub const Mask16 = Mask(u16);
pub const Mask8 = Mask(u8);

test {
    try std.testing.expectEqual(@as(u32, 0xFFFF_FFFF), Mask32.bits(31, 0).mask);
    try std.testing.expectEqual(@as(u32, 0x3), Mask32.bits(1, 0).mask);
    try std.testing.expectEqual(@as(u32, 0x8000_0000), Mask32.bit(31).mask);
    try std.testing.expectEqual(@as(u16, 0xFFFF), Mask16.bits(15, 0).mask);
    try std.testing.expectEqual(@as(u16, 0x00F0), Mask16.bits(7, 4).mask);
    try std.testing.expectEqual(@as(u8, 0xFF), Mask8.bits(7, 0).mask);
    try std.testing.expectEqual(@as(u8, 0x18), Mask8.bits(4, 3).mask);
    try std.testing.expectEqual(@as(u8, 0b101), Mask8.bits(2, 0).extract(0b1101));
    try std.testing.expectEqual(@as(u16, 0xF05F), Mask16.bits(7, 4).insert(0xF0FF, 0x5));
}
