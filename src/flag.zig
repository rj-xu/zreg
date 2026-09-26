const enums = @import("std").enums;

const RegRw = @import("reg.zig").RegRw;
const bit = @import("mask.zig").bit;

pub fn flag(comptime E: type, comptime reg_def: RegRw) type {
    return struct {
        pub const reg = reg_def;

        pub fn isSet(flag_bit: E) bool {
            return reg.maskIsSet(@as(u32, 1) << @intFromEnum(flag_bit));
        }

        pub fn isSetAll(comptime flag_bits: []const E) bool {
            comptime var m: u32 = 0;
            inline for (flag_bits) |flag_bit| m |= @as(u32, 1) << @intFromEnum(flag_bit);
            return reg_def.maskIsSet(m);
        }
    };
}
