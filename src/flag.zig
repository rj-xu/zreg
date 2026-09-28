const RegRw = @import("reg.zig").RegRw;

fn FlagRw(comptime T: type, comptime E: type, comptime reg_def: RegRw(T)) type {
    return struct {
        pub const reg = reg_def;

        pub fn isSet(comptime flag_bit: E) bool {
            return reg_def.isSetMask(@as(T, 1) << @intFromEnum(flag_bit));
        }

        pub fn isSetAll(comptime flag_bits: []const E) bool {
            comptime var m: T = 0;
            inline for (flag_bits) |flag_bit| m |= @as(T, 1) << @intFromEnum(flag_bit);
            return reg_def.isSetMask(m);
        }
    };
}

pub fn FlagRw32(comptime E: type, comptime reg_def: RegRw(u32)) type {
    return FlagRw(u32, E, reg_def);
}
