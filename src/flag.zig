const std = @import("std");
const RegRo = @import("reg.zig").RegRo;
const RegRw = @import("reg.zig").RegRw;
const Mask = @import("mask.zig").Mask;

fn Flag(comptime T: type, comptime E: type, comptime reg_def: anytype) type {
    if (@typeInfo(E) != .@"enum")
        @compileError("E must be an enum type, got " ++ @typeName(E));

    return struct {
        pub const reg = reg_def;

        pub fn mask(comptime flag_bit: E) Mask(T) {
            return .bit(@intFromEnum(flag_bit));
        }

        pub fn maskAll(comptime flag_bits: []const E) Mask(T) {
            comptime var m: T = 0;
            inline for (flag_bits) |flag_bit| m |= @as(T, 1) << @intFromEnum(flag_bit);
            return .{ .start = 0, .mask = m };
        }

        pub fn isSet(comptime flag_bit: E) bool {
            return mask(flag_bit).isSet(reg_def.read());
        }

        pub fn isSetAll(comptime flag_bits: []const E) bool {
            return maskAll(flag_bits).isSet(reg_def.read());
        }

        pub fn isClear(comptime flag_bit: E) bool {
            return mask(flag_bit).isClear(reg_def.read());
        }

        pub fn isClearAll(comptime flag_bits: []const E) bool {
            return maskAll(flag_bits).isClear(reg_def.read());
        }
    };
}

fn FlagRo(comptime T: type, comptime E: type, comptime reg_def: RegRo(T)) type {
    return Flag(T, E, reg_def);
}

fn FlagRw(comptime T: type, comptime E: type, comptime reg_def: RegRw(T)) type {
    const Base = Flag(T, E, reg_def);

    return struct {
        pub const reg = reg_def;

        pub const mask = Base.mask;
        pub const maskAll = Base.maskAll;

        pub const isSet = Base.isSet;
        pub const isSetAll = Base.isSetAll;
        pub const isClear = Base.isClear;
        pub const isClearAll = Base.isClearAll;

        pub fn set(comptime flag_bit: E) void {
            reg_def.write(mask(flag_bit).set(reg_def.read()));
        }

        pub fn setAll(comptime flag_bits: []const E) void {
            reg_def.write(maskAll(flag_bits).set(reg_def.read()));
        }

        pub fn clear(comptime flag_bit: E) void {
            reg_def.write(mask(flag_bit).clear(reg_def.read()));
        }

        pub fn clearAll(comptime flag_bits: []const E) void {
            reg_def.write(maskAll(flag_bits).clear(reg_def.read()));
        }
    };
}

pub fn FlagRo32(comptime E: type, comptime reg_def: RegRo(u32)) type {
    return FlagRo(u32, E, reg_def);
}

pub fn FlagRw32(comptime E: type, comptime reg_def: RegRw(u32)) type {
    return FlagRw(u32, E, reg_def);
}

pub fn FlagRo16(comptime E: type, comptime reg_def: RegRo(u16)) type {
    return FlagRo(u16, E, reg_def);
}

pub fn FlagRw16(comptime E: type, comptime reg_def: RegRw(u16)) type {
    return FlagRw(u16, E, reg_def);
}

pub fn FlagRo8(comptime E: type, comptime reg_def: RegRo(u8)) type {
    return FlagRo(u8, E, reg_def);
}

pub fn FlagRw8(comptime E: type, comptime reg_def: RegRw(u8)) type {
    return FlagRw(u8, E, reg_def);
}

test {
    const reg_mod = @import("reg.zig");
    try reg_mod.init(std.testing.allocator);
    defer reg_mod.deinit();

    const E = enum(u5) { a = 0, b = 1, c = 2 };
    const F = FlagRw32(E, .{ .addr = 0x30 });
    F.reg.write(0);

    F.set(.b);
    try std.testing.expect(F.isSet(.b));
    try std.testing.expect(F.isClear(.a));

    F.setAll(&.{ .a, .c });
    try std.testing.expect(F.isSetAll(&.{ .a, .b, .c }));

    F.clear(.b);
    F.clearAll(&.{ .a, .c });
    try std.testing.expect(F.isClearAll(&.{ .a, .b, .c }));
}
