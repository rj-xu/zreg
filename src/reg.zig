const std = @import("std");
const builtin = @import("builtin");
const Mask = @import("mask.zig").Mask;
const Field = @import("field.zig").Field;

var rng: std.Random.DefaultPrng = undefined;

pub fn init() void {
    var threaded: std.Io.Threaded = .init(std.mem.Allocator.failing, .{});
    defer threaded.deinit();
    // var seed: u64 = undefined;
    // threaded.io().random(std.mem.asBytes(&seed));
    const seed = 0;
    rng = std.Random.DefaultPrng.init(seed);
}

pub const RegRw = struct {
    addr: u32,
    size: u32,

    pub fn read(comptime self: RegRw, comptime mask: ?Mask) u32 {
        var val = rng.random().int(u32);
        std.debug.print("Read Reg([0x{X}], {d}) = 0x{X}", .{ self.addr, self.size, val });
        if (mask) |m| {
            val = m.extract(val);
        }
        return val;
    }
    pub fn write(comptime self: RegRw, val: u32) void {
        std.debug.print("Write Reg([0x{X}], {d}) = 0x{X}", .{ self.addr, self.size, val });
    }

    pub fn modify(comptime self: RegRw, comptime mask: Mask, val: u32) void {
        const rv = self.read(mask);
        const wv = mask.insert(rv, val);
        self.write(wv);
    }

    pub fn bit(comptime self: RegRw, comptime b: u5) Field {
        return self.bits(b, b);
    }

    pub fn bits(comptime self: RegRw, comptime e: u5, comptime s: ?u5) Field {
        return .{ .reg = self, .mask = Mask.bits(e, s) };
    }

    pub fn maskIsSet(comptime self: RegRw, mask: u32) bool {
        return self.read(null) & mask == mask;
    }
};
