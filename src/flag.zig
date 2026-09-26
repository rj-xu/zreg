const enums = @import("std").enums;

const RegRw = @import("reg.zig").RegRw;
const bit = @import("mask.zig").bit;

pub fn flag(comptime E: type, comptime reg_def: RegRw) type {
    return struct {
        pub const reg = reg_def;

        pub fn isSet(comptime flag_bit: E) bool {
            return reg_def.isSetMask(bit(@intFromEnum(flag_bit)));
        }

        pub fn isSetAll(comptime flag_bits: []const E) bool {
            comptime var m: u32 = 0;
            inline for (flag_bits) |flag_bit| m |= bit(@intFromEnum(flag_bit));
            return reg_def.isSetMask(m);
        }
    };
}
