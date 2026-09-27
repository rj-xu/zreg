const Mask = @import("mask.zig").Mask;
const RegRw = @import("reg.zig").RegRw;

pub const BitField = struct {
    reg: RegRw,
    mask: Mask,

    pub inline fn read(comptime self: BitField) u32 {
        return self.reg.read(self.mask);
    }

    pub inline fn write(comptime self: BitField, val: u32) void {
        self.reg.modify(self.mask, val);
    }
};

pub const BfBool = struct {
    reg: RegRw,
    mask: Mask,

    pub inline fn read(comptime self: BfBool) bool {
        return self.reg.read(self.mask) != 0;
    }

    pub inline fn write(comptime self: BfBool, val: bool) void {
        self.reg.modify(self.mask, if (val) 1 else 0);
    }
};

pub fn BfEnum(comptime T: type) type {
    return struct {
        reg: RegRw,
        mask: Mask,

        pub inline fn read(comptime self: @This()) T {
            return @intToEnum(T, self.reg.read(self.mask));
        }

        pub inline fn write(comptime self: @This(), val: T) void {
            self.reg.modify(self.mask, @enumToInt(val));
        }
    }
};
