const std = @import("std");
const prng = std.Random.DefaultPrng;

pub const Vec3 = struct {
    const Self = @This();
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,

    pub fn new(x: f32, y: f32, z: f32) Vec3 {
        return .{ .x = x, .y = y, .z = z };
    }
};
pub fn add(self: Vec3, other: Vec3) Vec3 {
    return .{
        .x = self.x + other.x,
        .y = self.y + other.y,
        .z = self.z + other.z,
    };
}
pub fn sub(self: Vec3, other: Vec3) Vec3 {
    return .{
        .x = self.x - other.x,
        .y = self.y - other.y,
        .z = self.z - other.z,
    };
}
pub fn scale(self: Vec3, scalar: f32) Vec3 {
    return .{
        .x = self.x * scalar,
        .y = self.y * scalar,
        .z = self.z * scalar,
    };
}
pub fn lengthsq(self: Vec3) f32 {
    const under = self.x * self.x + self.y * self.y + self.z * self.z;
    return under;
}
pub fn magnitude(self: Vec3) f32 {
    const under = self.x * self.x + self.y * self.y + self.z * self.z;
    return @sqrt(under);
}
pub fn dot(self: Vec3, other: Vec3) f32 {
    return self.x * other.x + self.y * other.y + self.z * other.z;
}

pub fn mul(self: Vec3, other: Vec3) Vec3 {
    return Vec3{
        .x = self.x * other.x,
        .y = self.y * other.y,
        .z = self.z * other.z,
    };
}
pub fn cross(self: Vec3, other: Vec3) Vec3 {
    return .{
        .x = self.y * other.z - self.z * other.y,
        .y = self.z * other.x - self.x * other.z,
        .z = self.x * other.y - self.y * other.x,
    };
}
pub fn unit(self: Vec3) Vec3 {
    const len = magnitude(self);
    return .{
        .x = self.x / len,
        .y = self.y / len,
        .z = self.z / len,
    };
}

pub fn random() Vec3 {
    var rng = prng.init(@intCast(std.time.nanoTimestamp()));
    const r = rng.random();
    return .{
        .x = r.float(f32),
        .y = r.float(f32),
        .z = r.float(f32),
    };
}
pub fn randomMinMax(min: f32, max: f32) Vec3 {
    var rng = prng.init(@intCast(std.time.nanoTimestamp()));
    const r = rng.random();
    return .{
        .x = r.float(f32) * (max - min) + min,
        .y = r.float(f32) * (max - min) + min,
        .z = r.float(f32) * (max - min) + min,
    };
}

pub inline fn randomUnitVector() Vec3 {
    while (true) {
        const p = randomMinMax(-1, 1);
        const lensq = lengthsq(p);
        if (lensq <= 1) {
            return scale(p, @sqrt(lensq));
        }
    }
}

pub inline fn randomOnHemisphere(normal: *const Vec3) Vec3 {
    const on_unit_sphere = randomUnitVector();
    if (dot(on_unit_sphere, normal.*) > 0.0) {
        return on_unit_sphere;
    } else {
        return .{
            .x = -on_unit_sphere.x,
            .y = -on_unit_sphere.y,
            .z = -on_unit_sphere.z,
        };
    }
}

pub fn nearZero(vec: Vec3) bool {
    const s = 1e-8;
    return (@abs(vec.x) < s and @abs(vec.y) < s and @abs(vec.z) < s);
}

pub inline fn reflect(vec: Vec3, normal: Vec3) Vec3 {
    return sub(vec, scale(normal, 2 * dot(vec, normal)));
}
