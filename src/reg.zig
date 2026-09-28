const std = @import("std");
const mask = @import("mask.zig");
const field = @import("field.zig");

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

fn Reg(comptime T: type) type {
    const read_fmt = std.fmt.comptimePrint("Read Reg([0x{{X:0>4}}], {{d}}) = 0x{{X:0>{d}}}\n", .{@bitSizeOf(T) / 4});
    const write_fmt = std.fmt.comptimePrint("Write Reg([0x{{X:0>4}}], {{d}}) = 0x{{X:0>{d}}}\n", .{@bitSizeOf(T) / 4});

    return struct {
        pub fn read(comptime addr: u32) T {
            const gop = map.getOrPutValue(addr, rng.random().int(u32)) catch
                @panic("zreg: out of memory while caching register");
            const val: T = @truncate(gop.value_ptr.*);
            std.debug.print(read_fmt, .{ addr, @sizeOf(T), val });
            return val;
        }

        pub fn extract(comptime addr: u32, comptime m: mask.Mask(T)) T {
            return m.extract(read(addr));
        }

        pub fn write(comptime addr: u32, val: T) void {
            map.putAssumeCapacity(addr, val);
            std.debug.print(write_fmt, .{ addr, @sizeOf(T), val });
        }

        pub fn modify(comptime addr: u32, comptime m: mask.Mask(T), val: T) void {
            write(addr, m.insert(read(addr), val));
        }

        pub fn isSetMask(comptime addr: u32, m: T) bool {
            return read(addr) & m == m;
        }
    };
}

pub fn RegRo(comptime T: type) type {
    return struct {
        addr: u32,

        const Self = @This();
        const Mask = mask.Mask(T);
        const RegOpt = Reg(T);
        const Shift = std.math.Log2Int(T);

        pub fn read(comptime self: Self) T {
            return RegOpt.read(self.addr);
        }

        pub fn extract(comptime self: Self, comptime m: Mask) T {
            return RegOpt.extract(self.addr, m);
        }

        pub fn bit(comptime self: Self, comptime b: Shift) field.BitFieldRo(T) {
            return self.bits(b, b);
        }

        pub fn bits(comptime self: Self, comptime hi: Shift, comptime lo: Shift) field.BitFieldRo(T) {
            return .{ .reg = self, .mask = Mask.bits(hi, lo) };
        }

        pub fn isSetMask(comptime self: Self, m: T) bool {
            return RegOpt.isSetMask(self.addr, m);
        }
    };
}

pub fn RegRw(comptime T: type) type {
    return struct {
        addr: u32,

        const Self = @This();
        const Mask = mask.Mask(T);
        const RegOpt = Reg(T);
        const Shift = std.math.Log2Int(T);

        pub fn read(comptime self: Self) T {
            return RegOpt.read(self.addr);
        }

        pub fn extract(comptime self: Self, comptime m: Mask) T {
            return RegOpt.extract(self.addr, m);
        }

        pub fn write(comptime self: Self, val: T) void {
            RegOpt.write(self.addr, val);
        }

        pub fn modify(comptime self: Self, comptime m: Mask, val: T) void {
            RegOpt.modify(self.addr, m, val);
        }

        pub fn bit(comptime self: Self, comptime b: Shift) field.BitField(T) {
            return self.bits(b, b);
        }

        pub fn bits(comptime self: Self, comptime hi: Shift, comptime lo: Shift) field.BitField(T) {
            return .{ .reg = self, .mask = Mask.bits(hi, lo) };
        }

        pub fn isSetMask(comptime self: Self, m: T) bool {
            return RegOpt.isSetMask(self.addr, m);
        }
    };
}

pub const RegRo32 = RegRo(u32);
pub const RegRo16 = RegRo(u16);
pub const RegRo8 = RegRo(u8);
pub const RegRw32 = RegRw(u32);
pub const RegRw16 = RegRw(u16);
pub const RegRw8 = RegRw(u8);

test {
    try init(std.testing.allocator);
    defer deinit();

    const r16 = comptime RegRw16{ .addr = 0x2000 };
    r16.write(0x1234);
    try std.testing.expectEqual(@as(u16, 0x1234), r16.read());

    const bf = comptime r16.bits(7, 4);
    bf.write(0xA);
    try std.testing.expectEqual(@as(u16, 0xA), bf.read());
    try std.testing.expectEqual(@as(u16, 0x12A4), r16.read());

    const r8 = comptime RegRo8{ .addr = 0x3000 };
    const b3 = comptime r8.bit(3);
    _ = b3.read();
}
