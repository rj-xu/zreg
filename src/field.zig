const Mask = @import("mask.zig").Mask;
const RegRw = @import("reg.zig").RegRw;

pub const Field = struct {
    reg: RegRw,
    mask: Mask,

    pub inline fn read(comptime self: Field) u32 {
        return self.reg.read(self.mask);
    }

    pub inline fn write(comptime self: Field, val: u32) void {
        self.reg.modify(self.mask, val);
    }
};
