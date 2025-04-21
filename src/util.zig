const std = @import("std");

pub const inf_f32 = std.math.inf(f32);
pub const pi = std.math.pi;

pub inline fn degreesToRadians(degree: f32) f32 {
    return degree * pi / 180;
}
