const std = @import("std");
const vec3 = @import("vec.zig").Vec3;
const Interval = @import("interval.zig");

pub inline fn linearToGamma(linear: f32) f32 {
    if (linear > 0) {
        return @sqrt(linear);
    }
    return 0;
}

pub const Color = struct {
    const Self = @This();
    r: f32,
    g: f32,
    b: f32,

    pub fn writeColor(self: *const Self, file: *std.fs.File) !void {
        @setRuntimeSafety(false);

        const int = Interval.new(0.000, 0.999);
        const ir: u8 = @intFromFloat(
            (256 * int.clamp(linearToGamma(self.r))),
        );
        const ig: u8 = @intFromFloat(
            (256 * int.clamp(linearToGamma(self.g))),
        );
        const ib: u8 = @intFromFloat(
            (256 * int.clamp(linearToGamma(self.b))),
        );
        const pixel = &[_]u8{ ir, ig, ib };

        try file.writeAll(pixel);
    }

    pub fn new(r: f32, g: f32, b: f32) Color {
        return .{ .r = r, .g = g, .b = b };
    }

    pub fn colorToVec(self: *Self) vec3 {
        return .{
            .x = self.r,
            .y = self.g,
            .z = self.b,
        };
    }

    pub fn add(self: *Self, color: Color) void {
        self.r += color.r;
        self.g += color.g;
        self.b += color.b;
    }

    pub fn scale(self: *Self, scalar: f32) void {
        self.r *= scalar;
        self.g *= scalar;
        self.b *= scalar;
    }
    pub fn mul(self: *Color, other: Color) void {
        self.r = self.r * other.r;
        self.g = self.g * other.g;
        self.b = self.b * other.b;
    }
};
pub fn colorFromVec(vec: vec3) Color {
    return .{
        .r = vec.x,
        .g = vec.y,
        .b = vec.z,
    };
}
