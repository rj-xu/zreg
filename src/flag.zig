const enums = @import("std").enums;

const RegRw = @import("reg.zig").RegRw;
const bit = @import("mask.zig").bit;

pub fn flag(comptime E: type, comptime reg_def: RegRw) type {
    return struct {
        pub const reg = reg_def;

        pub const Set = enums.EnumSet(E);

        pub fn isSet(flag_bit: E) bool {
            return reg.maskIsSet(@as(u32, 1) << @intFromEnum(flag_bit));
        }

        pub fn isSetAll(flag_bits: enums.EnumSet(E)) bool {
            var m: u32 = 0;
            inline for (@typeInfo(E).@"enum".fields) |f| {
                if (flag_bits.contains(@enumFromInt(f.value))) m |= @as(u32, 1) << @intCast(f.value);
            }
            return reg.maskIsSet(m);
        }

        pub fn isSetUnsafe(flag_bits: []const E) bool {
            comptime var m: u32 = 0;
            inline for (flag_bits) |flag_bit| m |= @as(u32, 1) << @intFromEnum(flag_bit);
            return reg_def.maskIsSet(m);
        }
    };
}
