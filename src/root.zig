const mask = @import("mask.zig");
pub const Mask32 = mask.Mask32;

const reg = @import("reg.zig");
pub const init = @import("reg.zig").init;
pub const deinit = @import("reg.zig").deinit;
pub const RegRw32 = reg.RegRw32;
pub const RegRw16 = reg.RegRw16;
pub const RegRw8 = reg.RegRw8;

const flag = @import("flag.zig");
pub const FlagRw32 = flag.FlagRw32;
