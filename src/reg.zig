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

fn Reg(comptime T: type, comptime Self: type) type {
    const read_fmt = std.fmt.comptimePrint("Read Reg([0x{{X:0>4}}], {{d}}) = 0x{{X:0>{d}}}\n", .{@bitSizeOf(T) / 4});
    const write_fmt = std.fmt.comptimePrint("Write Reg([0x{{X:0>4}}], {{d}}) = 0x{{X:0>{d}}}\n", .{@bitSizeOf(T) / 4});

    return struct {
        const Mask = mask.Mask(T);
        const Shift = std.math.Log2Int(T);

        pub fn read(comptime self: Self) T {
            const gop = map.getOrPutValue(self.addr, rng.random().int(u32)) catch
                @panic("zreg: out of memory while caching register");
            const val: T = @truncate(gop.value_ptr.*);
            std.debug.print(read_fmt, .{ self.addr, @sizeOf(T), val });
            return val;
        }

        pub fn extract(comptime self: Self, comptime m: Mask) T {
            return m.extract(read(self));
        }

        pub fn write(comptime self: Self, val: T) void {
            map.put(self.addr, val) catch @panic("zreg: out of memory");
            std.debug.print(write_fmt, .{ self.addr, @sizeOf(T), val });
        }

        pub fn modify(comptime self: Self, comptime m: Mask, val: T) void {
            const rv = read(self);
            const wv = m.insert(rv, val);
            write(self, wv);
        }

        pub fn readBytes(comptime self: Self) []const u8 {
            const gop = map.getOrPutValue(self.addr, rng.random().int(u32)) catch
                @panic("zreg: out of memory while caching register");
            return std.mem.asBytes(gop.value_ptr)[0..self.size];
        }

        pub fn writeBytes(comptime self: Self, bytes: []const u8) void {
            const gop = map.getOrPutValue(self.addr, 0) catch
                @panic("zreg: out of memory while caching register");
            @memcpy(std.mem.asBytes(gop.value_ptr)[0..self.size], bytes[0..self.size]);
        }
    };
}

pub fn RegRo(comptime T: type) type {
    return struct {
        addr: u32,

        const Self = @This();
        const Base = Reg(T, Self);

        pub const read = Base.read;
        pub const extract = Base.extract;

        pub fn bit(comptime self: Self, comptime b: Base.Shift) field.BitFieldRo(T) {
            return self.bits(b, b);
        }

        pub fn bits(comptime self: Self, comptime hi: Base.Shift, comptime lo: Base.Shift) field.BitFieldRo(T) {
            return .{ .reg = self, .mask = Base.Mask.bits(hi, lo) };
        }

        pub fn bitBool(comptime self: Self, comptime b: Base.Shift) field.BfBoolRo(T) {
            return .{ .reg = self, .mask = Base.Mask.bit(b) };
        }

        pub fn bitsEnum(comptime self: Self, comptime hi: Base.Shift, comptime lo: Base.Shift, comptime E: type) field.BfEnumRo(T, E) {
            return .{ .reg = self, .mask = Base.Mask.bits(hi, lo) };
        }
    };
}

pub fn RegRw(comptime T: type) type {
    return struct {
        addr: u32,

        const Self = @This();
        const Base = Reg(T, Self);

        pub const read = Base.read;
        pub const extract = Base.extract;
        pub const write = Base.write;
        pub const modify = Base.modify;

        pub fn bit(comptime self: Self, comptime b: Base.Shift) field.BitField(T) {
            return self.bits(b, b);
        }

        pub fn bits(comptime self: Self, comptime hi: Base.Shift, comptime lo: Base.Shift) field.BitField(T) {
            return .{ .reg = self, .mask = Base.Mask.bits(hi, lo) };
        }

        pub fn bitBool(comptime self: Self, comptime b: Base.Shift) field.BfBool(T) {
            return .{ .reg = self, .mask = Base.Mask.bit(b) };
        }

        pub fn bitsEnum(comptime self: Self, comptime hi: Base.Shift, comptime lo: Base.Shift, comptime E: type) field.BfEnum(T, E) {
            return .{ .reg = self, .mask = Base.Mask.bits(hi, lo) };
        }

        pub fn bitTrigger(comptime self: Self, comptime b: Base.Shift) field.BfTrigger(T) {
            return .{ .reg = self, .mask = Base.Mask.bit(b) };
        }
    };
}

/// 只写寄存器：没有位域工厂。位域写是读-改-写，
/// Wo 读不出其他域的当前值，只能整寄存器 write。
pub fn RegWo(comptime T: type) type {
    return struct {
        addr: u32,

        const Self = @This();
        const Base = Reg(T, Self);

        pub const write = Base.write;
    };
}

pub const RegRo32 = RegRo(u32);
pub const RegRo16 = RegRo(u16);
pub const RegRo8 = RegRo(u8);

pub const RegWo32 = RegWo(u32);
pub const RegWo16 = RegWo(u16);
pub const RegWo8 = RegWo(u8);

pub const RegRw32 = RegRw(u32);
pub const RegRw16 = RegRw(u16);
pub const RegRw8 = RegRw(u8);

pub const RegRoBytes = struct {
    addr: u32,
    size: u32,

    const Self = @This();

    pub const readBytes = Reg(u8, Self).readBytes;
};

pub const RegWoBytes = struct {
    addr: u32,
    size: u32,

    const Self = @This();

    pub const writeBytes = Reg(u8, Self).writeBytes;
};

pub const RegRwBytes = struct {
    addr: u32,
    size: u32,

    const Self = @This();

    pub const readBytes = Reg(u8, Self).readBytes;
    pub const writeBytes = Reg(u8, Self).writeBytes;
};

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

    const wo = comptime RegWo16{ .addr = 0x4000 };
    wo.write(0x00FF);
    try std.testing.expectEqual(@as(u32, 0x00FF), map.get(0x4000).?);

    const rb = comptime RegRwBytes{ .addr = 0x5000, .size = 3 };
    rb.writeBytes(&.{ 0xAA, 0xBB, 0xCC });
    try std.testing.expectEqualSlices(u8, &.{ 0xAA, 0xBB, 0xCC }, rb.readBytes());

    const rb2 = comptime RegRoBytes{ .addr = 0x5100, .size = 2 };
    try std.testing.expectEqual(@as(usize, 2), rb2.readBytes().len);

    const r2 = comptime RegRw16{ .addr = 0x2200 };
    r2.write(0);

    const bb = comptime r2.bitBool(3);
    bb.write(true);
    try std.testing.expect(bb.read());

    const Mode = enum(u2) { a, b, c, d };
    const se = comptime r2.bitsEnum(5, 4, Mode);
    se.write(.c);
    try std.testing.expectEqual(Mode.c, se.read());
    try std.testing.expectEqual(@as(u16, 0x28), r2.read());

    const tr = comptime r2.bitTrigger(7);
    tr.trigger();
    try std.testing.expectEqual(@as(u16, 0x28), r2.read()); // 脉冲后回到 low

    const ro2 = comptime RegRo16{ .addr = 0x2200 };
    const rbb = comptime ro2.bitBool(3);
    try std.testing.expect(rbb.read());
    const rse = comptime ro2.bitsEnum(5, 4, Mode);
    try std.testing.expectEqual(Mode.c, rse.read());
}
