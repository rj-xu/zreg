const Mask = @import("mask.zig").Mask;
const RegRo = @import("reg.zig").RegRo;
const RegRw = @import("reg.zig").RegRw;

pub fn BitFieldRo(comptime T: type) type {
    return struct {
        reg: RegRo(T),
        mask: Mask(T),

        pub inline fn read(comptime self: @This()) T {
            return self.reg.extract(self.mask);
        }
    };
}

pub fn BitField(comptime T: type) type {
    return struct {
        reg: RegRw(T),
        mask: Mask(T),

        pub inline fn read(comptime self: @This()) T {
            return self.reg.extract(self.mask);
        }

        pub inline fn write(comptime self: @This(), val: T) void {
            self.reg.modify(self.mask, val);
        }
    };
}

pub fn BfBool(comptime T: type) type {
    return struct {
        reg: RegRw(T),
        mask: RegRw(T).Mask,

        pub inline fn read(comptime self: @This()) bool {
            return self.reg.extract(self.mask) != 0;
        }

        pub inline fn write(comptime self: @This(), val: bool) void {
            self.reg.modify(self.mask, if (val) 1 else 0);
        }
    };
}

pub fn BfEnum(comptime T: type, comptime E: type) type {
    return struct {
        reg: RegRw(T),
        mask: Mask(T),

        pub inline fn read(comptime self: @This()) E {
            return @enumFromInt(self.reg.extract(self.mask));
        }

        pub inline fn write(comptime self: @This(), val: E) void {
            self.reg.modify(self.mask, @intFromEnum(val));
        }
    };
}

pub fn BfTrigger(comptime T: type) type {
    return struct {
        reg: RegRw(T),
        mask: Mask(T),
        trigger0: T = 1,
        trigger1: T = 0,

        pub inline fn trigger(comptime self: @This()) void {
            self.reg.modify(self.mask, self.trigger0);
            self.reg.modify(self.mask, self.trigger1);
        }
    };
}
