pub const Mask = struct {
    start: u5,
    mask: u32,

    pub fn bit(comptime b: u5) Mask {
        return .{ .start = b, .mask = 1 << b };
    }

    pub fn bits(comptime hi: u5, comptime lo: u5) Mask {
        if (hi < lo) @compileError("hi must be greater than or equal to lo");

        const len = hi - lo + 1;
        return .{
            .start = lo,
            .mask = ((1 << len) - 1) << lo,
        };
    }

    pub inline fn get(comptime self: Mask, v: u32) u32 {
        return v & self.mask;
    }

    pub inline fn set(comptime self: Mask, v: u32) u32 {
        return v | self.mask;
    }

    pub inline fn clear(comptime self: Mask, v: u32) u32 {
        return v & ~self.mask;
    }

    pub inline fn toggle(comptime self: Mask, v: u32) u32 {
        return v ^ self.mask;
    }

    pub inline fn isSet(comptime self: Mask, v: u32) bool {
        return (v & self.mask) == self.mask;
    }

    pub inline fn isClear(comptime self: Mask, v: u32) bool {
        return (v & self.mask) == 0;
    }
    pub inline fn extract(comptime self: Mask, val: u32) u32 {
        return self.get(val) >> self.start;
    }

    pub inline fn insert(comptime self: Mask, v: u32, x: u32) u32 {
        return self.clear(v) | ((x << self.start) & self.mask);
    }
};
