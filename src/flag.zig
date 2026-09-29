const RegRw = @import("reg.zig").RegRw;
const Mask = @import("mask.zig").Mask;

fn FlagRw(comptime T: type, comptime E: type, comptime reg_def: RegRw(T)) type {
    if (@typeInfo(E) != .@"enum")
        @compileError("FlagRw: E must be an enum type, got " ++ @typeName(E));

    return struct {
        pub const reg = reg_def;

        pub fn isSet(comptime flag_bit: E) bool {
            const m = Mask(T).bit(@intFromEnum(flag_bit));
            return m.isSet(reg_def.read());
        }

        pub fn isSetAll(comptime flag_bits: []const E) bool {
            comptime var m: T = 0;
            inline for (flag_bits) |flag_bit| m |= @as(T, 1) << @intFromEnum(flag_bit);
            const mask: Mask(T) = .{ .start = 0, .mask = m };
            return mask.isSet(reg_def.read());
        }
    };
}

pub fn FlagRw32(comptime E: type, comptime reg_def: RegRw(u32)) type {
    return FlagRw(u32, E, reg_def);
}
