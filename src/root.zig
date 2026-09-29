const mask = @import("mask.zig");

pub const Mask32 = mask.Mask32;
pub const Mask16 = mask.Mask16;
pub const Mask8 = mask.Mask8;

const reg = @import("reg.zig");

pub const init = reg.init;
pub const deinit = reg.deinit;

pub const RegRw32 = reg.RegRw32;
pub const RegRw16 = reg.RegRw16;
pub const RegRw8 = reg.RegRw8;

pub const RegRo32 = reg.RegRo32;
pub const RegRo16 = reg.RegRo16;
pub const RegRo8 = reg.RegRo8;

pub const RegWo32 = reg.RegWo32;
pub const RegWo16 = reg.RegWo16;
pub const RegWo8 = reg.RegWo8;

pub const RegRoBytes = reg.RegRoBytes;
pub const RegWoBytes = reg.RegWoBytes;
pub const RegRwBytes = reg.RegRwBytes;

const field = @import("field.zig");

pub const BitFieldRo = field.BitFieldRo;
pub const BitField = field.BitField;
pub const BfBoolRo = field.BfBoolRo;
pub const BfBool = field.BfBool;
pub const BfEnumRo = field.BfEnumRo;
pub const BfEnum = field.BfEnum;
pub const BfTrigger = field.BfTrigger;

const flag = @import("flag.zig");

pub const FlagRo32 = flag.FlagRo32;
pub const FlagRw32 = flag.FlagRw32;
pub const FlagRo16 = flag.FlagRo16;
pub const FlagRw16 = flag.FlagRw16;
pub const FlagRo8 = flag.FlagRo8;
pub const FlagRw8 = flag.FlagRw8;
