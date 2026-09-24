const std = @import("std");
const builtin = @import("builtin");
const Mask = @import("mask.zig").Mask;
const Field = @import("field.zig").Field;

var rng: std.Random.DefaultPrng = undefined;
pub var map: std.AutoHashMap(u32, u32) = undefined;

pub fn init(alloc: std.mem.Allocator) !void {
    var threaded: std.Io.Threaded = .init(std.mem.Allocator.failing, .{});
    defer threaded.deinit();
    var seed: u64 = undefined;
    threaded.io().random(std.mem.asBytes(&seed));
    // const seed = 0;
    rng = std.Random.DefaultPrng.init(seed);
    map = std.AutoHashMap(u32, u32).init(alloc);
    try map.ensureTotalCapacity(64);
}

pub fn deinit() void {
    map.deinit();
}

pub const RegRw = struct {
    addr: u32,
    size: u32,

    pub fn read(comptime self: RegRw, comptime mask: ?Mask) u32 {
        const gop = map.getOrPutValue(self.addr, rng.random().int(u32)) catch
            @panic("zreg: out of memory while caching register");
        var val = gop.value_ptr.*;
        std.debug.print("Read Reg([0x{X:0>4}], {d}) = 0x{X:0>8}\n", .{ self.addr, self.size, val });
        if (mask) |m| {
            val = m.extract(val);
        }
        return val;
    }

    pub fn write(comptime self: RegRw, val: u32) void {
        std.debug.print("Write Reg([0x{X:0>4}], {d}) = 0x{X:0>8}", .{ self.addr, self.size, val });
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
