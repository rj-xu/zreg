pub const Mask = struct {
    s: u5,
    mask: u32,
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
        return self.get(val) >> self.s;
    }

    pub inline fn insert(comptime self: Mask, v: u32, x: u32) u32 {
        // return self.clear(v) | self.get(x << self.s);
        return self.clear(v) | (x << self.s);
    }

    pub fn bits(comptime e: u5, comptime s: ?u5) Mask {
        const start = s orelse e;
        const l = e - start + 1;
        return .{
            .s = start,
            .mask = ((1 << l) - 1) << start,
        };
    }
};

pub inline fn bit(comptime b: u5) u32 {
    return 1 << b;
}

pub inline fn bits(comptime e: u5, comptime s: u5) Mask {
    if (e < s) @compileError("e must be greater than or equal to s");
    const l = e - s + 1;
    return ((1 << l) - 1) << s;
}
