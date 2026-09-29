const mask = @import("mask.zig");
pub const Mask32 = mask.Mask32;

const reg = @import("reg.zig");

pub const init = @import("reg.zig").init;
pub const deinit = @import("reg.zig").deinit;

pub const RegRw32 = reg.RegRw32;
pub const RegRw16 = reg.RegRw16;
pub const RegRw8 = reg.RegRw8;

pub const RegRo32 = reg.RegRo32;
pub const RegRo16 = reg.RegRo16;
pub const RegRo8 = reg.RegRo8;

pub const RegRoBytes = reg.RegRoBytes;
pub const RegRwBytes = reg.RegRwBytes;

const flag = @import("flag.zig");
pub const FlagRw32 = flag.FlagRw32;
