const Util = @import("util.zig");

const Self = @This();
min: f32 = 0,
max: f32 = Util.inf_f32,

pub fn new(x: f32, y: f32) Self {
    return .{
        .min = x,
        .max = y,
    };
}

pub fn size(self: *const Self) f32 {
    return self.max - self.min;
}

pub fn contains(self: *const Self, x: f32) bool {
    return self.min <= x and self.max >= x;
}

pub fn clamp(self: *const Self, x: f32) f32 {
    if (x < self.min) return self.min;
    if (x > self.max) return self.max;
    return x;
}

pub fn surrounds(self: *const Self, x: f32) bool {
    return self.min < x and self.max > x;
}

pub fn empty() Self {
    return .{ .min = Util.inf_f32, .max = -Util.inf_f32 };
}
pub fn universe() Self {
    return .{ .min = -Util.inf_f32, .max = Util.inf_f32 };
}
